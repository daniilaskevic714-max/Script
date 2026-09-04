-- ============================================================================
--  PRISON LIFE HUB — v3 "Modern Edition"
--  Модернизация v2. Что нового:
--   UI/UX:
--    • Табы: Телепорт / Визуал / Прочее (переключение страниц)
--    • Переключатели-свитчи с анимацией (TweenService) вместо текста ON/OFF
--    • Уведомления-тосты (auto-hide 2.5с) на каждое действие
--    • Ховер-подсветка кнопок, градиент заголовка, обводка панели (UIStroke)
--    • Анимация открытия панели, современный drag, кнопки "✕" и "_"
--    • Слайдеры: скорость персонажа и скорость полёта
--   Функции:
--    • Fly (полёт на WASD/Space/Ctrl, скорость слайдером, хоткей F)
--    • Infinite Jump, Anti-AFK, Click TP (Ctrl+ЛКМ), Rejoin
--    • Hotkeys: RightShift — меню, F — полёт, N — noclip
--    • ESP: угловой бокс (corner box) в цвете команды + трейсер/имя/дист/хп
--   Сохранено из v2: все фиксы b1-b4, телепорты (точное имя в приоритете),
--   taser bypass, noclip+antifall (сохранение CanCollide), highlight,
--   spectate с автовозвратом камеры, полная очистка GUI по "✕".
-- ============================================================================

local p=game.Players.LocalPlayer

if not p then return end

if not p.Character then p.CharacterAdded:Wait() end

task.wait(1)



local R,H,C

local function u()

    C=p.Character

    if C then R=C:FindFirstChild("HumanoidRootPart")H=C:FindFirstChild("Humanoid")end

end

u()



local RS=game:GetService("RunService")

local UIS=game:GetService("UserInputService")

local TS=game:GetService("TweenService")

local Cam=workspace.CurrentCamera

local PG=p:WaitForChild("PlayerGui")



-- ═══════════════ УТИЛИТЫ ═══════════════

local GREEN=Color3.fromRGB(0,150,0)

local GREY=Color3.fromRGB(80,80,80)

local ACCENT=Color3.fromRGB(88,101,242)

local ELEM=Color3.fromRGB(30,30,45)

local BG=Color3.fromRGB(15,15,25)



local function tween(obj,props,t)

    local ti=TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

    local tw=TS:Create(obj,ti,props)

    tw:Play()

    return tw

end



local function lighten(c)

    return Color3.new(math.min(c.R+0.12,1),math.min(c.G+0.12,1),math.min(c.B+0.12,1))

end



-- чистим старые копии GUI (CoreGui + PlayerGui)

local function destroyOld()

    local function scan(parent)

        if not parent then return end

        for _,g in ipairs(parent:GetChildren())do if g.Name=="D"then pcall(function()g:Destroy()end)end end

    end

    scan(PG)

    pcall(function()scan(game.CoreGui)end)

end

destroyOld()



-- ═══════════════ КАРКАС GUI ═══════════════

local S=Instance.new("ScreenGui")

S.Name="D"S.ResetOnSpawn=false

local ok=pcall(function()S.Parent=game.CoreGui end)

if not ok then S.Parent=PG end



-- v3.2: АВТО-МАСШТАБ ПОД ЭКРАН (на телефонах ViewportSize большой в пикселях —

-- без масштаба панель будет крошечной; на ПК остаётся 1.0)

local mScale=Instance.new("UIScale",S)

mScale.Scale=math.clamp((Cam.ViewportSize and Cam.ViewportSize.X or 1280)/1300,1,2.2)

pcall(function()

    Cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()

        mScale.Scale=math.clamp(Cam.ViewportSize.X/1300,1,2.2)

    end)

end)



local FULL=UDim2.new(0,190,0,300)

local M=Instance.new("Frame",S)

M.Size=FULL

M.Position=UDim2.new(0,10,0.5,-150)

M.BackgroundColor3=BG

M.BorderSizePixel=0

M.Active=true

Instance.new("UICorner",M).CornerRadius=UDim.new(0,10)

local mStroke=Instance.new("UIStroke",M)

mStroke.Color=Color3.fromRGB(60,60,95)mStroke.Thickness=1



local T=Instance.new("TextLabel",M)

T.Size=UDim2.new(1,0,0,32)

T.BackgroundColor3=Color3.fromRGB(35,35,55)

T.Text="⚡ PRISON LIFE HUB"

T.TextColor3=Color3.new(1,1,1)

T.Font=Enum.Font.SourceSansBold

T.TextSize=15

T.Active=true

Instance.new("UICorner",T).CornerRadius=UDim.new(0,10)

local grad=Instance.new("UIGradient",T)

grad.Color=ColorSequence.new(Color3.fromRGB(45,45,80),Color3.fromRGB(25,25,45))



local X=Instance.new("TextButton",T)

X.Size=UDim2.new(0,22,0,22)

X.Position=UDim2.new(1,-25,0,5)

X.BackgroundColor3=Color3.fromRGB(200,50,50)

X.Text="✕"X.TextColor3=Color3.new(1,1,1)

X.Font=Enum.Font.SourceSansBold

Instance.new("UICorner",X).CornerRadius=UDim.new(0,5)



local MN=Instance.new("TextButton",T)

MN.Size=UDim2.new(0,22,0,22)

MN.Position=UDim2.new(1,-50,0,5)

MN.BackgroundColor3=Color3.fromRGB(80,140,220)

MN.Text="_"MN.TextColor3=Color3.new(1,1,1)

MN.Font=Enum.Font.SourceSansBold

Instance.new("UICorner",MN).CornerRadius=UDim.new(0,5)



-- ═══════════════ УВЕДОМЛЕНИЯ ═══════════════

local noteHolder=Instance.new("Frame",S)

noteHolder.Name="NotifyHolder"

noteHolder.Size=UDim2.new(0,200,0,400)

noteHolder.Position=UDim2.new(1,-210,0,10)

noteHolder.BackgroundTransparency=1

