#!/usr/bin/env python3
"""
Best-effort static analyzer for the supplied Luraph v14.4.1-style Luau sample.

This is intentionally a STATIC analyzer:
- it does not execute the protected script;
- it does not emulate the Luraph VM;
- it does not claim to recover original variable names/comments.

Outputs:
  normalized.lua        numeric-literal-normalized copy
  function_inventory.json
  call_graph.json
  vm_opcode_hints.json
  report.txt

Usage:
  python luraph-v14-sample-analyzer.py input.lua output_dir
"""

from pathlib import Path
import re, json, sys, collections

IDENT = r"[A-Za-z_][A-Za-z0-9_]*"

def split_lua_segments(s):
    """Return [(is_code,text)] while approximately protecting strings/comments."""
    out, buf = [], []
    i, n = 0, len(s)

    def flush(code=True):
        nonlocal buf
        if buf:
            out.append((code, "".join(buf)))
            buf = []

    while i < n:
        # line comment / long comment
        if s.startswith("--", i):
            flush(True)
            j = i + 2
            if j < n and s.startswith("[[", j):
                k = s.find("]]", j + 2)
                if k < 0: k = n - 2
                out.append((False, s[i:k+2]))
                i = k + 2
            else:
                k = s.find("\n", j)
                if k < 0: k = n
                out.append((False, s[i:k]))
                i = k
            continue

        ch = s[i]
        if ch in ("'", '"'):
            flush(True)
            quote = ch
            j = i + 1
            while j < n:
                if s[j] == "\\":
                    j += 2
                    continue
                if s[j] == quote:
                    j += 1
                    break
                j += 1
            out.append((False, s[i:j]))
            i = j
            continue

        # basic Lua long string [[...]]
        if s.startswith("[[", i):
            flush(True)
            k = s.find("]]", i + 2)
            if k < 0: k = n - 2
            out.append((False, s[i:k+2]))
            i = k + 2
            continue

        buf.append(ch)
        i += 1

    flush(True)
    return out

def normalize_numeric_literals(s):
    """Normalize binary/hex/underscore integer literals in CODE only."""
    parts = []
    for is_code, seg in split_lua_segments(s):
        if not is_code:
            parts.append(seg)
            continue

        # remove underscores only inside number tokens
        def clean_num(m):
            return m.group(0).replace("_", "")
        seg = re.sub(r"(?<![\w.])(?:0[xX][0-9A-Fa-f_]+|0[bB][01_]+|\d[\d_]*)(?![\w.])",
                     clean_num, seg)

        def b2d(m):
            try: return str(int(m.group(1), 2))
            except: return m.group(0)
        def h2d(m):
            try: return str(int(m.group(1), 16))
            except: return m.group(0)

        seg = re.sub(r"(?<![\w.])0[bB]([01]+)(?![\w.])", b2d, seg)
        seg = re.sub(r"(?<![\w.])0[xX]([0-9A-Fa-f]+)(?![\w.])", h2d, seg)
        parts.append(seg)
    return "".join(parts)

def find_matching_end(s, func_start):
    """
    Approximate lexical function-end matcher.
    Tracks Lua block starters/enders in code-only text.
    Good enough for inventory extraction on the supplied sample.
    """
    token_re = re.compile(r"\b(function|if|for|while|repeat|do|end|until)\b")
    depth = 0
    started = False

    # Mask strings/comments to spaces, preserving offsets
    masked = []
    for code, seg in split_lua_segments(s):
        masked.append(seg if code else (" " * len(seg)))
    m = "".join(masked)

    for tm in token_re.finditer(m, func_start):
        tok = tm.group(1)
        if tok == "function":
            depth += 1
            started = True
        elif tok in ("if","for","while","do"):
            # "for/while ... do" would double count if both counted.
            # Count if/for/while, ignore standalone do for simplicity.
            if tok != "do":
                depth += 1
        elif tok == "repeat":
            depth += 1
        elif tok in ("end","until"):
            depth -= 1
            if started and depth == 0:
                return tm.end()
    return None

def extract_named_members(s):
    """
    Extract table members in the common Luraph form:
      name=function(...)
      name=(function(...)
    """
    masked = []
    for code, seg in split_lua_segments(s):
        masked.append(seg if code else (" " * len(seg)))
    m = "".join(masked)

    pat = re.compile(r"(?<![\w.])(" + IDENT + r")\s*=\s*\(?\s*function\s*\(")
    items = []
    seen = set()
    for hit in pat.finditer(m):
        name = hit.group(1)
        fpos = m.find("function", hit.start(), hit.end()+10)
        if fpos < 0: continue
        end = find_matching_end(s, fpos)
        if not end: continue
        key = (name, hit.start())
        if key in seen: continue
        seen.add(key)
        body = s[fpos:end]
        items.append({
            "name": name,
            "start": hit.start(),
            "end": end,
            "chars": end-hit.start(),
            "body": body
        })
    return items

def extract_aliases(s):
    # Common top-level simple aliases like z4=string.sub, o=bit32
    masked = []
    for code, seg in split_lua_segments(s):
        masked.append(seg if code else (" " * len(seg)))
    m = "".join(masked)
    aliases = {}
    for hit in re.finditer(r"(?<![\w.])(" + IDENT + r")\s*=\s*(" + IDENT + r"(?:\." + IDENT + r")?)\s*(?=[,}])", m):
        aliases[hit.group(1)] = hit.group(2)
    return aliases

