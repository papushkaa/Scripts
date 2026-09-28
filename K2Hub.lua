--[[ K2 Climbing Simulator - Hub v10
     Anti-AFK | Wipe | Inf Oxygen | Refills | Teleports
     RightShift: open/close with woosh + fade
     Intro: centered fade-in, ding, short slide
     Avatar + username top-right
     Credit: Loganx  ]]

local Players         = game:GetService("Players")
local UIS             = game:GetService("UserInputService")
local VIM             = game:GetService("VirtualInputManager")
local Tween           = game:GetService("TweenService")
local SoundService    = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local LP              = Players.LocalPlayer
local pg              = LP:WaitForChild("PlayerGui")

local CONFIG = {
    AntiAfkInterval = 60,
    WipeInterval    = 5,
    TpOffset        = 6,
    StatValue       = 100,
    ToggleKey       = Enum.KeyCode.RightShift,
}

local CAMP_RENAME = { [4] = 1, [12] = 2, [14] = 3 }
local State = { antiAfk=false, wipe=false, oxygen=false }

for _, n in ipairs({"K2Hub","K2HubV2","K2HubV3","K2HubV4","K2HubV5","K2HubV6","K2HubV7","K2HubV8","K2HubV9","K2HubV10"}) do
    local o = pg:FindFirstChild(n); if o then o:Destroy() end
end

-- =====================================================
--  UTILITIES
-- =====================================================
local function collectByKeyword(kws)
    local found, seen = {}, {}
    local function match(n)
        n = n:lower()
        for _, k in ipairs(kws) do
            if n:find(k, 1, true) then return true end
        end
        return false
    end
    local function scan(root)
        if not root then return end
        for _, v in ipairs(root:GetDescendants()) do
            if not seen[v] and (v:IsA("IntValue") or v:IsA("NumberValue")) then
                if match(v.Name) then
                    seen[v] = true; table.insert(found, v)
                end
            end
        end
    end
    scan(LP); scan(LP.Character)
    scan(LP:FindFirstChildOfClass("Backpack")); scan(pg)
    return found
end

local function setStat(v, n)
    if v and v.Parent then pcall(function() v.Value = n end) end
end

local function refillHealth()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.Health = hum.MaxHealth end) end
    end
    for _, v in ipairs(collectByKeyword({"health","hp","vitality"})) do
        setStat(v, CONFIG.StatValue)
    end
    for _, k in ipairs({"Health","health","HP"}) do
        if LP:GetAttribute(k) ~= nil then
            pcall(function() LP:SetAttribute(k, CONFIG.StatValue) end)
        end
    end
    print("[K2Hub] Health refill fired.")
end

local function refillOxygen()
    for _, v in ipairs(collectByKeyword({"oxygen","hypoxia","air","breath","o2"})) do
        setStat(v, CONFIG.StatValue)
    end
    for _, k in ipairs({"Oxygen","oxygen","O2","Hypoxia","Air"}) do
        if LP:GetAttribute(k) ~= nil then
            pcall(function() LP:SetAttribute(k, CONFIG.StatValue) end)
        end
    end
    print("[K2Hub] Oxygen refill fired.")
end

local function getAnchorPos(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local ok, piv = pcall(function() return obj:GetPivot().Position end)
        if ok and piv then return piv end
        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
        if p then return p.Position end
    end
    return nil
end

local function teleportTo(pos, label)
    if not pos then return end
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, CONFIG.TpOffset, 0))
    print(("[K2Hub] TP -> %s"):format(label or tostring(pos)))
end

local oxygenTargets = {}

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

local gui = Instance.new("ScreenGui")
gui.Name = "K2HubV10"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

