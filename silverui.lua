-- SilverUI Pro++ (Executor Friendly)
-- smooth, mobile/pc, theme+transparency, close/minimize, drag, tabs, elements, keybind toggle
-- by tuffslvr

local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local Players      = game:GetService("Players")
local HttpService  = game:GetService("HttpService")

local LP = Players.LocalPlayer
local function TI(t,e,d) return TweenInfo.new(t or .2, e or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out) end
local function tw(o,ti,pr) TweenService:Create(o,ti,pr):Play() end
local function clamp(n,a,b) return math.max(a,math.min(b,n)) end
local function isTouch() return UIS.TouchEnabled and not UIS.KeyboardEnabled end
local function canfs() return writefile and readfile and isfile end
local function saferead(p) if canfs() and isfile(p) then return readfile(p) end end
local function safewrite(p,c) if canfs() then writefile(p,c) end end

local DefaultTheme = {
  Bg          = Color3.fromRGB(18,19,22),
  Window      = Color3.fromRGB(26,27,31),
  Topbar      = Color3.fromRGB(30,31,36),
  Sidebar     = Color3.fromRGB(30,31,36),
  Card        = Color3.fromRGB(34,36,41),
  Stroke      = Color3.fromRGB(58,60,66),
  Text        = Color3.fromRGB(235,236,240),
  SubText     = Color3.fromRGB(165,170,180),
  Accent      = Color3.fromRGB(130,150,255),
  Accent2     = Color3.fromRGB(90,120,255),
  Good        = Color3.fromRGB(52,199,89),
  Warn        = Color3.fromRGB(255,200,87),
  Bad         = Color3.fromRGB(255,95,95),
  Transparency= 0.06, -- 0..1
  Blur        = 0     -- 0..30 (0 = kapalı)
}

local function corner(p, r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 10); return c end
local function stroke(p, col, th, tr) local s=Instance.new("UIStroke",p); s.Color=col; s.Thickness=th or 1; s.Transparency=tr or .35; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function vlist(p, pad)
  local padder=Instance.new("UIPadding",p)
  padder.PaddingTop=UDim.new(0,8); padder.PaddingBottom=UDim.new(0,8)
  padder.PaddingLeft=UDim.new(0,10); padder.PaddingRight=UDim.new(0,10)
  local l=Instance.new("UIListLayout",p); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Padding=UDim.new(0,pad or 8)
  return padder,l
end

local Silver, UI = {}, {}
Silver.__index = Silver

-- transparency tüm UI’ye yay
function Silver:_applyTransparency(root)
  local tr = self.Theme.Transparency or 0
  for _,g in ipairs(root:GetDescendants()) do
    if g:IsA("Frame") or g:IsA("TextLabel") or g:IsA("TextButton") or g:IsA("TextBox") or g:IsA("ImageLabel") then
      if g.BackgroundTransparency < 1 then
        g.BackgroundTransparency = clamp(g.BackgroundTransparency + tr, 0, 1)
      end
    end
  end
end

function Silver:SetTheme(t)
  for k,v in pairs(t or {}) do self.Theme[k]=v end
  if self._gui then
    -- ana renk güncellemeleri
    self.Window.BackgroundColor3 = self.Theme.Window
    self.Topbar.BackgroundColor3 = self.Theme.Topbar
    self.Sidebar.BackgroundColor3= self.Theme.Sidebar
    self:_applyTransparency(self._gui)
    -- blur
    if self.Theme.Blur and self.Theme.Blur>0 then
      if not self._blur then self._blur = Instance.new("BlurEffect"); self._blur.Parent = Lighting end
      self._blur.Size = self.Theme.Blur
    else
      if self._blur then self._blur:Destroy(); self._blur=nil end
    end
  end
end

-- config
function Silver:_save()
  local cfg = self.Config.ConfigurationSaving
  if not (cfg and cfg.Enabled) then return end
  local folder = cfg.FolderName or "SilverUI"
  local file   = (cfg.FileName or "config")..".json"
  if canfs() then if not isfolder(folder) then makefolder(folder) end
    safewrite(folder.."/"..file, HttpService:JSONEncode({v=self._values})) end
end
function Silver:_load()
  local cfg = self.Config.ConfigurationSaving
  if not (cfg and cfg.Enabled) then return end
  local folder = cfg.FolderName or "SilverUI"
  local file   = (cfg.FileName or "config")..".json"
  local data = saferead(folder.."/"..file)
  if not data then return end
  local ok, js = pcall(function() return HttpService:JSONDecode(data) end)
  if ok and js and js.v then
    for k,v in pairs(js.v) do self._values[k]=v end
  end
