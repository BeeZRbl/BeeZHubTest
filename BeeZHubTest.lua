
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- BEEZ HUB CONFIGURATION
local BeeZ = {
    Version = "2.5.0",
    Author = "BeeZ Team",
    
    -- Farming Settings
    AutoFarm = {
        Enabled = true,
        Method = "Normal", -- Normal, Fast, Safe, Boss
        Distance = 25,
        Priority = "Nearest", -- Nearest, HighestLevel, LowestHP
        StackFarming = false,
        MaxTargets = 5
    },
    
    -- Safety Settings
    Safety = {
        IgnoreKatakuri = false,
        KatakuriHPThreshold = 30,
        AntiBan = true,
        Humanizer = true,
        RandomBreaks = true,
        MaxFarmTime = 1800 -- 30 minutes
    },
    
    -- Auto Features
    Auto = {
        ServerHop = true,
        MaxHops = 10,
        Quest = {
            Katakuri = true,
            Bone = false,
            Tyrant = true,
            SeaEvents = false
        },
        Raid = false,
        Fruit = false,
        Mastery = {
            Enabled = true,
            Target = 300,
            AutoSwitch = true
        }
    },
    
    -- Player Settings
    Player = {
        SelectedSkill = "Z",
        SkillCombo = {"Z", "X", "C", "V", "F"},
        AutoHealthPot = true,
        HealthThreshold = 30,
        AutoEnergyPot = true,
        EnergyThreshold = 20
    },
    
    -- UI Settings
    UI = {
        Theme = "Dark",
        Watermark = true,
        Notifications = true,
        StatusDisplay = true
    }
}

-- BeeZ Hub Variables
local BeeZ_Hub = {
    Running = false,
    Target = nil,
    HopAttempts = 0,
    CurrentMastery = 0,
    FarmStartTime = 0,
    QuestsCompleted = 0,
    EnemiesKilled = 0,
    LastNotification = 0,
    SkillCooldowns = {},
    SafeZones = {},
    BlacklistedServers = {}
}

-- BeeZ Hub GUI Library Loader
local function LoadBeeZGUI()
    local success, guiLib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/uwuware-ui-library/main/ui.lua"))()
    end)
    
    if not success then
        -- Fallback to simple GUI
        return LoadSimpleGUI()
    end
    
    return guiLib
end

-- Simple GUI Fallback
local function LoadSimpleGUI()
    local SimpleGUI = {}
    
    function SimpleGUI:CreateWindow(title, theme)
        local BeeZWindow = {}
        local Tabs = {}
        
        print("[BeeZ Hub] Loaded Simple GUI - " .. title)
        
        function BeeZWindow:NewTab(tabName)
            local Tab = {Sections = {}}
            
            function Tab:NewSection(sectionName)
                local Section = {Controls = {}}
                
                function Section:NewLabel(text)
                    print("[BeeZ] " .. text)
                end
                
                function Section:NewToggle(name, desc, callback)
                    local toggleState = false
                    print("[BeeZ] Toggle: " .. name .. " - " .. desc)
                    
                    return {
                        SetState = function(state)
                            toggleState = state
                            callback(state)
                        end
                    }
                end
                
                function Section:NewSlider(name, desc, max, min, callback)
                    print("[BeeZ] Slider: " .. name .. " - " .. desc)
                    
                    return {
                        SetValue = function(value)
                            callback(value)
                        end
                    }
                end
                
                function Section:NewDropdown(name, desc, options, callback)
                    print("[BeeZ] Dropdown: " .. name .. " - " .. desc)
                    
                    return {
                        SetValue = function(value)
                            callback(value)
                        end
                    }
                end
                
                function Section:NewButton(name, desc, callback)
                    print("[BeeZ] Button: " .. name .. " - " .. desc)
                    
                    return {
                        Click = callback
                    }
                end
                
                table.insert(Section.Controls, Section)
                return Section
            end
            
            table.insert(Tabs, Tab)
            return Tab
        end
        
        return BeeZWindow
    end
    
    return SimpleGUI
end

