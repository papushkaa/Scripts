--[[ Click-to-TP Hub
     Hold Ctrl + Left Click to teleport
     Crosshair sits exactly on the mouse cursor
     RightShift: open/close with smooth fade + woosh
     Credit: Loganx  ]]

local Players         = game:GetService("Players")
local UIS             = game:GetService("UserInputService")
local Run             = game:GetService("RunService")
local Tween           = game:GetService("TweenService")
local SoundService    = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local LP              = Players.LocalPlayer
local Cam             = workspace.CurrentCamera
local pg              = LP:WaitForChild("PlayerGui")

local CONFIG = {
    ToggleKey = Enum.KeyCode.RightShift,
    MaxRange  = 2000,   -- raycast range for teleport target
    Offset    = 3.5,    -- studs above the hit surface
    Accent    = Color3.fromRGB(90, 200, 255),
}

local State = { enabled = true }

for _, n in ipairs({"ClickTP","ClickTPHub","ClickTP_Crosshair"}) do
    local o = pg:FindFirstChild(n); if o then o:Destroy() end
end

-- =====================================================
--  PALETTE
-- =====================================================
local P = {
    bg=Color3.fromRGB(14,17,24),      panel=Color3.fromRGB(22,27,38),
    panel2=Color3.fromRGB(30,37,52),  hover=Color3.fromRGB(44,54,74),
    text=Color3.fromRGB(232,238,248), sub=Color3.fromRGB(140,155,178),
    accent=Color3.fromRGB(96,165,250), accent2=Color3.fromRGB(147,197,253),
    green=Color3.fromRGB(52,199,123), stroke=Color3.fromRGB(58,70,92),
}

-- =====================================================
--  HUB
-- =====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ClickTPHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

local hub = Instance.new("CanvasGroup")
hub.Size = UDim2.new(0, 288, 0, 148)
hub.Position = UDim2.new(0, 24, 0, 40)
hub.BackgroundColor3 = P.bg
hub.BackgroundTransparency = 0.03
hub.GroupTransparency = 0
hub.BorderSizePixel = 0
hub.Active = true
hub.Draggable = true
hub.Parent = gui
Instance.new("UICorner", hub).CornerRadius = UDim.new(0, 14)

local DEFAULT_POS = UDim2.new(0, 24, 0, 40)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = hub

local hubStroke = Instance.new("UIStroke")
hubStroke.Color = P.accent
hubStroke.Thickness = 1
hubStroke.Transparency = 0.4
hubStroke.Parent = hub

local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, P.accent),
    ColorSequenceKeypoint.new(1, P.accent2),
}
grad.Rotation = 45
grad.Parent = hubStroke

-- Header
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 30, 0, 30); logo.Position = UDim2.new(0, 14, 0, 10)
logo.BackgroundColor3 = P.panel2; logo.Text = "🎯"
logo.TextSize = 16; logo.Font = Enum.Font.GothamBold; logo.TextColor3 = P.text
logo.Parent = hub; Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 130, 0, 18); title.Position = UDim2.new(0, 52, 0, 10)
title.BackgroundTransparency = 1; title.Text = "Click Teleport"
title.TextColor3 = P.text; title.Font = Enum.Font.GothamBold
title.TextSize = 15; title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = hub

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 130, 0, 14); subtitle.Position = UDim2.new(0, 52, 0, 26)
subtitle.BackgroundTransparency = 1; subtitle.Text = "Ctrl + Left Click"
subtitle.TextColor3 = P.sub; subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10; subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = hub

-- Avatar + username
local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 28, 0, 28)
avatar.Position = UDim2.new(1, -42, 0, 12)
avatar.BackgroundColor3 = P.panel2
avatar.BorderSizePixel = 0
avatar.Image = ""
avatar.Parent = hub
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

local avatarStroke = Instance.new("UIStroke")
avatarStroke.Color = P.accent2
avatarStroke.Thickness = 1
avatarStroke.Transparency = 0.5
avatarStroke.Parent = avatar

