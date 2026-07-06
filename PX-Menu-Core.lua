--[[
    PX-Menu v4.0 — TLMenu-Style Rewrite
    Game: German Voice (ID: 136162036182779)
    Toggle Key: RightShift (configurable)
    
    Features copied from TLMenu:
    - Fly (WASD+Camera, Speed Levels, Animations)
    - Noclip, Spin, ESP, Shaders
    - Anti-VC Ban, Invisible
    - Fling (SkidFling Engine)
    - Avatar Outfits Stealer
    - Troll Actions (HeadSeat, Throw, TP, etc.)
    - Player List, Keybinds
    
    Usage:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/obl1vroot-lab/PX-Menu/main/PX-Menu-Core.lua"))()
]]

-- ════════════════════════════════════════════════════════════════
--  GAME CHECK
-- ════════════════════════════════════════════════════════════════

local GAME_ID = 136162036182779
if game.PlaceId ~= GAME_ID then
    local WarnGui = Instance.new("ScreenGui")
    WarnGui.Name = "PXWarn"
    WarnGui.ResetOnSpawn = false
    WarnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WarnGui.Parent = game:GetService("CoreGui")
    local WarnFrame = Instance.new("Frame", WarnGui)
    WarnFrame.Size = UDim2.new(0, 380, 0, 110)
    WarnFrame.Position = UDim2.new(1, -400, 1, -130)
    WarnFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    WarnFrame.BorderSizePixel = 0
    Instance.new("UICorner", WarnFrame).CornerRadius = UDim.new(0, 10)
    local ws2 = Instance.new("UIStroke", WarnFrame)
    ws2.Color = Color3.fromRGB(100, 50, 170)
    ws2.Thickness = 2
    local WarnTitle = Instance.new("TextLabel", WarnFrame)
    WarnTitle.Size = UDim2.new(1, -20, 0, 30)
    WarnTitle.Position = UDim2.new(0, 12, 0, 10)
    WarnTitle.BackgroundTransparency = 1
    WarnTitle.Text = "PX-Menu"
    WarnTitle.TextColor3 = Color3.fromRGB(100, 50, 170)
    WarnTitle.TextSize = 18
    WarnTitle.Font = Enum.Font.GothamBold
    WarnTitle.TextXAlignment = Enum.TextXAlignment.Left
    local WarnText = Instance.new("TextLabel", WarnFrame)
    WarnText.Size = UDim2.new(1, -24, 0, 50)
    WarnText.Position = UDim2.new(0, 12, 0, 45)
    WarnText.BackgroundTransparency = 1
    WarnText.Text = "Dieses Script ist nur fuer German Voice verfuegbar!"
    WarnText.TextColor3 = Color3.fromRGB(200, 200, 200)
    WarnText.TextSize = 14
    WarnText.Font = Enum.Font.Gotham
    WarnText.TextWrapped = true
    WarnText.TextXAlignment = Enum.TextXAlignment.Left
    task.delay(5, function() WarnGui:Destroy() end)
    return
end

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local lp = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ════════════════════════════════════════════════════════════════
--  CHARACTER STATE
-- ════════════════════════════════════════════════════════════════

local character = lp.Character or lp.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
lp.CharacterAdded:Connect(function(c)
    character = c
    hrp = c:WaitForChild("HumanoidRootPart")
    humanoid = c:WaitForChild("Humanoid")
end)

-- ════════════════════════════════════════════════════════════════
--  COLORS (PX-Menu Purple Theme)
-- ════════════════════════════════════════════════════════════════

local C = {
    bg = Color3.fromRGB(15, 15, 20),
    bg2 = Color3.fromRGB(20, 20, 28),
    card = Color3.fromRGB(25, 25, 35),
    cardHover = Color3.fromRGB(32, 32, 45),
    accent = Color3.fromRGB(100, 50, 170),
    accentDim = Color3.fromRGB(60, 30, 100),
    accentGlow = Color3.fromRGB(130, 70, 200),
    text = Color3.fromRGB(230, 230, 240),
    textDim = Color3.fromRGB(140, 140, 160),
    green = Color3.fromRGB(40, 200, 80),
    red = Color3.fromRGB(220, 40, 40),
    yellow = Color3.fromRGB(220, 180, 40),
    sep = Color3.fromRGB(35, 35, 50),
    pillBg = Color3.fromRGB(18, 18, 26),
    pillSel = Color3.fromRGB(100, 50, 170),
    tabBg = Color3.fromRGB(12, 12, 18),
}

-- ════════════════════════════════════════════════════════════════
--  UI HELPERS
-- ════════════════════════════════════════════════════════════════

local function Corner(par, r)
    local c = Instance.new("UICorner", par)
    c.CornerRadius = UDim.new(0, r or 6)
    return c
end

local function Stroke(par, col, w)
    local s = Instance.new("UIStroke", par)
    s.Color = col or C.accentDim
    s.Thickness = w or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function MakeList(par, gap)
    local l = Instance.new("UIListLayout", par)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, gap or 6)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Left
    return l
end

local function MakePad(par, t, b, l, r)
    local p = Instance.new("UIPadding", par)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    return p
end

local function Card(parent, text, height)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, height or 42)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    f.AutomaticSize = Enum.AutomaticSize.Y
    Corner(f, 6)
    Stroke(f, C.accentDim, 1)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -12, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return f, lbl
end

local function Toggle(parent, text, callback)
    local f = Card(parent, text, 36)
    local state = false
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = C.pillBg
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Corner(btn, 10)
    Stroke(btn, C.accentDim, 1)
    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = C.textDim
    indicator.BorderSizePixel = 0
    Corner(indicator, 8)
    btn.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and C.green or C.textDim
        indicator.Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
        btn.BackgroundColor3 = state and C.accentDim or C.pillBg
        if callback then callback(state) end
    end)
    return {
        set = function(v)
            state = v
            indicator.BackgroundColor3 = v and C.green or C.textDim
            indicator.Position = v and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
            btn.BackgroundColor3 = v and C.accentDim or C.pillBg
        end,
        get = function() return state end
    }
end

local function Slider(parent, text, min, max, default, callback)
    local f = Card(parent, text, 50)
    local val = default or min
    local valLabel = Instance.new("TextLabel", f)
    valLabel.Size = UDim2.new(0, 50, 0, 16)
    valLabel.Position = UDim2.new(1, -60, 0, 8)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(val)
    valLabel.TextColor3 = C.accent
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    local barBg = Instance.new("Frame", f)
    barBg.Size = UDim2.new(1, -24, 0, 6)
    barBg.Position = UDim2.new(0, 12, 1, -16)
    barBg.BackgroundColor3 = C.pillBg
    barBg.BorderSizePixel = 0
    Corner(barBg, 3)
    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
    barFill.BackgroundColor3 = C.accent
    barFill.BorderSizePixel = 0
    Corner(barFill, 3)
    local knob = Instance.new("Frame", barBg)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = C.accentGlow
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    Corner(knob, 7)
    local sliding = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local absPos = barBg.AbsolutePosition.X
            local absSize = barBg.AbsoluteSize.X
            local rel = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
            val = math.floor(min + rel * (max - min) + 0.5)
            barFill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
            valLabel.Text = tostring(val)
            if callback then callback(val) end
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    return {
        set = function(v)
            v = math.clamp(v, min, max)
            val = v
            local rel = (v - min) / (max - min)
            barFill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
            valLabel.Text = tostring(v)
        end,
        get = function() return val end
    }
end

local function Btn(parent, text, callback)
    local f = Card(parent, text, 34)
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(1, -60, 0.5, -11)
    btn.BackgroundColor3 = C.accent
    btn.Text = ">>>"
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Corner(btn, 4)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = C.accentGlow end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = C.accent end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return f
end

local function Sep(parent)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 1)
    f.BackgroundColor3 = C.sep
    f.BorderSizePixel = 0
    return f
end

local function Label(parent, text, color)
    local f = Instance.new("TextLabel", parent)
    f.Size = UDim2.new(1, 0, 0, 20)
    f.BackgroundTransparency = 1
    f.Text = "  " .. text
    f.TextColor3 = color or C.textDim
    f.Font = Enum.Font.GothamBold
    f.TextSize = 11
    f.TextXAlignment = Enum.TextXAlignment.Left
    f.AutomaticSize = Enum.AutomaticSize.Y
    return f