local nl=Instance.new("UIListLayout",noteHolder)

nl.Padding=UDim.new(0,4)



local function notify(text,accent)

    local n=Instance.new("Frame",noteHolder)

    n.Size=UDim2.new(1,0,0,28)

    n.BackgroundColor3=Color3.fromRGB(20,20,32)

    n.BorderSizePixel=0

    Instance.new("UICorner",n).CornerRadius=UDim.new(0,6)

    local st=Instance.new("UIStroke",n)

    st.Color=accent or ACCENT st.Thickness=1

    local tl=Instance.new("TextLabel",n)

    tl.Size=UDim2.new(1,-12,1,0)tl.Position=UDim2.new(0,6,0,0)

    tl.BackgroundTransparency=1

    tl.Text=text tl.TextColor3=Color3.new(1,1,1)

    tl.Font=Enum.Font.SourceSansBold tl.TextSize=12 tl.TextXAlignment=Enum.TextXAlignment.Left

    task.delay(2.5,function()

        pcall(function()n:Destroy()end)

    end)

end



-- ═══════════════ ТАБЫ И СТРАНИЦЫ ═══════════════

local pages={}

local tabBtns={}

local TABS={"Телепорт","Визуал","Прочее"}



local tabBar=Instance.new("Frame",M)

tabBar.Size=UDim2.new(1,0,0,28)

tabBar.Position=UDim2.new(0,0,0,32)

tabBar.BackgroundTransparency=1



local function showTab(i)

    for k=1,#pages do

        pages[k].Visible=(k==i)

        tabBtns[k].BackgroundColor3=(k==i)and ACCENT or ELEM

    end

end



for i=1,#TABS do

    local tb=Instance.new("TextButton",tabBar)

    tb.Size=UDim2.new(1/#TABS,-4,1,-6)

    tb.Position=UDim2.new((i-1)/#TABS,2,0,3)

    tb.BackgroundColor3=ELEM

    tb.Text=TABS[i]tb.TextColor3=Color3.new(1,1,1)

    tb.Font=Enum.Font.SourceSansBold tb.TextSize=12

    Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)

    tabBtns[i]=tb

    local page=Instance.new("ScrollingFrame",M)

    page.Size=UDim2.new(1,-16,1,-94)

    page.Position=UDim2.new(0,8,0,62)

    page.BackgroundTransparency=1

    page.BorderSizePixel=0

    page.ScrollBarThickness=3

    page.CanvasSize=UDim2.new(0,0,0,0)

    page.AutomaticCanvasSize=Enum.AutomaticSize.Y

    page.Visible=(i==1)

    Instance.new("UIListLayout",page).Padding=UDim.new(0,3)

    pages[i]=page

    tb.MouseButton1Click:Connect(function()

        pcall(function()showTab(i)end)

    end)

end

showTab(1)



local ver=Instance.new("TextLabel",M)

ver.Size=UDim2.new(1,0,0,14)

ver.Position=UDim2.new(0,0,1,-16)

ver.BackgroundTransparency=1

ver.Text="v3.2 • Mobile Edition"

ver.TextColor3=Color3.fromRGB(110,110,140)

ver.Font=Enum.Font.SourceSans ver.TextSize=10



local B=Instance.new("TextButton",S)

B.Size=UDim2.new(0,36,0,36)

B.Position=UDim2.new(0,10,0,10)

B.BackgroundColor3=Color3.fromRGB(35,35,50)

B.Text="📋"B.TextColor3=Color3.new(1,1,1)

B.Font=Enum.Font.SourceSansBold B.TextSize=16

Instance.new("UICorner",B).CornerRadius=UDim.new(1,0)

B.Visible=false



local V=true

local function tg()

    V=not V

    if V then

        M.Visible=true

        M.Size=UDim2.new(0,190,0,0)

        tween(M,{Size=FULL},0.2)

    else

        M.Visible=false

    end

    B.Visible=not V

end

B.MouseButton1Click:Connect(function()pcall(tg)end)

MN.MouseButton1Click:Connect(function()pcall(tg)end)



-- drag за заголовок

do

    local dragging=false

    local dragStart,startPos

    T.InputBegan:Connect(function(input)

        local it=input.UserInputType

        if it==Enum.UserInputType.MouseButton1 or it==Enum.UserInputType.Touch then

            dragging=true

            dragStart=input.Position

            startPos=M.Position

            if input.Changed then

                input.Changed:Connect(function()

                    if input.UserInputState==Enum.UserInputState.End then dragging=false end

                end)

            end

        end

    end)

    UIS.InputChanged:Connect(function(input)

        if not dragging then return end

        local it=input.UserInputType

        if it==Enum.UserInputType.MouseMovement or it==Enum.UserInputType.Touch then

            local delta=input.Position-dragStart

            M.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)

        end

    end)

end



-- ═══════════════ ЭЛЕМЕНТЫ УПРАВЛЕНИЯ ═══════════════

local function mb(cont,text,color,cb)

    local b=Instance.new("TextButton",cont)

    b.Size=UDim2.new(1,0,0,28)

    b.BackgroundColor3=color or ELEM

    b.Text=text b.TextColor3=Color3.new(1,1,1)

    b.Font=Enum.Font.SourceSansBold b.TextSize=13

    b.AutoButtonColor=false

    b.BorderSizePixel=0

    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)

    local base=b.BackgroundColor3

    b.MouseEnter:Connect(function()b.BackgroundColor3=lighten(base)end)

    b.MouseLeave:Connect(function()b.BackgroundColor3=base end)

    b.MouseButton1Click:Connect(function()

        pcall(function()if cb then cb(b)end end)

    end)

    return b

end



local swReg={}