local hub = Instance.new("CanvasGroup")
hub.Size = UDim2.new(0, 300, 0, 520)
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
logo.Size = UDim2.new(0, 30, 0, 30); logo.Position = UDim2.new(0, 14, 0, 12)
logo.BackgroundColor3 = P.panel2; logo.Text = "🏔"
logo.TextSize = 16; logo.Font = Enum.Font.GothamBold; logo.TextColor3 = P.text
logo.Parent = hub; Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 120, 0, 18); title.Position = UDim2.new(0, 52, 0, 12)
title.BackgroundTransparency = 1; title.Text = "K2 Climbing"
title.TextColor3 = P.text; title.Font = Enum.Font.GothamBold
title.TextSize = 15; title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = hub

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 120, 0, 14); subtitle.Position = UDim2.new(0, 52, 0, 28)
subtitle.BackgroundTransparency = 1; subtitle.Text = "Utility Hub"
subtitle.TextColor3 = P.sub; subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10; subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = hub

-- Avatar + username top-right
local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 28, 0, 28)
avatar.Position = UDim2.new(1, -42, 0, 14)
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
userLbl.Position = UDim2.new(1, -160, 0, 21)
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

-- =====================================================
--  HELPERS
-- =====================================================
local function sectionLabel(y, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -28, 0, 16); l.Position = UDim2.new(0, 14, 0, y)
    l.BackgroundTransparency = 1; l.Text = text
    l.TextColor3 = P.sub; l.Font = Enum.Font.GothamBold
    l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = hub
end

local function makeSwitch(y, emoji, label, initial, onChanged)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -28, 0, 32); row.Position = UDim2.new(0, 14, 0, y)
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

    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = P.stroke; trackStroke.Thickness = 1
    trackStroke.Transparency = 0.4; trackStroke.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200, 210, 225)
    knob.BorderSizePixel = 0; knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0); click.BackgroundTransparency = 1
    click.Text = ""; click.Parent = row

    local on = initial or false
    local function render(animate)
        local info = animate and TweenInfo.new(0.22, Enum.EasingStyle.Quint)
                              or TweenInfo.new(0)
        Tween:Create(track, info, {BackgroundColor3 = on and P.accent or P.panel2}):Play()
        Tween:Create(trackStroke, info, {
            Color = on and P.accent2 or P.stroke,
            Transparency = on and 0.1 or 0.4,
        }):Play()
        Tween:Create(knob, info, {
            Position = on and UDim2.new(0, 23, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(200, 210, 225),
        }):Play()
    end
    render(false)

    click.MouseButton1Click:Connect(function()
        on = not on
        render(true)
        if onChanged then onChanged(on) end
    end)
    click.MouseEnter:Connect(function()
        Tween:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = P.hover}):Play()
    end)
    click.MouseLeave:Connect(function()
        Tween:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = P.panel}):Play()
    end)
end

local function makeAction(y, emoji, label, onClick)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -28, 0, 32); b.Position = UDim2.new(0, 14, 0, y)
    b.BackgroundColor3 = P.panel; b.Text = ""; b.AutoButtonColor = false
    b.Parent = hub
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local e = Instance.new("TextLabel")
    e.Size = UDim2.new(0, 30, 1, 0); e.Position = UDim2.new(0, 4, 0, 0)
    e.BackgroundTransparency = 1; e.Text = emoji; e.TextSize = 14
    e.Font = Enum.Font.Gotham; e.Parent = b

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -110, 1, 0); l.Position = UDim2.new(0, 36, 0, 0)
    l.BackgroundTransparency = 1; l.Text = label
    l.TextColor3 = P.text; l.Font = Enum.Font.GothamMedium
    l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = b

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0); arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1; arrow.Text = "›"
    arrow.TextColor3 = P.sub; arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 18; arrow.Parent = b

    b.MouseEnter:Connect(function()
        Tween:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = P.hover}):Play()
        Tween:Create(arrow, TweenInfo.new(0.15), {TextColor3 = P.accent2}):Play()
    end)
    b.MouseLeave:Connect(function()
        Tween:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = P.panel}):Play()
        Tween:Create(arrow, TweenInfo.new(0.15), {TextColor3 = P.sub}):Play()
    end)

    b.MouseButton1Click:Connect(function()
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = P.accent2
        flash.BackgroundTransparency = 0.7
        flash.BorderSizePixel = 0; flash.ZIndex = 5; flash.Parent = b
        Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 8)
        Tween:Create(flash, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
        task.delay(0.4, function() flash:Destroy() end)
        if onClick then onClick() end
    end)