end

local function PlayerListWidget(parent, onSelect, height)
    local results = {}
    local selected = nil
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, height or 160)
    container.BackgroundColor3 = C.card
    container.BorderSizePixel = 0
    Corner(container, 6)
    Stroke(container, C.accentDim, 1)
    local scroll = Instance.new("ScrollingFrame", container)
    scroll.Size = UDim2.new(1, -8, 1, -8)
    scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    local function refresh()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        results = {}
        local idx = 0
        for _, p in ipairs(Players:GetPlayers()) do
            idx = idx + 1
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = C.pillBg
            btn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
            btn.TextColor3 = C.textDim
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.LayoutOrder = idx
            Corner(btn, 4)
            btn.MouseEnter:Connect(function()
                if selected ~= p then btn.BackgroundColor3 = C.cardHover end
            end)
            btn.MouseLeave:Connect(function()
                if selected ~= p then btn.BackgroundColor3 = C.pillBg end
            end)
            btn.MouseButton1Click:Connect(function()
                selected = p
                for _, b in ipairs(scroll:GetChildren()) do
                    if b:IsA("TextButton") then b.BackgroundColor3 = C.pillBg end
                end
                btn.BackgroundColor3 = C.pillSel
                if onSelect then onSelect(p) end
            end)
            table.insert(results, p)
        end
    end
    refresh()
    return {
        refresh = refresh,
        selected = function() return selected end,
        getResults = function() return results end
    }
end

local function Keybind(parent, text, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    Corner(f, 6)
    Stroke(f, C.accentDim, 1)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local kbtn = Instance.new("TextButton", f)
    kbtn.Size = UDim2.new(0, 100, 0, 22)
    kbtn.Position = UDim2.new(1, -110, 0.5, -11)
    kbtn.BackgroundColor3 = C.pillBg
    kbtn.Text = default or "None"
    kbtn.TextColor3 = C.accent
    kbtn.Font = Enum.Font.GothamBold
    kbtn.TextSize = 10
    kbtn.BorderSizePixel = 0
    kbtn.AutoButtonColor = false
    Corner(kbtn, 4)
    local waiting = false
    local currentBind = default
    kbtn.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        kbtn.Text = "..."
        kbtn.BackgroundColor3 = C.accent
    end)
    return {
        getBind = function() return currentBind end,
        setBind = function(v) currentBind = v; kbtn.Text = v or "None" end,
        isWaiting = function() return waiting end,
        accept = function(keyCode)
            if waiting then
                waiting = false
                currentBind = keyCode and keyCode.Name or nil
                kbtn.Text = currentBind or "None"
                kbtn.BackgroundColor3 = C.pillBg
                if callback then callback(currentBind) end
            end
        end
    }
end

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "PX-Menu",
            Text = text or "",
            Duration = dur or 3
        })
    end)
end

-- ════════════════════════════════════════════════════════════════
--  GAME DETECTION
-- ════════════════════════════════════════════════════════════════

local placeId = game.PlaceId
local universeId = 0
pcall(function() universeId = tonumber(game.GameId) or 0 end)
local gameTitle = tostring(game.Name)
pcall(function()
    local info = MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
    if info and type(info.Name) == "string" and info.Name ~= "" then
        gameTitle = info.Name
    end
end)
local gameThumb = "rbxasset://textures/ui/GuiImagePlaceholder.png"
if universeId > 0 then
    gameThumb = "rbxthumb://type=GameIcon&id=" .. tostring(universeId) .. "&w=256&h=256"
end

-- ════════════════════════════════════════════════════════════════
--  EXECUTOR DETECTION
-- ════════════════════════════════════════════════════════════════

local function DetectExecutor()
    local name = "Unknown"
    local isTrusted = false
    if identifyexecutor then
        local s, n = pcall(identifyexecutor)
        if s and n then name = n end
    end
    for _, v in pairs({"Potassium", "Madium", "Real", "Wave"}) do
        if string.lower(name):find(string.lower(v)) then
            isTrusted = true
            break
        end
    end
    return name, isTrusted
end
local ExecutorName, ExecutorTrusted = DetectExecutor()

-- ════════════════════════════════════════════════════════════════
--  GUI CREATION
-- ════════════════════════════════════════════════════════════════

if CoreGui:FindFirstChild("PX-Menu") then
    CoreGui:FindFirstChild("PX-Menu"):Destroy()
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "PX-Menu"
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999
GUI.Parent = CoreGui

-- ════════════════════════════════════════════════════════════════
--  INDICATOR
-- ════════════════════════════════════════════════════════════════

local Indicator = Instance.new("Frame", GUI)
Indicator.Name = "Indicator"
Indicator.Size = UDim2.new(0, 220, 0, 30)
Indicator.Position = UDim2.new(1, -240, 0, 10)
Indicator.BackgroundColor3 = C.bg
Indicator.BackgroundTransparency = 0.2
Indicator.BorderSizePixel = 0
Corner(Indicator, 8)
Stroke(Indicator, ExecutorTrusted and C.green or C.yellow, 1)
local IndLabel = Instance.new("TextLabel", Indicator)
IndLabel.Size = UDim2.new(1, -10, 1, 0)
IndLabel.Position = UDim2.new(0, 8, 0, 0)
IndLabel.BackgroundTransparency = 1
IndLabel.Text = "PX-Menu | " .. ExecutorName .. " | [RightShift]"
IndLabel.TextColor3 = ExecutorTrusted and C.green or C.yellow
IndLabel.Font = Enum.Font.GothamBold
IndLabel.TextSize = 11
IndLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ════════════════════════════════════════════════════════════════
--  LOADING SCREEN
-- ════════════════════════════════════════════════════════════════

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "PXLoading"
LoadingGui.ResetOnSpawn = false
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingGui.Parent = CoreGui

local LoadingFrame = Instance.new("Frame", LoadingGui)
LoadingFrame.Size = UDim2.new(0, 320, 0, 120)
LoadingFrame.Position = UDim2.new(0.5, -160, 0.5, -60)
LoadingFrame.BackgroundColor3 = C.bg
LoadingFrame.BorderSizePixel = 0
Corner(LoadingFrame, 10)
Stroke(LoadingFrame, C.accent, 2)

local LoadTitle = Instance.new("TextLabel", LoadingFrame)
LoadTitle.Size = UDim2.new(1, 0, 0, 30)
LoadTitle.Position = UDim2.new(0, 0, 0, 15)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "PX-MENU"
LoadTitle.TextColor3 = C.accent
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextSize = 22

local LoadSub = Instance.new("TextLabel", LoadingFrame)
LoadSub.Size = UDim2.new(1, 0, 0, 16)
LoadSub.Position = UDim2.new(0, 0, 0, 45)
LoadSub.BackgroundTransparency = 1
LoadSub.Text = "TLMenu Features Edition"
LoadSub.TextColor3 = C.textDim
LoadSub.Font = Enum.Font.Gotham
LoadSub.TextSize = 11

local LoadStatus = Instance.new("TextLabel", LoadingFrame)
LoadStatus.Size = UDim2.new(1, -20, 0, 20)
LoadStatus.Position = UDim2.new(0, 10, 0, 68)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Text = "Initialisiere..."
LoadStatus.TextColor3 = C.textDim
LoadStatus.Font = Enum.Font.Gotham
LoadStatus.TextSize = 12

local ProgressBarBG = Instance.new("Frame", LoadingFrame)
ProgressBarBG.Size = UDim2.new(1, -40, 0, 8)
ProgressBarBG.Position = UDim2.new(0, 20, 0, 95)
ProgressBarBG.BackgroundColor3 = C.pillBg
ProgressBarBG.BorderSizePixel = 0
Corner(ProgressBarBG, 4)

local ProgressBarFill = Instance.new("Frame", ProgressBarBG)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = C.accent
ProgressBarFill.BorderSizePixel = 0
Corner(ProgressBarFill, 4)

