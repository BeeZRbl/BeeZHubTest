
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- BeeZ Hub Configuration
local Config = {
    AutoFarm = false,
    StackFarm = false,
    FarmMethod = "Normal",
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
    FarmPriority = "Nearest",
    AntiAfk = true,
    SafeMode = true,
    UIVisible = true
}

-- Biến toàn cục
local FarmEnabled = false
local Target = nil
local HopAttempts = 0
local CurrentMastery = 0
local SkillCooldowns = {}
local BeeZ_Status = "Ready"
local BeeZ_GUI = nil
local BeeZ_Icon = nil
local MainWindow = nil
local GUIEnabled = true

-- Tạo icon toggle UI
local function CreateToggleIcon()
    -- Xóa icon cũ nếu có
    if BeeZ_Icon then
        BeeZ_Icon:Destroy()
    end
    
    -- Tạo ScreenGui cho icon
    local IconGui = Instance.new("ScreenGui")
    IconGui.Name = "BeeZIconGUI"
    IconGui.Parent = game:GetService("CoreGui")
    IconGui.ResetOnSpawn = false
    
    -- Tạo icon frame
    local IconFrame = Instance.new("Frame")
    IconFrame.Name = "BeeZIcon"
    IconFrame.Size = UDim2.new(0, 50, 0, 50)
    IconFrame.Position = UDim2.new(0, 20, 0.5, -25)
    IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    IconFrame.BackgroundTransparency = 0.2
    IconFrame.BorderSizePixel = 0
    IconFrame.ZIndex = 100
    IconFrame.Parent = IconGui
    
    -- Làm tròn góc
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = IconFrame
    
    -- Thêm shadow
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 235, 100)
    UIStroke.Thickness = 2
    UIStroke.Parent = IconFrame
    
    -- Thêm logo ong
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "🐝"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 30
    IconLabel.TextScaled = false
    IconLabel.Parent = IconFrame
    
    -- Tooltip
    local Tooltip = Instance.new("TextLabel")
    Tooltip.Name = "Tooltip"
    Tooltip.Size = UDim2.new(0, 120, 0, 30)
    Tooltip.Position = UDim2.new(1, 10, 0.5, -15)
    Tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Tooltip.BackgroundTransparency = 0.2
    Tooltip.Text = "Click to toggle UI\nBeeZ Hub v2.0"
    Tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tooltip.Font = Enum.Font.Gotham
    Tooltip.TextSize = 12
    Tooltip.TextWrapped = true
    Tooltip.Visible = false
    Tooltip.ZIndex = 101
    Tooltip.Parent = IconFrame
    
    -- Làm tròn góc tooltip
    local TooltipCorner = Instance.new("UICorner")
    TooltipCorner.CornerRadius = UDim.new(0.1, 0)
    TooltipCorner.Parent = Tooltip
    
    -- Hiệu ứng hover
    IconFrame.MouseEnter:Connect(function()
        Tooltip.Visible = true
        local tween = TweenService:Create(IconFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 55, 0, 55)
        })
        tween:Play()
    end)
    
    IconFrame.MouseLeave:Connect(function()
        Tooltip.Visible = false
        local tween = TweenService:Create(IconFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2,
            Size = UDim2.new(0, 50, 0, 50)
        })
        tween:Play()
    end)
    
    -- Sự kiện click để toggle UI
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleBeeZGUI()
            
            -- Hiệu ứng click
            local clickTween = TweenService:Create(IconFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(255, 195, 0),
                Size = UDim2.new(0, 45, 0, 45)
            })
            clickTween:Play()
            
            task.wait(0.1)
            local releaseTween = TweenService:Create(IconFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(255, 215, 0),
                Size = UDim2.new(0, 50, 0, 50)
            })
            releaseTween:Play()
        end
    end)
    
    -- Cho phép kéo icon
    local dragging = false
    local dragStart, startPos
    
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = IconFrame.Position
        end
    end)
    
    IconFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            IconFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    BeeZ_Icon = IconGui
    return IconGui
end

-- Toggle GUI chính
local function ToggleBeeZGUI()
    if not BeeZ_GUI then
        CreateBeeZGUI()
    else
        GUIEnabled = not GUIEnabled
        BeeZ_GUI.Enabled = GUIEnabled
        
        -- Cập nhật icon khi toggle
        if BeeZ_Icon then
            local iconFrame = BeeZ_Icon:FindFirstChild("BeeZIcon")
            if iconFrame then
                local iconLabel = iconFrame:FindFirstChildOfClass("TextLabel")
                if iconLabel then
                    if GUIEnabled then
                        iconLabel.Text = "🐝"
                        iconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                    else
                        iconLabel.Text = "🔒"
                        iconFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    end
                end
            end
        end
        
        BeeZ_Notify("UI " .. (GUIEnabled and "enabled" or "disabled"))
    end
end

