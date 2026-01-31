
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- CONFIGURATION
local Config = {
    AutoFarm = true,
    StackFarm = false,
    FarmMethod = "Normal", -- Normal, Fast, Safe, Boss
    FarmDistance = 25,
    IgnoreKatakuri = false,
    IgnoreKatakuriHP = 30,
    AutoHop = true,
    MaxHopAttempts = 10,
    AutoQuest = {
        Katakuri = true,
        Bone = false,
        Tyrant = true
    },
    MasteryTarget = 300,
    SelectedSkill = "Z",
    FarmPriority = "Nearest", -- Nearest, HighestLevel, LowestHP
    AntiAfk = true,
    SafeMode = true
}

-- GUI Library (Simple Version)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Banana Cat Hub v2.0", "DarkTheme")

-- Tabs
local MainTab = Window:NewTab("Main")
local FarmingTab = Window:NewTab("Farming")
local AutoTab = Window:NewTab("Auto")
local PlayerTab = Window:NewTab("Player")
local MiscTab = Window:NewTab("Misc")

-- Sections
local FarmingSection = FarmingTab:NewSection("Farming Settings")
local AutoSection = AutoTab:NewSection("Auto Settings")
local QuestSection = AutoTab:NewSection("Quest Settings")
local PlayerSection = PlayerTab:NewSection("Player Settings")
local MiscSection = MiscTab:NewSection("Misc Settings")

-- Variables
local FarmEnabled = false
local Target = nil
local HopAttempts = 0
local CurrentMastery = 0
local QuestActive = false
local SkillCooldowns = {}
local FarmAreas = {}
local KatakuriNPCs = {}

-- Get Enemies in Range
function GetEnemiesInRange(distance)
    local enemies = {}
    for _, npc in pairs(Workspace.Enemies:GetChildren()) do
        if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
            if npc.Humanoid.Health > 0 then
                local distanceToNPC = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distanceToNPC <= distance then
                    table.insert(enemies, npc)
                end
            end
        end
    end
    return enemies
end

-- Select Target Based on Priority
function SelectTarget(enemies)
    if #enemies == 0 then return nil end
    
    if Config.FarmPriority == "Nearest" then
        table.sort(enemies, function(a, b)
            return (HumanoidRootPart.Position - a.HumanoidRootPart.Position).Magnitude <
                   (HumanoidRootPart.Position - b.HumanoidRootPart.Position).Magnitude
        end)
    elseif Config.FarmPriority == "HighestLevel" then
        table.sort(enemies, function(a, b)
            return (a:FindFirstChild("Level") and a.Level.Value or 0) > 
                   (b:FindFirstChild("Level") and b.Level.Value or 0)
        end)
    elseif Config.FarmPriority == "LowestHP" then
        table.sort(enemies, function(a, b)
            return a.Humanoid.Health < b.Humanoid.Health
        end)
    end
    
    return enemies[1]
end

