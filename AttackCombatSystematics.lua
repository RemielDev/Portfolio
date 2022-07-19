--[[
///////// Made by remiel430
//// Discord: Rem#0040
]]


-- Services


local self = {}

self.init = function()
	local RP = game:GetService("ReplicatedStorage")
	local Debris = game:GetService("Debris")

	local Modules = RP:WaitForChild("Modules")
	local Events = RP:WaitForChild("Events")
	local ActionEvents = Events.Action

	local mainActionEvent = ActionEvents.Action
	local ClientEvent = ActionEvents.Client
	local ActionService = _G.import("ActionService")

	local AbilitiesClass = Modules.Abilities

	local blockModule = require(script:WaitForChild("Block"))

	mainActionEvent.OnServerEvent:Connect(function(Caster, EventName, Serial1, Serial2, Serial3, Serial4) -- Serial1 = order
		local Character = Caster.Character or Caster.CharacterAdded:Wait()
		local Humanoid = Character:WaitForChild("Humanoid")
		local HRP = Character:WaitForChild("HumanoidRootPart")
		local chakraInt = Caster:WaitForChild("Chakra")

		local Range = 650 --- ChunkLoadRange

		local PlayersNearby = ActionService.CharacterService:FindPlayersNearby(Caster, Range)

		if EventName == "Dash" then
			for i, plr in pairs(PlayersNearby) do
				ClientEvent:FireClient(plr, "Dash", Modules.Abilities.Dash, Caster, Serial1)
			end
		end

		if EventName == "Combat Attack" then
			for i, plr in pairs(PlayersNearby) do
				ClientEvent:FireClient(plr, "ClientAttack", Modules.CombatModule, Caster, Serial1)
			end
		end

		if EventName == "Block Attack" then
			blockModule(Caster, EventName, Serial1, Serial2, Serial3, Serial4)
		end

		local Class = AbilitiesClass:FindFirstChild(EventName)
		if Class and Serial1 then
			local Module = Class:FindFirstChild(Serial1)
			if not Module then return end
			local Info = Character:WaitForChild("Info")
			local InfoModule = require(Info)
			local Abilities_Tab = InfoModule.Abilities
			local Ability
			for i,v in pairs(Abilities_Tab) do
				if v.Name == Serial1 then
					Ability = v
					break
				end
			end
			local chakraData = Ability.Chakra
			if chakraInt.Value >= chakraData then
				chakraInt.Value -= chakraData
				local mod = require(Module)
				mod.Server(Caster)
				for i, plr in pairs(PlayersNearby) do
					ClientEvent:FireClient(plr, "ClientAttack", Module, Caster)
				end
			else
				warn("NotEnoughChakra - SERVER SIDE -- HACKER DETECTED or MISLED ERROR")
			end
		end
	end)



end


return {
	priority = 3;
	listener = self;
	name = script.Name;
}
