
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

-- Biến toàn cục
local BeeZ_GUI = nil
local MainWindow = nil
local GUIEnabled = true
local BeeZ_Icon = nil

-- Tạo icon toggle đơn giản
local function CreateSimpleToggleIcon()
    -- Xóa icon cũ nếu có
    if BeeZ_Icon then
        BeeZ_Icon:Destroy()
    end
    
    -- Tạo ScreenGui cho icon
    local IconGui = Instance.new("ScreenGui")
    IconGui.Name = "BeeZToggleIcon"
    IconGui.Parent = game:GetService("CoreGui")
    IconGui.ResetOnSpawn = false
    
    -- Tạo icon frame
    local IconFrame = Instance.new("Frame")
    IconFrame.Name = "ToggleIcon"
    IconFrame.Size = UDim2.new(0, 40, 0, 40)
    IconFrame.Position = UDim2.new(0, 10, 0.5, -20)
    IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    IconFrame.BackgroundTransparency = 0.3
    IconFrame.BorderSizePixel = 0
    IconFrame.ZIndex = 999
    IconFrame.Parent = IconGui
    
    -- Làm tròn góc
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = IconFrame
    
    -- Thêm logo ong
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "🐝"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 24
    IconLabel.Parent = IconFrame
    
    -- Text hiển thị trạng thái
    local StateLabel = Instance.new("TextLabel")
    StateLabel.Size = UDim2.new(1, 0, 0, 15)
    StateLabel.Position = UDim2.new(0, 0, 1, 2)
    StateLabel.BackgroundTransparency = 1
    StateLabel.Text = "ON"
    StateLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    StateLabel.Font = Enum.Font.Gotham
    StateLabel.TextSize = 10
    StateLabel.Parent = IconFrame
    
    -- Sự kiện click để toggle UI
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleBeeZGUI()
            
            -- Hiệu ứng click
            local clickTween = TweenService:Create(IconFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(255, 195, 0),
                Size = UDim2.new(0, 36, 0, 36)
            })
            clickTween:Play()
            
            task.wait(0.1)
            local releaseTween = TweenService:Create(IconFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = GUIEnabled and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(100, 100, 100),
                Size = UDim2.new(0, 40, 0, 40)
            })
            releaseTween:Play()
        end
    end)
    
    -- Cập nhật trạng thái icon
    local function UpdateIconState()
        if GUIEnabled then
            IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            IconLabel.Text = "🐝"
            StateLabel.Text = "ON"
            StateLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            IconFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            IconLabel.Text = "🔒"
            StateLabel.Text = "OFF"
            StateLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end
    
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
    
    BeeZ_Icon = {
        Gui = IconGui,
        Update = UpdateIconState
    }
    
    UpdateIconState()
    return IconGui
end

-- Toggle GUI chính
local function ToggleBeeZGUI()
    if BeeZ_GUI then
        GUIEnabled = not GUIEnabled
        BeeZ_GUI.Enabled = GUIEnabled
        
        -- Cập nhật icon
        if BeeZ_Icon and BeeZ_Icon.Update then
            BeeZ_Icon.Update()
        end
        
        BeeZ_Notify("UI " .. (GUIEnabled and "bật" or "tắt"))
    end
end

-- Tạo GUI chính đơn giản
local function CreateSimpleGUI()
    -- Xóa GUI cũ nếu có
    if BeeZ_GUI then
        BeeZ_GUI:Destroy()
    end
    
    -- Load Kavo UI Library
    local success, Library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    end)
    
    if not success then
        -- Fallback GUI đơn giản
        BeeZ_Notify("Không thể load GUI library")
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
    
    -- Main Section
    local MainSection = MainTab:NewSection("BeeZ Hub Control")
    MainSection:NewLabel("🐝 BeeZ Hub v2.0")
    MainSection:NewLabel("Advanced Blox Fruits Automation")
    MainSection:NewLabel("Nhấn icon 🐝 để bật/tắt UI")
    
    -- Farming Section
    local FarmingSection = FarmingTab:NewSection("Farming Settings")
    FarmingSection:NewToggle("Enable Auto Farm", "Bật/tắt tự động farm", function(state)
        BeeZ_Notify("Auto Farm: " .. (state and "BẬT" or "TẮT"))
    end)
    
    FarmingSection:NewToggle("Stack Farming", "Farm nhiều mục tiêu", function(state)
        BeeZ_Notify("Stack Farming: " .. (state and "BẬT" : "TẮT"))
    end)
    
    FarmingSection:NewDropdown("Farm Method", "Chọn cách farm", {"Normal", "Fast", "Safe", "Boss"}, function(method)
        BeeZ_Notify("Farm method: " .. method)
    end)
    
    FarmingSection:NewSlider("Farm Distance", "Khoảng cách farm", 50, 10, function(value)
        BeeZ_Notify("Farm Distance: " .. value)
    end)
    
    -- Auto Section
    local AutoSection = AutoTab:NewSection("Auto Settings")
    AutoSection:NewToggle("Ignore Katakuri", "Bỏ qua Katakuri", function(state)
        BeeZ_Notify("Ignore Katakuri: " .. (state and "BẬT" : "TẮT"))
    end)
    
    AutoSection:NewToggle("Auto Server Hop", "Tự động đổi server", function(state)
        BeeZ_Notify("Auto Server Hop: " .. (state and "BẬT" : "TẮT"))
    end)
    
    -- Player Section
    local PlayerSection = PlayerTab:NewSection("Player Settings")
    PlayerSection:NewSlider("Mastery Target", "Mục tiêu Mastery", 500, 100, function(value)
        BeeZ_Notify("Mastery Target: " .. value)
    end)
    
    PlayerSection:NewDropdown("Skill Priority", "Ưu tiên skill", {"Z", "X", "C", "V", "F"}, function(skill)
        BeeZ_Notify("Skill Priority: " .. skill)
    end)
    
    -- Misc Section
    local MiscSection = MiscTab:NewSection("Misc Settings")
    MiscSection:NewToggle("Anti-AFK", "Chống AFK", function(state)
        BeeZ_Notify("Anti-AFK: " .. (state and "BẬT" : "TẮT"))
    end)
    
    MiscSection:NewToggle("Safe Mode", "Chế độ an toàn", function(state)
        BeeZ_Notify("Safe Mode: " .. (state and "BẬT" : "TẮT"))
    end)
    
    MiscSection:NewButton("Test Button", "Nút test", function()
        BeeZ_Notify("Test button clicked!")
    end)
    
    MiscSection:NewButton("Ẩn UI", "Ẩn UI này (dùng icon để bật lại)", function()
        ToggleBeeZGUI()
    end)
    
    return MainWindow
end

-- Hàm thông báo
function BeeZ_Notify(message, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = "🐝 BeeZ Hub",
        Text = message,
        Duration = duration or 2,
        Icon = "rbxassetid://6723928013"
    })
end

-- Khởi động BeeZ Hub
print([[
========================================
      🐝 BeeZ Hub v2.0 Loaded!
     Icon Toggle UI - Simple Version
========================================
]])

-- Tạo icon và GUI
CreateSimpleToggleIcon()
CreateSimpleGUI()

-- Hotkey F9 để toggle UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F9 then
        ToggleBeeZGUI()
    end
end)

BeeZ_Notify("BeeZ Hub v2.0 đã sẵn sàng!\nNhấn icon 🐝 hoặc F9 để bật/tắt UI", 4)
