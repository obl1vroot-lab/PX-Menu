--[[
    Module-Chat.lua
    PX-Menu Chat Module
    Features: Chat Spam, German Spam, Custom Messages
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Chat Spam", C.accent)
    
    local spamActive = false
    local spamConn = nil
    
    local spamMessages = {
        "PX-MENU", "gg", "LOL", "nice", "haha",
        "PX-Menu Dominanz", "Wo bist du?", "Komm her",
    }
    
    PX.Toggle(page, "Chat Spam", function(on)
        spamActive = on
        if on then
            spamConn = task.spawn(function()
                local idx = 1
                while spamActive do
                    PX.SafeExec(function()
                        local msg = spamMessages[idx % #spamMessages + 1]
                        idx = idx + 1
                        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(msg, "All")
                    end)
                    task.wait(math.random(1, 3))
                end
            end)
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "German Chat Spam", C.accent)
    
    local GermanMessages = {
        "Halt die Fresse du Lauch", "Ich bin der Chef hier", "Du bist so schlecht ey",
        "Schleich dich du Wurst", "Mach mal Fenster auf Kippe", "Komm du Zecke",
        "Alter bist du dumm oder was", "Hau ab du Vollidiot",
        "Ich verkauf dich auf eBay Kleinanzeigen", "Spinnst du oder wat",
        "PX-Menu uebernimmt hier", "Alle anderen sind Bots hier",
        "Weg hier du Penner", "Du hast die Kontrolle ueber dein Leben verloren",
        "Geh mal Baeume pflanzen", "Du bist so irrelevant wie ein Regenschirm im Auto",
        "Du bist so helle wie ein Backofen im Winter",
    }
    
    local germanSpamActive = false
    
    PX.Toggle(page, "German Spam", function(on)
        germanSpamActive = on
        if on then
            task.spawn(function()
                while germanSpamActive do
                    PX.SafeExec(function()
                        local msg = GermanMessages[math.random(1, #GermanMessages)]
                        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(msg, "All")
                    end)
                    task.wait(math.random(2, 5))
                end
            end)
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Toxic Kill Feed", C.accent)
    
    local toxicActive = false
    
    PX.Toggle(page, "Toxic Kill Feed", function(on)
        toxicActive = on
        if on then
            task.spawn(function()
                while toxicActive do
                    PX.SafeExec(function()
                        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(
                            "KILLS | PX-MENU DOMINIERT", "All"
                        )
                    end)
                    task.wait(math.random(3, 6))
                end
            end)
        end
    end)
end
