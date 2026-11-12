local REPO = "dhfehifhei/MonoSquat"
local BRANCH = "main"
local BASE = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/"

local function fetchScript(fileName)
	-- Добавляем tick(), чтобы GitHub не отдавал старый кэш
	local url = BASE .. fileName .. "?t=" .. tostring(math.floor(tick()))
	local ok, body = pcall(function() return game:HttpGet(url, true) end)
	if not ok or type(body) ~= "string" or #body < 20 then
		warn("[MonoSquat] Ошибка сети при загрузке: " .. fileName)
		return nil
	end
	if body:sub(1, 15):find("404") then
		warn("[MonoSquat] Файл не найден на GitHub (404): " .. fileName .. " — проверь регистр букв в названии файла!")
		return nil
	end
	return body
end

local part1Src = fetchScript("Part1_Engine.lua")
if not part1Src then return end

local part1Fn, err1 = loadstring(part1Src, "MonoSquat_Part1")
if not part1Fn then warn("[MonoSquat] Ошибка синтаксиса Part1: " .. tostring(err1)); return end

local ok1, Core = pcall(part1Fn)
if not ok1 or type(Core) ~= "table" then
	warn("[MonoSquat] Ошибка выполнения Part1: " .. tostring(Core))
	return
end

local part2Src = fetchScript("Part2_UI.lua")
if not part2Src then return end

local part2Fn, err2 = loadstring(part2Src, "MonoSquat_Part2")
if not part2Fn then warn("[MonoSquat] Ошибка синтаксиса Part2: " .. tostring(err2)); return end

local ok2, uiInitOrErr = pcall(part2Fn)
if not ok2 then
	warn("[MonoSquat] Ошибка загрузки Part2: " .. tostring(uiInitOrErr))
	return
end

-- Если Part2 начинается с `return function(Core)`, вызываем возвращенную функцию
if type(uiInitOrErr) == "function" then
	local okRun, runErr = pcall(uiInitOrErr, Core)
	if not okRun then
		warn("[MonoSquat] Ошибка внутри Part2: " .. tostring(runErr))
		return
	end
end

-- Принудительный перенос в PlayerGui для 100% отображения
task.wait(0.3)
local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local gui = (Core.guiParent and Core.guiParent:FindFirstChild("MonoSquat"))
	or (gethui and gethui():FindFirstChild("MonoSquat"))
	or game:GetService("CoreGui"):FindFirstChild("MonoSquat")
	or playerGui:FindFirstChild("MonoSquat")

if gui then
	gui.Parent = playerGui
	gui.Enabled = true
	print("[MonoSquat] Меню успешно загружено и выведено на экран!")
else
	warn("[MonoSquat] ScreenGui 'MonoSquat' не найден после запуска.")
end