local userLbl = Instance.new("TextLabel")
userLbl.Size = UDim2.new(0, 110, 0, 14)
userLbl.Position = UDim2.new(1, -160, 0, 19)
userLbl.BackgroundTransparency = 1
userLbl.Text = "@" .. LP.Name
userLbl.TextColor3 = P.sub
userLbl.Font = Enum.Font.Gotham
userLbl.TextSize = 10
userLbl.TextXAlignment = Enum.TextXAlignment.Right
userLbl.TextTruncate = Enum.TextTruncate.AtEnd
userLbl.Parent = hub

task.spawn(function()
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId,
            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and url then avatar.Image = url end
end)

-- Toggle row
local toggleRow = Instance.new("Frame")
toggleRow.Size = UDim2.new(1, -28, 0, 50)
toggleRow.Position = UDim2.new(0, 14, 0, 50)
toggleRow.BackgroundColor3 = P.panel
toggleRow.BorderSizePixel = 0
toggleRow.Parent = hub
Instance.new("UICorner", toggleRow).CornerRadius = UDim.new(0, 10)

local toggleIcon = Instance.new("TextLabel")
toggleIcon.Size = UDim2.new(0, 34, 1, 0)
toggleIcon.Position = UDim2.new(0, 6, 0, 0)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Text = "⏻"
toggleIcon.TextSize = 20
toggleIcon.TextColor3 = P.sub
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.Parent = toggleRow

local toggleLbl = Instance.new("TextLabel")
toggleLbl.Size = UDim2.new(1, -130, 1, 0)
toggleLbl.Position = UDim2.new(0, 44, 0, 0)
toggleLbl.BackgroundTransparency = 1
toggleLbl.Text = "Click Teleport"
toggleLbl.TextColor3 = P.text
toggleLbl.Font = Enum.Font.GothamBold
toggleLbl.TextSize = 13
toggleLbl.TextXAlignment = Enum.TextXAlignment.Left
toggleLbl.Parent = toggleRow

local track = Instance.new("Frame")
track.Size = UDim2.new(0, 48, 0, 26)
track.Position = UDim2.new(1, -60, 0.5, -13)
track.BackgroundColor3 = P.panel2
track.BorderSizePixel = 0
track.Parent = toggleRow
Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

local trackStroke = Instance.new("UIStroke")
trackStroke.Color = P.stroke; trackStroke.Thickness = 1
trackStroke.Transparency = 0.4; trackStroke.Parent = track

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(0, 3, 0.5, -10)
knob.BackgroundColor3 = Color3.fromRGB(200, 210, 225)
knob.BorderSizePixel = 0; knob.Parent = track
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

local click = Instance.new("TextButton")
click.Size = UDim2.new(1, 0, 1, 0)
click.BackgroundTransparency = 1
click.Text = ""
click.Parent = toggleRow

-- Status + credit
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 16)
status.Position = UDim2.new(0, 14, 0, 106)
status.BackgroundTransparency = 1
status.Text = "○ Idle"
status.TextColor3 = P.sub
status.Font = Enum.Font.GothamMedium
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = hub

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 6, 0, 6)
statusDot.Position = UDim2.new(1, -20, 0, 111)
statusDot.BackgroundColor3 = P.sub
statusDot.BorderSizePixel = 0
statusDot.Parent = hub
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -28, 0, 14)
credit.Position = UDim2.new(0, 14, 1, -20)
credit.BackgroundTransparency = 1
credit.Text = "·  Script by Loganx"
credit.TextColor3 = Color3.fromRGB(140, 165, 200)
credit.Font = Enum.Font.GothamBold
credit.TextSize = 10
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Parent = hub

-- =====================================================
--  TOGGLE LOGIC
-- =====================================================
local function renderToggle(animate)
    local on = State.enabled
    local info = animate and TweenInfo.new(0.25, Enum.EasingStyle.Quint)
                          or TweenInfo.new(0)

    Tween:Create(track, info, {BackgroundColor3 = on and P.green or P.panel2}):Play()
    Tween:Create(trackStroke, info, {
        Color = on and P.green or P.stroke,
        Transparency = on and 0.1 or 0.4,
    }):Play()
    Tween:Create(knob, info, {
        Position = on and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
        BackgroundColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(200, 210, 225),
    }):Play()
    Tween:Create(toggleIcon, info, {TextColor3 = on and P.green or P.sub}):Play()

    status.Text = on and "● Armed  —  hold Ctrl and click" or "○ Idle"
    status.TextColor3 = on and P.green or P.sub
    Tween:Create(statusDot, info, {BackgroundColor3 = on and P.green or P.sub}):Play()
