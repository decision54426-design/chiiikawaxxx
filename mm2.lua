-- MM2 + Lava Tower Cheat (Complete Custom GUI)
-- Ultra-wide layout, collapsible, transparent, minimize
-- Features: NoClip, ESP, Auto Jump, Speed Boost, Anti-Fall, Auto Collect

print("=== MM2 + Lava Tower Cheat Loading... ===")

local Player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- ====== 変数宣言 ======
-- NoClip
local NoclipEnabled = false
local NoclipConnection = nil

-- ESP
local ESPEnabled = false
local ESPObjects = {}
local ESPUpdateConnection = nil
local ESPConnections = {}

-- Lava Tower (溶岩タワー) 機能
local AutoJumpEnabled = false
local AutoJumpConnection = nil
local SpeedBoostEnabled = false
local SpeedBoostConnection = nil
local AntiFallEnabled = false
local AntiFallConnection = nil
local AutoCollectEnabled = false
local AutoCollectConnection = nil

-- 速度設定
local SpeedMultiplier = 1.5
local JumpPowerMultiplier = 1.5

-- ====== ESP設定 ======
local ESPColors = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 120, 255),
    Innocent = Color3.fromRGB(0, 255, 100)
}

local ESPConfig = {
    ShowName = true,
    ShowDistance = true,
    ShowRole = true,
    ShowBox = true
}

-- ====== 役職取得 ======
local function GetPlayerRole(player)
    if not player or player == Player then return "Unknown" end
    local character = player.Character
    if not character then return "Unknown" end
    
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("knife") or name:find("dagger") then return "Murderer" end
            if name:find("gun") or name:find("pistol") then return "Sheriff" end
        end
    end
    return "Innocent"
end

-- ====== ESP作成 ======
local function CreateESPForPlayer(player)
    if player == Player or not player.Character then return end
    
    local character = player.Character
    local primaryPart = character.PrimaryPart or character:FindFirstChild("Head")
    if not primaryPart then return end
    
    if ESPObjects[player] then
        pcall(function() ESPObjects[player].container:Destroy() end)
        ESPObjects[player] = nil
    end
    
    local role = GetPlayerRole(player)
    local color = ESPColors[role] or Color3.fromRGB(255,255,255)
    
    local container = Instance.new("ScreenGui")
    container.Name = "ESP_" .. player.Name
    container.ResetOnSpawn = false
    pcall(function() container.Parent = game.CoreGui end)
    if not container.Parent then
        container.Parent = Player:WaitForChild("PlayerGui")
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 40)
    billboard.Adornee = primaryPart
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.Parent = container
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = color
    text.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    text.TextStrokeTransparency = 0.2
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.TextScaled = true
    text.Parent = billboard
    
    if ESPConfig.ShowBox then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(2.5, 4.5, 1.5)
        box.Adornee = primaryPart
        box.Color3 = color
        box.Transparency = 0.4
        box.ZIndex = 10
        box.AlwaysOnTop = true
        box.Parent = container
    end
    
    local function UpdateText()
        local namePart = ESPConfig.ShowName and (player.DisplayName or player.Name) or ""
        local rolePart = ESPConfig.ShowRole and (" [" .. role .. "]") or ""
        local distPart = ""
        if ESPConfig.ShowDistance then
            local myChar = Player.Character
            if myChar and myChar.PrimaryPart then
                local dist = (myChar.PrimaryPart.Position - primaryPart.Position).Magnitude
                if dist < 1000 then distPart = " [" .. math.floor(dist) .. "m]" end
            end
        end
        text.Text = namePart .. rolePart .. distPart
    end
    UpdateText()
    
    ESPObjects[player] = {container = container, UpdateText = UpdateText}
    
    local conn = player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPEnabled then CreateESPForPlayer(player) end
    end)
    table.insert(ESPConnections, conn)
end

-- ====== ESP更新 ======
local function UpdateAllESP()
    for player, _ in pairs(ESPObjects) do
        if not Players:FindFirstChild(player.Name) then
            pcall(function() ESPObjects[player].container:Destroy() end)
            ESPObjects[player] = nil
        end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            if not ESPObjects[player] then
                CreateESPForPlayer(player)
            else
                pcall(function() ESPObjects[player].UpdateText() end)
            end
        end
    end
end

