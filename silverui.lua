--// SilverUI Pro v2 (LOCK-IN)
--// Responsive + stable tabs + smooth animations + mobile friendly
--// by tuffslvr

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RunS = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local THEME = {
    bg     = Color3.fromRGB(20,20,22),
    panel  = Color3.fromRGB(28,28,32),
    panel2 = Color3.fromRGB(35,35,40),
    line   = Color3.fromRGB(58,58,64),
    text   = Color3.fromRGB(235,235,240),
    dim    = Color3.fromRGB(175,175,185),
    accent = Color3.fromRGB(0,170,255),
    ok     = Color3.fromRGB(0,200,120),
}

local function corner(o, r) local u=Instance.new("UICorner",o);u.CornerRadius=UDim.new(0,r or 12);return u end
local function stroke(o,c,t) local s=Instance.new("UIStroke",o);s.Color=c or THEME.line;s.Thickness=t or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function pad(o,p) local u=Instance.new("UIPadding",o);u.PaddingLeft=UDim.new(0,p);u.PaddingRight=UDim.new(0,p);u.PaddingTop=UDim.new(0,p);u.PaddingBottom=UDim.new(0,p);return u end
local function tween(i,info,props) TS:Create(i,info,props):Play() end

local function getViewport()
    local cam = workspace.CurrentCamera
    return (cam and cam.ViewportSize) or Vector2.new(1280,720)
end

local function mountParent()
    local cg = game:GetService("CoreGui")
    local ok,uiroot = pcall(function()
        return gethui and gethui() or cg
    end)
    return ok and uiroot or cg
end

local SilverUI = {
    _wins = {},
    _visible = true,
    ToggleKey = Enum.KeyCode.RightShift,
    MobileButton = nil,
}

-- ========= Drag (pc+touch) + screen clamp =========
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging=false
    local startPos, startInputPos

    local function clampToScreen(pos, size)
        local vp = getViewport()
        local x = math.clamp(pos.X.Offset, 0, math.max(0, vp.X - size.X))
        local y = math.clamp(pos.Y.Offset, 0, math.max(0, vp.Y - size.Y))
        return UDim2.new(pos.X.Scale, x, pos.Y.Scale, y)
    end

    local function update(input)
        local delta = input.Position - startInputPos
        local npos = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        frame.Position = clampToScreen(npos, frame.AbsoluteSize)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            startPos = frame.Position
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) and dragging then
            update(input)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) and dragging then
            update(input)
        end
    end)
end

-- ========= Global show/hide =========
local function SetVisible(state)
    SilverUI._visible = state
    for _,w in ipairs(SilverUI._wins) do
        if w and w.Gui then w.Gui.Enabled = state end
    end
    if SilverUI.MobileButton then SilverUI.MobileButton.Visible = not state end
end

UIS.InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode == SilverUI.ToggleKey then
        SetVisible(not SilverUI._visible)
    end
end)

-- ========= Mobile floating Show button =========
local function EnsureMobileButton()
    if SilverUI.MobileButton then return end
    local b = Instance.new("TextButton")
    b.Name="SilverShow"
    b.Size=UDim2.new(0,140,0,44)
    b.Position=UDim2.new(0.5,-70,0.86,0)
    b.Text="Show Silver"
    b.TextColor3=THEME.text
    b.Font=Enum.Font.GothamMedium
    b.TextSize=14
    b.BackgroundColor3=THEME.panel2
    b.AutoButtonColor=true
    b.BorderSizePixel=0
    b.Visible=false
    b.ZIndex = 9999
    b.Parent=mountParent()
    corner(b,12); stroke(b,THEME.line,1.1)
    MakeDraggable(b)
    b.Activated:Connect(function() SetVisible(true) end)
    SilverUI.MobileButton=b
end
EnsureMobileButton()

