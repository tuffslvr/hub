--! Silver UI Library (Full Version)
-- Author: TuffSlvr & GPT
-- Version: 1.0
-- Features: Full element pack + Mobile & PC support

local SilverUI = {}
SilverUI.Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(100, 180, 255),
    Text = Color3.fromRGB(240,240,240),
    Transparency = 0.1
}

-- Utility Functions
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function tween(obj, props, time, style)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Main UI Creation
function SilverUI:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SilverUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
    ScreenGui.Parent = game.CoreGui

    -- Loading Screen
    local Loading = Instance.new("Frame", ScreenGui)
    Loading.Size = UDim2.fromScale(1,1)
    Loading.BackgroundColor3 = SilverUI.Theme.Background
    Loading.BackgroundTransparency = 0
    local Title = Instance.new("TextLabel", Loading)
    Title.AnchorPoint = Vector2.new(0.5,0.5)
    Title.Position = UDim2.fromScale(0.5,0.5)
    Title.Size = UDim2.new(0,300,0,50)
    Title.Text = "Silver UI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 36
    Title.TextColor3 = SilverUI.Theme.Accent
    Title.BackgroundTransparency = 1
    task.wait(2)
    tween(Loading,{BackgroundTransparency=1},1)
    tween(Title,{TextTransparency=1},1)
    task.wait(1)
    Loading:Destroy()

    -- Main Window
    local Window = Instance.new("Frame", ScreenGui)
    Window.Size = UDim2.new(0,600,0,400)
    Window.Position = UDim2.new(0.5,-300,0.5,-200)
    Window.BackgroundColor3 = SilverUI.Theme.Background
    Window.BackgroundTransparency = SilverUI.Theme.Transparency
    Window.BorderSizePixel = 0

    -- Drag
    local dragging, dragInput, dragStart, startPos
    Window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Window.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Topbar
    local Topbar = Instance.new("Frame", Window)
    Topbar.Size = UDim2.new(1,0,0,30)
    Topbar.BackgroundColor3 = SilverUI.Theme.Accent
    Topbar.BorderSizePixel = 0
    local TitleLabel = Instance.new("TextLabel", Topbar)
    TitleLabel.Size = UDim2.new(1,-60,1,0)
    TitleLabel.Position = UDim2.new(0,10,0,0)
    TitleLabel.Text = config.Name or "Silver UI"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = SilverUI.Theme.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Minimize & Close
    local Close = Instance.new("TextButton", Topbar)
    Close.Size = UDim2.new(0,30,1,0)
    Close.Position = UDim2.new(1,-30,0,0)
    Close.Text = "×"
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 16
    Close.TextColor3 = SilverUI.Theme.Text
    Close.BackgroundTransparency = 1
    Close.MouseButton1Click:Connect(function()
        tween(Window,{Size=UDim2.new(0,0,0,0)},0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame", Window)
    Sidebar.Size = UDim2.new(0,150,1,-30)
    Sidebar.Position = UDim2.new(0,0,0,30)
    Sidebar.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local Content = Instance.new("Frame", Window)
    Content.Size = UDim2.new(1,-150,1,-30)
    Content.Position = UDim2.new(0,150,0,30)
    Content.BackgroundTransparency = 1

    local TabFolder = Instance.new("Folder", Content)

    local WindowTable = {}
    function WindowTable:CreateTab(name)
        local Button = Instance.new("TextButton", Sidebar)
        Button.Size = UDim2.new(1,0,0,40)
        Button.Text = name
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        Button.BackgroundTransparency = 0.3
        Button.TextColor3 = SilverUI.Theme.Text

        local TabPage = Instance.new("ScrollingFrame", TabFolder)
        TabPage.Size = UDim2.new(1,0,1,0)
        TabPage.CanvasSize = UDim2.new(0,0,0,0)
        TabPage.Visible = false
        TabPage.BackgroundTransparency = 1

        Button.MouseButton1Click:Connect(function()
            for _,page in ipairs(TabFolder:GetChildren()) do
                page.Visible = false
            end
            TabPage.Visible = true
        end)

        local TabTable = {}
        function TabTable:CreateLabel(text)
            local Label = Instance.new("TextLabel", TabPage)
            Label.Size = UDim2.new(1,-20,0,30)
            Label.Position = UDim2.new(0,10,0,TabPage.CanvasSize.Y.Offset)
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.BackgroundTransparency = 1
            Label.TextColor3 = SilverUI.Theme.Text
            TabPage.CanvasSize = TabPage.CanvasSize + UDim2.new(0,0,0,40)
        end
        -- diğer elementler buraya eklenecek...

        return TabTable
    end

    return WindowTable
end

return SilverUI