end

-- =====================================================
--  BUILD UI
-- =====================================================
local y = 52
sectionLabel(y, "AUTOMATION"); y += 18

makeSwitch(y, "🛡", "Anti-AFK", false,
    function(v) State.antiAfk = v; refreshStatus() end); y += 36
makeSwitch(y, "🧽", "Auto-Wipe Screen", false,
    function(v) State.wipe = v; refreshStatus() end); y += 36
makeSwitch(y, "💨", "Infinite Oxygen", false, function(v)
    State.oxygen = v; refreshStatus()
    if not v then
        for _, t in ipairs(oxygenTargets) do setStat(t, CONFIG.StatValue) end
    end
end); y += 40

sectionLabel(y, "ACTIONS"); y += 18

makeAction(y, "✚", "Refill Health", function() refillHealth() end); y += 36
makeAction(y, "🌬", "Refill Oxygen", function() refillOxygen() end); y += 44

local div = Instance.new("Frame")
div.Size = UDim2.new(1, -28, 0, 1); div.Position = UDim2.new(0, 14, 0, y)
div.BackgroundColor3 = P.stroke; div.BackgroundTransparency = 0.4
div.BorderSizePixel = 0; div.Parent = hub; y += 8

sectionLabel(y, "TELEPORTS  ·  LOWEST → HIGHEST"); y += 18

local tpCount = Instance.new("TextLabel")
tpCount.Size = UDim2.new(1, -28, 0, 12); tpCount.Position = UDim2.new(0, 14, 0, y)
tpCount.BackgroundTransparency = 1; tpCount.Text = "loading…"
tpCount.TextColor3 = P.sub; tpCount.Font = Enum.Font.Gotham
tpCount.TextSize = 10; tpCount.TextXAlignment = Enum.TextXAlignment.Left
tpCount.Parent = hub; y += 14

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -28, 1, -(y + 54))
listFrame.Position = UDim2.new(0, 14, 0, y)
listFrame.BackgroundColor3 = P.panel; listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 3; listFrame.ScrollBarImageColor3 = P.accent
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.Parent = hub
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 10)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 6); listPad.PaddingBottom = UDim.new(0, 6)
listPad.PaddingLeft = UDim.new(0, 6); listPad.PaddingRight = UDim.new(0, 6)
listPad.Parent = listFrame

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -28, 0, 14); credit.Position = UDim2.new(0, 14, 1, -38)
credit.BackgroundTransparency = 1; credit.Text = "·  Script by Loganx"
credit.TextColor3 = Color3.fromRGB(140, 165, 200)
credit.Font = Enum.Font.GothamBold; credit.TextSize = 10
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Parent = hub

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 16); status.Position = UDim2.new(0, 14, 1, -22)
status.BackgroundTransparency = 1; status.Text = "Idle"
status.TextColor3 = P.sub; status.Font = Enum.Font.Gotham
status.TextSize = 10; status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = hub

function refreshStatus()
    local parts = {}
    if State.antiAfk then table.insert(parts, "Anti-AFK") end
    if State.wipe    then table.insert(parts, "Wipe") end
    if State.oxygen  then table.insert(parts, "Oxygen") end
    status.Text = #parts > 0 and ("● " .. table.concat(parts, "  ·  ")) or "○ Idle"
    status.TextColor3 = #parts > 0 and P.green or P.sub
end

-- =====================================================
--  RESIZE HANDLE
-- =====================================================
local resizeGrip = Instance.new("TextButton")
resizeGrip.Size = UDim2.new(0, 22, 0, 22)
resizeGrip.Position = UDim2.new(1, -24, 1, -24)
resizeGrip.BackgroundTransparency = 1
resizeGrip.Text = "◢"
resizeGrip.TextColor3 = P.sub
resizeGrip.TextSize = 14
resizeGrip.Font = Enum.Font.GothamBold
resizeGrip.AutoButtonColor = false
resizeGrip.Parent = hub