-- ========= Loader (simple Luna-like) =========
local function ShowLoader(appName, subtitle, duration)
    duration = duration or 1.2
    local sg = Instance.new("ScreenGui")
    sg.Name="SilverUILoader"
    sg.IgnoreGuiInset = true
    sg.Parent = mountParent()

    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.fromScale(1,1)
    bg.BackgroundColor3 = THEME.bg
    bg.BorderSizePixel=0

    local panel = Instance.new("Frame", bg)
    panel.Size = UDim2.new(0,math.clamp(getViewport().X*0.36,300,420),0,150)
    panel.Position = UDim2.new(0.5,-panel.Size.X.Offset/2,0.5,-75)
    panel.BackgroundColor3 = THEME.panel
    panel.BorderSizePixel=0
    panel.BackgroundTransparency = 1
    corner(panel,16); stroke(panel,THEME.line,1)
    pad(panel,16)

    local logo = Instance.new("Frame", panel)
    logo.Size = UDim2.new(0,34,0,34)
    logo.BackgroundColor3 = THEME.accent
    logo.BorderSizePixel=0
    logo.BackgroundTransparency = 1
    corner(logo,10)

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1,-50,0,26)
    title.Position = UDim2.new(0,50,0,0)
    title.BackgroundTransparency=1
    title.Text = appName or "Silver UI"
    title.Font = Enum.Font.GothamBold
    title.TextSize=20
    title.TextColor3=THEME.text
    title.TextXAlignment=Enum.TextXAlignment.Left
    title.TextTransparency = 1

    local sub = Instance.new("TextLabel", panel)
    sub.Size = UDim2.new(1,-50,0,20)
    sub.Position = UDim2.new(0,50,0,24)
    sub.BackgroundTransparency=1
    sub.Text = subtitle or "Loading..."
    sub.Font = Enum.Font.Gotham
    sub.TextSize=14
    sub.TextColor3=THEME.dim
    sub.TextXAlignment=Enum.TextXAlignment.Left
    sub.TextTransparency = 1

    local bar = Instance.new("Frame", panel)
    bar.Size = UDim2.new(1,0,0,10)
    bar.Position = UDim2.new(0,0,1,-20)
    bar.BackgroundColor3 = THEME.panel2
    bar.BorderSizePixel=0
    bar.BackgroundTransparency = 1
    corner(bar,8); stroke(bar,THEME.line,1)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = THEME.accent
    fill.BorderSizePixel=0
    corner(fill,8)

    tween(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency=0})
    tween(logo,  TweenInfo.new(0.22), {BackgroundTransparency=0})
    tween(title, TweenInfo.new(0.26), {TextTransparency=0})
    tween(sub,   TweenInfo.new(0.28), {TextTransparency=0})
    tween(bar,   TweenInfo.new(0.28), {BackgroundTransparency=0})
    tween(fill,  TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,0)})

    task.wait(duration+0.05)
    tween(bg, TweenInfo.new(0.22), {BackgroundTransparency = 1})
    tween(panel, TweenInfo.new(0.18), {BackgroundTransparency = 1})
    task.wait(0.22)
    sg:Destroy()
end

-- ========= Window class =========
local Win = {}; Win.__index = Win

local function mkSection(parent, h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,h or 44)
    f.BackgroundColor3 = THEME.panel2
    f.BorderSizePixel=0
    f.Parent = parent
    corner(f,10); stroke(f,THEME.line,1); pad(f,10)
    return f
end

function Win:_switchTo(idx)
    if self.ActiveIndex == idx then return end
    local newPage = self.Pages[idx]; if not newPage then return end
    local oldPage = self.ActiveIndex and self.Pages[self.ActiveIndex]

    -- hide old
    if oldPage then
        oldPage.Visible = false
    end

    -- slide+fade in new (simple: slide from slight offset)
    newPage.Visible = true
    newPage.Position = UDim2.new(0,8,0,0)
    newPage.BackgroundTransparency = 1
    tween(newPage, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)})
    tween(newPage, TweenInfo.new(0.12), {BackgroundTransparency = 1}) -- (page bg is transparent; we just use motion)

    self.ActiveIndex = idx

    -- button state
    for i,btn in ipairs(self._tabButtons) do
        btn.TextColor3 = (i==idx) and THEME.text or THEME.dim
        btn.BackgroundTransparency = (i==idx) and 0.06 or 1
    end
end

