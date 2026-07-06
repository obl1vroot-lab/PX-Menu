--[[
    PX-Menu v3.0 Core
    Game: German Voice (ID: 136162036182779)
    Toggle Key: RightShift (configurable)
    
    Usage:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/obl1vroot-lab/PX-Menu/main/PX-Menu-Core.lua"))()
]]

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
    WarnFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    WarnFrame.BorderSizePixel = 0
    Instance.new("UICorner", WarnFrame).CornerRadius = UDim.new(0, 10)
    local ws = Instance.new("UIStroke", WarnFrame)
    ws.Color = Color3.fromRGB(255, 85, 85)
    ws.Thickness = 2
    ws.Transparency = 0.3
    local WarnTitle = Instance.new("TextLabel", WarnFrame)
    WarnTitle.Size = UDim2.new(1, -20, 0, 30)
    WarnTitle.Position = UDim2.new(0, 12, 0, 10)
    WarnTitle.BackgroundTransparency = 1
    WarnTitle.Text = "PX-Menu"
    WarnTitle.TextColor3 = Color3.fromRGB(255, 85, 85)
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
--  CORE SERVICES
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

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
--  COLOR SCHEME
-- ════════════════════════════════════════════════════════════════

local C = {
    bg = Color3.fromRGB(24, 24, 32),
    header = Color3.fromRGB(30, 30, 40),
    card = Color3.fromRGB(36, 36, 50),
    cardHover = Color3.fromRGB(44, 44, 58),
    accent = Color3.fromRGB(100, 50, 170),
    accentDark = Color3.fromRGB(60, 30, 100),
    accentGlow = Color3.fromRGB(130, 70, 200),
    text = Color3.fromRGB(230, 230, 240),
    textDim = Color3.fromRGB(140, 140, 160),
    green = Color3.fromRGB(40, 200, 80),
    red = Color3.fromRGB(220, 40, 40),
    yellow = Color3.fromRGB(220, 180, 40),
    sep = Color3.fromRGB(40, 40, 55),
    pillBg = Color3.fromRGB(22, 22, 30),
    pillSel = Color3.fromRGB(100, 50, 170),
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
    s.Color = col or C.accentDark
    s.Thickness = w or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
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

local function Sep(parent)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 1)
    f.BackgroundColor3 = C.sep
    f.BorderSizePixel = 0
    return f
end

