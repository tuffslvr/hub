--// SilverUI Advanced Library
--// by tuffslvr

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local SilverUI = {}
SilverUI.__index = SilverUI

-- Main window storage
SilverUI.Windows = {}
SilverUI.MobileButton = nil
SilverUI.UIVisible = true
SilverUI.ToggleKey = Enum.KeyCode.RightShift -- default keybind

-- Drag function
local function MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, startPos, startInput

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = frame.Position
            startInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startInput.Position
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Toggle visibility
local function SetVisible(state)
    SilverUI.UIVisible = state
    for _, win in pairs(SilverUI.Windows) do
        win.Frame.Visible = state
    end
    if SilverUI.MobileButton then
        SilverUI.MobileButton.Visible = not state
    end
end

-- Listen for PC keybind
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == SilverUI.ToggleKey then
        SetVisible(not SilverUI.UIVisible)
    end
end)

-- Create floating mobile button
local function CreateMobileButton()
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0,120,0,40)
    button.Position = UDim2.new(0.5,-60,0.9,0)
    button.Text = "Show Silver"
    button.BackgroundColor3 = Color3.fromRGB(50,50,50)
    button.TextColor3 = Color3.new(1,1,1)
    button.BorderSizePixel = 0
    button.Visible = false
    button.Active = true
    button.Draggable = true
    button.Parent = game:GetService("CoreGui")

    button.MouseButton1Click:Connect(function()
        SetVisible(true)
    end)

    SilverUI.MobileButton = button
end
CreateMobileButton()

-- Create Window
function SilverUI:CreateWindow(opts)
    opts = opts or {}
    local name = opts.Name or "SilverUI Window"

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.Parent = game:GetService("CoreGui")

    -- Main frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,500,0,300)
    main.Position = UDim2.new(0.5,-250,0.5,-150)
    main.BackgroundColor3 = Color3.fromRGB(30,30,30)
    main.BorderSizePixel = 0
    main.Visible = true
    main.Parent = gui

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1,0,0,30)
    topbar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    topbar.BorderSizePixel = 0
    topbar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-60,1,0)
    title.Position = UDim2.new(0,5,0,0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar

    -- Close & Minimize
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,30,1,0)
    close.Position = UDim2.new(1,-30,0,0)
    close.BackgroundTransparency = 1
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255,80,80)
    close.Parent = topbar

    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.new(0,30,1,0)
    minimize.Position = UDim2.new(1,-60,0,0)
    minimize.BackgroundTransparency = 1
    minimize.Text = "-"
    minimize.TextColor3 = Color3.new(1,1,1)
    minimize.Parent = topbar

    -- Tabs frame
    local tabs = Instance.new("Frame")
    tabs.Size = UDim2.new(0,120,1,-30)
    tabs.Position = UDim2.new(0,0,0,30)
    tabs.BackgroundColor3 = Color3.fromRGB(25,25,25)
    tabs.BorderSizePixel = 0
    tabs.Parent = main

    -- Content frame
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-120,1,-30)
    content.Position = UDim2.new(0,120,0,30)
    content.BackgroundColor3 = Color3.fromRGB(35,35,35)
    content.BorderSizePixel = 0
    content.Parent = main

    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0,5)
    uiList.FillDirection = Enum.FillDirection.Vertical
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Parent = content

    -- tab storage
    local winObj = {
        Frame = main,
        Tabs = {},
        Content = content,
        TabHolder = tabs,
    }
    setmetatable(winObj, SilverUI)

    -- Functions
    close.MouseButton1Click:Connect(function()
        SetVisible(false)
    end)

    local minimized = false
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        tabs.Visible = not minimized
    end)

    MakeDraggable(main, topbar)

    table.insert(SilverUI.Windows, winObj)
    return winObj
end

-- Create Tab
function SilverUI:CreateTab(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,30)
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(30,30,30)
    button.TextColor3 = Color3.new(1,1,1)
    button.BorderSizePixel = 0
    button.Parent = self.TabHolder

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1,0,1,0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = self.Content

    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0,5)
    uiList.FillDirection = Enum.FillDirection.Vertical
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Parent = tabContent

    self.Tabs[name] = tabContent

    button.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Visible = false
        end
        tabContent.Visible = true
    end)

    return tabContent
end

-- UI Elements
function SilverUI:CreateButton(opts)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,30)
    btn.Text = opts.Text or "Button"
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BorderSizePixel = 0
    btn.Parent = opts.Tab

    btn.MouseButton1Click:Connect(function()
        if opts.Callback then
            opts.Callback()
        end
    end)
end

function SilverUI:CreateToggle(opts)
    local state = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,30)
    btn.Text = "[ ] " .. (opts.Text or "Toggle")
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BorderSizePixel = 0
    btn.Parent = opts.Tab

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "[✓] " or "[ ] ") .. (opts.Text or "Toggle")
        if opts.Callback then
            opts.Callback(state)
        end
    end)
end

return SilverUI
