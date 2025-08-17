-- // SilverUIPro.lua
-- // Custom Roblox UI Library with Themes + Full Elements
-- // Made by ChatGPT & tuffslvr ⚡

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local SilverUI = {}
SilverUI.__index = SilverUI

-- // THEMES
local Themes = {
    Dark = {
        Background = Color3.fromRGB(25,25,25),
        Topbar = Color3.fromRGB(35,35,35),
        Sidebar = Color3.fromRGB(30,30,30),
        Text = Color3.fromRGB(220,220,220),
        Accent = Color3.fromRGB(0,170,255),
    },
    Light = {
        Background = Color3.fromRGB(245,245,245),
        Topbar = Color3.fromRGB(230,230,230),
        Sidebar = Color3.fromRGB(235,235,235),
        Text = Color3.fromRGB(25,25,25),
        Accent = Color3.fromRGB(0,120,255),
    }
}

local CurrentTheme = Themes.Dark

-- // HELPERS
local function create(instance, props)
    local obj = Instance.new(instance)
    for k,v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- // WINDOW
function SilverUI:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "Silver UI"
    local theme = opts.Theme or "Dark"

    CurrentTheme = Themes[theme] or Themes.Dark

    local ScreenGui = create("ScreenGui", {Parent = game.CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})

    local Main = create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = CurrentTheme.Background,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BorderSizePixel = 0
    })
    create("UICorner", {CornerRadius = UDim.new(0,12), Parent = Main})

    local Topbar = create("Frame", {
        Parent = Main,
        BackgroundColor3 = CurrentTheme.Topbar,
        Size = UDim2.new(1,0,0,35),
        BorderSizePixel = 0
    })
    create("UICorner", {CornerRadius = UDim.new(0,12), Parent = Topbar})

    local Title = create("TextLabel", {
        Parent = Topbar,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = CurrentTheme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0,10,0,0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Close Button
    local Close = create("TextButton", {
        Parent = Topbar,
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = CurrentTheme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0,35,1,0),
        Position = UDim2.new(1,-35,0,0)
    })
    Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Drag
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Sidebar
    local Sidebar = create("Frame", {
        Parent = Main,
        BackgroundColor3 = CurrentTheme.Sidebar,
        Size = UDim2.new(0,150,1,-35),
        Position = UDim2.new(0,0,0,35),
        BorderSizePixel = 0
    })

    local TabContainer = create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-150,1,-35),
        Position = UDim2.new(0,150,0,35)
    })

    local UIListLayout = create("UIListLayout", {Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder})

    local Tabs = {}

    function SilverUI:CreateTab(name)
        local TabButton = create("TextButton", {
            Parent = Sidebar,
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = CurrentTheme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,35)
        })

        local TabPage = create("ScrollingFrame", {
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            ScrollBarThickness = 4,
            Visible = false
        })
        create("UIListLayout", {Parent = TabPage, Padding = UDim.new(0,5), SortOrder = Enum.SortOrder.LayoutOrder})

        TabButton.MouseButton1Click:Connect(function()
            for _,v in pairs(TabContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            TabPage.Visible = true
        end)

        if #Tabs == 0 then
            TabPage.Visible = true
        end

        table.insert(Tabs, {Button = TabButton, Page = TabPage})

        return {
            AddButton = function(self, txt, cb)
                local Btn = create("TextButton", {
                    Parent = TabPage,
                    Text = txt,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = CurrentTheme.Text,
                    BackgroundColor3 = CurrentTheme.Topbar,
                    Size = UDim2.new(0,200,0,30)
                })
                create("UICorner", {CornerRadius = UDim.new(0,6), Parent = Btn})
                Btn.MouseButton1Click:Connect(cb)
            end,
            AddLabel = function(self, txt)
                create("TextLabel", {
                    Parent = TabPage,
                    Text = txt,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = CurrentTheme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,0,25)
                })
            end
            -- buraya Toggle, Slider, Dropdown vs. eklenebilir (aynı mantıkla)
        }
    end

    return SilverUI
end

return SilverUI