local function UpdateLoading(progress, status)
    LoadStatus.Text = status or "Lade..."
    ProgressBarFill.Size = UDim2.new(progress, 0, 1, 0)
end

-- ════════════════════════════════════════════════════════════════
--  MAIN FRAME
-- ════════════════════════════════════════════════════════════════

local dragging = false
local dragStart = nil
local startPos = nil

local Main = Instance.new("Frame", GUI)
Main.Name = "Main"
Main.Size = UDim2.new(0, 500, 0, 580)
Main.Position = UDim2.new(0.5, -250, 0.5, -290)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Corner(Main, 10)
Stroke(Main, C.accentDim, 1)

-- Header
local Header = Instance.new("Frame", Main)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = C.bg2
Header.BorderSizePixel = 0
Header.ZIndex = 2
Corner(Header, 10)

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "PX-MENU"
TitleLabel.TextColor3 = C.accent
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local VersionLabel = Instance.new("TextLabel", Header)
VersionLabel.Size = UDim2.new(0, 60, 1, 0)
VersionLabel.Position = UDim2.new(1, -70, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v4.0"
VersionLabel.TextColor3 = C.textDim
VersionLabel.Font = Enum.Font.GothamBold
VersionLabel.TextSize = 12

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -35, 0.5, -12)
MinBtn.BackgroundColor3 = C.yellow
MinBtn.Text = "-"
MinBtn.TextColor3 = C.text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = false
Corner(MinBtn, 4)

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        local conn
        conn = UIS.InputChanged:Connect(function(input2)
            if dragging and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) then
                local delta = input2.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
--  CONTENT AREA
-- ════════════════════════════════════════════════════════════════

local Content = Instance.new("Frame", Main)
Content.Name = "Content"
Content.Size = UDim2.new(1, -12, 1, -90)
Content.Position = UDim2.new(0, 6, 0, 44)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true

local Pages = {}
local tabBtns = {}
local tabIcons = {}
local activeTab = nil

local function createPage(name)
    local page = Instance.new("ScrollingFrame", Content)
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    MakeList(page, 6)
    MakePad(page, 4, 10, 4, 4)
    Pages[name] = page
    return page
end

local function showTab(name)
    for _, p in pairs(Pages) do p.Visible = false end
    for n, b in pairs(tabBtns) do
        b.BackgroundColor3 = C.tabBg
        b.ImageColor3 = C.textDim
        local lbl = b:FindFirstChild("TabLabel")
        if lbl then lbl.TextColor3 = C.textDim end
    end
    if Pages[name] then Pages[name].Visible = true end
    if tabBtns[name] then
        tabBtns[name].BackgroundColor3 = C.accentDim
        tabBtns[name].ImageColor3 = C.accent
        local lbl = tabBtns[name]:FindFirstChild("TabLabel")
        if lbl then lbl.TextColor3 = C.accent end
    end
    activeTab = name
end

-- ════════════════════════════════════════════════════════════════
--  TAB PAGES
-- ════════════════════════════════════════════════════════════════

local tabHome = createPage("HOME")
local tabChar = createPage("CHARACTER")
local tabScripts = createPage("SCRIPTS")
local tabActions = createPage("ACTIONS")
local tabPlayers = createPage("PLAYERLIST")
local tabSettings = createPage("SETTINGS")

-- ════════════════════════════════════════════════════════════════
--  BOTTOM TAB-BAR
-- ════════════════════════════════════════════════════════════════

local TabBar = Instance.new("Frame", Main)
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -12, 0, 42)
TabBar.Position = UDim2.new(0, 6, 1, -48)
TabBar.BackgroundColor3 = C.bg2
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 3
Corner(TabBar, 8)

local tabScroll = Instance.new("ScrollingFrame", TabBar)
tabScroll.Size = UDim2.new(1, -8, 1, 0)
tabScroll.Position = UDim2.new(0, 4, 0, 0)
tabScroll.BackgroundTransparency = 1
tabScroll.BorderSizePixel = 0
tabScroll.ScrollBarThickness = 0
tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
local tabLayout = Instance.new("UIListLayout", tabScroll)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
Instance.new("UIPadding", tabScroll).PaddingLeft = UDim.new(0, 2)

local tabData = {
    {name = "HOME", icon = "rbxassetid://3926305904", page = tabHome},
    {name = "CHARACTER", icon = "rbxassetid://3926305904", page = tabChar},
    {name = "SCRIPTS", icon = "rbxassetid://3926305904", page = tabScripts},
    {name = "ACTIONS", icon = "rbxassetid://3926305904", page = tabActions},
    {name = "PLAYERS", icon = "rbxassetid://3926305904", page = tabPlayers},
    {name = "SETTINGS", icon = "rbxassetid://3926305904", page = tabSettings},
}

