local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local function getSafeParent()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local g=Instance.new("ScreenGui")
        syn.protect_gui(g)
        g.Parent=game:GetService("CoreGui")
        return g
    elseif pcall(function() return game:GetService("CoreGui") end) then
        return game:GetService("CoreGui")
    elseif LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        return LocalPlayer.PlayerGui
    else
        return game:GetService("CoreGui")
    end
end
local SilverUI={}
SilverUI.__index=SilverUI
local function TI(t,e,sr,rd,rt)
    return TweenInfo.new(t or .2,e or Enum.EasingStyle.Quad,sr or Enum.EasingDirection.Out,rd or 0,rt or false,0)
end
function SilverUI:New(cfg)
    cfg=cfg or {}
    local Name=cfg.Name or "Silver UI"
    local Size=cfg.Size or UDim2.new(0,565,0,370)
    local Parent=getSafeParent()
    local Gui=Instance.new("ScreenGui")
    Gui.Name="SilverUI"
    Gui.ResetOnSpawn=false
    Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    Gui.Parent=Parent
    local Main=Instance.new("Frame",Gui)
    Main.Name="Main"
    Main.Size=Size
    Main.Position=UDim2.new(.5,-Size.X.Offset/2,.5,-Size.Y.Offset/2)
    Main.BackgroundColor3=Color3.fromRGB(30,30,30)
    Main.BorderSizePixel=0
    local Shadow=Instance.new("ImageLabel",Main)
    Shadow.Image="rbxassetid://5028857084"
    Shadow.ScaleType=Enum.ScaleType.Slice
    Shadow.SliceCenter=Rect.new(24,24,276,276)
    Shadow.Size=UDim2.new(1,30,1,30)
    Shadow.Position=UDim2.new(0,-15,0,-15)
    Shadow.BackgroundTransparency=1
    Shadow.ImageTransparency=.55
    local Top=Instance.new("Frame",Main)
    Top.Name="Top"
    Top.Size=UDim2.new(1,0,0,32)
    Top.BackgroundColor3=Color3.fromRGB(20,20,20)
    Top.BorderSizePixel=0
    local Title=Instance.new("TextLabel",Top)
    Title.Size=UDim2.new(1,-90,1,0)
    Title.Position=UDim2.new(0,10,0,0)
    Title.BackgroundTransparency=1
    Title.Text=Name
    Title.TextColor3=Color3.new(1,1,1)
    Title.Font=Enum.Font.GothamBold
    Title.TextSize=14
    Title.TextXAlignment=Enum.TextXAlignment.Left
    local Close=Instance.new("TextButton",Top)
    Close.Size=UDim2.new(0,28,0,24)
    Close.Position=UDim2.new(1,-34,0,4)
    Close.Text="×"
    Close.TextScaled=true
    Close.BackgroundColor3=Color3.fromRGB(45,45,45)
    Close.AutoButtonColor=false
    Close.TextColor3=Color3.new(1,1,1)
    local Min=Instance.new("TextButton",Top)
    Min.Size=UDim2.new(0,28,0,24)
    Min.Position=UDim2.new(1,-66,0,4)
    Min.Text="–"
    Min.TextScaled=true
    Min.BackgroundColor3=Color3.fromRGB(45,45,45)
    Min.AutoButtonColor=false
    Min.TextColor3=Color3.new(1,1,1)
    local Body=Instance.new("Frame",Main)
    Body.Size=UDim2.new(1,0,1,-32)
    Body.Position=UDim2.new(0,0,0,32)
    Body.BackgroundColor3=Color3.fromRGB(32,32,32)
    Body.BorderSizePixel=0
    local Sidebar=Instance.new("Frame",Body)
    Sidebar.Size=UDim2.new(0,150,1,0)
    Sidebar.BackgroundColor3=Color3.fromRGB(25,25,25)
    Sidebar.BorderSizePixel=0
    local SideList=Instance.new("UIListLayout",Sidebar)
    SideList.Padding=UDim.new(0,6)
    SideList.SortOrder=Enum.SortOrder.LayoutOrder
    local Content=Instance.new("Frame",Body)
    Content.Size=UDim2.new(1,-150,1,0)
    Content.Position=UDim2.new(0,150,0,0)
    Content.BackgroundTransparency=1
    local Pages=Instance.new("Folder",Content)
    local Tabs={}
    local ActivePage=nil
    local dragging=false
    local dragInput,mousePos,framePos
    Top.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            mousePos=input.Position
            framePos=Main.Position
        end
    end)
    Top.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            dragInput=input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input==dragInput and dragging then
            local delta=input.Position-mousePos
            Main.Position=UDim2.new(framePos.X.Scale,framePos.X.Offset+delta.X,framePos.Y.Scale,framePos.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
    Min.MouseButton1Click:Connect(function()
        TweenService:Create(Body,TI(.15),{Transparency=1}):Play()
        for _,v in ipairs(Body:GetDescendants()) do
            if v:IsA("GuiObject") then TweenService:Create(v,TI(.15),{Transparency=1}):Play() end
        end
        wait(.15)
        Body.Visible=false
        Min.Visible=false
        local Restore=Instance.new("TextButton",Top)
        Restore.Size=UDim2.new(0,60,0,24)
        Restore.Position=UDim2.new(1,-66,0,4)
        Restore.Text="Show"
        Restore.TextScaled=true
        Restore.BackgroundColor3=Color3.fromRGB(45,45,45)
        Restore.TextColor3=Color3.new(1,1,1)
        Restore.MouseButton1Click:Connect(function()
            Body.Visible=true
            for _,v in ipairs(Body:GetDescendants()) do if v:IsA("GuiObject") then v.Transparency=0 end end
            Restore:Destroy()
            Min.Visible=true
        end)
    end)
    Close.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)
    local WindowAPI={}
    function WindowAPI:Tab(tabName)
        local btn=Instance.new("TextButton",Sidebar)
        btn.Size=UDim2.new(1,-12,0,28)
        btn.Position=UDim2.new(0,6,0,6)
        btn.BackgroundColor3=Color3.fromRGB(40,40,40)
        btn.Text=tabName or "Tab"
        btn.TextColor3=Color3.new(1,1,1)
        btn.AutoButtonColor=false
        btn.Font=Enum.Font.Gotham
        btn.TextSize=13
        local page=Instance.new("ScrollingFrame",Pages)
        page.BorderSizePixel=0
        page.Size=UDim2.new(1,0,1,0)
        page.CanvasSize=UDim2.new(0,0,0,0)
        page.ScrollBarThickness=4
        page.Visible=false
        local list=Instance.new("UIListLayout",page)
        list.Padding=UDim.new(0,8)
        list.SortOrder=Enum.SortOrder.LayoutOrder
        local pad=Instance.new("UIPadding",page)
        pad.PaddingTop=UDim.new(0,10)
        pad.PaddingLeft=UDim.new(0,10)
        pad.PaddingRight=UDim.new(0,10)
        local function show()
            if ActivePage then ActivePage.Visible=false end
            ActivePage=page
            page.Visible=true
            for _,b in ipairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3=Color3.fromRGB(40,40,40) end end
            btn.BackgroundColor3=Color3.fromRGB(60,60,60)
        end
        btn.MouseButton1Click:Connect(show)
        if not ActivePage then show() end
        local TabAPI={}
        function TabAPI:Label(text)
            local l=Instance.new("TextLabel",page)
            l.Size=UDim2.new(1,0,0,24)
            l.BackgroundColor3=Color3.fromRGB(45,45,45)
            l.TextColor3=Color3.new(1,1,1)
            l.TextWrapped=true
            l.TextXAlignment=Enum.TextXAlignment.Left
            l.Font=Enum.Font.Gotham
            l.TextSize=13
            l.Text="  "..(text or "")
            return l
        end
        function TabAPI:Paragraph(h,c)
            local h1=self:Label(h or "")
            local c1=self:Label(c or "")
            return {Header=h1,Content=c1}
        end
        function TabAPI:Divider()
            local d=Instance.new("Frame",page)
            d.Size=UDim2.new(1,0,0,2)
            d.BackgroundColor3=Color3.fromRGB(70,70,70)
            return d
        end
        function TabAPI:Button(opt)
            local b=Instance.new("TextButton",page)
            b.Size=UDim2.new(1,0,0,28)
            b.BackgroundColor3=Color3.fromRGB(50,50,50)
            b.TextColor3=Color3.new(1,1,1)
            b.Text=opt.Title or "Button"
            b.Font=Enum.Font.Gotham
            b.TextSize=13
            b.MouseButton1Click:Connect(function() if opt.Callback then opt.Callback() end end)
            return b
        end
        function TabAPI:Toggle(opt)
            local state=opt.Default or false
            local b=self:Button({Title=((state and "[ON] " or "[OFF] ")..(opt.Title or "Toggle")),Callback=function()
                state=not state
                btn.Text=(tabName or "Tab")
                if opt.Callback then opt.Callback(state) end
            end})
            b.MouseButton1Click:Connect(function()
                state=not state
                b.Text=((state and "[ON] " or "[OFF] ")..(opt.Title or "Toggle"))
                if opt.Callback then opt.Callback(state) end
            end)
            return {Set=function(v) state=v b.Text=((state and "[ON] " or "[OFF] ")..(opt.Title or "Toggle")) end,Get=function() return state end}
        end
        function TabAPI:Slider(opt)
            local min=opt.Min or 0
            local max=opt.Max or 100
            local val=math.clamp(opt.Default or min,min,max)
            local holder=Instance.new("Frame",page)
            holder.Size=UDim2.new(1,0,0,40)
            holder.BackgroundColor3=Color3.fromRGB(45,45,45)
            local title=Instance.new("TextLabel",holder)
            title.Size=UDim2.new(1,0,0,18)
            title.BackgroundTransparency=1
            title.Text="  "..(opt.Title or "Slider").." : "..val
            title.TextColor3=Color3.new(1,1,1)
            title.Font=Enum.Font.Gotham
            title.TextSize=13
            local bar=Instance.new("Frame",holder)
            bar.Size=UDim2.new(1,-20,0,6)
            bar.Position=UDim2.new(0,10,0,26)
            bar.BackgroundColor3=Color3.fromRGB(65,65,65)
            bar.BorderSizePixel=0
            local fill=Instance.new("Frame",bar)
            fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
            fill.BackgroundColor3=Color3.fromRGB(120,120,255)
            fill.BorderSizePixel=0
            local draggingS=false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                    draggingS=true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                    draggingS=false
                end
            end)
            bar.InputChanged:Connect(function(input)
                if (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) and draggingS then
                    local rel=(input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
                    rel=math.clamp(rel,0,1)
                    val=math.floor(min+rel*(max-min)+.5)
                    fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
                    title.Text="  "..(opt.Title or "Slider").." : "..val
                    if opt.Callback then opt.Callback(val) end
                end
            end)
            return {Set=function(v) val=math.clamp(v,min,max) fill.Size=UDim2.new((val-min)/(max-min),0,1,0) title.Text="  "..(opt.Title or "Slider").." : "..val end,Get=function() return val end}
        end
        function TabAPI:Textbox(opt)
            local box=Instance.new("TextBox",page)
            box.Size=UDim2.new(1,0,0,28)
            box.BackgroundColor3=Color3.fromRGB(50,50,50)
            box.TextColor3=Color3.new(1,1,1)
            box.PlaceholderText=opt.Placeholder or ""
            box.Text=opt.Default or ""
            box.Font=Enum.Font.Gotham
            box.TextSize=13
            box.ClearTextOnFocus=false
            box.FocusLost:Connect(function(enter)
                if enter and opt.Callback then opt.Callback(box.Text) end
            end)
            return box
        end
        function TabAPI:Dropdown(opt)
            local current=opt.Default or (opt.Options and opt.Options[1]) or ""
            local btn=self:Button({Title=(opt.Title or "Dropdown")..": "..tostring(current)})
            local open=false
            local listFrame=Instance.new("Frame",page)
            listFrame.Size=UDim2.new(1,0,0,0)
            listFrame.BackgroundTransparency=1
            listFrame.Visible=false
            local l=Instance.new("UIListLayout",listFrame)
            l.Padding=UDim.new(0,6)
            btn.MouseButton1Click:Connect(function()
                open=not open
                listFrame.Visible=open
                listFrame.Size=UDim2.new(1,0,0,open and (#(opt.Options or {})*28+6) or 0)
            end)
            for _,v in ipairs(opt.Options or {}) do
                local o=Instance.new("TextButton",listFrame)
                o.Size=UDim2.new(1,0,0,28)
                o.BackgroundColor3=Color3.fromRGB(55,55,55)
                o.TextColor3=Color3.new(1,1,1)
                o.Text=tostring(v)
                o.Font=Enum.Font.Gotham
                o.TextSize=13
                o.MouseButton1Click:Connect(function()
                    current=v
                    btn.Text=(opt.Title or "Dropdown")..": "..tostring(current)
                    if opt.Callback then opt.Callback(current) end
                    open=false
                    listFrame.Visible=false
                    listFrame.Size=UDim2.new(1,0,0,0)
                end)
            end
            return {Get=function() return current end,Set=function(v) current=v btn.Text=(opt.Title or "Dropdown")..": "..tostring(current) end}
        end
        function TabAPI:MultiDropdown(opt)
            local selected={}
            for _,d in ipairs(opt.Default or {}) do selected[d]=true end
            local function listToArray()
                local t={} for k,v in pairs(selected) do if v then table.insert(t,k) end end return t
            end
            local btn=self:Button({Title=(opt.Title or "MultiDropdown")..": 0 seçili"})
            local listFrame=Instance.new("Frame",page)
            listFrame.Size=UDim2.new(1,0,0,0)
            listFrame.BackgroundTransparency=1
            listFrame.Visible=false
            local l=Instance.new("UIListLayout",listFrame)
            l.Padding=UDim.new(0,6)
            local open=false
            btn.MouseButton1Click:Connect(function()
                open=not open
                listFrame.Visible=open
                listFrame.Size=UDim2.new(1,0,0,open and (#(opt.Options or {})*28+6) or 0)
            end)
            local function refreshBtn()
                local c=#listToArray()
                btn.Text=(opt.Title or "MultiDropdown")..": "..tostring(c).." seçili"
            end
            for _,v in ipairs(opt.Options or {}) do
                local o=Instance.new("TextButton",listFrame)
                o.Size=UDim2.new(1,0,0,28)
                o.BackgroundColor3=Color3.fromRGB(55,55,55)
                o.TextColor3=Color3.new(1,1,1)
                o.Text="[] "..tostring(v)
                o.Font=Enum.Font.Gotham
                o.TextSize=13
                o.MouseButton1Click:Connect(function()
                    selected[v]=not selected[v]
                    o.Text=((selected[v] and "[x] " or "[] ")..tostring(v))
                    if opt.Callback then opt.Callback(listToArray()) end
                    refreshBtn()
                end)
                if selected[v] then o.Text="[x] "..tostring(v) end
            end
            refreshBtn()
            return {Get=function() return listToArray() end,Set=function(arr) selected={} for _,vv in ipairs(arr or {}) do selected[vv]=true end refreshBtn() end}
        end
        function TabAPI:Colorpicker(opt)
            local col=opt.Default or Color3.fromRGB(255,255,255)
            local b=self:Button({Title=(opt.Title or "ColorPicker")})
            b.BackgroundColor3=Color3.fromRGB(50,50,50)
            local sw=Instance.new("Frame",b)
            sw.AnchorPoint=Vector2.new(1,.5)
            sw.Position=UDim2.new(1,-6,.5,0)
            sw.Size=UDim2.new(0,22,0,14)
            sw.BackgroundColor3=col
            b.MouseButton1Click:Connect(function()
                col=Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
                sw.BackgroundColor3=col
                if opt.Callback then opt.Callback(col) end
            end)
            return {Get=function() return col end,Set=function(c) col=c sw.BackgroundColor3=c end}
        end
        function TabAPI:Keybind(opt)
            local key=opt.Default or Enum.KeyCode.RightShift
            local capturing=false
            local b=self:Button({Title=(opt.Title or "Keybind")..": "..key.Name})
            b.MouseButton1Click:Connect(function()
                capturing=true
                b.Text=(opt.Title or "Keybind")..": ..."
            end)
            UserInputService.InputBegan:Connect(function(i,gp)
                if gp then return end
                if capturing then
                    if i.KeyCode~=Enum.KeyCode.Unknown then
                        key=i.KeyCode
                        b.Text=(opt.Title or "Keybind")..": "..key.Name
                        capturing=false
                        if opt.Callback then opt.Callback(key) end
                    end
                elseif i.KeyCode==key then
                    if opt.Pressed then opt.Pressed() end
                end
            end)
            return {Get=function() return key end,Set=function(kc) key=kc b.Text=(opt.Title or "Keybind")..": "..key.Name end}
        end
        function TabAPI:Notify(t,k,d)
            d=d or 3
            local n=Instance.new("TextLabel",Gui)
            n.Size=UDim2.new(0,260,0,28)
            n.Position=UDim2.new(1,-270,1,-38)
            n.BackgroundColor3=Color3.fromRGB(20,20,20)
            n.BorderSizePixel=0
            n.Text=string.format("%s | %s",t or "Silver UI",k or "")
            n.TextColor3=Color3.new(1,1,1)
            n.Font=Enum.Font.Gotham
            n.TextSize=12
            n.TextXAlignment=Enum.TextXAlignment.Center
            n.TextYAlignment=Enum.TextYAlignment.Center
            n.AnchorPoint=Vector2.new(0,1)
            TweenService:Create(n,TI(.2),{Position=UDim2.new(1,-270,1,-70)}):Play()
            task.delay(d,function()
                TweenService:Create(n,TI(.2),{TextTransparency=1,BackgroundTransparency=.2}):Play()
                task.wait(.25)
                n:Destroy()
            end)
        end
        return TabAPI
    end
    return WindowAPI
end
return setmetatable({},SilverUI)