-- ====== ESP関数 ======
local function EnableESP()
    if ESPEnabled then return end
    ESPEnabled = true
    DisableESP()
    
    local added = Players.PlayerAdded:Connect(function(p)
        task.wait(1)
        if ESPEnabled and p.Character then CreateESPForPlayer(p) end
    end)
    table.insert(ESPConnections, added)
    
    local removed = Players.PlayerRemoving:Connect(function(p)
        if ESPObjects[p] then
            pcall(function() ESPObjects[p].container:Destroy() end)
            ESPObjects[p] = nil
        end
    end)
    table.insert(ESPConnections, removed)
    
    ESPUpdateConnection = RunService.Stepped:Connect(function()
        if ESPEnabled then UpdateAllESP() end
    end)
    
    task.wait(0.5)
    UpdateAllESP()
    print("ESP ON")
end

local function DisableESP()
    ESPEnabled = false
    if ESPUpdateConnection then ESPUpdateConnection:Disconnect() ESPUpdateConnection = nil end
    for _, conn in pairs(ESPConnections) do pcall(function() conn:Disconnect() end) end
    ESPConnections = {}
    for _, obj in pairs(ESPObjects) do pcall(function() obj.container:Destroy() end) end
    ESPObjects = {}
    print("ESP OFF")
end

-- ====== NoClip関数 ======
local function EnableNoClip()
    if NoclipEnabled then return end
    NoclipEnabled = true
    NoclipConnection = RunService.Stepped:Connect(function()
        if not NoclipEnabled then return end
        local char = Player.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end)
    print("NoClip ON")
end

local function DisableNoClip()
    NoclipEnabled = false
    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
    local char = Player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = true end)
            end
        end
    end
    print("NoClip OFF")
end

-- ====== 溶岩タワー機能 ======

-- 1. 自動ジャンプ（連続ジャンプ）
local function EnableAutoJump()
    if AutoJumpEnabled then return end
    AutoJumpEnabled = true
    AutoJumpConnection = RunService.Heartbeat:Connect(function()
        if not AutoJumpEnabled then return end
        local char = Player.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    print("Auto Jump ON")
end

local function DisableAutoJump()
    AutoJumpEnabled = false
    if AutoJumpConnection then
        AutoJumpConnection:Disconnect()
        AutoJumpConnection = nil
    end
    print("Auto Jump OFF")
end

-- 2. 速度ブースト
local function EnableSpeedBoost()
    if SpeedBoostEnabled then return end
    SpeedBoostEnabled = true
    SpeedBoostConnection = RunService.Heartbeat:Connect(function()
        if not SpeedBoostEnabled then return end
        local char = Player.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 * SpeedMultiplier
            humanoid.JumpPower = 50 * JumpPowerMultiplier
        end
    end)
    print("Speed Boost ON (x" .. SpeedMultiplier .. ")")
end

local function DisableSpeedBoost()
    SpeedBoostEnabled = false
    if SpeedBoostConnection then
        SpeedBoostConnection:Disconnect()
        SpeedBoostConnection = nil
    end
    local char = Player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
    print("Speed Boost OFF")
end

-- 3. 落下防止（地面に着地したらジャンプ）
local function EnableAntiFall()
    if AntiFallEnabled then return end
    AntiFallEnabled = true
    AntiFallConnection = RunService.Heartbeat:Connect(function()
        if not AntiFallEnabled then return end
        local char = Player.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- 地面からの距離をチェック
                local ray = Ray.new(rootPart.Position, Vector3.new(0, -10, 0))
                local hit = Workspace:FindPartOnRay(ray, char)
                if not hit then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
    print("Anti-Fall ON")
end

local function DisableAntiFall()
    AntiFallEnabled = false
    if AntiFallConnection then
        AntiFallConnection:Disconnect()
        AntiFallConnection = nil
    end
    print("Anti-Fall OFF")
end

-- 4. 自動収集（アイテムを自動で拾う）
local function EnableAutoCollect()
    if AutoCollectEnabled then return end
    AutoCollectEnabled = true
    AutoCollectConnection = RunService.Heartbeat:Connect(function()
        if not AutoCollectEnabled then return end
        local char = Player.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- 近くのアイテムを検索（溶岩タワーのコインやアイテム）
        for _, item in pairs(Workspace:GetDescendants()) do
            if item:IsA("Part") or item:IsA("MeshPart") then
                local name = item.Name:lower()
                if name:find("coin") or name:find("gem") or name:find("crystal") or name:find("orb") then
                    local distance = (rootPart.Position - item.Position).Magnitude
                    if distance < 15 then
                        -- アイテムに近づく（実際のゲームに合わせて調整）
                        rootPart.CFrame = CFrame.new(item.Position)
                    end
                end
            end
        end
    end)
    print("Auto Collect ON")
end

local function DisableAutoCollect()
    AutoCollectEnabled = false
    if AutoCollectConnection then
        AutoCollectConnection:Disconnect()
        AutoCollectConnection = nil
    end
    print("Auto Collect OFF")
end

-- ============================================
-- ====== 超横長カスタムGUI ======
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_CustomGUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- ====== メインフレーム（超横長・縦長・半透明） ======
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 650, 0, 550)  -- 超横長！以前より170px広い
Frame.Position = UDim2.new(0.5, -325, 0.5, -275)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Frame.BackgroundTransparency = 0.25
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = Frame

-- ====== タイトルバー ======
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

-- タイトル
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.03, 0, 0, 0)
Title.Text = "🔥 MM2 + Lava Tower Cheat"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- ====== 縮小ボタン ======
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -105, 0, 6)
MinBtn.Text = "─"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- ====== 折りたたみボタン ======
local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Size = UDim2.new(0, 32, 0, 32)
CollapseBtn.Position = UDim2.new(1, -68, 0, 6)
CollapseBtn.Text = "▲"
CollapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CollapseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 16
CollapseBtn.Parent = TitleBar