local function sw(cont,name,get,set)

    local row=Instance.new("TextButton",cont)

    row.Size=UDim2.new(1,0,0,26)

    row.BackgroundColor3=ELEM

    row.Text=name -- невидимый текст (для доступности/тестов)

    row.TextTransparency=1

    row.AutoButtonColor=false

    row.BorderSizePixel=0

    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)

    local lbl=Instance.new("TextLabel",row)

    lbl.Size=UDim2.new(1,-50,1,0)lbl.Position=UDim2.new(0,8,0,0)

    lbl.BackgroundTransparency=1

    lbl.Text=name lbl.TextColor3=Color3.new(1,1,1)

    lbl.Font=Enum.Font.SourceSansBold lbl.TextSize=12

    lbl.TextXAlignment=Enum.TextXAlignment.Left

    local bar=Instance.new("Frame",row)

    bar.Name="SwitchBar"

    bar.Size=UDim2.new(0,34,0,14)

    bar.Position=UDim2.new(1,-42,0.5,-7)

    bar.BackgroundColor3=GREY

    bar.BorderSizePixel=0

    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",bar)

    knob.Name="Knob"

    knob.Size=UDim2.new(0,10,0,10)

    knob.Position=UDim2.new(0,2,0.5,-5)

    knob.BackgroundColor3=Color3.new(1,1,1)

    knob.BorderSizePixel=0

    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local function refresh(anim)

        local on=get()

        if anim then

            tween(bar,{BackgroundColor3=on and GREEN or GREY},0.15)

            tween(knob,{Position=UDim2.new(0,on and 22 or 2,0.5,-5)},0.15)

        else

            bar.BackgroundColor3=on and GREEN or GREY

            knob.Position=UDim2.new(0,on and 22 or 2,0.5,-5)

        end

    end

    swReg[name]={get=get,set=set,refresh=refresh}

    row.MouseButton1Click:Connect(function()

        pcall(function()

            set(not get())

            refresh(true)

            notify(name..(get()and": ВКЛ"or": ВЫКЛ"),get()and GREEN or GREY)

        end)

    end)

    refresh(false)

    return row

end

local function flip(name)

    local r=swReg[name]

    if r then r.set(not r.get())r.refresh()end

end



local function sl(cont,name,min,max,val,onCh)

    local row=Instance.new("Frame",cont)

    row.Size=UDim2.new(1,0,0,34)

    row.BackgroundColor3=ELEM

    row.BorderSizePixel=0

    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)

    local lbl=Instance.new("TextLabel",row)

    lbl.Size=UDim2.new(1,-16,0,16)lbl.Position=UDim2.new(0,8,0,3)

    lbl.BackgroundTransparency=1

    lbl.Text=name..": "..math.floor(val+0.5)

    lbl.TextColor3=Color3.fromRGB(210,210,220)

    lbl.Font=Enum.Font.SourceSansBold lbl.TextSize=12

    lbl.TextXAlignment=Enum.TextXAlignment.Left

    local bar=Instance.new("Frame",row)

    bar.Name="SliderBar"

    bar.Size=UDim2.new(1,-16,0,6)

    bar.Position=UDim2.new(0,8,1,-12)

    bar.BackgroundColor3=Color3.fromRGB(50,50,70)

    bar.BorderSizePixel=0

    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",bar)

    fill.Name="SliderFill"

    fill.Size=UDim2.new((val-min)/(max-min),0,1,0)

    fill.BackgroundColor3=ACCENT

    fill.BorderSizePixel=0

    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local dragging=false

    local function setFromX(x)

        local frac=(x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1)

        frac=math.clamp(frac,0,1)

        val=min+(max-min)*frac

        fill.Size=UDim2.new(frac,0,1,0)

        lbl.Text=name..": "..math.floor(val+0.5)

        pcall(function()onCh(val)end)

    end

    bar.InputBegan:Connect(function(inp)

        local it=inp.UserInputType

        if it==Enum.UserInputType.MouseButton1 or it==Enum.UserInputType.Touch then

            dragging=true

            setFromX(inp.Position.X)

        end

    end)

    UIS.InputChanged:Connect(function(inp)

        if not dragging then return end

        local it=inp.UserInputType

        if it==Enum.UserInputType.MouseMovement or it==Enum.UserInputType.Touch then

            setFromX(inp.Position.X)

        end

    end)

    UIS.InputEnded:Connect(function(inp)

        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end

    end)

    return row

end



-- ═══════════════ ТЕЛЕПОРТ ═══════════════

local function tp(pos)

    if pos and R then

        aaGrace=true -- свой телепорт: Anti-Arrest не мешает

        R.CFrame=CFrame.new(pos+Vector3.new(0,5,0))R.Velocity=Vector3.zero

    end

end



local function partPos(o)

    if o:IsA("BasePart")then return o.Position end

    if o:IsA("Model")then

        local x=o:FindFirstChildWhichIsA("BasePart")

        if x then return x.Position end

    end

    return nil

end

