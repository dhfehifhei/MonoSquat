local REPO = "dhfehifhei/MonoSquat"
local BRANCH = "main"

local BASE = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/"

print("[MonoSquat] Fetching Part 1...")
local part1Src = game:HttpGet(BASE .. "Part1_Engine.lua")
local part1Fn, err1 = loadstring(part1Src)
if not part1Fn then warn("[MonoSquat] Compile error Part1: " .. tostring(err1)) return end

local ok1, Core = pcall(part1Fn)
if not ok1 then warn("[MonoSquat] Runtime error Part1: " .. tostring(Core)) return end
print("[MonoSquat] Part 1 loaded OK.")

print("[MonoSquat] Fetching Part 2...")
local part2Src = game:HttpGet(BASE .. "Part2_UI.lua")
local part2Fn, err2 = loadstring(part2Src)
if not part2Fn then warn("[MonoSquat] Compile error Part2: " .. tostring(err2)) return end

print("[MonoSquat] Running Part 2...")
local ok2, err3 = pcall(part2Fn, Core)
if not ok2 then warn("[MonoSquat] Runtime error Part2: " .. tostring(err3)) return end

print("[MonoSquat] Loaded successfully. Click the watermark to toggle the menu.")