local CollapseCorner = Instance.new("UICorner")
CollapseCorner.CornerRadius = UDim.new(0, 6)
CollapseCorner.Parent = CollapseBtn

-- ====== 閉じるボタン ======
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -36, 0, 6)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ====== コンテンツ用フレーム ======
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -45)
ContentFrame.Position = UDim2.new(0, 0, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = Frame

-- ====== スクローリング用 ======
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -10)
ScrollFrame.Position = UDim2.new(0, 10, 0, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
ScrollFrame.Parent = ContentFrame

-- ====== 2カラムレイアウト ======
local Column1 = Instance.new("Frame")
Column1.Size = UDim2.new(0.48, 0, 1, 0)
Column1.Position = UDim2.new(0, 0, 0, 0)
Column1.BackgroundTransparency = 1
Column1.Parent = ScrollFrame

local Column2 = Instance.new("Frame")
Column2.Size = UDim2.new(0.48, 0, 1, 0)
Column2.Position = UDim2.new(0.52, 0, 0, 0)
Column2.BackgroundTransparency = 1
Column2.Parent = ScrollFrame

-- ====== トグル作成関数 ======
local function CreateToggle(parent, yPos, label, defaultValue, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 0, 35)
    Label.Position = UDim2.new(0.03, 0, 0, yPos)
    Label.Text = label
    Label.TextColor3 = Color3.fromRGB(220, 220, 240)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.28, 0, 0, 32)
    Btn.Position = UDim2.new(0.70, 0, 0, yPos + 1)
    Btn.Text = defaultValue and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = parent
    
    local BgColor = defaultValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 40, 40)
    Btn.BackgroundColor3 = BgColor
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn
    
    local state = defaultValue
    
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = state and "ON" or "OFF"
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 40, 40)
        callback(state)
    end)
    
    return {Btn = Btn, getState = function() return state end}
end

-- ====== セクションタイトル ======
local function CreateSection(parent, yPos, title, icon)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 32)
    Label.Position = UDim2.new(0.02, 0, 0, yPos)
    Label.Text = icon and icon .. " " .. title or "── " .. title .. " ──"
    Label.TextColor3 = Color3.fromRGB(150, 150, 220)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

-- ====== ボタン作成関数 ======
local function CreateButton(parent, yPos, label, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.94, 0, 0, 40)
    Btn.Position = UDim2.new(0.03, 0, 0, yPos)
    Btn.Text = label
    Btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 80)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 15
    Btn.Parent = parent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- ====== ラベル作成関数 ======
local function CreateLabel(parent, yPos, text, color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.94, 0, 0, 25)
    Label.Position = UDim2.new(0.03, 0, 0, yPos)
    Label.Text = text
    Label.TextColor3 = color or Color3.fromRGB(180, 180, 200)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

-- ============================================
-- ====== カラム1: MM2機能 ======
-- ============================================
local y1 = 10

CreateSection(Column1, y1, "MM2 Features", "🔪")
y1 = y1 + 38

