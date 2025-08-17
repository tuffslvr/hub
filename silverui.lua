-- Silver UI Library
-- Clean, Smooth, Mobile + PC Supported

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local SilverUI = {}
SilverUI.Theme = {
    Background = Color3.fromRGB(20,20,20),
    Accent = Color3.fromRGB(100,150,255),
    TextColor = Color3.fromRGB(240,240,240),
    Transparency = 0.05
}

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilverUI"
ScreenGui.Parent = game:GetService("CoreGui")

-- Toggle Button (mobile)
local ShowBtn = Instance.new("TextButton")
ShowBtn.Size = UDim2.new(0,120,0,40)
ShowBtn.Position = UDim2.new(0,10,0,10)
ShowBtn.Text = "Show Silver"
ShowBtn.BackgroundColor3 = SilverUI.Theme.Accent
ShowBtn.TextColor3 = SilverUI.Theme.TextColor
ShowBtn.Visible = false
ShowBtn.Parent = ScreenGui

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,600,0,400)
MainFrame.Position = UDim2.new(0.5,-300,0.5,-200)
MainFrame.BackgroundColor3 = SilverUI.Theme.Background
MainFrame.BackgroundTransparency = SilverUI.Theme.Transparency
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0,10)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,40)
TopBar.BackgroundColor3 = SilverUI.Theme.Accent
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-80,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.Text = "Silver UI"
Title.BackgroundTransparency = 1
Title.TextColor3 = SilverUI.Theme.TextColor
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = TopBar

-- Close / Minimize
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,40,0,40)
Close.Position = UDim2.new(1,-40,0,0)
Close.Text = "X"
Close.TextColor3 = SilverUI.Theme.TextColor
Close.BackgroundTransparency = 1
Close.Parent = TopBar

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0,40,0,40)
Minimize.Position = UDim2.new(1,-80,0,0)
Minimize.Text = "-"
Minimize.TextColor3 = SilverUI.Theme.TextColor
Minimize.BackgroundTransparency = 1
Minimize.Parent = TopBar

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,150,1,-40)
Sidebar.Position = UDim2.new(0,0,0,40)
Sidebar.BackgroundColor3 = Color3.fromRGB(30,30,30)
Sidebar.Parent = MainFrame

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1,-150,1,-40)
TabContainer.Position = UDim2.new(0,150,0,40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local Tabs = {}

function SilverUI:CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1,0,0,40)
    TabBtn.Text = name
    TabBtn.BackgroundTransparency = 1
    TabBtn.TextColor3 = SilverUI.Theme.TextColor
    TabBtn.Parent = Sidebar

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1,0,1,0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.new(0,0,0,0)
    TabFrame.ScrollBarThickness = 4
    TabFrame.Visible = false
    TabFrame.Parent = TabContainer

    Tabs[name] = TabFrame

    TabBtn.MouseButton1Click:Connect(function()
        for _,f in pairs(TabContainer:GetChildren()) do
            if f:IsA("ScrollingFrame") then f.Visible = false end
        end
        TabFrame.Visible = true
    end)

    return TabFrame
end

-- Elements
function SilverUI:CreateButton(tab, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0,400,0,40)
    Btn.Text = text
    Btn.BackgroundColor3 = SilverUI.Theme.Accent
    Btn.TextColor3 = SilverUI.Theme.TextColor
    Btn.Parent = tab

    Btn.MouseButton1Click:Connect(callback)
end

function SilverUI:CreateToggle(tab, text, callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0,400,0,40)
    Toggle.Text = text.." [OFF]"
    Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Toggle.TextColor3 = SilverUI.Theme.TextColor
    Toggle.Parent = tab

    local state = false
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = text.." ["..(state and "ON" or "OFF").."]"
        callback(state)
    end)
end

-- More element functions (Slider, Dropdown, TextBox, ColorPicker, etc.) buraya eklenebilir...

-- Close / Minimize Logic
Close.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ShowBtn.Visible = true
end)

Minimize.MouseButton1Click:Connect(function()
    local size = MainFrame.Size
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0,600,0,40)}):Play()
end)

-- ShowBtn Logic
ShowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ShowBtn.Visible = false
end)

-- Keybind (RightShift)
UserInputService.InputBegan:Connect(function(input,gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

return SilverUI
