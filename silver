local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Güvenli parent seçici
local function getSafeParent()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local g = Instance.new("ScreenGui")
        syn.protect_gui(g)
        g.Parent = game:GetService("CoreGui")
        return g
    elseif game:GetService("CoreGui") then
        return game:GetService("CoreGui")
    elseif LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        return LocalPlayer.PlayerGui
    else
        return game:GetService("CoreGui")
    end
end

local Silver = {}
Silver.__index = Silver

-- Bildirim
function Silver:Notify(title, text, duration)
    duration = duration or 3
    local msg = Instance.new("Hint")
    msg.Parent = getSafeParent()
    msg.Text = title .. " | " .. text
    game:GetService("Debris"):AddItem(msg, duration)
end

-- Pencere oluşturma
function Silver:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Window"
    local Size = config.Size or UDim2.new(0, 500, 0, 350)

    local gui = Instance.new("ScreenGui")
    gui.Name = "BetterUI"
    gui.ResetOnSpawn = false
    gui.Parent = getSafeParent()

    local main = Instance.new("Frame", gui)
    main.Size = Size
    main.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    main.Active = true
    main.Draggable = true

    local topbar = Instance.new("TextLabel", main)
    topbar.Size = UDim2.new(1, 0, 0, 30)
    topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    topbar.Text = Title
    topbar.TextColor3 = Color3.new(1,1,1)
    topbar.Font = Enum.Font.SourceSansBold
    topbar.TextSize = 18

    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, 0, 1, -30)
    container.Position = UDim2.new(0, 0, 0, 30)
    container.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0, 6)
    layout.FillDirection = Enum.FillDirection.Vertical

    local WindowAPI = {}

    function WindowAPI:AddLabel(text)
        local lbl = Instance.new("TextLabel", container)
        lbl.Size = UDim2.new(1, -10, 0, 25)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.TextSize = 16
        lbl.Font = Enum.Font.SourceSans
        return lbl
    end

    function WindowAPI:AddButton(opt)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Text = opt.Title or "Button"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.MouseButton1Click:Connect(function()
            if opt.Callback then opt.Callback() end
        end)
        return btn
    end

    function WindowAPI:AddToggle(opt)
        local state = opt.Default or false
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Text = (state and "[ON] " or "[OFF] ") .. (opt.Title or "Toggle")
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = (state and "[ON] " or "[OFF] ") .. (opt.Title or "Toggle")
            if opt.Callback then opt.Callback(state) end
        end)
        return btn
    end

    function WindowAPI:AddSlider(opt)
        local val = opt.Default or opt.Min or 0
        local slider = Instance.new("TextButton", container)
        slider.Size = UDim2.new(1, -10, 0, 30)
        slider.Text = (opt.Title or "Slider") .. ": " .. val
        slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
        slider.TextColor3 = Color3.new(1,1,1)

        slider.MouseButton1Click:Connect(function()
            val = val + 1
            if val > opt.Max then val = opt.Min end
            slider.Text = (opt.Title or "Slider") .. ": " .. val
            if opt.Callback then opt.Callback(val) end
        end)
        return slider
    end

    function WindowAPI:AddTextbox(opt)
        local box = Instance.new("TextBox", container)
        box.Size = UDim2.new(1, -10, 0, 30)
        box.PlaceholderText = opt.Placeholder or "Yaz..."
        box.Text = ""
        box.TextColor3 = Color3.new(1,1,1)
        box.BackgroundColor3 = Color3.fromRGB(50,50,50)
        box.FocusLost:Connect(function(enter)
            if enter and opt.Callback then opt.Callback(box.Text) end
        end)
        return box
    end

    function WindowAPI:AddDropdown(opt)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Text = "[Dropdown] " .. (opt.Default or "")
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.MouseButton1Click:Connect(function()
            if opt.Callback then opt.Callback(opt.Default) end
        end)
        return btn
    end

    function WindowAPI:AddColorPicker(opt)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Text = "[ColorPicker]"
        btn.BackgroundColor3 = opt.Default or Color3.fromRGB(255,255,255)
        btn.MouseButton1Click:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            if opt.Callback then opt.Callback(btn.BackgroundColor3) end
        end)
        return btn
    end

    function WindowAPI:AddDivider()
        local line = Instance.new("Frame", container)
        line.Size = UDim2.new(1, -10, 0, 2)
        line.BackgroundColor3 = Color3.fromRGB(80,80,80)
        return line
    end

    function WindowAPI:Notify(title, text, dur)
        Silver:Notify(title, text, dur)
    end

    return WindowAPI
end

return Silver