function Win:CreateTab(name, icon)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,36)
    b.BackgroundTransparency=1
    b.Text = (icon and (icon.."  ") or "")..name
    b.Font=Enum.Font.Gotham
    b.TextColor3=THEME.dim
    b.TextXAlignment=Enum.TextXAlignment.Left
    b.TextSize=14
    b.AutoButtonColor=false
    b.Parent = self.TabList

    b.MouseEnter:Connect(function()
        if b.TextColor3==THEME.dim then tween(b,TweenInfo.new(0.1),{BackgroundTransparency=0.2}) end
    end)
    b.MouseLeave:Connect(function()
        if b.TextColor3==THEME.dim then tween(b,TweenInfo.new(0.1),{BackgroundTransparency=1}) end
    end)

    local page = Instance.new("ScrollingFrame")
    page.Name = name.."_Page"
    page.Size = UDim2.new(1,0,1,0)
    page.Visible=false
    page.BackgroundTransparency=1
    page.BorderSizePixel=0
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarImageColor3 = THEME.line
    page.ScrollBarThickness = 6
    page.ClipsDescendants = true
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    table.insert(self.Pages, page)
    table.insert(self._tabButtons, b)

    local thisIndex = #self.Pages
    b.Activated:Connect(function()
        self:_switchTo(thisIndex)
    end)

    if not self.ActiveIndex then
        self:_switchTo(thisIndex)
    end

    -- Tab API
    local T = {}
    function T:Button(o) return self._w:_elButton(page,o) end
    function T:Toggle(o) return self._w:_elToggle(page,o) end
    function T:Slider(o) return self._w:_elSlider(page,o) end
    function T:Dropdown(o) return self._w:_elDropdown(page,o) end
    function T:Input(o) return self._w:_elInput(page,o) end
    function T:ColorPicker(o) return self._w:_elColor(page,o) end
    function T:Keybind(o) return self._w:_elKeybind(page,o) end
    T._w = self
    return T
end

-- Elements
function Win:_elButton(parent, o)
    o=o or {}
    local f = mkSection(parent,44)
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(1,0,1,0)
    b.BackgroundTransparency=1
    b.TextXAlignment=Enum.TextXAlignment.Left
    b.TextColor3=THEME.text
    b.Font=Enum.Font.GothamMedium
    b.TextSize=14
    b.Text = o.Text or "Button"
    b.AutoButtonColor=false

    b.MouseEnter:Connect(function() tween(f,TweenInfo.new(0.12),{BackgroundColor3=THEME.panel}) end)
    b.MouseLeave:Connect(function() tween(f,TweenInfo.new(0.12),{BackgroundColor3=THEME.panel2}) end)
    b.Activated:Connect(function()
        tween(f,TweenInfo.new(0.06),{BackgroundColor3=THEME.panel})
        task.delay(0.08,function() tween(f,TweenInfo.new(0.12),{BackgroundColor3=THEME.panel2}) end)
        if o.Callback then task.spawn(o.Callback) end
    end)

    return b
end

function Win:_elToggle(parent,o)
    o=o or {}
    local f=mkSection(parent,44)

    local lbl=Instance.new("TextLabel",f)
    lbl.Size=UDim2.new(1,-54,1,0)
    lbl.BackgroundTransparency=1
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextColor3=THEME.text
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=14
    lbl.Text=o.Text or "Toggle"

    local t=Instance.new("TextButton",f)
    t.Size=UDim2.new(0,40,0,24)
    t.Position=UDim2.new(1,-42,0.5,-12)
    t.Text=""
    t.AutoButtonColor=false
    t.BackgroundColor3=Color3.fromRGB(70,70,76)
    corner(t,12)

    local knob=Instance.new("Frame",t)
    knob.Size=UDim2.new(0,20,0,20)
    knob.Position=UDim2.new(0,2,0.5,-10)
    knob.BackgroundColor3=THEME.bg
    knob.BorderSizePixel=0
    corner(knob,10)

    local state = o.Default or false
    local function apply()
        tween(t,TweenInfo.new(0.15),{BackgroundColor3 = state and THEME.ok or Color3.fromRGB(70,70,76)})
        tween(knob,TweenInfo.new(0.15),{Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)})
    end
    apply()
    t.Activated:Connect(function()
        state=not state; apply(); if o.Callback then task.spawn(o.Callback,state) end
    end)
    return {Set=function(_,v) state=v; apply() end, Get=function() return state end}
end

function Win:_elSlider(parent,o)
    o=o or {}
    local min,max=o.Min or 0,o.Max or 100
    local val = math.clamp(o.Default or min,min,max)

    local f=mkSection(parent,56)
    local lbl=Instance.new("TextLabel",f)
    lbl.Size=UDim2.new(1,0,0,20)
    lbl.BackgroundTransparency=1
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextColor3=THEME.text
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=14
    lbl.Text=o.Text or "Slider"

    local bar=Instance.new("Frame",f)
    bar.Size=UDim2.new(1,-2,0,16)
    bar.Position=UDim2.new(0,1,1,-22)
    bar.BackgroundColor3=THEME.panel
    bar.BorderSizePixel=0
    corner(bar,8); stroke(bar,THEME.line,1)

    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
    fill.BackgroundColor3=THEME.accent
    fill.BorderSizePixel=0
    corner(fill,8)

    local txt=Instance.new("TextLabel",bar)
    txt.Size=UDim2.new(0,120,1,0)
    txt.BackgroundTransparency=1
    txt.TextColor3=THEME.text
    txt.Font=Enum.Font.Gotham
    txt.TextSize=12
    txt.Text=("%d%s"):format(val, o.Suffix and (" "..o.Suffix) or "")

    local dragging=false
    local function setFromX(x)
        local p = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        val = math.floor(min + p*(max-min))
        fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
        txt.Text=("%d%s"):format(val, o.Suffix and (" "..o.Suffix) or "")
        if o.Callback then o.Callback(val) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; setFromX(input.Position.X) end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then setFromX(input.Position.X) end
    end)

    return {Set=function(_,v) val=math.clamp(v,min,max); fill.Size=UDim2.new((val-min)/(max-min),0,1,0); txt.Text=tostring(val) end, Get=function() return val end}
