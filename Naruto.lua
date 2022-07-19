debug.setmemorycategory("ReplicatedStorage.Modules.CombatModule")
local RP = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Sounds = RP:WaitForChild("Sounds")
local punch = Sounds:WaitForChild("Punch") 
local Kick = Sounds:WaitForChild("Kick")

local Storage = workspace:WaitForChild("InGameStorage")

local Modules = RP:WaitForChild("Modules")
local Events = RP:WaitForChild("Events")


local ActionEvents = Events.Action
local GlobalEvents = Events.Global
local HitFunction = ActionEvents.Hit
local Tween_Server = ActionEvents.Tween

local Animations = RP:WaitForChild("Animations")
local Anim_Combat = Animations.Combat
local Anim_Random = Animations.Random
local Anim_Abilities = Animations.Abilities

local _Combat_Caster = Anim_Combat.Caster
local _Combat_Casted = Anim_Combat.Casted

local mainActionEvent = ActionEvents.Action
local ClientEvent = ActionEvents.Client

local DebounceChecker= ActionEvents.DebounceChecker

local CameraUtility = require(Modules.CameraUtil)
local CameraShaker = require(Modules.CameraShaker)

local clientVignette
local RaycastModule = require(Modules.Raycast)

local ActionService = _G.import("ActionService")
local CharacterService = ActionService.CharacterService
local RemoveSprintTrails = CharacterService.RemoveSprintTrails
local HitboxCreation = ActionService.CreateHitbox
local LookTowards = CharacterService.LookTowards -- HRP, OtherHRP, WaitTime
local LookTowardsMouse = CharacterService.LookTowardsMouse -- Object/HRP, MousePFosition, WaitTime
local FindHRPsInRange = CharacterService.FindHRPInRange -- YourHRP/ Ignore, Object/ Radius Start, Distance
local IndicateDamage = ActionService.IndicateDamage -- (Gui, Character, Damage)
local Tween = ActionService.Tween
local HitFX = ActionService.HitFX

local RockModule = ActionService.rock

--- Additional Effects --- 

local Blood = script:WaitForChild("BloodEffect")
local Fright = script:WaitForChild("Fright")

local Animations : any = {
	[1] = _Combat_Casted.Right_Hit;
	[2] = _Combat_Casted.Left_Hit;
	[3] = _Combat_Casted.Head_Hit;
	[4] = _Combat_Casted.Pushed_Hit
}

local functions = {}

local Effect  = script:WaitForChild("Effect"):WaitForChild("Effect")

local getCast = ActionService.GetCast


functions.Push = function(Character, Caster, desired_WalkSpeed : number)
	if Caster:IsA("Player")then
		Caster = Caster.Character
	end

	local Humanoid = Character:WaitForChild("Humanoid")
	local HRP = Character:WaitForChild("HumanoidRootPart")

	local Animation = Animations[4]

	Humanoid.WalkSpeed = 0
	local TrackAnimation = Humanoid:WaitForChild("Animator"):LoadAnimation(Animation)
	local casterHRP = Caster:WaitForChild("HumanoidRootPart")
	local ray = getCast(Caster, Character, 15)-- or casterHRP.CFrame.LookVector * 10
	
	HRP.Anchored = true
	local rotation = HRP.CFrame - HRP.Position
	Tween_Server:InvokeServer(HRP, {CFrame = rotation + ray}, "Knockback")
	Tween(HRP, {CFrame = rotation + ray}, .3, Enum.EasingStyle.Linear)
	
	--Tween_Server:InvokeServer(HRP, {CFrame = rotation + ray}, "Knockback")

	TrackAnimation:Play() 
	task.wait(.3)
	HRP.Anchored = false
	
	TrackAnimation:Stop()
	--BodyPosition:Destroy()	
	Humanoid.WalkSpeed = desired_WalkSpeed
end