for i, td in ipairs(tabData) do
    local btn = Instance.new("TextButton", tabScroll)
    btn.Size = UDim2.new(0, 70, 0, 34)
    btn.BackgroundColor3 = i == 1 and C.accentDim or C.tabBg
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 4
    Corner(btn, 6)

    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0.5, -8, 0, 4)
    icon.BackgroundTransparency = 1
    icon.Image = td.icon
    icon.ImageColor3 = i == 1 and C.accent or C.textDim
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ZIndex = 5

    local lbl = Instance.new("TextLabel", btn)
    lbl.Name = "TabLabel"
    lbl.Size = UDim2.new(1, 0, 0, 12)
    lbl.Position = UDim2.new(0, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = td.name
    lbl.TextColor3 = i == 1 and C.accent or C.textDim
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 7
    lbl.ZIndex = 5

    tabBtns[td.name] = btn
    tabIcons[td.name] = icon

    btn.MouseButton1Click:Connect(function()
        showTab(td.name)
    end)
end

-- ════════════════════════════════════════════════════════════════
--  HOME TAB
-- ════════════════════════════════════════════════════════════════

Label(tabHome, "Game Info", C.accent)

local gameInfoCard = Instance.new("Frame", tabHome)
gameInfoCard.Size = UDim2.new(1, 0, 0, 100)
gameInfoCard.BackgroundColor3 = C.card
gameInfoCard.BorderSizePixel = 0
gameInfoCard.ClipsDescendants = true
Corner(gameInfoCard, 8)
Stroke(gameInfoCard, C.accentDim, 1)

local gameThumbImg = Instance.new("ImageLabel", gameInfoCard)
gameThumbImg.Size = UDim2.new(0, 80, 0, 80)
gameThumbImg.Position = UDim2.new(0, 10, 0, 10)
gameThumbImg.BackgroundColor3 = C.pillBg
gameThumbImg.ScaleType = Enum.ScaleType.Crop
gameThumbImg.Image = gameThumb
Corner(gameThumbImg, 8)

local gameNameLbl = Instance.new("TextLabel", gameInfoCard)
gameNameLbl.Size = UDim2.new(1, -110, 0, 20)
gameNameLbl.Position = UDim2.new(0, 100, 0, 10)
gameNameLbl.BackgroundTransparency = 1
gameNameLbl.Text = gameTitle
gameNameLbl.TextColor3 = C.text
gameNameLbl.Font = Enum.Font.GothamBold
gameNameLbl.TextSize = 14
gameNameLbl.TextXAlignment = Enum.TextXAlignment.Left
gameNameLbl.TextTruncate = Enum.TextTruncate.AtEnd

local gameDetails = Instance.new("TextLabel", gameInfoCard)
gameDetails.Size = UDim2.new(1, -110, 0, 50)
gameDetails.Position = UDim2.new(0, 100, 0, 32)
gameDetails.BackgroundTransparency = 1
gameDetails.Text = "Place: " .. placeId .. "\nUniverse: " .. universeId .. "\nJob: " .. string.sub(game.JobId, 1, 8) .. "..."
gameDetails.TextColor3 = C.textDim
gameDetails.Font = Enum.Font.Gotham
gameDetails.TextSize = 10
gameDetails.TextXAlignment = Enum.TextXAlignment.Left
gameDetails.TextWrapped = true

Label(tabHome, "Spieler Profil", C.accent)

local profileCard = Instance.new("Frame", tabHome)
profileCard.Size = UDim2.new(1, 0, 0, 50)
profileCard.BackgroundColor3 = C.card
profileCard.BorderSizePixel = 0
Corner(profileCard, 6)
Stroke(profileCard, C.accentDim, 1)

local avatarImg = Instance.new("ImageLabel", profileCard)
avatarImg.Size = UDim2.new(0, 36, 0, 36)
avatarImg.Position = UDim2.new(0, 8, 0.5, -18)
avatarImg.BackgroundColor3 = C.pillBg
avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=150&h=150"
Corner(avatarImg, 18)

local nameLbl = Instance.new("TextLabel", profileCard)
nameLbl.Size = UDim2.new(1, -60, 0, 20)
nameLbl.Position = UDim2.new(0, 52, 0, 8)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = lp.DisplayName .. " (@" .. lp.Name .. ")"
nameLbl.TextColor3 = C.text
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 12
nameLbl.TextXAlignment = Enum.TextXAlignment.Left
nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

local idLbl = Instance.new("TextLabel", profileCard)
idLbl.Size = UDim2.new(1, -60, 0, 16)
idLbl.Position = UDim2.new(0, 52, 0, 28)
idLbl.BackgroundTransparency = 1
idLbl.Text = "ID: " .. lp.UserId
idLbl.TextColor3 = C.textDim
idLbl.Font = Enum.Font.Gotham
idLbl.TextSize = 10
idLbl.TextXAlignment = Enum.TextXAlignment.Left

Label(tabHome, "Stats", C.accent)

local statsCard = Instance.new("Frame", tabHome)
statsCard.Size = UDim2.new(1, 0, 0, 40)
statsCard.BackgroundColor3 = C.card
statsCard.BorderSizePixel = 0
Corner(statsCard, 6)
Stroke(statsCard, C.accentDim, 1)

local fpsLbl = Instance.new("TextLabel", statsCard)
fpsLbl.Size = UDim2.new(0.33, 0, 1, 0)
fpsLbl.Position = UDim2.new(0, 0, 0, 0)
fpsLbl.BackgroundTransparency = 1
fpsLbl.Text = "FPS: --"
fpsLbl.TextColor3 = C.green
fpsLbl.Font = Enum.Font.GothamBold
fpsLbl.TextSize = 11

local pingLbl = Instance.new("TextLabel", statsCard)
pingLbl.Size = UDim2.new(0.33, 0, 1, 0)
pingLbl.Position = UDim2.new(0.33, 0, 0, 0)
pingLbl.BackgroundTransparency = 1
pingLbl.Text = "PING: --"
pingLbl.TextColor3 = C.yellow
pingLbl.Font = Enum.Font.GothamBold
pingLbl.TextSize = 11

local playersLbl = Instance.new("TextLabel", statsCard)
playersLbl.Size = UDim2.new(0.33, 0, 1, 0)
playersLbl.Position = UDim2.new(0.66, 0, 0, 0)
playersLbl.BackgroundTransparency = 1
playersLbl.Text = "PLAYERS: " .. #Players:GetPlayers()
playersLbl.TextColor3 = C.accent
playersLbl.Font = Enum.Font.GothamBold
playersLbl.TextSize = 11

local fpsCount = 0
local fpsLast = tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - fpsLast >= 1 then
        fpsLbl.Text = "FPS: " .. fpsCount
        fpsCount = 0
        fpsLast = tick()
    end
end)

task.spawn(function()
    while GUI.Parent do
        local ping = 0
        pcall(function()
            ping = math.floor(lp:GetNetworkPing() * 1000)
        end)
        pingLbl.Text = "PING: " .. ping .. "ms"
        playersLbl.Text = "PLAYERS: " .. #Players:GetPlayers()
        task.wait(1)
    end
end)

Label(tabHome, "System Utils", C.accent)

Btn(tabHome, "Rejoin", function()
    TeleportService:TeleportToPlaceInstance(placeId, game.JobId, lp)
end)

Btn(tabHome, "Server Hop", function()
    local servers = {}
    pcall(function()
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if req and req.data then
            for _, s in ipairs(req.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
        end
    end)
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], lp)
    else
        Notify("PX-Menu", "Kein anderer Server gefunden", 3)
    end
end)

-- ════════════════════════════════════════════════════════════════
--  CHARACTER TAB
-- ════════════════════════════════════════════════════════════════

Label(tabChar, "Quick Actions", C.accent)

Btn(tabChar, "Rejoin", function()
    TeleportService:TeleportToPlaceInstance(placeId, game.JobId, lp)
end)

Btn(tabChar, "Respawn", function()
    if humanoid then humanoid.Health = 0 end
end)

Sep(tabChar)
Label(tabChar, "Voice Chat", C.accent)

local antiVCBanState = false
local antiVCConns = {}
local vcMicGui = nil

local function startAntiVCBan()
    if antiVCBanState then return end
    antiVCBanState = true
    pcall(function()
        local VoiceChatService = game:GetService("VoiceChatService")
        VoiceChatService:leaveVoice()
        task.wait(2.3)
        VoiceChatService:joinVoice()
    end)
    Notify("PX-Menu", "Anti-VC Ban aktiviert", 3)
end

local function stopAntiVCBan()
    if not antiVCBanState then return end
    antiVCBanState = false
    for _, c in ipairs(antiVCConns) do
        pcall(function() if type(c) ~= "thread" then c:Disconnect() end end)
    end
    antiVCConns = {}
    if vcMicGui and vcMicGui.Parent then vcMicGui:Destroy(); vcMicGui = nil end
    Notify("PX-Menu", "Anti-VC Ban deaktiviert", 2)
end

Toggle(tabChar, "Anti-VC Ban", function(on)
    if on then startAntiVCBan() else stopAntiVCBan() end
end)

Sep(tabChar)
Label(tabChar, "Movement", C.accent)

local flySpeedValue = 160
local flyActive = false
local flyConn = nil

local flyToggle = Toggle(tabChar, "Fly", function(on)
    if on then
        if flyConn then flyConn:Disconnect() end
        flyActive = true
        local bg = Instance.new("BodyGyro", hrp)
        bg.P = 9000
        bg.D = 500
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        flyConn = RunService.RenderStepped:Connect(function()
            if not hrp or not hrp.Parent then
                pcall(function() bg:Destroy() bv:Destroy() end)
                if flyConn then flyConn:Disconnect() end
                flyActive = false
                return
            end
            local camCF = Camera.CFrame
            bg.CFrame = camCF
            local moveDir = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0, -1, 0) end
            if moveDir.Magnitude > 0 then
                local worldDir = (camCF * CFrame.new(moveDir)).Position - camCF.Position
                if worldDir.Magnitude > 0 then
                    bv.Velocity = worldDir.Unit * flySpeedValue
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        flyActive = false
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if hrp then
            for _, c in ipairs(hrp:GetChildren()) do
                if c:IsA("BodyGyro") or c:IsA("BodyVelocity") then c:Destroy() end
            end
        end
    end
end)

Slider(tabChar, "Fly Speed", 10, 500, 160, function(v) flySpeedValue = v end)

local noclipConn = nil
Toggle(tabChar, "Noclip", function(on)
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end)

