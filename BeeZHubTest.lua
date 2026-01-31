
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ===== TẠO GUI CHÍNH =====
local BananaCatGUI = Instance.new("ScreenGui")
BananaCatGUI.Name = "BeeZHub"
BananaCatGUI.Parent = player:WaitForChild("PlayerGui")

-- Main Container
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Parent = BananaCatGUI
MainContainer.Size = UDim2.new(0.35, 0, 0.75, 0)
MainContainer.Position = UDim2.new(0.01, 0, 0.12, 0)
MainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainContainer.BorderSizePixel = 0

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0.02, 0)
ContainerCorner.Parent = MainContainer

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(255, 200, 0)
ContainerStroke.Thickness = 2
ContainerStroke.Parent = MainContainer

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainContainer
Header.Size = UDim2.new(1, 0, 0.07, 0)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Header
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🍌 Banana Cat Hub - Blox Fruit"
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- Toggle UI Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = Header
ToggleBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
ToggleBtn.Position = UDim2.new(0.9, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
ToggleBtn.Text = "X"
ToggleBtn.TextColor3 = Color3.white
ToggleBtn.Font = Enum.Font.GothamBold

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0.2, 0)
ToggleCorner.Parent = ToggleBtn

-- Search
local SearchFrame = Instance.new("Frame")
SearchFrame.Name = "SearchFrame"
SearchFrame.Parent = MainContainer
SearchFrame.Size = UDim2.new(0.95, 0, 0.05, 0)
SearchFrame.Position = UDim2.new(0.025, 0, 0.08, 0)
SearchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Parent = SearchFrame
SearchBox.Size = UDim2.new(0.9, 0, 0.7, 0)
SearchBox.Position = UDim2.new(0.05, 0, 0.15, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = "Search section or Func"
SearchBox.TextColor3 = Color3.fromRGB(180, 180, 200)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.PlaceholderText = "Search section or Func"

-- ===== LEFT MENU =====
local LeftMenu = Instance.new("Frame")
LeftMenu.Name = "LeftMenu"
LeftMenu.Parent = MainContainer
LeftMenu.Size = UDim2.new(0.28, 0, 0.82, 0)
LeftMenu.Position = UDim2.new(0.02, 0, 0.14, 0)
LeftMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 35)

local MenuItems = {
    "🏆 Farming",
    "⚡ Speed Control",
    "⬆️ Jump Control", 
    "👤 LocalPlayer",
    "⚙️ Settings",
    "🎮 Skills"
}

local MenuButtons = {}

for i, itemName in ipairs(MenuItems) do
    local MenuButton = Instance.new("TextButton")
    MenuButton.Name = itemName:gsub("[^%w]", "")
    MenuButton.Parent = LeftMenu
    MenuButton.Size = UDim2.new(0.9, 0, 0.12, 0)
    MenuButton.Position = UDim2.new(0.05, 0, 0.05 + (i-1) * 0.14, 0)
    MenuButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    MenuButton.Text = itemName
    MenuButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    MenuButton.Font = Enum.Font.Gotham
    MenuButton.TextSize = 13
    MenuButton.TextXAlignment = Enum.TextXAlignment.Left
    
    local ButtonPadding = Instance.new("UIPadding")
    ButtonPadding.Parent = MenuButton
    ButtonPadding.PaddingLeft = UDim.new(0.05, 0)
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0.05, 0)
    ButtonCorner.Parent = MenuButton
    
    table.insert(MenuButtons, MenuButton)
end

-- ===== CONTENT AREA =====
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainContainer
ContentArea.Size = UDim2.new(0.68, 0, 0.82, 0)
ContentArea.Position = UDim2.new(0.3, 0, 0.14, 0)
ContentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 35)

-- ===== FARMING SECTION =====
local FarmingSection = Instance.new("ScrollingFrame")
FarmingSection.Name = "FarmingSection"
FarmingSection.Parent = ContentArea
FarmingSection.Size = UDim2.new(1, 0, 1, 0)
FarmingSection.BackgroundTransparency = 1
FarmingSection.ScrollBarThickness = 6
FarmingSection.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 0)
FarmingSection.CanvasSize = UDim2.new(0, 0, 1.5, 0)
FarmingSection.Visible = true

