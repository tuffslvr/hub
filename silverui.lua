-- SilverUI Library
-- Mobil + PC uyumlu, dark tema

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local SilverUI = {}
SilverUI.__index = SilverUI

-- UI Screen
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilverUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Window
function SilverUI:CreateWindow(config)
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = UDim2.new(0, 450, 0, 300)
    Window.Position = UDim2.new(0.5, -225, 0.5, -150)
    Window.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.Draggable = true
    Window.Parent = ScreenGui

    -- UICorner
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 10)

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 30)
    Topbar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Window
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Text = config.Name or "SilverUI"
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.Text = "X"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = Topbar
    CloseBtn.MouseButton1Click:Connect(function()
        Window.Visible = false
    end)

    -- Minimize
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0, 0)
    MinBtn.Text = "-"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Parent = Topbar
    MinBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(Window:GetChildren()) do
            if child ~= Topbar then
                child.Visible = not child.Visible
            end
        end
        Window.Size = UDim2.new(Window.Size.X.Scale, Window.Size.X.Offset, 0, MinBtn.Text == "-" and 300 or 30)
        MinBtn.Text = (MinBtn.Text == "-" and "+" or "-")
    end)

    -- Tab Holder (sol)
    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(0, 100, 1, -30)
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabHolder.BorderSizePixel = 0
    TabHolder.Parent = Window

    -- Content Holder
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -100, 1, -30)
    ContentHolder.Position = UDim2.new(0, 100, 0, 30)
    ContentHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentHolder.BorderSizePixel = 0
    ContentHolder.Parent = Window

    -- Tabs + Pages
    local Tabs = {}
    function SilverUI:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.TextSize = 14
        TabBtn.Parent = TabHolder

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Visible = false
        Page.Parent = ContentHolder

        local UIList = Instance.new("UIListLayout", Page)
        UIList.Padding = UDim.new(0, 5)

        TabBtn.MouseButton1Click:Connect(function()
            for _, tab in pairs(ContentHolder:GetChildren()) do
                if tab:IsA("ScrollingFrame") then
                    tab.Visible = false
                end
            end
            Page.Visible = true
        end)

        if #Tabs == 0 then
            Page.Visible = true
        end

        table.insert(Tabs, {Button = TabBtn, Page = Page})
        return Page
    end

    -- Elements
    function SilverUI:CreateButton(cfg, parent)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 30)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Btn.Text = cfg.Text or "Button"
        Btn.Font = Enum.Font.Gotham
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 14
        Btn.Parent = parent
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)

        Btn.MouseButton1Click:Connect(function()
            if cfg.Callback then cfg.Callback() end
        end)
    end

    function SilverUI:CreateToggle(cfg, parent)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -10, 0, 30)
        Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Frame.Parent = parent
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

        local Label = Instance.new("TextLabel")
        Label.Text = cfg.Text or "Toggle"
        Label.Size = UDim2.new(1, -40, 1, 0)
        Label.Font = Enum.Font.Gotham
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 30, 0, 30)
        Btn.Position = UDim2.new(1, -35, 0, 0)
        Btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        Btn.Text = ""
        Btn.Parent = Frame
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)

        local State = false
        Btn.MouseButton1Click:Connect(function()
            State = not State
            Btn.BackgroundColor3 = State and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(70, 70, 70)
            if cfg.Callback then cfg.Callback(State) end
        end)
    end

    function SilverUI:CreateSlider(cfg, parent)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -10, 0, 40)
        Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Frame.Parent = parent
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

        local Label = Instance.new("TextLabel")
        Label.Text = cfg.Text or "Slider"
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Font = Enum.Font.Gotham
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, -10, 0, 15)
        Bar.Position = UDim2.new(0, 5, 0, 20)
        Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Bar.Parent = Frame
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 5)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0.5, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        Fill.Parent = Bar
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 5)

        local dragging = false
        local min, max = cfg.Min or 0, cfg.Max or 100

        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                local val = math.floor(min + pos * (max - min))
                if cfg.Callback then cfg.Callback(val) end
            end
        end)
    end

    return self
end

return SilverUI