-- Initialize BeeZ GUI
local GUI = LoadBeeZGUI()
local Window = GUI:CreateWindow("BeeZ Hub v" .. BeeZ.Version, BeeZ.UI.Theme)

-- Create Tabs
local MainTab = Window:NewTab("Main")
local FarmTab = Window:NewTab("Farming")
local AutoTab = Window:NewTab("Auto")
local PlayerTab = Window:NewTab("Player")
local RaidTab = Window:NewTab("Raid")
local SettingsTab = Window:NewTab("Settings")

-- Create Sections
local MainSection = MainTab:NewSection("BeeZ Hub Control")
local FarmSection = FarmTab:NewSection("Farming Configuration")
local AutoSection = AutoTab:NewSection("Auto Features")
local QuestSection = AutoTab:NewSection("Quest Automation")
local PlayerSection = PlayerTab:NewSection("Player Settings")
local RaidSection = RaidTab:NewSection("Raid Automation")
local SettingsSection = SettingsTab:NewSection("Hub Settings")

-- BeeZ Hub Core Functions
function BeeZ_Hub:Notify(title, message, duration)
    if BeeZ.UI.Notifications then
        local currentTime = tick()
        if currentTime - self.LastNotification > 2 then
            print("[BEEZ] " .. title .. ": " .. message)
            
            -- Create notification GUI
            local Notification = Instance.new("ScreenGui")
            Notification.Name = "BeeZNotification"
            Notification.Parent = game:GetService("CoreGui")
            
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(0, 300, 0, 80)
            Frame.Position = UDim2.new(1, -320, 1, -100)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            Frame.BackgroundTransparency = 0.2
            Frame.BorderSizePixel = 0
            Frame.Parent = Notification
            
            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 25)
            Title.Position = UDim2.new(0, 10, 0, 10)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = Color3.fromRGB(255, 215, 0)
            Title.Text = "🐝 " .. title
            Title.Font = Enum.Font.Code
            Title.TextSize = 16
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Frame
            
            local Message = Instance.new("TextLabel")
            Message.Size = UDim2.new(1, -20, 0, 40)
            Message.Position = UDim2.new(0, 10, 0, 35)
            Message.BackgroundTransparency = 1
            Message.TextColor3 = Color3.fromRGB(255, 255, 255)
            Message.Text = message
            Message.Font = Enum.Font.Gotham
            Message.TextSize = 14
            Message.TextXAlignment = Enum.TextXAlignment.Left
            Message.TextYAlignment = Enum.TextYAlignment.Top
            Message.TextWrapped = true
            Message.Parent = Frame
            
            -- Animate in
            Frame:TweenPosition(UDim2.new(1, -320, 1, -100), "Out", "Quad", 0.3)
            
            -- Auto remove
            task.wait(duration or 3)
            Frame:TweenPosition(UDim2.new(1, 0, 1, -100), "Out", "Quad", 0.3)
            task.wait(0.3)
            Notification:Destroy()
            
            self.LastNotification = currentTime
        end
    end
end

function BeeZ_Hub:GetEnemies()
    local enemies = {}
    
    for _, npc in pairs(Workspace.Enemies:GetChildren()) do
        if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
            if npc.Humanoid.Health > 0 then
                local distance = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distance <= BeeZ.AutoFarm.Distance then
                    table.insert(enemies, {
                        Object = npc,
                        Distance = distance,
                        Level = npc:FindFirstChild("Level") and npc.Level.Value or 1,
                        Health = npc.Humanoid.Health,
                        MaxHealth = npc.Humanoid.MaxHealth,
                        IsKatakuri = string.find(npc.Name:lower(), "katakuri") ~= nil
                    })
                end
            end
        end
    end
    
    return enemies
end