def call_graph(functions):
    names = {f["name"] for f in functions}
    graph = {}
    for f in functions:
        body = f["body"]
        called = set()
        # g:foo(...) style is dominant in the sample
        for x in re.findall(r"\bg:(" + IDENT + r")\s*\(", body):
            if x in names and x != f["name"]:
                called.add(x)
        # direct foo(...) calls
        for x in re.findall(r"(?<![:.\w])(" + IDENT + r")\s*\(", body):
            if x in names and x != f["name"]:
                called.add(x)
        graph[f["name"]] = sorted(called)
    return graph

def opcode_hints(functions):
    """
    Identify dispatcher-style comparisons around variable I.
    The supplied sample's x6 function contains the large virtual instruction loop.
    """
    target = next((f for f in functions if f["name"] == "x6"), None)
    if not target:
        return {"target": None, "opcodes": [], "comparisons": []}

    body = normalize_numeric_literals(target["body"])
    exact = sorted({int(x) for x in re.findall(r"\bI\s*==\s*(-?\d+)", body)})
    ne = sorted({int(x) for x in re.findall(r"\bI\s*~=\s*(-?\d+)", body)})

    comps = []
    for op, val in re.findall(r"\bI\s*(<=|>=|<|>)\s*(-?\d+)", body):
        comps.append({"op": op, "value": int(val)})

    # Also search reversed comparisons: 58 > I
    for val, op in re.findall(r"(-?\d+)\s*(<=|>=|<|>)\s*I\b", body):
        comps.append({"op": "reversed_" + op, "value": int(val)})

    return {
        "target": "x6",
        "exact_opcode_tests": exact,
        "not_equal_tests": ne,
        "range_comparisons": comps,
        "body_chars": len(body),
        "note": "These are static dispatcher tests, not decoded opcode semantics."
    }

def main():
    if len(sys.argv) < 2:
        print("usage: analyzer.py input.lua [output_dir]")
        raise SystemExit(2)

    inp = Path(sys.argv[1])
    od = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("luraph_analysis")
    od.mkdir(parents=True, exist_ok=True)

    s = inp.read_text("utf-8", errors="replace")
    norm = normalize_numeric_literals(s)
    (od / "normalized.lua").write_text(norm, "utf-8")

    funcs = extract_named_members(s)
    aliases = extract_aliases(s)
    graph = call_graph(funcs)
    hints = opcode_hints(funcs)

    inv = []
    for f in funcs:
        b = normalize_numeric_literals(f["body"])
        inv.append({
            "name": f["name"],
            "start_offset": f["start"],
            "end_offset": f["end"],
            "chars": f["chars"],
            "calls": graph.get(f["name"], []),
            "if_count": len(re.findall(r"\bif\b", b)),
            "loop_count": len(re.findall(r"\b(?:for|while|repeat)\b", b)),
        })

    (od / "function_inventory.json").write_text(json.dumps(inv, indent=2), "utf-8")
    (od / "call_graph.json").write_text(json.dumps(graph, indent=2), "utf-8")
    (od / "vm_opcode_hints.json").write_text(json.dumps(hints, indent=2), "utf-8")
    (od / "aliases.json").write_text(json.dumps(aliases, indent=2), "utf-8")

    entry = re.search(r"\):(" + IDENT + r")\(\)\(\.\.\.\)\s*;?\s*$", s)
    entry_name = entry.group(1) if entry else None

    incoming = collections.Counter()
    for src, dsts in graph.items():
        for d in dsts:
            incoming[d] += 1

    report = []
    report.append("Luraph v14 sample static-analysis report")
    report.append("=" * 44)
    report.append(f"Input: {inp.name}")
    report.append(f"Bytes/chars: {len(s.encode('utf-8'))}/{len(s)}")
    report.append(f"Physical lines: {s.count(chr(10))+1}")
    report.append(f"Named function members found: {len(funcs)}")
    report.append(f"Likely final entry member: {entry_name!r}")
    report.append("")
    report.append("Likely VM/loader observations")
    report.append("-----------------------------")
    report.append("- x6 contains the very large dispatcher/interpreter-looking function.")
    report.append("- n4 is the final table member invoked at the end of the file.")
    report.append("- Numeric literals are intentionally mixed hex/binary/underscored decimal forms.")
    report.append("- The analyzer normalizes those literals without executing the script.")
    report.append("")
    report.append("Most-called helper members")
    report.append("--------------------------")
    for name, count in incoming.most_common(20):
        report.append(f"{name:>8} : {count} incoming function references")
    report.append("")
    report.append("x6 static opcode-test summary")
    report.append("-----------------------------")
    report.append(f"Exact I == N tests: {hints.get('exact_opcode_tests', [])}")
    report.append(f"Exact I ~= N tests: {hints.get('not_equal_tests', [])}")
    report.append(f"Range-comparison count: {len(hints.get('range_comparisons', []))}")
    report.append("")
    report.append("Important limitation")
    report.append("--------------------")
    report.append("This does not reconstruct the original unobfuscated source.")
    report.append("A full recovery would require understanding/emulating the VM's serialized")
    report.append("prototype/instruction format and mapping each virtual opcode to semantics.")

    (od / "report.txt").write_text("\n".join(report), "utf-8")
    print("\n".join(report[:25]))
    print(f"\nWrote analysis to: {od}")

if __name__ == "__main__":
    main()
