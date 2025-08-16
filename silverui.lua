--// SilverUI Advanced - tuffslvr
--// Rayfield benzeri düzen + mobil/pc destek + keybind + drag + tüm temel elementler

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local THEME = {
    bg        = Color3.fromRGB(26,26,26),
    panel     = Color3.fromRGB(32,32,32),
    panel2    = Color3.fromRGB(38,38,38),
    line      = Color3.fromRGB(55,55,55),
    text      = Color3.fromRGB(240,240,240),
    dim       = Color3.fromRGB(190,190,190),
    accent    = Color3.fromRGB(0,170,255),
    ok        = Color3.fromRGB(0,200,120),
    bad       = Color3.fromRGB(220,70,70),
}

local function corner(o,r) local u = Instance.new("UICorner", o); u.CornerRadius = UDim.new(0,r or 8) return u end
local function stroke(o,c,t) local s = Instance.new("UIStroke", o); s.Color=c or THEME.line; s.Thickness=t or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border return s end
local function pad(parent,p) local ui = Instance.new("UIPadding", parent); ui.PaddingLeft = UDim.new(0,p); ui.PaddingRight=UDim.new(0,p); ui.PaddingTop=UDim.new(0,p); ui.PaddingBottom=UDim.new(0,p); return ui end

local SilverUI = {
    _windows = {},
    _visible = true,
    ToggleKey = Enum.KeyCode.RightShift,
    MobileButton = nil
}

-- ===== Drag helper (pc + touch) =====
local function MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(frame.Position.X.Scale, startPos.X.Offset + delta.X, frame.Position.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then update(input) end
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            update(input)
        end
    end)
end

-- ===== global show/hide =====
local function SetVisible(state)
    SilverUI._visible = state
    for _,win in ipairs(SilverUI._windows) do
        if win and win.ScreenGui then win.ScreenGui.Enabled = state end
    end
    if SilverUI.MobileButton then SilverUI.MobileButton.Visible = not state end
end

UIS.InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode == SilverUI.ToggleKey then
        SetVisible(not SilverUI._visible)
    end
end)

-- ===== mobile floating button (draggable) =====
local function EnsureMobileButton()
    if SilverUI.MobileButton then return end
    local b = Instance.new("TextButton")
    b.Name = "SilverShowButton"
    b.Size = UDim2.new(0,140,0,44)
    b.Position = UDim2.new(0.5,-70,0.85,0)
    b.Text = "Show Silver"
    b.AutoButtonColor = true
    b.BackgroundColor3 = THEME.panel
    b.TextColor3 = THEME.text
    b.BorderSizePixel = 0
    b.Visible = false
    b.Parent = game:GetService("CoreGui")
    corner(b,10) stroke(b,THEME.line,1.2)
    b.MouseButton1Click:Connect(function() SetVisible(true) end)
    MakeDraggable(b)
    SilverUI.MobileButton = b
end
EnsureMobileButton()

-- ===== Window object =====
local Window = {}
Window.__index = Window

function Window:_selectTab(tabFrame)
    for _,pg in pairs(self.Pages) do pg.Visible = false end
    tabFrame.Visible = true
end

function Window:CreateTab(name, iconText)
    -- tab button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,40)
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 1
    btn.Text = (iconText and (iconText.."  ") or "") .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = THEME.dim
    btn.Parent = self.TabList

    -- tab page
    local page = Instance.new("ScrollingFrame")
    page.Name = name.."Page"
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarImageColor3 = THEME.line
    page.Parent = self.Content

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0,8)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    btn.Activated:Connect(function()
        for _,b in ipairs(self._tabButtons) do b.TextColor3 = THEME.dim end
        btn.TextColor3 = THEME.text
        self:_selectTab(page)
    end)

    table.insert(self._tabButtons, btn)
    table.insert(self.Pages, page)
    if #self.Pages == 1 then
        btn.TextColor3 = THEME.text
        page.Visible = true
    end

    -- simple container api
    local TabApi = {}
    function TabApi:Button(opts) return self._parent:_elemButton(page, opts) end
    function TabApi:Toggle(opts) return self._parent:_elemToggle(page, opts) end
    function TabApi:Slider(opts) return self._parent:_elemSlider(page, opts) end
    function TabApi:Dropdown(opts)return self._parent:_elemDropdown(page, opts) end
    function TabApi:Input(opts)  return self._parent:_elemInput(page, opts) end
    function TabApi:ColorPicker(opts)return self._parent:_elemColor(page, opts) end
    function TabApi:Keybind(opts) return self._parent:_elemKeybind(page, opts) end
    TabApi._parent = self
    return TabApi
end