-- Tạo GUI chính
local function CreateBeeZGUI()
    -- Xóa GUI cũ nếu có
    if BeeZ_GUI then
        BeeZ_GUI:Destroy()
    end
    
    -- Load Kavo UI Library
    local success, Library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    end)
    
    if not success then
        BeeZ_Notify("Failed to load GUI library")
        return
    end
    
    -- Tạo cửa sổ chính
    MainWindow = Library.CreateLib("🐝 BeeZ Hub v2.0", "DarkTheme")
    BeeZ_GUI = MainWindow
    
    -- Tạo tabs
    local MainTab = MainWindow:NewTab("Main")
    local FarmingTab = MainWindow:NewTab("Farming")
    local AutoTab = MainWindow:NewTab("Auto")
    local PlayerTab = MainWindow:NewTab("Player")
    local MiscTab = MainWindow:NewTab("Misc")
    
    -- Tạo sections
    local MainSection = MainTab:NewSection("BeeZ Hub Control")
    local FarmingSection = FarmingTab:NewSection("Farming Settings")
    local AutoSection = AutoTab:NewSection("Auto Settings")
    local QuestSection = AutoTab:NewSection("Quest Settings")
    local PlayerSection = PlayerTab:NewSection("Player Settings")
    local MiscSection = MiscTab:NewSection("Misc Settings")
    
    -- Main Section
    MainSection:NewLabel("🐝 BeeZ Hub v2.0")
    MainSection:NewLabel("Advanced Blox Fruits Automation")
    
    MainSection:NewButton("Toggle UI Icon", "Show/Hide the toggle icon", function()
        if BeeZ_Icon then
            BeeZ_Icon.Enabled = not BeeZ_Icon.Enabled
            BeeZ_Notify("UI Icon " .. (BeeZ_Icon.Enabled and "shown" or "hidden"))
        else
            CreateToggleIcon()
            BeeZ_Notify("UI Icon created")
        end
    end)
    
    -- Farming Section
    FarmingSection:NewToggle("Enable Auto Farm", "Starts farming automatically", function(state)
        Config.AutoFarm = state
        FarmEnabled = state
        
        if state then
            BeeZ_Status = "Farming"
            BeeZ_Notify("Auto Farm Enabled")
            coroutine.wrap(BeeZ_Farm)()
        else
            BeeZ_Status = "Idle"
            BeeZ_Notify("Auto Farm Disabled")
        end
    end)
    
    FarmingSection:NewToggle("Stack Farming", "Farm multiple enemies at once", function(state)
        Config.StackFarm = state
    end)
    
    FarmingSection:NewDropdown("Farm Method", "Choose farming method", {"Normal", "Fast", "Safe", "Boss"}, function(method)
        Config.FarmMethod = method
        BeeZ_Notify("Farm method: " .. method)
    end)
    
    FarmingSection:NewSlider("Farm Distance", "Distance to farm enemies", 50, 10, function(value)
        Config.FarmDistance = value
    end)
    
    -- Auto Section
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
    
    -- Quest Section
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
    
    -- Player Section
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
    
    -- Misc Section
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
        BeeZ_Status = "Farming"
        BeeZ_Notify("Starting farm session...")
        coroutine.wrap(BeeZ_Farm)()
        coroutine.wrap(MasteryFarm)()
    end)
    
    MiscSection:NewButton("Stop Farm", "Stop farming session", function()
        FarmEnabled = false
        Config.AutoFarm = false
        BeeZ_Status = "Idle"
        BeeZ_Notify("Farm session stopped")
    end)
    
    MiscSection:NewButton("Hide UI", "Hide the main UI (use icon to show)", function()
        if BeeZ_GUI then
            BeeZ_GUI.Enabled = false
            GUIEnabled = false
            if BeeZ_Icon then
                local iconFrame = BeeZ_Icon:FindFirstChild("BeeZIcon")
                if iconFrame then
                    local iconLabel = iconFrame:FindFirstChildOfClass("TextLabel")
                    if iconLabel then
                        iconLabel.Text = "🔓"
                    end
                end
            end
            BeeZ_Notify("UI hidden - Click icon to show")
        end
    end)
    
    return MainWindow
end

-- Các hàm chức năng BeeZ Hub
function BeeZ_Notify(message, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = "🐝 BeeZ Hub",
        Text = message,
        Duration = duration or 3,
        Icon = "rbxassetid://6723928013"
    })
end

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

