-- SilverUI Pro+  |  by tuffslvr (you)
-- Premium Roblox UI Library for Executor usage
-- Features: Loading screen, Drag, RightShift toggle, Mobile show button, Minimize/Close anim,
-- Tabs + Sections, Button/Toggle/Slider/TextBox/Keybind/Dropdown/ColorPicker/Label/Paragraph/Divider/Progress,
-- Notifications (toasts), Tooltips, Config Save/Load (writefile), Smooth tweens, Touch support

--////////////////////////////////////////////////////////////////////

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

local function t(o,ti,pr) TweenService:Create(o,ti,pr):Play() end
local function newTween(time,ease,dir) return TweenInfo.new(time or .25, ease or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out) end
local function round(n,dec) dec = dec or 0 local m = 10^dec return math.floor(n*m+0.5)/m end
local function isTouch() return UIS.TouchEnabled and not UIS.KeyboardEnabled end
local function clamp(n,a,b) if n<a then return a elseif n>b then return b else return n end end

-- Safe file helpers (executor)
local function canfs() return writefile and readfile and isfile end
local function saferead(p) if canfs() and isfile(p) then return readfile(p) end end
local function safewrite(p,c) if canfs() then writefile(p,c) end end

-- Theme
local Theme = {
    Bg = Color3.fromRGB(18,18,19),
    Layer = Color3.fromRGB(24,24,26),
    Card = Color3.fromRGB(28,28,32),
    Stroke = Color3.fromRGB(45,45,50),
    Text = Color3.fromRGB(230,230,235),
    SubText = Color3.fromRGB(170,170,178),
    Accent = Color3.fromRGB(120, 140, 255),
    Accent2 = Color3.fromRGB(90, 110, 240),
    Good = Color3.fromRGB(52,199,89),
    Warn = Color3.fromRGB(255, 200, 87),
    Bad  = Color3.fromRGB(255, 85, 85)
}

-- Rounded + Stroke util
local function style(container, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = container
    local s = Instance.new("UIStroke")
    s.Color = Theme.Stroke
    s.Thickness = 1
    s.Transparency = .25
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = container
    return c,s
end

-- Padding + List util
local function vlist(parent, pad)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop = UDim.new(0,8)
    p.PaddingBottom = UDim.new(0,8)
    p.PaddingLeft = UDim.new(0,10)
    p.PaddingRight = UDim.new(0,10)
    local l = Instance.new("UIListLayout", parent)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0,pad or 8)
    return p,l
end

-- Toasts
local function makeToaster(root)
    local Toasts = Instance.new("Frame")
    Toasts.Name = "Toasts"
    Toasts.BackgroundTransparency = 1
    Toasts.Size = UDim2.new(1, -20, 1, -20)
    Toasts.Position = UDim2.new(0, 10, 0, 10)
    Toasts.AnchorPoint = Vector2.new(0,0)
    Toasts.Parent = root

    local layout = Instance.new("UIListLayout", Toasts)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom

    local function notify(cfg)
        cfg = cfg or {}
        local msg = tostring(cfg.Text or "Notification")
        local kind = (cfg.Kind or "info")
        local dur = cfg.Duration or 3

        local color = Theme.Accent
        if kind=="success" then color=Theme.Good elseif kind=="warn" then color=Theme.Warn elseif kind=="error" then color=Theme.Bad end

        local card = Instance.new("Frame")
        card.BackgroundColor3 = Theme.Card
        card.Size = UDim2.new(0, 260, 0, 40)
        card.AnchorPoint = Vector2.new(1,1)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.Parent = Toasts
        style(card, 10)

        local bar = Instance.new("Frame", card)
        bar.BackgroundColor3 = color
        bar.Size = UDim2.new(0,4,1,0)
        bar.BorderSizePixel = 0

        local txt = Instance.new("TextLabel", card)
        txt.BackgroundTransparency = 1
        txt.Text = msg
        txt.TextWrapped = true
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 14
        txt.TextColor3 = Theme.Text
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.AutomaticSize = Enum.AutomaticSize.Y
        txt.Size = UDim2.new(1, -16, 0, 0)
        txt.Position = UDim2.new(0, 12, 0, 8)

        card.BackgroundTransparency = 1
        bar.Size = UDim2.new(0,0,1,0)
        t(card, newTween(.25), {BackgroundTransparency = 0})
        t(bar, newTween(.3), {Size = UDim2.new(0,4,1,0)})

        task.spawn(function()
            task.wait(dur)
            t(card, newTween(.2), {BackgroundTransparency = 1})
            task.wait(.2)
            card:Destroy()
        end)
    end

    return notify
end

