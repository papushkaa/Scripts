--[[ Basketball Legends — Q→Auto-E Macro
     Press Q → script holds E for 348ms (perfect timing)
     RightShift: open/close  ·  Credit: Loganx  ]]

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local Tween        = game:GetService("TweenService")
local VIM          = game:GetService("VirtualInputManager")
local SoundService = game:GetService("SoundService")
local LP           = Players.LocalPlayer
local pg           = LP:WaitForChild("PlayerGui")

local CONFIG = {
    ToggleKey   = Enum.KeyCode.RightShift,
    TriggerKey  = Enum.KeyCode.Q,
    HoldKey     = Enum.KeyCode.E,
}

local State = {
    enabled    = true,
    holdTimeMs = 348,   -- perfect timing
}

for _, n in ipairs({"BLMacro","BLMacroDebug"}) do
    local o = pg:FindFirstChild(n); if o then o:Destroy() end
end

-- ============ PALETTE ============
local P = {
    bg=Color3.fromRGB(14,17,24),      panel=Color3.fromRGB(22,27,38),
    panel2=Color3.fromRGB(30,37,52),  hover=Color3.fromRGB(44,54,74),
    text=Color3.fromRGB(232,238,248), sub=Color3.fromRGB(140,155,178),
    accent=Color3.fromRGB(255,140,50), accent2=Color3.fromRGB(255,180,100),
    green=Color3.fromRGB(52,199,123), stroke=Color3.fromRGB(58,70,92),
}

-- ============ ROOT ============
local gui = Instance.new("ScreenGui")
gui.Name = "BLMacro"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 50
gui.Parent = pg

local hub = Instance.new("CanvasGroup")
hub.Size = UDim2.new(0, 300, 0, 220)
hub.Position = UDim2.new(0, 24, 0, 40)
hub.BackgroundColor3 = P.bg
hub.BackgroundTransparency = 0.03
hub.GroupTransparency = 0
hub.BorderSizePixel = 0
hub.Active = true
hub.Draggable = true
hub.Parent = gui
Instance.new("UICorner", hub).CornerRadius = UDim.new(0, 14)

local uiScale = Instance.new("UIScale"); uiScale.Parent = hub

local hubStroke = Instance.new("UIStroke")
hubStroke.Color = P.accent; hubStroke.Thickness = 1
hubStroke.Transparency = 0.4; hubStroke.Parent = hub

local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, P.accent),
    ColorSequenceKeypoint.new(1, P.accent2),
}
grad.Rotation = 45; grad.Parent = hubStroke

-- ============ HEADER ============
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 30, 0, 30); logo.Position = UDim2.new(0, 14, 0, 12)
logo.BackgroundColor3 = P.panel2; logo.Text = "🏀"
logo.TextSize = 16; logo.Font = Enum.Font.GothamBold; logo.TextColor3 = P.text
logo.Parent = hub; Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 130, 0, 18); title.Position = UDim2.new(0, 52, 0, 12)
title.BackgroundTransparency = 1; title.Text = "Q → E Macro"
title.TextColor3 = P.text; title.Font = Enum.Font.GothamBold
title.TextSize = 15; title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = hub

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 130, 0, 14); subtitle.Position = UDim2.new(0, 52, 0, 28)
subtitle.BackgroundTransparency = 1; subtitle.Text = "Basketball Legends"
subtitle.TextColor3 = P.sub; subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10; subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = hub

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 28, 0, 28); avatar.Position = UDim2.new(1, -42, 0, 14)
avatar.BackgroundColor3 = P.panel2; avatar.BorderSizePixel = 0
avatar.Image = ""; avatar.Parent = hub
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
local avStroke = Instance.new("UIStroke")
avStroke.Color = P.accent2; avStroke.Thickness = 1; avStroke.Transparency = 0.5
avStroke.Parent = avatar

local userLbl = Instance.new("TextLabel")
userLbl.Size = UDim2.new(0, 110, 0, 14); userLbl.Position = UDim2.new(1, -160, 0, 21)
userLbl.BackgroundTransparency = 1; userLbl.Text = "@" .. LP.Name
userLbl.TextColor3 = P.sub; userLbl.Font = Enum.Font.Gotham
userLbl.TextSize = 10; userLbl.TextXAlignment = Enum.TextXAlignment.Right
userLbl.TextTruncate = Enum.TextTruncate.AtEnd; userLbl.Parent = hub

task.spawn(function()
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId,
            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and url then avatar.Image = url end
end)

-- ============ BUILDERS ============
local function sectionLabel(y, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -28, 0, 14); l.Position = UDim2.new(0, 14, 0, y)
    l.BackgroundTransparency = 1; l.Text = text
    l.TextColor3 = P.sub; l.Font = Enum.Font.GothamBold
    l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = hub
end