function BeeZ_Farm()
    while FarmEnabled and Config.AutoFarm do
        task.wait(0.1)
        
        if Config.AntiAfk then
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
        
        local enemies = GetEnemiesInRange(Config.FarmDistance)
        Target = SelectTarget(enemies)
        
        if Target then
            if Config.IgnoreKatakuri and string.find(Target.Name:lower(), "katakuri") then
                if (Humanoid.Health / Humanoid.MaxHealth) * 100 > Config.IgnoreKatakuriHP then
                    Target = nil
                    continue
                end
            end
            
            HumanoidRootPart.CFrame = CFrame.new(Target.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
            UseSkill(Config.SelectedSkill)
            
            if Config.StackFarm and #enemies > 1 then
                for i = 2, math.min(5, #enemies) do
                    UseSkill("X")
                end
            end
        else
            if Config.AutoHop then
                FindKatakuri()
            end
        end
    end
end

function UseSkill(skill)
    if skill and not SkillCooldowns[skill] then
        game:GetService("VirtualInputManager"):SendKeyEvent(true, skill, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, skill, false, game)
        
        SkillCooldowns[skill] = true
        task.wait(1)
        SkillCooldowns[skill] = false
    end
end

function FindKatakuri()
    if HopAttempts >= Config.MaxHopAttempts then
        BeeZ_Notify("Max hop attempts reached")
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
        BeeZ_Notify("Server hopping... (" .. HopAttempts .. "/" .. Config.MaxHopAttempts .. ")")
        
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                task.wait(5)
                break
            end
        end
    end
end

function AutoQuest()
    while Config.AutoQuest.Katakuri or Config.AutoQuest.Bone or Config.AutoQuest.Tyrant do
        task.wait(5)
        
        local playerGui = Player:WaitForChild("PlayerGui")
        local questLog = playerGui:FindFirstChild("QuestLog")
        
        if questLog then
            if Config.AutoQuest.Katakuri and not string.find(questLog.Text, "Katakuri") then
                AcceptQuest("Katakuri")
            end
            
            if Config.AutoQuest.Bone and not string.find(questLog.Text, "Bone") then
                AcceptQuest("Bone")
            end
            
            if Config.AutoQuest.Tyrant and not string.find(questLog.Text, "Tyrant") then
                AcceptQuest("Tyrant")
            end
        end
    end
end

function AcceptQuest(questName)
    BeeZ_Notify("Accepting " .. questName .. " quest")
end

function MasteryFarm()
    while Config.AutoFarm and CurrentMastery < Config.MasteryTarget do
        task.wait(1)
        
        local backpack = Player:WaitForChild("Backpack")
        local tool = backpack:FindFirstChildOfClass("Tool")
        
        if tool and tool:FindFirstChild("Mastery") then
            CurrentMastery = tool.Mastery.Value
        end
        
        if CurrentMastery >= Config.MasteryTarget then
            BeeZ_Notify("Mastery target reached!")
            if Config.AutoFarm then
                Config.AutoFarm = false
            end
        end
    end
end

function SafeMode()
    if Config.SafeMode then
        while true do
            task.wait(math.random(10, 30))
            
            if math.random(1, 100) <= 10 then
                local pauseTime = math.random(2, 5)
                BeeZ_Notify("Taking a break for " .. pauseTime .. " seconds")
                task.wait(pauseTime)
            end
            
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

-- Tạo status display
local function CreateStatusDisplay()
    local StatusGui = Instance.new("ScreenGui")
    StatusGui.Name = "BeeZStatusDisplay"
    StatusGui.Parent = game:GetService("CoreGui")
    StatusGui.ResetOnSpawn = false
    
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(0, 220, 0, 100)
    StatusFrame.Position = UDim2.new(1, -230, 0, 10)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    StatusFrame.BackgroundTransparency = 0.3
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = StatusGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.1, 0)
    UICorner.Parent = StatusFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.Text = "🐝 BeeZ Status"
    Title.Font = Enum.Font.Code
    Title.TextSize = 16
    Title.Parent = StatusFrame
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -10, 0, 60)
    StatusText.Position = UDim2.new(0, 5, 0, 35)
    StatusText.BackgroundTransparency = 1
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusText.Font = Enum.Font.Code
    StatusText.TextSize = 12
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.TextYAlignment = Enum.TextYAlignment.Top
    StatusText.Parent = StatusFrame
    
    -- Update status
    coroutine.wrap(function()
        while true do
            task.wait(1)
            local enemies = #GetEnemiesInRange(100)
            StatusText.Text = string.format("Status: %s\nMastery: %d/%d\nTargets: %d\nHops: %d/%d",
                BeeZ_Status, CurrentMastery, Config.MasteryTarget, enemies, HopAttempts, Config.MaxHopAttempts)
        end
    end)()
    
    return StatusGui
end

-- Khởi tạo BeeZ Hub
print([[
========================================
   ____  ______  ______      __
  / __ )/ ____/ / ____/___  / /___  _____
 / __  / __/   / /   / __ \/ / __ \/ ___/
/ /_/ / /___  / /___/ /_/ / / /_/ (__  )
/_____/_____/  \____/\____/_/\____/____/
                                        
        Version 2.0 with Toggle Icon
========================================
]])

-- Tạo icon và GUI
CreateToggleIcon()
CreateBeeZGUI()
CreateStatusDisplay()

BeeZ_Notify("BeeZ Hub v2.0 loaded!\nClick the 🐝 icon to toggle UI", 5)

-- Thêm hotkey (F8 để toggle UI)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F8 then
            ToggleBeeZGUI()
        elseif input.KeyCode == Enum.KeyCode.F9 then
            -- Toggle farm
            FarmEnabled = not FarmEnabled
            Config.AutoFarm = FarmEnabled
            BeeZ_Status = FarmEnabled and "Farming" or "Idle"
            BeeZ_Notify("Farm " .. (FarmEnabled and "started" or "stopped"))
            if FarmEnabled then
                coroutine.wrap(BeeZ_Farm)()
            end
        end
    end
end)

BeeZ_Notify("Hotkeys:\nF8 - Toggle UI\nF9 - Toggle Farm", 5)
