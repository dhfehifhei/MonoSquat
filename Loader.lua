local REPO = "dhfehifhei/MonoSquat"
local BRANCH = "main"
local BASE = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/"

local function fetchScript(url)
	local ok, body = pcall(function() return game:HttpGet(url, true) end)
	if ok and type(body) == "string" and #body > 0 then return body end
	return nil
end

local function runChunk(source, chunkName)
	local fn, err = loadstring(source, chunkName)
	if not fn then return nil, "compile error: " .. tostring(err) end
	local ok, result = pcall(fn)
	if not ok then return nil, "runtime error: " .. tostring(result) end
	return result
end

local part1Src = fetchScript(BASE .. "Part1_Engine.lua")
if not part1Src then warn("[MonoSquat] Failed to fetch Part1"); return end

local Core, err2 = runChunk(part1Src, "MonoSquat_Part1")
if not Core then warn("[MonoSquat] " .. tostring(err2)); return end

local part2Src = fetchScript(BASE .. "Part2_UI.lua")
if not part2Src then warn("[MonoSquat] Failed to fetch Part2"); return end

local part2Fn, err4 = loadstring(part2Src, "MonoSquat_Part2")
if not part2Fn then warn("[MonoSquat] " .. tostring(err4)); return end

local ok, runErr = pcall(part2Fn, Core)
if not ok then warn("[MonoSquat] Part2 error: " .. tostring(runErr)); return end

-- ==========================================
-- ПРИНУДИТЕЛЬНОЕ ОТОБРАЖЕНИЕ GUI
-- ==========================================
print("[MonoSquat] Скрипт загружен. Ищем меню...")

task.wait(0.5) -- Ждем полсекунды, чтобы GUI успел прогрузиться

local gui = game:GetService("CoreGui"):FindFirstChild("MonoSquat") 
	or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MonoSquat")

if gui then
	print("[MonoSquat] Меню найдено! Принудительно переносим на экран.")
	
	-- 1. Переносим в обычный PlayerGui (там он точно не скроется)
	gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	
	-- 2. Включаем видимость
	gui.Enabled = true
	
	-- 3. Ищем главный фрейм и ставим его в центр экрана
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("Frame") and obj.Name == "MainFrame" then
			obj.Visible = true
			obj.Position = UDim2.new(0.5, -227, 0.5, -139)
			obj.Size = UDim2.new(0, 455, 0, 278)
			obj.ZIndex = 1000
		end
		-- На всякий случай поднимаем ватермарку
		if obj:IsA("TextButton") and obj.Name == "Watermark" then
			obj.Visible = true
			obj.ZIndex = 1000
		end
	end
	print("[MonoSquat] Готово! Меню должно быть по центру экрана.")
else
	warn("[MonoSquat] ОШИБКА: GUI вообще не был создан в памяти игры.")
end