end

click.MouseButton1Click:Connect(function()
    State.enabled = not State.enabled
    renderToggle(true)
    crosshair.Visible = State.enabled
end)
click.MouseEnter:Connect(function()
    Tween:Create(toggleRow, TweenInfo.new(0.15), {BackgroundColor3 = P.hover}):Play()
end)
click.MouseLeave:Connect(function()
    Tween:Create(toggleRow, TweenInfo.new(0.15), {BackgroundColor3 = P.panel}):Play()
end)

-- =====================================================
--  CROSSHAIR  (screen-space, exactly on mouse)
-- =====================================================
local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = "ClickTP_Crosshair"
crosshairGui.ResetOnSpawn = false
crosshairGui.IgnoreGuiInset = true
crosshairGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
crosshairGui.DisplayOrder = 100
crosshairGui.Parent = pg

local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 34, 0, 34)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1
crosshair.Parent = crosshairGui

-- ring
local ring = Instance.new("Frame")
ring.Size = UDim2.new(1, 0, 1, 0)
ring.BackgroundTransparency = 1
ring.Parent = crosshair
Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

local ringStroke = Instance.new("UIStroke")
ringStroke.Color = CONFIG.Accent
ringStroke.Thickness = 1.5
ringStroke.Transparency = 0.2
ringStroke.Parent = ring

-- center dot
local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 4, 0, 4)
dot.Position = UDim2.new(0.5, -2, 0.5, -2)
dot.BackgroundColor3 = CONFIG.Accent
dot.BorderSizePixel = 0
dot.Parent = crosshair
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

-- four ticks
local function tick(size, pos)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = CONFIG.Accent
    f.BorderSizePixel = 0
    f.Parent = crosshair
    Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
end
tick(UDim2.new(0, 2, 0, 7), UDim2.new(0.5, -1, 0, -1))
tick(UDim2.new(0, 2, 0, 7), UDim2.new(0.5, -1, 1, -6))
tick(UDim2.new(0, 7, 0, 2), UDim2.new(0, -1, 0.5, -1))
tick(UDim2.new(0, 7, 0, 2), UDim2.new(1, -6, 0.5, -1))

-- fade helper
local function setCrosshairValid(valid)
    local col = valid and CONFIG.Accent or Color3.fromRGB(200, 90, 90)
    local tr  = valid and 0.2 or 0.5
    ringStroke.Color = col
    ringStroke.Transparency = tr
    dot.BackgroundColor3 = col
    for _, c in ipairs(crosshair:GetChildren()) do
        if c:IsA("Frame") and c ~= ring and c ~= dot then
            c.BackgroundColor3 = col
            c.BackgroundTransparency = valid and 0 or 0.3
        end
    end
end

-- =====================================================
--  RAYCAST + TELEPORT
-- =====================================================
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude
rp.FilterDescendantsInstances = {crosshairGui}

local function castFromMouse()
    local filter = {crosshairGui}
    if LP.Character then table.insert(filter, LP.Character) end
    rp.FilterDescendantsInstances = filter

    local mp  = UIS:GetMouseLocation()
    local ray = Cam:ViewportPointToRay(mp.X, mp.Y)
    return workspace:Raycast(ray.Origin, ray.Direction * CONFIG.MaxRange, rp)
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not State.enabled then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not (UIS:IsKeyDown(Enum.KeyCode.LeftControl)
         or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then return end

    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local result = castFromMouse()
    if result then
        hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, CONFIG.Offset, 0))
    end
end)