-- Farming Options
local FarmingFrame = Instance.new("Frame")
FarmingFrame.Name = "FarmingFrame"
FarmingFrame.Parent = FarmingSection
FarmingFrame.Size = UDim2.new(0.95, 0, 0.25, 0)
FarmingFrame.Position = UDim2.new(0.025, 0, 0.02, 0)
FarmingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

local FarmingTitle = Instance.new("TextLabel")
FarmingTitle.Name = "Title"
FarmingTitle.Parent = FarmingFrame
FarmingTitle.Size = UDim2.new(1, 0, 0.15, 0)
FarmingTitle.BackgroundTransparency = 1
FarmingTitle.Text = "🌾 Farming"
FarmingTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
FarmingTitle.Font = Enum.Font.GothamBold
FarmingTitle.TextSize = 16

local FarmingOptions = {
    "Stack Farming",
    "Farming Other", 
    "Fruit and Raid",
    "Sea Event"
}

for i, option in ipairs(FarmingOptions) do
    local OptionFrame = Instance.new("Frame")
    OptionFrame.Parent = FarmingFrame
    OptionFrame.Size = UDim2.new(0.95, 0, 0.15, 0)
    OptionFrame.Position = UDim2.new(0.025, 0, 0.2 + (i-1)*0.18, 0)
    OptionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    
    local OptionLabel = Instance.new("TextLabel")
    OptionLabel.Parent = OptionFrame
    OptionLabel.Size = UDim2.new(0.7, 0, 1, 0)
    OptionLabel.BackgroundTransparency = 1
    OptionLabel.Text = option
    OptionLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    OptionLabel.Font = Enum.Font.Gotham
    OptionLabel.TextSize = 14
    OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Toggle = Instance.new("TextButton")
    Toggle.Name = "Toggle"
    Toggle.Parent = OptionFrame
    Toggle.Size = UDim2.new(0.15, 0, 0.6, 0)
    Toggle.Position = UDim2.new(0.8, 0, 0.2, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(220, 220, 220)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 12
end

-- Method Farms
local MethodFrame = Instance.new("Frame")
MethodFrame.Name = "MethodFrame"
MethodFrame.Parent = FarmingSection
MethodFrame.Size = UDim2.new(0.95, 0, 0.25, 0)
MethodFrame.Position = UDim2.new(0.025, 0, 0.3, 0)
MethodFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

local MethodTitle = Instance.new("TextLabel")
MethodTitle.Name = "Title"
MethodTitle.Parent = MethodFrame
MethodTitle.Size = UDim2.new(1, 0, 0.15, 0)
MethodTitle.BackgroundTransparency = 1
MethodTitle.Text = "🎯 Select Method Farms"
MethodTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
MethodTitle.Font = Enum.Font.GothamBold
MethodTitle.TextSize = 16

local MethodOptions = {
    "Distance Farm Aura",
    "Ignore Attack Katakuri",
    "Hop Find Katakuri", 
    "Auto Quest [Katakuri/Bone/Tyrant]"
}

for i, option in ipairs(MethodOptions) do
    local OptionFrame = Instance.new("Frame")
    OptionFrame.Parent = MethodFrame
    OptionFrame.Size = UDim2.new(0.95, 0, 0.15, 0)
    OptionFrame.Position = UDim2.new(0.025, 0, 0.2 + (i-1)*0.18, 0)
    OptionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    
    local OptionLabel = Instance.new("TextLabel")
    OptionLabel.Parent = OptionFrame
    OptionLabel.Size = UDim2.new(0.7, 0, 1, 0)
    OptionLabel.BackgroundTransparency = 1
    OptionLabel.Text = option
    OptionLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    OptionLabel.Font = Enum.Font.Gotham
    OptionLabel.TextSize = 14
    OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Toggle = Instance.new("TextButton")
    Toggle.Name = "Toggle"
    Toggle.Parent = OptionFrame
    Toggle.Size = UDim2.new(0.15, 0, 0.6, 0)
    Toggle.Position = UDim2.new(0.8, 0, 0.2, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(220, 220, 220)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 12
end

-- Start Farm Button
local StartFarmBtn = Instance.new("TextButton")
StartFarmBtn.Name = "StartFarmBtn"
StartFarmBtn.Parent = FarmingSection
StartFarmBtn.Size = UDim2.new(0.95, 0, 0.08, 0)
StartFarmBtn.Position = UDim2.new(0.025, 0, 0.58, 0)
StartFarmBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
StartFarmBtn.Text = "🚀 Start Farm"
StartFarmBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
StartFarmBtn.Font = Enum.Font.GothamBold
StartFarmBtn.TextSize = 16

-- Mastery Farm
local MasteryFrame = Instance.new("Frame")
MasteryFrame.Name = "MasteryFrame"
MasteryFrame.Parent = FarmingSection
MasteryFrame.Size = UDim2.new(0.95, 0, 0.1, 0)
MasteryFrame.Position = UDim2.new(0.025, 0, 0.68, 0)
MasteryFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

local MasteryLabel = Instance.new("TextLabel")
MasteryLabel.Name = "MasteryLabel"
MasteryLabel.Parent = MasteryFrame
MasteryLabel.Size = UDim2.new(0.5, 0, 1, 0)
MasteryLabel.BackgroundTransparency = 1
MasteryLabel.Text = "⭐ Mastery Farm:"
MasteryLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
MasteryLabel.Font = Enum.Font.GothamBold
MasteryLabel.TextSize = 16

local MasteryValue = Instance.new("TextLabel")
MasteryValue.Name = "MasteryValue"
MasteryValue.Parent = MasteryFrame
MasteryValue.Size = UDim2.new(0.4, 0, 1, 0)
MasteryValue.Position = UDim2.new(0.55, 0, 0, 0)
MasteryValue.BackgroundTransparency = 1
MasteryValue.Text = "300"
MasteryValue.TextColor3 = Color3.fromRGB(0, 255, 150)
MasteryValue.Font = Enum.Font.GothamBold
MasteryValue.TextSize = 24

-- ===== SPEED CONTROL SECTION =====
local SpeedSection = Instance.new("Frame")
SpeedSection.Name = "SpeedSection"
SpeedSection.Parent = ContentArea
SpeedSection.Size = UDim2.new(1, 0, 1, 0)
SpeedSection.BackgroundTransparency = 1
SpeedSection.Visible = false

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Name = "SpeedTitle"
SpeedTitle.Parent = SpeedSection
SpeedTitle.Size = UDim2.new(1, 0, 0.1, 0)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "⚡ SPEED CONTROL"
SpeedTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.TextSize = 20

-- Speed Display
local SpeedDisplay = Instance.new("Frame")
SpeedDisplay.Name = "SpeedDisplay"
SpeedDisplay.Parent = SpeedSection
SpeedDisplay.Size = UDim2.new(0.9, 0, 0.15, 0)
SpeedDisplay.Position = UDim2.new(0.05, 0, 0.15, 0)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Parent = SpeedDisplay
SpeedLabel.Size = UDim2.new(0.6, 0, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "🏃 TỐC ĐỘ CHẠY:"
SpeedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 18

local SpeedNumber = Instance.new("TextLabel")
SpeedNumber.Name = "SpeedNumber"
SpeedNumber.Parent = SpeedDisplay
SpeedNumber.Size = UDim2.new(0.4, 0, 1, 0)
SpeedNumber.Position = UDim2.new(0.6, 0, 0, 0)
SpeedNumber.BackgroundTransparency = 1
SpeedNumber.Text = "16"
SpeedNumber.TextColor3 = Color3.fromRGB(0, 255, 150)
SpeedNumber.Font = Enum.Font.GothamBold
SpeedNumber.TextSize = 24

-- Speed Slider
local SpeedSliderBg = Instance.new("TextButton")
SpeedSliderBg.Name = "SpeedSliderBg"
SpeedSliderBg.Parent = SpeedSection
SpeedSliderBg.Size = UDim2.new(0.9, 0, 0.08, 0)
SpeedSliderBg.Position = UDim2.new(0.05, 0, 0.35, 0)
SpeedSliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SpeedSliderBg.Text = ""
SpeedSliderBg.AutoButtonColor = false

local SpeedSliderFill = Instance.new("Frame")
SpeedSliderFill.Name = "SpeedSliderFill"
SpeedSliderFill.Parent = SpeedSliderBg
SpeedSliderFill.Size = UDim2.new(0.16, 0, 1, 0)
SpeedSliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
SpeedSliderFill.BorderSizePixel = 0

-- Speed Controls
local SpeedControls = Instance.new("Frame")
SpeedControls.Name = "SpeedControls"
SpeedControls.Parent = SpeedSection
SpeedControls.Size = UDim2.new(0.9, 0, 0.1, 0)
SpeedControls.Position = UDim2.new(0.05, 0, 0.45, 0)
SpeedControls.BackgroundTransparency = 1

local SpeedMinus = Instance.new("TextButton")
SpeedMinus.Name = "SpeedMinus"
SpeedMinus.Parent = SpeedControls
SpeedMinus.Size = UDim2.new(0.2, 0, 1, 0)
SpeedMinus.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
SpeedMinus.Text = "-"
SpeedMinus.TextColor3 = Color3.white
SpeedMinus.Font = Enum.Font.GothamBold
SpeedMinus.TextSize = 20

local SpeedPlus = Instance.new("TextButton")
SpeedPlus.Name = "SpeedPlus"
SpeedPlus.Parent = SpeedControls
SpeedPlus.Size = UDim2.new(0.2, 0, 1, 0)
SpeedPlus.Position = UDim2.new(0.8, 0, 0, 0)
SpeedPlus.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
SpeedPlus.Text = "+"
SpeedPlus.TextColor3 = Color3.white
SpeedPlus.Font = Enum.Font.GothamBold
SpeedPlus.TextSize = 20

-- Speed Presets
local SpeedPresets = Instance.new("Frame")
SpeedPresets.Name = "SpeedPresets"
SpeedPresets.Parent = SpeedSection
SpeedPresets.Size = UDim2.new(0.9, 0, 0.2, 0)
SpeedPresets.Position = UDim2.new(0.05, 0, 0.6, 0)
SpeedPresets.BackgroundTransparency = 1

local PresetButtons = {
    {"Normal", 16},
    {"Fast", 32},
    {"Very Fast", 50},
    {"Ultra", 75}
}

for i, preset in ipairs(PresetButtons) do
    local PresetBtn = Instance.new("TextButton")
    PresetBtn.Name = preset[1]
    PresetBtn.Parent = SpeedPresets
    PresetBtn.Size = UDim2.new(0.48, 0, 0.4, 0)
    PresetBtn.Position = UDim2.new((i-1)%2 * 0.5, 0, math.floor((i-1)/2) * 0.5, 0)
    PresetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    PresetBtn.Text = preset[1] .. " (" .. preset[2] .. ")"
    PresetBtn.TextColor3 = Color3.white
    PresetBtn.Font = Enum.Font.Gotham
    PresetBtn.TextSize = 14
end

-- ===== JUMP CONTROL SECTION =====
local JumpSection = Instance.new("Frame")
JumpSection.Name = "JumpSection"
JumpSection.Parent = ContentArea
JumpSection.Size = UDim2.new(1, 0, 1, 0)
JumpSection.BackgroundTransparency = 1
JumpSection.Visible = false

local JumpTitle = Instance.new("TextLabel")
JumpTitle.Name = "JumpTitle"
JumpTitle.Parent = JumpSection
JumpTitle.Size = UDim2.new(1, 0, 0.1, 0)
JumpTitle.BackgroundTransparency = 1
JumpTitle.Text = "⬆️ JUMP CONTROL"
JumpTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
JumpTitle.Font = Enum.Font.GothamBold
JumpTitle.TextSize = 20

-- Jump Display
local JumpDisplay = Instance.new("Frame")
JumpDisplay.Name = "JumpDisplay"
JumpDisplay.Parent = JumpSection
JumpDisplay.Size = UDim2.new(0.9, 0, 0.15, 0)
JumpDisplay.Position = UDim2.new(0.05, 0, 0.15, 0)
JumpDisplay.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Name = "JumpLabel"
JumpLabel.Parent = JumpDisplay
JumpLabel.Size = UDim2.new(0.6, 0, 1, 0)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "⬆️ ĐỘ CAO NHẢY:"
JumpLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
JumpLabel.Font = Enum.Font.GothamBold
JumpLabel.TextSize = 18

local JumpNumber = Instance.new("TextLabel")
JumpNumber.Name = "JumpNumber"
JumpNumber.Parent = JumpDisplay
JumpNumber.Size = UDim2.new(0.4, 0, 1, 0)
JumpNumber.Position = UDim2.new(0.6, 0, 0, 0)
JumpNumber.BackgroundTransparency = 1
JumpNumber.Text = "50"
JumpNumber.TextColor3 = Color3.fromRGB(0, 255, 150)
JumpNumber.Font = Enum.Font.GothamBold
JumpNumber.TextSize = 24

-- Jump Slider
local JumpSliderBg = Instance.new("TextButton")
JumpSliderBg.Name = "JumpSliderBg"
JumpSliderBg.Parent = JumpSection
JumpSliderBg.Size = UDim2.new(0.9, 0, 0.08, 0)
JumpSliderBg.Position = UDim2.new(0.05, 0, 0.35, 0)
JumpSliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
JumpSliderBg.Text = ""
JumpSliderBg.AutoButtonColor = false

local JumpSliderFill = Instance.new("Frame")
JumpSliderFill.Name = "JumpSliderFill"
JumpSliderFill.Parent = JumpSliderBg
JumpSliderFill.Size = UDim2.new(0.33, 0, 1, 0)
JumpSliderFill.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
JumpSliderFill.BorderSizePixel = 0

-- Jump Controls
local JumpControls = Instance.new("Frame")
JumpControls.Name = "JumpControls"
JumpControls.Parent = JumpSection
JumpControls.Size = UDim2.new(0.9, 0, 0.1, 0)
JumpControls.Position = UDim2.new(0.05, 0, 0.45, 0)
JumpControls.BackgroundTransparency = 1

local JumpMinus = Instance.new("TextButton")
JumpMinus.Name = "JumpMinus"
JumpMinus.Parent = JumpControls
JumpMinus.Size = UDim2.new(0.2, 0, 1, 0)
JumpMinus.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
JumpMinus.Text = "-"
JumpMinus.TextColor3 = Color3.white
JumpMinus.Font = Enum.Font.GothamBold
JumpMinus.TextSize = 20

local JumpPlus = Instance.new("TextButton")
JumpPlus.Name = "JumpPlus"
JumpPlus.Parent = JumpControls
JumpPlus.Size = UDim2.new(0.2, 0, 1, 0)
JumpPlus.Position = UDim2.new(0.8, 0, 0, 0)
JumpPlus.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
JumpPlus.Text = "+"
JumpPlus.TextColor3 = Color3.white
JumpPlus.Font = Enum.Font.GothamBold
JumpPlus.TextSize = 20

-- Jump Action Buttons
local JumpActions = Instance.new("Frame")
JumpActions.Name = "JumpActions"
JumpActions.Parent = JumpSection
JumpActions.Size = UDim2.new(0.9, 0, 0.25, 0)
JumpActions.Position = UDim2.new(0.05, 0, 0.6, 0)
JumpActions.BackgroundTransparency = 1

local NormalJumpBtn = Instance.new("TextButton")
NormalJumpBtn.Name = "NormalJumpBtn"
NormalJumpBtn.Parent = JumpActions
NormalJumpBtn.Size = UDim2.new(0.48, 0, 0.4, 0)
NormalJumpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
NormalJumpBtn.Text = "🚀 NHẢY"
NormalJumpBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
NormalJumpBtn.Font = Enum.Font.GothamBold
NormalJumpBtn.TextSize = 16

local SuperJumpBtn = Instance.new("TextButton")
SuperJumpBtn.Name = "SuperJumpBtn"
SuperJumpBtn.Parent = JumpActions
SuperJumpBtn.Size = UDim2.new(0.48, 0, 0.4, 0)
SuperJumpBtn.Position = UDim2.new(0.52, 0, 0, 0)
SuperJumpBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
SuperJumpBtn.Text = "🔥 SIÊU NHẢY"
SuperJumpBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
SuperJumpBtn.Font = Enum.Font.GothamBold
SuperJumpBtn.TextSize = 16

local AutoJumpBtn = Instance.new("TextButton")
AutoJumpBtn.Name = "AutoJumpBtn"
AutoJumpBtn.Parent = JumpActions
AutoJumpBtn.Size = UDim2.new(1, 0, 0.4, 0)
AutoJumpBtn.Position = UDim2.new(0, 0, 0.55, 0)
AutoJumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
AutoJumpBtn.Text = "🤖 AUTO JUMP: OFF"
AutoJumpBtn.TextColor3 = Color3.white
AutoJumpBtn.Font = Enum.Font.GothamMedium
AutoJumpBtn.TextSize = 14

-- ===== STATUS BAR =====
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Parent = MainContainer
StatusBar.Size = UDim2.new(1, 0, 0.04, 0)
StatusBar.Position = UDim2.new(0, 0, 0.96, 0)
StatusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)

local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Parent = StatusBar
StatusText.Size = UDim2.new(1, 0, 1, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "🟢 Ready | Speed: 16 | Jump: 50"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 12

-- ===== BO GÓC CHO TẤT CẢ =====
local allCorners = {}
for _, obj in pairs(BananaCatGUI:GetDescendants()) do
    if obj:IsA("Frame") or obj:IsA("TextButton") then
        if not obj:FindFirstChild("UICorner") then
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0.05, 0)
            corner.Parent = obj
            table.insert(allCorners, corner)
        end
    end
end

-- ===== BIẾN VÀ HÀM =====
local settings = {
    speed = 16,
    jump = 50,
    autoJump = false,
    farmingActive = false
}

local currentSection = "Farming"

-- Hàm cập nhật hiển thị
local function updateUI()
    -- Cập nhật tốc độ
    SpeedNumber.Text = tostring(settings.speed)
    SpeedSliderFill.Size = UDim2.new(settings.speed / 100, 0, 1, 0)
    
    -- Cập nhật nhảy cao
    JumpNumber.Text = tostring(settings.jump)
    JumpSliderFill.Size = UDim2.new(settings.jump / 150, 0, 1, 0)
    
    -- Áp dụng vào nhân vật
    humanoid.WalkSpeed = settings.speed
    humanoid.JumpPower = settings.jump
    
    -- Cập nhật trạng thái
    StatusText.Text = string.format("🟢 %s | Speed: %d | Jump: %d",
        currentSection,
        settings.speed,
        settings.jump
    )
    
    -- Cập nhật nút auto jump
    AutoJumpBtn.Text = settings.autoJump and "⏹️ AUTO JUMP: ON" or "🤖 AUTO JUMP: OFF"
    AutoJumpBtn.BackgroundColor3 = settings.autoJump and 
        Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 80)
    
    print("UPDATE - Speed:", settings.speed, "Jump:", settings.jump)
end

-- Hàm thay đổi giá trị
local function changeValue(type, amount)
    if type == "speed" then
        settings.speed = math.clamp(settings.speed + amount, 0, 100)
    elseif type == "jump" then
        settings.jump = math.clamp(settings.jump + amount, 0, 150)
    end
    updateUI()
end

-- Hàm nhảy
local lastJumpTime = 0
local function performJump(isSuper)
    local now = tick()
    if now - lastJumpTime < 0.3 then return end
    lastJumpTime = now
    
    if humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
        local force = settings.jump * (isSuper and 2.0 or 1.0)
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, force, 0)
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Parent = character.HumanoidRootPart
        
        game.Debris:AddItem(bv, 0.2)
        
        -- Hiệu ứng
        local btn = isSuper and SuperJumpBtn or NormalJumpBtn
        local original = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 100)
        StatusText.Text = isSuper and "🔥 SIÊU NHẢY!" or "🚀 ĐANG NHẢY..."
        
        task.wait(0.2)
        btn.BackgroundColor3 = original
        updateUI()
    end
