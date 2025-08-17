-- 📥 SilverUI Library'yi yükle
local Silver = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuffslvr/hub/refs/heads/main/silver.lua"))()

-- 🪟 Pencere oluştur
local win = Silver:New({Name = "Silver UI Demo"})

-- 📑 Tab ekle
local tab = win:Tab("Ana Menü")

-- Label
tab:Label("Silver UI başarıyla yüklendi ✅")

-- Button
tab:Button({
    Title = "Selam Ver",
    Callback = function()
        tab:Notify("Silver UI", "Butona tıklandı 🎉", 3)
    end
})

-- Toggle
tab:Toggle({
    Title = "God Mode",
    Default = false,
    Callback = function(state)
        print("God Mode:", state)
    end
})

-- Slider
tab:Slider({
    Title = "Hız Ayarı",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})

-- Textbox
tab:Textbox({
    Placeholder = "Mesaj yaz...",
    Callback = function(text)
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
    end
})

-- Dropdown
tab:Dropdown({
    Title = "Takım Seç",
    Options = {"Red", "Blue", "Green"},
    Default = "Red",
    Callback = function(opt)
        print("Seçilen takım:", opt)
    end
})

-- MultiDropdown
tab:MultiDropdown({
    Title = "Eşyalar",
    Options = {"Kılıç", "Kalkan", "Yay"},
    Default = {"Kılıç"},
    Callback = function(opts)
        print("Seçilen eşyalar:", table.concat(opts, ", "))
    end
})

-- ColorPicker
tab:Colorpicker({
    Title = "Arkaplan Rengi",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(col)
        game.Lighting.Ambient = col
    end
})

-- Keybind
tab:Keybind({
    Title = "Menüyü Aç/Kapat",
    Default = Enum.KeyCode.RightShift,
    Pressed = function()
        print("Keybind çalıştı!")
    end
})

-- Divider
tab:Divider()

-- Notify test
tab:Notify("Silver UI", "Her şey hazır 🚀", 3)