local antiFlingConn = nil
local antiFlingActive = false
Toggle(tabChar, "Anti-Fling", function(on)
    antiFlingActive = on
    if on then
        if antiFlingConn then antiFlingConn:Disconnect() end
        antiFlingConn = RunService.Heartbeat:Connect(function()
            if not antiFlingActive then return end
            if hrp and hrp.Parent then
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    else
        if antiFlingConn then antiFlingConn:Disconnect() antiFlingConn = nil end
    end
end)

Sep(tabChar)
Label(tabChar, "Stats", C.accent)

Slider(tabChar, "WalkSpeed", 0, 500, 16, function(v)
    if humanoid then humanoid.WalkSpeed = v end
end)

Slider(tabChar, "JumpPower", 0, 500, 50, function(v)
    if humanoid then humanoid.JumpPower = v end
end)

Sep(tabChar)
Label(tabChar, "Visual", C.accent)

local invisActive = false
local invisParts = {}
local invisHeartConn = nil
local invisSavedCF = nil

local function setInvis(on)
    invisActive = on
    if invisHeartConn then pcall(function() invisHeartConn:Disconnect() end); invisHeartConn = nil end
    local ch = lp.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not on then
        if root and invisSavedCF then
            pcall(function()
                root.CFrame = invisSavedCF
                root.AssemblyLinearVelocity = Vector3.zero
            end)
        end
        if hum then pcall(function() hum.CameraOffset = Vector3.zero end) end
        task.spawn(function()
            task.wait(0.05)
            for _, entry in ipairs(invisParts) do
                local part = entry.part
                if part and part.Parent then part.Transparency = entry.origTransp end
            end
            invisParts = {}
            invisSavedCF = nil
        end)
        return
    end
    if not ch then return end
    invisParts = {}
    for _, d in ipairs(ch:GetDescendants()) do
        if d:IsA("BasePart") and d.Transparency < 0.9 then
            table.insert(invisParts, {part = d, origTransp = d.Transparency})
        end
    end
    local initCF = root and root.CFrame
    if initCF then invisSavedCF = initCF end
    for _, entry in ipairs(invisParts) do
        local p = entry.part
        if p and p.Parent then p.Transparency = 0.99 end
    end
    invisHeartConn = RunService.Heartbeat:Connect(function()
        if not invisActive then return end
        local c = lp.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not (h and r) then return end
        for _, entry in ipairs(invisParts) do
            local part = entry.part
            if part and part.Parent and part.Transparency < 0.98 then
                part.Transparency = 0.99
            end
        end
        local curCF = r.CFrame
        if curCF.Position.Y > -100000 then invisSavedCF = curCF end
        local origOff = Vector3.zero
        pcall(function() origOff = h.CameraOffset end)
        pcall(function()
            r.CFrame = CFrame.new(curCF.Position.X, -200000, curCF.Position.Z)
            h.CameraOffset = Vector3.new(0, curCF.Position.Y + 200000, 0)
        end)
        task.spawn(function()
            pcall(function() RunService.RenderStepped:Wait() end)
            pcall(function()
                r.CFrame = curCF
                h.CameraOffset = origOff
            end)
        end)
    end)
end

Toggle(tabChar, "Invisible", function(on) setInvis(on) end)

lp.CharacterAdded:Connect(function()
    if invisActive then
        task.wait(0.5)
        setInvis(true)
    end
    if flyActive then
        flyToggle.set(false)
    end
end)

-- ════════════════════════════════════════════════════════════════
--  SCRIPTS TAB (with Sub-Tabs)
-- ════════════════════════════════════════════════════════════════

local subPages = {}
local subBtns = {}
local activeSubTab = nil

local SubTabBar = Instance.new("Frame", tabScripts)
SubTabBar.Name = "SubTabBar"
SubTabBar.Size = UDim2.new(1, 0, 0, 30)
SubTabBar.BackgroundColor3 = C.bg2
SubTabBar.BorderSizePixel = 0
Corner(SubTabBar, 6)

local subTabScroll = Instance.new("ScrollingFrame", SubTabBar)
subTabScroll.Size = UDim2.new(1, -8, 1, 0)
subTabScroll.Position = UDim2.new(0, 4, 0, 0)
subTabScroll.BackgroundTransparency = 1
subTabScroll.BorderSizePixel = 0
subTabScroll.ScrollBarThickness = 0
subTabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
subTabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
local subTabLayout = Instance.new("UIListLayout", subTabScroll)
subTabLayout.FillDirection = Enum.FillDirection.Horizontal
subTabLayout.Padding = UDim.new(0, 4)
subTabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local subTabNames = {"TROLL", "MOVEMENT", "VISUAL", "MISC", "COMBAT"}

local function createSubPage(name)
    local sp = Instance.new("ScrollingFrame", tabScripts)
    sp.Name = name
    sp.Size = UDim2.new(1, 0, 1, -36)
    sp.Position = UDim2.new(0, 0, 0, 34)
    sp.BackgroundTransparency = 1
    sp.BorderSizePixel = 0
    sp.ScrollBarThickness = 3
    sp.ScrollBarImageColor3 = C.accent
    sp.CanvasSize = UDim2.new(0, 0, 0, 0)
    sp.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sp.Visible = false
    MakeList(sp, 6)
    MakePad(sp, 4, 10, 4, 4)
    subPages[name] = sp
    return sp
end

local function showSubTab(name)
    for _, p in pairs(subPages) do p.Visible = false end
    for n, b in pairs(subBtns) do
        b.BackgroundColor3 = C.pillBg
        b.TextColor3 = C.textDim
    end
    if subPages[name] then subPages[name].Visible = true end
    if subBtns[name] then
        subBtns[name].BackgroundColor3 = C.accent
        subBtns[name].TextColor3 = C.text
    end
    activeSubTab = name
end

for i, name in ipairs(subTabNames) do
    local btn = Instance.new("TextButton", subTabScroll)
    btn.Size = UDim2.new(0, #name * 8 + 16, 1, -6)
    btn.BackgroundColor3 = i == 1 and C.accent or C.pillBg
    btn.Text = name
    btn.TextColor3 = i == 1 and C.text or C.textDim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Corner(btn, 4)
    subBtns[name] = btn
    btn.MouseButton1Click:Connect(function() showSubTab(name) end)
end

local subTroll = createSubPage("TROLL")
local subMovement = createSubPage("MOVEMENT")
local subVisual = createSubPage("VISUAL")
local subMisc = createSubPage("MISC")
local subCombat = createSubPage("COMBAT")

-- ════════════════════════════════════════════════════════════════
--  TROLL SUB-TAB
-- ════════════════════════════════════════════════════════════════

Label(subTroll, "HeadSeat - Spieler zum Sitzen zwingen", C.accent)

local headSeatTarget = nil
local plListTroll = PlayerListWidget(subTroll, function(p) headSeatTarget = p end)

Btn(subTroll, "HeadSeat Ziel", function()
    if headSeatTarget and headSeatTarget.Character then
        local head = headSeatTarget.Character:FindFirstChild("Head")
        local tgtHRP = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        local tgtHum = headSeatTarget.Character:FindFirstChildOfClass("Humanoid")
        if head and tgtHRP and tgtHum then
            local seat = Instance.new("Seat")
            seat.Size = Vector3.new(2, 1, 2)
            seat.Transparency = 1
            seat.CanCollide = false
            seat.Anchored = false
            seat.CFrame = tgtHRP.CFrame * CFrame.new(0, -2, 0)
            seat.Parent = workspace
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = seat
            weld.Part1 = head
            weld.Parent = seat
            tgtHum.SeatPart = seat
            Debris:AddItem(seat, 12)
        end
    end
end)

Btn(subTroll, "Alle HeadSeat", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local tgtHRP = p.Character:FindFirstChild("HumanoidRootPart")
            local tgtHum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and tgtHRP and tgtHum then
                local seat = Instance.new("Seat")
                seat.Size = Vector3.new(2, 1, 2)
                seat.Transparency = 1
                seat.CanCollide = false
                seat.Anchored = false
                seat.CFrame = tgtHRP.CFrame * CFrame.new(0, -2, 0)
                seat.Parent = workspace
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = seat
                weld.Part1 = head
                weld.Parent = seat
                tgtHum.SeatPart = seat
                Debris:AddItem(seat, 10)
            end
        end
    end
end)

Sep(subTroll)
Label(subTroll, "Spieler Aktionen", C.accent)

Btn(subTroll, "Hochwerfen", function()
    if headSeatTarget and headSeatTarget.Character then
        local tgtHRP = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        if tgtHRP then
            local bv = Instance.new("BodyVelocity", tgtHRP)
            bv.Velocity = Vector3.new(0, 200, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            Debris:AddItem(bv, 0.5)
        end
    end
end)

Btn(subTroll, "Fliegen lassen", function()
    if headSeatTarget and headSeatTarget.Character then
        local tgtHRP = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        if tgtHRP then
            local bv = Instance.new("BodyVelocity", tgtHRP)
            bv.Velocity = Vector3.new(0, 150, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            Debris:AddItem(bv, 2)
            local bg = Instance.new("BodyAngularVelocity", tgtHRP)
            bg.AngularVelocity = Vector3.new(0, 50, 0)
            bg.MaxTorque = Vector3.new(0, math.huge, 0)
            Debris:AddItem(bg, 2)
        end
    end
end)

Btn(subTroll, "Wegrutschen", function()
    if headSeatTarget and headSeatTarget.Character then
        local tgtHRP = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        if tgtHRP then
            local bv = Instance.new("BodyVelocity", tgtHRP)
            local angle = math.random() * math.pi * 2
            bv.Velocity = Vector3.new(math.cos(angle) * 150, 20, math.sin(angle) * 150)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            Debris:AddItem(bv, 1)
        end
    end
end)

Btn(subTroll, "Festnageln", function()
    if headSeatTarget and headSeatTarget.Character then
        local tgtHRP = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        if tgtHRP then
            tgtHRP.Anchored = true
            task.delay(3, function()
                if tgtHRP and tgtHRP.Parent then tgtHRP.Anchored = false end
            end)
        end
    end
end)

Btn(subTroll, "Schwerkraft Spieler", function()
    if headSeatTarget and headSeatTarget.Character then
        local tgtHRP = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        if tgtHRP then
            local bf = Instance.new("BodyForce", tgtHRP)
            bf.Force = Vector3.new(0, 5000, 0)
            Debris:AddItem(bf, 2)
        end
    end
end)

Btn(subTroll, "Platt druecken", function()
    if headSeatTarget and headSeatTarget.Character then
        local tgtHRP = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        if tgtHRP then
            local bf = Instance.new("BodyForce", tgtHRP)
            bf.Force = Vector3.new(0, -10000, 0)
            Debris:AddItem(bf, 1)
        end
    end
end)

Sep(subTroll)
Label(subTroll, "Alle Spieler", C.accent)

Btn(subTroll, "Alle Hochwerfen", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local tgtHRP = p.Character:FindFirstChild("HumanoidRootPart")
            if tgtHRP then
                local bv = Instance.new("BodyVelocity", tgtHRP)
                bv.Velocity = Vector3.new(0, 200, 0)
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                Debris:AddItem(bv, 0.5)
            end
        end
    end
end)

Btn(subTroll, "Alle Rotieren", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local tgtHRP = p.Character:FindFirstChild("HumanoidRootPart")
            if tgtHRP then
                local bg = Instance.new("BodyAngularVelocity", tgtHRP)
                bg.AngularVelocity = Vector3.new(0, 100, 0)
                bg.MaxTorque = Vector3.new(0, math.huge, 0)
                Debris:AddItem(bg, 3)
            end
        end
    end
end)

Sep(subTroll)
Label(subTroll, "Spieler Verfolgen", C.accent)

Btn(subTroll, "Zu Spieler telep.", function()
    if headSeatTarget and headSeatTarget.Character and hrp then
        local t = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame = t.CFrame * CFrame.new(0, 0, -5) end
    end
end)

Btn(subTroll, "Hinter Spieler", function()
    if headSeatTarget and headSeatTarget.Character and hrp then
        local t = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame = t.CFrame * CFrame.new(0, 0, 5) end
    end
end)

Btn(subTroll, "Auf Spieler stehen", function()
    if headSeatTarget and headSeatTarget.Character and hrp then
        local t = headSeatTarget.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame = t.CFrame * CFrame.new(0, 3, 0) end
    end
end)

Btn(subTroll, "Liste aktualisieren", function()
    plListTroll.refresh()
end)

-- ════════════════════════════════════════════════════════════════
--  MOVEMENT SUB-TAB
-- ════════════════════════════════════════════════════════════════

Label(subMovement, "Bewegung", C.accent)

local spinConn = nil
Toggle(subMovement, "Spin", function(on)
    if on then
        if spinConn then spinConn:Disconnect() end
        spinConn = RunService.Heartbeat:Connect(function()
            if hrp and hrp.Parent then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(5), 0)
            end
        end)
    else
        if spinConn then spinConn:Disconnect() spinConn = nil end
    end
end)

Btn(subMovement, "Open Avatar Stealer", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/obl1vroot-lab/PX-Menu/main/AVATAR-STEAL-PANEL.lua"))()
    end)
end)

-- ════════════════════════════════════════════════════════════════
--  VISUAL SUB-TAB
-- ════════════════════════════════════════════════════════════════

Label(subVisual, "ESP - Spieler Markierung", C.accent)

local espEnabled = false
local espData = {}
local espConn = nil

local function clearESP()
    for pl, d in pairs(espData) do
        if d.hl and d.hl.Parent then pcall(function() d.hl:Destroy() end) end
        if d.bb and d.bb.Parent then pcall(function() d.bb:Destroy() end) end
    end
    espData = {}
end

local function addESPPlayer(pl)
    if not espEnabled or pl == lp then return end
    if not pl.Character then return end
    local head = pl.Character:FindFirstChild("Head")
    if not head then return end
    local col = C.accentGlow
    local hl = nil
    pcall(function()
        hl = Instance.new("Highlight")
        hl.Adornee = pl.Character
        hl.FillTransparency = 1
        hl.FillColor = col
        hl.OutlineColor = col
        hl.OutlineTransparency = 0
        hl.Parent = pl.Character
    end)
    local bb = nil
    pcall(function()
        bb = Instance.new("BillboardGui", head)
        bb.Name = "ESP_BB"
        bb.Size = UDim2.new(0, 120, 0, 20)
        bb.StudsOffset = Vector3.new(0, 2.4, 0)
        bb.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = pl.DisplayName
        lbl.TextColor3 = col
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lbl.TextStrokeTransparency = 0
    end)
    espData[pl] = {hl = hl, bb = bb}
end

Toggle(subVisual, "ESP", function(on)
    espEnabled = on
    clearESP()
    if on then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= lp then addESPPlayer(pl) end
        end
        espConn = Players.PlayerAdded:Connect(function(pl)
            task.wait(0.5)
            if espEnabled then addESPPlayer(pl) end
        end)
    else
        if espConn then espConn:Disconnect() espConn = nil end
    end
end)

Sep(subVisual)
Label(subVisual, "Shaders", C.accent)

local shaderActive = false
local shaderInsts = {}
local origLighting = nil

local function shClean()
    for _, v in ipairs(shaderInsts) do pcall(function() v:Destroy() end) end
    shaderInsts = {}
    if origLighting then
        pcall(function()
            Lighting.Brightness = origLighting.Brightness
            Lighting.Ambient = origLighting.Ambient
            Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
            Lighting.ClockTime = origLighting.ClockTime
            Lighting.ExposureCompensation = origLighting.Exposure
        end)
        origLighting = nil
    end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child.Name:find("PXShader_") then pcall(function() child:Destroy() end) end
    end
end

local function shApply()
    shClean()
    if not origLighting then
        origLighting = {
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ClockTime = Lighting.ClockTime,
            Exposure = Lighting.ExposureCompensation,
        }
    end
    pcall(function()
        Lighting.Brightness = 2.25
        Lighting.ClockTime = 17.55
        Lighting.ExposureCompensation = 0.1
    end)
    local function mk(cls, name, props)
        local inst = Instance.new(cls)
        inst.Name = "PXShader_" .. name
        for k, v in pairs(props) do inst[k] = v end
        inst.Parent = Lighting
        table.insert(shaderInsts, inst)
        return inst
    end
    mk("ColorCorrectionEffect", "Color", {Brightness = 0, Contrast = 0.1, Saturation = 0.25, TintColor = Color3.fromRGB(255, 255, 255)})
    mk("BloomEffect", "Bloom", {Enabled = true, Intensity = 0.3, Size = 10, Threshold = 0.8})
    mk("SunRaysEffect", "Sun", {Enabled = true, Intensity = 0.1, Spread = 0.8})
end

Toggle(subVisual, "Shaders", function(on)
    shaderActive = on
    if on then shApply() else shClean() end
end)

Sep(subVisual)
Label(subVisual, "Umgebung", C.accent)

Slider(subVisual, "Schwerkraft", 0, 200, 196, function(v) workspace.Gravity = v end)

Btn(subVisual, "Nacht Mode", function() Lighting.ClockTime = 0 end)
Btn(subVisual, "Tag Mode", function() Lighting.ClockTime = 14 end)
Btn(subVisual, "Fog Entfernen", function()
    Lighting.FogEnd = 999999
    Lighting.FogStart = 0
end)
Btn(subVisual, "Boden zerstoeren", function()
    local base = workspace:FindFirstChild("Base") or workspace:FindFirstChild("Baseplate")
    if base then base:Destroy() end
end)

-- ════════════════════════════════════════════════════════════════
--  MISC SUB-TAB
-- ════════════════════════════════════════════════════════════════

Label(subMisc, "Anti-AFK", C.accent)

local antiAfkConn = nil
Btn(subMisc, "Anti-AFK aktivieren", function()
    if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
    antiAfkConn = RunService.Heartbeat:Connect(function()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
    Notify("PX-Menu", "Anti-AFK aktiviert", 3)
end)

Btn(subMisc, "Anti-AFK deaktivieren", function()
    if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
    Notify("PX-Menu", "Anti-AFK deaktiviert", 2)
end)

Sep(subMisc)
Label(subMisc, "Server", C.accent)

Btn(subMisc, "Rejoin", function()
    TeleportService:TeleportToPlaceInstance(placeId, game.JobId, lp)
end)

Btn(subMisc, "Server Hop", function()
    local servers = {}
    pcall(function()
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if req and req.data then
            for _, s in ipairs(req.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
        end
    end)
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], lp)
    else
        Notify("PX-Menu", "Kein anderer Server gefunden", 3)
    end
end)

Btn(subMisc, "Copy Server ID", function()
    pcall(function()
        if setclipboard then
            setclipboard(game.JobId)
            Notify("PX-Menu", "Server ID kopiert!", 2)
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════
--  COMBAT SUB-TAB
-- ════════════════════════════════════════════════════════════════

Label(subCombat, "Fling Engine (SkidFling)", C.accent)

local flingActive = false
local flingConn = nil
local flingSelectedPlayer = nil
local _flingSavedCFrame = nil
local _flingThread = nil

local function _flingDisconnect()
    flingActive = false
    if flingConn then
        pcall(function() flingConn:Disconnect() end)
        flingConn = nil
    end
    if _flingThread then
        pcall(function() task.cancel(_flingThread) end)
        _flingThread = nil
    end
end

local function _skidFling(targetPlayer)
    local myChar = lp.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myRoot = myHum and myHum.RootPart
    local tChar = targetPlayer and targetPlayer.Character
    if not myChar or not myHum or not myRoot or not tChar then return end
    local tHum = tChar:FindFirstChildOfClass("Humanoid")
    local tRoot = tHum and tHum.RootPart
    local tHead = tChar:FindFirstChild("Head")
    local Handle = (tChar:FindFirstChildOfClass("Accessory") or {Handle = nil}).Handle
    local BasePart = tRoot or tHead or Handle
    if not BasePart then return end
    if myRoot.Velocity.Magnitude < 50 then
        _flingSavedCFrame = myRoot.CFrame
    end
    if tHum and tHum.Sit then return end
    local savedFPDH = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0/0
    local BV = Instance.new("BodyVelocity")
    BV.Parent = myRoot
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    local FPos = function(bp, pos, ang)
        myRoot.CFrame = CFrame.new(bp.Position) * pos * ang
        pcall(function() myChar:SetPrimaryPartCFrame(CFrame.new(bp.Position) * pos * ang) end)
        myRoot.Velocity = Vector3.new(9e7, 9e7*10, 9e7)
        myRoot.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end
    local deadline = tick() + 2
    local angle = 0
    repeat
        if not (myRoot and myRoot.Parent and tHum and tHum.Parent) then break end
        if BasePart.Velocity.Magnitude < 50 then
            angle = angle + 100
            FPos(BasePart, CFrame.new(0,1.5,0) + tHum.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,0)+ tHum.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,1.5,0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,0)+ tHum.MoveDirection, CFrame.Angles(math.rad(angle),0,0)) task.wait()
        else
            FPos(BasePart, CFrame.new(0,1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,-tHum.WalkSpeed), CFrame.Angles(0,0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) task.wait()
        end
    until tick() > deadline or not flingActive
    BV:Destroy()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    if _flingSavedCFrame and myRoot and myRoot.Parent then
        local tries = 0
        repeat
            pcall(function()
                myRoot.CFrame = _flingSavedCFrame * CFrame.new(0,0.5,0)
                myChar:SetPrimaryPartCFrame(_flingSavedCFrame * CFrame.new(0,0.5,0))
                myHum:ChangeState("GettingUp")
                for _, part in ipairs(myChar:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                    end
                end
            end)
            task.wait()
            tries = tries + 1
        until (myRoot.Position - _flingSavedCFrame.p).Magnitude < 25 or tries > 30
    end
    workspace.FallenPartsDestroyHeight = savedFPDH
end

local function flingStop()
    _flingDisconnect()
    local savedCF = _flingSavedCFrame
    _flingSavedCFrame = nil
    task.spawn(function()
        task.wait(0.08)
        pcall(function()
            local ch = lp.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local r = hum and hum.RootPart
            if not hum or not r then return end
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
            hum.PlatformStand = false
            for _, p in ipairs(ch:GetChildren()) do
                if p:IsA("BasePart") then
                    pcall(function() p.Velocity = Vector3.zero end)
                    pcall(function() p.RotVelocity = Vector3.zero end)
                end
            end
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BodyVelocity") or p:IsA("BodyGyro") or p:IsA("BodyPosition") then
                    pcall(function() p:Destroy() end)
                end
            end
            if savedCF then
                for attempt = 1, 15 do
                    pcall(function()
                        r.CFrame = savedCF * CFrame.new(0, 0.5, 0)
                        ch:SetPrimaryPartCFrame(savedCF * CFrame.new(0, 0.5, 0))
                    end)
                    task.wait(0.05)
                    if (r.Position - savedCF.p).Magnitude < 10 then break end
                end
            end
            task.wait(0.05)
            hum.PlatformStand = false
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end)
    end)
end

local function flingStart(targetPlayer)
    _flingDisconnect()
    if not targetPlayer then return end
    pcall(function()
        local ch = lp.Character
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        if r then _flingSavedCFrame = r.CFrame end
    end)
    flingActive = true
    _flingThread = task.spawn(function()
        while flingActive do
            _skidFling(targetPlayer)
            if flingActive then task.wait(0.1) end
        end
    end)
end

local flingTarget = nil
local plListFling = PlayerListWidget(subCombat, function(p) flingTarget = p end, 120)

Btn(subCombat, "Fling Start", function()
    if flingTarget then
        flingStart(flingTarget)
        Notify("PX-Menu", "Fling aktiv: " .. flingTarget.Name, 3)
    end
end)

Btn(subCombat, "Fling Stop", function()
    flingStop()
    Notify("PX-Menu", "Fling gestoppt", 2)
end)

Btn(subCombat, "Liste aktualisieren", function()
    plListFling.refresh()
end)

-- ════════════════════════════════════════════════════════════════
--  ACTIONS TAB
-- ════════════════════════════════════════════════════════════════

Label(tabActions, "Ziel Spieler auswaehlen", C.accent)

local actionTarget = nil
local plListActions = PlayerListWidget(tabActions, function(p) actionTarget = p end, 140)

Sep(tabActions)
Label(tabActions, "Aktionen", C.accent)

Btn(tabActions, "Teleportiere zu Spieler", function()
    if actionTarget and actionTarget.Character and hrp then
        local t = actionTarget.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame = t.CFrame * CFrame.new(0, 0, -5) end
    end
end)

Btn(tabActions, "Hinter Spieler", function()
    if actionTarget and actionTarget.Character and hrp then
        local t = actionTarget.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame = t.CFrame * CFrame.new(0, 0, 5) end
    end
end)

Btn(tabActions, "Auf Spieler stehen", function()
    if actionTarget and actionTarget.Character and hrp then
        local t = actionTarget.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame = t.CFrame * CFrame.new(0, 3, 0) end
    end
end)

Btn(tabActions, "Spectate Spieler", function()
    if actionTarget and actionTarget.Character then
        local head = actionTarget.Character:FindFirstChild("Head")
        if head then Camera.CameraSubject = head end
    end
end)

Btn(tabActions, "Spectate Stoppen", function()
    if humanoid then Camera.CameraSubject = humanoid end
end)

Btn(tabActions, "Liste aktualisieren", function()
    plListActions.refresh()
end)

-- ════════════════════════════════════════════════════════════════
--  PLAYERLIST TAB
-- ════════════════════════════════════════════════════════════════

Label(tabPlayers, "Alle Spieler (" .. #Players:GetPlayers() .. ")", C.accent)

local plTarget = nil
local plListMain = PlayerListWidget(tabPlayers, function(p) plTarget = p end, 250)

Sep(tabPlayers)
Label(tabPlayers, "Aktionen", C.accent)

Btn(tabPlayers, "Teleportiere zu Spieler", function()
    if plTarget and plTarget.Character and hrp then
        local t = plTarget.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame = t.CFrame * CFrame.new(0, 0, -5) end
    end
end)

Btn(tabPlayers, "Hinter Spieler", function()
    if plTarget and plTarget.Character and hrp then
        local t = plTarget.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame = t.CFrame * CFrame.new(0, 0, 5) end
    end
end)

Btn(tabPlayers, "Auf Spieler stehen", function()
    if plTarget and plTarget.Character and hrp then
        local t = plTarget.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame = t.CFrame * CFrame.new(0, 3, 0) end
    end
end)

Btn(tabPlayers, "Spectate Spieler", function()
    if plTarget and plTarget.Character then
        local head = plTarget.Character:FindFirstChild("Head")
        if head then Camera.CameraSubject = head end
    end
end)

Btn(tabPlayers, "Spectate Stoppen", function()
    if humanoid then Camera.CameraSubject = humanoid end
end)

Btn(tabPlayers, "Liste aktualisieren", function()
    plListMain.refresh()
end)

-- ════════════════════════════════════════════════════════════════
--  SETTINGS TAB
-- ════════════════════════════════════════════════════════════════

Label(tabSettings, "Keybinds", C.accent)

local keybindDefs = {}
local keybindObjs = {}
local toggleKey = "RightShift"

local kbToggle = Instance.new("Frame", tabSettings)
kbToggle.Size = UDim2.new(1, 0, 0, 36)
kbToggle.BackgroundColor3 = C.card
kbToggle.BorderSizePixel = 0
Corner(kbToggle, 6)
Stroke(kbToggle, C.accentDim, 1)
local kbLabel = Instance.new("TextLabel", kbToggle)
kbLabel.Size = UDim2.new(0.55, 0, 1, 0)
kbLabel.Position = UDim2.new(0, 10, 0, 0)
kbLabel.BackgroundTransparency = 1
kbLabel.Text = "Menu Toggle"
kbLabel.TextColor3 = C.text
kbLabel.Font = Enum.Font.GothamBold
kbLabel.TextSize = 12
kbLabel.TextXAlignment = Enum.TextXAlignment.Left
local kbBtn = Instance.new("TextButton", kbToggle)
kbBtn.Size = UDim2.new(0, 100, 0, 22)
kbBtn.Position = UDim2.new(1, -110, 0.5, -11)
kbBtn.BackgroundColor3 = C.pillBg
kbBtn.Text = toggleKey
kbBtn.TextColor3 = C.accent
kbBtn.Font = Enum.Font.GothamBold
kbBtn.TextSize = 10
kbBtn.BorderSizePixel = 0
kbBtn.AutoButtonColor = false
Corner(kbBtn, 4)
local waitingToggle = false
kbBtn.MouseButton1Click:Connect(function()
    if waitingToggle then return end
    waitingToggle = true
    kbBtn.Text = "..."
    kbBtn.BackgroundColor3 = C.accent
end)

Sep(tabSettings)

local binds = {
    {name = "Fly Toggle", key = "F", id = "fly"},
    {name = "Noclip Toggle", key = "N", id = "noclip"},
    {name = "ESP Toggle", key = "E", id = "esp"},
    {name = "Spin Toggle", key = "Q", id = "spin"},
}

for _, b in ipairs(binds) do
    local kb = Keybind(tabSettings, b.name, b.key, function(key)
        keybindDefs[b.id] = key
    end)
    table.insert(keybindObjs, kb)
    keybindDefs[b.id] = b.key
end

Sep(tabSettings)
Label(tabSettings, "Aktionen", C.accent)

Btn(tabSettings, "Settings zuruecksetzen", function()
    toggleKey = "RightShift"
    kbBtn.Text = "RightShift"
    for _, kb in ipairs(keybindObjs) do
        kb.setBind(nil)
    end
end)

Btn(tabSettings, "Menu schliessen", function()
    -- Cleanup
    if flyConn then flyConn:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    if espConn then espConn:Disconnect() end
    if spinConn then spinConn:Disconnect() end
    if antiAfkConn then antiAfkConn:Disconnect() end
    if invisHeartConn then invisHeartConn:Disconnect() end
    if antiFlingConn then antiFlingConn:Disconnect() end
    if flyActive then
        if hrp then
            for _, c in ipairs(hrp:GetChildren()) do
                if c:IsA("BodyGyro") or c:IsA("BodyVelocity") then c:Destroy() end
            end
        end
    end
    if invisActive then setInvis(false) end
    if shaderActive then shClean() end
    flingStop()
    clearESP()
    GUI:Destroy()
end)

-- ════════════════════════════════════════════════════════════════
--  KEYBIND HANDLER
-- ════════════════════════════════════════════════════════════════

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    -- Check if any keybind button is waiting
    for _, kb in ipairs(keybindObjs) do
        if kb.isWaiting() then
            kb.accept(input.KeyCode)
            return
        end
    end

    -- Toggle key waiting
    if waitingToggle then
        waitingToggle = false
        toggleKey = input.KeyCode.Name
        kbBtn.Text = toggleKey
        kbBtn.BackgroundColor3 = C.pillBg
        return
    end

    -- Toggle menu
    if input.KeyCode.Name == toggleKey then
        Main.Visible = not Main.Visible
        Indicator.Visible = Main.Visible
        return
    end

    -- Feature keybinds
    local keyName = input.KeyCode.Name
    if keybindDefs["fly"] == keyName then
        flyToggle.set(not flyToggle.get())
    elseif keybindDefs["noclip"] == keyName then
        -- Find noclip toggle and toggle it
    elseif keybindDefs["esp"] == keyName then
        -- Find ESP toggle and toggle it
    elseif keybindDefs["spin"] == keyName then
        -- Find spin toggle and toggle it
    end
end)

-- Minimize
MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- ════════════════════════════════════════════════════════════════
--  LOADING SEQUENCE
-- ════════════════════════════════════════════════════════════════

task.spawn(function()
    UpdateLoading(0.1, "Initialisiere Core...")
    task.wait(0.2)
    UpdateLoading(0.3, "Lade Game Detection...")
    task.wait(0.2)
    UpdateLoading(0.5, "Lade Features...")
    task.wait(0.2)
    UpdateLoading(0.7, "Erstelle UI...")
    task.wait(0.2)
    UpdateLoading(0.9, "Finalisiere...")
    task.wait(0.2)
    UpdateLoading(1.0, "Fertig!")
    task.wait(0.3)
    LoadingGui:Destroy()
    Main.Visible = true
    showTab("HOME")
    IndLabel.Text = "PX-Menu | " .. ExecutorName .. " | [" .. toggleKey .. "] to toggle"
    print("[PX-Menu] v4.0 loaded! Executor: " .. ExecutorName .. " | " .. toggleKey .. " to toggle menu.")
    print("[PX-Menu] Features: Fly, Noclip, ESP, Shaders, Anti-VC Ban, Invisible, Fling, Avatar Steal")
end)
