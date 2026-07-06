--[[
    Module-Troll.lua
    PX-Menu Troll Module
    Features: HeadSeat, Fire, Smoke, Sparks, Anchor, TP, Sound, Gravity
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Ziel auswaehlen", C.accent)
    
    local targetPlayer = nil
    local plList = PX.PlayerList(page, function(p) targetPlayer = p end)
    
    PX.Btn(page, "Spieler Liste aktualisieren", function()
        plList.refresh()
    end)
    
    PX.Sep(page)
    PX.Label(page, "HeadSeat - Spieler zum Sitzen zwingen", C.accent)
    
    PX.Btn(page, "HeadSeat Ziel", function()
        if targetPlayer and targetPlayer.Character then
            local head = targetPlayer.Character:FindFirstChild("Head")
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if head and hrp and hum then
                local seat = Instance.new("Seat")
                seat.Size = Vector3.new(2, 1, 2)
                seat.Transparency = 1
                seat.CanCollide = false
                seat.Anchored = false
                seat.CFrame = hrp.CFrame * CFrame.new(0, -2, 0)
                seat.Parent = workspace
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = seat
                weld.Part1 = head
                weld.Parent = seat
                hum.SeatPart = seat
                PX.Debris:AddItem(seat, 12)
            end
        end
    end)
    
    PX.Btn(page, "Alle HeadSeat", function()
        for _, p in ipairs(PX.Players:GetPlayers()) do
            if p ~= PX.LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if head and hrp and hum then
                    local seat = Instance.new("Seat")
                    seat.Size = Vector3.new(2, 1, 2)
                    seat.Transparency = 1
                    seat.CanCollide = false
                    seat.Anchored = false
                    seat.CFrame = hrp.CFrame * CFrame.new(0, -2, 0)
                    seat.Parent = workspace
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = seat
                    weld.Part1 = head
                    weld.Parent = seat
                    hum.SeatPart = seat
                    PX.Debris:AddItem(seat, 10)
                end
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Spieler Aktionen", C.accent)
    
    PX.Btn(page, "Hochwerfen", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Velocity = Vector3.new(0, 200, 0)
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                PX.Debris:AddItem(bv, 0.5)
            end
        end
    end)
    
    PX.Btn(page, "Fliegen lassen", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Velocity = Vector3.new(0, 150, 0)
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                PX.Debris:AddItem(bv, 2)
                local bg = Instance.new("BodyAngularVelocity", hrp)
                bg.AngularVelocity = Vector3.new(0, 50, 0)
                bg.MaxTorque = Vector3.new(0, math.huge, 0)
                PX.Debris:AddItem(bg, 2)
            end
        end
    end)
    
    PX.Btn(page, "Wegrutschen", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = Instance.new("BodyVelocity", hrp)
                local angle = math.random() * math.pi * 2
                bv.Velocity = Vector3.new(math.cos(angle) * 150, 20, math.sin(angle) * 150)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                PX.Debris:AddItem(bv, 1)
            end
        end
    end)
    
    PX.Btn(page, "Festnageln", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Anchored = true
                task.delay(3, function()
                    if hrp and hrp.Parent then hrp.Anchored = false end
                end)
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Alle Spieler", C.accent)
    
    PX.Btn(page, "Alle Hochwerfen", function()
        for _, p in ipairs(PX.Players:GetPlayers()) do
            if p ~= PX.LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = Instance.new("BodyVelocity", hrp)
                    bv.Velocity = Vector3.new(0, 200, 0)
                    bv.MaxForce = Vector3.new(0, math.huge, 0)
                    PX.Debris:AddItem(bv, 0.5)
                end
            end
        end
    end)
    
    PX.Btn(page, "Alle Rotieren", function()
        for _, p in ipairs(PX.Players:GetPlayers()) do
            if p ~= PX.LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bg = Instance.new("BodyAngularVelocity", hrp)
                    bg.AngularVelocity = Vector3.new(0, 100, 0)
                    bg.MaxTorque = Vector3.new(0, math.huge, 0)
                    PX.Debris:AddItem(bg, 3)
                end
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Gadgets", C.accent)
    
    PX.Btn(page, "Feuer auf Spieler", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local fire = Instance.new("Fire", hrp)
                fire.Size = 10
                fire.Heat = 10
                PX.Debris:AddItem(fire, 5)
            end
        end
    end)
    
    PX.Btn(page, "Rauch auf Spieler", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local smoke = Instance.new("Smoke", hrp)
                smoke.Size = 5
                smoke.Opacity = 1
                PX.Debris:AddItem(smoke, 5)
            end
        end
    end)
    
    PX.Btn(page, "Sparks auf Spieler", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sparks = Instance.new("Sparkles", hrp)
                PX.Debris:AddItem(sparks, 5)
            end
        end
    end)
    
    PX.Btn(page, "Schwerkraft Spieler", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bf = Instance.new("BodyForce", hrp)
                bf.Force = Vector3.new(0, 5000, 0)
                PX.Debris:AddItem(bf, 2)
            end
        end
    end)
    
    PX.Btn(page, "Platt druecken", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bf = Instance.new("BodyForce", hrp)
                bf.Force = Vector3.new(0, -10000, 0)
                PX.Debris:AddItem(bf, 1)
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Sound", C.accent)
    
    PX.Btn(page, "Lauter Sound", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                PX.SafeExec(function()
                    local s = Instance.new("Sound", hrp)
                    s.SoundId = "rbxassetid://138087576"
                    s.Volume = 10
                    s:Play()
                    PX.Debris:AddItem(s, 3)
                end)
            end
        end
    end)
    
    PX.Btn(page, "Siren Sound", function()
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                PX.SafeExec(function()
                    local s = Instance.new("Sound", hrp)
                    s.SoundId = "rbxassetid://1843463117"
                    s.Volume = 10
                    s.Looped = true
                    s:Play()
                    PX.Debris:AddItem(s, 5)
                end)
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Alle Ziel", C.accent)
    
    PX.Btn(page, "Lauter Noise Alle", function()
        for _, player in pairs(PX.Players:GetPlayers()) do
            if player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for i = 1, 5 do
                        local s = Instance.new("Sound")
                        s.SoundId = "rbxassetid://5767826764"
                        s.Volume = 10
                        s.Parent = hrp
                        s:Play()
                        PX.Debris:AddItem(s, 2)
                    end
                end
            end
        end
    end)
    
    PX.Btn(page, "Regen Schrott auf Alle", function()
        for _, player in pairs(PX.Players:GetPlayers()) do
            if player ~= PX.LocalPlayer then
                PX.SafeExec(function()
                    local pHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    for i = 1, 10 do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(math.random(1, 4), math.random(1, 4), math.random(1, 4))
                        part.Position = pHRP.Position + Vector3.new(math.random(-15, 15), 40 + math.random(0, 30), math.random(-15, 15))
                        part.Anchored = false
                        part.CanCollide = true
                        part.BrickColor = BrickColor.new("Bright red")
                        part.Material = Enum.Material.Neon
                        part.Parent = workspace
                        local fire = Instance.new("Fire")
                        fire.Size = 3
                        fire.Parent = part
                        PX.Debris:AddItem(part, 8)
                    end
                end)
            end
        end
    end)
end
