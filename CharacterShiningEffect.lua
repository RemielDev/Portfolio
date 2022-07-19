 --[[
///////// Made by remiel430
//// Discord: Rem#0040
]]


-- Services

local Debris = game:GetService("Debris")
local Mods = game:GetService("ReplicatedStorage"):WaitForChild("Modules"); local dataMods = Mods:WaitForChild("Data")

local ActionService = _G.import("ActionService")
local Tween = ActionService.Tween
local ProgModule = require(dataMods.Save)
local lvlUP = script:WaitForChild("LevelUp")
local pt1 = lvlUP.PT1
local pt2 = lvlUP.PT2

local function upt(at1, at2)
	
	at1.Ray1.Enabled = false
	at1.Ray2.Enabled = false
	for i,v in pairs(at2:GetChildren()) do
		v.Enabled = false
	end
	Debris:AddItem(at1, 1)
	Debris:AddItem(at2, 1)
end

return function(plr)
	local plrFX = workspace.InGameStorage.PlayerStorage:FindFirstChild(plr.UserId).EffectsStorage

	local Character = plr.Character
	if Character then
		local HRP = Character:WaitForChild("HumanoidRootPart")
		
		-- Coin Collect Sound --
		local ccSound = script:WaitForChild("CoinCollect"):Clone()
		ccSound.Parent = HRP
		ccSound:Play()
		Debris:AddItem(ccSound, ccSound.TimeLength)
		
		--- Particle Effects ---
		task.defer(function()
			local at1 = pt1.AT:Clone()
			local at2 = pt2.AT:Clone()
			at1.Parent =  HRP
			at2.Parent = HRP
			task.wait(5)
			upt(at1, at2)
		end)
		
		--- VFX ---
		
		task.defer(function()
			local FX1 = lvlUP.FX1:Clone()
			FX1.Transparency = 1
			FX1.Position = HRP.Position - Vector3.new(0,.6,0)
			local w = Instance.new("WeldConstraint", FX1)
			w.Part0 = FX1
			w.Part1 = HRP
			FX1.Parent = plrFX
			Tween(FX1, {Transparency = 0, Orientation = FX1.Orientation+Vector3.new(0,250,0)}, .5)
			task.wait(.5)
			Tween(FX1, {Transparency = 1, Orientation = FX1.Orientation+Vector3.new(0,250,0), Size = FX1.Size + Vector3.new(5,5,5)}, .5)
			Debris:AddItem(FX1, 1)
		end)
		--- VFX 2 ---
		task.defer(function()
			local FX2 = lvlUP.FX2:Clone()
			FX2.Transparency = 1
			FX2.Position = HRP.Position - Vector3.new(0,3,0)
			local w = Instance.new("WeldConstraint", FX2)
			w.Part0 = FX2
			w.Part1 = HRP
			FX2.Parent = plrFX
			Tween(FX2, {Transparency = 0, Orientation = FX2.Orientation+Vector3.new(0,250,0)}, .5)
			task.wait(.5)
			Tween(FX2, {Transparency = 1, Orientation = FX2.Orientation+Vector3.new(0,250,0), Size = FX2.Size + Vector3.new(5,5,5)}, .5)
			Debris:AddItem(FX2, 1)
		end)
	end
end