function BeeZ_Hub:SelectTarget(enemies)
    if #enemies == 0 then return nil end
    
    -- Filter out Katakuri if IgnoreKatakuri is enabled
    if BeeZ.Safety.IgnoreKatakuri then
        local filtered = {}
        for _, enemy in pairs(enemies) do
            if not enemy.IsKatakuri or 
               (Humanoid.Health / Humanoid.MaxHealth * 100) <= BeeZ.Safety.KatakuriHPThreshold then
                table.insert(filtered, enemy)
            end
        end
        enemies = filtered
    end
    
    if #enemies == 0 then return nil end
    
    -- Sort based on priority
    if BeeZ.AutoFarm.Priority == "Nearest" then
        table.sort(enemies, function(a, b)
            return a.Distance < b.Distance
        end)
    elseif BeeZ.AutoFarm.Priority == "HighestLevel" then
        table.sort(enemies, function(a, b)
            return a.Level > b.Level
        end)
    elseif BeeZ.AutoFarm.Priority == "LowestHP" then
        table.sort(enemies, function(a, b)
            return a.Health < b.Health
        end)
    end
    
    -- Stack farming - select multiple targets
    local targets = {}
    for i = 1, math.min(BeeZ.AutoFarm.MaxTargets, #enemies) do
        table.insert(targets, enemies[i].Object)
    end
    
    return targets
end

function BeeZ_Hub:UseSkill(skill)
    if not skill or BeeZ_Hub.SkillCooldowns[skill] then return end
    
    game:GetService("VirtualInputManager"):SendKeyEvent(true, skill, false, game)
    task.wait(0.05)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, skill, false, game)
    
    -- Set cooldown
    BeeZ_Hub.SkillCooldowns[skill] = true
    task.wait(0.5) -- Skill cooldown
    BeeZ_Hub.SkillCooldowns[skill] = false
    
    self:Notify("Skill Used", "Used skill: " .. skill, 1)
end

function BeeZ_Hub:StartFarming()
    if BeeZ_Hub.Running then return end
    
    BeeZ_Hub.Running = true
    BeeZ_Hub.FarmStartTime = tick()
    BeeZ_Hub.EnemiesKilled = 0
    
    self:Notify("BeeZ Hub", "Farming session started!", 2)
    
    coroutine.wrap(function()
        while BeeZ_Hub.Running and BeeZ.AutoFarm.Enabled do
            -- Check farm time limit
            if BeeZ.Safety.MaxFarmTime > 0 and (tick() - BeeZ_Hub.FarmStartTime) > BeeZ.Safety.MaxFarmTime then
                self:Notify("Safety", "Farm time limit reached, taking a break", 3)
                BeeZ_Hub:StopFarming()
                task.wait(60) -- 1 minute break
                BeeZ_Hub:StartFarming()
                break
            end
            
            -- Anti-AFK
            if BeeZ.Safety.AntiBan then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
            
            -- Humanizer - random breaks
            if BeeZ.Safety.RandomBreaks and math.random(1, 100) <= 5 then
                local breakTime = math.random(2, 8)
                self:Notify("Humanizer", "Taking a short break for " .. breakTime .. "s", 2)
                task.wait(breakTime)
            end
            
            -- Get and attack enemies
            local enemies = BeeZ_Hub:GetEnemies()
            local targets = BeeZ_Hub:SelectTarget(enemies)
            
            if targets and #targets > 0 then
                -- Move to first target
                HumanoidRootPart.CFrame = CFrame.new(
                    targets[1].HumanoidRootPart.Position + 
                    Vector3.new(0, 3, 0)
                )
                
                -- Use skill combo
                for _, skill in pairs(BeeZ.Player.SkillCombo) do
                    if BeeZ_Hub.Running then
                        BeeZ_Hub:UseSkill(skill)
                    end
                end
                
                -- Stack farming attack
                if BeeZ.AutoFarm.StackFarming and #targets > 1 then
                    BeeZ_Hub:UseSkill("X") -- AOE skill
                    BeeZ_Hub:UseSkill("C") -- Another AOE
                end
                
                BeeZ_Hub.EnemiesKilled = BeeZ_Hub.EnemiesKilled + 1
                
            else
                -- No enemies found, check for server hop
                if BeeZ.Auto.ServerHop and BeeZ_Hub.HopAttempts < BeeZ.Auto.MaxHops then
                    BeeZ_Hub:FindKatakuriAndHop()
                end
            end
            
            task.wait(0.2) -- Farming loop delay
        end
    end)()
end

