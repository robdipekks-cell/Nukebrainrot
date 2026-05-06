-- // Brainrot Auto Farm | Fluent UI

-- ============================================================
-- // Universal HTTP Getter
-- ============================================================
local function HttpGet(url)
    if syn and syn.request then
        return syn.request({ Url = url, Method = "GET" }).Body
    elseif http and http.request then
        return http.request({ Url = url, Method = "GET" }).Body
    elseif request then
        return request({ Url = url, Method = "GET" }).Body
    elseif game.HttpGet then
        return game:HttpGet(url)
    else
        error("No HTTP method available on this executor!")
    end
end

-- ============================================================
-- // Load Fluent
-- ============================================================
local Fluent = loadstring(HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

local SaveManager = loadstring(HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()

local InterfaceManager = loadstring(HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

-- ============================================================
-- // Services & Locals
-- ============================================================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character   = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP         = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
end)

local Remote = ReplicatedStorage
    :WaitForChild("ModifiedPackages")
    :WaitForChild("Packet")
    :WaitForChild("RemoteEvent")

-- ============================================================
-- // Hardcoded Lists
-- ============================================================
local BrainrotNames = {
    "Bisonte Giuppitere",
    "Dragon Cannelloni",
    "Job Job Sahur",
    "Lavaca Blackhole",
    "Lavaca Saturna",
    "Matteo",
    "Meow",
    "Orcaledon",
    "Piccione Macchina",
    "Strawberry Elephanto",
    "Tralaledon",
}

local LuckyBlockNames = {
    "Celestial Lucky Block",
    "Gigantic Lucky Block",
}

-- ============================================================
-- // State
-- ============================================================
local FarmEnabled       = false
local FarmBrainrots     = {}
local FarmMinLevel      = 0
local FarmThread        = nil

local CollectEnabled    = false
local CollectThread     = nil

local RebirthEnabled    = false
local RebirthThread     = nil

local LuckyEnabled      = false
local LuckySelected     = {}
local LuckyThread       = nil

local UpgradeEnabled    = false
local UpgradeThread     = nil

local SpinEnabled       = false
local SpinThread        = nil

local FloorEnabled      = false
local FloorThread       = nil

local PowerEnabled      = false
local PowerThread       = nil

local SpeedEnabled      = false
local SpeedThread       = nil

local CarryEnabled      = false
local CarryThread       = nil

-- ============================================================
-- // Helpers
-- ============================================================
local function SafeTP(target)
    if not (Character and HRP) then return end
    local cf
    if typeof(target) == "CFrame" then
        cf = target
    elseif typeof(target) == "Instance" then
        if target:IsA("BasePart") then
            cf = target.CFrame * CFrame.new(0, 3, 0)
        else
            local part = target:FindFirstChildWhichIsA("BasePart")
            if part then cf = part.CFrame * CFrame.new(0, 3, 0) end
        end
    end
    if cf then HRP.CFrame = cf end
end

local function FireRemote(str)
    Remote:FireServer(buffer.fromstring(str))
end

local function ParseDisplay(text)
    if not text or text == "" then return nil, 0 end
    local name  = text:match("^(.-)%s*%(Lvl")
    local level = tonumber(text:match("%(Lvl%s*(%d+)%)")) or 0
    return name, level
end

local function Norm(s)
    return (s or ""):lower():gsub("%s+", "")
end

-- Returns the base model itself
local function GetPlayerBase()
    local gameArea = workspace:FindFirstChild("GameArea")
    if not gameArea then return nil end
    local bases = gameArea:FindFirstChild("Bases")
    if not bases then return nil end
    for i = 1, 10 do
        local base = bases:FindFirstChild("Base" .. i)
        if base then
            local info      = base:FindFirstChild("PlayerInfo")
            local billboard = info and info:FindFirstChild("BillboardGui")
            local label     = billboard and billboard:FindFirstChild("TextLabel")
            if label and label.Text == LocalPlayer.Name then
                return base
            end
        end
    end
    return nil
end

local function TeleportToBase()
    local base = GetPlayerBase()
    if not base then return false end
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP       = Character:WaitForChild("HumanoidRootPart")
    local spawn = base:FindFirstChild("SpawnLocation") or base
    SafeTP(spawn)
    return true
end

-- ============================================================
-- // Collect All
-- ============================================================
local function CollectAll()
    local base = GetPlayerBase()
    if not base then return end
    local stands = base:FindFirstChild("BrainrotStands")
    if not stands then return end

    for floorNum = 1, 4 do
        local floor = stands:FindFirstChild("Floor" .. floorNum)
        if floor then
            for _, stand in ipairs(floor:GetChildren()) do
                local uniqueId = stand:GetAttribute("BrainrotStandUniqueId")
                if uniqueId then
                    FireRemote(";$" .. tostring(uniqueId))
                    task.wait(0.1)
                end
            end
        end
    end
end

local function CollectLoop()
    while CollectEnabled do
        CollectAll()
        task.wait(1)
    end
end

-- ============================================================
-- // Upgrade All
-- ============================================================
local function UpgradeAll()
    local base = GetPlayerBase()
    if not base then return end
    local stands = base:FindFirstChild("BrainrotStands")
    if not stands then return end

    for floorNum = 1, 4 do
        local floor = stands:FindFirstChild("Floor" .. floorNum)
        if floor then
            for _, stand in ipairs(floor:GetChildren()) do
                local uniqueId = stand:GetAttribute("BrainrotStandUniqueId")
                if uniqueId then
                    FireRemote("6$" .. tostring(uniqueId))
                    task.wait(0.1)
                end
            end
        end
    end
end

local function UpgradeLoop()
    while UpgradeEnabled do
        UpgradeAll()
        task.wait(1)
    end
end

-- ============================================================
-- // Spin Loop
-- ============================================================
local function SpinLoop()
    while SpinEnabled do
        FireRemote("`\0")
        task.wait(1)
    end
end

-- ============================================================
-- // Floor Loop
-- ============================================================
local function FloorLoop()
    while FloorEnabled do
        FireRemote(">")
        task.wait(1)
    end
end

-- ============================================================
-- // Farm Loop
-- ============================================================
local function FarmLoop()
    while FarmEnabled do
        local container = workspace.Camera:FindFirstChild("BrainrotContainer")
        local targetId  = nil

        if container then
            for _, brainrot in ipairs(container:GetChildren()) do
                if not FarmEnabled then break end

                local info      = brainrot:FindFirstChild("BrainrotInfo")
                local frame     = info and info:FindFirstChild("Frame")
                local dispLabel = frame and frame:FindFirstChild("DisplayName")

                if dispLabel then
                    local bName, bLevel = ParseDisplay(dispLabel.Text)

                    local passLevel = (bLevel >= FarmMinLevel)
                    local passName  = (#FarmBrainrots == 0)
                    if not passName and bName then
                        for _, sel in ipairs(FarmBrainrots) do
                            if Norm(bName) == Norm(sel) then
                                passName = true
                                break
                            end
                        end
                    end

                    if passLevel and passName then
                        targetId = brainrot.Name
                        break
                    end
                end
            end
        end

        if targetId and FarmEnabled then
            FireRemote("a")
            task.wait(0.3)

            local spawns = workspace:FindFirstChild("GameArea")
            spawns = spawns and spawns:FindFirstChild("BrainrotSpawns")
            local zone   = spawns and spawns:FindFirstChild("12")
            local spot   = zone and zone:FindFirstChild("9")
            if spot then SafeTP(spot) end
            task.wait(0.4)

            FireRemote("2\t\003" .. targetId)
            task.wait(0.4)

            FireRemote("b")
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end

-- ============================================================
-- // Lucky Block Loop
-- ============================================================
local function LuckyLoop()
    while LuckyEnabled do
        local container = workspace.Camera:FindFirstChild("LuckyBlockContainer")
        local targetId  = nil

        if container then
            for _, block in ipairs(container:GetChildren()) do
                if not LuckyEnabled then break end

                local info      = block:FindFirstChild("BrainrotInfo")
                local frame     = info and info:FindFirstChild("Frame")
                local dispLabel = frame and frame:FindFirstChild("DisplayName")

                if dispLabel then
                    local bName   = dispLabel.Text
                    local passName = (#LuckySelected == 0)
                    if not passName then
                        for _, sel in ipairs(LuckySelected) do
                            if Norm(bName) == Norm(sel) then
                                passName = true
                                break
                            end
                        end
                    end

                    if passName then
                        targetId = block.Name
                        break
                    end
                end
            end
        end

        if targetId and LuckyEnabled then
            FireRemote("a")
            task.wait(0.3)

            local lb = workspace.Camera:FindFirstChild("LuckyBlockContainer")
            lb = lb and lb:FindFirstChild("02b")
            if lb then SafeTP(lb) end
            task.wait(0.4)

            FireRemote("2\t\003" .. targetId)
            task.wait(0.4)

            FireRemote("b")
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end

-- ============================================================
-- // Build Window
-- ============================================================
local Window = Fluent:CreateWindow({
    Title       = "Brainrot Farm",
    SubTitle    = "Auto Collector",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 540),
    Acrylic     = true,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

local Tabs = {
    Farm         = Window:AddTab({ Title = "Farm",          Icon = "sprout"   }),
    LuckyBlock   = Window:AddTab({ Title = "Lucky Block",   Icon = "gem"      }),
    Upgrades     = Window:AddTab({ Title = "Upgrades",      Icon = "zap"      }),
    ShopUpgrades = Window:AddTab({ Title = "Shop Upgrades", Icon = "shopping-cart" }),
    Settings     = Window:AddTab({ Title = "Settings",      Icon = "settings" }),
}

-- ============================================================
-- // Farm Tab
-- ============================================================

Tabs.Farm:AddDropdown("BrainrotSelect", {
    Title       = "Brainrot Filter",
    Description = "Pick brainrots to farm. Leave empty to farm all.",
    Values      = BrainrotNames,
    Multi       = true,
    Default     = {},
    Callback    = function(selected)
        FarmBrainrots = {}
        for name, active in pairs(selected) do
            if active then table.insert(FarmBrainrots, name) end
        end
    end,
})

Tabs.Farm:AddInput("LevelFilter", {
    Title       = "Level Filter",
    Description = "Only farm brainrots at or above this level. 0 = all.",
    Default     = "0",
    Placeholder = "e.g. 100",
    Numeric     = true,
    Finished    = false,
    Callback    = function(value)
        FarmMinLevel = tonumber(value) or 0
    end,
})

Tabs.Farm:AddToggle("AutoFarmToggle", {
    Title    = "Auto Farm",
    Default  = false,
    Callback = function(state)
        FarmEnabled = state
        if state then
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HRP       = Character:WaitForChild("HumanoidRootPart")
            if FarmThread then task.cancel(FarmThread) end
            FarmThread = task.spawn(FarmLoop)
            Fluent:Notify({ Title = "Auto Farm", Content = "Farm started!", Duration = 2 })
        else
            if FarmThread then task.cancel(FarmThread); FarmThread = nil end
            Fluent:Notify({ Title = "Auto Farm", Content = "Farm stopped.", Duration = 2 })
        end
    end,
})

Tabs.Farm:AddToggle("AutoFloorToggle", {
    Title       = "Auto Floor",
    Description = "Automatically buys the next floor.",
    Default     = false,
    Callback    = function(state)
        FloorEnabled = state
        if state then
            if FloorThread then task.cancel(FloorThread) end
            FloorThread = task.spawn(FloorLoop)
            Fluent:Notify({ Title = "Auto Floor", Content = "Started!", Duration = 2 })
        else
            if FloorThread then task.cancel(FloorThread); FloorThread = nil end
            Fluent:Notify({ Title = "Auto Floor", Content = "Stopped.", Duration = 2 })
        end
    end,
})

Tabs.Farm:AddToggle("AutoSpinToggle", {
    Title       = "Auto Spin",
    Description = "Automatically spins for brainrots.",
    Default     = false,
    Callback    = function(state)
        SpinEnabled = state
        if state then
            if SpinThread then task.cancel(SpinThread) end
            SpinThread = task.spawn(SpinLoop)
            Fluent:Notify({ Title = "Auto Spin", Content = "Started!", Duration = 2 })
        else
            if SpinThread then task.cancel(SpinThread); SpinThread = nil end
            Fluent:Notify({ Title = "Auto Spin", Content = "Stopped.", Duration = 2 })
        end
    end,
})

Tabs.Farm:AddToggle("AutoRebirthToggle", {
    Title       = "Auto Rebirth",
    Description = "Automatically rebirths when available.",
    Default     = false,
    Callback    = function(state)
        RebirthEnabled = state
        if state then
            if RebirthThread then task.cancel(RebirthThread) end
            RebirthThread = task.spawn(function()
                while RebirthEnabled do
                    FireRemote("h")
                    task.wait(1)
                end
            end)
            Fluent:Notify({ Title = "Auto Rebirth", Content = "Started!", Duration = 2 })
        else
            if RebirthThread then task.cancel(RebirthThread); RebirthThread = nil end
            Fluent:Notify({ Title = "Auto Rebirth", Content = "Stopped.", Duration = 2 })
        end
    end,
})

Tabs.Farm:AddToggle("CollectAllToggle", {
    Title       = "Auto Collect",
    Description = "Auto collect from all stands on Floor 1–4.",
    Default     = false,
    Callback    = function(state)
        CollectEnabled = state
        if state then
            if CollectThread then task.cancel(CollectThread) end
            CollectThread = task.spawn(CollectLoop)
            Fluent:Notify({ Title = "Auto Collect", Content = "Started!", Duration = 2 })
        else
            if CollectThread then task.cancel(CollectThread); CollectThread = nil end
            Fluent:Notify({ Title = "Auto Collect", Content = "Stopped.", Duration = 2 })
        end
    end,
})

Tabs.Farm:AddToggle("UpgradeAllToggle2", {
    Title       = "Auto Upgrade",
    Description = "Automatically upgrades all brainrot stands on Floor 1–4.",
    Default     = false,
    Callback    = function(state)
        UpgradeEnabled = state
        if state then
            if UpgradeThread then task.cancel(UpgradeThread) end
            UpgradeThread = task.spawn(UpgradeLoop)
            Fluent:Notify({ Title = "Auto Upgrade", Content = "Started!", Duration = 2 })
        else
            if UpgradeThread then task.cancel(UpgradeThread); UpgradeThread = nil end
            Fluent:Notify({ Title = "Auto Upgrade", Content = "Stopped.", Duration = 2 })
        end
    end,
})

Tabs.Farm:AddButton({
    Title       = "Teleport to Base",
    Description = "Instantly teleport to your base.",
    Callback    = function()
        if TeleportToBase() then
            Fluent:Notify({ Title = "Teleport", Content = "Teleported to your base!", Duration = 2 })
        else
            Fluent:Notify({ Title = "Teleport", Content = "Could not find your base.", Duration = 2 })
        end
    end,
})


-- ============================================================
-- // Lucky Block Tab
-- ============================================================

Tabs.LuckyBlock:AddToggle("AutoLuckyToggle", {
    Title    = "Auto Lucky Block",
    Default  = false,
    Callback = function(state)
        LuckyEnabled = state
        if state then
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HRP       = Character:WaitForChild("HumanoidRootPart")
            if LuckyThread then task.cancel(LuckyThread) end
            LuckyThread = task.spawn(LuckyLoop)
            Fluent:Notify({ Title = "Lucky Block", Content = "Started!", Duration = 2 })
        else
            if LuckyThread then task.cancel(LuckyThread); LuckyThread = nil end
            Fluent:Notify({ Title = "Lucky Block", Content = "Stopped.", Duration = 2 })
        end
    end,
})

Tabs.LuckyBlock:AddDropdown("LuckySelect", {
    Title       = "Lucky Block Filter",
    Description = "Pick lucky blocks to open. Leave empty to open all.",
    Values      = LuckyBlockNames,
    Multi       = true,
    Default     = {},
    Callback    = function(selected)
        LuckySelected = {}
        for name, active in pairs(selected) do
            if active then table.insert(LuckySelected, name) end
        end
    end,
})

Tabs.LuckyBlock:AddButton({
    Title       = "Teleport to Base",
    Description = "Instantly teleport to your base.",
    Callback    = function()
        if TeleportToBase() then
            Fluent:Notify({ Title = "Teleport", Content = "Teleported to your base!", Duration = 2 })
        else
            Fluent:Notify({ Title = "Teleport", Content = "Could not find your base.", Duration = 2 })
        end
    end,
})

-- ============================================================
-- // Upgrades Tab (Shop Upgrades only — Auto Upgrade moved to Farm tab)
-- ============================================================

-- ============================================================
-- // Shop Upgrades Tab
-- ============================================================

Tabs.ShopUpgrades:AddToggle("AutoPowerToggle", {
    Title       = "Auto Upgrade Power",
    Description = "Continuously buys Power upgrades from the shop.",
    Default     = false,
    Callback    = function(state)
        PowerEnabled = state
        if state then
            if PowerThread then task.cancel(PowerThread) end
            PowerThread = task.spawn(function()
                while PowerEnabled do
                    FireRemote("4\tNukePower\005\001")
                    task.wait(0.5)
                end
            end)
            Fluent:Notify({ Title = "Auto Power", Content = "Started!", Duration = 2 })
        else
            if PowerThread then task.cancel(PowerThread); PowerThread = nil end
            Fluent:Notify({ Title = "Auto Power", Content = "Stopped.", Duration = 2 })
        end
    end,
})

Tabs.ShopUpgrades:AddToggle("AutoSpeedToggle", {
    Title       = "Auto Upgrade Speed",
    Description = "Continuously buys Speed upgrades from the shop.",
    Default     = false,
    Callback    = function(state)
        SpeedEnabled = state
        if state then
            if SpeedThread then task.cancel(SpeedThread) end
            SpeedThread = task.spawn(function()
                while SpeedEnabled do
                    FireRemote("4\rMovementSpeed\005\001")
                    task.wait(0.5)
                end
            end)
            Fluent:Notify({ Title = "Auto Speed", Content = "Started!", Duration = 2 })
        else
            if SpeedThread then task.cancel(SpeedThread); SpeedThread = nil end
            Fluent:Notify({ Title = "Auto Speed", Content = "Stopped.", Duration = 2 })
        end
    end,
})

Tabs.ShopUpgrades:AddToggle("AutoCarryToggle", {
    Title       = "Auto Upgrade Carry",
    Description = "Continuously buys Carry Capacity upgrades from the shop.",
    Default     = false,
    Callback    = function(state)
        CarryEnabled = state
        if state then
            if CarryThread then task.cancel(CarryThread) end
            CarryThread = task.spawn(function()
                while CarryEnabled do
                    FireRemote("4\rCarryCapacity\005\001")
                    task.wait(0.5)
                end
            end)
            Fluent:Notify({ Title = "Auto Carry", Content = "Started!", Duration = 2 })
        else
            if CarryThread then task.cancel(CarryThread); CarryThread = nil end
            Fluent:Notify({ Title = "Auto Carry", Content = "Stopped.", Duration = 2 })
        end
    end,
})

-- ============================================================
-- // Settings Tab
-- ============================================================
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- ============================================================
-- // Done
-- ============================================================
Window:SelectTab(1)

Fluent:Notify({
    Title    = "Brainrot Farm",
    Content  = "Script loaded successfully!",
    Duration = 4,
})