end

-- toast
local function makeToaster(root, theme)
  local holder=Instance.new("Frame", root)
  holder.Size=UDim2.new(1,-20,1,-20); holder.Position=UDim2.new(0,10,0,10)
  holder.BackgroundTransparency=1; holder.ZIndex=1000
  local lay=Instance.new("UIListLayout", holder)
  lay.HorizontalAlignment=Enum.HorizontalAlignment.Right
  lay.VerticalAlignment=Enum.VerticalAlignment.Bottom
  lay.Padding=UDim.new(0,8)
  return function(o)
    o=o or {}
    local txt=tostring(o.Text or "Notification")
    local dur=o.Duration or 2.6
    local col=theme.Accent
    if o.Kind=="success" then col=theme.Good elseif o.Kind=="warn" then col=theme.Warn elseif o.Kind=="error" then col=theme.Bad end
    local card=Instance.new("Frame", holder); card.Size=UDim2.fromOffset(260,40)
    card.BackgroundColor3=theme.Card; card.BorderSizePixel=0; card.BackgroundTransparency=1
    corner(card,10); stroke(card, theme.Stroke,1,.35)
    local bar=Instance.new("Frame", card); bar.BackgroundColor3=col; bar.BorderSizePixel=0; bar.Size=UDim2.fromOffset(4,0); bar.AnchorPoint=Vector2.new(0,1); bar.Position=UDim2.new(0,0,1,0)
    local lab=Instance.new("TextLabel", card); lab.BackgroundTransparency=1; lab.Font=Enum.Font.Gotham; lab.TextSize=13; lab.TextColor3=theme.Text
    lab.TextXAlignment=Enum.TextXAlignment.Left; lab.TextWrapped=true; lab.AutomaticSize=Enum.AutomaticSize.Y
    lab.Size=UDim2.new(1,-14,0,0); lab.Position=UDim2.new(0,10,0,8); lab.Text=txt
    tw(card,TI(.16),{BackgroundTransparency=0}); tw(bar,TI(.22),{Size=UDim2.fromOffset(4,card.AbsoluteSize.Y)})
    task.spawn(function() task.wait(dur); tw(card,TI(.16),{BackgroundTransparency=1}); task.wait(.16); card:Destroy() end)
  end
end

function UI:Notify(o, k, d) self._notify({Text=o,Kind=k,Duration=d}) end

