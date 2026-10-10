--[[
    ██████╗██╗    ██╗███████╗███╗   ██╗ ██████╗ ███████╗
    ██╔════╝██║    ██║██╔════╝████╗  ██║██╔═══██╗██╔════╝
    ██║     ██║ █╗ ██║█████╗  ██╔██╗ ██║██║   ██║███████╗
    ██║     ██║███╗██║██╔══╝  ██║╚██╗██║██║   ██║╚════██║
    ╚██████╗╚███╔███╔╝███████╗██║ ╚████║╚██████╔╝███████║
     ╚═════╝ ╚══╝╚══╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
    CwenosSCRIPTS • Tower of Hell edition
    loadstring(game:HttpGet("ВАШ_URL"))()
--]]

if _G.CwenosSCRIPTS and _G.CwenosSCRIPTS.Destroy then pcall(_G.CwenosSCRIPTS.Destroy) end

--=================================================================
--  CONFIG
--=================================================================
local CONFIG = {
    Title  = "CwenosSCRIPTS",
    Accent = Color3.fromRGB(120, 100, 255),
    Accent2= Color3.fromRGB(0, 200, 255),
}
local Theme = {
    BG    = Color3.fromRGB(18, 18, 22),
    Top   = Color3.fromRGB(26, 26, 32),
    Card  = Color3.fromRGB(32, 32, 40),
    CardH = Color3.fromRGB(40, 40, 50),
    Text  = Color3.fromRGB(232, 232, 240),
    Sub   = Color3.fromRGB(145, 145, 160),
    Line  = Color3.fromRGB(52, 52, 64),
}

--=================================================================
--  SERVICES
--=================================================================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local VirtualUser      = game:GetService("VirtualUser")
local CoreGui          = game:GetService("CoreGui")

local LP     = Players.LocalPlayer
local parent = (gethui and gethui()) or CoreGui

--=================================================================
--  HELPERS
--=================================================================
local function new(class, props)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do if k ~= "Parent" then i[k] = v end end
    if props and props.Parent then i.Parent = props.Parent end
    return i
end
local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 10), Parent = o }) end
local function stroke(o, c, t, tr) return new("UIStroke", { Color = c or Theme.Line, Thickness = t or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o }) end
local function tween(o, tm, p, s, d) local t = TweenService:Create(o, TweenInfo.new(tm, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), p); t:Play(); return t end
local function grad(o, a, b) return new("UIGradient", { Color = ColorSequence.new(a, b), Parent = o }) end

local Connections = {}
local function connect(sig, fn) local c = sig:Connect(fn); table.insert(Connections, c); return c end

--=================================================================
--  STATE
--=================================================================
local State = { speed = 16, jump = 50, noclip = false, infjump = false, antifly = false }
local Originals = { ambient = Lighting.Ambient, outdoor = Lighting.OutdoorAmbient,
    brightness = Lighting.Brightness, fogend = Lighting.FogEnd, fogstart = Lighting.FogStart }

local function getHum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

--=================================================================
--  SPLASH
--=================================================================
local splash = new("ScreenGui", { Name = "CwenosSplash", IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = parent })
local dim = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(8, 8, 11), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = splash })
local wrap = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(340, 54), BackgroundTransparency = 1, Parent = dim })
local big = new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, Text = CONFIG.Title, TextScaled = true, TextColor3 = Color3.new(1,1,1), TextTransparency = 1, Parent = wrap })
grad(big, CONFIG.Accent, CONFIG.Accent2)
local bigStroke = stroke(big, Color3.new(1,1,1), 2, 1)
local sub = new("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 8), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = "TOWER OF HELL", TextSize = 13, TextColor3 = Theme.Sub, TextTransparency = 1, Parent = wrap })

--=================================================================
--  MAIN GUI
--=================================================================
local gui = new("ScreenGui", { Name = "CwenosSCRIPTS", IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = gui and nil or parent })
gui.Parent = parent

local win = new("CanvasGroup", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(560, 380), BackgroundColor3 = Theme.BG, BorderSizePixel = 0, GroupTransparency = 1, Parent = gui })
corner(win, 12); stroke(win, Theme.Line, 1)