local function fp(names)

    local wanted={}

    for _,n in ipairs(names)do wanted[#wanted+1]=string.lower(n)end

    local partial

    for _,o in ipairs(workspace:GetDescendants())do

        if o:IsA("BasePart")or o:IsA("Model")then

            local n=string.lower(o.Name)

            for _,w in ipairs(wanted)do

                if n==w then

                    local pos=partPos(o)

                    if pos then return pos end

                end

                if not partial and string.find(n,w,1,true)then partial=o end

            end

        end

    end

    if partial then return partPos(partial)end

    return nil

end



-- ═══════════════ TASER BYPASS ═══════════════

local bp,bc=false

local function sb()

    if bc then bc:Disconnect()end

    bc=RS.Heartbeat:Connect(function()

        if not bp then return end

        local ch=p.Character;if not ch then return end

        local h=ch:FindFirstChild("Humanoid")

        if not h then return end

        if h.WalkSpeed<15 then h.WalkSpeed=16 end

        if h.PlatformStand then h.PlatformStand=false end

        if h.JumpPower<50 then h.JumpPower=50 end

        local s=ch:FindFirstChild("StunAnimation")

        if s then pcall(function()s:Destroy()end)end

        for _,o in ipairs(ch:GetDescendants())do

            if o:IsA("BodyVelocity")or o:IsA("BodyGyro")or o:IsA("BodyAngularVelocity")then

                local n=string.lower(o.Name)

                if n:find("stun")or n:find("tase")or n:find("ragdoll")then pcall(function()o:Destroy()end)end

            end

        end

    end)

end



-- ═══════════════ ЦВЕТ КОМАНДЫ ═══════════════

local function gt(pl)

    if pl.Team then

        local c=pl.TeamColor.Color

        if c~=Color3.new(1,1,1)and c~=Color3.new(0,0,0)then return c end

    end

    local ch=pl.Character

    if not ch then return Color3.fromRGB(255,50,50)end

    local s=ch:FindFirstChild("Shirt")

    if s then

        local n=string.lower(s.Name)

        if n:find("police")or n:find("officer")then return Color3.fromRGB(0,120,255)end

        if n:find("prison")or n:find("inmate")then return Color3.fromRGB(255,140,0)end

    end

    return Color3.fromRGB(200,50,50)

end



-- ═══════════════ HIGHLIGHT ═══════════════

local ho,hl,hc=false,{},{}

local function chl()

    for pl,h in pairs(hl)do pcall(function()h:Destroy()end)end

    hl={}

    for pl,c in pairs(hc)do pcall(function()c:Disconnect()end)end

    hc={}

end

local function ah(pl)

    if pl==p or not pl.Character then return end

    if hl[pl]then pcall(function()hl[pl]:Destroy()end)end

    local h=Instance.new("Highlight")

    h.Name="H"h.Adornee=pl.Character

    h.FillColor=gt(pl)h.OutlineColor=Color3.new(1,1,1)

    h.FillTransparency=0.75 h.OutlineTransparency=0

    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop

    h.Parent=pl.Character

    hl[pl]=h

end

local function sh(pl)

    if pl==p then return end

    if pl.Character then pcall(function()ah(pl)end)end

    local c=pl.CharacterAdded:Connect(function()

        if not ho then return end

        task.wait(0.5)

        if not ho then return end

        pcall(function()ah(pl)end)

    end)

    if hc[pl]then pcall(function()hc[pl]:Disconnect()end)end

    hc[pl]=c

end

local function th()

    ho=not ho

    if ho then for _,pl in ipairs(game.Players:GetPlayers())do sh(pl)end

    else chl()end

    return ho

end



-- ═══════════════ DRAWING ESP (угловой бокс) ═══════════════

local ee=false

local eTracer=true

local eName=true

local eDist=true

local eHealth=true

local eHealthOut=true

local eTeam=false

local eDistMax=5000



local boxes={}

local tracers={}

local nameTags={}

local distTags={}

local healthBars={}

local espSetup={}



local function crTxt(s)

    local t=Drawing.new("Text")

    t.Size=s t.Center=true t.Outline=false t.Visible=false

    return t

end

local function crBar()

    local o=Drawing.new("Square")

    o.Thickness=1 o.Filled=true o.Visible=false o.Color=Color3.fromRGB(0,0,0)

    local b=Drawing.new("Square")

    b.Thickness=1 b.Filled=true b.Visible=false b.Color=Color3.fromRGB(0,255,0)

    return{Outline=o,Bar=b}

end

local function crCorners(color)

    local t={}

    for i=1,8 do

        local l=Drawing.new("Line")

        l.Visible=false l.Thickness=1 l.Color=color l.Transparency=1

        t[i]=l

    end

    return t

end

local function isEn(pl)

    if not eTeam then return true end

    return pl.Team~=p.Team

end

local function rmESP(char,pl)

    if boxes[char]then

        if boxes[char].Connection then boxes[char].Connection:Disconnect()end

        if boxes[char].Box then boxes[char].Box:Remove()end

        if boxes[char].Corners then

            for _,l in ipairs(boxes[char].Corners)do pcall(function()l:Remove()end)end

        end

        boxes[char]=nil

    end

    if tracers[char]then

        if tracers[char].Line then tracers[char].Line:Remove()end

        tracers[char]=nil

    end

    if nameTags[pl]then nameTags[pl]:Remove()nameTags[pl]=nil end

    if distTags[pl]then distTags[pl]:Remove()distTags[pl]=nil end

    if healthBars[pl]then

        if healthBars[pl].Outline then healthBars[pl].Outline:Remove()end

        if healthBars[pl].Bar then healthBars[pl].Bar:Remove()end

        healthBars[pl]=nil

    end

end

local function mkESP(char,pl)

    if not char or boxes[char]or pl==p then return end

    local hrp=char:FindFirstChild("HumanoidRootPart")

    local head=char:FindFirstChild("Head")

    local hum=char:FindFirstChild("Humanoid")

    if not hrp or not head or not hum then return end



    local box=Drawing.new("Square")

    box.Visible=false box.Color=Color3.fromRGB(255,255,255)box.Filled=false box.Transparency=1 box.Thickness=1

    local corners=crCorners(Color3.fromRGB(255,255,255))

    local line=Drawing.new("Line")

    line.Visible=false line.Color=Color3.fromRGB(255,255,255)line.Thickness=1 line.Transparency=1

    local nameTag=crTxt(11)

    local distTag=crTxt(11)

    if not healthBars[pl]then healthBars[pl]=crBar()end



    local con

    con=RS.RenderStepped:Connect(function()

        local hb=healthBars[pl]

        local function hideAll()

            box.Visible=false

            for _,l in ipairs(corners)do l.Visible=false end

            line.Visible=false nameTag.Visible=false distTag.Visible=false

            if hb then hb.Outline.Visible=false hb.Bar.Visible=false end

        end

        if not ee then hideAll()return end

        if not isEn(pl)then hideAll()return end

        hrp=char:FindFirstChild("HumanoidRootPart")

        head=char:FindFirstChild("Head")

        hum=char:FindFirstChild("Humanoid")

        if not hrp or not head or not hum then hideAll()return end



        local pos=Cam:WorldToViewportPoint(hrp.Position)

        local top=Cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.6,0))

        local bot=Cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))

        local dist=(Cam.CFrame.Position-hrp.Position).Magnitude



        if pos.Z>0 and dist<=eDistMax then

            local h=math.abs(bot.Y-top.Y)

            local w=math.clamp(h*0.5,12,400)

            local x,y=top.X-w/2,top.Y

            local col=gt(pl)

            local len=math.clamp(math.floor(w/4),4,40)



            local function setLine(l,x1,y1,x2,y2)

                l.From=Vector2.new(x1,y1)l.To=Vector2.new(x2,y2)

                l.Color=col l.Visible=true

            end

            do -- угловой бокс всегда включён (v3)

                box.Size=Vector2.new(w,h)box.Position=Vector2.new(x,y)box.Visible=true

                setLine(corners[1],x,y,x+len,y)

                setLine(corners[2],x,y,x,y+len)

                setLine(corners[3],x+w-len,y,x+w,y)

                setLine(corners[4],x+w,y,x+w,y+len)

                setLine(corners[5],x,y+h-len,x,y+h)

                setLine(corners[6],x,y+h,x+len,y+h)

                setLine(corners[7],x+w,y+h-len,x+w,y+h)

                setLine(corners[8],x+w-len,y+h,x+w,y+h)

            end -- угловой бокс

            if eTracer then line.From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y-50)line.To=Vector2.new(pos.X,pos.Y)line.Visible=true else line.Visible=false end

            if eName then nameTag.Position=Vector2.new(top.X,top.Y-18)nameTag.Text=pl.Name nameTag.Visible=true else nameTag.Visible=false end

            if eDist and R then

                local d=math.floor((hrp.Position-R.Position).Magnitude)

                distTag.Position=Vector2.new(bot.X,bot.Y+4)

                distTag.Text=tostring(d).."m"distTag.Visible=true

            else distTag.Visible=false end



            if eHealth then

                local bh=h local bw=2

                local bx=x-bw-5 local by=y

                local pct=math.clamp(hum.Health/hum.MaxHealth,0,1)

                local fh=bh*pct



                if eHealthOut then hb.Outline.Size=Vector2.new(bw+2,bh+2)hb.Outline.Position=Vector2.new(bx-1,by-1)hb.Outline.Visible=true else hb.Outline.Visible=false end

                hb.Bar.Size=Vector2.new(bw,fh)hb.Bar.Position=Vector2.new(bx,by+(bh-fh))

                if pct<=0.2 then hb.Bar.Color=Color3.fromRGB(255,0,0)elseif pct<=0.65 then hb.Bar.Color=Color3.fromRGB(255,255,0)else hb.Bar.Color=Color3.fromRGB(0,255,0)end

                hb.Bar.Visible=true

            else

                hb.Outline.Visible=false hb.Bar.Visible=false

            end

        else

            hideAll()

        end

    end)



    boxes[char]={Box=box,Corners=corners,Connection=con}

    tracers[char]={Line=line}

    nameTags[pl]=nameTag

    distTags[pl]=distTag