local function Card(parent, text, height)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, height or 42)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    f.AutomaticSize = Enum.AutomaticSize.Y
    Corner(f, 6)
    Stroke(f, C.accentDark, 1)
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
    Stroke(btn, C.accentDark, 1)
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
        btn.BackgroundColor3 = state and C.accentDark or C.pillBg
        if callback then callback(state) end
    end)
    return {
        set = function(v)
            state = v
            indicator.BackgroundColor3 = v and C.green or C.textDim
            indicator.Position = v and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
            btn.BackgroundColor3 = v and C.accentDark or C.pillBg
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
    UserInputService.InputChanged:Connect(function(input)
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
    UserInputService.InputEnded:Connect(function(input)
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

local function PlayerList(parent, onSelect, height)
    local results = {}
    local selected = nil
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, height or 160)
    container.BackgroundColor3 = C.card
    container.BorderSizePixel = 0
    Corner(container, 6)
    Stroke(container, C.accentDark, 1)
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

    local function refresh(filter)
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        results = {}
        local idx = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if not filter or filter == "" or string.find(string.lower(p.Name), string.lower(filter), 1, true) or string.find(string.lower(p.DisplayName), string.lower(filter), 1, true) then
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
    end

    refresh()

    return {
        refresh = refresh,
        selected = function() return selected end,
        getResults = function() return results end
    }
end

-- ════════════════════════════════════════════════════════════════
--  GUI CREATION
-- ════════════════════════════════════════════════════════════════

local function ClearExisting()
    if CoreGui:FindFirstChild("PX-Menu") then
        CoreGui:FindFirstChild("PX-Menu"):Destroy()
    end
end

ClearExisting()

local GUI = Instance.new("ScreenGui")
GUI.Name = "PX-Menu"
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999
GUI.Parent = CoreGui

-- ════════════════════════════════════════════════════════════════
--  INDICATOR (Executor + Menu Status)
-- ════════════════════════════════════════════════════════════════

local Indicator = Instance.new("Frame", GUI)
Indicator.Name = "Indicator"
Indicator.Size = UDim2.new(0, 200, 0, 30)
Indicator.Position = UDim2.new(1, -220, 0, 10)
Indicator.BackgroundColor3 = C.bg
Indicator.BackgroundTransparency = 0.2
Indicator.BorderSizePixel = 0
Corner(Indicator, 8)
Stroke(Indicator, ExecutorTrusted and C.green or C.yellow, 1)

local IndLabel = Instance.new("TextLabel", Indicator)
IndLabel.Size = UDim2.new(1, -10, 1, 0)
IndLabel.Position = UDim2.new(0, 8, 0, 0)
IndLabel.BackgroundTransparency = 1
IndLabel.Text = "PX-Menu | " .. ExecutorName
IndLabel.TextColor3 = ExecutorTrusted and C.green or C.yellow
IndLabel.Font = Enum.Font.GothamBold
IndLabel.TextSize = 11
IndLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ════════════════════════════════════════════════════════════════
--  LOADING ANIMATION
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
LoadTitle.Text = "PX-Menu v3.0"
LoadTitle.TextColor3 = C.accent
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextSize = 20

local LoadStatus = Instance.new("TextLabel", LoadingFrame)
LoadStatus.Size = UDim2.new(1, -20, 0, 20)
LoadStatus.Position = UDim2.new(0, 10, 0, 50)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Text = "Lade Module..."
LoadStatus.TextColor3 = C.textDim
LoadStatus.Font = Enum.Font.Gotham
LoadStatus.TextSize = 12

local ProgressBarBG = Instance.new("Frame", LoadingFrame)
ProgressBarBG.Size = UDim2.new(1, -40, 0, 8)
ProgressBarBG.Position = UDim2.new(0, 20, 0, 80)
ProgressBarBG.BackgroundColor3 = C.pillBg
ProgressBarBG.BorderSizePixel = 0
Corner(ProgressBarBG, 4)

local ProgressBarFill = Instance.new("Frame", ProgressBarBG)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = C.accent
ProgressBarFill.BorderSizePixel = 0
Corner(ProgressBarFill, 4)

local LoadTween = TweenService:Create(ProgressBarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {})

local function UpdateLoading(progress, status)
    LoadStatus.Text = status or "Lade..."
    ProgressBarFill.Size = UDim2.new(progress, 0, 1, 0)
end

-- ════════════════════════════════════════════════════════════════
--  MAIN MENU
-- ════════════════════════════════════════════════════════════════

local dragging = false
local dragStart = nil
local startPos = nil

local Main = Instance.new("Frame", GUI)
Main.Name = "Main"
Main.Size = UDim2.new(0, 460, 0, 540)
Main.Position = UDim2.new(0.5, -230, 0.5, -270)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Corner(Main, 8)
Stroke(Main, C.accentDark, 1)

local Header = Instance.new("Frame", Main)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel = 0
Header.ZIndex = 2
Corner(Header, 8)

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "PX-MENU"
TitleLabel.TextColor3 = C.accent
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatusLabel = Instance.new("TextLabel", Header)
StatusLabel.Size = UDim2.new(0, 80, 1, 0)
StatusLabel.Position = UDim2.new(1, -90, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "v3.0"
StatusLabel.TextColor3 = C.textDim
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12

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
        conn = UserInputService.InputChanged:Connect(function(input2)
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
--  TAB SYSTEM
-- ════════════════════════════════════════════════════════════════

local TabHolder = Instance.new("Frame", Main)
TabHolder.Name = "TabHolder"
TabHolder.Size = UDim2.new(1, 0, 0, 34)
TabHolder.Position = UDim2.new(0, 0, 0, 40)
TabHolder.BackgroundColor3 = C.header
TabHolder.BorderSizePixel = 0
TabHolder.ZIndex = 2

local tabScroll = Instance.new("ScrollingFrame", TabHolder)
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
Instance.new("UIPadding", tabScroll).PaddingLeft = UDim.new(0, 2)

local Content = Instance.new("Frame", Main)
Content.Name = "Content"
Content.Size = UDim2.new(1, -12, 1, -86)
Content.Position = UDim2.new(0, 6, 0, 80)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true

local Pages = {}
local tabBtns = {}
local activeTab = nil

local function createTab(name)
    local btn = Instance.new("TextButton", tabScroll)
    btn.Size = UDim2.new(0, #name * 9 + 20, 1, -6)
    btn.BackgroundColor3 = C.pillBg
    btn.TextColor3 = C.textDim
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 3
    Corner(btn, 6)

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
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 6)
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 4)
    page.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    page.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    Pages[name] = page
    tabBtns[name] = btn

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(tabBtns) do
            b.BackgroundColor3 = C.pillBg
            b.TextColor3 = C.textDim
        end
        page.Visible = true
        btn.BackgroundColor3 = C.pillSel
        btn.TextColor3 = C.text
        activeTab = name
    end)

    return page
end

local function showTab(name)
    if Pages[name] then
        for _, p in pairs(Pages) do p.Visible = false end
        for n, b in pairs(tabBtns) do
            b.BackgroundColor3 = C.pillBg
            b.TextColor3 = C.textDim
        end
        Pages[name].Visible = true
        tabBtns[name].BackgroundColor3 = C.pillSel
        tabBtns[name].TextColor3 = C.text
        activeTab = name
    end
end

-- ════════════════════════════════════════════════════════════════
--  TAB PAGES
-- ════════════════════════════════════════════════════════════════

local tabMovement = createTab("Movement")
local tabESP = createTab("ESP")
local tabVisual = createTab("Visual")
local tabTroll = createTab("Troll")
local tabActions = createTab("Actions")
local tabCombat = createTab("Combat")
local tabBalls = createTab("Balls")
local tabChaos = createTab("Chaos")
local tabWorld = createTab("World")
local tabChat = createTab("Chat")
local tabServer = createTab("Server")
local tabConfig = createTab("Config")

-- ════════════════════════════════════════════════════════════════
--  SHARED STATE (for modules to access)
-- ════════════════════════════════════════════════════════════════

local State = {
    Connections = {},
    FlyBody = nil,
    FlyEnabled = false,
    FlySpeed = 100,
    NoclipEnabled = false,
    ESPEnabled = false,
    FullbrightEnabled = false,
    GodModeEnabled = false,
    InfiniteJumpEnabled = false,
    ClickTPEnabled = false,
    SpinEnabled = false,
    SpinSpeed = 10,
    AntiAFKConn = nil,
    AntiVoidConn = nil,
    TargetPlayer = nil,
    ToggleKey = Enum.KeyCode.RightShift,
}

-- ════════════════════════════════════════════════════════════════
--  MODULE TABLE (passed to modules)
-- ════════════════════════════════════════════════════════════════

local PXMenu = {
    Players = Players,
    UIS = UserInputService,
    Run = RunService,
    Tween = TweenService,
    CoreGui = CoreGui,
    Debris = Debris,
    Lighting = Lighting,
    Teleport = TeleportService,
    StarterGui = game:GetService("StarterGui"),
    Http = game:GetService("HttpService"),
    LocalPlayer = LocalPlayer,
    Mouse = Mouse,
    Camera = Camera,
    State = State,
    Colors = C,
    Pages = Pages,
    GUI = GUI,
    Main = Main,
    -- UI Helpers
    Label = Label,
    Sep = Sep,
    Card = Card,
    Toggle = Toggle,
    Slider = Slider,
    Btn = Btn,
    PlayerList = PlayerList,
    Corner = Corner,
    Stroke = Stroke,
    -- Helper functions
    Notify = function(title, text, dur)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title or "PX-Menu",
                Text = text or "",
                Duration = dur or 3
            })
        end)
    end,
    SafeExec = function(fn)
        local s, e = pcall(fn)
        if not s then warn("[PX-Menu] Error: " .. tostring(e)) end
        return s
    end,
    GetChar = function()
        return PXMenu.Character, PXMenu.HRP, PXMenu.Humanoid
    end,
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(),
    HRP = nil,
    Humanoid = nil,
}