-- top bar ---------------------------------------------------------
local top = new("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Theme.Top, BorderSizePixel = 0, Parent = win })
corner(top, 12)
new("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = Theme.Top, BorderSizePixel = 0, Parent = top })
local brand = new("TextLabel", { Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(0, 260, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, Text = CONFIG.Title, TextSize = 18, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, Parent = top })
grad(brand, CONFIG.Accent, CONFIG.Accent2)

local function topBtn(x, glyph)
    local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = Theme.Card, Font = Enum.Font.GothamBold, Text = glyph, TextSize = 15, TextColor3 = Theme.Sub, AutoButtonColor = false, BorderSizePixel = 0, Parent = top })
    corner(b, 7)
    b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundColor3 = CONFIG.Accent, TextColor3 = Color3.new(1,1,1) }) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundColor3 = Theme.Card, TextColor3 = Theme.Sub }) end)
    return b
end
local btnClose = topBtn(-12, "✕")
local btnMin   = topBtn(-46, "—")

-- tab bar ---------------------------------------------------------
local tabBar = new("Frame", { Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.BG, BorderSizePixel = 0, Parent = win })
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Parent = tabBar })
new("UIPadding", { PaddingLeft = UDim.new(0, 12), Parent = tabBar })

-- content ---------------------------------------------------------
local content = new("Frame", { Position = UDim2.new(0, 0, 0, 82), Size = UDim2.new(1, 0, 1, -82), BackgroundColor3 = Theme.BG, Parent = win })

local pages, tabs, selected = {}, {}, nil
local function selectTab(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
        local t = tabs[n]
        tween(t.btn, 0.18, { BackgroundColor3 = (n == name) and Theme.Card or Theme.BG, TextColor3 = (n == name) and Color3.new(1,1,1) or Theme.Sub })
        tween(t.under, 0.18, { Size = (n == name) and UDim2.new(1, 0, 0, 2) or UDim2.new(0, 0, 0, 2) })
    end
    selected = name
end

local function makeTab(name)
    local btn = new("TextButton", { Size = UDim2.fromOffset(100, 30), BackgroundColor3 = Theme.BG, Font = Enum.Font.GothamMedium, Text = name, TextSize = 14, TextColor3 = Theme.Sub, AutoButtonColor = false, BorderSizePixel = 0, Parent = tabBar })
    corner(btn, 8)
    local under = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, -3), Size = UDim2.new(0, 0, 0, 2), BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0, Parent = btn })
    corner(under, 2)
    local page = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = CONFIG.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = content })
    new("UIPadding", { PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = page })
    new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    pages[name] = page; tabs[name] = { btn = btn, under = under }
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    btn.MouseEnter:Connect(function() if selected ~= name then tween(btn, 0.15, { BackgroundColor3 = Theme.CardH }) end end)
    btn.MouseLeave:Connect(function() if selected ~= name then tween(btn, 0.15, { BackgroundColor3 = Theme.BG }) end end)
    return page
end

--=================================================================
--  CONTROLS
--=================================================================
local function sectionLabel(page, text)
    local l = new("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = string.upper(text), TextSize = 11, TextColor3 = Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left, Parent = page })
    return l
end

local function addToggle(page, cfg)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Parent = page })
    corner(row, 9)
    new("TextLabel", { Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -70, 1, 0), BackgroundTransparency = 1, Text = cfg.name, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local track = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(42, 22), BackgroundColor3 = Theme.BG, BorderSizePixel = 0, Parent = row })
    corner(track, 11)
    local knob = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromRGB(150, 150, 160), Parent = track })
    corner(knob, 8)
    local on = cfg.default and true or false
    local function render(anim)
        local p = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        local tc = on and CONFIG.Accent or Theme.BG
        local kc = on and Color3.new(1,1,1) or Color3.fromRGB(150,150,160)
        if anim then tween(knob,0.16,{Position=p}); tween(track,0.16,{BackgroundColor3=tc}); tween(knob,0.16,{BackgroundColor3=kc})
        else knob.Position=p; track.BackgroundColor3=tc; knob.BackgroundColor3=kc end
    end
    render(false)
    local function set(s, anim) on = s; render(anim); if cfg.callback then task.spawn(cfg.callback, on) end end
    local b = new("TextButton", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "", Parent = row })
    b.MouseButton1Click:Connect(function() set(not on, true) end)
    return { set = set }
end