function Silver:CreateWindow(cfg)
  self.Config = cfg or {}
  self.Theme  = table.clone(DefaultTheme)
  if self.Config.Theme then self:SetTheme(self.Config.Theme) end
  self._values, self._tabs, self._elements = {}, {}, {}

  local gui = Instance.new("ScreenGui")
  gui.Name="SilverUI"; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
  gui.Parent = (gethui and gethui()) or game.CoreGui
  self._gui = gui

  -- loading bar (kısa)
  do
    local ld=Instance.new("Frame", gui); ld.Size=UDim2.fromScale(1,1); ld.BackgroundColor3=self.Theme.Bg; ld.BorderSizePixel=0; ld.BackgroundTransparency=1
    local bar=Instance.new("Frame", ld); bar.AnchorPoint=Vector2.new(.5,.5); bar.Position=UDim2.fromScale(.5,.5); bar.Size=UDim2.fromOffset(280,6)
    bar.BackgroundColor3=self.Theme.Topbar; bar.BorderSizePixel=0; corner(bar,999); bar.BackgroundTransparency=.2
    local fill=Instance.new("Frame", bar); fill.Size=UDim2.fromScale(0,1); fill.BorderSizePixel=0; fill.BackgroundColor3=self.Theme.Accent; corner(fill,999)
    tw(fill,TI(0.9,Enum.EasingStyle.Sine),{Size=UDim2.fromScale(1,1)}); task.wait(.95); ld:Destroy()
  end

  -- window
  local win=Instance.new("Frame", gui)
  win.Size=self.Config.Size or UDim2.fromOffset(720,440)
  win.AnchorPoint=Vector2.new(.5,.5); win.Position=UDim2.fromScale(.5,.5)
  win.BackgroundColor3=self.Theme.Window; win.BorderSizePixel=0
  corner(win,14); stroke(win,self.Theme.Stroke,1,.35)
  self.Window=win

  -- shadow
  local sh=Instance.new("ImageLabel", win); sh.BackgroundTransparency=1
  sh.Image="rbxassetid://5028857084"; sh.ScaleType=Enum.ScaleType.Slice; sh.SliceCenter=Rect.new(24,24,276,276)
  sh.Size=UDim2.new(1,40,1,40); sh.Position=UDim2.new(0,-20,0,-20); sh.ImageTransparency=.55; sh.ZIndex=-1

  -- topbar
  local top=Instance.new("Frame", win); top.Size=UDim2.new(1,0,0,40); top.BackgroundColor3=self.Theme.Topbar; top.BorderSizePixel=0
  corner(top,14); self.Topbar=top
  local title=Instance.new("TextLabel", top); title.BackgroundTransparency=1; title.Text=self.Config.Title or "Silver UI Pro++"
  title.Font=Enum.Font.GothamBold; title.TextSize=16; title.TextColor3=self.Theme.Text
  title.TextXAlignment=Enum.TextXAlignment.Left; title.Size=UDim2.new(1,-128,1,0); title.Position=UDim2.new(0,14,0,0)

  -- top buttons
  local btnBar=Instance.new("Frame", top); btnBar.BackgroundTransparency=1
  btnBar.AnchorPoint=Vector2.new(1,0); btnBar.Position=UDim2.new(1,-8,0,6); btnBar.Size=UDim2.fromOffset(88,28)
  local bList=Instance.new("UIListLayout", btnBar); bList.FillDirection=Enum.FillDirection.Horizontal; bList.Padding=UDim.new(0,8); bList.HorizontalAlignment=Enum.HorizontalAlignment.Right

  local function topButton(char, tip)
    local b=Instance.new("TextButton", btnBar)
    b.AutoButtonColor=false; b.Size=UDim2.fromOffset(36,28)
    b.Text=char; b.Font=Enum.Font.GothamBold; b.TextSize=18; b.TextColor3=self.Theme.Text
    b.BackgroundColor3=self.Theme.Card; b.BorderSizePixel=0; corner(b,10); stroke(b,self.Theme.Stroke,1,.3)
    b.TextXAlignment=Enum.TextXAlignment.Center; b.TextYAlignment=Enum.TextYAlignment.Center
    b.MouseEnter:Connect(function() tw(b,TI(.12),{BackgroundColor3=self.Theme.Window}) end)
    b.MouseLeave:Connect(function() tw(b,TI(.12),{BackgroundColor3=self.Theme.Card}) end)
    return b
  end
  local btnMin = topButton("–","Minimize")
  local btnClose=topButton("✕","Close")

  -- layout
  local side=Instance.new("Frame", win)
  side.Size=UDim2.new(0,124,1,-48); side.Position=UDim2.new(0,8,0,44)
  side.BackgroundColor3=self.Theme.Sidebar; side.BorderSizePixel=0; corner(side,12); stroke(side,self.Theme.Stroke,1,.35)
  local sidePad, sideList = vlist(side,6); sideList.HorizontalAlignment=Enum.HorizontalAlignment.Center
  self.Sidebar=side

  local right=Instance.new("Frame", win)
  right.Size=UDim2.new(1,-(124+24),1,-48); right.Position=UDim2.new(0,124+16,0,44)
  right.BackgroundTransparency=1

  local pages=Instance.new("Folder", right); self._pagesFolder=pages

  -- show animation
  local fSize=win.Size; win.Size=UDim2.fromOffset(0,0); tw(win,TI(.22),{Size=fSize})

  -- drag (topbar)
  do
    local dragging, start, sp
    local function begin(i) dragging=true; start=i.Position; sp=win.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end) end
    top.InputBegan:Connect(function(i)
      if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then begin(i) end
    end)
    UIS.InputChanged:Connect(function(i)
      if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-start; win.Position=UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
      end
    end)
  end

  -- minimize/close
  btnMin.MouseButton1Click:Connect(function()
    if right.Visible then
      tw(win,TI(.18),{Size=UDim2.fromOffset(fSize.X.Offset,40)}); task.wait(.18); side.Visible=false; right.Visible=false
    else
      side.Visible=true; right.Visible=true; tw(win,TI(.18),{Size=fSize})
    end
  end)
  btnClose.MouseButton1Click:Connect(function()
    tw(win,TI(.18),{Size=UDim2.fromOffset(0,0)}); task.wait(.18)
    if self._blur then self._blur:Destroy() end
    gui:Destroy()
  end)

  -- RightShift toggle + mobil buton
  local toggleKey = self.Config.Keybind or Enum.KeyCode.RightShift
  UIS.InputBegan:Connect(function(i,gpe)
    if not gpe and i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==toggleKey then gui.Enabled = not gui.Enabled end
  end)
  if (self.Config.MobileButton ~= false) and isTouch() then
    local mb=Instance.new("TextButton", gui)
    mb.Text="Show Silver"; mb.Font=Enum.Font.GothamBold; mb.TextSize=14; mb.TextColor3=self.Theme.Text
    mb.Size=UDim2.fromOffset(130,40); mb.Position=UDim2.new(0,12,1,-52)
    mb.AutoButtonColor=false; mb.BackgroundColor3=self.Theme.Topbar; corner(mb,10); stroke(mb,self.Theme.Stroke,1,.35)
    mb.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)
    -- drag
    local drag,falseDrag=false,nil,nil
    mb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true; falseDrag=i.Position; falsePos=mb.Position end end)
    UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-falseDrag; mb.Position=UDim2.new(falsePos.X.Scale,falsePos.X.Offset+d.X,falsePos.Y.Scale,falsePos.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
  end

  -- toaster
  self.Notify = makeToaster(gui, self.Theme)
  self._notify = self.Notify

  -- API: AddTab
  function self:AddTab(info)
    info=info or {}
    local titleTxt=info.Title or "Tab"
    local glyph=info.IconText or "•"

    local tabBtn=Instance.new("TextButton", side)
    tabBtn.AutoButtonColor=false; tabBtn.Size=UDim2.new(1,-16,0,36)
    tabBtn.BackgroundColor3=self.Theme.Card; tabBtn.BorderSizePixel=0; tabBtn.Text=""
    corner(tabBtn,10); stroke(tabBtn,self.Theme.Stroke,1,.35)
    local g=Instance.new("TextLabel", tabBtn); g.BackgroundTransparency=1; g.Text=glyph; g.Font=Enum.Font.GothamBold; g.TextSize=14; g.TextColor3=self.Theme.SubText
    g.Size=UDim2.fromOffset(18,18); g.Position=UDim2.new(0,8,0.5,-9)
    local nm=Instance.new("TextLabel", tabBtn); nm.BackgroundTransparency=1; nm.Text=titleTxt; nm.Font=Enum.Font.GothamMedium; nm.TextSize=14; nm.TextColor3=self.Theme.Text
    nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Size=UDim2.new(1,-40,1,0); nm.Position=UDim2.new(0,32,0,0)
    tabBtn.MouseEnter:Connect(function() tw(tabBtn,TI(.12),{BackgroundColor3=self.Theme.Window}) end)
    tabBtn.MouseLeave:Connect(function() tw(tabBtn,TI(.12),{BackgroundColor3=self.Theme.Card}) end)

    local page=Instance.new("ScrollingFrame", pages)
    page.Visible=false; page.BackgroundTransparency=1; page.Size=UDim2.fromScale(1,1); page.ScrollBarThickness=4
    local pad,_=vlist(page,8)

    local TabAPI={Owner=self}
    function TabAPI:AddSection(title)
      local sec=Instance.new("Frame", page); sec.Size=UDim2.new(1,0,0,48); sec.AutomaticSize=Enum.AutomaticSize.Y
      sec.BackgroundColor3=self.Theme.Card; sec.BorderSizePixel=0; corner(sec,12); stroke(sec,self.Theme.Stroke,1,.35)
      local sp,_=vlist(sec,8)
      if title and title~="" then local h=Instance.new("TextLabel",sec); h.BackgroundTransparency=1; h.Font=Enum.Font.GothamBold; h.TextSize=14; h.TextColor3=self.Theme.Text; h.TextXAlignment=Enum.TextXAlignment.Left; h.Size=UDim2.new(1,0,0,18); h.Text=title end

      local function row(h) local r=Instance.new("Frame",sec); r.BackgroundColor3=self.Theme.Window; r.Size=UDim2.new(1,0,0,h or 36); r.BorderSizePixel=0; corner(r,8); stroke(r,self.Theme.Stroke,1,.25); return r end
      local API={}

      function API:AddLabel(text) local r=row(32); local l=Instance.new("TextLabel",r); l.BackgroundTransparency=1; l.Text=text or "Label"; l.Font=Enum.Font.GothamMedium; l.TextSize=14; l.TextColor3=self.Theme.Text; l.TextXAlignment=Enum.TextXAlignment.Left; l.Size=UDim2.new(1,-12,1,0); l.Position=UDim2.new(0,12,0,0); return {Set=function(_,v) l.Text=tostring(v) end} end

      function API:AddParagraph(hd,ct)
        local r=row(58)
        local h=Instance.new("TextLabel",r); h.BackgroundTransparency=1; h.Text=hd or "Paragraph"; h.Font=Enum.Font.GothamBold; h.TextSize=14; h.TextColor3=self.Theme.Text; h.TextXAlignment=Enum.TextXAlignment.Left; h.Size=UDim2.new(1,-12,0,18); h.Position=UDim2.new(0,12,0,6)
        local c=Instance.new("TextLabel",r); c.BackgroundTransparency=1; c.Text=ct or "Content"; c.Font=Enum.Font.Gotham; c.TextSize=13; c.TextColor3=self.Theme.SubText; c.TextXAlignment=Enum.TextXAlignment.Left; c.Size=UDim2.new(1,-12,0,18); c.Position=UDim2.new(0,12,0,28); c.TextWrapped=true
        return {SetHeader=function(_,v) h.Text=tostring(v) end, SetText=function(_,v) c.Text=tostring(v) end}
      end

      function API:AddButton(o)
        o=o or {}; local r=row(36)
        local b=Instance.new("TextButton",r); b.AutoButtonColor=false; b.Size=UDim2.new(1,-12,1,-8); b.Position=UDim2.new(0,6,0,4)
        b.Text=tostring(o.Title or "Button"); b.Font=Enum.Font.GothamMedium; b.TextSize=14; b.TextColor3=self.Theme.Text; b.BackgroundColor3=self.Theme.Card; corner(b,8); stroke(b,self.Theme.Stroke,1,.3)
        b.MouseEnter:Connect(function() tw(b,TI(.1),{BackgroundColor3=self.Theme.Window}) end)
        b.MouseLeave:Connect(function() tw(b,TI(.1),{BackgroundColor3=self.Theme.Card}) end)
        b.MouseButton1Click:Connect(function() if o.Callback then task.spawn(o.Callback) end end)
        return {SetTitle=function(_,v) b.Text=tostring(v) end, Click=function(_) if o.Callback then task.spawn(o.Callback) end end}
      end

      function API:AddToggle(o)
        o=o or {}; local key=o.Key or ("toggle_"..tostring(math.random(1,9e5))); local state=o.Default==true; self._values[key]=state
        local r=row(36)
        local t=Instance.new("TextLabel",r); t.BackgroundTransparency=1; t.Text=tostring(o.Title or "Toggle"); t.Font=Enum.Font.GothamMedium; t.TextSize=14; t.TextColor3=self.Theme.Text; t.TextXAlignment=Enum.TextXAlignment.Left; t.Size=UDim2.new(1,-70,1,0); t.Position=UDim2.new(0,12,0,0)
        local sw=Instance.new("Frame",r); sw.Size=UDim2.fromOffset(44,20); sw.AnchorPoint=Vector2.new(1,0.5); sw.Position=UDim2.new(1,-12,0.5,0); sw.BackgroundColor3=self.Theme.Card; corner(sw,999)
        local dot=Instance.new("Frame",sw); dot.Size=UDim2.fromOffset(16,16); dot.Position=UDim2.new(0,2,0,2); dot.BackgroundColor3=self.Theme.SubText; corner(dot,999)
        local function apply(v) tw(dot,TI(.14),{Position=v and UDim2.new(1,-18,0,2) or UDim2.new(0,2,0,2), BackgroundColor3=v and self.Theme.Good or self.Theme.SubText}); tw(sw,TI(.14),{BackgroundColor3=v and Color3.fromRGB(34,44,34) or self.Theme.Card}) end
        apply(state)
        r.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then state=not state; apply(state); self._values[key]=state; self:_save(); if o.Callback then task.spawn(o.Callback,state) end end end)
        return {Get=function() return state end, Set=function(_,v) state=not not v; apply(state); self._values[key]=state; self:_save() end, _apply=apply}
      end

      function API:AddSlider(o)
        o=o or {}; local key=o.Key or ("slider_"..tostring(math.random(1,9e5)))
        local mn, mx = o.Min or 0, o.Max or 100
        local val = clamp(o.Default or mn, mn, mx); self._values[key]=val
        local r=row(44)
        local tl=Instance.new("TextLabel",r); tl.BackgroundTransparency=1; tl.Text=tostring(o.Title or "Slider"); tl.Font=Enum.Font.GothamMedium; tl.TextSize=13; tl.TextColor3=self.Theme.Text; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Size=UDim2.new(1,-12,0,16); tl.Position=UDim2.new(0,12,0,6)
        local bar=Instance.new("Frame",r); bar.Size=UDim2.new(1,-24,0,8); bar.Position=UDim2.new(0,12,0,28); bar.BackgroundColor3=self.Theme.Card; bar.BorderSizePixel=0; corner(bar,999)
        local fill=Instance.new("Frame",bar); fill.Size=UDim2.fromScale((val-mn)/(mx-mn),1); fill.BackgroundColor3=self.Theme.Accent; fill.BorderSizePixel=0; corner(fill,999)
        local txt=Instance.new("TextLabel",r); txt.BackgroundTransparency=1; txt.Text=tostring(val); txt.Font=Enum.Font.Gotham; txt.TextSize=12; txt.TextColor3=self.Theme.SubText; txt.Size=UDim2.new(0,60,0,14); txt.Position=UDim2.new(1,-70,0,6)
        local dragging=false
        local function setfrom(px) local rel=clamp((px-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); val=math.floor(mn+rel*(mx-mn)+.5); fill.Size=UDim2.fromScale((val-mn)/(mx-mn),1); txt.Text=tostring(val); self._values[key]=val; self:_save(); if o.Callback then task.spawn(o.Callback,val) end end
        bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; setfrom(i.Position.X) end end)
        UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setfrom(i.Position.X) end end)
        UIS.InputEnded:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then dragging=false end end)
        local function apply(v) val=clamp(v,mn,mx); fill.Size=UDim2.fromScale((val-mn)/(mx-mn),1); txt.Text=tostring(val) end
        return {Get=function() return val end, Set=function(_,v) apply(v); self._values[key]=val; self:_save() end, _apply=apply}
      end

      function API:AddTextbox(o)
        o=o or {}; local key=o.Key or ("textbox_"..tostring(math.random(1,9e5))); local val=tostring(o.Default or ""); self._values[key]=val
        local r=row(40)
        local box=Instance.new("TextBox",r); box.PlaceholderText=o.Placeholder or "Input"; box.Text=val; box.TextColor3=self.Theme.Text; box.PlaceholderColor3=self.Theme.SubText
        box.Font=Enum.Font.Gotham; box.TextSize=14; box.BackgroundColor3=self.Theme.Card; box.Size=UDim2.new(1,-12,1,-8); box.Position=UDim2.new(0,6,0,4); corner(box,8); stroke(box,self.Theme.Stroke,1,.25)
        box.Focused:Connect(function() tw(box,TI(.1),{BackgroundColor3=self.Theme.Window}) end)
        box.FocusLost:Connect(function(enter) tw(box,TI(.1),{BackgroundColor3=self.Theme.Card}); val=box.Text; self._values[key]=val; self:_save(); if o.Callback then task.spawn(o.Callback,val,enter) end end)
        local function apply(v) val=tostring(v or ""); box.Text=val end
        return {Get=function() return val end, Set=function(_,v) apply(v); self._values[key]=val; self:_save() end, _apply=apply}
      end

      function API:AddKeybind(o)
        o=o or {}; local key=o.Key or ("key_"..tostring(math.random(1,9e5)))
        local current = o.Default or Enum.KeyCode.E; self._values[key]=current.Name or tostring(current)
        local r=row(36)
        local nm=Instance.new("TextLabel",r); nm.BackgroundTransparency=1; nm.Text=tostring(o.Title or "Keybind"); nm.Font=Enum.Font.GothamMedium; nm.TextSize=14; nm.TextColor3=self.Theme.Text; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Size=UDim2.new(1,-70,1,0); nm.Position=UDim2.new(0,12,0,0)
        local btn=Instance.new("TextButton",r); btn.Size=UDim2.fromOffset(56,24); btn.AnchorPoint=Vector2.new(1,0.5); btn.Position=UDim2.new(1,-12,0.5,0)
        btn.Text=(current.Name or "Key"); btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.TextColor3=self.Theme.Text; btn.BackgroundColor3=self.Theme.Card; btn.AutoButtonColor=false; corner(btn,8); stroke(btn,self.Theme.Stroke,1,.25)
        local listening=false
        btn.MouseButton1Click:Connect(function()
          if listening then return end; listening=true; btn.Text="..."
          local conn; conn=UIS.InputBegan:Connect(function(i,gpe)
            if gpe then return end
            if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode~=Enum.KeyCode.Unknown then
              current=i.KeyCode; btn.Text=current.Name; listening=false; conn:Disconnect()
              self._values[key]=current.Name; self:_save(); if o.Callback then task.spawn(o.Callback,current) end
            end
          end)
        end)
        UIS.InputBegan:Connect(function(i,gpe) if not gpe and i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==current then if o.Pressed then task.spawn(o.Pressed) end end end)
        local function apply(v) if typeof(v)=="EnumItem" then current=v else current=Enum.KeyCode[v] or current end; btn.Text=current.Name end
        return {Get=function() return current end, Set=function(_,v) apply(v); self._values[key]=current.Name; self:_save() end, _apply=apply}
      end

      function API:AddDropdown(o)
        o=o or {}; local key=o.Key or ("dd_"..tostring(math.random(1,9e5)))
        local opts=o.Options or {"None"}; local cur=o.Default or opts[1]; self._values[key]=cur
        local r=row(36)
        local btn=Instance.new("TextButton",r); btn.AutoButtonColor=false; btn.Size=UDim2.new(1,-12,1,-8); btn.Position=UDim2.new(0,6,0,4)
        btn.Text=tostring(o.Title or "Dropdown").."  •  "..tostring(cur); btn.Font=Enum.Font.GothamMedium; btn.TextSize=14; btn.TextColor3=self.Theme.Text; btn.BackgroundColor3=self.Theme.Card; corner(btn,8); stroke(btn,self.Theme.Stroke,1,.25)
        local open=false; local menu
        local function toggle()
          open=not open
          if open then
            menu=Instance.new("Frame",r); menu.BackgroundColor3=self.Theme.Card; menu.BorderSizePixel=0; menu.Position=UDim2.new(0,6,1,-4); menu.Size=UDim2.new(1,-12,0,#opts*28+12)
            corner(menu,8); stroke(menu,self.Theme.Stroke,1,.25); vlist(menu,6)
            for _,o2 in ipairs(opts) do
              local it=Instance.new("TextButton",menu); it.AutoButtonColor=false; it.Size=UDim2.new(1,0,0,24); it.Text=tostring(o2)
              it.Font=Enum.Font.Gotham; it.TextSize=13; it.TextColor3=self.Theme.Text; it.BackgroundColor3=self.Theme.Window; corner(it,8); stroke(it,self.Theme.Stroke,1,.2)
              it.MouseEnter:Connect(function() tw(it,TI(.1),{BackgroundColor3=self.Theme.Card}) end)
              it.MouseLeave:Connect(function() tw(it,TI(.1),{BackgroundColor3=self.Theme.Window}) end)
              it.MouseButton1Click:Connect(function() cur=o2; btn.Text=(o.Title or "Dropdown").."  •  "..tostring(cur); self._values[key]=cur; self:_save(); if o.Callback then task.spawn(o.Callback,cur) end; menu:Destroy(); open=false end)
            end
          else if menu then menu:Destroy() end end
        end
        btn.MouseButton1Click:Connect(toggle)
        local function apply(v) cur=v; btn.Text=(o.Title or "Dropdown").."  •  "..tostring(cur) end
        return {Get=function() return cur end, Set=function(_,v) apply(v); self._values[key]=cur; self:_save() end, _apply=apply}
      end

      function API:AddColorPicker(o)
        o=o or {}; local key=o.Key or ("col_"..tostring(math.random(1,9e5)))
        local col=o.Default or self.Theme.Accent; self._values[key]={col.R,col.G,col.B}
        local r=row(36)
        local nm=Instance.new("TextLabel",r); nm.BackgroundTransparency=1; nm.Text=tostring(o.Title or "Color"); nm.Font=Enum.Font.GothamMedium; nm.TextSize=14; nm.TextColor3=self.Theme.Text; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Size=UDim2.new(1,-70,1,0); nm.Position=UDim2.new(0,12,0,0)
        local sw=Instance.new("TextButton",r); sw.Size=UDim2.fromOffset(40,24); sw.AnchorPoint=Vector2.new(1,0.5); sw.Position=UDim2.new(1,-12,0.5,0)
        sw.Text=""; sw.BackgroundColor3=col; corner(sw,8); stroke(sw,self.Theme.Stroke,1,.25)
        local open=false; local picker
        local function openP()
          open=not open
          if open then
            picker=Instance.new("Frame",r); picker.BackgroundColor3=self.Theme.Card; picker.BorderSizePixel=0; picker.Position=UDim2.new(1,-220,1,6); picker.Size=UDim2.fromOffset(210,110)
            corner(picker,10); stroke(picker,self.Theme.Stroke,1,.25); vlist(picker,6)
            local function mk(lbl,init) local l=Instance.new("TextLabel",picker); l.BackgroundTransparency=1; l.Text=lbl; l.Font=Enum.Font.Gotham; l.TextColor3=self.Theme.SubText; l.Size=UDim2.new(0,18,0,16); local bx=Instance.new("TextBox",picker); bx.Size=UDim2.new(1,-26,0,24); bx.Text=tostring(init); bx.Font=Enum.Font.Gotham; bx.TextColor3=self.Theme.Text; bx.BackgroundColor3=self.Theme.Window; corner(bx,8); stroke(bx,self.Theme.Stroke,1,.2); return bx end
            local rr=mk("R:", math.floor(col.R*255)); local gg=mk("G:", math.floor(col.G*255)); local bb=mk("B:", math.floor(col.B*255))
            local function applyFrom() local rV=clamp(tonumber(rr.Text) or 0,0,255)/255; local gV=clamp(tonumber(gg.Text) or 0,0,255)/255; local bV=clamp(tonumber(bb.Text) or 0,0,255)/255; col=Color3.new(rV,gV,bV); sw.BackgroundColor3=col; self._values[key]={col.R,col.G,col.B}; self:_save(); if o.Callback then task.spawn(o.Callback,col) end end
            rr.FocusLost:Connect(applyFrom); gg.FocusLost:Connect(applyFrom); bb.FocusLost:Connect(applyFrom)
          else if picker then picker:Destroy() end end
        end
        sw.MouseButton1Click:Connect(openP)
        local function apply(v) if typeof(v)=="Color3" then col=v elseif typeof(v)=="table" then col=Color3.new(v[1],v[2],v[3]) end; sw.BackgroundColor3=col end
        return {Get=function() return col end, Set=function(_,v) apply(v); self._values[key]={col.R,col.G,col.B}; self:_save() end, _apply=apply}
      end

      function API:AddDivider() local d=Instance.new("Frame",sec); d.BackgroundColor3=self.Theme.Stroke; d.BorderSizePixel=0; d.Size=UDim2.new(1,0,0,1); return {} end
      function API:AddProgress(o) o=o or {}; local v=clamp(o.Value or 0,0,100); local r=row(42); local tl=Instance.new("TextLabel",r); tl.BackgroundTransparency=1; tl.Text=tostring(o.Title or "Progress"); tl.Font=Enum.Font.GothamMedium; tl.TextSize=13; tl.TextColor3=self.Theme.Text; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Size=UDim2.new(1,-12,0,16); tl.Position=UDim2.new(0,12,0,6); local bar=Instance.new("Frame",r); bar.Size=UDim2.new(1,-24,0,8); bar.Position=UDim2.new(0,12,0,28); bar.BackgroundColor3=self.Theme.Card; bar.BorderSizePixel=0; corner(bar,999); local fill=Instance.new("Frame",bar); fill.Size=UDim2.fromScale(v/100,1); fill.BackgroundColor3=self.Theme.Accent2; fill.BorderSizePixel=0; corner(fill,999); return {Set=function(_,nv) v=clamp(nv,0,100); tw(fill,TI(.14),{Size=UDim2.fromScale(v/100,1)}) end, Get=function() return v end} end

      function API:Notify(t,k,d) self.Owner:Notify({Text=t,Kind=k,Duration=d}) end
      return API
    end

    local function select()
      for _,p in ipairs(pages:GetChildren()) do p.Visible=false end
      for _,b in ipairs(side:GetChildren()) do if b:IsA("TextButton") then tw(b,TI(.12),{BackgroundColor3=self.Theme.Card}) end end
      page.Visible=true; tw(tabBtn,TI(.12),{BackgroundColor3=self.Theme.Window})
    end
    tabBtn.MouseButton1Click:Connect(select)
    if #self._tabs==0 then task.defer(select) end
    table.insert(self._tabs, {Button=tabBtn, Page=page})
    return TabAPI
  end

  -- transparency uygula (tam ekran arkaplan yok!)
  self:_applyTransparency(gui)

  -- config yükle (değerler elemanlar eklendikçe set edilecek)
  self:_load()

  -- public notify
  function self:Notify(o) self.Notify(o) end

  return self
end

return {
  CreateWindow = function(cfg) local ui=setmetatable({},Silver); return ui:CreateWindow(cfg) end,
  SetTheme = function(t) -- convenience
    if UI and UI.SetTheme then UI:SetTheme(t) end
  end
}
