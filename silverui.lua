-- Silver UI Pro
-- Advanced Roblox UI Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local SilverUI = {}
SilverUI.__index = SilverUI

-- Create Main Window
function SilverUI:Create(config)
    local Title = config.Title or "Silver UI Pro"

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SilverUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui

    -- Background Blur for Loading
    local Blur = Instance.new("BlurEffect", game.Lighting)
    Blur.Size = 0
    TweenService:Create(Blur, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 20}):Play()

    -- Loading Screen
    local LoadingFrame = Instance.new("Frame", ScreenGui)
    LoadingFrame.Size = UDim2.new(1,0,1,0)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)

    local LoadingLabel = Instance.new("TextLabel", LoadingFrame)
    LoadingLabel.AnchorPoint = Vector2.new(0.5,0.5)
    LoadingLabel.Position = UDim2.new(0.5,0,0.5,0)
    LoadingLabel.Text = "Loading Silver UI..."
    LoadingLabel.Font = Enum.Font.GothamBold
    LoadingLabel.TextSize = 22
    LoadingLabel.TextColor3 = Color3.fromRGB(200,200,200)
    LoadingLabel.BackgroundTransparency = 1
    LoadingLabel.Size = UDim2.new(0,300,0,50)

    wait(2)
    LoadingFrame:Destroy()
    Blur:Destroy()

    -- Main Frame
    local Window = Instance.new("Frame", ScreenGui)
    Window.Name = "Window"
    Window.Size = UDim2.new(0,600,0,400)
    Window.Position = UDim2.new(0.5,-300,0.5,-200)
    Window.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Window.BorderSizePixel = 0
    Window.AnchorPoint = Vector2.new(0.5,0.5)
    Window.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", Window)
    UICorner.CornerRadius = UDim.new(0,10)

    -- Titlebar
    local TitleBar = Instance.new("Frame", Window)
    TitleBar.Size = UDim2.new(1,0,0,40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
    TitleBar.BorderSizePixel = 0

    local TitleText = Instance.new("TextLabel", TitleBar)
    TitleText.Text = Title
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    TitleText.TextColor3 = Color3.fromRGB(220,220,220)
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0,10,0,0)
    TitleText.Size = UDim2.new(0.5,0,1,0)
    TitleText.TextXAlignment = Enum.TextXAlignment.Left

    -- Close/Minimize
    local Close = Instance.new("TextButton", TitleBar)
    Close.Text = "✕"
    Close.Size = UDim2.new(0,40,1,0)
    Close.Position = UDim2.new(1,-40,0,0)
    Close.BackgroundTransparency = 1
    Close.TextColor3 = Color3.fromRGB(220,220,220)

    local Minimize = Instance.new("TextButton", TitleBar)
    Minimize.Text = "–"
    Minimize.Size = UDim2.new(0,40,1,0)
    Minimize.Position = UDim2.new(1,-80,0,0)
    Minimize.BackgroundTransparency = 1
    Minimize.TextColor3 = Color3.fromRGB(220,220,220)

    -- Drag Support
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tab Holder
    local TabHolder = Instance.new("Frame", Window)
    TabHolder.Size = UDim2.new(0,150,1,-40)
    TabHolder.Position = UDim2.new(0,0,0,40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local TabLayout = Instance.new("UIListLayout", TabHolder)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0,4)

    -- Content Frame
    local ContentFrame = Instance.new("Frame", Window)
    ContentFrame.Size = UDim2.new(1,-160,1,-40)
    ContentFrame.Position = UDim2.new(0,160,0,40)
    ContentFrame.BackgroundTransparency = 1

    -- Keybind Toggle (RightShift)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
            Window.Visible = not Window.Visible
        end
    end)

    -- Mobile Button
    local MobileBtn = Instance.new("TextButton", ScreenGui)
    MobileBtn.Text = "Show Silver"
    MobileBtn.Size = UDim2.new(0,120,0,40)
    MobileBtn.Position = UDim2.new(0,10,1,-50)
    MobileBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    MobileBtn.TextColor3 = Color3.fromRGB(220,220,220)
    local BtnCorner = Instance.new("UICorner", MobileBtn)
    BtnCorner.CornerRadius = UDim.new(0,8)

    MobileBtn.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
    end)

    -- Close / Minimize Animations
    Close.MouseButton1Click:Connect(function()
        TweenService:Create(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,0,0,0)}):Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)

    Minimize.MouseButton1Click:Connect(function()
        Window.Visible = false
    end)

    -- AddTab
    function SilverUI:AddTab(tabConfig)
        local TabBtn = Instance.new("TextButton", TabHolder)
        TabBtn.Text = tabConfig.Title or "Tab"
        TabBtn.Size = UDim2.new(1,-10,0,35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        TabBtn.TextColor3 = Color3.fromRGB(200,200,200)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 14

        local TabContent = Instance.new("ScrollingFrame", ContentFrame)
        TabContent.Visible = false
        TabContent.Size = UDim2.new(1,0,1,0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 4
        local Layout = Instance.new("UIListLayout", TabContent)
        Layout.Padding = UDim.new(0,6)

        TabBtn.MouseButton1Click:Connect(function()
            for _,frame in pairs(ContentFrame:GetChildren()) do
                if frame:IsA("ScrollingFrame") then
                    frame.Visible = false
                end
            end
            TabContent.Visible = true
        end)

        return TabContent
    end

    return SilverUI
end

return SilverUI