PXMenu.HRP = PXMenu.Character:WaitForChild("HumanoidRootPart")
PXMenu.Humanoid = PXMenu.Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(char)
    PXMenu.Character = char
    PXMenu.HRP = char:WaitForChild("HumanoidRootPart")
    PXMenu.Humanoid = char:WaitForChild("Humanoid")
end)

-- ════════════════════════════════════════════════════════════════
--  LOAD MODULES
-- ════════════════════════════════════════════════════════════════

local BASE_URL = "https://raw.githubusercontent.com/obl1vroot-lab/PX-Menu/main/"

local Modules = {
    {name = "Movement", file = "Module-Movement.lua", page = tabMovement},
    {name = "ESP", file = "Module-ESP.lua", page = tabESP},
    {name = "Visual", file = "Module-Visual.lua", page = tabVisual},
    {name = "Troll", file = "Module-Troll.lua", page = tabTroll},
    {name = "Actions", file = "Module-Actions.lua", page = tabActions},
    {name = "Combat", file = "Module-Combat.lua", page = tabCombat},
    {name = "Balls", file = "Module-Balls.lua", page = tabBalls},
    {name = "Chaos", file = "Module-Chaos.lua", page = tabChaos},
    {name = "World", file = "Module-World.lua", page = tabWorld},
    {name = "Chat", file = "Module-Chat.lua", page = tabChat},
    {name = "Server", file = "Module-Server.lua", page = tabServer},
}