local noClipToggle = CreateToggle(Column1, y1, "NoClip", false, function(state)
    if state then EnableNoClip() else DisableNoClip() end
end)
y1 = y1 + 45

local espToggle = CreateToggle(Column1, y1, "ESP", false, function(state)
    if state then EnableESP() else DisableESP() end
end)
y1 = y1 + 50

CreateSection(Column1, y1, "ESP Settings", "👁")
y1 = y1 + 38

local nameToggle = CreateToggle(Column1, y1, "Show Name", true, function(state)
    ESPConfig.ShowName = state
    for _, obj in pairs(ESPObjects) do pcall(obj.UpdateText) end
end)
y1 = y1 + 45

local distToggle = CreateToggle(Column1, y1, "Show Distance", true, function(state)
    ESPConfig.ShowDistance = state
    for _, obj in pairs(ESPObjects) do pcall(obj.UpdateText) end
end)
y1 = y1 + 45

local roleToggle = CreateToggle(Column1, y1, "Show Role", true, function(state)
    ESPConfig.ShowRole = state
    for _, obj in pairs(ESPObjects) do pcall(obj.UpdateText) end
end)
y1 = y1 + 45

local boxToggle = CreateToggle(Column1, y1, "Show Box", true, function(state)
    ESPConfig.ShowBox = state
    if ESPEnabled then
        DisableESP()
        task.wait(0.5)
        EnableESP()
    end
end)
y1 = y1 + 50

-- Color Legend
CreateSection(Column1, y1, "Color Legend", "🎨")
y1 = y1 + 35

CreateLabel(Column1, y1, "🔴 Murderer", Color3.fromRGB(255, 80, 80))
y1 = y1 + 28

CreateLabel(Column1, y1, "🔵 Sheriff", Color3.fromRGB(80, 150, 255))
y1 = y1 + 28

CreateLabel(Column1, y1, "🟢 Innocent", Color3.fromRGB(80, 255, 120))
y1 = y1 + 40

-- ============================================
-- ====== カラム2: 溶岩タワー機能 ======
-- ============================================
local y2 = 10

CreateSection(Column2, y2, "Lava Tower", "🌋")
y2 = y2 + 38

local autoJumpToggle = CreateToggle(Column2, y2, "Auto Jump", false, function(state)
    if state then EnableAutoJump() else DisableAutoJump() end
end)
y2 = y2 + 45

local speedToggle = CreateToggle(Column2, y2, "Speed Boost", false, function(state)
    if state then EnableSpeedBoost() else DisableSpeedBoost() end
end)
y2 = y2 + 45

local antiFallToggle = CreateToggle(Column2, y2, "Anti-Fall", false, function(state)
    if state then EnableAntiFall() else DisableAntiFall() end
end)
y2 = y2 + 45

local autoCollectToggle = CreateToggle(Column2, y2, "Auto Collect", false, function(state)
    if state then EnableAutoCollect() else DisableAutoCollect() end
end)
y2 = y2 + 55

-- 速度設定
CreateSection(Column2, y2, "Speed Settings", "⚡")
y2 = y2 + 35

CreateLabel(Column2, y2, "Speed: x" .. string.format("%.1f", SpeedMultiplier), Color3.fromRGB(200, 200, 255))
y2 = y2 + 28

-- 簡易スライダー（速度調整）
local SpeedSlider = Instance.new("Frame")
SpeedSlider.Size = UDim2.new(0.8, 0, 0, 6)
SpeedSlider.Position = UDim2.new(0.1, 0, 0, y2)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SpeedSlider.BackgroundTransparency = 0.5
SpeedSlider.Parent = Column2

local SpeedBar = Instance.new("Frame")
SpeedBar.Size = UDim2.new(SpeedMultiplier / 3, 0, 1, 0)
SpeedBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
SpeedBar.BorderSizePixel = 0
SpeedBar.Parent = SpeedSlider

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 3)
SpeedCorner.Parent = SpeedBar

local SpeedSliderCorner = Instance.new("UICorner")
SpeedSliderCorner.CornerRadius = UDim.new(0, 3)
SpeedSliderCorner.Parent = SpeedSlider

-- 速度調整ボタン（簡易）
local function UpdateSpeedUI()
    SpeedBar.Size = UDim2.new(SpeedMultiplier / 3, 0, 1, 0)
end