local function makeSlider(y, label, minV, maxV, default, suffix, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -28, 0, 40); row.Position = UDim2.new(0, 14, 0, y)
    row.BackgroundColor3 = P.panel; row.BorderSizePixel = 0; row.Parent = hub
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 0, 14); lbl.Position = UDim2.new(0, 12, 0, 5)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = P.text; lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.35, 0, 0, 14); val.Position = UDim2.new(0.6, 0, 0, 5)
    val.BackgroundTransparency = 1; val.Text = tostring(default) .. (suffix or "")
    val.TextColor3 = P.accent2; val.Font = Enum.Font.GothamBold
    val.TextSize = 11; val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6); track.Position = UDim2.new(0, 12, 0, 26)
    track.BackgroundColor3 = P.panel2; track.BorderSizePixel = 0; track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = P.accent; fill.BorderSizePixel = 0; fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - minV) / (maxV - minV), 0, 0.5, -7)
    knob.AnchorPoint = Vector2.new(0.5, 0); knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0; knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function apply(mouseX)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        local pct = math.clamp((mouseX - absPos) / absSize, 0, 1)
        local v = minV + pct * (maxV - minV)
        v = math.floor(v + 0.5)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, -7)
        val.Text = tostring(v) .. (suffix or "")
        if onChange then onChange(v) end
    end

    local catcher = Instance.new("TextButton")
    catcher.Size = UDim2.new(1, 20, 0, 20); catcher.Position = UDim2.new(0, -10, 0, 18)
    catcher.BackgroundTransparency = 1; catcher.Text = ""; catcher.Parent = row
    catcher.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; apply(input.Position.X)
        end
    end)
    catcher.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                      or input.UserInputType == Enum.UserInputType.Touch) then
            apply(input.Position.X)
        end
    end)
end

local function makeToggle(y, emoji, label, initial, onChanged)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -28, 0, 34); row.Position = UDim2.new(0, 14, 0, y)
    row.BackgroundColor3 = P.panel; row.BorderSizePixel = 0; row.Parent = hub
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local e = Instance.new("TextLabel")
    e.Size = UDim2.new(0, 30, 1, 0); e.Position = UDim2.new(0, 4, 0, 0)
    e.BackgroundTransparency = 1; e.Text = emoji; e.TextSize = 14
    e.Font = Enum.Font.Gotham; e.Parent = row

    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(1, -110, 1, 0); n.Position = UDim2.new(0, 36, 0, 0)
    n.BackgroundTransparency = 1; n.Text = label
    n.TextColor3 = P.text; n.Font = Enum.Font.GothamMedium
    n.TextSize = 12; n.TextXAlignment = Enum.TextXAlignment.Left; n.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 42, 0, 22)
    track.Position = UDim2.new(1, -50, 0.5, -11)
    track.BackgroundColor3 = P.panel2; track.BorderSizePixel = 0; track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local ts = Instance.new("UIStroke")
    ts.Color = P.stroke; ts.Thickness = 1; ts.Transparency = 0.4; ts.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200,210,225)
    knob.BorderSizePixel = 0; knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0); click.BackgroundTransparency = 1
    click.Text = ""; click.Parent = row

    local on = initial or false
    local function render(animate)
        local info = animate and TweenInfo.new(0.22, Enum.EasingStyle.Quint) or TweenInfo.new(0)
        Tween:Create(track, info, {BackgroundColor3 = on and P.accent or P.panel2}):Play()
        Tween:Create(ts, info, {
            Color = on and P.accent2 or P.stroke,
            Transparency = on and 0.1 or 0.4,
        }):Play()
        Tween:Create(knob, info, {
            Position = on and UDim2.new(0, 23, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(200,210,225),
        }):Play()
    end
    render(false)

    click.MouseButton1Click:Connect(function()
        on = not on; render(true)
        if onChanged then onChanged(on) end
    end)
    click.MouseEnter:Connect(function()
        Tween:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = P.hover}):Play()
    end)
    click.MouseLeave:Connect(function()
        Tween:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = P.panel}):Play()
    end)
end

-- ============ BUILD UI ============
local y = 52

sectionLabel(y, "MACRO"); y += 16
makeToggle(y, "🏀", "Q → Auto-Hold E", true, function(v)
    State.enabled = v
    refreshStatus()
end); y += 42

sectionLabel(y, "E HOLD DURATION"); y += 16

makeSlider(y, "Hold Time", 100, 1500, 348, " ms", function(v)
    State.holdTimeMs = v
end); y += 42

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 16); status.Position = UDim2.new(0, 14, 0, y)
status.BackgroundTransparency = 1; status.Text = "● Armed"
status.TextColor3 = P.green; status.Font = Enum.Font.GothamMedium
status.TextSize = 11; status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = hub; y += 18

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, -28, 0, 14); infoLbl.Position = UDim2.new(0, 14, 0, y)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "Press Q to trigger  ·  348ms"
infoLbl.TextColor3 = P.sub; infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = 10; infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.Parent = hub

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -28, 0, 14); credit.Position = UDim2.new(0, 14, 1, -22)
credit.BackgroundTransparency = 1; credit.Text = "·  Script by Loganx"
credit.TextColor3 = Color3.fromRGB(140, 165, 200)
credit.Font = Enum.Font.GothamBold; credit.TextSize = 10
credit.TextXAlignment = Enum.TextXAlignment.Left; credit.Parent = hub