end

local function setupESP(pl)

    if pl==p or espSetup[pl]then return end

    espSetup[pl]=true

    pl.CharacterAdded:Connect(function(ch)

        rmESP(ch,pl)task.wait(0.1)

        ch:WaitForChild("HumanoidRootPart",5)ch:WaitForChild("Head",5)ch:WaitForChild("Humanoid",5)

        mkESP(ch,pl)

    end)

    pl.CharacterRemoving:Connect(function(ch)rmESP(ch,pl)end)

    if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")and pl.Character:FindFirstChild("Head")and pl.Character:FindFirstChild("Humanoid")then

        mkESP(pl.Character,pl)

    end

end

local function toggleESP()

    ee=not ee

    if ee then

        for _,pl in ipairs(game.Players:GetPlayers())do

            if not boxes[pl.Character]then setupESP(pl)end

        end

    end

    return ee

end



-- ═══════════════ NOCLIP + ANTI-FALL ═══════════════

local Clip=true

local Noclip=nil

local Noclip2=nil

local safeY=0

local savedCollide={}

local flying=false

local flySpeed=60

local flyConn,flyBV,flyBG=nil

local infJump=false

local clickTP=false

local lastWS=nil

-- v3.1: машина / анти-арест / вэйпоинты
local carFlying=false

local carSpeed=100

local carConn,carBV,carBG=nil

local antiArrest=false

local aaPos=nil

local aaGrace=false

local waypoints={}



local function noclip()

    Clip=false

    if Noclip then Noclip:Disconnect()end

    if Noclip2 then Noclip2:Disconnect()end



    local ch=p.Character

    if ch then

        for _,v in ipairs(ch:GetDescendants())do

            if v:IsA("BasePart")then savedCollide[v]=v.CanCollide end

        end

    end



    Noclip=RS.Stepped:Connect(function()

        if Clip then return end

        local ch=p.Character

        if not ch then return end

        for _,v in pairs(ch:GetDescendants())do

            if v:IsA("BasePart")then

                if savedCollide[v]==nil then savedCollide[v]=v.CanCollide end

                v.CanCollide=false

            end

        end

    end)



    Noclip2=RS.Heartbeat:Connect(function()

        if Clip then return end

        local ch=p.Character

        if not ch then return end

        local hrp=ch:FindFirstChild("HumanoidRootPart")

        local hum=ch:FindFirstChild("Humanoid")

        if not hrp or not hum then return end



        if hrp.Velocity.Y>-2 then safeY=hrp.Position.Y end

        if hrp.Velocity.Y<-20 then hrp.Velocity=Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z)end

        if hrp.Position.Y<safeY-30 then

            hrp.CFrame=CFrame.new(hrp.Position.X,safeY+3,hrp.Position.Z)

            hrp.Velocity=Vector3.zero

        end

    end)

end



local function clip()

    if Noclip then Noclip:Disconnect()Noclip=nil end

    if Noclip2 then Noclip2:Disconnect()Noclip2=nil end

    Clip=true

    for part,can in pairs(savedCollide)do

        pcall(function()

            if part and part.Parent then part.CanCollide=can end

        end)

    end

    savedCollide={}

end