local resizing = false
local startY, startSizeY = 0, 0

resizeGrip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        startY = input.Position.Y
        startSizeY = hub.Size.Y.Offset
        resizeGrip.TextColor3 = P.accent2
    end
end)
UIS.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position.Y - startY
        local newH = math.clamp(startSizeY + d, 300, 900)
        hub.Size = UDim2.new(0, hub.Size.X.Offset, 0, newH)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
        resizeGrip.TextColor3 = P.sub
    end
end)

-- =====================================================
--  TELEPORT LIST  (Teleporters folder removed)
-- =====================================================
local function makeTpButton(label, getPos, accent)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = accent or P.panel2
    b.TextColor3 = P.text; b.Font = Enum.Font.GothamMedium
    b.TextSize = 11; b.Text = "  " .. label
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false; b.Parent = listFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke")
    s.Color = Color3.new(1,1,1); s.Thickness = 1
    s.Transparency = 0.9; s.Parent = b

    local base = accent or P.panel2
    b.MouseEnter:Connect(function()
        Tween:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = P.hover}):Play()
    end)
    b.MouseLeave:Connect(function()
        Tween:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = base}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        teleportTo(getPos(), label)
    end)
end

local function routeEmoji(i, total)
    if i == total then return "🏔" end
    if i >= total - 2 then return "🧗" end
    local t = i / total
    if t < 0.34 then return "🥾"
    elseif t < 0.67 then return "⛰"
    else return "🧗" end
end

local function buildTeleportList()
    for _, c in ipairs(listFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local added = 0

    -- Summit
    do
        local best, bestY = nil, -math.huge
        for _, p in ipairs(workspace:GetChildren()) do
            if p.Name == "SummitEffect1" and p:IsA("BasePart") then
                if p.Position.Y > bestY then best, bestY = p, p.Position.Y end
            end
        end
        if best then
            makeTpButton(("🏔  Summit        Y:%d"):format(math.floor(best.Position.Y)),
                function() return best.Position end,
                Color3.fromRGB(42, 62, 92))
            added += 1
        end
    end

    -- RevivePoints
    local rp = workspace:FindFirstChild("RevivePoints")
    if rp then
        local list = {}
        for _, c in ipairs(rp:GetChildren()) do
            local pos = getAnchorPos(c)
            if pos then table.insert(list, {obj=c, pos=pos}) end
        end
        table.sort(list, function(a,b) return a.pos.Y < b.pos.Y end)
        local total = #list
        local routeN = 0

        for i, entry in ipairs(list) do
            local yv = math.floor(entry.pos.Y)
            local c  = entry.obj
            local label, accent

            if CAMP_RENAME[i] then
                label  = ("🏕  Camp %d       Y:%d"):format(CAMP_RENAME[i], yv)
                accent = Color3.fromRGB(60, 82, 60)
            else
                routeN += 1
                label  = ("%s  Route %d      Y:%d"):format(routeEmoji(i, total), routeN, yv)
                accent = Color3.fromRGB(34, 44, 60)
            end
            makeTpButton(label, function() return getAnchorPos(c) end, accent)
            added += 1
        end
    end

    -- (Teleporters folder section removed)

    tpCount.Text = ("%d destinations"):format(added)
end

task.spawn(function() task.wait(0.2); buildTeleportList() end)
do
    local rp = workspace:WaitForChild("RevivePoints", 10)
    if rp then
        rp.ChildAdded:Connect(function() task.wait(0.1); buildTeleportList() end)
        rp.ChildRemoved:Connect(function() task.wait(0.1); buildTeleportList() end)
    end
end

-- =====================================================
--  LOOPS
-- =====================================================
local vUser = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    if not State.antiAfk then return end
    pcall(function()
        vUser:CaptureController(); vUser:ClickButton2(Vector2.new())
    end)
end)
task.spawn(function()
    while task.wait(CONFIG.AntiAfkInterval) do
        if not State.antiAfk then continue end
        pcall(function()
            vUser:CaptureController(); vUser:ClickButton2(Vector2.new())
        end)
    end
end)