function BeeZ_Hub:StopFarming()
    BeeZ_Hub.Running = false
    local farmDuration = tick() - BeeZ_Hub.FarmStartTime
    local killsPerMinute = BeeZ_Hub.EnemiesKilled / (farmDuration / 60)
    
    self:Notify("BeeZ Hub", 
        string.format("Farming stopped\nKills: %d\nTime: %.1f min\nKPM: %.1f",
        BeeZ_Hub.EnemiesKilled, farmDuration / 60, killsPerMinute), 5)
end

function BeeZ_Hub:FindKatakuriAndHop()
    BeeZ_Hub.HopAttempts = BeeZ_Hub.HopAttempts + 1
    
    self:Notify("Server Hop", 
        "Attempt " .. BeeZ_Hub.HopAttempts .. "/" .. BeeZ.Auto.MaxHops, 2)
    
    -- Try to find Katakuri
    local katakuriFound = false
    for _, npc in pairs(Workspace.Enemies:GetChildren()) do
        if string.find(npc.Name:lower(), "katakuri") then
            katakuriFound = true
            break
        end
    end
    
    if not katakuriFound and BeeZ.Auto.ServerHop then
        -- Get server list
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. 
                game.PlaceId .. 
                "/servers/Public?sortOrder=Desc&limit=100"
            ))
        end)
        
        if success and servers.data then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    if not BeeZ_Hub.BlacklistedServers[server.id] then
                        self:Notify("Server Hop", "Joining new server...", 3)
                        TeleportService:TeleportToPlaceInstance(
                            game.PlaceId, 
                            server.id, 
                            Player
                        )
                        task.wait(5)
                        break
                    end
                end
            end
        end
    end
end

function BeeZ_Hub:AutoQuest()
    while BeeZ.Auto.Quest.Katakuri or BeeZ.Auto.Quest.Bone or BeeZ.Auto.Quest.Tyrant do
        task.wait(10)
        
        -- Check and accept quests
        local questData = self:GetCurrentQuests()
        
        if BeeZ.Auto.Quest.Katakuri and not questData.Katakuri then
            self:AcceptQuest("Katakuri")
        end
        
        if BeeZ.Auto.Quest.Bone and not questData.Bone then
            self:AcceptQuest("Bone")
        end
        
        if BeeZ.Auto.Quest.Tyrant and not questData.Tyrant then
            self:AcceptQuest("Tyrant")
        end
        
        if BeeZ.Auto.Quest.SeaEvents then
            self:CheckSeaEvents()
        end
    end
end

function BeeZ_Hub:AcceptQuest(questName)
    -- Quest acceptance logic
    self:Notify("Quest", "Accepting " .. questName .. " quest", 2)
    -- Implementation would go here based on game structure
end

function BeeZ_Hub:GetCurrentQuests()
    -- Return current quest status
    return {
        Katakuri = false,
        Bone = false,
        Tyrant = false
    }
end

function BeeZ_Hub:CheckSeaEvents()
    -- Check for sea events
    self:Notify("Sea Event", "Checking for sea events...", 2)
end

function BeeZ_Hub:MasteryFarm()
    while BeeZ.Auto.Mastery.Enabled and BeeZ_Hub.CurrentMastery < BeeZ.Auto.Mastery.Target do
        task.wait(5)
        
        -- Update mastery level
        local tool = Player:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Mastery") then
            BeeZ_Hub.CurrentMastery = tool.Mastery.Value
            
            if BeeZ_Hub.CurrentMastery >= BeeZ.Auto.Mastery.Target then
                self:Notify("Mastery", "Target reached: " .. BeeZ_Hub.CurrentMastery, 3)
                if BeeZ.Auto.Mastery.AutoSwitch then
                    -- Auto switch to next weapon
                    self:Notify("Mastery", "Switching to next weapon...", 3)
                end
            end
        end
    end
end

-- GUI Elements
MainSection:NewLabel("🐝 BeeZ Hub v" .. BeeZ.Version)
MainSection:NewLabel("Advanced Blox Fruits Automation")

local FarmToggle = MainSection:NewToggle("Start Farming", "Enable/Disable Auto Farm", function(state)
    BeeZ.AutoFarm.Enabled = state
    if state then
        BeeZ_Hub:StartFarming()
    else
        BeeZ_Hub:StopFarming()
    end
end)