functions.CreateHitbox = function(Client : Player, Caster : any, FinalHit : boolean, Order : number , obj, scnd_obj)
	print("CreatingHitbox:", Client, Caster)
	local Character = Caster
	local bot = true
	if not Caster:IsA("Model") then
		bot = false
		Character = Caster.Character or Caster.CharacterAdded:Wait()
	end
	local Humanoid = Character:WaitForChild("Humanoid")
	local HRP = Character:WaitForChild("HumanoidRootPart")

	local Hitbox
	local DoubleHitbox

	local hitPlayer = false
	local function collided(hit, otherHumanoid)
		if hitPlayer then return end	
		--print("Hit!", "Bot:", bot, "HitHumanoid:", otherHumanoid, "ClientHumanoid:", Humanoid, "HIT:", hit)
		-- and (otherHumanoid ~= Humanoid or (bot and otherHumanoid == Humanoid))
		if otherHumanoid then

			local otherCharacter 	= otherHumanoid.Parent
			local safeZone 			= otherCharacter:FindFirstChild("SafeZone")
			local isLog 			= otherCharacter:FindFirstChild("Log")

			if otherHumanoid.Health ~= 0 and Humanoid.Health ~= 0 and not safeZone then
				local propBot = (otherCharacter.Parent == workspace.Dummies.Fighting)

				if bot and propBot  then print("Team Mate") return end
				hitPlayer = true

				clientVignette(3)

				local walkspeed = 16

				local OtherPlr = game.Players:GetPlayerFromCharacter(otherCharacter)
				local OtherHRP = otherCharacter:WaitForChild("HumanoidRootPart")
				local cam = workspace.CurrentCamera
				
				
				task.defer(function()
					local in1 = Client
					local in2 = Caster
					if Client:IsA("Player") then
						in1 = Client.Character
					end
					if Caster:IsA("Player") then
						in2 = Caster.Character
					end
					if in1 == in2 or in2 == otherCharacter then
						local camShake = CameraUtility.camShake
						camShake:Start()
						if not FinalHit then
							camShake:Shake(CameraShaker.Presets.MinorBump)
						else
							camShake:Shake(CameraShaker.Presets.Explosion)
						end
						task.wait(.5)
						camShake:Stop()
					end
				end)
				
				
				
				local damage = 10; if FinalHit then damage *= 1.8 end

				
				task.defer(function()
					RemoveSprintTrails(Client)
					if Client == Caster then
						HitFunction:InvokeServer(otherCharacter, damage, "Strength", false)
					elseif bot then
						HitFunction:InvokeServer(otherCharacter, 8, "Strength", bot)
					end
				end)
				

				if not isLog then -- make cframe diffrence
					--[[
					
					local magnitude = (HRP.Position - OtherHRP.Position).Magnitude
					local addition = CFrame.new(0,0,0)
					if 2 > magnitude then
						if not bot then
							addition = CFrame.new(0,0,1)
						else
							addition = CFrame.new(0,0,-1)
						end
					end
					
					]]
					
					--[[
					CharacterService.LookTowards(HRP, OtherHRP, .2)	
					CharacterService.LookTowards(OtherHRP, HRP, .2)	
					]]
					
					
					HRP.CFrame = CFrame.new(HRP.Position, OtherHRP.Position)
					if not isLog then
						OtherHRP.CFrame = CFrame.new(OtherHRP.CFrame.p, HRP.CFrame.p)
					end
					
					
				end

				
				
				otherHumanoid.WalkSpeed = 2
				--[[
				task.defer(function()
					local FrightClone = Fright:Clone()
					FrightClone.Parent = Storage
					FrightClone.Anchored = true
					FrightClone.CFrame = CFrame.new(OtherHRP.Position , HRP.Position) * CFrame.Angles( 0,0, math.rad(90) )
					task.wait(.1)
					Debris:AddItem(FrightClone, .6)	
					Tween(FrightClone, {Size = FrightClone.Size+Vector3.new(6,6,6), Transparency = 1}, .6, Enum.EasingStyle.Exponential)
				end)
				task.defer(function()
					
					local BloodClone = Blood:Clone()
					BloodClone.Parent = hit
					task.wait(.8)
					BloodClone.Enabled = false
					Debris:AddItem(BloodClone, 1)
				end)
				]]
				
				
				task.defer(function()
					if Humanoid.Health ~= 0 then
						local punchSound = nil
						if Order == 4 then
							punchSound = Kick:Clone()
						else
							punchSound = punch:Clone()
						end
						punchSound.Parent = HRP
						punchSound:Play()
						Debris:AddItem(punchSound, punchSound.TimeLength)
					end
				end)
				--[[
					-- MAIN PARTICLE FX
					task.defer(function()
					local punchFX = script:WaitForChild("PunchFX"):WaitForChild("Attachment"):Clone()
					local EmitMultiplier = 1
					if FinalHit then EmitMultiplier += .5 end
					local hitInst = Instance.new("Part"); hitInst.Transparency = 1; hitInst.Anchored = true; hitInst.CanCollide = false
					hitInst.CFrame = obj.CFrame
					punchFX.Parent = hitInst
					hitInst.Parent = Storage
					for i,v in pairs(punchFX:GetChildren()) do
						if v:IsA("ParticleEmitter") then
							v:Emit(v:GetAttribute("EmitCount")*EmitMultiplier)
						end
					end
					Tween(punchFX.PointLight, {Brightness = 0, Range = 0}, .8)
					Debris:AddItem(hitInst, 1)
				end)
				]]
				
				task.defer(function()
					local ParticleHitFX = HitFX.new(
						OtherHRP, --Target 
						script:WaitForChild("Burst"), --Your special mesh part
						1, --Duration (How long will the particles last?)
						1 -- Spawn Rate
					)
					local ParticleBloodFX = HitFX.new(
						OtherHRP, --Target 
						Blood, --Your special mesh part
						.8, --Duration (How long will the particles last?)
						1 -- Spawn Rate
					)
					local MeshFX = HitFX.new(
						OtherHRP, --Target 
						script:WaitForChild("MeshStick"), --Your special mesh part
						0.25, --Duration (How long will the particles last?)
						6 -- Spawn Rate
					)
					MeshFX:MeshExplode()
					ParticleBloodFX:GenerateParticles()
					ParticleHitFX:GenerateParticles()
					
				end)
				
				if not isLog then
					task.defer(function()
						if FinalHit then --HRP.CFrame*CFrame.new(0,-3.25,0)
							task.defer(functions.Push,otherCharacter, Caster, walkspeed)
							local Info = {
								Position = (HRP.CFrame*CFrame.new(0,-3.25,0).Position);
								Amount = 12;
								Radius = 4;
								DelayTime = 2;
								Size = Vector3.new(1.5,1.5,1.5);
								DoesShrink = true;
								RandomizedSize = false;
							}
							task.defer(RockModule.UniformCrater, Info)
						else
							
							local Animation = Animations[Order]

							local track = Humanoid:WaitForChild("Animator"):LoadAnimation(Animation)
							track:Play()
							

							local Animation1 = Animations[4]

							otherHumanoid.WalkSpeed = 0
							local TrackAnimation = otherHumanoid:WaitForChild("Animator"):LoadAnimation(Animation1)
							local ray = getCast(Character, OtherHRP.Parent, 2)-- or casterHRP.CFrame.LookVector * 10

							local rotation = OtherHRP.CFrame - OtherHRP.Position
							Tween(OtherHRP, {CFrame = rotation + ray}, .2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
							OtherHRP.Anchored = true
							--Tween_Server:InvokeServer(HRP, {CFrame = rotation + ray}, "Knockback")

							TrackAnimation:Play() 
							task.delay(.2, function()
								OtherHRP.Anchored = false

								TrackAnimation:Stop()
								--BodyPosition:Destroy()	
								otherHumanoid.WalkSpeed = walkspeed
							end)
							
						end
					end)
				end

				task.wait(1.75)
				if otherHumanoid.WalkSpeed < 16 then
					otherHumanoid.WalkSpeed = walkspeed
				end
			end
		else
			--print("Requirement V1 Not Met")
		end
	end

	Hitbox = RaycastModule:GetHitbox(obj)
	if Hitbox then
		Hitbox:HitStart(.5)
		Hitbox.OnHit:Connect(collided)
	end
	if scnd_obj then
		-- This is the double hand hit
		DoubleHitbox = RaycastModule:GetHitbox(scnd_obj)
		if DoubleHitbox then
			DoubleHitbox:HitStart(.5)
			DoubleHitbox.OnHit:Connect(collided)
		end
	end
	--[[
	if Hitbox then
		Hitbox.OnHit:Connect(collided)
		--Debris:AddItem(Hitbox, .5)
	end
	]]
end

functions.OrderAnimations = {
	--- Put Animations Here --
	[1] = _Combat_Caster.Right_Punch; -- right punch
	[2] = _Combat_Caster.Left_Punch; -- left punch
	[3] = _Combat_Caster.Head_Punch; -- head butt
	[4] = _Combat_Caster.Kick_Punch; -- kick
}
local tracks = {}


local CreateHitbox = functions.CreateHitbox

local function ClientFunction(Client, Caster, Order, bot)
	print("Client")
	if not clientVignette then
		clientVignette = require(Modules.Vignette)
	end
	--print(Client, Caster)
	local Character = Caster
	if not Caster:IsA("Model") and not bot then
		Character = Caster.Character
		--print("CHANGED CASTer")
	end
	if Character then
		local HRP = Character:WaitForChild("HumanoidRootPart")
		local Humanoid = Character:WaitForChild("Humanoid")
		task.defer(function()
			if Humanoid.Health ~= 0 then
				local punchSound = nil
				local time_pos = 0
				if Order == 4 then
					punchSound = script:WaitForChild("FinalPunchSound"):Clone()
					time_pos = .25
				else
					punchSound = script:WaitForChild("PunchSwoosh"):Clone()
				end
				punchSound.Parent = HRP
				punchSound:Play(time_pos)
				Debris:AddItem(punchSound, punchSound.TimeLength)
			end
		end)
		local rHand = Character:WaitForChild("RightHand")
		local lHand = Character:WaitForChild("LeftHand")

		if Order == 1 then
			CreateHitbox(Client, Caster, false,Order, rHand)
		elseif Order == 2 then
			CreateHitbox(Client, Caster, false,Order, lHand)
		elseif Order == 3 then
			CreateHitbox(Client, Caster, false,Order, lHand, rHand)
		elseif Order == 4 then 
			local rFoot = Character:WaitForChild("RightFoot")
			task.defer(function()
				local wind = script:WaitForChild("Wind"):Clone()
				wind.Transparency = 1
				wind.CFrame = HRP.CFrame*CFrame.new(0,-3.25,0)
				wind.Parent = Storage
				Tween(wind, {Transparency = .3}, .2)
				task.wait(.2)
				Tween(wind, {Transparency = 1, Size = wind.Size*Vector3.new(2,1,2)}, .5)
				Debris:AddItem(wind, .8)
			end)
			CreateHitbox(Client, Caster, true, Order, rFoot)
		end
	end

end

functions.Client = coroutine.create(ClientFunction)

functions.WrapOrder = function(Character, Order, MaxOrder, bot)
	if Character:FindFirstChild("Disable") then return end
	
	bot = bot or false
	Order += 1

	local Humanoid = Character:WaitForChild("Humanoid")

	if Order > MaxOrder then
		Order = 1
	end

	local Animation = functions.OrderAnimations[Order]
	if Animation then
		Humanoid:WaitForChild("Animator"):LoadAnimation(Animation):Play()
	end

	if not bot then
		mainActionEvent:FireServer("Combat Attack", Order, false)
	else
		local PlayersNearby = ActionService.CharacterService:FindPlayersNearby(Character, 650, true)
		for i, plr in pairs(PlayersNearby) do
			ClientEvent:FireClient(plr, "ClientAttack", Modules.CombatModule, Character, Order, false)
		end
	end
	

	return Order
end


return functions