CreateButton(Column2, y2 + 20, "Speed +0.5", Color3.fromRGB(0, 100, 200), function()
    if SpeedMultiplier < 3 then
        SpeedMultiplier = SpeedMultiplier + 0.5
        UpdateSpeedUI()
        if SpeedBoostEnabled then
            DisableSpeedBoost()
            EnableSpeedBoost()
        end
        print("Speed: x" .. string.format("%.1f", SpeedMultiplier))
    end
end)

y2 = y2 + 70

CreateButton(Column2, y2, "Speed -0.5", Color3.fromRGB(200, 100, 0), function()
    if SpeedMultiplier > 0.5 then
        SpeedMultiplier = SpeedMultiplier - 0.5
        UpdateSpeedUI()
        if SpeedBoostEnabled then
            DisableSpeedBoost()
            EnableSpeedBoost()
        end
        print("Speed: x" .. string.format("%.1f", SpeedMultiplier))
    end
end)

y2 = y2 + 50

-- Jump Power設定
CreateLabel(Column2, y2, "Jump Power: x" .. string.format("%.1f", JumpPowerMultiplier), Color3.fromRGB(200, 255, 200))
y2 = y2 + 28

CreateButton(Column2, y2, "Jump +0.5", Color3.fromRGB(0, 150, 100), function()
    if JumpPowerMultiplier < 4 then
        JumpPowerMultiplier = JumpPowerMultiplier + 0.5
        if SpeedBoostEnabled then
            DisableSpeedBoost()
            EnableSpeedBoost()
        end
        print("Jump Power: x" .. string.format("%.1f", JumpPowerMultiplier))
    end
end)

y2 = y2 + 50

CreateButton(Column2, y2, "Jump -0.5", Color3.fromRGB(150, 100, 0), function()
    if JumpPowerMultiplier > 0.5 then
        JumpPowerMultiplier = JumpPowerMultiplier - 0.5
        if SpeedBoostEnabled then
            DisableSpeedBoost()
            EnableSpeedBoost()
        end
        print("Jump Power: x" .. string.format("%.1f", JumpPowerMultiplier))
    end
end)

y2 = y2 + 55

-- ============================================
-- ====== 緊急停止ボタン（両カラムにまたがる） ======
-- ============================================
local function CreateFullWidthButton(parent, yPos, label, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.97, 0, 0, 45)
    Btn.Position = UDim2.new(0.015, 0, 0, yPos)
    Btn.Text = label
    Btn.BackgroundColor3 = color or Color3.fromRGB(180, 30, 30)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 18
    Btn.Parent = parent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- 両カラムの高さを合わせる
local maxY = math.max(y1, y2) + 60

-- 緊急停止ボタン（全体に配置）
CreateFullWidthButton(ScrollFrame, maxY, "⚠ EMERGENCY STOP (ALL)", Color3.fromRGB(180, 20, 20), function()
    -- MM2機能停止
    DisableNoClip()
    DisableESP()
    noClipToggle.Btn.Text = "OFF"
    noClipToggle.Btn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
    espToggle.Btn.Text = "OFF"
    espToggle.Btn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
    
    -- 溶岩タワー機能停止
    DisableAutoJump()
    DisableSpeedBoost()
    DisableAntiFall()
    DisableAutoCollect()
    autoJumpToggle.Btn.Text = "OFF"
    autoJumpToggle.Btn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
    speedToggle.Btn.Text = "OFF"
    speedToggle.Btn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
    antiFallToggle.Btn.Text = "OFF"
    antiFallToggle.Btn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
    autoCollectToggle.Btn.Text = "OFF"
    autoCollectToggle.Btn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
    
    print("⚠ EMERGENCY STOP: All functions stopped")
end)

-- ====== CanvasSizeを更新 ======
local function UpdateCanvasSize()
    local children = ScrollFrame:GetChildren()
    local maxY = 0
    for _, child in pairs(children) do
        if child:IsA("GuiObject") then
            local y = child.Position.Y.Offset + child.Size.Y.Offset
            if y > maxY then maxY = y end
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, maxY + 30)
end
task.wait(0.1)
UpdateCanvasSize()

-- ====== ウィンドウ状態 ======
local isMinimized = false
local isCollapsed = false
local normalSize = Frame.Size
local collapsedSize = UDim2.new(normalSize.X.Scale, normalSize.X.Offset, 0, 45)

-- ====== 縮小機能 ======
MinBtn.MouseButton
