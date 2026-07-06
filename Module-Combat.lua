--[[
    Module-Combat.lua
    PX-Menu Combat Module
    Features: God Mode, Click Fling, Detach Limbs, Explode
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Combat", C.accent)
    
    -- God Mode
    PX.Toggle(page, "God Mode", function(on)
        State.GodModeEnabled = on
        if on then
            State.Connections.GodMode = PX.Run.Heartbeat:Connect(function()
                PX.SafeExec(function()
                    PX.Humanoid.Health = 999999
                end)
            end)
        else
            if State.Connections.GodMode then
                State.Connections.GodMode:Disconnect()
                State.Connections.GodMode = nil
            end
        end
    end)
    
    -- Click Fling
    PX.Toggle(page, "Click Fling (Strg+Click)", function(on)
        State.ClickFlingEnabled = on
    end)
    
    PX.Mouse.Button1Down:Connect(function()
        if State.ClickFlingEnabled then
            PX.SafeExec(function()
                local hrp = PX.Character:FindFirstChild("HumanoidRootPart")
                local vel = Instance.new("BodyAngularVelocity")
                vel.AngularVelocity = Vector3.new(0, 9999, 0)
                vel.MaxTorque = Vector3.new(0, math.huge, 0)
                vel.P = 1000000
                vel.Parent = hrp
                PX.Debris:AddItem(vel, 0.5)
            end)
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Charakter Aktionen", C.accent)
    
    -- Detach Limbs
    PX.Btn(page, "Gliedmassen losloesen", function()
        PX.SafeExec(function()
            for _, obj in pairs(PX.Character:GetDescendants()) do
                if obj:IsA("Motor6D") then obj:Destroy() end
            end
        end)
    end)
    
    -- Explode Character
    PX.Btn(page:FindFirstChildOfClass("UIListLayout") and page or page, "Charakter explodieren", function()
        PX.SafeExec(function()
            PX.Humanoid.Health = 0
            local explosion = Instance.new("Explosion")
            explosion.Position = PX.HRP.Position
            explosion.BlastPressure = 500000
            explosion.BlastRadius = 20
            explosion.Parent = workspace
        end)
    end)
    
    -- Reset Character
    PX.Btn(page, "Charakter Reset", function()
        PX.SafeExec(function() PX.Humanoid.Health = 0 end)
    end)
    
    PX.Sep(page)
    PX.Label(page, "Effekte entfernen", C.accent)
    
    PX.Btn(page, "Alle Fire/Smoke entfernen", function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj:Destroy()
            end
        end
    end)
    
    PX.Btn(page, "Alle Anchor entfernen", function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(PX.Character) then
                obj.Anchored = false
            end
        end
    end)
end