local function toggleNoclip()

    if Clip then

        safeY=(p.Character and p.Character:FindFirstChild("HumanoidRootPart"))and p.Character.HumanoidRootPart.Position.Y or 0

        noclip()

    else

        clip()

    end

    return not Clip

end



-- ═══════════════ FLY ═══════════════

-- v3.2: ЭКРАННЫЕ КНОПКИ ВЫСОТЫ (для телефона; на ПК тоже работают мышью)

local flyBtnHolder=Instance.new("Frame",S)

flyBtnHolder.Name="FlyBtns"

flyBtnHolder.Size=UDim2.new(0,120,0,56)

flyBtnHolder.Position=UDim2.new(1,-135,1,-70)

flyBtnHolder.BackgroundTransparency=1

flyBtnHolder.Visible=false

local function mkFlyBtn(txt,dx,name)

    local b=Instance.new("TextButton",flyBtnHolder)

    b.Size=UDim2.new(0,56,0,56)

    b.Position=UDim2.new(0,dx,0,0)

    b.Name=name

    b.BackgroundColor3=Color3.fromRGB(30,30,45)

    b.BackgroundTransparency=0.35

    b.Text=txt b.TextColor3=Color3.new(1,1,1)

    b.Font=Enum.Font.SourceSansBold b.TextSize=24

    b.BorderSizePixel=0

    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)

    return b

end

local upHeld,downHeld=false,false

local btnUp=mkFlyBtn("▲",0,"FlyUpBtn")

local btnDown=mkFlyBtn("▼",62,"FlyDownBtn")

local flyUpT=0 -- до какого времени активен «вверх» (от JumpRequest)

local function updateFlyBtns()

    flyBtnHolder.Visible=flying or carFlying

end

local function bindHold(btn,set)

    btn.InputBegan:Connect(function(inp)

        local it=inp.UserInputType

        if it==Enum.UserInputType.Touch or it==Enum.UserInputType.MouseButton1 then

            set(true)

        end

    end)

    UIS.InputEnded:Connect(function(inp)

        local it=inp.UserInputType

        if it==Enum.UserInputType.Touch or it==Enum.UserInputType.MouseButton1 then set(false)end

    end)

end

bindHold(btnUp,function(v)upHeld=v end)

bindHold(btnDown,function(v)downHeld=v end)



-- вертикальная составляющая полёта: Space/▲ (или кнопка прыжка) вверх, Ctrl/▼ вниз

local function flyVertical()

    local up=UIS:IsKeyDown(Enum.KeyCode.Space)or upHeld or (os.clock()<flyUpT)

    local dn=UIS:IsKeyDown(Enum.KeyCode.LeftControl)or downHeld

    if up and not dn then return 1 elseif dn and not up then return -1 end

    return 0

end



local function stopFly()

    flying=false

    if flyConn then flyConn:Disconnect()flyConn=nil end

    if flyBV then pcall(function()flyBV:Destroy()end)flyBV=nil end

    if flyBG then pcall(function()flyBG:Destroy()end)flyBG=nil end

    updateFlyBtns()

end

local function startFly()

    local ch=p.Character

    if not ch then return end

    local hrp=ch:FindFirstChild("HumanoidRootPart")

    local hum=ch:FindFirstChild("Humanoid")

    if not hrp or not hum then return end

    stopFly()

    flying=true

    flyBV=Instance.new("BodyVelocity")

    flyBV.Name="FlyVelocity"

    flyBV.MaxForce=Vector3.new(1e9,1e9,1e9)

    flyBV.Velocity=Vector3.zero

    flyBV.Parent=hrp

    flyBG=Instance.new("BodyGyro")

    flyBG.Name="FlyGyro"

    flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9)

    flyBG.P=9e4

    flyBG.CFrame=hrp.CFrame

    flyBG.Parent=hrp

    hum.PlatformStand=false

    updateFlyBtns()

    flyConn=RS.RenderStepped:Connect(function()

        if not flying then return end

        local ch=p.Character

        if not ch then return end

        local hrp=ch:FindFirstChild("HumanoidRootPart")

        local hum=ch:FindFirstChild("Humanoid")

        if not hrp or not hum or not flyBV or flyBV.Parent~=hrp then return end

        -- v3.2: движение из MoveDirection (тач-стик И WASD дают его автоматически)

        local mv=hum.MoveDirection or Vector3.zero

        local vy=flyVertical()

        local vel=mv*flySpeed+Vector3.new(0,vy*flySpeed*0.8,0)

        if vel.Magnitude>0 then flyBV.Velocity=vel else flyBV.Velocity=Vector3.zero end

        flyBG.CFrame=Cam.CFrame

    end)

end

UIS.JumpRequest:Connect(function()

    if flying or carFlying then flyUpT=os.clock()+0.2 end

end)



-- ═══════════════ CAR FLY (v3.1) ═══════════════

local function carStop()

    carFlying=false

    if carConn then carConn:Disconnect()carConn=nil end

    if carBV then pcall(function()carBV:Destroy()end)carBV=nil end

    if carBG then pcall(function()carBG:Destroy()end)carBG=nil end

    updateFlyBtns()

end

