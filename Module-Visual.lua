--[[
    Module-Visual.lua
    PX-Menu Visual Module
    Features: Fullbright, No Fog, Remove Skybox, Rainbow, X-Ray
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Visuelle Effekte", C.accent)
    
    -- Fullbright
    PX.Toggle(page, "Fullbright", function(on)
        State.FullbrightEnabled = on
        if on then
            PX.Lighting.Brightness = 2
            PX.Lighting.ClockTime = 14
            PX.Lighting.FogEnd = 100000
            PX.Lighting.GlobalShadows = false
            PX.Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            PX.Lighting.Brightness = 1
            PX.Lighting.ClockTime = 12
            PX.Lighting.GlobalShadows = true
            PX.Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end)
    
    -- No Fog
    PX.Toggle(page, "Kein Nebel", function(on)
        if on then
            PX.Lighting.FogEnd = 9999999
        else
            PX.Lighting.FogEnd = 100000
        end
    end)
    
    -- Remove Skybox
    PX.Btn(page, "Skybox entfernen", function()
        for _, obj in pairs(PX.Lighting:GetDescendants()) do
            if obj:IsA("Sky") then obj:Destroy() end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Charakter Effekte", C.accent)
    
    -- Rainbow Character
    PX.Btn(page, "Rainbow Charakter", function()
        task.spawn(function()
            PX.SafeExec(function()
                for i = 0, 1, 0.01 do
                    for _, part in pairs(PX.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.Color = Color3.fromHSV(i, 1, 1) end
                    end
                    task.wait(0.05)
                end
            end)
        end)
    end)
    
    -- X-Ray Vision
    PX.Toggle(page, "X-Ray Vision", function(on)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(PX.Character) then
                PX.SafeExec(function() obj.Transparency = on and 0.8 or 0 end)
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Schatteneffekte", C.accent)
    
    -- Bloom Shader
    local bloomEnabled = false
    PX.Toggle(page, "Bloom Shader", function(on)
        bloomEnabled = on
        if on then
            local bloom = Instance.new("BloomEffect")
            bloom.Name = "PXMenu_Bloom"
            bloom.Intensity = 1
            bloom.Size = 24
            bloom.Threshold = 2
            bloom.Parent = PX.Lighting
        else
            local bloom = PX.Lighting:FindFirstChild("PXMenu_Bloom")
            if bloom then bloom:Destroy() end
        end
    end)
    
    -- Color Correction
    PX.Toggle(page, "Color Correction", function(on)
        if on then
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "PXMenu_CC"
            cc.Brightness = 0.1
            cc.Contrast = 0.1
            cc.Saturation = 0.2
            cc.Parent = PX.Lighting
        else
            local cc = PX.Lighting:FindFirstChild("PXMenu_CC")
            if cc then cc:Destroy() end
        end
    end)
    
    -- Sun Rays
    PX.Toggle(page, "Sun Rays", function(on)
        if on then
            local sr = Instance.new("SunRaysEffect")
            sr.Name = "PXMenu_SunRays"
            sr.Intensity = 0.1
            sr.Spread = 0.5
            sr.Parent = PX.Lighting
        else
            local sr = PX.Lighting:FindFirstChild("PXMenu_SunRays")
            if sr then sr:Destroy() end
        end
    end)
end
