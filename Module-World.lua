--[[
    Module-World.lua
    PX-Menu World Module
    Features: Time of Day, Brightness, Fog, Anti Void
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Welt Einstellungen", C.accent)
    
    PX.Slider(page, "Tageszeit", 0, 24, 14, function(val)
        PX.Lighting.ClockTime = val
    end)
    
    PX.Slider(page, "Helligkeit", 0, 10, 1, function(val)
        PX.Lighting.Brightness = val
    end)
    
    PX.Sep(page)
    PX.Label(page, "Nacht / Tag", C.accent)
    
    PX.Btn(page, "Nacht Modus", function()
        PX.Lighting.ClockTime = 0
    end)
    
    PX.Btn(page, "Tag Modus", function()
        PX.Lighting.ClockTime = 14
    end)
    
    PX.Btn(page, "Dunkelheit", function()
        PX.Lighting.Brightness = 0
        PX.Lighting.ClockTime = 0
    end)
    
    PX.Btn(page, "Helligkeit Max", function()
        PX.Lighting.Brightness = 10
        PX.Lighting.ClockTime = 14
    end)
    
    PX.Btn(page, "Fog entfernen", function()
        PX.Lighting.FogEnd = 999999
        PX.Lighting.FogStart = 0
    end)
    
    PX.Sep(page)
    PX.Label(page, "Schutz", C.accent)
    
    -- Anti Void
    PX.Toggle(page, "Anti Void", function(on)
        if on then
            State.Connections.AntiVoid = PX.Run.Heartbeat:Connect(function()
                PX.SafeExec(function()
                    local pos = PX.HRP.Position
                    if pos.Y < -100 then
                        PX.HRP.CFrame = CFrame.new(0, 100, 0)
                    end
                end)
            end)
        else
            if State.Connections.AntiVoid then
                State.Connections.AntiVoid:Disconnect()
                State.Connections.AntiVoid = nil
            end
        end
    end)
    
    -- Anti Ragdoll
    PX.Toggle(page, "Anti Ragdoll", function(on)
        if on then
            State.Connections.AntiRagdoll = PX.Run.Heartbeat:Connect(function()
                PX.SafeExec(function()
                    local hum = PX.Humanoid
                    if hum then
                        hum.PlatformStand = false
                        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    end
                end)
            end)
        else
            if State.Connections.AntiRagdoll then
                State.Connections.AntiRagdoll:Disconnect()
                State.Connections.AntiRagdoll = nil
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Zerstoeren", C.accent)
    
    PX.Btn(page, "Boden zerstoeren", function()
        local base = workspace:FindFirstChild("Base") or workspace:FindFirstChild("Baseplate")
        if base then base:Destroy() end
    end)
end