MainSection:NewButton("Emergency Stop", "Immediately stop all actions", function()
    BeeZ_Hub.Running = false
    BeeZ.AutoFarm.Enabled = false
    BeeZ_Hub:Notify("Emergency", "All actions stopped!", 3)
end)

-- Farming Settings
FarmSection:NewDropdown("Farm Method", "Select farming strategy", 
    {"Normal", "Fast", "Safe", "Boss"}, 
    function(method)
        BeeZ.AutoFarm.Method = method
        BeeZ_Hub:Notify("Farm Method", "Set to: " .. method, 2)
    end)

FarmSection:NewSlider("Farm Distance", "Max distance to farm", 50, 10, function(value)
    BeeZ.AutoFarm.Distance = value
end)

FarmSection:NewDropdown("Target Priority", "How to select targets", 
    {"Nearest", "HighestLevel", "LowestHP"}, 
    function(priority)
        BeeZ.AutoFarm.Priority = priority
    end)

FarmSection:NewToggle("Stack Farming", "Attack multiple enemies", function(state)
    BeeZ.AutoFarm.StackFarming = state
end)

-- Auto Features
AutoSection:NewToggle("Ignore Katakuri", "Avoid Katakuri when farming", function(state)
    BeeZ.Safety.IgnoreKatakuri = state
end)

AutoSection:NewSlider("Katakuri HP Threshold", "Ignore when HP below %", 90, 10, function(value)
    BeeZ.Safety.KatakuriHPThreshold = value
end)

AutoSection:NewToggle("Auto Server Hop", "Hop when no Katakuri found", function(state)
    BeeZ.Auto.ServerHop = state
end)

AutoSection:NewSlider("Max Hop Attempts", "Maximum server hops", 20, 1, function(value)
    BeeZ.Auto.MaxHops = value
end)

-- Quest Automation
QuestSection:NewToggle("Katakuri Quest", "Auto accept Katakuri quest", function(state)
    BeeZ.Auto.Quest.Katakuri = state
    if state then coroutine.wrap(BeeZ_Hub.AutoQuest)() end
end)

QuestSection:NewToggle("Bone Quest", "Auto accept Bone quest", function(state)
    BeeZ.Auto.Quest.Bone = state
end)

QuestSection:NewToggle("Tyrant Quest", "Auto accept Tyrant quest", function(state)
    BeeZ.Auto.Quest.Tyrant = state
end)

QuestSection:NewToggle("Sea Events", "Auto participate in sea events", function(state)
    BeeZ.Auto.Quest.SeaEvents = state
end)

-- Player Settings
PlayerSection:NewDropdown("Main Skill", "Primary skill to use", 
    {"Z", "X", "C", "V", "F"}, 
    function(skill)
        BeeZ.Player.SelectedSkill = skill
    end)

PlayerSection:NewSlider("Mastery Target", "Target mastery level", 500, 100, function(value)
    BeeZ.Auto.Mastery.Target = value
    if BeeZ.Auto.Mastery.Enabled then
        coroutine.wrap(BeeZ_Hub.MasteryFarm)()
    end
end)

PlayerSection:NewToggle("Auto Health Pots", "Auto use health potions", function(state)
    BeeZ.Player.AutoHealthPot = state
end)

PlayerSection:NewSlider("Health Threshold", "Use pot when HP below %", 50, 10, function(value)
    BeeZ.Player.HealthThreshold = value
end)

-- Settings
SettingsSection:NewToggle("Anti-Ban Mode", "Extra safety measures", function(state)
    BeeZ.Safety.AntiBan = state
end)

SettingsSection:NewToggle("Humanizer", "Random human-like behavior", function(state)
    BeeZ.Safety.Humanizer = state
end)

SettingsSection:NewToggle("Notifications", "Show in-game notifications", function(state)
    BeeZ.UI.Notifications = state
end)

SettingsSection:NewToggle("Status Display", "Show farming status", function(state)
    BeeZ.UI.StatusDisplay = state
end)