end

-- Auto Jump
local autoJumpConnection
local function toggleAutoJump()
    settings.autoJump = not settings.autoJump
    
    if settings.autoJump then
        autoJumpConnection = RunService.Heartbeat:Connect(function()
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(0, settings.jump * 0.7, 0)
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                bv.Parent = character.HumanoidRootPart
                
                game.Debris:AddItem(bv, 0.15)
            end
        end)
    else
        if autoJumpConnection then
            autoJumpConnection:Disconnect()
            autoJumpConnection = nil
        end
    end
    
    updateUI()
end

-- Hàm kéo thanh trượt
local function setupSliderDrag(sliderBg, type)
    local dragging = false
    
    sliderBg.MouseButton1Down:Connect(function()
        dragging = true
        local mouse = player:GetMouse()
        local absoluteX = sliderBg.AbsolutePosition.X
        local absoluteWidth = sliderBg.AbsoluteSize.X
        
        local mouseX = math.clamp(mouse.X - absoluteX, 0, absoluteWidth)
        local percent = mouseX / absoluteWidth
        
        if type == "speed" then
            settings.speed = math.floor(percent * 100)
        elseif type == "jump" then
            settings.jump = math.floor(percent * 150)
        end
        
        updateUI()
    end)
    
    sliderBg.MouseButton1Click:Connect(function()
        local mouse = player:GetMouse()
        local absoluteX = sliderBg.AbsolutePosition.X
        local absoluteWidth = sliderBg.AbsoluteSize.X
        
        local mouseX = math.clamp(mouse.X - absoluteX, 0, absoluteWidth)
        local percent = mouseX / absoluteWidth
        
        if type == "speed" then
            settings.speed = math.floor(percent * 100)
        elseif type == "jump" then
            settings.jump = math.floor(percent * 150)
        end
        
        updateUI()
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = player:GetMouse()
            local absoluteX = sliderBg.AbsolutePosition.X
            local absoluteWidth = sliderBg.AbsoluteSize.X
            
            local mouseX = math.clamp(mouse.X - absoluteX, 0, absoluteWidth)
            local percent = mouseX / absoluteWidth
            
            if type == "speed" then
                settings.speed = math.floor(percent * 100)
            elseif type == "jump" then
                settings.jump = math.floor(percent * 150)
            end
            
            updateUI()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Hàm chuyển section
local function showSection(sectionName)
    FarmingSection.Visible = false
    SpeedSection.Visible = false
    JumpSection.Visible = false
    
    currentSection = sectionName
    
    if sectionName == "Farming" then
        FarmingSection.Visible = true
        StatusText.Text = "🌾 Farming Mode"
    elseif sectionName == "Speed Control" then
        SpeedSection.Visible = true
        StatusText.Text = "⚡ Speed Control"
    elseif sectionName == "Jump Control" then
        JumpSection.Visible = true
        StatusText.Text = "⬆️ Jump Control"
    elseif sectionName == "LocalPlayer" then
        StatusText.Text = "👤 Local Player"
    end
    
    updateUI()
end

-- Toggle function
local function setupToggle(toggleBtn)
    local isOn = false
    toggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            toggleBtn.Text = "OFF"
        end
    end)
