--[[
    Module-Character.lua
    PX-Menu Character Module
    Features: Sonic/Ninja/Giant/Zombie modes, Big Head, Speedy Sonic
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Charakter Mods", C.accent)
    
    local currentTrollChar = nil
    local trollCharAnim = nil
    
    local function resetChar()
        if trollCharAnim then trollCharAnim:Stop() trollCharAnim = nil end
        currentTrollChar = nil
    end
    
    PX.Btn(page, "Sonic Modus", function()
        resetChar()
        PX.SafeExec(function()
            local hum = PX.Humanoid
            for _, part in pairs(PX.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "Head" then
                        part.BrickColor = BrickColor.new("Cyan")
                    else
                        part.BrickColor = BrickColor.new("Bright blue")
                    end
                end
            end
            hum.WalkSpeed = 80
            hum.JumpPower = 100
            local runAnim = Instance.new("Animation")
            runAnim.AnimationId = "rbxassetid://180436148"
            trollCharAnim = hum:LoadAnimation(runAnim)
            trollCharAnim:Play()
            trollCharAnim:AdjustSpeed(2)
            currentTrollChar = "Sonic"
            PX.Notify("PX-Menu", "Sonic Modus! Schnell wie der Blitz!")
        end)
    end)
    
    PX.Btn(page, "Ninja Modus", function()
        resetChar()
        PX.SafeExec(function()
            local hum = PX.Humanoid
            for _, part in pairs(PX.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "Head" then
                        part.BrickColor = BrickColor.new("Really black")
                    else
                        part.BrickColor = BrickColor.new("Dark green")
                    end
                end
            end
            hum.WalkSpeed = 60
            hum.JumpPower = 120
            local ninjaAnim = Instance.new("Animation")
            ninjaAnim.AnimationId = "rbxassetid://180436334"
            trollCharAnim = hum:LoadAnimation(ninjaAnim)
            trollCharAnim:Play()
            trollCharAnim:AdjustSpeed(1.8)
            currentTrollChar = "Ninja"
            PX.Notify("PX-Menu", "Ninja Modus!")
        end)
    end)
    
    PX.Btn(page, "Gigant Modus", function()
        resetChar()
        PX.SafeExec(function()
            local hum = PX.Humanoid
            for _, part in pairs(PX.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * 4
                    part.BrickColor = BrickColor.new("Bright red")
                    part.Transparency = 0.3
                end
            end
            hum.HipHeight = 6
            hum.WalkSpeed = 40
            PX.Notify("PX-Menu", "GIGANT MODUS!")
        end)
    end)
    
    PX.Btn(page, "Zombie Modus", function()
        resetChar()
        PX.SafeExec(function()
            local hum = PX.Humanoid
            for _, part in pairs(PX.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new("Dark green")
                    part.Material = Enum.Material.Grass
                end
            end
            hum.WalkSpeed = 12
            hum.JumpPower = 30
            local zombieAnim = Instance.new("Animation")
            zombieAnim.AnimationId = "rbxassetid://180436148"
            trollCharAnim = hum:LoadAnimation(zombieAnim)
            trollCharAnim:Play()
            trollCharAnim:AdjustSpeed(0.4)
            currentTrollChar = "Zombie"
            PX.Notify("PX-Menu", "Zombie Modus! BRAAAINS...")
        end)
    end)
    
    PX.Btn(page, "Modus Reset", function()
        resetChar()
        PX.SafeExec(function() PX.Humanoid.Health = 0 end)
    end)
    
    PX.Sep(page)
    PX.Label(page, "Koerper Effekte", C.accent)
    
    -- Big Head
    PX.Toggle(page, "Big Head", function(on)
        PX.SafeExec(function()
            local head = PX.Character:FindFirstChild("Head")
            if head then
                if on then
                    head.Size = Vector3.new(5, 5, 5)
                    head.Transparency = 0.5
                    head.BrickColor = BrickColor.new("Hot pink")
                else
                    head.Size = Vector3.new(2, 1, 1)
                    head.Transparency = 0
                    head.BrickColor = BrickColor.new("Bright yellow")
                end
            end
        end)
    end)
    
    -- Invisible
    PX.Btn(page, "Unsichtbar", function()
        PX.SafeExec(function()
            for _, part in pairs(PX.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
            PX.Humanoid.NameDisplayDistance = 0
            PX.Humanoid.HealthDisplayDistance = 0
            PX.Notify("PX-Menu", "Unsichtbar!")
        end)
    end)
    
    PX.Sep(page)
    PX.Label(page, "Speedy Sonic", C.accent)
    
    PX.Btn(page, "Speedy Sonic (Max Speed + Trail)", function()
        PX.SafeExec(function()
            local hrp = PX.HRP
            PX.Humanoid.WalkSpeed = 200
            PX.Humanoid.JumpPower = 200
            local att0 = Instance.new("Attachment", hrp)
            local att1 = Instance.new("Attachment", hrp)
            att1.Position = Vector3.new(0, 0, 2)
            local trail = Instance.new("Trail")
            trail.Attachment0 = att0
            trail.Attachment1 = att1
            trail.Color = ColorSequence.new(Color3.fromRGB(100, 50, 170), Color3.fromRGB(130, 70, 200))
            trail.Transparency = NumberSequence.new(0.3)
            trail.Lifetime = 0.5
            trail.Parent = hrp
            PX.Notify("PX-Menu", "SPEEDY SONIC!")
        end)
    end)
end