local function carStart()

    local ch=p.Character

    local hum=ch and ch:FindFirstChild("Humanoid")

    local seat=hum and hum.SeatPart

    if not seat or not seat:IsA("BasePart")then

        notify("Сядь в машину",Color3.fromRGB(200,140,40))

        return

    end

    carStop()

    local car=seat.Parent

    local chassis=car and (car:FindFirstChild("Chassis")or car.PrimaryPart)or seat

    carFlying=true

    carBV=Instance.new("BodyVelocity")

    carBV.Name="CarFlyVelocity"

    carBV.MaxForce=Vector3.new(1e9,1e9,1e9)

    carBV.Velocity=Vector3.zero

    carBV.Parent=chassis

    carBG=Instance.new("BodyGyro")

    carBG.Name="CarFlyGyro"

    carBG.MaxTorque=Vector3.new(1e9,1e9,1e9)

    carBG.P=9e4

    carBG.CFrame=chassis.CFrame

    carBG.Parent=chassis

    pcall(function()seat.MaxSpeed=carSpeed end)

    updateFlyBtns()

    carConn=RS.RenderStepped:Connect(function()

        if not carFlying then return end

        local ch=p.Character

        local hum=ch and ch:FindFirstChild("Humanoid")

        if not hum or hum.SeatPart~=seat then carStop()return end

        if not carBV or carBV.Parent==nil then return end

        -- v3.2: газ/руль из VehicleSeat (на телефоне ими управляет тач-стик, на ПК — WASD)

        local throttle=seat.ThrottleFloat or 0

        local steer=seat.SteerFloat or 0

        local cf=Cam.CFrame

        local mv=cf.LookVector*throttle+cf.RightVector*steer

        local vy=flyVertical()

        mv=mv+Vector3.new(0,vy*0.8,0)

        if mv.Magnitude>0.01 then carBV.Velocity=mv.Unit*carSpeed else carBV.Velocity=Vector3.zero end

        carBG.CFrame=cf

    end)

end



-- ═══════════════ ANTI-ARREST (v3.1) ═══════════════

-- Возвращает персонажа на место при резком телепорте (арест/бринк).

-- Собственные телепорты не блокируются (grace-флаг в tp()).

RS.Heartbeat:Connect(function()

    if not antiArrest then return end

    local ch=p.Character

    local hrp=ch and ch:FindFirstChild("HumanoidRootPart")

    if not hrp then aaPos=nil return end

    local pos=hrp.Position

    if aaGrace then

        aaGrace=false

        aaPos=pos

        return

    end

    if not aaPos then

        aaPos=pos

        return

    end

    if (pos-aaPos).Magnitude>60 then

        hrp.CFrame=CFrame.new(aaPos)

        hrp.Velocity=Vector3.zero

        notify("Anti-Arrest: возврат",ACCENT)

        return

    end

    aaPos=pos

end)



-- ═══════════════ INFINITE JUMP ═══════════════

UIS.JumpRequest:Connect(function()

    if not infJump then return end

    local ch=p.Character

    if not ch then return end

    local hum=ch:FindFirstChild("Humanoid")

    if not hum then return end

    pcall(function()hum:ChangeState(Enum.HumanoidStateType.Jumping)end)

end)



-- ═══════════════ ANTI-AFK ═══════════════

local afkConn=nil

local function setAntiAFK(on)

    if afkConn then afkConn:Disconnect()afkConn=nil end

    if on then

        afkConn=p.Idled:Connect(function()

            pcall(function()

                local vu=game:GetService("VirtualUser")

                vu:CaptureController()

                vu:ClickButton2(Vector2.new(0,0))

            end)

        end)

    end

end



-- ═══════════════ CLICK TP (Ctrl+ЛКМ на ПК; ТАП по экрану на телефоне) ═══════════════

UIS.InputBegan:Connect(function(inp,gp)

    if not clickTP or gp then return end

    local it=inp.UserInputType

    local isTap=(it==Enum.UserInputType.Touch)

    local isCtrlClick=(it==Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl))

    if not (isTap or isCtrlClick) then return end

    local okv,pos=pcall(function()return inp.Position end)

    if not okv or not pos then return end

    local okr,ray=pcall(function()return Cam:ViewportPointToRay(pos.X,pos.Y)end)

    if not okr or not ray then return end

    local hit=workspace:Raycast(ray.Origin,ray.Direction*1000)

    if hit and hit.Position then

        tp(hit.Position)

        notify("Click TP",ACCENT)

    end

end)



-- ═══════════════ SPECTATE ═══════════════

local st,sc=nil

local function ss()

    if sc then pcall(function()sc:Disconnect()end)sc=nil end

    st=nil

    pcall(function()

        if p.Character and p.Character:FindFirstChild("Humanoid")then

            workspace.CurrentCamera.CameraSubject=p.Character.Humanoid

        end

    end)

end