end

-- ===== KẾT NỐI SỰ KIỆN =====
-- Menu buttons
for i, button in ipairs(MenuButtons) do
    button.MouseButton1Click:Connect(function()
        for _, btn in ipairs(MenuButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        end
        button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        button.TextColor3 = Color3.fromRGB(20, 20, 30)
        showSection(button.Text:match("[%w%s]+$") or button.Text)
    end)
end

-- Speed controls
SpeedMinus.MouseButton1Click:Connect(function() changeValue("speed", -5) end)
SpeedPlus.MouseButton1Click:Connect(function() changeValue("speed", 5) end)

-- Jump controls
JumpMinus.MouseButton1Click:Connect(function() changeValue("jump", -5) end)
JumpPlus.MouseButton1Click:Connect(function() changeValue("jump", 5) end)

-- Jump actions
NormalJumpBtn.MouseButton1Click:Connect(function() performJump(false) end)
SuperJumpBtn.MouseButton1Click:Connect(function() performJump(true) end)
AutoJumpBtn.MouseButton1Click:Connect(toggleAutoJump)

-- Start Farm button
StartFarmBtn.MouseButton1Click:Connect(function()
    StatusText.Text = "🚀 Starting Farm..."
    StartFarmBtn.Text = "⏳ PROCESSING..."
    StartFarmBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    
    task.wait(1.5)
    
    StartFarmBtn.Text = "✅ FARMING"
    StartFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    StatusText.Text = "🌾 Farming in progress..."
    
    task.wait(2)
    
    StartFarmBtn.Text = "🚀 Start Farm"
    StartFarmBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
end)

-- Speed presets
for _, btn in pairs(SpeedPresets:GetChildren()) do
    if btn:IsA("TextButton") then
        btn.MouseButton1Click:Connect(function()
            local speedValue = tonumber(btn.Text:match("%((%d+)%)")) or 16
            settings.speed = speedValue
            updateUI()
        end)
    end
end

-- Toggle UI button
ToggleBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = not MainContainer.Visible
    ToggleBtn.Text = MainContainer.Visible and "X" or "☰"
    ToggleBtn.BackgroundColor3 = MainContainer.Visible and 
        Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
end)