function refreshStatus()
    if State.enabled then
        status.Text = "● Armed"
        status.TextColor3 = P.green
    else
        status.Text = "○ Disabled"
        status.TextColor3 = P.sub
    end
end

-- ============ MACRO LOGIC ============
local macroRunning = false

local function runMacro()
    if macroRunning then return end
    macroRunning = true

    pcall(function()
        VIM:SendKeyEvent(true, CONFIG.HoldKey, false, game)
    end)

    task.delay(State.holdTimeMs / 1000, function()
        pcall(function()
            VIM:SendKeyEvent(false, CONFIG.HoldKey, false, game)
        end)
        macroRunning = false
    end)
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not State.enabled then return end
    if input.KeyCode == CONFIG.TriggerKey then
        runMacro()
    end
end)

-- ============ SOUNDS ============
local function newSound(id, vol, speed)
    local s = Instance.new("Sound")
    s.SoundId = id; s.Volume = vol
    s.PlaybackSpeed = speed or 1
    s.Parent = SoundService
    return s
end

local WOOSH_ID = "rbxassetid://6042053626"
local DING_ID  = "rbxassetid://876939830"

local openSound  = newSound(WOOSH_ID, 0.65, 1.15)
local closeSound = newSound(WOOSH_ID, 0.6,  0.9)
local dingSound  = newSound(DING_ID,  0.85, 1.0)

task.spawn(function()
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({openSound, closeSound, dingSound})
    end)
end)

local function playDing()
    if not dingSound.IsLoaded then
        local t0 = os.clock()
        while not dingSound.IsLoaded and os.clock() - t0 < 3 do task.wait(0.05) end
    end
    local v = dingSound.Volume
    dingSound.Volume = 0; dingSound.TimePosition = 0; dingSound:Play()
    task.wait(0.03); dingSound:Stop()
    dingSound.Volume = v; dingSound.TimePosition = 0; dingSound:Play()
end

-- ============ FADE + OPEN/CLOSE ============
local hubOpen = true

local function fadeIn(dur)
    dur = dur or 0.42
    hub.Visible = true
    Tween:Create(hub, TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        GroupTransparency = 0, BackgroundTransparency = 0.03,
    }):Play()
    Tween:Create(hubStroke, TweenInfo.new(dur), {Transparency = 0.4}):Play()
end

local function fadeOut(dur)
    dur = dur or 0.28
    Tween:Create(hub, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        GroupTransparency = 1, BackgroundTransparency = 1,
    }):Play()
    Tween:Create(hubStroke, TweenInfo.new(dur), {Transparency = 1}):Play()
    task.delay(dur + 0.02, function()
        if not hubOpen then hub.Visible = false end
    end)
end

local function playOpen()
    openSound:Play()
    uiScale.Scale = 0.92
    hub.GroupTransparency = 1; hub.BackgroundTransparency = 1
    hubStroke.Transparency = 1
    fadeIn(0.42)
    Tween:Create(uiScale, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Scale = 1}):Play()
end

local function playClose()
    closeSound:Play()
    Tween:Create(uiScale, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Scale = 0.94}):Play()
    fadeOut(0.28)
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == CONFIG.ToggleKey then
        hubOpen = not hubOpen
        if hubOpen then playOpen() else playClose() end
    end
end)

-- ============ INTRO ============
task.spawn(function()
    local vp = workspace.CurrentCamera.ViewportSize
    local w, h = hub.Size.X.Offset, hub.Size.Y.Offset

    local HOME_X = 140
    local HOME_Y = math.floor(vp.Y * 0.16)

    hub.Position = UDim2.new(0, vp.X/2 - w/2, 0, vp.Y/2 - h/2)
    hub.Visible = true
    hub.GroupTransparency = 1
    hub.BackgroundTransparency = 1
    hubStroke.Transparency = 1
    uiScale.Scale = 0.88

    task.wait(0.35)
    playDing()

    Tween:Create(hub, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        GroupTransparency = 0, BackgroundTransparency = 0.03,
    }):Play()
    Tween:Create(hubStroke, TweenInfo.new(0.55), {Transparency = 0.4}):Play()
    Tween:Create(uiScale, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Scale = 1}):Play()

    task.wait(1.2)
    Tween:Create(hub, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
        {Position = UDim2.new(0, HOME_X, 0, HOME_Y)}):Play()
end)

refreshStatus()
print("[BLMacro] Loaded. Press Q → E held for 348ms. RightShift = hub.")