local function ns()

    local list={}

    for _,pl in ipairs(game.Players:GetPlayers())do

        if pl~=p and pl.Character and pl.Character:FindFirstChild("Humanoid")then list[#list+1]=pl end

    end

    if #list==0 then return end

    local idx=0

    for k,pl in ipairs(list)do if pl==st then idx=k break end end

    st=list[(idx%#list)+1]

    local h=st.Character and st.Character:FindFirstChild("Humanoid")

    if h then

        pcall(function()workspace.CurrentCamera.CameraSubject=h end)

        if sc then pcall(function()sc:Disconnect()end)end

        sc=h.Died:Connect(function()

            task.wait(0.5)

            ns()

        end)

    end

end



-- ═══════════════ СОБЫТИЯ ИГРОКОВ ═══════════════

game.Players.PlayerAdded:Connect(function(pl)

    if ho then sh(pl)end

    setupESP(pl)

end)

game.Players.PlayerRemoving:Connect(function(pl)

    espSetup[pl]=nil

    if pl.Character then rmESP(pl.Character,pl)end

    pcall(function()

        if hl[pl]then hl[pl]:Destroy()end

        if hc[pl]then hc[pl]:Disconnect()end

        hl[pl]=nil hc[pl]=nil

    end)

    if st==pl then ss()end

end)



-- ═══════════════ КНОПКА ✕ — ПОЛНОЕ ЗАКРЫТИЕ ═══════════════

X.MouseButton1Click:Connect(function()

    if bc then bc:Disconnect()bc=nil end

    bp=false

    stopFly()

    carStop()

    setAntiAFK(false)

    if not Clip then clip()end

    if sc then pcall(function()sc:Disconnect()end)sc=nil end

    st=nil

    chl()

    ee=false

    pcall(function()S:Destroy()end)

end)



-- ═══════════════ НАПОЛНЕНИЕ ТАБОВ ═══════════════

-- Таб 1: Телепорт

local page1=pages[1]

mb(page1,"🔵 Police",Color3.fromRGB(0,80,150),function()local x=fp({"armory","police","gunroom"})if x then tp(x)notify("TP: Police",ACCENT)end end)

mb(page1,"🔴 Criminal",Color3.fromRGB(150,0,0),function()local x=fp({"criminal","gang"})if x then tp(x)notify("TP: Criminal",ACCENT)end end)

mb(page1,"🚪 Exit",Color3.fromRGB(50,120,80),function()local x=fp({"gate","exit"})if x then tp(x)notify("TP: Exit",ACCENT)end end)

mb(page1,"🔒 Cells",Color3.fromRGB(80,80,100),function()local x=fp({"cell","jail"})if x then tp(x)notify("TP: Cells",ACCENT)end end)

mb(page1,"🍽️ Food",Color3.fromRGB(150,120,0),function()local x=fp({"cafeteria","food"})if x then tp(x)notify("TP: Food",ACCENT)end end)

mb(page1,"🔄 Respawn",Color3.fromRGB(120,50,50),function()local h=p.Character and p.Character:FindFirstChild("Humanoid")if h then h.Health=0 end end)

mb(page1,"🌐 Rejoin",Color3.fromRGB(60,60,90),function()

    local okv=pcall(function()

        game:GetService("TeleportService"):Teleport(game.PlaceId,p)

    end)

    if okv then notify("Rejoin...",ACCENT)else notify("Rejoin недоступен",Color3.fromRGB(200,60,60))end

end)



-- v3.1: ВЭЙПОИНТЫ (таб Телепорт)

local wpBtns={}

local function rebuildWP()

    for _,b in ipairs(wpBtns)do pcall(function()b:Destroy()end)end

    wpBtns={}

    for i,wp in ipairs(waypoints)do

        local b=mb(page1,("📍 %s (%d, %d)"):format(wp.name,math.floor(wp.pos.X+0.5),math.floor(wp.pos.Z+0.5)),

            Color3.fromRGB(70,60,110),function()

                tp(wp.pos)

                notify("WP: "..wp.name,ACCENT)

            end)

        wpBtns[#wpBtns+1]=b

    end

end

mb(page1,"💾 Сохранить точку",Color3.fromRGB(60,110,80),function()

    if not R then return end

    if #waypoints>=8 then notify("Максимум 8 точек",Color3.fromRGB(200,140,40))return end

    waypoints[#waypoints+1]={name="Точка "..(#waypoints+1),pos=R.Position}

    rebuildWP()

    notify("Точка сохранена",GREEN)

end)

mb(page1,"🗑️ Очистить точки",Color3.fromRGB(110,60,60),function()

    waypoints={}

    rebuildWP()

    notify("Точки очищены",GREY)

end)



-- Таб 2: Визуал

local page2=pages[2]

sw(page2,"Highlight",function()return ho end,function(v)if v~=ho then th()end end)

sw(page2,"ESP",function()return ee end,function(v)if v~=ee then toggleESP()end end)

sw(page2,"TeamCheck",function()return eTeam end,function(v)eTeam=v end)



-- Таб 3: Прочее

local page3=pages[3]

sw(page3,"TaserBypass",function()return bp end,function(v)

    bp=v

    if v then sb()elseif bc then bc:Disconnect()bc=nil end

end)

sw(page3,"Noclip",function()return not Clip end,function(v)

    if v and Clip then toggleNoclip()elseif not v and not Clip then toggleNoclip()end

end)

sw(page3,"Fly",function()return flying end,function(v)

    if v and not flying then startFly()elseif not v and flying then stopFly()end

end)

sw(page3,"InfJump",function()return infJump end,function(v)infJump=v end)

sw(page3,"AntiAFK",function()return afkConn~=nil end,function(v)setAntiAFK(v)end)

sw(page3,"ClickTP",function()return clickTP end,function(v)clickTP=v end)

sl(page3,"Скорость",8,150,16,function(v)

    lastWS=v

    local h=p.Character and p.Character:FindFirstChild("Humanoid")

    if h then h.WalkSpeed=v end

end)

sl(page3,"Полёт",20,200,60,function(v)flySpeed=v end)

-- v3.1: машина и анти-арест

sw(page3,"CarFly",function()return carFlying end,function(v)

    if v and not carFlying then carStart()elseif not v and carFlying then carStop()end

end)

sw(page3,"AntiArrest",function()return antiArrest end,function(v)

    antiArrest=v

    aaPos=nil

end)

sl(page3,"Машина",30,250,100,function(v)

    carSpeed=v

    local h=p.Character and p.Character:FindFirstChild("Humanoid")

    local s=h and h.SeatPart

    if s and s:IsA("BasePart")then pcall(function()s.MaxSpeed=v end)end

end)

mb(page3,"⏭️ Spectate",Color3.fromRGB(0,100,100),ns)

mb(page3,"⏹️ StopSpec",Color3.fromRGB(150,50,50),ss)

mb(page3,"⌨️ RS/📋-меню | F-полёт | N-noclip | Тап-TP",Color3.fromRGB(40,40,60),function()end)



-- ═══════════════ ХОТКЕИ ═══════════════

UIS.InputBegan:Connect(function(inp,gp)

    if gp then return end

    local kc=inp.KeyCode

    if kc==Enum.KeyCode.RightShift then

        pcall(tg)

    elseif kc==Enum.KeyCode.F then

        pcall(function()flip("Fly")end)

    elseif kc==Enum.KeyCode.N then

        pcall(function()flip("Noclip")end)

    end

end)



-- ═══════════════ ИНИЦИАЛИЗАЦИЯ ═══════════════

for _,pl in ipairs(game.Players:GetPlayers())do setupESP(pl)end



p.CharacterAdded:Connect(function(ch)

    task.wait(0.5)

    u()

    if bp then sb()end

    savedCollide={}

    carStop()

    aaPos=nil

    if not Clip then noclip()end

    if flying then startFly()end

    if lastWS then

        local h=ch and ch:FindFirstChild("Humanoid")

        if h then h.WalkSpeed=lastWS end

    end

end)



print("✅ Prison Life Hub v3.2 loaded")