-- Setup all toggles
for _, toggle in pairs(FarmingSection:GetDescendants()) do
    if toggle.Name == "Toggle" then
        setupToggle(toggle)
    end
end

-- Setup slider drag
setupSliderDrag(SpeedSliderBg, "speed")
setupSliderDrag(JumpSliderBg, "jump")

-- Search box
SearchBox.Focused:Connect(function()
    if SearchBox.Text == "Search section or Func" then
        SearchBox.Text = ""
        SearchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    end
end)

SearchBox.FocusLost:Connect(function()
    if SearchBox.Text == "" then
        SearchBox.Text = "Search section or Func"
        SearchBox.TextColor3 = Color3.fromRGB(180, 180, 200)
    else
        StatusText.Text = "🔍 Searching: " .. SearchBox.Text
    end
end)

-- ===== PHÍM TẮT =====
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainContainer.Visible = not MainContainer.Visible
        ToggleBtn.Text = MainContainer.Visible and "X" or "☰"
    
    elseif input.KeyCode == Enum.KeyCode.F then
        showSection("Farming")
    
    elseif input.KeyCode == Enum.KeyCode.S then
        showSection("Speed Control")
    
    elseif input.KeyCode == Enum.KeyCode.J then
        showSection("Jump Control")
        performJump(true)
    
    elseif input.KeyCode == Enum.KeyCode.Space then
        performJump(false)
    
    elseif input.KeyCode == Enum.KeyCode.U then
        toggleAutoJump()
    
    elseif input.KeyCode == Enum.KeyCode.R then
        settings.speed = 16
        settings.jump = 50
        updateUI()
        StatusText.Text = "🔄 Đã reset về mặc định"
    end