-- ===== Elements =====
function Window:_sectionFrame(parent, h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-12,0,h or 44)
    f.BackgroundColor3 = THEME.panel2
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f,8) stroke(f,THEME.line,1)
    pad(f,8)
    return f
end

function Window:_elemButton(parent, opts)
    opts = opts or {}
    local fr = self:_sectionFrame(parent,44)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.Text = opts.Text or "Button"
    btn.BackgroundTransparency = 1
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = THEME.text
    btn.Parent = fr

    btn.Activated:Connect(function()
        if opts.Callback then task.spawn(opts.Callback) end
        -- tiny feedback
        TweenService:Create(fr, TweenInfo.new(0.06), {BackgroundColor3 = THEME.panel}):Play()
        task.delay(0.08, function()
            TweenService:Create(fr, TweenInfo.new(0.12), {BackgroundColor3 = THEME.panel2}):Play()
        end)
    end)
    return btn
end

function Window:_elemToggle(parent, opts)
    opts = opts or {}
    local fr = self:_sectionFrame(parent,44)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-52,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.Text = opts.Text or "Toggle"
    lbl.TextColor3 = THEME.text
    lbl.Parent = fr

    local tbtn = Instance.new("TextButton")
    tbtn.Size = UDim2.new(0,36,0,24)
    tbtn.Position = UDim2.new(1,-40,0.5,-12)
    tbtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    tbtn.Text = ""
    tbtn.AutoButtonColor = false
    tbtn.Parent = fr
    corner(tbtn,12)

    local knob = Instance.new("Frame", tbtn)
    knob.Size = UDim2.new(0,20,0,20)
    knob.Position = UDim2.new(0,2,0.5,-10)
    knob.BackgroundColor3 = THEME.bg
    knob.BorderSizePixel = 0
    corner(knob,10)

    local state = opts.Default or false
    local function apply()
        TweenService:Create(tbtn, TweenInfo.new(0.15), {BackgroundColor3 = state and THEME.ok or Color3.fromRGB(70,70,70)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)}):Play()
    end
    apply()

    tbtn.Activated:Connect(function()
        state = not state
        apply()
        if opts.Callback then task.spawn(opts.Callback, state) end
    end)

    return {
        Set = function(_,v) state=v; apply() end,
        Get = function() return state end
    }
end

function Window:_elemSlider(parent, opts)
    opts = opts or {}
    local min, max = opts.Min or 0, opts.Max or 100
    local val = math.clamp(opts.Default or min, min, max)

    local fr = self:_sectionFrame(parent,56)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = THEME.text
    lbl.Text = (opts.Text or "Slider")
    lbl.Parent = fr

    local bar = Instance.new("Frame", fr)
    bar.Size = UDim2.new(1,-4,0,16)
    bar.Position = UDim2.new(0,2,1,-20)
    bar.BackgroundColor3 = THEME.panel
    bar.BorderSizePixel = 0
    corner(bar,8) stroke(bar,THEME.line,1)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = THEME.accent
    fill.BorderSizePixel = 0
    corner(fill,8)

    local text = Instance.new("TextLabel", bar)
    text.Size = UDim2.new(0,120,1,0)
    text.BackgroundTransparency = 1
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.Text = tostring(val) .. (opts.Suffix and (" "..opts.Suffix) or "")
    text.TextColor3 = THEME.text
    text.Font = Enum.Font.Gotham
    text.TextSize = 12

    local dragging=false; local startX
    local function setFromX(x)
        local p = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        val = math.floor(min + p*(max-min))
        fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
        text.Text = tostring(val) .. (opts.Suffix and (" "..opts.Suffix) or "")
        if opts.Callback then opts.Callback(val) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; setFromX(input.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)

    return {
        Set=function(_,v) val=math.clamp(v,min,max); fill.Size=UDim2.new((val-min)/(max-min),0,1,0); text.Text=tostring(val)..(opts.Suffix and (" "..opts.Suffix) or "") end,
        Get=function() return val end
    }
end