task.spawn(function()
    while task.wait(CONFIG.WipeInterval) do
        if not State.wipe then continue end
        pcall(function() VIM:SendKeyEvent(true,  Enum.KeyCode.C, false, game) end)
        task.wait(0.05)
        pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game) end)
    end
end)

-- oxygen scanner
do
    local lastRescan = 0
    local printedO = false
    task.spawn(function()
        while task.wait(0.05) do
            local now = os.clock()
            if now - lastRescan >= 1 then
                lastRescan = now
                oxygenTargets = collectByKeyword({"oxygen","hypoxia","breath","o2"})
                if not printedO then
                    printedO = true
                    print(("[K2Hub] Oxygen scan: %d target(s)"):format(#oxygenTargets))
                end
            end
            if State.oxygen then
                for _, v in ipairs(oxygenTargets) do setStat(v, CONFIG.StatValue) end
                for _, k in ipairs({"Oxygen","oxygen","O2","Hypoxia"}) do
                    if LP:GetAttribute(k) ~= nil then
                        pcall(function() LP:SetAttribute(k, CONFIG.StatValue) end)
                    end
                end
            end
        end
    end)
end

-- =====================================================
--  SOUNDS  (SoundService, preloaded)
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
local DING_ID  = "rbxassetid://876939830"   -- very short, loads fast

local openSound  = newSound(WOOSH_ID, 0.65, 1.15)
local closeSound = newSound(WOOSH_ID, 0.6,  0.9)
local dingSound  = newSound(DING_ID,  0.85, 1.0)

-- Preload synchronously (blocks this task, not the whole script)
task.spawn(function()
    pcall(function()
        ContentProvider:PreloadAsync({openSound, closeSound, dingSound})
    end)
end)

-- Robust ding that waits for load
local function playDing()
    if not dingSound.IsLoaded then
        local t0 = os.clock()
        while not dingSound.IsLoaded and os.clock() - t0 < 3 do
            task.wait(0.05)
        end
    end
    -- silent warm-up to force the audio engine to prime the buffer
    local realVol = dingSound.Volume
    dingSound.Volume = 0
    dingSound.TimePosition = 0
    dingSound:Play()
    task.wait(0.03)
    dingSound:Stop()
    -- now actually play it
    dingSound.Volume = realVol
    dingSound.TimePosition = 0
    dingSound:Play()
end

-- =====================================================
--  FADE ENGINE
-- =====================================================
local hubOpen = true

local function fadeIn(dur, style, dir)
    dur = dur or 0.4
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    hub.Visible = true
    Tween:Create(hub, TweenInfo.new(dur, style, dir), {
        GroupTransparency = 0,
        BackgroundTransparency = 0.03,
    }):Play()
    Tween:Create(hubStroke, TweenInfo.new(dur, style, dir), {Transparency = 0.4}):Play()
end

local function fadeOut(dur, style, dir, cb)
    dur = dur or 0.28
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.In
    Tween:Create(hub, TweenInfo.new(dur, style, dir), {
        GroupTransparency = 1,
        BackgroundTransparency = 1,
    }):Play()
    Tween:Create(hubStroke, TweenInfo.new(dur, style, dir), {Transparency = 1}):Play()
    task.delay(dur + 0.02, function()
        if not hubOpen then hub.Visible = false end
        if cb then cb() end
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

    -- Resting spot: upper area but not pinned to the left edge
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
--  WELCOME NOTIFICATION
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
    nIcon.Text = "❄"
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
    nBody.Text = "Thanks for choosing our script, enjoy the climb!"
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
refreshStatus()
print("[K2Hub v10] Loaded. RightShift = show/hide. by Loganx")
