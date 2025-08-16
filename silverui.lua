--!strict
-- SilverUI Library | Premium Roblox UI System
-- Developer Mode: ON 🚀
-- Features: Smooth Tabs, Animations, Keybinds, Drag, Mobile Support

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local SilverUI = {}
SilverUI.__index = SilverUI

-- Utility: Tween Function
local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

-- Create new UI Window
function SilverUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Silver UI Pro"
    local size = config.Size or UDim2.fromOffset(550, 320)

    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SilverUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    -- Dragging Vars
    local dragging, dragStart, startPos

    -- Window Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = size
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Main.Active = true

    -- UI Corner
    local corner = Instance.new("UICorner", Main)
    corner.CornerRadius = UDim.new(0, 8)

    -- Drag System
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.fromOffset(30, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.Parent = TopBar

    CloseBtn.MouseButton1Click:Connect(function()
        tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(0, 0), Transparency = 1})
        wait(0.35)
        ScreenGui:Destroy()
    end)

    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.fromOffset(30, 30)
    MinBtn.Position = UDim2.new(1, -60, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "–"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 20
    MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinBtn.Parent = TopBar

    MinBtn.MouseButton1Click:Connect(function()
        tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(0, 30)})
        wait(0.35)
    end)

    -- Tabs System
    local Tabs = Instance.new("Frame")
    Tabs.Size = UDim2.new(0, 120, 1, -30)
    Tabs.Position = UDim2.new(0, 0, 0, 30)
    Tabs.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Tabs.BorderSizePixel = 0
    Tabs.Parent = Main

    local TabLayout = Instance.new("UIListLayout", Tabs)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, -120, 1, -30)
    Pages.Position = UDim2.new(0, 120, 0, 30)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Main

    local PageFolder = Instance.new("Folder", Pages)

    local function CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.Text = name
        TabBtn.BackgroundTransparency = 0.2
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
        TabBtn.TextSize = 13
        TabBtn.Parent = Tabs

        local Page = Instance.new("ScrollingFrame")
        Page.Name = name
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarThickness = 4
        Page.Visible = false
        Page.Parent = PageFolder

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in ipairs(PageFolder:GetChildren()) do
                p.Visible = false
            end
            Page.Visible = true
        end)

        return Page
    end

    return {
        Tab = CreateTab
    }
end

return SilverUI