end)

-- ===== KHỞI ĐỘNG =====
MenuButtons[1].BackgroundColor3 = Color3.fromRGB(255, 200, 0)
MenuButtons[1].TextColor3 = Color3.fromRGB(20, 20, 30)
showSection("Farming")
updateUI()

-- Respawn handler
character.Died:Connect(function()
    task.wait(3)
    if character and character.Parent then
        humanoid = character:WaitForChild("Humanoid")
        updateUI()
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    task.wait(1)
    updateUI()
end)

print("=" .. string.rep("=", 60))
print("🍌 BANANA CAT HUB - COMPLETE LOCAL SCRIPT")
print("✅ Đã tải thành công!")
print("")
print("🎮 SECTIONS:")
print("   • 🏆 Farming - Toggle farming options")
print("   • ⚡ Speed Control - Điều chỉnh tốc độ chạy")
print("   • ⬆️ Jump Control - Điều chỉnh nhảy cao")
print("   • 👤 LocalPlayer - Player settings")
print("")
print("🎯 TÍNH NĂNG CHÍNH:")
print("   • Thanh trượt kéo chuột cho Speed/Jump")
print("   • Nút +/- điều chỉnh nhanh")
print("   • Nhảy thường & Siêu nhảy")
print("   • Auto Jump tự động")
print("   • Start Farm với hiệu ứng")
print("   • Search box tìm kiếm")
print("")
print("⌨️ PHÍM TẮT:")
print("   RightShift: Ẩn/hiện UI")
print("   F: Chuyển đến Farming")
print("   S: Chuyển đến Speed Control")
print("   J: Chuyển đến Jump + Siêu nhảy")
print("   Space: Nhảy thường")
print("   U: Bật/tắt Auto Jump")
print("   R: Reset về mặc định")
print("=" .. string.rep("=", 60))