-- =====================================================
--  CROSSHAIR UPDATE  (screen-space, exact mouse position)
-- =====================================================
Run.RenderStepped:Connect(function()
    if not State.enabled then
        if crosshair.Visible then crosshair.Visible = false end
        return
    end

    local mp = UIS:GetMouseLocation()
    crosshair.Position = UDim2.new(0, mp.X, 0, mp.Y)
    if not crosshair.Visible then crosshair.Visible = true end

    local result = castFromMouse()
    setCrosshairValid(result ~= nil)
end)

-- =====================================================
--  SOUNDS  (SoundService + preloaded)
-- =====================================================
local function newSound(id, vol, speed)
    local s = Instance.new("Sound")
    s.SoundId       = id
    s.Volume        = vol
    s.PlaybackSpeed = speed or 1
    s.Parent        = SoundService
    return s
end

local WOOSH_ID = "rbxassetid://6042053626"
local DING_ID  = "rbxassetid://876939830"

local openSound  = newSound(WOOSH_ID, 0.65, 1.15)
local closeSound = newSound(WOOSH_ID, 0.6,  0.9)
local dingSound  = newSound(DING_ID,  0.85, 1.0)

task.spawn(function()
    pcall(function()
        ContentProvider:PreloadAsync({openSound, closeSound, dingSound})
    end)
end)

local function playDing()
    if not dingSound.IsLoaded then
        local t0 = os.clock()
        while not dingSound.IsLoaded and os.clock() - t0 < 3 do
            task.wait(0.05)
        end
    end
    local realVol = dingSound.Volume
    dingSound.Volume = 0
    dingSound.TimePosition = 0
    dingSound:Play()
    task.wait(0.03)
    dingSound:Stop()
    dingSound.Volume = realVol
    dingSound.TimePosition = 0
    dingSound:Play()
end

-- =====================================================
--  FADE ENGINE + OPEN/CLOSE
-- =====================================================
local hubOpen = true

local function fadeIn(dur)
    dur = dur or 0.42
    hub.Visible = true
    Tween:Create(hub, TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
        BackgroundTransparency = 0.03,
    }):Play()
    Tween:Create(hubStroke, TweenInfo.new(dur), {Transparency = 0.4}):Play()
end

local function fadeOut(dur)
    dur = dur or 0.28
    Tween:Create(hub, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        GroupTransparency = 1,
        BackgroundTransparency = 1,
    }):Play()
    Tween:Create(hubStroke, TweenInfo.new(dur), {Transparency = 1}):Play()
    task.delay(dur + 0.02, function()
        if not hubOpen then hub.Visible = false end
    end)
end

local function playOpen()
    openSound:Play()
    uiScale.Scale = 0.92
    hub.GroupTransparency = 1
    hub.BackgroundTransparency = 1
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

-- =====================================================
--  INTRO: centered fade-in + ding, short gentle slide
-- =====================================================
task.spawn(function()
    local vp = workspace.CurrentCamera.ViewportSize
    local w  = hub.Size.X.Offset
    local h  = hub.Size.Y.Offset

    local HOME_X = 140
    local HOME_Y = math.floor(vp.Y * 0.16)

    local cx = vp.X/2 - w/2
    local cy = vp.Y/2 - h/2

    hub.Position = UDim2.new(0, cx, 0, cy)
    hub.Visible = true
    hub.GroupTransparency = 1
    hub.BackgroundTransparency = 1
    hubStroke.Transparency = 1
    uiScale.Scale = 0.88

    task.wait(0.35)
    playDing()

    Tween:Create(hub, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
        BackgroundTransparency = 0.03,
    }):Play()
    Tween:Create(hubStroke, TweenInfo.new(0.55), {Transparency = 0.4}):Play()
    Tween:Create(uiScale, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Scale = 1}):Play()

    task.wait(1.2)

    Tween:Create(hub, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
        {Position = UDim2.new(0, HOME_X, 0, HOME_Y)}):Play()

    DEFAULT_POS = UDim2.new(0, HOME_X, 0, HOME_Y)
end)

