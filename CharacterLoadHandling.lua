
--[[
///////// Made by remiel430
//// Discord: Rem#0040
]]


-- Services

local self = {}

self.init = function()
	local RP = game:GetService("ReplicatedStorage")
	local SS = game:GetService("ServerStorage")
	
	---// MODIFICATIONS \\---
	
	local gameSettings = RP:WaitForChild("GameSettings")
	local AutoSelectCharacter = gameSettings:WaitForChild("AutoSelectCharacter").Value

	---// SCRIPT \\\---
	
	local PS = game:GetService("Players")
	local InGameStorage = workspace.InGameStorage
	local plrStorage = InGameStorage.PlayerStorage

	local Characters = RP:WaitForChild("Characters")
	local Events = RP:WaitForChild("Events")
	local Modules = RP:WaitForChild("Modules")

	local GlobalEvents = Events.Global
	local ActionService = _G.import("ActionService")
	local CameraEvent = GlobalEvents.Camera
	local CustomizeEvents = Events.Customization
	local ServerEvent = CustomizeEvents.Server
	local CharacterLoads = {}

	local CollisionsModule = require(Modules:WaitForChild("CollisionHandler"))
	
	local respawnTime = game.Players.RespawnTime
	

	
	local function loadCharacter(plr, CustomCharacter)
		local CharacterLoad = CharacterLoads[plr.UserId] or CustomCharacter
		if not CharacterLoad then plr:LoadCharacter() print("No External Character Connected") return end
		local PersonalCharacter = plr.Character
		if PersonalCharacter then  task.wait(respawnTime) PersonalCharacter:Remove() task.wait(1.5)  end

		CharacterLoad = Characters[CharacterLoad:GetAttribute("CharacterName")]:Clone()

		CharacterLoads[plr.UserId] = CharacterLoad
		---plr:LoadCharacter() -- QuickLoad
		CharacterLoad.Parent = workspace
		CharacterLoad.Name = plr.Name
		CollisionsModule.onCharacterAdded(CharacterLoad)
		plr.Character = CharacterLoad

		local Humanoid = CharacterLoad:FindFirstChild("Humanoid")
		CharacterLoad.PrimaryPart = Humanoid.RootPart

		local HRP = CharacterLoad:WaitForChild("HumanoidRootPart")
		HRP.CFrame = RP:WaitForChild("CS")["Subject"].CFrame
		--wait(.5)
		local CharacterTools = CharacterLoad.Tools

		for i, tool in pairs(CharacterTools:GetChildren()) do
			local T1 = tool:Clone()
			local T2 = tool:Clone()
			tool:Destroy()
			T2.Parent = plr.Backpack
		end

		local ChakraValue, MaxChakraValue = plr:WaitForChild("Chakra"), plr:WaitForChild("MaxChakra")
		ChakraValue.Value = MaxChakraValue.Value

		local plr_Gui = plr:WaitForChild("PlayerGui")

		local bp = plr_Gui:WaitForChild("Backpack")
		local mobUI = plr_Gui:WaitForChild("MobileUI")
		local ScrollBar = plr_Gui:WaitForChild("ScrollBar")
		local StatsGui = plr_Gui:WaitForChild("Stats")

		ScrollBar.Enabled = true; 	ScrollBar:FindFirstChildOfClass("LocalScript").Disabled = false
		StatsGui.Enabled = true; 	StatsGui:FindFirstChildOfClass("LocalScript").Disabled = false
		bp.Enabled = true; 			bp:FindFirstChildOfClass("LocalScript").Disabled = false
		mobUI.Enabled = true; 		mobUI:FindFirstChildOfClass("LocalScript").Disabled = false
		print("Loaded:", plr)
	end


	local function SelectCharacter(plr, newCharacter, isOverride)
		newCharacter = Characters:FindFirstChild(newCharacter)
		if not newCharacter then error(newCharacter.." Not Listed In Characters Folder") return end
		loadCharacter(plr, newCharacter); 
		if not isOverride then
			ServerEvent:FireClient(plr, "Select Character")
			local Character = plr.Character
			local Humanoid = Character:WaitForChild("Humanoid")
			Humanoid.WalkSpeed = 0
		else
			ServerEvent:FireClient(plr, "Select Character", true)
		end
	end

	local function SignalCustomization(plr)
		ServerEvent:FireClient(plr, "Customize")
	end

	local function Load(plr)
		SelectCharacter(plr, "Naruto", true)
	end
	
	local function onPlayerAdded(plr)

			local chScript = script:WaitForChild("CharacterEffects"):Clone()
			chScript.Parent = workspace:WaitForChild("InGameStorage"):WaitForChild("PlayerStorage")
			chScript.Name = plr.UserId

			plr.CharacterAdded:Connect(function(Character)
				local Humanoid = Character:WaitForChild("Humanoid")

				Humanoid.Died:Connect(function()

					if AutoSelectCharacter then
						loadCharacter(plr)
					else
						loadCharacter(plr)
					end

				end)

				local lastHealth = Humanoid.MaxHealth

				Humanoid:GetPropertyChangedSignal("Health"):Connect(function()

					local val = Humanoid.Health
					local cals = (val - lastHealth)
					local positive = false

					if cals > 0 then
						positive = true
					end

					if positive then
						ActionService.IndicateDamage(Humanoid.Parent, cals, positive)
					end

					lastHealth = val
				end)


				local lastMaxHealth = Humanoid.MaxHealth

				Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()

					local NewMaxHealth = Humanoid.MaxHealth
					local isBlocking = ActionService.DetectBlock(Humanoid.Parent)

					if isBlocking then
						local MaxHealthDiffrence = math.floor(NewMaxHealth - lastMaxHealth)
						--print(MaxHealthDiffrence)
						local currentBlockHealth = math.floor((MaxHealthDiffrence/1.5) + isBlocking.Value)
						isBlocking.Value = currentBlockHealth
					end

					lastMaxHealth = Humanoid.MaxHealth

				end)


				local scriptsFolder =  script:WaitForChild("ClientScripts"):Clone()
			--	print(scriptsFolder)
				local scripts = {}
				for i,v in pairs(scriptsFolder:GetChildren()) do
					v.Parent= Humanoid.Parent
					table.insert(scripts, 1, v)
				end

				task.wait(3)
				for i,v in pairs(scripts) do
					if v:IsA("Script") or v:IsA("LocalScript") then
						v.Disabled = false
					end
				end
				scriptsFolder:Destroy()
			end)
	end
	
	local function onPlayerLeft(plr)
		local plrStorageFolder = plrStorage:FindFirstChild(plr.UserId)
		if plrStorageFolder then
			plrStorageFolder:Destroy()
		end
	end
	
	local functions = {
		["Select Character"] = SelectCharacter;
		["Begin Customization"] = SignalCustomization,
		['Load'] = Load,
	}
	
	local Players = game:GetService("Players")
	
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerLeft)
	
	for i,plr in pairs(Players:GetPlayers()) do
		onPlayerAdded(plr)
	end
	
	ServerEvent.OnServerEvent:Connect(function(plr, type, type2)
		functions[type](plr, type2)
	end)
end


return {
	priority = 2;
	listener = self;
	name = script.Name;
}