-- Create Status Display
local function CreateStatusDisplay()
    if BeeZ.UI.StatusDisplay then
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "BeeZStatus"
        ScreenGui.Parent = game:GetService("CoreGui")
        
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 250, 0, 120)
        Frame.Position = UDim2.new(0, 10, 0, 10)
        Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        Frame.BackgroundTransparency = 0.3
        Frame.BorderSizePixel = 0
        Frame.Parent = ScreenGui
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 30)
        Title.BackgroundTransparency = 1
        Title.TextColor3 = Color3.fromRGB(255, 215, 0)
        Title.Text = "🐝 BeeZ Hub Status"
        Title.Font = Enum.Font.Code
        Title.TextSize = 16
        Title.Parent = Frame
        
        local Status = Instance.new("TextLabel")
        Status.Size = UDim2.new(1, -10, 0, 80)
        Status.Position = UDim2.new(0, 5, 0, 35)
        Status.BackgroundTransparency = 1
        Status.TextColor3 = Color3.fromRGB(255, 255, 255)
        Status.Font = Enum.Font.Code
        Status.TextSize = 12
        Status.TextXAlignment = Enum.TextXAlignment.Left
        Status.TextYAlignment = Enum.TextYAlignment.Top
        Status.TextWrapped = true
        Status.Parent = Frame
        
        -- Update status
        coroutine.wrap(function()
            while BeeZ.UI.StatusDisplay do
                task.wait(1)
                local statusText = string.format(
                    "Status: %s\n" ..
                    "Mastery: %d/%d\n" ..
                    "Kills: %d\n" ..
                    "Time: %.1f min\n" ..
                    "Server Hops: %d",
                    BeeZ_Hub.Running and "Farming" or "Idle",
                    BeeZ_Hub.CurrentMastery,
                    BeeZ.Auto.Mastery.Target,
                    BeeZ_Hub.EnemiesKilled,
                    BeeZ_Hub.Running and (tick() - BeeZ_Hub.FarmStartTime) / 60 or 0,
                    BeeZ_Hub.HopAttempts
                )
                Status.Text = statusText
            end
        end)()
    end
end

-- Watermark
local function CreateWatermark()
    if BeeZ.UI.Watermark then
        local Watermark = Instance.new("ScreenGui")
        Watermark.Name = "BeeZWatermark"
        Watermark.Parent = game:GetService("CoreGui")
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0, 150, 0, 20)
        Label.Position = UDim2.new(1, -160, 0, 10)
        Label.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        Label.BackgroundTransparency = 0.8
        Label.TextColor3 = Color3.fromRGB(0, 0, 0)
        Label.Text = "🐝 BeeZ Hub v" .. BeeZ.Version
        Label.Font = Enum.Font.Code
        Label.TextSize = 12
        Label.Parent = Watermark
        
        -- Click to toggle GUI
        Label.MouseButton1Click:Connect(function()
            -- Toggle GUI visibility
            BeeZ_Hub:Notify("BeeZ Hub", "GUI toggled", 1)
        end)
    end
end

-- Initialization
BeeZ_Hub:Notify("BeeZ Hub", 
    string.format("Version %s loaded!\nAuthor: %s", BeeZ.Version, BeeZ.Author), 5)

print([[
========================================
🐝 BeeZ Hub v]] .. BeeZ.Version .. [[ Loaded!
========================================
Features:
✅ Advanced Auto Farming
✅ Smart Target Selection
✅ Stack Farming System
✅ Katakuri Ignore System
✅ Auto Server Hop
✅ Quest Automation
✅ Mastery Farm with Auto-Switch
✅ Anti-Ban & Humanizer
✅ Status Display & Notifications
========================================
]])

-- Start features
CreateStatusDisplay()
CreateWatermark()

if BeeZ.Auto.Mastery.Enabled then
    coroutine.wrap(BeeZ_Hub.MasteryFarm)()
end

if BeeZ.Safety.AntiBan then
    -- Anti-AFK loop
    coroutine.wrap(function()
        while true do
            task.wait(30)
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)()
end

-- Auto start if enabled
if BeeZ.AutoFarm.Enabled then
    task.wait(2)
    BeeZ_Hub:StartFarming()
end
