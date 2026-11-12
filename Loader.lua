local REPO = "dhfehifhei/MonoSquat"
local BRANCH = "main"
local BASE = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/"

print("[MonoSquat] 1. Загрузка Part1...")
local part1Src = game:HttpGet(BASE .. "Part1_Engine.lua")
local part1Fn, err1 = loadstring(part1Src)
if not part1Fn then warn("[MonoSquat] Ошибка компиляции Part1: " .. tostring(err1)) return end

local ok1, Core = pcall(part1Fn)
if not ok1 then warn("[MonoSquat] Ошибка выполнения Part1: " .. tostring(Core)) return end
print("[MonoSquat] 2. Part1 загружен успешно.")

print("[MonoSquat] 3. Загрузка Part2...")
local part2Src = game:HttpGet(BASE .. "Part2_UI.lua")
local part2Fn, err2 = loadstring(part2Src)
if not part2Fn then warn("[MonoSquat] Ошибка компиляции Part2: " .. tostring(err2)) return end

print("[MonoSquat] 4. Запуск Part2 (создание UI)...")
-- Убираем pcall, чтобы экзекутор выдал красную ошибку с точной строкой
local success, err3 = pcall(part2Fn, Core)
if not success then 
    warn("[MonoSquat] ОШИБКА В PART2: " .. tostring(err3)) 
    -- Выводим ошибку в консоль разработчика, чтобы она была красной и заметной
    error("[MonoSquat] PART2 FAILED: " .. tostring(err3))
end

print("[MonoSquat] 5. Part2 выполнен.")