local function addSlider(page, cfg)
    local mn, mx, st = cfg.min, cfg.max, cfg.step or 1
    local value = cfg.default or mn
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Parent = page })
    corner(row, 9)
    new("TextLabel", { Position = UDim2.new(0, 14, 0, 8), Size = UDim2.new(1, -28, 0, 18), BackgroundTransparency = 1, Text = cfg.name, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local val = new("TextLabel", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 8), Size = UDim2.new(0, 80, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = CONFIG.Accent2, TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
    local track = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, -16), Size = UDim2.new(1, -28, 0, 6), BackgroundColor3 = Theme.BG, BorderSizePixel = 0, Parent = row })
    corner(track, 3)
    local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0, Parent = track })
    corner(fill, 3); grad(fill, CONFIG.Accent, CONFIG.Accent2)
    local knob = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 2, Parent = track })
    corner(knob, 8); stroke(knob, CONFIG.Accent, 2)
    local function apply()
        local rel = (value - mn) / (mx - mn)
        fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, 0, 0.5, 0)
        val.Text = tostring(math.floor(value * 10 + 0.5) / 10) .. (cfg.suffix or "")
    end
    apply()
    local drag = false
    local function fromInput(i)
        local rel = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.clamp(math.floor((mn + rel * (mx - mn)) / st + 0.5) * st, mn, mx)
        apply(); if cfg.callback then cfg.callback(value) end
    end
    connect(track.InputBegan, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; fromInput(i) end end)
    connect(UserInputService.InputChanged, function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromInput(i) end end)
    connect(UserInputService.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    return { set = function(v) value = v; apply() end }
end

local function addButton(page, cfg)
    local b = new("TextButton", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Card, Font = Enum.Font.GothamMedium, Text = cfg.name, TextSize = 14, TextColor3 = Theme.Text, AutoButtonColor = false, BorderSizePixel = 0, Parent = page })
    corner(b, 9)
    b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundColor3 = Theme.CardH }) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundColor3 = Theme.Card }) end)
    b.MouseButton1Click:Connect(function() if cfg.callback then task.spawn(cfg.callback) end end)
    return b
end

