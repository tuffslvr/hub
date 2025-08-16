local SilverUI = {}

-- 🔹 Ana Window Oluştur
function SilverUI:CreateWindow(config)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name or "SilverUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.Parent = screenGui

    local tabHolder = Instance.new("Frame")
    tabHolder.Size = UDim2.new(0, 120, 1, 0)
    tabHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tabHolder.Parent = mainFrame

    local pageHolder = Instance.new("Frame")
    pageHolder.Size = UDim2.new(1, -120, 1, 0)
    pageHolder.Position = UDim2.new(0, 120, 0, 0)
    pageHolder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    pageHolder.Parent = mainFrame

    local pages = {}

    function SilverUI:CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Text = name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.Parent = tabHolder

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.Parent = pageHolder

        local layout = Instance.new("UIListLayout")
        layout.Parent = page
        layout.Padding = UDim.new(0, 5)

        btn.Activated:Connect(function()
            for _, p in pairs(pages) do
                p.Visible = false
            end
            page.Visible = true
        end)

        table.insert(pages, page)

        if #pages == 1 then
            page.Visible = true
        end

        return page
    end

    return mainFrame
end

-- 🔹 Button
function SilverUI:CreateButton(config, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Text = config.Text or "Button"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Parent = parent

    btn.Activated:Connect(function()
        if config.Callback then
            config.Callback()
        end
    end)

    return btn
end

-- 🔹 Toggle
function SilverUI:CreateToggle(config, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Toggle"
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 1, 0)
    btn.Position = UDim2.new(0.7, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = frame

    local state = false

    btn.Activated:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
        btn.Text = state and "ON" or "OFF"
        if config.Callback then
            config.Callback(state)
        end
    end)

    return frame
end

-- 🔹 Slider (Mouse + Touch destekli)
function SilverUI:CreateSlider(config, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.4, 0)
    label.Text = config.Text or "Slider"
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -10, 0, 10)
    bar.Position = UDim2.new(0, 5, 0.7, -5)
    bar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,200,200)
    fill.Parent = bar

    local dragging = false
    local UserInputService = game:GetService("UserInputService")

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            local value = math.floor((config.Min or 0) + pos * ((config.Max or 100) - (config.Min or 0)))
            if config.Callback then
                config.Callback(value)
            end
        end
    end)

    return frame
end

return SilverUI
