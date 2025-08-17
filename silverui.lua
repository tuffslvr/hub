--// Pepsi UI Library //--
local PepsiUI = {}
PepsiUI.__index = PepsiUI

-- Window
function PepsiUI:CreateWindow(Config)
    Config = Config or {}
    local Title = Config.Title or "Pepsi UI"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Kırmızı ince border
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleBar.BorderSizePixel = 0
    TitleBar.Text = Title .. " | General Board Mods ⚙"
    TitleBar.TextColor3 = Color3.fromRGB(255, 50, 50)
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.TextSize = 14
    TitleBar.Parent = Main

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    return setmetatable({
        Main = Main,
        Container = Container
    }, PepsiUI)
end

-- Checkbox
function PepsiUI:CreateCheckbox(Config)
    Config = Config or {}
    local Text = Config.Text or "Checkbox"
    local Callback = Config.Callback or function() end
    local State = false

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 25)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.Text = "[ ] " .. Text
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 12
    Button.Parent = self.Container

    Button.MouseButton1Click:Connect(function()
        State = not State
        Button.Text = State and "[✔] " .. Text or "[ ] " .. Text
        pcall(Callback, State)
    end)
end

-- Slider
function PepsiUI:CreateSlider(Config)
    Config = Config or {}
    local Text = Config.Text or "Slider"
    local Min = Config.Min or 0
    local Max = Config.Max or 100
    local Default = Config.Default or 50
    local Callback = Config.Callback or function() end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    Frame.Parent = self.Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 15)
    Label.Text = Text .. ": " .. Default
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 10)
    Bar.Position = UDim2.new(0, 0, 0, 20)
    Bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Bar.BorderColor3 = Color3.fromRGB(255,0,0)
    Bar.Parent = Frame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Default-Min)/(Max-Min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255,50,50)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    local UserInputService = game:GetService("UserInputService")
    local dragging = false

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relative = math.clamp((input.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
            local value = math.floor(Min + (Max-Min)*relative)
            Fill.Size = UDim2.new(relative,0,1,0)
            Label.Text = Text .. ": " .. value
            pcall(Callback, value)
        end
    end)
end

return PepsiUI
