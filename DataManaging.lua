
--[[
///////// Made by remiel430
//// Discord: Rem#0040
]]


-- Services

-- USING PROFILE SERVICE ||||||||||||||||||||||||||||||||||||\\\\\\\\\\\\\\



local players = game:GetService("Players")
local ProfileService = require(script.Parent.ProfileService)

local RP = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Modules = RP:WaitForChild("Modules")
local DataModules = Modules:WaitForChild("Data")
local QuestModule = require(DataModules.Quest)
local ProgModule = require(DataModules.Save)

--- CURRENT VERSION

local version = 1


--- VERSION INT JUST KEEPS A VALUE IN PROFILE SERVICE FOLDER WITH THE CURRENT VERSION CALLED "CURRENTVERSION"

local VersionInt = script.Parent:WaitForChild("CurrentVersion")
VersionInt.Value = version

--- DATA MODULES ---

local AddVersions = require(script.Parent:WaitForChild("Add Versions"))
local SaveModule = require(script.Parent:WaitForChild("Save"))

--- PROFILE DATA (BASE DATA) ---

local BaseData = {
	version = version;
	AttackMultipliers = {
		Strength = 1;
		Ability = 1;
		Durability = 1;
		Chakra = 1;
	};

	Leaderstats = {
		SkillPoints = 0;
		Yen = 100;
		Level = 1;
		XP = 0;
		MaxExp = 20^1.28;
	};

	Quests = {
		Data = QuestModule.Quests;
		Current = "none";
	};

}

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData",
	BaseData
)

local Profiles = {}
local function onPlayerAdded(plr)
	local profile
	
	if RunService:IsStudio() then
		profile = ProfileStore.Mock:LoadProfileAsync(
			""..plr.UserId,
			"ForceLoad"
		)
	else
		profile = ProfileStore:LoadProfileAsync(
			""..plr.UserId,
			"ForceLoad"
		)
	end
	
	
	if profile then
		profile:ListenToRelease(function()
			Profiles[players] = nil
			plr:Kick()
		end)
		if plr:IsDescendantOf(players) then
			Profiles[plr] = profile
			local Data = profile.Data -- DATA
			ProgModule[plr.UserId] = profile.Data
			-- Add Stats Here --
			
			local abilityLevels = Data.AttackMultipliers
			local lds = Data.Leaderstats
			local YenData = lds.Yen
			local LevelData = lds.Level
			
			local MaxChakra = 150 * abilityLevels.Chakra
			Data.Chakra = MaxChakra
			Data.MaxChakra = MaxChakra
			
			
			local Leaderstats 	= Instance.new("Folder", plr); Leaderstats.Name = "leaderstats"
			local Yen 			= Instance.new("IntValue", Leaderstats); Yen.Name = "Yen"; Yen.Value = YenData
			local Level 		= Instance.new("IntValue", Leaderstats); Level.Name = "Level"; Level.Value = LevelData
			local XP 			= Instance.new("IntValue", plr); XP.Name = "XP"; XP.Value = lds.XP
			local Chakra 		= Instance.new("IntValue", plr); Chakra.Name = "Chakra"; Chakra.Value = MaxChakra
			local Max_Chakra 	= Instance.new("IntValue", plr); Max_Chakra.Name = "MaxChakra"; Max_Chakra.Value = MaxChakra
			
			AddVersions(plr) -- Add Versions for people under original version.
			SaveModule(plr) -- This holds the change events to keep saving the data.
			
		else
			profile:Release()
		end
	else
		plr:Kick()
	end
	
	
	
end

local function onPlayerRemoved(plr)
	local profile = Profiles[plr]
	if profile then
		local data = profile.Data
		--- Clear Data
		data.Chakra = nil
		data.MaxChakra = nil
		
		--- Release Profile ---
		profile:Release()
		if RunService:IsStudio() then
			ProfileStore:WipeProfileAsync(""..plr.UserId)
		end
		print("Saved "..plr.Name.."'s data!")
		ProgModule[plr.UserId] = nil
	end
end

local DataManager = {}

function DataManager:Get(plr)
	local profile = Profiles[plr]

	if profile then
		return profile.Data
	end
end

players.PlayerAdded:Connect(onPlayerAdded)

for i,v in pairs(players:GetPlayers()) do
	if not ProgModule[v.UserId] then
		onPlayerAdded(v)
	end
end

players.PlayerRemoving:Connect(onPlayerRemoved)
return DataManager
