--// SilverUI Advanced – dark, mobile + PC, full controls
--// tuffslvr
--// Özellikler:
--// - Window: title, minimize, close, draggable (mouse + touch)
--// - Global toggle key (RightShift) + mobil "Show Silver" floating button (draggable)
--// - Sol dikey tab menüsü (Rayfield tarzı) + içerik sayfaları
--// - Elementler: Button, Toggle, Slider, Dropdown, Input, ColorPicker (RGB popup), Keybind Picker
--// - Hepsi dokunmatik ve mouse ile çalışır

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local function getGuiRoot()
    -- Executor farklılıklarına dayanıklı ebeveyn seçimi
    local ok, hui = pcall(function() return (gethui and gethui()) end)
    if ok and typeof(hui) == "Instance" then return hui end
    local CoreGui = game:GetService("CoreGui")
    return CoreGui
end

local function makeScreen(name)
    local sg = Instance.new("ScreenGui")
    sg.Name = name or "SilverUI"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    pcall(function()
        sg.Parent = getGuiRoot()
    end)
    if sg.Parent == nil then
        -- CoreGui blokluysa PlayerGui'ye düş
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    return sg
end

local function uiCorner(inst, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 10); c.Parent=inst; return c end
local function uiStroke(inst, th, col, tran)
    local s=Instance.new("UIStroke")
    s.Thickness = th or 1
    s.Color = col or Color3.fromRGB(60,60,60)
    s.Transparency = tran or 0
    s.Parent = inst
    return s
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, startPos, startInputPos

    local function update(input)
        local delta = input.Position - startInputPos
        frame.Position = UDim2.new(
            frame.Position.X.Scale, frame.Position.X.Offset + delta.X,
            frame.Position.Y.Scale, frame.Position.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = frame.Position
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

local SilverUI = {
    _windows = {},
    _visible = true,
    _toggleKey = Enum.KeyCode.RightShift,
    _mobileButton = nil,
    _screen = nil
}

-- görünürlük
function SilverUI:_setVisible(state)
    self._visible = state
    for _, w in ipairs(self._windows) do
        w.Root.Visible = state
    end
    if self._mobileButton then
        self._mobileButton.Visible = not state
    end
end

-- global keybind (PC)
UserInputService.InputBegan:Connect(function(input, gpe)
    local lib = rawget(_G, "__SILVERUI_SINGLETON__")
    if not lib or gpe then return end
    if input.KeyCode == lib._toggleKey then
        lib:_setVisible(not lib._visible)
    end
end)

-- mobil floating "Show Silver" butonu
local function createMobileButton(screen, onPress)
    local b = Instance.new("TextButton")
    b.Name = "SilverShowButton"
    b.Size = UDim2.new(0,130,0,42)
    b.Position = UDim2.new(0.5,-65,1,-52)
    b.Text = "Show Silver"
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.AutoButtonColor = true
    b.Visible = false
    b.Parent = screen
    uiCorner(b, 10)
    uiStroke(b, 1, Color3.fromRGB(70,70,70))
    makeDraggable(b)
    b.MouseButton1Click:Connect(onPress)
    return b
end

-- kütüphane init (tekil)
function SilverUI:Init(opts)
    if rawget(_G, "__SILVERUI_SINGLETON__") then
        return _G["__SILVERUI_SINGLETON__"]
    end
    opts = opts or {}
    self._screen = makeScreen("SilverUI")
    self._toggleKey = opts.ToggleKey or self._toggleKey
    self._mobileButton = createMobileButton(self._screen, function()
        self:_setVisible(true)
    end)
    _G["__SILVERUI_SINGLETON__"] = self
    return self
end

function SilverUI:SetToggleKey(keycode) self._toggleKey = keycode end

-- ==== Window ====
function SilverUI:CreateWindow(cfg)
    cfg = cfg or {}
    if not self._screen then self:Init({}) end

    local root = Instance.new("Frame")
    root.Name = "SilverWindow"
    root.Size = UDim2.new(0, 640, 0, 380)
    root.Position = UDim2.new(0.5, -320, 0.5, -190)
    root.BackgroundColor3 = Color3.fromRGB(26,26,26)
    root.BorderSizePixel = 0
    root.Parent = self._screen
    uiCorner(root, 12)
    uiStroke(root, 1, Color3.fromRGB(60,60,60), 0.3)

    -- topbar
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1,0,0,36)
    top.BackgroundColor3 = Color3.fromRGB(34,34,34)
    top.BorderSizePixel = 0
    top.Parent = root
    uiCorner(top, 12)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-120,1,0)
    title.Position = UDim2.new(0,14,0,0)
    title.BackgroundTransparency = 1
    title.Text = cfg.Name or "Silver UI"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(235,235,235)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    -- top buttons
    local btnMin = Instance.new("TextButton")
    btnMin.Size = UDim2.new(0,36,1,0)
    btnMin.Position = UDim2.new(1,-72,0,0)
    btnMin.BackgroundTransparency = 1
    btnMin.Text = "-"
    btnMin.Font = Enum.Font.GothamBold
    btnMin.TextSize = 18
    btnMin.TextColor3 = Color3.fromRGB(220,220,220)
    btnMin.Parent = top

    local btnClose = Instance.new("TextButton")
    btnClose.Size = UDim2.new(0,36,1,0)
    btnClose.Position = UDim2.new(1,-36,0,0)
    btnClose.BackgroundTransparency = 1
    btnClose.Text = "X"
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 16
    btnClose.TextColor3 = Color3.fromRGB(230,80,80)
    btnClose.Parent = top

    -- left tabs
    local tabs = Instance.new("Frame")
    tabs.Size = UDim2.new(0,140,1,-36)
    tabs.Position = UDim2.new(0,0,0,36)
    tabs.BackgroundColor3 = Color3.fromRGB(22,22,22)
    tabs.BorderSizePixel = 0
    tabs.Parent = root

    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0,4)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = tabs

    -- right content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-140,1,-36)
    content.Position = UDim2.new(0,140,0,36)
    content.BackgroundColor3 = Color3.fromRGB(18,18,18)
    content.BorderSizePixel = 0
    content.Parent = root
    uiStroke(content,1,Color3.fromRGB(55,55,55),0.35)

    -- minimize behavior
    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        tabs.Visible = not minimized
        content.Visible = not minimized
        root.Size = minimized and UDim2.new(0,640,0,36) or UDim2.new(0,640,0,380)
    end)

    btnClose.MouseButton1Click:Connect(function()
        self:_setVisible(false)
    end)

    makeDraggable(root, top)

    local win = {
        Root = root,
        Top = top,
        Tabs = {},
        TabsContainer = tabs,
        ContentRoot = content,
        _selected = nil
    }

    -- Tab API
    function win:CreateTab(tabName)
        local tbtn = Instance.new("TextButton")
        tbtn.Size = UDim2.new(1, -8, 0, 32)
        tbtn.Position = UDim2.new(0, 4, 0, 0)
        tbtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        tbtn.Text = tabName or "Tab"
        tbtn.TextColor3 = Color3.fromRGB(210,210,210)
        tbtn.Font = Enum.Font.GothamSemibold
        tbtn.TextSize = 14
        tbtn.BorderSizePixel = 0
        tbtn.Parent = tabs
        uiCorner(tbtn, 8)
        uiStroke(tbtn,1,Color3.fromRGB(55,55,55),0.2)

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, -16, 1, -16)
        page.Position = UDim2.new(0, 8, 0, 8)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 6
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.Visible = false
        page.Parent = content

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0,8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        local tabObj = {Button=tbtn, Page=page, ElementsLayout=layout}
        table.insert(self.Tabs, tabObj)

        local function selectTab()
            for _, t in ipairs(self.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = Color3.fromRGB(30,30,30)
            end
            page.Visible = true
            tbtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            self._selected = tabObj
        end
        tbtn.MouseButton1Click:Connect(selectTab)
        if not self._selected then selectTab() end

        -- ---- Element Builders ----
        local E = {}

        function E:_container(height)
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, -0, 0, height)
            item.BackgroundColor3 = Color3.fromRGB(28,28,28)
            item.BorderSizePixel = 0
            item.Parent = page
            uiCorner(item, 8)
            uiStroke(item,1,Color3.fromRGB(60,60,60),0.25)
            return item
        end

        function E:Button(cfg)
            cfg = cfg or {}
            local f = self:_container(40)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-12,1,-12)
            btn.Position = UDim2.new(0,6,0,6)
            btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
            btn.Text = cfg.Text or "Button"
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.AutoButtonColor = true
            btn.Parent = f
            uiCorner(btn,6)
            btn.MouseButton1Click:Connect(function()
                if cfg.Callback then cfg.Callback() end
            end)
            return btn
        end

        function E:Toggle(cfg)
            cfg = cfg or {}
            local f = self:_container(40)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1,-50,1,0)
            label.Position = UDim2.new(0,10,0,0)
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = cfg.Text or "Toggle"
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextColor3 = Color3.new(1,1,1)
            label.Parent = f

            local t = Instance.new("TextButton")
            t.Size = UDim2.new(0,34,0,22)
            t.Position = UDim2.new(1,-44,0.5,-11)
            t.BackgroundColor3 = Color3.fromRGB(70,70,70)
            t.Text = ""
            t.Parent = f
            uiCorner(t, 11)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0,18,0,18)
            knob.Position = UDim2.new(0,2,0.5,-9)
            knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
            knob.Parent = t
            uiCorner(knob, 9)

            local state = false
            local function setState(v)
                state = v
                TweenService:Create(knob, TweenInfo.new(0.15), {Position = v and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play()
                t.BackgroundColor3 = v and Color3.fromRGB(0,170,255) or Color3.fromRGB(70,70,70)
                if cfg.Callback then cfg.Callback(state) end
            end
            t.MouseButton1Click:Connect(function() setState(not state) end)
            if cfg.Default ~= nil then setState(cfg.Default) end
            return {Set = setState, Get = function() return state end}
        end

        function E:Slider(cfg)
            cfg = cfg or {}
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local def = math.clamp(cfg.Default or min, min, max)

            local f = self:_container(56)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 0, 20)
            lbl.Position = UDim2.new(0,10,0,6)
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = cfg.Text or "Slider"
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Parent = f

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1,-20,0,10)
            bar.Position = UDim2.new(0,10,0,34)
            bar.BackgroundColor3 = Color3.fromRGB(55,55,55)
            bar.Parent = f
            uiCorner(bar,5)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0,0,1,0)
            fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
            fill.Parent = bar
            uiCorner(fill,5)

            local valueLabel = Instance.new("TextLabel")
            valueLabel.AnchorPoint = Vector2.new(0,1)
            valueLabel.Position = UDim2.new(0,10,0,32)
            valueLabel.Size = UDim2.new(0,120,0,16)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.TextColor3 = Color3.fromRGB(210,210,210)
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextSize = 12
            valueLabel.Parent = f

            local dragging = false
            local function setFromRatio(r)
                r = math.clamp(r,0,1)
                fill.Size = UDim2.new(r,0,1,0)
                local v = math.floor(min + r*(max-min) + 0.5)
                valueLabel.Text = tostring(v) .. (cfg.Suffix and (" "..cfg.Suffix) or "")
                if cfg.Callback then cfg.Callback(v) end
            end
            local function updateFromInput(x)
                local ratio = (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                setFromRatio(ratio)
            end

            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromInput(input.Position.X)
                end
            end)
            bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input.Position.X)
                end
            end)

            setFromRatio((def-min)/(max-min))
            return {SetRatio = setFromRatio}
        end

        function E:Dropdown(cfg)
            cfg = cfg or {}
            local items = cfg.Items or {}
            local f = self:_container(40)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-12,1,-12)
            btn.Position = UDim2.new(0,6,0,6)
            btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Text = (cfg.Text or "Dropdown") .. "  ▾"
            btn.Parent = f
            uiCorner(btn,6)

            local list = Instance.new("Frame")
            list.Visible = false
            list.Size = UDim2.new(1,-12,0, math.min(#items,6)*28 + 8)
            list.Position = UDim2.new(0,6,1,2)
            list.BackgroundColor3 = Color3.fromRGB(28,28,28)
            list.Parent = f
            uiCorner(list,6)
            uiStroke(list,1,Color3.fromRGB(60,60,60),0.25)

            local lLayout = Instance.new("UIListLayout", list)
            lLayout.Padding = UDim.new(0,4)

            local function select(v)
                btn.Text = tostring(v)
                list.Visible = false
                if cfg.Callback then cfg.Callback(v) end
            end
            for _, it in ipairs(items) do
                local iBtn = Instance.new("TextButton")
                iBtn.Size = UDim2.new(1,-8,0,24)
                iBtn.Position = UDim2.new(0,4,0,0)
                iBtn.BackgroundColor3 = Color3.fromRGB(36,36,36)
                iBtn.TextColor3 = Color3.new(1,1,1)
                iBtn.Font = Enum.Font.Gotham
                iBtn.TextSize = 13
                iBtn.Text = tostring(it)
                iBtn.Parent = list
                uiCorner(iBtn,6)
                iBtn.MouseButton1Click:Connect(function() select(it) end)
            end

            btn.MouseButton1Click:Connect(function()
                list.Visible = not list.Visible
            end)

            if cfg.Default then select(cfg.Default) end
            return {Open=function(v) list.Visible=v end}
        end

        function E:Input(cfg)
            cfg = cfg or {}
            local f = self:_container(40)
            local box = Instance.new("TextBox")
            box.ClearTextOnFocus = false
            box.Size = UDim2.new(1,-12,1,-12)
            box.Position = UDim2.new(0,6,0,6)
            box.BackgroundColor3 = Color3.fromRGB(38,38,38)
            box.TextColor3 = Color3.new(1,1,1)
            box.PlaceholderText = cfg.Placeholder or "Type here..."
            box.Font = Enum.Font.Gotham
            box.TextSize = 14
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.Parent = f
            uiCorner(box,6)
            if cfg.Default then box.Text = tostring(cfg.Default) end
            box.FocusLost:Connect(function(enter)
                if cfg.Callback then cfg.Callback(box.Text, enter) end
            end)
            return box
        end

        function E:ColorPicker(cfg)
            cfg = cfg or {}
            local f = self:_container(40)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1,-50,1,0)
            label.Position = UDim2.new(0,10,0,0)
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = cfg.Text or "Color"
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextColor3 = Color3.new(1,1,1)
            label.Parent = f

            local swatch = Instance.new("TextButton")
            swatch.Size = UDim2.new(0,30,0,22)
            swatch.Position = UDim2.new(1,-44,0.5,-11)
            swatch.BackgroundColor3 = cfg.Default or Color3.fromRGB(255,0,0)
            swatch.Text = ""
            swatch.Parent = f
            uiCorner(swatch,6)

            local popup = Instance.new("Frame")
            popup.Visible = false
            popup.Size = UDim2.new(0,220,0,140)
            popup.Position = UDim2.new(1,-226,0,40)
            popup.BackgroundColor3 = Color3.fromRGB(28,28,28)
            popup.Parent = f
            uiCorner(popup,8)
            uiStroke(popup,1,Color3.fromRGB(60,60,60),0.25)

            local function sliderRow(text, y, min, max, def)
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0,40,0,20)
                lbl.Position = UDim2.new(0,8,0,y)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = Color3.new(1,1,1)
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 12
                lbl.Parent = popup

                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(1,-70,0,8)
                bar.Position = UDim2.new(0,50,0,y+6)
                bar.BackgroundColor3 = Color3.fromRGB(55,55,55)
                bar.Parent = popup
                uiCorner(bar,4)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
                fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
                fill.Parent = bar
                uiCorner(fill,4)

                local dragging = false
                local function setFromX(x)
                    local r = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(r,0,1,0)
                    return math.floor(min + r*(max-min) + 0.5)
                end
                bar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        def = setFromX(inp.Position.X)
                    end
                end)
                bar.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        def = setFromX(inp.Position.X)
                    end
                end)
                return function() return def end, function(v)
                    local r = (v-min)/(max-min)
                    fill.Size = UDim2.new(r,0,1,0)
                    def = v
                end
            end

            local getR, setR = sliderRow("R", 10, 0,255, math.floor(swatch.BackgroundColor3.R*255+0.5))
            local getG, setG = sliderRow("G", 50, 0,255, math.floor(swatch.BackgroundColor3.G*255+0.5))
            local getB, setB = sliderRow("B", 90, 0,255, math.floor(swatch.BackgroundColor3.B*255+0.5))

            local function fire()
                local c = Color3.fromRGB(getR(), getG(), getB())
                swatch.BackgroundColor3 = c
                if cfg.Callback then cfg.Callback(c) end
            end

            swatch.MouseButton1Click:Connect(function()
                popup.Visible = not popup.Visible
            end)

            popup.InputChanged:Connect(function() fire() end)
            UserInputService.InputEnded:Connect(function() if popup.Visible then fire() end end)

            return {
                Set = function(c)
                    setR(math.floor(c.R*255)); setG(math.floor(c.G*255)); setB(math.floor(c.B*255))
                    swatch.BackgroundColor3 = c; fire()
                end
            }
        end

        function E:Keybind(cfg)
            cfg = cfg or {}
            local f = self:_container(40)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-120,1,0)
            lbl.Position = UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = cfg.Text or "Keybind"
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Parent = f

            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0,100,0,24)
            b.Position = UDim2.new(1,-110,0.5,-12)
            b.BackgroundColor3 = Color3.fromRGB(38,38,38)
            b.TextColor3 = Color3.new(1,1,1)
            b.TextSize = 13
            b.Font = Enum.Font.Gotham
            b.Text = "Set Key"
            b.Parent = f
            uiCorner(b,6)

            local currentKey = cfg.Default or Enum.KeyCode.None
            local waiting = false
            b.MouseButton1Click:Connect(function()
                waiting = true
                b.Text = "Press key..."
            end)
            UserInputService.InputBegan:Connect(function(input, gpe)
                if not waiting or gpe then return end
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode
                    waiting = false
                    b.Text = tostring(currentKey.Name)
                    if cfg.Callback then cfg.Callback(currentKey) end
                end
            end)

            return {Get=function() return currentKey end, Set=function(k) currentKey=k; b.Text=tostring(k.Name) end}
        end

        return E
    end

    table.insert(self._windows, win)
    return win
end

-- mobilde Show Silver’u otomatik göster
task.defer(function()
    local lib = rawget(_G,"__SILVERUI_SINGLETON__") or SilverUI
    if UserInputService.TouchEnabled and lib._mobileButton then
        lib._mobileButton.Visible = false -- UI ilk açık gelir
    end
end)

return (rawget(_G,"__SILVERUI_SINGLETON__") and _G["__SILVERUI_SINGLETON__"] or SilverUI:Init({}))
