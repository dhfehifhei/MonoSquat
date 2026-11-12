local REPO = "dhfehifhei/MonoSquat"
local BRANCH = "main"
local BASE = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/"

local function fetchScript(url)
	local ok, body = pcall(function() return game:HttpGet(url, true) end)
	if ok and type(body) == "string" and #body > 0 then return body end
	return nil
end

local part1Src = fetchScript(BASE .. "Part1_Engine.lua")
if not part1Src then warn("[MonoSquat] Failed to fetch Part1"); return end
local Core, err2 = pcall(function() return loadstring(part1Src)() end)
if not Core then warn("[MonoSquat] Part1 error: " .. tostring(err2)); return end

local part2Src = fetchScript(BASE .. "Part2_UI.lua")
if not part2Src then warn("[MonoSquat] Failed to fetch Part2"); return end

print("[MonoSquat] Запуск Part2...")
local ok, runErr = pcall(function() return loadstring(part2Src)()(Core) end)
if not ok then warn("[MonoSquat] Part2 error: " .. tostring(runErr)); return end
print("[MonoSquat] Part2 выполнен.")

-- ==========================================
-- ПРИНУДИТЕЛЬНЫЙ ПОИСК И ВКЛЮЧЕНИЕ GUI
-- ==========================================
task.wait(0.5)
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local gui = PlayerGui:FindFirstChild("MonoSquat")

if gui then
	print("[MonoSquat] Меню найдено в PlayerGui!")
	gui.Enabled = true
	gui.DisplayOrder = 999
	
	-- Ищем MainFrame и принудительно ставим его на экран
	local mainFrame = gui:FindFirstChild("MainFrame")
	if mainFrame then
		mainFrame.Visible = true
		mainFrame.Position = UDim2.new(0.5, -227, 0.5, -139)
		mainFrame.ZIndex = 100
		print("[MonoSquat] MainFrame включен и отцентрирован.")
	else
		warn("[MonoSquat] MainFrame не найден внутри GUI!")
	end
	
	-- Включаем ватермарку
	local wm = gui:FindFirstChild("Watermark")
	if wm then
		wm.Visible = true
		wm.ZIndex = 100
		print("[MonoSquat] Watermark включен.")
	end
else
	warn("[MonoSquat] GUI не найден в PlayerGui (даже после успешного Part2).")
end