--=================================================================
--  NOTIFICATIONS
--=================================================================
local notifyGui = new("ScreenGui", { Name = "CwenosNotify", IgnoreGuiInset = true, ResetOnSpawn = false, Parent = parent })
local nHolder = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16), Size = UDim2.fromOffset(240, 300), BackgroundTransparency = 1, Parent = notifyGui })
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = nHolder })
local function notify(text)
    local f = new("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Theme.Top, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = nHolder })
    corner(f, 8); stroke(f, CONFIG.Accent, 1)
    local bar = new("Frame", { Size = UDim2.fromOffset(3, 38), BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0, Parent = f })
    corner(bar, 2)
    new("TextLabel", { Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -18, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = text, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, Parent = f })
    for _, d in ipairs(f:GetDescendants()) do
        if d:IsA("TextLabel") then tween(d, 0.2, { TextTransparency = 0 }) end
    end
    tween(f, 0.2, { BackgroundTransparency = 0 })
    task.delay(2.4, function()
        tween(f, 0.3, { BackgroundTransparency = 1 })
        for _, d in ipairs(f:GetDescendants()) do
            if d:IsA("TextLabel") then tween(d, 0.3, { TextTransparency = 1 }) end
        end
        task.wait(0.35); f:Destroy()
    end)
end

--=================================================================
--  PLAYER / ToH LOGIC
--=================================================================
local function applySpeed(v) State.speed = v; local h = getHum(); if h then h.WalkSpeed = v end end
local function applyJump(v) State.jump = v; local h = getHum(); if h then h.UseJumpPower = true; h.JumpPower = v end end

connect(LP.CharacterAdded, function(ch)
    local h = ch:WaitForChild("Humanoid", 5)
    task.wait(0.1)
    if h then h.WalkSpeed = State.speed; h.UseJumpPower = true; h.JumpPower = State.jump end
end)

-- Noclip
connect(RunService.Stepped, function()
    if not State.noclip then return end
    local ch = LP.Character; if not ch then return end
    for _, p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
    end
end)

-- Infinite Jump
connect(UserInputService.JumpRequest, function()
    if not State.infjump then return end
    local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Anti-AFK (ToH kicks idle players)
connect(LP.Idled, function()
    if not State.antiafk then return end
    VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
end)

--=================================================================
--  BUILD UI
--=================================================================
-- PLAYER
local pPlayer = makeTab("Player")
sectionLabel(pPlayer, "Movement")
addSlider(pPlayer, { name = "Walk Speed", min = 16, max = 500, default = 16, callback = applySpeed })
addSlider(pPlayer, { name = "Jump Power", min = 50, max = 500, default = 50, callback = applyJump })
addToggle(pPlayer, { name = "Infinite Jump", default = false, callback = function(on) State.infjump = on; notify(on and "Infinite Jump ON" or "Infinite Jump OFF") end })
addToggle(pPlayer, { name = "Noclip", default = false, callback = function(on) State.noclip = on; notify(on and "Noclip ON" or "Noclip OFF") end })
addButton(pPlayer, { name = "Reset to Default", callback = function() applySpeed(16); applyJump(50); notify("Player reset") end })

-- MISC (ToH helpers)
local pMisc = makeTab("Misc")
sectionLabel(pMisc, "Tower of Hell")
addToggle(pMisc, { name = "Anti-AFK", default = true, callback = function(on) State.antiafk = on; notify(on and "Anti-AFK ON" or "Anti-AFK OFF") end })
addToggle(pMisc, { name = "Fullbright", default = false, callback = function(on)
    if on then
        Lighting.Ambient = Color3.fromRGB(178,178,178); Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178); Lighting.Brightness = 2
    else
        Lighting.Ambient = Originals.ambient; Lighting.OutdoorAmbient = Originals.outdoor; Lighting.Brightness = Originals.brightness
    end
    notify(on and "Fullbright ON" or "Fullbright OFF")
end })
addToggle(pMisc, { name = "No Fog", default = false, callback = function(on)
    Lighting.FogEnd = on and 100000 or Originals.fogend
    Lighting.FogStart = on and 0 or Originals.fogstart
    notify(on and "No Fog ON" or "No Fog OFF")
end })

selectTab("Player")

--=================================================================
--  WINDOW DRAG
--=================================================================
do
    local drag, s, sp
    connect(top.InputBegan, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; s = i.Position; sp = win.Position end end)
    connect(UserInputService.InputChanged, function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - s
            win.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    connect(UserInputService.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
end

--=================================================================
--  TOGGLE BUTTON + KEYBIND
--=================================================================
local visible = true
local function setVisible(v)
    visible = v
    if v then
        win.Visible = true; win.Size = UDim2.fromOffset(500, 340); win.GroupTransparency = 1
        tween(win, 0.28, { Size = UDim2.fromOffset(560, 380), GroupTransparency = 0 }, Enum.EasingStyle.Back)
    else
        local t = tween(win, 0.2, { Size = UDim2.fromOffset(500, 340), GroupTransparency = 1 })
        t.Completed:Connect(function() if not visible then win.Visible = false end end)
    end
end
connect(btnMin.MouseButton1Click, function() setVisible(false) end)
connect(btnClose.MouseButton1Click, function() setVisible(false) end)

local floatBtn = new("TextButton", { AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, 20, 0, 20), Size = UDim2.fromOffset(42, 42), BackgroundColor3 = CONFIG.Accent, Font = Enum.Font.GothamBlack, Text = "C", TextSize = 20, TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, Visible = false, Parent = gui })
corner(floatBtn, 21); stroke(floatBtn, Color3.new(1,1,1), 1, 0.6)
connect(floatBtn.MouseButton1Click, function() setVisible(true); floatBtn.Visible = false end)
connect(UserInputService.InputBegan, function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if visible then setVisible(false); floatBtn.Visible = true else setVisible(true); floatBtn.Visible = false end
    end
end)

--=================================================================
--  INTRO
--=================================================================
task.spawn(function()
    tween(dim, 0.35, { BackgroundTransparency = 0 })
    tween(big, 0.55, { TextTransparency = 0, Size = UDim2.fromOffset(700, 110) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(bigStroke, 0.55, { Transparency = 0 })
    task.wait(0.25); tween(sub, 0.5, { TextTransparency = 0 })
    task.wait(1.1)
    tween(big, 0.4, { TextTransparency = 1 }); tween(bigStroke, 0.4, { Transparency = 1 }); tween(sub, 0.35, { TextTransparency = 1 })
    task.wait(0.15); setVisible(true); tween(dim, 0.5, { BackgroundTransparency = 1 })
    task.wait(0.5); splash:Destroy()
end)

--=================================================================
--  DESTROY
--=================================================================
_G.CwenosSCRIPTS = {
    Destroy = function()
        for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
        pcall(function() splash:Destroy() end); pcall(function() gui:Destroy() end); pcall(function() notifyGui:Destroy() end)
        _G.CwenosSCRIPTS = nil
    end,
}