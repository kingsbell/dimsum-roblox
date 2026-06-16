-- File ini sangat sempurna jika Anda ingin menggabungkannya dengan UI Library (Orion, Rayfield, dll.)

-- Variabel ini yang akan dikendalikan (diubah) oleh tombol Toggle di UI Anda nanti
if _G.AutoCollectAktif == nil then
    _G.AutoCollectAktif = false
end
if _G.AutoBuyAktif == nil then
    _G.AutoBuyAktif = false
end
if _G.TargetRarity == nil then
    _G.TargetRarity = "All"
end

-- Mencegah loop berjalan ganda (Crash Prevention) jika loadstring dipanggil dua kali
if _G.AutoFarmLoopStarted then return end
_G.AutoFarmLoopStarted = true

local player = game.Players.LocalPlayer

-- Fungsi pendeteksi Base
local function getMyBase()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local terdekat = nil
    local jarakTerdekat = math.huge

    for _, obj in pairs(workspace:GetChildren()) do
        if string.sub(obj.Name, 1, 5) == "Base_" then
            local partBase = obj:FindFirstChildWhichIsA("BasePart", true) or obj:FindFirstChildWhichIsA("Model", true)
            if partBase then
                local pos = partBase:IsA("BasePart") and partBase.Position or
                (partBase.PrimaryPart and partBase.PrimaryPart.Position)
                if pos then
                    local jarak = (root.Position - pos).Magnitude
                    if jarak < jarakTerdekat then
                        jarakTerdekat = jarak
                        terdekat = obj
                    end
                end
            end
        end
    end
    return terdekat
end

-- Looping Utama yang berjalan di latar belakang (selamanya)
task.spawn(function()
    while true do
        -- [FITUR 1] Auto Collect Koin
        if _G.AutoCollectAktif then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            local myBase = getMyBase()

            if root and myBase then
                local slotsFolder = myBase:FindFirstChild("Slots")

                if slotsFolder then
                    for i = 1, 96 do
                        if not _G.AutoCollectAktif then break end

                        local slot = slotsFolder:FindFirstChild(tostring(i))

                        if slot then
                            local targetPart = nil
                            local partNein = slot:FindFirstChild("nein", true)

                            if partNein and partNein:IsA("BasePart") then
                                targetPart = partNein
                            else
                                targetPart = slot:FindFirstChildWhichIsA("BasePart", true)
                                if not targetPart and slot:IsA("Model") then
                                    targetPart = slot.PrimaryPart
                                end
                            end

                            if targetPart and targetPart:IsA("BasePart") then
                                root.CFrame = targetPart.CFrame
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end

        -- [FITUR 2] Auto Buy CollectibleBox
        if _G.AutoBuyAktif then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local myBase = getMyBase()

            if root and myBase then
                -- Mencari semua anak di dalam Base Anda
                for _, obj in pairs(myBase:GetChildren()) do
                    if not _G.AutoBuyAktif then break end
                    
                    -- Cari objek yang memiliki TierId di dalamnya (seperti CollectibleBox)
                    local tierIdObj = obj:FindFirstChild("TierId")
                    
                    if tierIdObj then
                        local tierValue = tostring(tierIdObj.Value)
                        
                        -- Cek apakah objek ini VISIBLE (tidak menghilang/transparan)
                        local isVisible = false
                        local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                        
                        if targetPart and targetPart.Transparency < 1 then
                            isVisible = true
                        end
                        
                        -- Jika Box nya ada wujudnya (visible) dan Rarity-nya sesuai
                        if isVisible then
                            if _G.TargetRarity == "All" or _G.TargetRarity == tierValue then
                                root.CFrame = targetPart.CFrame
                                task.wait(0.2) -- Jeda saat membeli
                            end
                        end
                    end
                end
            end
        end

        -- Jeda idle
        task.wait(0.1)
    end
end)
