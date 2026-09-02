if not getgenv().Bk then
    getgenv().Bk = true

    repeat task.wait() until game:IsLoaded()

    --// Kütüphane ve Modüllerin Yüklenmesi
    local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
    local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

    local FlyModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/GeorgeRoblox/LINDOR/refs/heads/main/addonsfolder/Fly.lua"))()
    local Environments = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/Components/Environment.luau"))()

    local Functions = {}
    local Connections = {}
    local Globals = {}

    local Services = setmetatable({}, {
        __index = function(self, Key)
            return game:GetService(Key)
        end
    })

    --// Versiyon Kontrolü
    local VERSION_URL = "https://raw.githubusercontent.com/GeorgeRoblox/version/refs/heads/main/.luau"
    local EXPECTED_VERSION = "v.2.0.0"
    local FILE_NAME = "DONT_DELEATE_BLACKKING"

    if not isfile(FILE_NAME) then
        writefile(FILE_NAME, "VersionCheck Initialized")
    end

    local success, onlineVersion = pcall(function()
        return game:HttpGet(VERSION_URL)
    end)

    if not success then
        warn("Version check failed: Could not fetch version")
        return
    end

    onlineVersion = tostring(onlineVersion):gsub("%s+", "")

    if onlineVersion ~= EXPECTED_VERSION then
        local lp = Services.Players.LocalPlayer
        lp:Kick("Your Playing With The Wrong version of blackking... Current Version: ".. EXPECTED_VERSION)
        return
    end

    --// Entity İsim Eşleştirmeleri
    local EntityShortNames = {
        ["RushMoving"] = "Rush",
        ["AmbushMoving"] = "Ambush",
        ["BackdoorRush"] = "Blitz",
        ["A60"] = "A-60",
        ["A120"] = "A-120",
        ["monster2"] = "A-200",
        ["Eyes"] = "Eyes",
        ["Lookman"] = "Lookman",
        ["BackdoorLookman"] = "Lookman",
        ["Jeff"] = "Jeff The Killer",
        ["JeffTheKiller"] = "Jeff The Killer",
        ["CustomEntity"] = "Custom Entity",
        ["GloombatSwarm"] = "Gloombat Swarm",
        ["Halt"] = "Halt",
        ["SallyMoving"] = "Sally",
        ["Groundskeeper"] = "Groundskeeper",
        ["MonumentEntity"] = "Monument",
        ["GlitchRush"] = "RNIUSHCG",
        ["GlitchedAmbush"] = "AR0xMBUSH",
        ["RushCounterpart"] = "Cease",
        ["Death"] = "Ripper",
        ["Frostbite"] = "Frostbite",
        ["ReboundMoving"] = "Rebound",
        ["Silence"] = "Silence",
        ["Deer God"] = "Deer God",
        ["FigureRig"] = "Figure",
        ["FigureRagdoll"] = "Figure",
        ["LiveEntityBramble"] = "Bramble"
    }

    --// ESP Kurulumu
    local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))()
    ESPLibrary:SetRainbow(false)
    ESPLibrary:SetShowDistance(false)
    ESPLibrary:SetFillTransparency(0.75)
    ESPLibrary:SetOutlineTransparency(0)
    ESPLibrary:SetFadeTime(0.25)
    ESPLibrary:SetTextSize(18)
    ESPLibrary:SetFont(Enum.Font.RobotoCondensed)
    ESPLibrary:SetTracers(false)
    ESPLibrary:SetTracerSize(0.75)
    ESPLibrary:SetTracerOrigin("Bottom")
    ESPLibrary:SetArrows(false)
    ESPLibrary:SetArrowRadius(250)
    ESPLibrary:SetDistanceSizeRatio(0.8)

    --// UI Hazırlıkları
    local Window = Library:CreateWindow({
        Title = "BlackKing | Doors",
        Center = true,
        AutoShow = true,
        Resizable = true,
        ShowCustomCursor = true,
        UnlockMouseWhileOpen = true,
        NotifySide = "Right",
        TabPadding = 8,
        MenuFadeTime = 0.2
    })

    local Tabs = {
        Info = Window:AddTab("Info"),
        Main = Window:AddTab("General"),
        visual = Window:AddTab("Visuals"),
        Exploits = Window:AddTab("Exploits"),
        floortab = Window:AddTab("Floor"),
        ["UI Settings"] = Window:AddTab("UI Settings"),
    }

    local Options = Library.Options
    local Toggles = Library.Toggles

    --// Oyun İçi Gereksinimlerin Alınması
    local LocalPlayer = Services.Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Module = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI"):WaitForChild("Initiator"):WaitForChild("Main_Game"):WaitForChild("RemoteListener"):WaitForChild("Modules")

    local Screech = Module:FindFirstChild("Screech") or Module:FindFirstChild("Screech_") or Module:FindFirstChild("Screech_Disabled")
    local Dread = Module:FindFirstChild("Dread") or Module:FindFirstChild("Dread_") or Module:FindFirstChild("Dread_Disabled") or Instance.new("Folder")

    local RemotesFolder
    if Services.ReplicatedStorage:FindFirstChild("RemotesFolder") then
        RemotesFolder = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
    elseif Services.ReplicatedStorage:FindFirstChild("EntityInfo") then
        RemotesFolder = Services.ReplicatedStorage:FindFirstChild("EntityInfo")
    elseif Services.ReplicatedStorage:FindFirstChild("Bricks") then
        RemotesFolder = Services.ReplicatedStorage:FindFirstChild("Bricks")
    end

    --// Fake Remote Tanımlamaları (Anti-Damage Sistemleri İçin)
    local ShadeEvent = RemotesFolder:FindFirstChild("ShadeResult") or Instance.new("RemoteEvent")
    local FakeShadeEvent = Instance.new("RemoteEvent")
    FakeShadeEvent.Name = "ShadeResult"
    FakeShadeEvent.Parent = Services.ReplicatedStorage

    local DreadEvent = RemotesFolder:FindFirstChild("Dread") or Instance.new("RemoteEvent")
    local FakeDreadEvent = Instance.new("RemoteEvent")
    FakeDreadEvent.Name = "Dread"
    FakeDreadEvent.Parent = Services.ReplicatedStorage

    local A90Event = RemotesFolder:FindFirstChild("A90") or Instance.new("RemoteEvent")
    local FakeA90Event = Instance.new("RemoteEvent")
    FakeA90Event.Name = "A90"
    FakeA90Event.Parent = Services.ReplicatedStorage

    local ScreechEvent = RemotesFolder:FindFirstChild("Screech") or Instance.new("RemoteEvent")
    local FakeScreechEvent = Instance.new("RemoteEvent")
    FakeScreechEvent.Name = "Screech"
    FakeScreechEvent.Parent = Services.ReplicatedStorage

    local SurgeEvent = RemotesFolder:FindFirstChild("SurgeRemote") or Instance.new("RemoteEvent")
    local FakeSurgeEvent = Instance.new("RemoteEvent")
    FakeSurgeEvent.Name = "SurgeRemote"
    FakeSurgeEvent.Parent = Services.ReplicatedStorage

    --// Floor Kontrolleri
    local SupportedFloors = { "Hotel", "Mines", "Garden", "Retro", "Ripple", "Backdoor", "Fools26", "Rooms", "Party" }
    local OldHotel = (RemotesFolder.Name == "Bricks")

    local function FloorSupported(name)
        for _, floor in ipairs(SupportedFloors) do
            if floor == name then return true end
        end
        return false
    end

    if not FloorSupported(Services.ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Floor").Value) then
        LocalPlayer:Kick("This script doesn't support this floor. SupportedFloors: " .. table.concat(SupportedFloors, ", "))
        return
    end

    local function sound()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://4590662766"
        s.Volume = 3
        s.Parent = Services.SoundService
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
    end

    --// UI Yapılandırması (Kategoriler)
    local infTab = Tabs.Info:AddLeftTabbox()
    local inffirsttab = infTab:AddTab('Update Log')
    inffirsttab:AddLabel("\n<DOORS>")
    inffirsttab:AddLabel("<font color='#1eff00'>+ Lobby Support</font>")
    inffirsttab:AddLabel("\n<SCRIPT>")
    inffirsttab:AddLabel("<font color='#1eff00'>+ Auto Show Ui when loaded</font>")

    local mnTAB = Tabs.Main:AddLeftTabbox()
    local firsttab = mnTAB:AddTab('General')

    local mctab = Tabs.Main:AddRightTabbox()
    local firsttabMics = mctab:AddTab('Mics')

    local gntab = Tabs.Main:AddRightTabbox()
    local firsttabGen = gntab:AddTab('General')

    Tabs.floortab:UpdateWarningBox({
        Visible = true,
        Title = "Warning",
        Text = "Features highlighted in red do not work in the current floor you are in.",
    })

    --// Speed Boost & Speed Bypass
    local SpeedBypassLabel = firsttab:AddLabel("Speed Bypass: <font color='#FF0000'>Disabled</font>")

    local function UpdateSpeedBypassLabel(value)
        if value > 6 then
            SpeedBypassLabel:SetText("Speed Bypass: <font color='#00FF00'>Active</font>")
        else
            SpeedBypassLabel:SetText("Speed Bypass: <font color='#FF0000'>Disabled</font>")
        end
    end

    local SpeedBoostConnection = nil
    local SpeedBypassLoop = nil
    local WalkSpeedForceConnection = nil
    local OriginWalkSpeed = nil

    firsttab:AddSlider("SpeedBoostSlie", {
        Text = "Speed Boost",
        Default = 6,
        Min = 0,
        Max = 75,
        Rounding = 1,
        Compact = true,
        Callback = function(value)
            UpdateSpeedBypassLabel(value)
        end
    })

    local function ApplyWalkSpeedBoost()
        if not Character then return end
        local Humanoid = Character:FindFirstChild("Humanoid")
        if not Humanoid then return end

        if not OriginWalkSpeed then
            OriginWalkSpeed = Humanoid.WalkSpeed
        end

        local boost = Options.SpeedBoostSlie.Value or 0
        Humanoid.WalkSpeed = OriginWalkSpeed + boost
    end

    local function RestoreWalkSpeed()
        if not Character then return end
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid and OriginWalkSpeed then
            Humanoid.WalkSpeed = OriginWalkSpeed
        end
    end

    local function StartWalkSpeedForce()
        if WalkSpeedForceConnection then return end
        WalkSpeedForceConnection = Services.RunService.Heartbeat:Connect(function()
            if not OldHotel then return end
            ApplyWalkSpeedBoost()
        end)
    end

    local function StopWalkSpeedForce()
        if WalkSpeedForceConnection then
            WalkSpeedForceConnection:Disconnect()
            WalkSpeedForceConnection = nil
        end
    end

    local function StartSpeedBypassLoop()
        if SpeedBypassLoop then return end
        SpeedBypassLoop = task.spawn(function()
            while task.wait() do
                if not getgenv().SpeedBypass then continue end
                if not Character then continue end

                local slider = Options.SpeedBoostSlie.Value
                local Clone = Character:FindFirstChild("ClonedCollision")
                local HRP = Character:FindFirstChild("HumanoidRootPart")

                if not (Clone and HRP) then continue end

                if slider > 6 then
                    SpeedBypassLabel:SetText("Speed Bypass: <font color='#00FF00'>Active</font>")
                    if HRP.Anchored then
                        Clone.Massless = true
                        HRP.Massless = false
                        HRP.RootPriority = 0
                        task.wait(1)
                    else
                        Clone.Massless = not Clone.Massless
                        HRP.Massless = not HRP.Massless
                        HRP.RootPriority = (HRP.Massless and 1 or 0)
                        task.wait(0.215)
                    end
                else
                    SpeedBypassLabel:SetText("Speed Bypass: <font color='#FF0000'>Disabled</font>")
                    Clone.Massless = true
                    HRP.Massless = false
                    HRP.RootPriority = 0
                end
            end
        end)
    end

    Options.SpeedBoostSlie:OnChanged(function(value)
        UpdateSpeedBypassLabel(value)
        if OldHotel then
            ApplyWalkSpeedBoost()
        end
    end)

    if not Environments.require then
        Library:Notify("<b>[BlackKing]</b>\nSHIT SPLOIT BRO PLS USE EXECUTORS IN https://whatexpsare.online/")
        sound()
    else
        print("Good Sploit Detected")
    end

    firsttab:AddDivider()

    firsttab:AddToggle("SpeedBoost", {
        Text = "Enable Speed Boost",
        Default = false,
        Callback = function(enabled)
            if not enabled then
                getgenv().SpeedBypass = false
                OldHotel = false

                local clone = Character:FindFirstChild("ClonedCollision")
                if clone then clone:Destroy() end

                if SpeedBoostConnection then
                    SpeedBoostConnection:Disconnect()
                    SpeedBoostConnection = nil
                end

                StopWalkSpeedForce()
                RestoreWalkSpeed()

                if Character then
                    local HRP = Character:FindFirstChild("HumanoidRootPart")
                    if HRP then
                        HRP.Massless = false
                        HRP.RootPriority = 0
                    end
                end

                SpeedBypassLabel:SetText("Speed Bypass: <font color='#FF0000'>Disabled</font>")
                return
            end

            task.spawn(function()
                task.wait(0.25)
                if Character then
                    local HRP = Character:FindFirstChild("HumanoidRootPart")
                    if HRP then
                        HRP.Massless = false
                        HRP.RootPriority = 0
                    end
                    local clone = Character:FindFirstChild("ClonedCollision")
                    if clone then clone:Destroy() end
                end
            end)

            UpdateSpeedBypassLabel(Options.SpeedBoostSlie.Value)

            if RemotesFolder.Name == "Bricks" then
                OldHotel = true
                ApplyWalkSpeedBoost()
                StartWalkSpeedForce()
            end

            getgenv().SpeedBypass = true
            StartSpeedBypassLoop()

            if SpeedBoostConnection then SpeedBoostConnection:Disconnect() end
            SpeedBoostConnection = Services.RunService.Heartbeat:Connect(function()
                ApplyWalkSpeedBoost()
            end)

            task.spawn(function()
                task.wait(0.35)
                if Character and not Character:FindFirstChild("ClonedCollision") then
                    local Collision = Character:WaitForChild("Collision")
                    local clone = Collision:Clone()
                    clone.Name = "ClonedCollision"
                    clone.Parent = Character
                    clone.CanCollide = false
                    clone.Massless = true

                    if clone:FindFirstChild("CollisionCrouch") then
                        clone.CollisionCrouch:Destroy()
                    end
                end
            end)
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(NewChar)
        Character = NewChar
        task.wait(0.5)
        if OldHotel then
            OriginWalkSpeed = nil
            ApplyWalkSpeedBoost()
            StartWalkSpeedForce()
        end
    end)

    --// Jump Enforcer
    if not _G.JumpEnforcer then
        _G.JumpEnforcer = Services.RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end

            if Toggles.EnableJump and Toggles.EnableJump.Value == true then
                if char:GetAttribute("CanJump") ~= true then
                    char:SetAttribute("CanJump", true)
                end
            else
                if char:GetAttribute("CanJump") ~= false then
                    char:SetAttribute("CanJump", false)
                end
            end
        end)
    end

    firsttab:AddToggle("EnableJump", {
        Text = "Enable Jump",
        Default = false,
        Tooltip = "Allows you to jump even when the game disables it.",
        Callback = function(value)
            if not Character then return end
            Character:SetAttribute("CanJump", value)
        end
    })

    --// Anti-Slip (No Acceleration)
    local function ApplyNoAcceleration(enabled)
        Character = LocalPlayer.Character
        if not Character then return end

        local Acceleration = not enabled
        local limbNames = {
            "LeftFoot", "LeftHand", "LeftLowerArm", "LeftLowerLeg", "LeftUpperArm", "LeftUpperLeg",
            "LowerTorso", "RightFoot", "RightHand", "RightLowerArm", "RightLowerLeg", "RightUpperArm",
            "RightUpperLeg", "UpperTorso"
        }
        for _, limbName in ipairs(limbNames) do
            local limb = Character:FindFirstChild(limbName)
            if limb then
                limb.Massless = Acceleration
            end
        end
    end

    local NoAccelerationConnection = nil
    firsttab:AddToggle("NoAcceleration", {
        Text = "No Acceleration",
        Default = false,
        Tooltip = "Anti Slip",
        Callback = function(enabled)
            if NoAccelerationConnection then
                NoAccelerationConnection:Disconnect()
                NoAccelerationConnection = nil
            end

            ApplyNoAcceleration(enabled)

            if not enabled then return end
            NoAccelerationConnection = Services.RunService.Heartbeat:Connect(function()
                ApplyNoAcceleration(true)
            end)
        end
    end)

    --// Reset & Lobby Mics
    local ReplicateSignalSupport = (replicatesignal ~= nil)
    local Resetting = false

    firsttabMics:AddButton({
        Text = 'Reset Character',
        Func = function()
            if ReplicateSignalSupport then
                replicatesignal(LocalPlayer.Kill)
                task.wait(2)
            end

            if LocalPlayer:GetAttribute("Alive") ~= false then
                if RemotesFolder:FindFirstChild("Underwater") then
                    RemotesFolder.Underwater:FireServer(not Resetting)
                    Resetting = not Resetting
                else
                    local Hum = Character:FindFirstChildWhichIsA("Humanoid")
                    if Hum then Hum.Health = 0 end
                end
            end
        end,
        DoubleClick = ReplicateSignalSupport,
        Tooltip = 'Makes you die.'
    })

    firsttabMics:AddButton({
        Text = 'Play Again',
        Func = function()
            if RemotesFolder:FindFirstChild("PlayAgain") then
                RemotesFolder.PlayAgain:FireServer()
            end
        end,
        DoubleClick = true,
        Tooltip = 'Makes You Press Play Again Automatically.'
    })

    firsttabMics:AddButton({
        Text = 'Return To Lobby',
        Func = function()
            if RemotesFolder:FindFirstChild("Lobby") then
                RemotesFolder.Lobby:FireServer()
            end
        end,
        DoubleClick = true,
        Tooltip = 'Makes You Return Back To Lobby.'
    })

    --// Door Reach Hack
    local REACHDOORHACK = false
    firsttabGen:AddToggle('DoorReach', {
        Text = 'Door Reach',
        Default = false,
        Callback = function(value)
            REACHDOORHACK = value
        end
    })

    task.spawn(function()
        while task.wait(0.5) do  
            if REACHDOORHACK then
                local latestRoom = Services.ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LatestRoom").Value
                local currentRoom = workspace:WaitForChild("CurrentRooms"):FindFirstChild(tostring(latestRoom))
                if currentRoom and currentRoom:FindFirstChild("Door") then
                    local openEvent = currentRoom.Door:FindFirstChild("ClientOpen")
                    if openEvent then openEvent:FireServer() end
                end
            end
        end
    end)

    --// Auto Interact Engine
    local TrackedPrompts = {}
    local ActiveFakeConnections = {}
    local AutoInteractConnection = nil
    local AutoInteractRemoval = nil
    local AutoInteractLoop = nil

    local FakeNames = {
        Lock = true, ChestBoxLocked = true, Cellar = true, Chest_Vine = true,
        CuttableVines = true, SkullLock = true, Toolbox_Locked = true, Lock1 = true, Lock2 = true
    }

    local AutoInteractPrompts = {
        UnlockPrompt = true, ActivateEventPrompt = true, LootPrompt = true, ModulePrompt = true,
        LeverPrompt = true, FusesPrompt = true, AwesomePrompt = true, LongPushPrompt = true,
        BigPropPrompt = true, ValvePrompt = true, PartyDoorPrompt = true, HerbPrompt = true
    }

    local function AutoInteractRequested()
        return Toggles.AutoIntr and Toggles.AutoIntr.Value
    end

    local function RemoveFakePromptOnce(fakePrompt)
        if not fakePrompt or not fakePrompt:IsA("ProximityPrompt") then return end
        if ActiveFakeConnections[fakePrompt] then return end

        local conn
        conn = fakePrompt.Triggered:Connect(function()
            if conn then
                conn:Disconnect()
                ActiveFakeConnections[fakePrompt] = nil
            end
            if fakePrompt.Parent then
                fakePrompt:Destroy()
            end
        end)
        ActiveFakeConnections[fakePrompt] = conn
    end

    local function TryInteract(prompt)
        if not AutoInteractRequested() then return end
        if not prompt:IsA("ProximityPrompt") then return end
        if not Character then return end

        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local parent = prompt.Parent
        if not parent then return end

        local modelName = parent.Name

        if FakeNames[modelName] then
            local Fake = parent:FindFirstChild("FPrompt", true)
            if Fake and Fake:IsA("ProximityPrompt") then
                RemoveFakePromptOnce(Fake)
                local part = Fake.Parent:IsA("BasePart") and Fake.Parent or Fake.Parent:FindFirstChildWhichIsA("BasePart", true)
                if part and (hrp.Position - part.Position).Magnitude <= Options.AutoInteractDistance.Value then
                    fireproximityprompt(Fake)
                end
                return
            end
        end

        if not AutoInteractPrompts[prompt.Name] then return end

        local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart", true)
        if part and (hrp.Position - part.Position).Magnitude <= Options.AutoInteractDistance.Value then
            fireproximityprompt(prompt)
        end
    end

    local function RegisterPrompt(obj)
        if obj:IsA("ProximityPrompt") then
            TrackedPrompts[obj] = true
        end
    end

    local function UnregisterPrompt(obj)
        TrackedPrompts[obj] = nil
        if ActiveFakeConnections[obj] then
            ActiveFakeConnections[obj]:Disconnect()
            ActiveFakeConnections[obj] = nil
        end
    end

    local function StartLoop()
        if AutoInteractLoop then return end
        AutoInteractLoop = task.spawn(function()
            while true do
                task.wait(0.05)
                if AutoInteractRequested() then
                    for prompt in pairs(TrackedPrompts) do
                        if not prompt.Parent then
                            UnregisterPrompt(prompt)
                        else
                            TryInteract(prompt)
                        end
                    end
                end
            end
        end)
    end

    local function EnableAutoInteractEngine()
        if AutoInteractConnection then return end
        AutoInteractConnection = workspace.DescendantAdded:Connect(RegisterPrompt)
        AutoInteractRemoval = workspace.DescendantRemoving:Connect(UnregisterPrompt)
        for _, obj in ipairs(workspace:GetDescendants()) do
            RegisterPrompt(obj)
        end
        StartLoop()
    end

    local function DisableAutoInteractEngine()
        if AutoInteractConnection then AutoInteractConnection:Disconnect(); AutoInteractConnection = nil end
        if AutoInteractRemoval then AutoInteractRemoval:Disconnect(); AutoInteractRemoval = nil end
        if AutoInteractLoop then task.cancel(AutoInteractLoop); AutoInteractLoop = nil end
        for fake, conn in pairs(ActiveFakeConnections) do conn:Disconnect() end
        table.clear(ActiveFakeConnections)
        table.clear(TrackedPrompts)
    end

    firsttabGen:AddSlider('AutoInteractDistance', {
        Text = 'Interact Distance',
        Default = 12,
        Min = 5,
        Max = 12,
        Rounding = 1,
        Compact = true,
    })

    firsttabGen:AddToggle("AutoIntr", {
        Text = "Auto Interact",
        Default = false,
        Tooltip = "Interacts with proximity prompts instead of you.",
        Callback = function(enabled)
            if enabled then EnableAutoInteractEngine() else DisableAutoInteractEngine() end
        end
    })

    --// Instant Prompt & Distance Interact
    local InstantPromptConnection = nil
    local InstantPromptEnabled = false

    local function ApplyInstantPrompt(room)
        if not room then return end
        for _, obj in ipairs(room:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = InstantPromptEnabled and 0 or 1
            end
        end
    end

    firsttabGen:AddToggle("InstandPrompt", {
        Text = "Instant Prompt",
        Default = false,
        Tooltip = "Makes prompts get interacted with 0 hold duration.",
        Callback = function(enabled)
            InstantPromptEnabled = enabled
            if InstantPromptConnection then InstantPromptConnection:Disconnect(); InstantPromptConnection = nil end

            for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
                ApplyInstantPrompt(room)
            end

            if not enabled then return end
            InstantPromptConnection = workspace.CurrentRooms.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end)
        end
    end)

    local DistanceInteractConnection = nil
    local DistanceInteractEnabled = false

    local function ApplyDistanceToRoom(room)
        if not room then return end
        for _, obj in ipairs(room:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.MaxActivationDistance = DistanceInteractEnabled and Options.DistanceInteractSizer.Value or 8
            end
        end
    end

    firsttabGen:AddSlider("DistanceInteractSizer", {
        Text = "Distance",
        Default = 8,
        Min = 8,
        Max = 18,
        Rounding = 1,
        Compact = true,
        Callback = function(value)
            if DistanceInteractEnabled then
                for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
                    ApplyDistanceToRoom(room)
                end
            end
        end
    })

    firsttabGen:AddToggle("DistanceInteract", {
        Text = "Distance Interact",
        Default = false,
        Tooltip = "Lets you interact with prompts from far away.",
        Callback = function(enabled)
            DistanceInteractEnabled = enabled
            if DistanceInteractConnection then DistanceInteractConnection:Disconnect(); DistanceInteractConnection = nil end

            for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
                ApplyDistanceToRoom(room)
            end

            if not enabled then return end
            DistanceInteractConnection = workspace.CurrentRooms.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") then
                    obj.MaxActivationDistance = Options.DistanceInteractSizer.Value
                end
            end)
        end
    end)

    --// Visuals Tab Setup
    local vstab = Tabs.visual:AddLeftTabbox()
    local SecTab = vstab:AddTab('Visual')
    local epSet = Tabs.visual:AddRightTabbox()
    local SecTabSet = epSet:AddTab('Settings')
    local notifications = Tabs.visual:AddRightTabbox()
    local SecTabnot = notifications:AddTab('Notifications')

    --// Third Person
    local Camera = workspace.CurrentCamera
    Globals.ThirdPersonParts = {}

    local function UpdateThirdPersonParts()
        table.clear(Globals.ThirdPersonParts)
        if Character then
            for _, Object in ipairs(Character:GetDescendants()) do
                if Object:IsA("Accessory") and Object:FindFirstChild("Handle") then
                    table.insert(Globals.ThirdPersonParts, Object.Handle)
                end
            end
            local head = Character:FindFirstChild("Head")
            if head then table.insert(Globals.ThirdPersonParts, head) end
        end
    end
    UpdateThirdPersonParts()

    SecTab:AddToggle("ThirdPersonToggle", {
        Text = "Third Person",
        Default = false,
        Tooltip = "Zooms out your camera, allowing you to see your character from behind."
    })

    Toggles.ThirdPersonToggle:AddKeyPicker("ThirdPersonKeybind", {
        Text = "Third Person",
        Default = "T",
        Mode = "Toggle",
        SyncToggleState = true
    })

    SecTab:AddSlider("ThirdPersonOffsetX", { Text = "X Offset", Min = -10, Max = 10, Default = 10, Rounding = 1, Compact = true })
    SecTab:AddSlider("ThirdPersonOffsetY", { Text = "Y Offset", Min = -10, Max = 10, Default = 4, Rounding = 1, Compact = true })
    SecTab:AddSlider("ThirdPersonOffsetZ", { Text = "Z Offset", Min = -10, Max = 20, Default = 20, Rounding = 1, Compact = true })

    local ThirdPersonConnection = nil
    Toggles.ThirdPersonToggle:OnChanged(function(state)
        if state then
            Camera.CameraType = Enum.CameraType.Scriptable
            UpdateThirdPersonParts()
            ThirdPersonConnection = Services.RunService.RenderStepped:Connect(function()
                if not Character then return end
                local HRP = Character:FindFirstChild("HumanoidRootPart")
                if not HRP then return end

                local offset = Vector3.new(
                    Options.ThirdPersonOffsetX.Value,
                    Options.ThirdPersonOffsetY.Value,
                    Options.ThirdPersonOffsetZ.Value
                )

                local camPos = HRP.CFrame:ToWorldSpace(CFrame.new(offset))
                local targetCFrame = CFrame.new(camPos.Position, HRP.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.15)

                for _, Part in pairs(Globals.ThirdPersonParts) do
                    Part.Transparency = 0
                    Part.LocalTransparencyModifier = 0
                end
            end)
        else
            if ThirdPersonConnection then ThirdPersonConnection:Disconnect(); ThirdPersonConnection = nil end
            Camera.CameraType = Enum.CameraType.Custom
            for _, Part in pairs(Globals.ThirdPersonParts) do
                Part.Transparency = 1
                Part.LocalTransparencyModifier = 1
            end
        end
    end)

    --// Ambient & Fov Lock
    local AmbientColor = Color3.fromRGB(255, 255, 255)
    local DefaultAmbient = Services.Lighting.Ambient
    local AmbientLockConnection = nil

    local function TweenAmbient(toColor)
        Services.TweenService:Create(
            Services.Lighting,
            TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { Ambient = toColor }
        ):Play()
    end

    local CAmbientToggle = SecTab:AddToggle('CAmbient', {
        Text = 'Ambient',
        Default = false,
        Tooltip = 'Changes the Ambient Color.',
    })

    CAmbientToggle:AddColorPicker("AmbientColor", {
        Default = AmbientColor,
        Title = "Ambient",
        Transparency = 0,
        Callback = function(newColor)
            AmbientColor = newColor
            if CAmbientToggle.Value then TweenAmbient(AmbientColor) end
        end
    })

    CAmbientToggle:OnChanged(function(state)
        if state then
            TweenAmbient(AmbientColor)
            if AmbientLockConnection then AmbientLockConnection:Disconnect() end
            AmbientLockConnection = Services.Lighting.Changed:Connect(function(prop)
                if prop == "Ambient" and Services.Lighting.Ambient ~= AmbientColor then
                    TweenAmbient(AmbientColor)
                end
            end)
        else
            TweenAmbient(DefaultAmbient)
            if AmbientLockConnection then AmbientLockConnection:Disconnect(); AmbientLockConnection = nil end
        end
    end)

    local FovLockConnection = nil
    local CurrentFov = 70

    local function SetFov(Value)
        CurrentFov = Value
        if FovLockConnection then FovLockConnection:Disconnect(); FovLockConnection = nil end

        local tween = Services.TweenService:Create(
            Camera,
            TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { FieldOfView = Value }
        )
        tween:Play()
        tween.Completed:Connect(function()
            FovLockConnection = Services.RunService.RenderStepped:Connect(function()
                Camera.FieldOfView = CurrentFov
            end)
        end)
    end

    SecTab:AddSlider("FovSlider", {
        Text = "Fov", Default = 70, Min = 10, Max = 120, Rounding = 1, Compact = true,
        Callback = SetFov
    })

    SecTab:AddDivider()

    --// Hiding Spot Transparency
    local ObjectsTable = { Closets = {} }

    local function ScanClosets()
        table.clear(ObjectsTable.Closets)
        for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
            local assets = room:FindFirstChild("Assets")
            if not assets then continue end

            for _, inst in ipairs(assets:GetChildren()) do
                if inst:FindFirstChild("HiddenPlayer") then
                    table.insert(ObjectsTable.Closets, inst)
                    for _, part in ipairs(inst:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part:SetAttribute("Transparency", part.Transparency)
                        end
                    end
                end
            end
        end
    end

    workspace.CurrentRooms.ChildAdded:Connect(function()
        task.wait(0.1)
        ScanClosets()
    end)
    ScanClosets()

    local function UpdateAllHidingSpots()
        for _, inst in pairs(ObjectsTable.Closets) do
            local hidden = inst:FindFirstChild("HiddenPlayer")
            if not hidden then continue end

            local parts = {}
            local parts2 = (inst.Name == "Double_Bed" and inst.Parent or inst):GetDescendants()

            for _, part in ipairs(parts2) do
                if part:IsA("BasePart") and part:GetAttribute("Transparency") ~= nil then
                    table.insert(parts, part)
                end
            end

            local targetTransparency = (Toggles.TransparentHidingspots.Value and hidden.Value == Character) and Options.SpotTransparency.Value or nil

            for _, e in ipairs(parts) do
                Services.TweenService:Create(
                    e,
                    TweenInfo.new(0.75, Enum.EasingStyle.Quad),
                    { Transparency = targetTransparency or e:GetAttribute("Transparency") }
                ):Play()
            end
        end
    end

    SecTab:AddSlider("SpotTransparency", {
        Text = "Hiding Spot Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 1, Compact = true,
        Callback = UpdateAllHidingSpots
    })

    SecTab:AddToggle("TransparentHidingspots", {
        Text = "Transparent Hiding Spot", Default = false,
        Callback = UpdateAllHidingSpots
    })

    task.spawn(function()
        while task.wait(0.1) do
            if Toggles.TransparentHidingspots and Toggles.TransparentHidingspots.Value then
                UpdateAllHidingSpots()
            end
        end
    end)

    --// ESP Library Elements (Door, Chest, Player, Item, Currency, Objective)
    local ObjectiveColor = Color3.fromRGB(26, 255, 0)
    local DoorESPColor   = Color3.fromRGB(0, 199, 255)
    local SpotESPColor   = Color3.fromRGB(255, 174, 43)
    local ItemESPColor   = Color3.fromRGB(170, 0, 255)
    local ChestESPColor  = Color3.fromRGB(255, 255, 0)
    local CurrencyColor  = Color3.fromRGB(255, 215, 0)
    local PlayerColor    = Color3.fromRGB(255, 255, 255)

    local ObjectiveESPObjects = {}
    local DoorESPObjects      = {}
    local SpotESPObjects      = {}
    local ItemESPObjects      = {}
    local ChestESPObjects     = {}
    local CurrencyESPObjects  = {}
    local PlayerESPObjects    = {}

    local ObjectiveBlacklist  = {}
    local ProcessedObjectives = {}
    local ESPConnections      = {}

    local function ClearObjectiveESP()
        for obj in pairs(ObjectiveESPObjects) do ESPLibrary:RemoveESP(obj) end
        table.clear(ObjectiveESPObjects)
    end

    local function ProcessObjective(obj)
        if ProcessedObjectives[obj] then return end
        ProcessedObjectives[obj] = true

        local root = obj:FindFirstAncestorWhichIsA("Model")
        if root and ObjectiveBlacklist[root] then return end
        if not Toggles.Objective.Value then return end

        if obj.Name == "KeyObtain" then
            ESPLibrary:AddESP({ Object = obj, Text = "Door Key", Color = ObjectiveColor })
            ObjectiveESPObjects[obj] = true
        elseif obj.Name == "FuseObtain" then
            local fusePart = obj:FindFirstChildWhichIsA("BasePart", true)
            if fusePart then
                ESPLibrary:AddESP({ Object = fusePart, Text = "Generator Fuse", Color = ObjectiveColor })
                ObjectiveESPObjects[fusePart] = true
            end
        elseif obj.Name == "ElectricalKeyObtain" then
            ESPLibrary:AddESP({ Object = obj, Text = "Electrical Key", Color = ObjectiveColor })
            ObjectiveESPObjects[obj] = true
        end
    end

    local ObjectiveDescendantConnection = nil
    local function ConnectRoom(roomNumber)
        if ObjectiveDescendantConnection then ObjectiveDescendantConnection:Disconnect() end
        local roomFolder = workspace.CurrentRooms:FindFirstChild(tostring(roomNumber))
        if not roomFolder then return end

        for _, obj in ipairs(roomFolder:GetDescendants()) do ProcessObjective(obj) end
        ObjectiveDescendantConnection = roomFolder.DescendantAdded:Connect(ProcessObjective)
    end

    SecTab:AddToggle("Objective", {
        Text = "Objectives", Default = false,
        Callback = function(enabled)
            if not enabled then
                ClearObjectiveESP()
                table.clear(ProcessedObjectives)
            else
                local room = LocalPlayer:GetAttribute("CurrentRoom")
                if room then ConnectRoom(room) end
            end
        end
    })
    Toggles.Objective:AddColorPicker("ObjectiveColor", {
        Default = ObjectiveColor, Title = "Objectives", Transparency = 0,
        Callback = function(newColor)
            ObjectiveColor = newColor
            for obj in pairs(ObjectiveESPObjects) do ESPLibrary:UpdateObjectColor(obj, newColor) end
        end
    })

    --// Door ESP
    local function ClearDoorESP()
        for part in pairs(DoorESPObjects) do
            if part and part.Parent then ESPLibrary:RemoveESP(part); part:Destroy() end
        end
        table.clear(DoorESPObjects)
    end

    local function CreateDoorESP(roomNumber)
        local Room = workspace.CurrentRooms:FindFirstChild(tostring(roomNumber))
        if not Room then return end

        local DoorFolder = Room:FindFirstChild("Door")
        if not DoorFolder then return end

        local DoorPart = DoorFolder:FindFirstChild("Door")
        if not DoorPart then return end

        local ESPPart = Instance.new("Part")
        ESPPart.Name = "DoorESPPart"
        ESPPart.Anchored, ESPPart.CanCollide, ESPPart.Transparency = true, false, 0.99
        ESPPart.Color, ESPPart.Size, ESPPart.CFrame = DoorESPColor, DoorPart.Size, DoorPart.CFrame
        ESPPart.Parent = DoorFolder

        DoorESPObjects[ESPPart] = true
        ESPLibrary:AddESP({ Object = ESPPart, Text = "Door", Color = DoorESPColor })
    end

    SecTab:AddToggle("DoorESP", {
        Text = "Doors", Default = false,
        Callback = function(enabled)
            if not enabled then ClearDoorESP() else local r = LocalPlayer:GetAttribute("CurrentRoom"); if r then CreateDoorESP(r) end end
        end
    })
    Toggles.DoorESP:AddColorPicker("DoorESPColor", {
        Default = DoorESPColor, Title = "Door Color",
        Callback = function(newColor)
            DoorESPColor = newColor
            for part in pairs(DoorESPObjects) do ESPLibrary:UpdateObjectColor(part, newColor) end
        end
    })

    --// Spot ESP
    local function ClearSpotESP()
        for obj in pairs(SpotESPObjects) do ESPLibrary:RemoveESP(obj) end
        table.clear(SpotESPObjects)
    end

    local function CreateSpotESP(roomNumber)
        local Room = workspace.CurrentRooms:FindFirstChild(tostring(roomNumber))
        if not Room then return end
        local Assets = Room:FindFirstChild("Assets")
        if not Assets then return end

        local validSpots = { Wardrobe = "Closet", Bed = "Bed", Double_Bed = "Bed", Rooms_Locker = "Locker" }
        for _, child in ipairs(Assets:GetChildren()) do
            if validSpots[child.Name] then
                ESPLibrary:AddESP({ Object = child, Text = validSpots[child.Name], Color = SpotESPColor })
                SpotESPObjects[child] = true
            end
        end
    end

    SecTab:AddToggle("SpotESP", {
        Text = "Hiding Spots", Default = false,
        Callback = function(enabled)
            if not enabled then ClearSpotESP() else local r = LocalPlayer:GetAttribute("CurrentRoom"); if r then CreateSpotESP(r) end end
        end
    })
    Toggles.SpotESP:AddColorPicker("SpotESPColor", {
        Default = SpotESPColor, Title = "Spot Color",
        Callback = function(newColor)
            SpotESPColor = newColor
            for obj in pairs(SpotESPObjects) do ESPLibrary:UpdateObjectColor(obj, newColor) end
        end
    })

    --// Entity ESP
    local EntityESPObjects = {}
    local EntityColor = Color3.fromRGB(255, 0, 0)

    local EntityEspNames = {
        ["RushMoving"] = "Rush", ["CustomEntity"] = "Custom Entity", ["AmbushMoving"] = "Ambush",
        ["A60"] = "A-60", ["A120"] = "A-120", ["Eyes"] = "Eyes", ["Lookman"] = "Lookman",
        ["FigureRig"] = "Figure", ["BackdoorLookman"] = "Lookman", ["BackdoorRush"] = "Blitz"
    }

    local function ClearEntityESP()
        for model, part in pairs(EntityESPObjects) do ESPLibrary:RemoveESP(part) end
        table.clear(EntityESPObjects)
    end

    local function ScanForEntities()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and EntityEspNames[obj.Name] then
                if EntityESPObjects[obj] then continue end
                ESPLibrary:AddESP({ Object = obj, Text = EntityEspNames[obj.Name], Color = EntityColor })
                EntityESPObjects[obj] = obj
            end
        end
    end

    SecTab:AddToggle("EntityESP", {
        Text = "Entities", Default = false,
        Callback = function(enabled)
            if not enabled then ClearEntityESP() else ScanForEntities() end
        end
    })
    Toggles.EntityESP:AddColorPicker("EntityColor", {
        Default = EntityColor, Title = "Entity Color",
        Callback = function(newColor)
            EntityColor = newColor
            for model, part in pairs(EntityESPObjects) do ESPLibrary:UpdateObjectColor(part, newColor) end
        end
    })

    local entityESPAccumulator = 0
    Services.RunService.Heartbeat:Connect(function(dt)
        if Toggles.EntityESP and Toggles.EntityESP.Value then
            entityESPAccumulator = entityESPAccumulator + dt
            if entityESPAccumulator >= 0.25 then
                entityESPAccumulator = 0
                ScanForEntities()
            end
        end
    end)

    --// Item ESP & Currency ESP & Chest ESP
    local ItemNames = { Lighter = "Lighter", Flashlight = "Flashlight", Lockpick = "Lockpicks", Vitamins = "Vitamins", KeyIron = "Iron Key" }
    local function ClearItemESP()
        for obj in pairs(ItemESPObjects) do ESPLibrary:RemoveESP(obj) end
        table.clear(ItemESPObjects)
    end

    local function CreateItemESP(roomNumber)
        local Room = workspace.CurrentRooms:FindFirstChild(tostring(roomNumber))
        if not Room then return end
        local Assets = Room:FindFirstChild("Assets")
        if not Assets then return end

        for _, child in ipairs(Assets:GetDescendants()) do
            if ItemNames[child.Name] and child:FindFirstChildOfClass("ProximityPrompt") then
                ESPLibrary:AddESP({ Object = child, Text = ItemNames[child.Name], Color = ItemESPColor })
                ItemESPObjects[child] = true
            end
        end
    end

    SecTab:AddToggle("ItemESP", {
        Text = "Items", Default = false,
        Callback = function(enabled)
            if not enabled then ClearItemESP() else local r = LocalPlayer:GetAttribute("CurrentRoom"); if r then CreateItemESP(r) end end
        end
    })
    Toggles.ItemESP:AddColorPicker("ItemESPColor", {
        Default = ItemESPColor, Title = "Item Color",
        Callback = function(newColor)
            ItemESPColor = newColor
            for obj in pairs(ItemESPObjects) do ESPLibrary:UpdateObjectColor(obj, newColor) end
        end
    })

    --// Chest ESP
    local ChestNames = { ChestBox = "Chest", ChestBoxLocked = "Chest [Locked]", Toolbox = "Toolbox" }
    local function ClearChestESP()
        for obj in pairs(ChestESPObjects) do ESPLibrary:RemoveESP(obj) end
        table.clear(ChestESPObjects)
    end

    local function CreateChestESP(roomNumber)
        local Room = workspace.CurrentRooms:FindFirstChild(tostring(roomNumber))
        if not Room then return end
        local Assets = Room:FindFirstChild("Assets")
        if not Assets then return end

        for _, child in ipairs(Assets:GetChildren()) do
            if ChestNames[child.Name] then
                ESPLibrary:AddESP({ Object = child, Text = ChestNames[child.Name], Color = ChestESPColor })
                ChestESPObjects[child] = true
            end
        end
    end

    SecTab:AddToggle("ChestESP", {
        Text = "Chests", Default = false,
        Callback = function(enabled)
            if not enabled then ClearChestESP() else local r = LocalPlayer:GetAttribute("CurrentRoom"); if r then CreateChestESP(r) end end
        end
    })
    Toggles.ChestESP:AddColorPicker("ChestESPColor", {
        Default = ChestESPColor, Title = "Chest Color",
        Callback = function(newColor)
            ChestESPColor = newColor
            for obj in pairs(ChestESPObjects) do ESPLibrary:UpdateObjectColor(obj, newColor) end
        end
    })

    --// Currency ESP
    local function ClearCurrencyESP()
        for obj in pairs(CurrencyESPObjects) do ESPLibrary:RemoveESP(obj) end
        table.clear(CurrencyESPObjects)
    end

    local function CreateCurrencyESP(roomNumber)
        local Room = workspace.CurrentRooms:FindFirstChild(tostring(roomNumber))
        if not Room then return end
        local Assets = Room:FindFirstChild("Assets")
        if not Assets then return end

        for _, child in ipairs(Assets:GetDescendants()) do
            if child.Name == "GoldPile" then
                local val = child:GetAttribute("GoldValue") or 0
                ESPLibrary:AddESP({ Object = child, Text = "Gold Pile [" .. tostring(val) .. "]", Color = CurrencyColor })
                CurrencyESPObjects[child] = true
            end
        end
    end

    SecTab:AddToggle("CurrencyESP", {
        Text = "Currency", Default = false,
        Callback = function(enabled)
            if not enabled then ClearCurrencyESP() else local r = LocalPlayer:GetAttribute("CurrentRoom"); if r then CreateCurrencyESP(r) end end
        end
    })
    Toggles.CurrencyESP:AddColorPicker("CurrencyColor", {
        Default = CurrencyColor, Title = "Currency Color",
        Callback = function(newColor)
            CurrencyColor = newColor
            for obj in pairs(CurrencyESPObjects) do ESPLibrary:UpdateObjectColor(obj, newColor) end
        end
    })

    --// Player ESP
    local function ClearPlayerESP()
        for char in pairs(PlayerESPObjects) do ESPLibrary:RemoveESP(char) end
        table.clear(PlayerESPObjects)
    end

    local function CreatePlayerESP(plr)
        if plr == LocalPlayer then return end
        if not plr.Character then return end
        local char = plr.Character
        if PlayerESPObjects[char] then return end

        ESPLibrary:AddESP({ Object = char, Text = plr.Name, Color = PlayerColor })
        PlayerESPObjects[char] = true
    end

    local function ScanPlayers()
        ClearPlayerESP()
        for _, plr in ipairs(Services.Players:GetPlayers()) do CreatePlayerESP(plr) end
    end

    SecTab:AddToggle("PlayerESP", {
        Text = "Players", Default = false,
        Callback = function(enabled)
            if not enabled then ClearPlayerESP() else ScanPlayers() end
        end
    })
    Toggles.PlayerESP:AddColorPicker("PlayerColor", {
        Default = PlayerColor, Title = "Player Color",
        Callback = function(newColor)
            PlayerColor = newColor
            for char in pairs(PlayerESPObjects) do ESPLibrary:UpdateObjectColor(char, newColor) end
        end
    })

    --// Room Changed Signal (ESP Auto Update)
    LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
        local room = LocalPlayer:GetAttribute("CurrentRoom")
        if not room then return end

        if Toggles.Objective and Toggles.Objective.Value then ClearObjectiveESP(); table.clear(ProcessedObjectives); ConnectRoom(room) end
        if Toggles.DoorESP and Toggles.DoorESP.Value then ClearDoorESP(); CreateDoorESP(room) end
        if Toggles.SpotESP and Toggles.SpotESP.Value then ClearSpotESP(); CreateSpotESP(room) end
        if Toggles.ItemESP and Toggles.ItemESP.Value then ClearItemESP(); CreateItemESP(room) end
        if Toggles.ChestESP and Toggles.ChestESP.Value then ClearChestESP(); CreateChestESP(room) end
        if Toggles.CurrencyESP and Toggles.CurrencyESP.Value then ClearCurrencyESP(); CreateCurrencyESP(room) end
    end)

    --// Settings Sliders
    SecTabSet:AddSlider('SetFadeTime', { Text = 'FadeTime ', Default = 0.5, Min = 0, Max = 2, Rounding = 1, Compact = true, Callback = function(v) ESPLibrary:SetFadeTime(v) end })
    SecTabSet:AddSlider('TracerSizer', { Text = 'Tracer Size ', Default = 1, Min = 1, Max = 3, Rounding = 1, Compact = true, Callback = function(v) ESPLibrary:SetTracerSize(v) end })
    SecTabSet:AddSlider('FillTransparency', { Text = 'Fill Transparency', Default = 0.75, Min = 0, Max = 1, Rounding = 2, Compact = true, Callback = function(v) ESPLibrary:SetFillTransparency(v) end })
    SecTabSet:AddSlider('TextSizer', { Text = 'Text Size ', Default = 18, Min = 12, Max = 24, Rounding = 0, Compact = true, Callback = function(v) ESPLibrary:SetTextSize(v) end })

    SecTabSet:AddDivider()
    SecTabSet:AddToggle("DistancesEsp", { Text = "Distances", Default = false, Callback = function(v) ESPLibrary:SetShowDistance(v) end })
    SecTabSet:AddToggle("TracersEsp", { Text = "Tracers", Default = false, Callback = function(v) ESPLibrary:SetTracers(v) end })
    SecTabSet:AddToggle("ArrowsEsp", { Text = "Arrows", Default = false, Callback = function(v) ESPLibrary:SetArrows(v) end })
    SecTabSet:AddToggle("RainbowEsp", { Text = "Rainbow Esp", Default = false, Callback = function(v) ESPLibrary:SetRainbow(v) end })

    SecTabSet:AddDivider()
    SecTabSet:AddDropdown("ESPTextFont", {
        Text = "Text Font",
        Values = { "Legacy", "Arial", "SourceSans", "Roboto", "RobotoCondensed" },
        Default = 4
    })

    --// Notification System
    local notified = {}
    local notifiedHalt = false

    local CustomMessages = {
        Rush = "<b>[BlackKing]</b>\nEntity 'Rush' has spawned, find a hiding spot.",
        Ambush = "<b>[BlackKing]</b>\nEntity 'Ambush' has spawned, find a hiding spot.",
        Blitz = "<b>[BlackKing]</b>\nEntity 'Blitz' has spawned, find a hiding spot.",
        Eyes = "<b>[BlackKing]</b>\nEntity 'Eyes' has spawned, avoid looking at them.",
        Lookman = "<b>[BlackKing]</b>\nEntity 'Lookman' has spawned, avoid looking at him.",
        Halt = "<b>[BlackKing]</b>\nEntity 'Halt' will spawn in the next room.",
    }

    SecTabnot:AddDropdown('NotifyMonsters', {
        Values = {"Rush","Ambush","Blitz","Eyes","Lookman","Halt"},
        Default = {},
        Multi = true,
        Compact = true,
        Text = 'Entity List',
    })

    SecTabnot:AddToggle('NotifyEntities', { Default = false, Text = 'Notify Entities' })
    SecTabnot:AddToggle("EntityChatToggle", { Text = "Chat Message", Default = false })
    SecTabnot:AddInput("EntityChatMessage", { Text = "Message", Default = "Has Spawned!", Numeric = false })

    Functions.SendChat = function(Message)
        local Folder = Services.ReplicatedStorage:FindFirstChild("DefaultChatSystemEvents")
        if Folder then
            local Event = Folder:FindFirstChild("SayMessageRequest")
            if Event then Event:FireServer(Message, "All") end
        end
        if Services.TextChatService and Services.TextChatService:FindFirstChild("TextChannels") then
            local Channel = Services.TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if Channel then Channel:SendAsync(Message) end
        end
    end

    workspace.ChildAdded:Connect(function(child)
        if not Toggles.NotifyEntities.Value then return end
        local name = child.Name
        local shortName = EntityShortNames[name]

        if shortName and Options.NotifyMonsters.Value[shortName] and not notified[child] then
            local msg = CustomMessages[shortName] or ("<b>[BlackKing]</b>\nEntity '"..shortName.."' has spawned.")
            Library:Notify(msg)
            sound()
            notified[child] = true

            if Toggles.EntityChatToggle.Value then
                Functions.SendChat("[BlackKing] " .. shortName .. " " .. Options.EntityChatMessage.Value)
            end
        end
    end)

    --// Digital Timer & Oxygen Bar
    local ShowTimerConnection = nil
    SecTabnot:AddToggle("ShowTimer", {
        Text = "Show Timer",
        Callback = function(enabled)
            local DigitalTimer = Services.ReplicatedStorage:WaitForChild("FloorReplicated", 5) and Services.ReplicatedStorage.FloorReplicated:FindFirstChild("DigitalTimer")
            if not DigitalTimer then return end

            if ShowTimerConnection then ShowTimerConnection:Disconnect(); ShowTimerConnection = nil end

            local MainUI = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
            if not MainUI then return end

            local function cleanupTimer()
                local old = MainUI:FindFirstChild("LiveCaption_Timer")
                if old then old:Destroy() end
            end
            cleanupTimer()

            if not enabled then return end

            ShowTimerConnection = DigitalTimer.Changed:Connect(function(newValue)
                cleanupTimer()
                local minutes = math.floor(newValue / 60)
                local seconds = newValue % 60
                local formatted = string.format("%02d:%02d", minutes, seconds)

                local Caption = MainUI:WaitForChild("MainFrame"):WaitForChild("Caption")

                local TimerFrame = Instance.new("Frame")
                TimerFrame.Name = "LiveCaption_Timer"
                TimerFrame.Parent = MainUI
                TimerFrame.Size = UDim2.new(0, 181, 0, 100)
                TimerFrame.Position = Caption.Position
                TimerFrame.AnchorPoint = Caption.AnchorPoint
                TimerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                TimerFrame.BorderSizePixel = 0

                local Stroke = Instance.new("UIStroke")
                Stroke.Parent = TimerFrame
                Stroke.Thickness = 2
                Stroke.Color = Library.Scheme.AccentColor

                local Corner = Instance.new("UICorner")
                Corner.Parent = TimerFrame
                Corner.CornerRadius = UDim.new(0, 6)

                local Label = Instance.new("TextLabel")
                Label.Parent = TimerFrame
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = formatted
                Label.TextColor3 = Color3.fromRGB(255, 222, 189)
                Label.TextSize = 32
                Label.TextXAlignment = Enum.TextXAlignment.Center
                Label.TextYAlignment = Enum.TextYAlignment.Center

                task.spawn(function()
                    while TimerFrame.Parent do
                        Stroke.Color = Library.Scheme.AccentColor
                        task.wait(0.1)
                    end
                end)
            end)
        end
    })

    --// Exploits / Removes
    local EXPTTAB = Tabs.Exploits:AddLeftTabbox()
    local thirdtab = EXPTTAB:AddTab('Remove')

    local EXPTTAB2 = Tabs.Exploits:AddRightTabbox()
    local thirdtabPlayer = EXPTTAB2:AddTab('Movement')

    --// Anti Giggle & Anti Eyes & Anti Lookman & Anti Snare
    local GiggleConnection = nil
    thirdtab:AddToggle('AntiGiggle', {
        Text = 'Anti Giggle', Default = false,
        Callback = function(Value)
            if GiggleConnection then GiggleConnection:Disconnect(); GiggleConnection = nil end
            if not Value then return end

            GiggleConnection = workspace.CurrentRooms.DescendantAdded:Connect(function(inst)
                if inst.Name == "GiggleCeiling" then
                    local hb = inst:WaitForChild("Hitbox", 5)
                    if hb then hb.CanTouch = false end
                end
            end)
        end
    })

    local Eyesa = nil
    thirdtab:AddToggle("AntiEyes", {
        Text = "Anti Eyes", Default = false,
        Callback = function(state)
            if Eyesa then Eyesa:Disconnect(); Eyesa = nil end
            if not state then return end

            Eyesa = Services.RunService.Heartbeat:Connect(function()
                if workspace:FindFirstChild("Eyes") then
                    RemotesFolder.MotorReplication:FireServer(-760)
                end
            end)
        end
    })

    --// No A-90 / Screech / Surge / Halt Damage (Fake Remotes Swap)
    thirdtab:AddToggle('AntiA90', {
        Text = 'No A-90 Damage', Default = false,
        Callback = function(Value)
            if Value then
                A90Event.Parent = Services.ReplicatedStorage
                FakeA90Event.Parent = RemotesFolder
            else
                A90Event.Parent = RemotesFolder
                FakeA90Event.Parent = Services.ReplicatedStorage
            end
        end
    })

    thirdtab:AddToggle('AntiScreecha', {
        Text = 'No Screech Damage', Default = false,
        Callback = function(Value)
            if Value then
                ScreechEvent.Parent = Services.ReplicatedStorage
                FakeScreechEvent.Parent = RemotesFolder
            else
                ScreechEvent.Parent = RemotesFolder
                FakeScreechEvent.Parent = Services.ReplicatedStorage
            end
        end
    })

    --// Fast Closet Exit (Tamamlanan Kısım)
    local Event = RemotesFolder:FindFirstChild("CamLock")
    local FastExita = false

    thirdtabPlayer:AddToggle("FastClosetExit", {
        Text = "Fast Closet Exit",
        Default = false,
        Tooltip = "Instantly exits closets without delay animations.",
        Callback = function(Value)
            FastExita = Value
        end
    })

    -- Fast Closet Exit Arka Plan Mekanizması
    task.spawn(function()
        while task.wait() do
            if FastExita and Character then
                local hiding = Character:GetAttribute("Hiding")
                if hiding then
                    -- Dolaptan anında çıkmak için gereken Remote tetiklenir veya proximity prompt simüle edilir
                    local interactEvent = RemotesFolder:FindFirstChild("Interact") or RemotesFolder:FindFirstChild("CamLock")
                    if interactEvent then
                        interactEvent:FireServer(false)
                    end
                end
            end
        end
    end)
end