function Window:_elemDropdown(parent, opts)
    opts = opts or {}
    local items = opts.Items or {}
    local current = opts.Default or items[1]

    local fr = self:_sectionFrame(parent,44)
    local btn = Instance.new("TextButton", fr)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = THEME.text
    btn.Text = (opts.Text or "Select") .. ": " .. (current or "-")

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1,0,0,0)
    listFrame.Position = UDim2.new(0,0,1,4)
    listFrame.BackgroundColor3 = THEME.panel2
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = fr
    corner(listFrame,8) stroke(listFrame,THEME.line,1)

    local lpad = pad(listFrame,6)
    local ul = Instance.new("UIListLayout", listFrame)
    ul.Padding = UDim.new(0,6)

    local open=false
    local function populate()
        listFrame:ClearAllChildren(); corner(listFrame,8); stroke(listFrame,THEME.line,1); pad(listFrame,6); ul = Instance.new("UIListLayout", listFrame); ul.Padding = UDim.new(0,6)
        for _,it in ipairs(items) do
            local i = Instance.new("TextButton", listFrame)
            i.Size = UDim2.new(1,0,0,28)
            i.BackgroundColor3 = THEME.panel
            i.TextColor3 = THEME.text
            i.Text = tostring(it)
            i.Font = Enum.Font.Gotham
            i.TextSize = 13
            i.AutoButtonColor = true
            corner(i,6)
            i.Activated:Connect(function()
                current = it
                btn.Text = (opts.Text or "Select") .. ": " .. tostring(current)
                listFrame.Visible=false; listFrame.Size=UDim2.new(1,0,0,0); open=false
                if opts.Callback then opts.Callback(current) end
            end)
        end
        task.wait(); -- layout calc
        local total = (#items)*(28+6)+6
        listFrame.Size = UDim2.new(1,0,0,total)
    end
    populate()

    btn.Activated:Connect(function()
        open = not open
        listFrame.Visible = open
    end)

    return {
        SetList = function(_,arr) items=arr; populate() end,
        Set = function(_,v) current=v; btn.Text=(opts.Text or "Select")..": "..tostring(v) end,
        Get = function() return current end
    }
end

function Window:_elemInput(parent, opts)
    opts = opts or {}
    local fr = self:_sectionFrame(parent,44)
    local tb = Instance.new("TextBox", fr)
    tb.Size = UDim2.new(1,0,1,0)
    tb.BackgroundTransparency = 1
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.PlaceholderText = opts.Placeholder or "Type here..."
    tb.Text = opts.Default or ""
    tb.ClearTextOnFocus = false
    tb.TextColor3 = THEME.text
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 14

    tb.FocusLost:Connect(function(enterPressed)
        if opts.Callback then opts.Callback(tb.Text, enterPressed) end
    end)

    return tb
end

function Window:_elemColor(parent, opts)
    opts = opts or {}
    local color = opts.Default or Color3.fromRGB(255,0,0)

    local fr = self:_sectionFrame(parent,44)
    local lb = Instance.new("TextLabel", fr)
    lb.Size = UDim2.new(1,-44,1,0)
    lb.BackgroundTransparency = 1
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 14
    lb.Text = opts.Text or "Color"
    lb.TextColor3 = THEME.text

    local sw = Instance.new("TextButton", fr)
    sw.Size = UDim2.new(0,34,0,24)
    sw.Position = UDim2.new(1,-36,0.5,-12)
    sw.BackgroundColor3 = color
    sw.Text = ""
    sw.AutoButtonColor = true
    corner(sw,6) stroke(sw,THEME.line,1)

    -- mini picker (3 preset + random) – basit ama iş görür
    local picker = Instance.new("Frame")
    picker.Size = UDim2.new(0,140,0,36)
    picker.Position = UDim2.new(1,-140,1,6)
    picker.BackgroundColor3 = THEME.panel
    picker.Visible = false
    picker.Parent = fr
    corner(picker,8) stroke(picker,THEME.line,1)
    pad(picker,6)

    local colors = {
        Color3.fromRGB(255,0,0),
        Color3.fromRGB(0,200,120),
        Color3.fromRGB(0,170,255),
    }
    for i,c in ipairs(colors) do
        local b = Instance.new("TextButton", picker)
        b.Size = UDim2.new(0,30,1,-0)
        b.Position = UDim2.new(0,(i-1)*36,0,0)
        b.BackgroundColor3 = c
        b.Text = ""
        corner(b,6) stroke(b,THEME.line,1)
        b.Activated:Connect(function()
            color=c; sw.BackgroundColor3=c; picker.Visible=false; if opts.Callback then opts.Callback(color) end
        end)
    end
    local rnd = Instance.new("TextButton", picker)
    rnd.Size = UDim2.new(0,30,1,0)
    rnd.Position = UDim2.new(0,3*36,0,0)
    rnd.Text = "🎲"
    rnd.BackgroundColor3 = THEME.panel2
    rnd.TextColor3 = THEME.text
    corner(rnd,6) stroke(rnd,THEME.line,1)
    rnd.Activated:Connect(function()
        local r=math.random; color=Color3.fromRGB(r(0,255),r(0,255),r(0,255))
        sw.BackgroundColor3=color; picker.Visible=false; if opts.Callback then opts.Callback(color) end
    end)

    sw.Activated:Connect(function()
        picker.Visible = not picker.Visible
    end)

    return {
        Set=function(_,c) color=c; sw.BackgroundColor3=c end,
        Get=function() return color end
    }
end

function Window:_elemKeybind(parent, opts)
    opts = opts or {}
    local fr = self:_sectionFrame(parent,44)
    local lbl = Instance.new("TextLabel", fr)
    lbl.Size = UDim2.new(1,-110,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.Text = opts.Text or "Keybind"
    lbl.TextColor3 = THEME.text

    local kb = Instance.new("TextButton", fr)
    kb.Size = UDim2.new(0,90,0,28)
    kb.Position = UDim2.new(1,-94,0.5,-14)
    kb.Text = (opts.Default and opts.Default.Name) or "None"
    kb.TextColor3 = THEME.text
    kb.Font = Enum.Font.Gotham
    kb.TextSize = 13
    kb.BackgroundColor3 = THEME.panel
    corner(kb,6) stroke(kb,THEME.line,1)

    local current = opts.Default
    kb.Activated:Connect(function()
        kb.Text = "Press..."
        local conn; conn = UIS.InputBegan:Connect(function(input,gpe)
            if gpe then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                current = input.KeyCode
                kb.Text = current.Name
                conn:Disconnect()
            end
        end)
    end)

    UIS.InputBegan:Connect(function(input,gpe)
        if not gpe and current and input.KeyCode == current then
            if opts.Callback then opts.Callback() end
        end
    end)

    return {
        Get=function() return current end,
        Set=function(_,kc) current = kc; kb.Text = kc and kc.Name or "None" end
    }
end

-- ===== CreateWindow (public) =====
function SilverUI:CreateWindow(opts)
    opts = opts or {}
    local name = opts.Name or "Silver UI"
    local sg = Instance.new("ScreenGui")
    sg.Name = "SilverUI_"..tostring(math.random(1,9999))
    sg.ResetOnSpawn = false
    sg.Parent = game:GetService("CoreGui")

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0,640,0,380)
    main.Position = UDim2.new(0.5,-320,0.5,-190)
    main.BackgroundColor3 = THEME.bg
    main.BorderSizePixel = 0
    corner(main,12) stroke(main,THEME.line,1)

    -- top bar
    local top = Instance.new("Frame", main)
    top.Size = UDim2.new(1,0,0,40)
    top.BackgroundColor3 = THEME.panel
    top.BorderSizePixel = 0
    corner(top,12)
    pad(top,12)

    local title = Instance.new("TextLabel", top)
    title.Size = UDim2.new(1,-120,1,0)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = THEME.text
    title.Text = name

    -- buttons
    local minBtn = Instance.new("TextButton", top)
    minBtn.Size = UDim2.new(0,30,0,24)
    minBtn.Position = UDim2.new(1,-70,0.5,-12)
    minBtn.Text = "-"
    minBtn.BackgroundColor3 = THEME.panel2
    minBtn.TextColor3 = THEME.text
    corner(minBtn,8) stroke(minBtn,THEME.line,1)

    local closeBtn = Instance.new("TextButton", top)
    closeBtn.Size = UDim2.new(0,30,0,24)
    closeBtn.Position = UDim2.new(1,-34,0.5,-12)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = THEME.bad
    closeBtn.TextColor3 = Color3.new(1,1,1)
    corner(closeBtn,8)

    -- left tabs
    local tabPanel = Instance.new("Frame", main)
    tabPanel.Size = UDim2.new(0,160,1,-48)
    tabPanel.Position = UDim2.new(0,12,0,48)
    tabPanel.BackgroundColor3 = THEME.panel
    tabPanel.BorderSizePixel = 0
    corner(tabPanel,10) stroke(tabPanel,THEME.line,1)
    pad(tabPanel,8)

    local list = Instance.new("UIListLayout", tabPanel)
    list.Padding = UDim.new(0,6)

    -- content panel
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1,-(160+24),1,-48)
    content.Position = UDim2.new(0,160+12,0,48)
    content.BackgroundColor3 = THEME.panel
    content.BorderSizePixel = 0
    corner(content,10) stroke(content,THEME.line,1)
    pad(content,8)

    local win = setmetatable({
        ScreenGui = sg,
        Main = main,
        Top = top,
        TabList = tabPanel,
        Content = content,
        Pages = {},
        _tabButtons = {}
    }, Window)

    -- actions
    closeBtn.Activated:Connect(function()
        SetVisible(false)
    end)

    local minimized=false
    minBtn.Activated:Connect(function()
        minimized = not minimized
        tabPanel.Visible = not minimized
        content.Visible = not minimized
        main.Size = minimized and UDim2.new(0,640,0,52) or UDim2.new(0,640,0,380)
    end)

    -- drag both pc+touch
    MakeDraggable(main, top)

    table.insert(SilverUI._windows, win)
    return win
end

return SilverUI
