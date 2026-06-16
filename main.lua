-- File ini sangat sempurna jika Anda ingin menggabungkannya dengan UI Library (Orion, Rayfield, dll.)

-- Variabel ini yang akan dikendalikan (diubah) oleh tombol Toggle di UI Anda nanti
if _G.AutoCollectAktif == nil then
    _G.AutoCollectAktif = false
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
        -- Skrip hanya akan teleport / bekerja APABILA Toggle di UI Anda menyala (true)
        if _G.AutoCollectAktif then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            -- Mendeteksi base secara real-time (berguna jika user pindah base sebelum menyalakan toggle)
            local myBase = getMyBase()

            if root and myBase then
                local slotsFolder = myBase:FindFirstChild("Slots")

                if slotsFolder then
                    for i = 1, 96 do
                        -- Fitur Darurat: Jika tiba-tiba UI dimatikan di tengah-tengah teleport, skrip langsung berhenti
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

                            -- TELEPORTASI
                            if targetPart and targetPart:IsA("BasePart") then
                                root.CFrame = targetPart.CFrame
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end

        -- Jeda idle. Jika UI Mati (false), skrip akan tertidur di sini tanpa memakan RAM
        task.wait(0.1)
    end
end)