-- Tooltip
local function attachTooltip(inst, text, ScreenGui)
    local tip = Instance.new("TextLabel")
    tip.BackgroundColor3 = Theme.Card
    tip.TextColor3 = Theme.SubText
    tip.BorderSizePixel = 0
    tip.Visible = false
    tip.ZIndex = 1000
    tip.Text = text
    tip.Font = Enum.Font.Gotham
    tip.TextSize = 12
    tip.AutomaticSize = Enum.AutomaticSize.XY
    tip.Parent = ScreenGui
    style(tip, 6)
    local pad = Instance.new("UIPadding", tip)
    pad.PaddingTop = UDim.new(0,6); pad.PaddingBottom = UDim.new(0,6); pad.PaddingLeft = UDim.new(0,8); pad.PaddingRight = UDim.new(0,8)

    local con1, con2
    con1 = inst.MouseEnter:Connect(function()
        tip.Visible = true
    end)
    con2 = inst.MouseLeave:Connect(function()
        tip.Visible = false
    end)
    inst.MouseMoved:Connect(function(x,y)
        tip.Position = UDim2.fromOffset(x+12,y+12)
    end)
end

--////////////////////////////////////////////////////////////////////

local Silver = {}
Silver.__index = Silver

function Silver:Destroy() if self.ScreenGui then self.ScreenGui:Destroy() end end

-- Save system
function Silver:_save()
    if not self.Config or not self.Config.ConfigurationSaving or not self.Config.ConfigurationSaving.Enabled then return end
    local folder = self.Config.ConfigurationSaving.FolderName or "SilverUI"
    local file = (self.Config.ConfigurationSaving.FileName or "config")..".json"
    local path = folder.."/"..file
    local tbl = { values = self._values }
    local ok, data = pcall(function() return game:GetService("HttpService"):JSONEncode(tbl) end)
    if ok then
        if canfs() then
            if not isfile(folder) then makefolder(folder) end
            safewrite(path, data)
        end
    end
end
function Silver:_load()
    if not self.Config or not self.Config.ConfigurationSaving or not self.Config.ConfigurationSaving.Enabled then return end
    local folder = self.Config.ConfigurationSaving.FolderName or "SilverUI"
    local file = (self.Config.ConfigurationSaving.FileName or "config")..".json"
    local path = folder.."/"..file
    local content = saferead(path)
    if not content then return end
    local ok, tbl = pcall(function() return game:GetService("HttpService"):JSONDecode(content) end)
    if ok and tbl and tbl.values then
        for key,val in pairs(tbl.values) do
            self._values[key] = val
            -- element varsa UI'yi güncelle
            local el = self._elements[key]
            if el and el._apply then el:_apply(val) end
        end
    end
end