-- =====================================================
--  WELCOME NOTIFICATION  (bottom-right)
-- =====================================================
do
    local note = Instance.new("Frame")
    note.Size = UDim2.new(0, 280, 0, 74)
    note.Position = UDim2.new(1, 320, 1, -100)
    note.BackgroundColor3 = Color3.fromRGB(18, 23, 32)
    note.BackgroundTransparency = 0.05
    note.BorderSizePixel = 0
    note.ZIndex = 10
    note.Parent = gui
    Instance.new("UICorner", note).CornerRadius = UDim.new(0, 10)

    local nStroke = Instance.new("UIStroke")
    nStroke.Color = Color3.fromRGB(96, 165, 250)
    nStroke.Thickness = 1
    nStroke.Transparency = 0.35
    nStroke.Parent = note

    local nGrad = Instance.new("UIGradient")
    nGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 165, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 197, 253)),
    }
    nGrad.Rotation = 45
    nGrad.Parent = nStroke

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -16)
    accentBar.Position = UDim2.new(0, 8, 0, 8)
    accentBar.BackgroundColor3 = Color3.fromRGB(96, 165, 250)
    accentBar.BorderSizePixel = 0
    accentBar.Parent = note
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    local nIcon = Instance.new("TextLabel")
    nIcon.Size = UDim2.new(0, 40, 0, 40)
    nIcon.Position = UDim2.new(0, 18, 0, 17)
    nIcon.BackgroundColor3 = Color3.fromRGB(30, 37, 52)
    nIcon.Text = "🎯"
    nIcon.TextSize = 20
    nIcon.Font = Enum.Font.GothamBold
    nIcon.Parent = note
    Instance.new("UICorner", nIcon).CornerRadius = UDim.new(0, 8)

    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -80, 0, 18)
    nTitle.Position = UDim2.new(0, 68, 0, 14)
    nTitle.BackgroundTransparency = 1
    nTitle.Text = "Thank you!"
    nTitle.TextColor3 = Color3.fromRGB(235, 240, 250)
    nTitle.Font = Enum.Font.GothamBold
    nTitle.TextSize = 13
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.Parent = note

    local nBody = Instance.new("TextLabel")
    nBody.Size = UDim2.new(1, -80, 0, 26)
    nBody.Position = UDim2.new(0, 68, 0, 32)
    nBody.BackgroundTransparency = 1
    nBody.Text = "Thanks for choosing our script, hold Ctrl and click!"
    nBody.TextColor3 = Color3.fromRGB(160, 175, 200)
    nBody.Font = Enum.Font.Gotham
    nBody.TextSize = 11
    nBody.TextWrapped = true
    nBody.TextXAlignment = Enum.TextXAlignment.Left
    nBody.Parent = note

    local nClose = Instance.new("TextButton")
    nClose.Size = UDim2.new(0, 20, 0, 20)
    nClose.Position = UDim2.new(1, -26, 0, 8)
    nClose.BackgroundTransparency = 1
    nClose.Text = "✕"
    nClose.TextColor3 = Color3.fromRGB(150, 165, 190)
    nClose.Font = Enum.Font.GothamBold
    nClose.TextSize = 12
    nClose.AutoButtonColor = false
    nClose.Parent = note

    local function slideIn()
        Tween:Create(note, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, -300, 1, -100)}):Play()
    end
    local function slideOut()
        Tween:Create(note, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 320, 1, -100)}):Play()
        task.delay(0.4, function() note:Destroy() end)
    end

    nClose.MouseButton1Click:Connect(slideOut)
    nClose.MouseEnter:Connect(function()
        Tween:Create(nClose, TweenInfo.new(0.15),
            {TextColor3 = Color3.fromRGB(235, 240, 250)}):Play()
    end)
    nClose.MouseLeave:Connect(function()
        Tween:Create(nClose, TweenInfo.new(0.15),
            {TextColor3 = Color3.fromRGB(150, 165, 190)}):Play()
    end)

    task.wait(2.0)
    slideIn()
    task.delay(8, function()
        if note and note.Parent then slideOut() end
    end)
end

-- =====================================================
renderToggle(false)
crosshair.Visible = State.enabled
print("[ClickTPHub] Loaded. RightShift = show/hide. by Loganx")