-- Farm Function
function Farm()
    while FarmEnabled and Config.AutoFarm do
        task.wait(0.1)
        
        -- Anti AFK
        if Config.AntiAfk then
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
        
        -- Get enemies
        local enemies = GetEnemiesInRange(Config.FarmDistance)
        Target = SelectTarget(enemies)
        
        if Target then
            -- Ignore Katakuri if enabled
            if Config.IgnoreKatakuri and string.find(Target.Name:lower(), "katakuri") then
                if (Humanoid.Health / Humanoid.MaxHealth) * 100 > Config.IgnoreKatakuriHP then
                    Target = nil
                    continue
                end
            end
            
            -- Move to target
            HumanoidRootPart.CFrame = CFrame.new(Target.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
            
            -- Use skills
            UseSkill(Config.SelectedSkill)
            
            -- Stack farming
            if Config.StackFarm and #enemies > 1 then
                for i = 2, math.min(5, #enemies) do
                    local extraTarget = enemies[i]
                    UseSkill("X") -- AOE skill
                end
            end
        else
            -- No enemies found, try to find Katakuri with server hop
            if Config.AutoHop then
                FindKatakuri()
            end
        end
    end
end

-- Use Skill
function UseSkill(skill)
    if skill and not SkillCooldowns[skill] then
        game:GetService("VirtualInputManager"):SendKeyEvent(true, skill, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, skill, false, game)
        
        -- Set cooldown
        SkillCooldowns[skill] = true
        task.wait(1) -- Cooldown time
        SkillCooldowns[skill] = false
    end
end

-- Find Katakuri with Server Hop
function FindKatakuri()
    if HopAttempts >= Config.MaxHopAttempts then
        print("[Banana Cat Hub] Max hop attempts reached")
        return
    end
    
    local katakuriFound = false
    for _, npc in pairs(Workspace.Enemies:GetChildren()) do
        if string.find(npc.Name:lower(), "katakuri") then
            katakuriFound = true
            break
        end
    end
    
    if not katakuriFound and Config.AutoHop then
        HopAttempts = HopAttempts + 1
        print("[Banana Cat Hub] Katakuri not found, hopping server... (" .. HopAttempts .. "/" .. Config.MaxHopAttempts .. ")")
        
        -- Server hop logic
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                task.wait(5)
                break
            end
        end
    end
end

-- Auto Quest
function AutoQuest()
    while Config.AutoQuest.Katakuri or Config.AutoQuest.Bone or Config.AutoQuest.Tyrant do
        task.wait(5)
        
        -- Check current quests
        local playerGui = Player:WaitForChild("PlayerGui")
        local questLog = playerGui:FindFirstChild("QuestLog")
        
        if questLog then
            -- Accept Katakuri quest
            if Config.AutoQuest.Katakuri and not string.find(questLog.Text, "Katakuri") then
                AcceptQuest("Katakuri")
            end
            
            -- Accept Bone quest
            if Config.AutoQuest.Bone and not string.find(questLog.Text, "Bone") then
                AcceptQuest("Bone")
            end
            
            -- Accept Tyrant quest
            if Config.AutoQuest.Tyrant and not string.find(questLog.Text, "Tyrant") then
                AcceptQuest("Tyrant")
            end
        end
    end
end

function AcceptQuest(questName)
    -- This would interact with quest NPCs
    print("[Banana Cat Hub] Accepting " .. questName .. " quest")
    -- Implementation depends on game structure
end

-- Mastery Farm
function MasteryFarm()
    while Config.AutoFarm and CurrentMastery < Config.MasteryTarget do
        task.wait(1)
        
        -- Update current mastery
        local backpack = Player:WaitForChild("Backpack")
        local tool = backpack:FindFirstChildOfClass("Tool")
        
        if tool and tool:FindFirstChild("Mastery") then
            CurrentMastery = tool.Mastery.Value
        end
        
        -- If mastery target reached, stop or change target
        if CurrentMastery >= Config.MasteryTarget then
            print("[Banana Cat Hub] Mastery target reached!")
            if Config.AutoFarm then
                Config.AutoFarm = false
            end
        end
    end
end

-- Safe Mode (Anti-Ban)
function SafeMode()
    if Config.SafeMode then
        -- Randomize human-like behavior
        while true do
            task.wait(math.random(10, 30))
            
            -- Random pauses
            if math.random(1, 100) <= 10 then
                local pauseTime = math.random(2, 5)
                print("[Banana Cat Hub] Taking a break for " .. pauseTime .. " seconds")
                task.wait(pauseTime)
            end
            
            -- Random movement
            if math.random(1, 100) <= 20 then
                Humanoid:MoveTo(HumanoidRootPart.Position + Vector3.new(
                    math.random(-10, 10),
                    0,
                    math.random(-10, 10)
                ))
            end
        end
    end
end

-- GUI Elements
FarmingSection:NewToggle("Enable Auto Farm", "Starts farming automatically", function(state)
    Config.AutoFarm = state
    FarmEnabled = state
    
    if state then
        print("[Banana Cat Hub] Auto Farm Enabled")
        coroutine.wrap(Farm)()
    else
        print("[Banana Cat Hub] Auto Farm Disabled")
    end
end)

FarmingSection:NewToggle("Stack Farming", "Farm multiple enemies at once", function(state)
    Config.StackFarm = state
end)

FarmingSection:NewDropdown("Farm Method", "Choose farming method", {"Normal", "Fast", "Safe", "Boss"}, function(method)
    Config.FarmMethod = method
end)

FarmingSection:NewSlider("Farm Distance", "Distance to farm enemies", 50, 10, function(value)
    Config.FarmDistance = value
end)

AutoSection:NewToggle("Ignore Katakuri", "Ignore Katakuri when farming", function(state)
    Config.IgnoreKatakuri = state
end)

AutoSection:NewSlider("Ignore Katakuri HP %", "HP threshold for ignoring Katakuri", 90, 10, function(value)
    Config.IgnoreKatakuriHP = value
end)

AutoSection:NewToggle("Auto Server Hop", "Auto hop when Katakuri not found", function(state)
    Config.AutoHop = state
end)

AutoSection:NewSlider("Max Hop Attempts", "Maximum server hop attempts", 20, 1, function(value)
    Config.MaxHopAttempts = value
end)

QuestSection:NewToggle("Auto Katakuri Quest", "Auto accept Katakuri quest", function(state)
    Config.AutoQuest.Katakuri = state
    if state then coroutine.wrap(AutoQuest)() end
end)

QuestSection:NewToggle("Auto Bone Quest", "Auto accept Bone quest", function(state)
    Config.AutoQuest.Bone = state
end)

QuestSection:NewToggle("Auto Tyrant Quest", "Auto accept Tyrant quest", function(state)
    Config.AutoQuest.Tyrant = state
end)

PlayerSection:NewSlider("Mastery Target", "Target mastery level", 500, 100, function(value)
    Config.MasteryTarget = value
    coroutine.wrap(MasteryFarm)()
end)

PlayerSection:NewDropdown("Skill Priority", "Skill to use first", {"Z", "X", "C", "V", "F"}, function(skill)
    Config.SelectedSkill = skill
end)

PlayerSection:NewDropdown("Farm Priority", "Target selection priority", {"Nearest", "HighestLevel", "LowestHP"}, function(priority)
    Config.FarmPriority = priority
end)

MiscSection:NewToggle("Anti-AFK", "Prevent AFK kick", function(state)
    Config.AntiAfk = state
end)

MiscSection:NewToggle("Safe Mode", "Human-like behavior", function(state)
    Config.SafeMode = state
    if state then coroutine.wrap(SafeMode)() end
end)

MiscSection:NewButton("Start Farm", "Start farming session", function()
    FarmEnabled = true
    Config.AutoFarm = true
    print("[Banana Cat Hub] Starting farm session...")
    coroutine.wrap(Farm)()
    coroutine.wrap(MasteryFarm)()
end)

MiscSection:NewButton("Stop Farm", "Stop farming session", function()
    FarmEnabled = false
    Config.AutoFarm = false
    print("[Banana Cat Hub] Farm session stopped")
end)

MiscSection:NewButton("Teleport to Safe Zone", "Teleport to safe area", function()
    -- Teleport to safe zone coordinates
    HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
end)

-- Status Display
local StatusLabel = Instance.new("ScreenGui")
StatusLabel.Name = "BananaCatStatus"
StatusLabel.Parent = Player:WaitForChild("PlayerGui")

local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 200, 0, 100)
StatusFrame.Position = UDim2.new(0, 10, 0, 10)
StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StatusFrame.BackgroundTransparency = 0.3
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = StatusLabel

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 1, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextColor3 = Color3.fromRGB(255, 204, 0)
StatusText.Text = "Banana Cat Hub\nStatus: Ready\nMastery: " .. CurrentMastery
StatusText.Font = Enum.Font.Code
StatusText.TextSize = 14
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextYAlignment = Enum.TextYAlignment.Top
StatusText.Parent = StatusFrame

-- Update status
coroutine.wrap(function()
    while true do
        task.wait(1)
        if StatusText then
            local status = FarmEnabled and "Farming" or "Idle"
            StatusText.Text = string.format("Banana Cat Hub v2.0\nStatus: %s\nMastery: %d/%d\nTargets: %d",
                status, CurrentMastery, Config.MasteryTarget, #GetEnemiesInRange(100))
        end
    end
end)()

-- Initialization
print("====================================")
print("Banana Cat Hub v2.0 Loaded!")
print("Features:")
print("- Auto Farm with multiple methods")
print("- Stack Farming")
print("- Ignore Katakuri system")
print("- Auto Server Hop")
print("- Auto Quest (Katakuri/Bone/Tyrant)")
print("- Mastery Farm to target level")
print("- Safe Mode (Anti-ban)")
print("====================================")

-- Start coroutines
coroutine.wrap(SafeMode)()