-- CreateWindow
function Silver:CreateWindow(cfg)
    self.Config = cfg or {}
    self._values = {}
    self._elements = {}

    local title = self.Config.Title or "Silver UI Pro+"
    local size = self.Config.Size or UDim2.fromOffset(680, 420)
    local keybind = self.Config.Keybind or Enum.KeyCode.RightShift
    local mobileButton = (self.Config.MobileButton ~= false)

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SilverUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    self.ScreenGui = ScreenGui

    -- Loading screen (soft)
    do
        local load = Instance.new("Frame", ScreenGui)
        load.Size = UDim2.fromScale(1,1)
        load.BackgroundColor3 = Theme.Bg
        load.BorderSizePixel = 0
        local label = Instance.new("TextLabel", load)
        label.Text = "Silver UI is loading…"
        label.Font = Enum.Font.GothamBold
        label.TextSize = 20
        label.TextColor3 = Theme.Text
        label.BackgroundTransparency = 1
        label.AnchorPoint = Vector2.new(.5,.5)
        label.Position = UDim2.fromScale(.5,.5)
        label.Size = UDim2.fromOffset(320,40)

        local bar = Instance.new("Frame", load)
        bar.BackgroundColor3 = Theme.Layer
        bar.BorderSizePixel = 0
        bar.AnchorPoint = Vector2.new(.5,0)
        bar.Position = UDim2.new(.5,0,.5,28)
        bar.Size = UDim2.fromOffset(320,6)
        style(bar, 999)
        local fill = Instance.new("Frame", bar)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Size = UDim2.fromScale(0,1)
        style(fill, 999)

        t(fill, newTween(1.2, Enum.EasingStyle.Sine), {Size = UDim2.fromScale(1,1)})
        task.wait(1.25)
        t(load, newTween(.25), {BackgroundTransparency = 1})
        task.wait(.2)
        load:Destroy()
    end

    -- Main Window
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Window"
    Main.Size = size
    Main.Position = UDim2.fromScale(.5,.5)
    Main.AnchorPoint = Vector2.new(.5,.5)
    Main.BackgroundColor3 = Theme.Layer
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    style(Main, 16)

    -- drop shadow
    local shadow = Instance.new("ImageLabel", Main)
    shadow.ZIndex = -1
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084"
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24,24,276,276)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.ImageTransparency = .4

    -- topbar
    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1,0,0,40)
    Top.BackgroundColor3 = Theme.Card
    Top.BorderSizePixel = 0
    style(Top, 16)

    local Title = Instance.new("TextLabel", Top)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0,16,0,0)

    local BtnHolder = Instance.new("Frame", Top)
    BtnHolder.BackgroundTransparency = 1
    BtnHolder.AnchorPoint = Vector2.new(1,0)
    BtnHolder.Position = UDim2.new(1,-8,0,6)
    BtnHolder.Size = UDim2.fromOffset(88,28)

    local UIList = Instance.new("UIListLayout", BtnHolder)
    UIList.FillDirection = Enum.FillDirection.Horizontal
    UIList.Padding = UDim.new(0,6)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right

    local function topBtn(txt, tip)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(36,28)
        b.Text = txt
        b.TextColor3 = Theme.Text
        b.TextSize = 18
        b.Font = Enum.Font.GothamBold
        b.BackgroundColor3 = Theme.Layer
        b.AutoButtonColor = false
        b.Parent = BtnHolder
        style(b, 8)
        attachTooltip(b, tip, ScreenGui)
        b.MouseEnter:Connect(function() t(b, newTween(.15), {BackgroundColor3 = Theme.Card}) end)
        b.MouseLeave:Connect(function() t(b, newTween(.15), {BackgroundColor3 = Theme.Layer}) end)
        return b
    end

    local MinBtn = topBtn("–","Minimize")
    local CloseBtn = topBtn("✕","Close")

    -- Left tabs
    local Left = Instance.new("Frame", Main)
    Left.Size = UDim2.new(0,170,1,-48)
    Left.Position = UDim2.new(0,8,0,44)
    Left.BackgroundColor3 = Theme.Card
    Left.BorderSizePixel = 0
    style(Left, 12)
    vlist(Left,6)

    -- Right content
    local Right = Instance.new("Frame", Main)
    Right.Size = UDim2.new(1,-186,1,-48)
    Right.Position = UDim2.new(0,178,0,44)
    Right.BackgroundTransparency = 1
    Right.Parent = Main

    local PageContainer = Instance.new("Frame", Right)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Size = UDim2.fromScale(1,1)
    PageContainer.Parent = Right

    -- tabs folder
    local PagesFolder = Instance.new("Folder", PageContainer)

    -- animations in
    Main.Size = UDim2.fromOffset(0,0)
    t(Main, newTween(.25), {Size = size})

    -- drag (topbar only)
    do
        local dragging, start, startPos
        Top.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging = true; start = i.Position; startPos = Main.Position
                i.Changed:Connect(function()
                    if i.UserInputState==Enum.UserInputState.End then dragging=false end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d = i.Position - start
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    -- minimize/close logic
    MinBtn.MouseButton1Click:Connect(function()
        if Main.Visible then
            t(Main, newTween(.2), {Size = UDim2.fromOffset(size.X.Offset, 40)})
            task.wait(.2)
            Right.Visible=false; Left.Visible=false
        else
            Right.Visible=true; Left.Visible=true
            t(Main, newTween(.2), {Size = size})
        end
        Main.Visible = true
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        t(Main, newTween(.2), {Size = UDim2.fromOffset(0,0)})
        task.wait(.22)
        self:Destroy()
    end)

    -- RightShift toggle + mobile button
    UIS.InputBegan:Connect(function(i,gpe)
        if not gpe and i.KeyCode==keybind then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    if mobileButton and isTouch() then
        local m = Instance.new("TextButton", ScreenGui)
        m.Text = "Show Silver"
        m.TextSize = 14
        m.Font = Enum.Font.GothamBold
        m.TextColor3 = Theme.Text
        m.Size = UDim2.fromOffset(130,40)
        m.Position = UDim2.new(0,12,1,-52)
        m.BackgroundColor3 = Theme.Card
        style(m, 10)
        m.MouseButton1Click:Connect(function()
            ScreenGui.Enabled = not ScreenGui.Enabled
        end)
        -- draggable mobile btn
        local dr=false,st,sp
        m.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dr=true; st=i.Position; sp=m.Position end end)
        UIS.InputChanged:Connect(function(i)
            if dr and i.UserInputType==Enum.UserInputType.Touch then
                local d = i.Position-st
                m.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
    end

    -- toaster
    self.Notify = makeToaster(ScreenGui)

    -- Tab create
    self._tabs = {}
    function self:AddTab(tab)
        tab = tab or {}
        local title = tab.Title or "Tab"
        local iconText = tab.IconText -- optional glyph/emoji when id yok
        local iconId = tab.Icon -- optional Roblox asset id (string/number)

        local btn = Instance.new("TextButton")
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.Size = UDim2.new(1,-16,0,40)
        btn.BackgroundColor3 = Theme.Layer
        btn.Parent = Left
        style(btn, 10)

        local lpad = Instance.new("UIPadding", btn)
        lpad.PaddingLeft = UDim.new(0,10); lpad.PaddingRight = UDim.new(0,10)

        local icon
        if iconId then
            icon = Instance.new("ImageLabel", btn)
            icon.BackgroundTransparency = 1
            icon.Size = UDim2.fromOffset(18,18)
            icon.Position = UDim2.new(0,8,0.5,-9)
            icon.Image = tostring(iconId)
        else
            icon = Instance.new("TextLabel", btn)
            icon.BackgroundTransparency = 1
            icon.Size = UDim2.fromOffset(18,18)
            icon.Position = UDim2.new(0,8,0.5,-9)
            icon.Text = iconText or "●"
            icon.Font = Enum.Font.GothamBold
            icon.TextSize = 14
            icon.TextColor3 = Theme.SubText
        end

        local name = Instance.new("TextLabel", btn)
        name.BackgroundTransparency = 1
        name.Text = title
        name.Font = Enum.Font.GothamMedium
        name.TextSize = 14
        name.TextColor3 = Theme.Text
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Size = UDim2.new(1,-40,1,0)
        name.Position = UDim2.new(0,32,0,0)

        btn.MouseEnter:Connect(function() t(btn,newTween(.12),{BackgroundColor3=Theme.Card}) end)
        btn.MouseLeave:Connect(function() t(btn,newTween(.12),{BackgroundColor3=Theme.Layer}) end)

        local page = Instance.new("ScrollingFrame", PagesFolder)
        page.Visible = false
        page.BackgroundTransparency = 1
        page.Size = UDim2.fromScale(1,1)
        page.ScrollBarThickness = 4
        local pad, list = vlist(page, 8)

        -- Section builder inside tab
        local TabAPI = {}
        function TabAPI:AddSection(titleTxt)
            local sec = Instance.new("Frame", page)
            sec.BackgroundColor3 = Theme.Card
            sec.Size = UDim2.new(1,-0,0,48)
            sec.AutomaticSize = Enum.AutomaticSize.Y
            style(sec, 12)
            local spad, slist = vlist(sec, 8)

            if titleTxt and titleTxt ~= "" then
                local head = Instance.new("TextLabel", sec)
                head.BackgroundTransparency = 1
                head.Text = titleTxt
                head.Font = Enum.Font.GothamBold
                head.TextSize = 14
                head.TextColor3 = Theme.Text
                head.Size = UDim2.new(1,0,0,18)
            end

            -- elements layout
            local function row(height) local r=Instance.new("Frame",sec) r.BackgroundColor3=Theme.Layer r.Size=UDim2.new(1,0,0,height or 36) r.BorderSizePixel=0 style(r,8) return r end

            local API = {}

            function API:AddLabel(text)
                local r = row(32)
                local l = Instance.new("TextLabel", r)
                l.BackgroundTransparency=1; l.Text=text or "Label"; l.Font=Enum.Font.GothamMedium; l.TextSize=14; l.TextColor3=Theme.Text
                l.TextXAlignment=Enum.TextXAlignment.Left; l.Size=UDim2.new(1,-12,1,0); l.Position=UDim2.new(0,12,0,0)
                return {Set=function(_,v) l.Text=tostring(v) end}
            end

            function API:AddParagraph(header, content)
                local r = row(58)
                local h = Instance.new("TextLabel", r)
                h.BackgroundTransparency=1; h.Text=header or "Paragraph"; h.Font=Enum.Font.GothamBold; h.TextSize=14; h.TextColor3=Theme.Text
                h.TextXAlignment=Enum.TextXAlignment.Left; h.Size=UDim2.new(1,-12,0,18); h.Position=UDim2.new(0,12,0,6)
                local c = Instance.new("TextLabel", r)
                c.BackgroundTransparency=1; c.Text=content or "Content"; c.Font=Enum.Font.Gotham; c.TextSize=13; c.TextColor3=Theme.SubText
                c.TextXAlignment=Enum.TextXAlignment.Left; c.Size=UDim2.new(1,-12,0,18); c.Position=UDim2.new(0,12,0,28); c.TextWrapped=true
                return {
                    SetHeader=function(_,v) h.Text=tostring(v) end,
                    SetText=function(_,v) c.Text=tostring(v) end
                }
            end

            function API:AddButton(cfg)
                cfg = cfg or {}
                local r = row(36)
                local b = Instance.new("TextButton", r)
                b.AutoButtonColor=false; b.Size=UDim2.new(1,-12,1,-8); b.Position=UDim2.new(0,6,0,4)
                b.Text = tostring(cfg.Title or "Button")
                b.Font=Enum.Font.GothamMedium; b.TextSize=14; b.TextColor3=Theme.Text
                b.BackgroundColor3 = Theme.Card; style(b,8)
                b.MouseEnter:Connect(function() t(b,newTween(.1),{BackgroundColor3=Theme.Layer}) end)
                b.MouseLeave:Connect(function() t(b,newTween(.1),{BackgroundColor3=Theme.Card}) end)
                b.MouseButton1Click:Connect(function()
                    if cfg.Callback then task.spawn(cfg.Callback) end
                end)
                if cfg.Tooltip then attachTooltip(b, cfg.Tooltip, ScreenGui) end
                return {
                    SetTitle=function(_,v) b.Text=tostring(v) end,
                    Click=function(_) if cfg.Callback then task.spawn(cfg.Callback) end end
                }
            end

            function API:AddToggle(cfg)
                cfg = cfg or {}; local key = cfg.Key; local def = (cfg.Default==true)
                self._values[key or ("toggle_"..tostring(math.random(1,99999)))] = def
                local r = row(36)
                local title = Instance.new("TextLabel", r)
                title.BackgroundTransparency=1; title.Text=tostring(cfg.Title or "Toggle")
                title.Font=Enum.Font.GothamMedium; title.TextSize=14; title.TextColor3=Theme.Text
                title.TextXAlignment=Enum.TextXAlignment.Left; title.Size=UDim2.new(1,-70,1,0); title.Position=UDim2.new(0,12,0,0)

                local sw = Instance.new("Frame", r)
                sw.AnchorPoint=Vector2.new(1,0.5); sw.Position=UDim2.new(1,-12,0.5,-10); sw.Size=UDim2.fromOffset(44,20)
                sw.BackgroundColor3=Theme.Layer; style(sw, 999)
                local dot = Instance.new("Frame", sw)
                dot.Size=UDim2.fromOffset(16,16); dot.Position=UDim2.new(0,2,0,2); dot.BackgroundColor3=Theme.SubText; style(dot,999)

                local function apply(v)
                    t(dot, newTween(.15), {Position = v and UDim2.new(1,-18,0,2) or UDim2.new(0,2,0,2), BackgroundColor3 = v and Theme.Good or Theme.SubText})
                    t(sw, newTween(.15), {BackgroundColor3 = v and Color3.fromRGB(32,40,32) or Theme.Layer})
                end
                apply(def)

                r.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        def = not def; apply(def)
                        if key then self._values[key]=def self:_save() end
                        if cfg.Callback then task.spawn(cfg.Callback, def) end
                    end
                end)
                return {Get=function() return def end, Set=function(_,v) def=not not v; apply(def); if key then self._values[key]=def self:_save() end end, _apply=apply}
            end

            function API:AddSlider(cfg)
                cfg = cfg or {}; local key = cfg.Key
                local min,max = cfg.Min or 0, cfg.Max or 100
                local value = clamp(cfg.Default or min, min, max)
                self._values[key or ("slider_"..tostring(math.random(1,99999)))] = value

                local r = row(44)
                local title = Instance.new("TextLabel", r)
                title.BackgroundTransparency=1; title.Text=tostring(cfg.Title or "Slider")
                title.Font=Enum.Font.GothamMedium; title.TextSize=13; title.TextColor3=Theme.Text
                title.TextXAlignment=Enum.TextXAlignment.Left; title.Size=UDim2.new(1,-12,0,16); title.Position=UDim2.new(0,12,0,6)

                local bar = Instance.new("Frame", r)
                bar.Size=UDim2.new(1,-24,0,8); bar.Position=UDim2.new(0,12,0,28); bar.BackgroundColor3=Theme.Layer; bar.BorderSizePixel=0; style(bar,999)
                local fill = Instance.new("Frame", bar)
                fill.Size=UDim2.fromScale((value-min)/(max-min),1); fill.BackgroundColor3=Theme.Accent; fill.BorderSizePixel=0; style(fill,999)

                local valtxt = Instance.new("TextLabel", r)
                valtxt.BackgroundTransparency=1; valtxt.Text = tostring(value)
                valtxt.Font=Enum.Font.Gotham; valtxt.TextSize=12; valtxt.TextColor3=Theme.SubText
                valtxt.Size=UDim2.new(0,60,0,14); valtxt.Position=UDim2.new(1,-70,0,6)

                local dragging=false
                local function setfrom(x)
                    local rel = clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    value = round(min + rel*(max-min), cfg.Decimals or 0)
                    fill.Size = UDim2.fromScale((value-min)/(max-min),1)
                    valtxt.Text = tostring(value)
                    if key then self._values[key]=value self:_save() end
                    if cfg.Callback then task.spawn(cfg.Callback, value) end
                end
                bar.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging=true; setfrom(i.Position.X)
                    end
                end)
                UIS.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        setfrom(i.Position.X)
                    end
                end)
                UIS.InputEnded:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then dragging=false end end)

                local function apply(v) value = clamp(v,min,max); fill.Size=UDim2.fromScale((value-min)/(max-min),1); valtxt.Text=tostring(value) end
                return {Get=function() return value end, Set=function(_,v) apply(v); if key then self._values[key]=value self:_save() end end, _apply=apply}
            end

            function API:AddTextbox(cfg)
                cfg = cfg or {}; local key = cfg.Key
                local def = tostring(cfg.Default or "")
                self._values[key or ("textbox_"..tostring(math.random(1,99999)))] = def

                local r = row(40)
                local box = Instance.new("TextBox", r)
                box.PlaceholderText = cfg.Placeholder or "Input"
                box.Text = def
                box.TextColor3 = Theme.Text
                box.PlaceholderColor3 = Theme.SubText
                box.Font = Enum.Font.Gotham
                box.TextSize = 14
                box.BackgroundColor3 = Theme.Layer
                box.Size = UDim2.new(1,-12,1,-8)
                box.Position = UDim2.new(0,6,0,4)
                style(box, 8)

                box.Focused:Connect(function() t(box,newTween(.1),{BackgroundColor3=Theme.Card}) end)
                box.FocusLost:Connect(function(enter)
                    t(box,newTween(.1),{BackgroundColor3=Theme.Layer})
                    def = box.Text
                    if key then self._values[key]=def self:_save() end
                    if cfg.Callback then task.spawn(cfg.Callback, def, enter) end
                end)

                local function apply(v) def=tostring(v or ""); box.Text=def end
                return {Get=function() return def end, Set=function(_,v) apply(v); if key then self._values[key]=def self:_save() end end, _apply=apply}
            end

            function API:AddKeybind(cfg)
                cfg = cfg or {}; local key = cfg.Key
                local current = cfg.Default or Enum.KeyCode.E
                self._values[key or ("keybind_"..tostring(math.random(1,99999)))] = tostring(current)

                local r = row(36)
                local name = Instance.new("TextLabel", r)
                name.BackgroundTransparency=1; name.Text=tostring(cfg.Title or "Keybind")
                name.Font=Enum.Font.GothamMedium; name.TextSize=14; name.TextColor3=Theme.Text
                name.TextXAlignment=Enum.TextXAlignment.Left; name.Size=UDim2.new(1,-70,1,0); name.Position=UDim2.new(0,12,0,0)

                local btn = Instance.new("TextButton", r)
                btn.Size=UDim2.fromOffset(56,24); btn.AnchorPoint=Vector2.new(1,0.5); btn.Position=UDim2.new(1,-12,0.5,0)
                btn.Text = current.Name or "Key"
                btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.TextColor3=Theme.Text
                btn.BackgroundColor3=Theme.Layer; btn.AutoButtonColor=false; style(btn,8)

                local listening=false
                btn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening=true; btn.Text="..."
                    local con; con = UIS.InputBegan:Connect(function(i,gpe)
                        if gpe then return end
                        if i.KeyCode==Enum.KeyCode.Unknown then return end
                        current = i.KeyCode; btn.Text = current.Name
                        listening=false; con:Disconnect()
                        if key then self._values[key]=current.Name self:_save() end
                        if cfg.Callback then task.spawn(cfg.Callback, current) end
                    end)
                end)

                UIS.InputBegan:Connect(function(i,gpe)
                    if not gpe and i.KeyCode==current then
                        if cfg.Pressed then task.spawn(cfg.Pressed) end
                    end
                end)

                local function apply(v)
                    if typeof(v)=="EnumItem" then current=v else current = Enum.KeyCode[v] or current end
                    btn.Text = current.Name
                end
                return {Get=function() return current end, Set=function(_,v) apply(v); if key then self._values[key]=current.Name self:_save() end end, _apply=apply}
            end

            function API:AddDropdown(cfg)
                cfg = cfg or {}; local key = cfg.Key
                local opts = cfg.Options or {"None"}
                local cur = cfg.Default or opts[1]
                self._values[key or ("dropdown_"..tostring(math.random(1,99999)))] = cur

                local r = row(36)
                local btn = Instance.new("TextButton", r)
                btn.AutoButtonColor=false; btn.Size=UDim2.new(1,-12,1,-8); btn.Position=UDim2.new(0,6,0,4)
                btn.Text = tostring(cfg.Title or "Dropdown").."  •  "..tostring(cur)
                btn.Font=Enum.Font.GothamMedium; btn.TextSize=14; btn.TextColor3=Theme.Text
                btn.BackgroundColor3 = Theme.Card; style(btn,8)

                local open=false
                local menu
                local function toggleList()
                    open = not open
                    if open then
                        menu = Instance.new("Frame", r)
                        menu.BackgroundColor3=Theme.Card; menu.BorderSizePixel=0; menu.Position=UDim2.new(0,6,1,-4); menu.Size=UDim2.new(1,-12,0,#opts*28+12)
                        style(menu,8)
                        vlist(menu,6)
                        for _,o in ipairs(opts) do
                            local it = Instance.new("TextButton", menu)
                            it.AutoButtonColor=false; it.Size=UDim2.new(1,0,0,24); it.Text=tostring(o)
                            it.Font=Enum.Font.Gotham; it.TextSize=13; it.TextColor3=Theme.Text
                            it.BackgroundColor3=Theme.Layer; style(it,8)
                            it.MouseEnter:Connect(function() t(it,newTween(.1),{BackgroundColor3=Theme.Card}) end)
                            it.MouseLeave:Connect(function() t(it,newTween(.1),{BackgroundColor3=Theme.Layer}) end)
                            it.MouseButton1Click:Connect(function()
                                cur = o; btn.Text = (cfg.Title or "Dropdown").."  •  "..tostring(cur)
                                if key then self._values[key]=cur self:_save() end
                                if cfg.Callback then task.spawn(cfg.Callback, cur) end
                                menu:Destroy(); open=false
                            end)
                        end
                    else
                        if menu then menu:Destroy() end
                    end
                end
                btn.MouseButton1Click:Connect(toggleList)

                local function apply(v) cur=v; btn.Text = (cfg.Title or "Dropdown").."  •  "..tostring(cur) end
                return {Get=function() return cur end, Set=function(_,v) apply(v); if key then self._values[key]=cur self:_save() end end, _apply=apply}
            end

            function API:AddColorPicker(cfg)
                cfg = cfg or {}; local key = cfg.Key
                local col = cfg.Default or Theme.Accent
                self._values[key or ("color_"..tostring(math.random(1,99999)))] = {col.R, col.G, col.B}

                local r = row(36)
                local name = Instance.new("TextLabel", r)
                name.BackgroundTransparency=1; name.Text=tostring(cfg.Title or "Color")
                name.Font=Enum.Font.GothamMedium; name.TextSize=14; name.TextColor3=Theme.Text
                name.TextXAlignment=Enum.TextXAlignment.Left; name.Size=UDim2.new(1,-70,1,0); name.Position=UDim2.new(0,12,0,0)

                local swatch = Instance.new("TextButton", r)
                swatch.Size=UDim2.fromOffset(40,24); swatch.AnchorPoint=Vector2.new(1,0.5); swatch.Position=UDim2.new(1,-12,0.5,0)
                swatch.Text=""; swatch.BackgroundColor3=col; style(swatch,8)

                local open=false
                local picker
                local function openPicker()
                    open = not open
                    if open then
                        picker = Instance.new("Frame", r)
                        picker.BackgroundColor3=Theme.Card; picker.BorderSizePixel=0; picker.Position=UDim2.new(1,-220,1,6); picker.Size=UDim2.fromOffset(210,110)
                        style(picker,10)
                        vlist(picker,6)

                        local r1 = Instance.new("TextLabel", picker); r1.BackgroundTransparency=1; r1.Text="R:"; r1.Font=Enum.Font.Gotham; r1.TextColor3=Theme.SubText; r1.Size=UDim2.new(0,18,0,16)
                        local rr = Instance.new("TextBox", picker); rr.Size=UDim2.new(1,-26,0,24); rr.Text=tostring(math.floor(col.R*255)); rr.Font=Enum.Font.Gotham; rr.TextColor3=Theme.Text; rr.BackgroundColor3=Theme.Layer; style(rr,8)

                        local g1 = Instance.new("TextLabel", picker); g1.BackgroundTransparency=1; g1.Text="G:"; g1.Font=Enum.Font.Gotham; g1.TextColor3=Theme.SubText; g1.Size=UDim2.new(0,18,0,16)
                        local gg = Instance.new("TextBox", picker); gg.Size=UDim2.new(1,-26,0,24); gg.Text=tostring(math.floor(col.G*255)); gg.Font=Enum.Font.Gotham; gg.TextColor3=Theme.Text; gg.BackgroundColor3=Theme.Layer; style(gg,8)

                        local b1 = Instance.new("TextLabel", picker); b1.BackgroundTransparency=1; b1.Text="B:"; b1.Font=Enum.Font.Gotham; b1.TextColor3=Theme.SubText; b1.Size=UDim2.new(0,18,0,16)
                        local bb = Instance.new("TextBox", picker); bb.Size=UDim2.new(1,-26,0,24); bb.Text=tostring(math.floor(col.B*255)); bb.Font=Enum.Font.Gotham; bb.TextColor3=Theme.Text; bb.BackgroundColor3=Theme.Layer; style(bb,8)

                        local function applyFromBoxes()
                            local rV = clamp(tonumber(rr.Text) or 0,0,255)/255
                            local gV = clamp(tonumber(gg.Text) or 0,0,255)/255
                            local bV = clamp(tonumber(bb.Text) or 0,0,255)/255
                            col = Color3.new(rV,gV,bV)
                            swatch.BackgroundColor3 = col
                            if key then self._values[key]={col.R,col.G,col.B} self:_save() end
                            if cfg.Callback then task.spawn(cfg.Callback, col) end
                        end
                        rr.FocusLost:Connect(applyFromBoxes)
                        gg.FocusLost:Connect(applyFromBoxes)
                        bb.FocusLost:Connect(applyFromBoxes)
                    else
                        if picker then picker:Destroy() end
                    end
                end
                swatch.MouseButton1Click:Connect(openPicker)

                local function apply(v)
                    if typeof(v)=="Color3" then col=v
                    elseif typeof(v)=="table" then col=Color3.new(v[1],v[2],v[3]) end
                    swatch.BackgroundColor3=col
                end
                return {Get=function() return col end, Set=function(_,v) apply(v); if key then self._values[key]={col.R,col.G,col.B} self:_save() end end, _apply=apply}
            end

            function API:AddDivider()
                local d = Instance.new("Frame", sec)
                d.BackgroundColor3=Theme.Stroke; d.BorderSizePixel=0
                d.Size=UDim2.new(1,0,0,1); d.LayoutOrder=10000
                return {}
            end

            function API:AddProgress(cfg)
                cfg = cfg or {}
                local val = clamp(cfg.Value or 0,0,100)
                local r = row(42)
                local title = Instance.new("TextLabel", r)
                title.BackgroundTransparency=1; title.Text=tostring(cfg.Title or "Progress")
                title.Font=Enum.Font.GothamMedium; title.TextSize=13; title.TextColor3=Theme.Text
                title.TextXAlignment=Enum.TextXAlignment.Left; title.Size=UDim2.new(1,-12,0,16); title.Position=UDim2.new(0,12,0,6)

                local bar = Instance.new("Frame", r)
                bar.Size=UDim2.new(1,-24,0,8); bar.Position=UDim2.new(0,12,0,28); bar.BackgroundColor3=Theme.Layer; bar.BorderSizePixel=0; style(bar,999)
                local fill = Instance.new("Frame", bar)
                fill.Size=UDim2.fromScale(val/100,1); fill.BackgroundColor3=Theme.Accent2; fill.BorderSizePixel=0; style(fill,999)
                local function setv(v) val=clamp(v,0,100); t(fill,newTween(.15),{Size=UDim2.fromScale(val/100,1)}) end
                return {Set=function(_,v) setv(v) end, Get=function() return val end}
            end

            function API:Notify(text, kind, dur)
                self.Owner.Notify({Text=text, Kind=kind, Duration=dur})
            end

            API.Owner = self
            return API
        end

        local function select()
            for _,p in ipairs(PagesFolder:GetChildren()) do p.Visible=false end
            for _,b in ipairs(Left:GetChildren()) do
                if b:IsA("TextButton") then t(b,newTween(.12),{BackgroundColor3=Theme.Layer}) end
            end
            page.Visible=true
            t(btn,newTween(.12),{BackgroundColor3=Theme.Card})
        end

        btn.MouseButton1Click:Connect(select)
        if #self._tabs==0 then task.defer(select) end

        table.insert(self._tabs, {Button=btn, Page=page})
        return TabAPI
    end

    -- load previous config if any
    self:_load()

    return self
end

-- Factory
local function New()
    local o = setmetatable({}, Silver)
    return o
end

return { CreateWindow = function(cfg) return New():CreateWindow(cfg) end }