task.spawn(function()
    UpdateLoading(0.1, "Initialisiere Core...")
    task.wait(0.2)
    
    for i, mod in ipairs(Modules) do
        local progress = 0.1 + (i / #Modules) * 0.85
        UpdateLoading(progress, "Lade " .. mod.name .. "...")
        
        local success, result = pcall(function()
            local code = game:HttpGet(BASE_URL .. mod.file, true)
            local func = loadstring(code)
            if func then
                func(PXMenu, mod.page)
            end
        end)
        
        if not success then
            warn("[PX-Menu] Failed to load " .. mod.name .. ": " .. tostring(result))
        end
        
        task.wait(0.1)
    end
    
    UpdateLoading(1.0, "Fertig!")
    task.wait(0.3)
    LoadingGui:Destroy()
    
    -- Show menu
    Main.Visible = true
    showTab("Movement")
    
    -- ════════════════════════════════════════════════════════════════
    --  KEYBIND SYSTEM
    -- ════════════════════════════════════════════════════════════════
    
    local keybindDefs = {}
    local keybindObjs = {}
    
    local function SetupKeybinds()
        -- Config tab keybinds and settings
        Label(tabConfig, "PX-Menu Einstellungen", C.accent)
        
        -- Toggle Key
        local kbToggle = Instance.new("Frame", tabConfig)
        kbToggle.Size = UDim2.new(1, 0, 0, 36)
        kbToggle.BackgroundColor3 = C.card
        kbToggle.BorderSizePixel = 0
        Corner(kbToggle, 6)
        Stroke(kbToggle, C.accentDark, 1)
        
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
        kbBtn.Text = "RightShift"
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
        
        Sep(tabConfig)
        Label(tabConfig, "Keybinds", C.accent)
        
        local binds = {
            {name = "Fly Toggle", key = "F", id = "fly"},
            {name = "Noclip Toggle", key = "N", id = "noclip"},
            {name = "ESP Toggle", key = "E", id = "esp"},
            {name = "Spin Toggle", key = "Q", id = "spin"},
            {name = "God Mode", key = "G", id = "god"},
            {name = "Click TP", key = "T", id = "clicktp"},
        }
        
        for _, b in ipairs(binds) do
            local f = Instance.new("Frame", tabConfig)
            f.Size = UDim2.new(1, 0, 0, 36)
            f.BackgroundColor3 = C.card
            f.BorderSizePixel = 0
            Corner(f, 6)
            Stroke(f, C.accentDark, 1)
            local lbl = Instance.new("TextLabel", f)
            lbl.Size = UDim2.new(0.55, 0, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = b.name
            lbl.TextColor3 = C.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            local kbtn = Instance.new("TextButton", f)
            kbtn.Size = UDim2.new(0, 100, 0, 22)
            kbtn.Position = UDim2.new(1, -110, 0.5, -11)
            kbtn.BackgroundColor3 = C.pillBg
            kbtn.Text = b.key or "None"
            kbtn.TextColor3 = C.accent
            kbtn.Font = Enum.Font.GothamBold
            kbtn.TextSize = 10
            kbtn.BorderSizePixel = 0
            kbtn.AutoButtonColor = false
            Corner(kbtn, 4)
            local waiting = false
            local currentBind = b.key
            kbtn.MouseButton1Click:Connect(function()
                if waiting then return end
                waiting = true
                kbtn.Text = "..."
                kbtn.BackgroundColor3 = C.accent
            end)
            local kbObj = {
                id = b.id,
                getBind = function() return currentBind end,
                setBind = function(v) currentBind = v; kbtn.Text = v or "None" end,
                isWaiting = function() return waiting end,
                accept = function(keyCode)
                    if waiting then
                        waiting = false
                        currentBind = keyCode and keyCode.Name or nil
                        kbtn.Text = currentBind or "None"
                        kbtn.BackgroundColor3 = C.pillBg
                        keybindDefs[b.id] = currentBind
                    end
                end
            }
            table.insert(keybindObjs, kbObj)
            keybindDefs[b.id] = currentBind
        end
        
        Sep(tabConfig)
        
        -- Reset Settings
        Btn(tabConfig, "Settings zuruecksetzen", function()
            State.ToggleKey = Enum.KeyCode.RightShift
            for _, kb in ipairs(keybindObjs) do
                kb.setBind(nil)
            end
        end)
        
        -- Destroy Menu
        Btn(tabConfig, "Menu schliessen", function()
            -- Cleanup all connections
            for _, c in pairs(State.Connections) do
                if typeof(c) == "RBXScriptConnection" then pcall(function() c:Disconnect() end) end
            end
            if State.FlyBody then pcall(function() State.FlyBody:Destroy() end) end
            GUI:Destroy()
        end)
        
        -- Keybind handler
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            
            -- Check if any keybind button is waiting
            for _, kb in ipairs(keybindObjs) do
                if kb.isWaiting() then
                    kb.accept(input.KeyCode)
                    return
                end
            end
            
            if waitingToggle then
                waitingToggle = false
                State.ToggleKey = input.KeyCode
                kbBtn.Text = input.KeyCode.Name
                kbBtn.BackgroundColor3 = C.pillBg
                return
            end
            
            -- Toggle menu
            if input.KeyCode == State.ToggleKey then
                Main.Visible = not Main.Visible
                Indicator.Visible = Main.Visible
                return
            end
        end)
        
        -- Minimize
        MinBtn.MouseButton1Click:Connect(function()
            Main.Visible = false
        end)
    end
    
    SetupKeybinds()
    
    print("[PX-Menu] v3.0 loaded! Executor: " .. ExecutorName .. " | RightShift to toggle menu.")
end)