end

function Win:_elDropdown(parent,o)
    o=o or {}
    local list=o.Items or {}
    local current=o.Default or list[1]

    local f=mkSection(parent,44)
    local b=Instance.new("TextButton",f)
    b.Size=UDim2.new(1,0,1,0)
    b.BackgroundTransparency=1
    b.TextXAlignment=Enum.TextXAlignment.Left
    b.TextColor3=THEME.text
    b.Font=Enum.Font.Gotham
    b.TextSize=14
    b.Text=(o.Text or "Select")..": "..(current or "-")

    local drop=Instance.new("Frame",f)
    drop.Size=UDim2.new(1,0,0,0)
    drop.Position=UDim2.new(0,0,1,6)
    drop.BackgroundColor3=THEME.panel
    drop.BorderSizePixel=0
    drop.Visible=false
    corner(drop,10); stroke(drop,THEME.line,1); pad(drop,8)

    local ll=Instance.new("UIListLayout",drop); ll.Padding=UDim.new(0,6)

    local function populate()
        drop:ClearAllChildren(); corner(drop,10); stroke(drop,THEME.line,1); pad(drop,8); ll=Instance.new("UIListLayout",drop); ll.Padding=UDim.new(0,6)
        for _,it in ipairs(list) do
            local i=Instance.new("TextButton",drop)
            i.Size=UDim2.new(1,0,0,28)
            i.BackgroundColor3=THEME.panel2
            i.TextColor3=THEME.text
            i.Font=Enum.Font.Gotham
            i.TextSize=13
            i.Text=tostring(it)
            corner(i,8); stroke(i,THEME.line,1)
            i.Activated:Connect(function()
                current=it; b.Text=(o.Text or "Select")..": "..tostring(it); drop.Visible=false
                if o.Callback then o.Callback(current) end
            end)
        end
        task.wait()
        drop.Size=UDim2.new(1,0,0,#list*(28+6)+6)
    end
    populate()

    b.Activated:Connect(function() drop.Visible = not drop.Visible end)

    return {SetList=function(_,arr) list=arr; populate() end, Set=function(_,v) current=v; b.Text=(o.Text or "Select")..": "..tostring(v) end, Get=function() return current end}
end

function Win:_elInput(parent,o)
    o=o or {}
    local f=mkSection(parent,44)
    local tb=Instance.new("TextBox",f)
    tb.Size=UDim2.new(1,0,1,0)
    tb.BackgroundTransparency=1
    tb.TextXAlignment=Enum.TextXAlignment.Left
    tb.PlaceholderText = o.Placeholder or "Type here..."
    tb.Text = o.Default or ""
    tb.ClearTextOnFocus=false
    tb.TextColor3=THEME.text
    tb.Font=Enum.Font.Gotham
    tb.TextSize=14

    tb.FocusLost:Connect(function(enter)
        if o.Callback then o.Callback(tb.Text, enter) end
    end)

    return tb
end

function Win:_elColor(parent,o)
    o=o or {}
    local color=o.Default or Color3.fromRGB(255,0,0)
    local f=mkSection(parent,44)

    local lbl=Instance.new("TextLabel",f)
    lbl.Size=UDim2.new(1,-46,1,0)
    lbl.BackgroundTransparency=1
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextColor3=THEME.text
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=14
    lbl.Text=o.Text or "Color"

    local sw=Instance.new("TextButton",f)
    sw.Size=UDim2.new(0,34,0,24)
    sw.Position=UDim2.new(1,-36,0.5,-12)
    sw.BackgroundColor3=color
    sw.Text=""
    corner(sw,8); stroke(sw,THEME.line,1)

    local pop=Instance.new("Frame",f)
    pop.Size=UDim2.new(0,160,0,40)
    pop.Position=UDim2.new(1,-160,1,6)
    pop.BackgroundColor3=THEME.panel
    pop.Visible=false
    corner(pop,10); stroke(pop,THEME.line,1); pad(pop,8)

    local presets={Color3.fromRGB(255,0,0), Color3.fromRGB(0,200,120), Color3.fromRGB(0,170,255), Color3.fromRGB(255,200,0)}
    for i,c in ipairs(presets) do
        local b=Instance.new("TextButton",pop)
        b.Size=UDim2.new(0,30,1,0)
        b.Position=UDim2.new(0,(i-1)*36,0,0)
        b.Text=""
        b.BackgroundColor3=c
        corner(b,8); stroke(b,THEME.line,1)
        b.Activated:Connect(function() color=c; sw.BackgroundColor3=c; pop.Visible=false; if o.Callback then o.Callback(color) end end)
    end

    sw.Activated:Connect(function() pop.Visible=not pop.Visible end)

    return {Set=function(_,c) color=c; sw.BackgroundColor3=c end, Get=function() return color end}
end

function Win:_elKeybind(parent,o)
    o=o or {}
    local f=mkSection(parent,44)

    local lbl=Instance.new("TextLabel",f)
    lbl.Size=UDim2.new(1,-110,1,0)
    lbl.BackgroundTransparency=1
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextColor3=THEME.text
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=14
    lbl.Text=o.Text or "Keybind"

    local kb=Instance.new("TextButton",f)
    kb.Size=UDim2.new(0,90,0,28)
    kb.Position=UDim2.new(1,-94,0.5,-14)
    kb.Text=(o.Default and o.Default.Name) or "None"
    kb.TextColor3=THEME.text
    kb.Font=Enum.Font.Gotham
    kb.TextSize=13
    kb.BackgroundColor3=THEME.panel
    corner(kb,8); stroke(kb,THEME.line,1)

    local current=o.Default
    kb.Activated:Connect(function()
        kb.Text="Press..."
        local conn; conn=UIS.InputBegan:Connect(function(input,gpe)
            if gpe then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                current=input.KeyCode; kb.Text=current.Name
                conn:Disconnect()
            end
        end)
    end)

    UIS.InputBegan:Connect(function(input,gpe)
        if not gpe and current and input.KeyCode==current then
            if o.Callback then o.Callback() end
        end
    end)

    return {Get=function() return current end, Set=function(_,k) current=k; kb.Text=k and k.Name or "None" end}
end

-- ========= CreateWindow (responsive + animations) =========
function SilverUI:CreateWindow(o)
    o=o or {}
    if o.Loading ~= false then
        ShowLoader(o.LoadingTitle or (o.Name or "Silver UI"), o.LoadingSubtitle or "Loading UI...", o.LoadingDuration or 1.0)
    end

    local parent = mountParent()
    local sg=Instance.new("ScreenGui")
    sg.Name="SilverUIPro_"..tostring(math.random(1000,9999))
    sg.ResetOnSpawn=false
    sg.Parent=parent

    -- responsive size
    local vp = getViewport()
    local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
    local W = isMobile and math.clamp(math.floor(vp.X*0.9), 300, 520) or (o.Width or 720)
    local H = isMobile and math.clamp(math.floor(vp.Y*0.7), 240, 420) or (o.Height or 420)

    local main=Instance.new("Frame",sg)
    main.Size=UDim2.new(0,W,0,H)
    main.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
    main.BackgroundColor3=THEME.bg
    main.BorderSizePixel=0
    main.ClipsDescendants=false
    corner(main,14); stroke(main,THEME.line,1)

    -- top
    local top=Instance.new("Frame",main)
    top.Size=UDim2.new(1,0,0,44)
    top.BackgroundColor3=THEME.panel
    top.BorderSizePixel=0
    top.ClipsDescendants=true
    corner(top,14); pad(top,12)

    local title=Instance.new("TextLabel",top)
    title.Size=UDim2.new(1,-120,1,0)
    title.BackgroundTransparency=1
    title.TextXAlignment=Enum.TextXAlignment.Left
    title.TextColor3=THEME.text
    title.Font=Enum.Font.GothamBold
    title.TextSize=16
    title.Text=o.Name or "Silver UI Pro"

    local minB=Instance.new("TextButton",top)
    minB.Size=UDim2.new(0,32,0,28)
    minB.Position=UDim2.new(1,-76,0.5,-14)
    minB.Text="-"
    minB.TextColor3=THEME.text
    minB.BackgroundColor3=THEME.panel2
    minB.AutoButtonColor=false
    corner(minB,10); stroke(minB,THEME.line,1)
    minB.MouseEnter:Connect(function() tween(minB,TweenInfo.new(0.12),{BackgroundColor3=THEME.panel}) end)
    minB.MouseLeave:Connect(function() tween(minB,TweenInfo.new(0.12),{BackgroundColor3=THEME.panel2}) end)

    local closeB=Instance.new("TextButton",top)
    closeB.Size=UDim2.new(0,32,0,28)
    closeB.Position=UDim2.new(1,-36,0.5,-14)
    closeB.Text="X"
    closeB.TextColor3=THEME.text
    closeB.BackgroundColor3=THEME.panel2 -- uyumlu, kırmızı değil
    closeB.AutoButtonColor=false
    corner(closeB,10); stroke(closeB,THEME.line,1)
    closeB.MouseEnter:Connect(function() tween(closeB,TweenInfo.new(0.12),{BackgroundColor3=THEME.panel}) end)
    closeB.MouseLeave:Connect(function() tween(closeB,TweenInfo.new(0.12),{BackgroundColor3=THEME.panel2}) end)

    -- left tabs
    local tabs=Instance.new("Frame",main)
    tabs.Size=UDim2.new(0, math.min(184, math.max(140, math.floor(W*0.28))), 1, -(44+12))
    tabs.Position=UDim2.new(0,8,0,44+8)
    tabs.BackgroundColor3=THEME.panel
    tabs.BorderSizePixel=0
    tabs.ClipsDescendants=true
    corner(tabs,12); stroke(tabs,THEME.line,1); pad(tabs,8)
    local tlist=Instance.new("UIListLayout",tabs); tlist.Padding=UDim.new(0,6)

    -- content
    local content=Instance.new("Frame",main)
    local leftW = tabs.Size.X.Offset + 16
    content.Size=UDim2.new(1,-(leftW+8),1,-(44+16))
    content.Position=UDim2.new(0,leftW+8,0,44+8)
    content.BackgroundColor3=THEME.panel
    content.BorderSizePixel=0
    content.ClipsDescendants=true
    corner(content,12); stroke(content,THEME.line,1); pad(content,8)

    -- open anim
    main.BackgroundTransparency=1; top.BackgroundTransparency=1; tabs.BackgroundTransparency=1; content.BackgroundTransparency=1
    tween(main,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0})
    task.delay(0.02,function()
        tween(top,TweenInfo.new(0.14),{BackgroundTransparency=0})
        tween(tabs,TweenInfo.new(0.14),{BackgroundTransparency=0})
        tween(content,TweenInfo.new(0.14),{BackgroundTransparency=0})
    end)

    local WN=setmetatable({
        Gui=sg, Main=main, Top=top, TabList=tabs, Content=content,
        Pages={}, _tabButtons={}, ActiveIndex=nil
    }, Win)

    -- minimize / close
    local minimized=false
    minB.Activated:Connect(function()
        minimized = not minimized
        if minimized then
            content.Visible=false; tabs.Visible=false
            tween(main,TweenInfo.new(0.16),{Size=UDim2.new(0,W,0,60)})
        else
            tween(main,TweenInfo.new(0.16),{Size=UDim2.new(0,W,0,H)})
            task.delay(0.02,function() tabs.Visible=true; content.Visible=true end)
        end
    end)

    closeB.Activated:Connect(function()
        tween(main,TweenInfo.new(0.16),{BackgroundTransparency=1})
        task.wait(0.16)
        SetVisible(false)
    end)

    -- drag + clamp
    MakeDraggable(main, top)

    -- keep clamped on resize/rotation
    local rsConn
    rsConn = RunS.RenderStepped:Connect(function()
        if not WN or not WN.Main or not WN.Main.Parent then
            rsConn:Disconnect(); return
        end
        local vp = getViewport()
        local pos = WN.Main.Position
        local size = WN.Main.AbsoluteSize
        local x = math.clamp(pos.X.Offset, 0, math.max(0, vp.X - size.X))
        local y = math.clamp(pos.Y.Offset, 0, math.max(0, vp.Y - size.Y))
        WN.Main.Position = UDim2.new(pos.X.Scale, x, pos.Y.Scale, y)
    end)

    table.insert(SilverUI._wins, WN)
    return WN
end

-- ======= Public return =======
return SilverUI
