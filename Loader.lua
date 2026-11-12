local REPO = "dhfehifhei/MonoSquat"
local BRANCH = "main"
local BASE = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/"

local function fetchScript(url)
	local ok, body = pcall(function() return game:HttpGet(url, true) end)
	if ok and type(body) == "string" and #body > 0 then return body end
	return nil
end

-- ==== ЧАСТЬ 1 ====
local part1Src = fetchScript(BASE .. "Part1_Engine.lua")
if not part1Src then warn("[MonoSquat] Failed to fetch Part1"); return end

local part1Fn, err1 = loadstring(part1Src)
if not part1Fn then warn("[MonoSquat] Part1 compile error: " .. tostring(err1)); return end

local ok1, Core = pcall(part1Fn)
if not ok1 then warn("[MonoSquat] Part1 runtime error: " .. tostring(Core)); return end

-- ==== ЧАСТЬ 2 ====
local part2Src = fetchScript(BASE .. "Part2_UI.lua")
if not part2Src then warn("[MonoSquat] Failed to fetch Part2"); return end

local part2Fn, err2 = loadstring(part2Src)
if not part2Fn then warn("[MonoSquat] Part2 compile error: " .. tostring(err2)); return end

print("[MonoSquat] Запуск Part2...")
local ok2, err3 = pcall(part2Fn, Core) -- <--- ВОТ ТУТ ПЕРЕДАЕТСЯ CORE
if not ok2 then warn("[MonoSquat] Part2 runtime error: " .. tostring(err3)); return end
print("[MonoSquat] Part2 выполнен.")

-- ==========================================
-- ПРИНУДИТЕЛЬНОЕ ВКЛЮЧЕНИЕ UI
-- ==========================================
task.wait(0.5)
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local gui = PlayerGui:FindFirstChild("MonoSquat")

if gui then
	print("[MonoSquat] GUI найден в PlayerGui!")
	gui.Enabled = true
	gui.DisplayOrder = 999
	
	local mainFrame = gui:FindFirstChild("MainFrame")
	if mainFrame then
		mainFrame.Visible = true
		mainFrame.Position = UDim2.new(0.5, -227, 0.5, -139)
		mainFrame.ZIndex = 100
		print("[MonoSquat] MainFrame включен.")
	end
	
	local wm = gui:FindFirstChild("Watermark")
	if wm then
		wm.Visible = true
		wm.ZIndex = 100
		print("[MonoSquat] Watermark включен.")
	end
else
	warn("[MonoSquat] ОШИБКА: GUI не найден в PlayerGui даже после успешного Part2.")
end