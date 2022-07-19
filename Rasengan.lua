--[[
///////// Made by remiel430
//// Discord: Rem#0040
]]


-- Services

local RP = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local GameStorage = workspace:WaitForChild("InGameStorage")
local PlayerStorage = GameStorage.PlayerStorage

--- Major Folders ---

local Events = RP:WaitForChild("Events")
local Modules = RP:WaitForChild("Modules")
local ReplicatedSounds = RP:WaitForChild("Sounds")

local Sounds = script:WaitForChild("Sounds")
local Meshes = script:WaitForChild("Meshes")
local Other = script:WaitForChild("Other")

--- Minor Folders ---

local Abilities = Modules.Abilities
local ActionEvents = Events.Action
local ActionServer = ActionEvents.Action
local ActionClient = ActionEvents.Client
local HitFunction = ActionEvents.Hit

local Animations = RP:WaitForChild("Animations")
local Anim_Combat = Animations.Combat
local Anim_Random = Animations.Random
local Anim_Abilities = Animations.Abilities
local Anim_Naruto = Anim_Abilities.Naruto
local Naruto_Rasengan = Anim_Naruto.Rasengan

local clientVignette
local CameraShaker = require(Modules.CameraShaker)
local CameraUtility = require(Modules.CameraUtil)

local ActionService = _G.import("ActionService")
local Tween = ActionService.Tween
local CreateHitbox = ActionService.CreateHitbox
local DetectBlock = ActionService.DetectBlock

local CharacterService = ActionService.CharacterService

local DisableActions = CharacterService.DisableActions


local RemoveSprintTrails = CharacterService.RemoveSprintTrails

local RockModule = ActionService.rock


local GlobalEvents = Events.Global
local CameraEvent = GlobalEvents.Camera

local getRay = ActionService.GetCast


local function ae(CFrame, Parent)
	task.defer(function()
		local AE = Meshes.AE:Clone()
		AE.Anchored = true
		AE.CFrame = CFrame
		AE.Transparency = 1
		AE.Parent = Parent
		Tween(AE, {Transparency = 0.15}, .3)
		task.wait(.7)
		Tween(AE, {Transparency = 1}, .6)
		Debris:AddItem(AE, 1)
	end)
end

local bindfunction = Other:WaitForChild("Function")

local function Rasengan(Client, Caster, Distinct)
	local Character :Model = Caster.Character or Caster.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local HRP = Character:WaitForChild("HumanoidRootPart")

	CharacterService.StopAllAnimations(Humanoid)

	if HRP:FindFirstChild("Disabled") then print("Error") return end

	--	print("Rasengann")
	if not clientVignette then
		clientVignette = require(Modules.Vignette)
	end
	local CameraUtility = require(Modules.CameraUtil)


	local PlayerPersonalFolder = PlayerStorage[Caster.UserId]
	local fxStorage = PlayerPersonalFolder.EffectsStorage

	local inActionLabel
	if Client == Caster then
		inActionLabel = DisableActions("Rasengan", Character)
	end

	local SmackSound = ReplicatedSounds.Smack:Clone()
	local OpeningSound = Sounds.Opening:Clone()

	local Rasengan = Meshes.Rasengan:Clone()
	local FX = Rasengan.FX
	local FX1 = Rasengan.FX1


	local HandWeld = Rasengan.Hand

	RemoveSprintTrails(Caster)

	local RasenganHitAnimation 	= Humanoid:WaitForChild("Animator"):LoadAnimation(Naruto_Rasengan.Hit)
	local RasenganHoldAnimation = Humanoid:WaitForChild("Animator"):LoadAnimation(Naruto_Rasengan.Hold)
	local RasenganOpenAnimation = Humanoid:WaitForChild("Animator"):LoadAnimation(Naruto_Rasengan.Open)

	local ShakeInstance
	task.defer(function()
		RasenganOpenAnimation:Play()
		OpeningSound.Parent = Rasengan
		OpeningSound:Play()

		if Client == Caster then
			local camShake = CameraUtility.camShake
			camShake:Start()
			ShakeInstance = camShake:ShakeSustain(CameraShaker.Presets.Earthquake)
		end
	end)

	local RasenganInfo = require(Character:WaitForChild("Info"))["Abilities"][2]
	local dom  = Character:WaitForChild("RightHand")

	Humanoid.WalkSpeed = 5

	local FX_Connection
	local pl = Rasengan.Attachment.PointLight
	local brightness, range = pl.Brightness, pl.Range
	pl.Brightness, pl.Range = 0, 0 

	local StartActionDelay = coroutine.create(function()
		if inActionLabel then
			task.wait(2)
			if inActionLabel then
				inActionLabel:Destroy()
			end
		end
	end)

	local function OpenRasengan()
		local originatedSize = Rasengan.Size
		Rasengan.Size = Vector3.new(.5,.5,.5)
		Rasengan.FX.Size = Vector3.new(.9,.9,.9)
		Rasengan.FX1.Size = Vector3.new(.9,.9,.9)
		Rasengan.Parent = fxStorage
		Rasengan.CFrame = dom.CFrame
		HandWeld.Parent = dom
		HandWeld.Part0 = dom
		Tween(Rasengan, {Size = originatedSize}, 1)
		Tween(FX, {Size = originatedSize+ Vector3.new(.2,.2,.2)}, 1)
		Tween(FX1, {Size = originatedSize+ Vector3.new(.2,.2,.2)}, 1)
		Tween(pl, {Brightness = brightness, Range = range}, .9)
		FX_Connection = RunService.Heartbeat:Connect(function()
			FX.Weld.C0 *= CFrame.Angles(0,.3,0.1)
			FX1.Weld.C0 *= CFrame.Angles(0,-.3,-0.1)
		end)

	end

	RasenganOpenAnimation:GetMarkerReachedSignal("Open"):Connect(OpenRasengan)
	local Other_HRP
	local OtherHumanoid
	local hitPart
	local function Stop()

		if Client == Caster then
			ShakeInstance:StartFadeOut(1)
		end

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


		RasenganHitAnimation:Play()
		Humanoid.WalkSpeed = 1

		task.defer(function()
			if hitPart then
				ae(dom.CFrame*CFrame.new(1.1,0,1.1), fxStorage)
				task.wait(.25)
				ae(dom.CFrame*CFrame.new(1.1,0,1.1), fxStorage)
				task.wait(.15)
				ae(Rasengan.CFrame*CFrame.new(1.1,0,1.1), fxStorage)
				task.wait(.2)
				ae(Rasengan.CFrame*CFrame.new(1.1,0,1.1), fxStorage)

			end
		end)

		for i,v in pairs(Rasengan:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end

		Tween(Rasengan, {Transparency = 1, Size = Vector3.new(.5,.5,.5)}, 1)
		Tween(FX, {Transparency = 1, Size = Vector3.new(.5,.5,.5)}, 1)
		Tween(FX1, {Transparency = 1, Size = Vector3.new(.5,.5,.5)}, 1)
		Tween(Rasengan.Attachment.PointLight, {Brightness = 0, Range = 0}, 1)

		task.delay(.6, function() Rasengan.Attachment.Wave.Enabled = false end)
		task.delay(1, function() FX_Connection:Disconnect() end)

		local openTween = Tween(OpeningSound, {Volume = 0}, .7, nil)
		openTween.Completed:Connect(function()
			OpeningSound:Destroy()
		end)

		Debris:AddItem(Rasengan, 1.8)

		RasenganHoldAnimation:Stop()
		RasenganOpenAnimation:Stop()

		StartActionDelay()

		task.wait(1)

		Humanoid.WalkSpeed = 16

	end
	local hitPlayer = false
	RasenganOpenAnimation:GetMarkerReachedSignal("Attack"):Connect(function()

		RasenganHoldAnimation:Play()
		Humanoid.WalkSpeed = 30

		local Hitbox = CreateHitbox(Vector3.new(3,3,3), Rasengan)
		Hitbox.Touched:Connect(function(hit)
			if hitPlayer then return end
			--- Sets Character Variables

			local otherCharacter 	= hit.Parent
			local safeZone 			= otherCharacter:FindFirstChild("SafeZone")
			Other_HRP 				= otherCharacter:FindFirstChild("HumanoidRootPart")
			OtherHumanoid 			= otherCharacter:FindFirstChild("Humanoid")
			local isLog 			= otherCharacter:FindFirstChild("Log")
			--- Checks If Dead Or Invince

			if not OtherHumanoid or OtherHumanoid.Health == 0 or safeZone then return end
			task.defer(function() bindfunction:InvokeServer("CheckForBot", otherCharacter, 1) end)
			--- Sets Client Variables

			hitPart = hit
			hitPlayer = true

			--- Character Cframe Facing Eachother ---

			if not isLog then
				HRP.CFrame = CFrame.new(HRP.Position, Other_HRP.Position) --- Caster
				Other_HRP.CFrame = CFrame.new(Other_HRP.Position, HRP.Position) --- Casted
			end

			--- Special FX ---

			ActionService.Stun(otherCharacter, 5, 1)
			Stop()

		end)


		task.wait(6)

		--- If Player Hasn't Hit Anyone In The Past (6) Seconds

		if not hitPlayer then
			hitPlayer = true -- Disable Further HitTakes 
			ActionService.Stun(Character, 5, 1)
			Stop()
		end
	end)

	RasenganHitAnimation:GetMarkerReachedSignal("Hit"):Connect(function()
		if hitPart and hitPart.Parent and hitPart.Parent:FindFirstChild("Humanoid") then
			SmackSound.Parent = dom
			SmackSound:Play()
			Debris:AddItem(SmackSound, 2)
			OtherHumanoid = hitPart.Parent:WaitForChild("Humanoid")
			--local Other_HRP = hitPart.Parent:WaitForChild("HumanoidRootPart")


			task.defer(function()
				local punchFX = Rasengan:WaitForChild("Attachment"):Clone()
				local EmitMultiplier = 1.5
				punchFX.PointLight:Destroy()
				local hitInst = Instance.new("Part"); hitInst.Transparency = 1; hitInst.Anchored = true; hitInst.CanCollide = false; hitInst.CanQuery = false; hitInst.CanTouch = false
				hitInst.CFrame = dom.CFrame
				punchFX.Parent = hitInst
				hitInst.Parent = fxStorage
				for i,v in pairs(punchFX:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount")*EmitMultiplier)
					end
				end
				Debris:AddItem(hitInst, 1)			
			end)

			local OtherCharacter = OtherHumanoid.Parent
			if OtherCharacter and OtherCharacter == Client.Character then
				clientVignette(3)
				task.defer(function()
					local camShake = CameraUtility.camShake
					camShake:Start()
					camShake:Shake(CameraShaker.Presets.Explosion)
					task.wait(1)
					camShake:Stop()
				end)
			end

			if Client == Caster then
				--- Sends Server Hit Event		
				clientVignette(3)
				task.defer(function()
					local camShake = CameraUtility.camShake
					camShake:Start()
					camShake:Shake(CameraShaker.Presets.Explosion)
					task.wait(1)
					camShake:Stop()
				end)


			end

			if Caster.Character and OtherCharacter.Parent then
				local ModelClone = Meshes:WaitForChild("Impact"):Clone()
				local oldWS = OtherHumanoid.WalkSpeed
				OtherHumanoid.WalkSpeed = 0
				local TrackAnimation = OtherHumanoid:WaitForChild("Animator"):LoadAnimation(Naruto_Rasengan.Push)

				local ray = getRay(Caster.Character, Character, 20, {fxStorage, ModelClone, OtherCharacter, Character:FindFirstChildOfClass("Tool")})-- or casterHRP.CFrame.LookVector * 10

				--[[
				local p = Instance.new("Part", workspace)
				p.Anchored = true
				p.CanCollide = false
				p.Position = ray
				]]

				local rotation = Other_HRP.CFrame - Other_HRP.Position
				Tween(Other_HRP, {CFrame = rotation + ray}, .3, Enum.EasingStyle.Linear)
				Other_HRP.Anchored = true
				--Tween_Server:InvokeServer(HRP, {CFrame = rotation + ray}, "Knockback")

				---/// IMPACT \\---

				task.defer(function()



					local sds = ModelClone:WaitForChild("SideBeams")	
					local sd1, sd2, sd3, sd4 = sds:WaitForChild("SideBeam"), sds:WaitForChild("SideBeam1"), sds:WaitForChild("SideBeam2"), sds:WaitForChild("SideBeam3")		
					local bigRing, smallRing = ModelClone:WaitForChild("BigRing"), ModelClone:WaitForChild("SmallRing")
					local fd, fd1 = ModelClone:WaitForChild("fd"), ModelClone:WaitForChild("fd1")
					local smash = ModelClone:WaitForChild("Smash")

					for i,v in pairs(ModelClone:GetDescendants()) do
						if v:isA("BasePart") then
							v.Transparency = 1
						end
					end

					local b1, b2 = bigRing.Size, smallRing.Size
					bigRing.Size -= Vector3.new(0,8,8)
					smallRing.Size -= Vector3.new(0,2,2)

					local cfr = Other_HRP.CFrame

					ModelClone:SetPrimaryPartCFrame(cfr)
					ModelClone.Parent = fxStorage --; print(fxStorage)

					sds:SetPrimaryPartCFrame(sds.PrimaryPart.CFrame * CFrame.Angles(math.rad(180),math.rad(-90),math.rad(180)))

					Tween(sd1, {Transparency = sd1:GetAttribute("Trans"), Size = sd1.Size + Vector3.new(0,.4,8)}, .3)
					Tween(sd2, {Transparency = sd2:GetAttribute("Trans"), Size = sd2.Size + Vector3.new(0,.4,8)}, .3)

					Tween(bigRing, {Transparency = bigRing:GetAttribute("Trans"), Size = b1}, .2)
					Tween(smallRing, {Transparency = smallRing:GetAttribute("Trans"), Size = b2}, .2)

					local connection = RunService.Heartbeat:Connect(function()
						fd.CFrame, fd1.CFrame = fd.CFrame * CFrame.Angles(0,math.rad(5),0), fd1.CFrame * CFrame.Angles(0,math.rad(5), 0)
						smash.CFrame = smash.CFrame * CFrame.Angles(0,math.rad(5),0)
						smallRing.CFrame, bigRing.CFrame = smallRing.CFrame * CFrame.Angles(0,0,math.rad(-3.5)), bigRing.CFrame * CFrame.Angles(0,0,math.rad(-3.5))
					end)

					task.wait(.15)

					task.delay(.5, function()
						Tween(sd1, {Transparency = 1, Size = sd1.Size - Vector3.new(0,.4,2)}, .15)
						Tween(sd2, {Transparency = 1, Size = sd2.Size - Vector3.new(0,.4,2)}, .15)
						task.wait(.15)
						Tween(sd3, {Transparency = 1, Size = sd1.Size - Vector3.new(0,.4,2)}, .15)
						Tween(sd4, {Transparency = 1, Size = sd2.Size - Vector3.new(0,.4,2)}, .15)

						Tween(fd, {Transparency = 1, Size = fd.Size - Vector3.new(0,.2,.2)}, .45)
						Tween(fd1, {Transparency = 1, Size = fd1.Size + Vector3.new(0,.2,.2)}, .45)


						Tween(bigRing, {Transparency = 1, Size = b1 + Vector3.new(0,.4,.4)}, .2)
						Tween(smallRing, {Transparency = 1, Size = b2 + Vector3.new(0,.4,.4)}, .2)

						task.wait(.1)

						Tween(smash, {Transparency = 1, Size = smash.Size - Vector3.new(0,.4,.4)}, .15)

						task.wait(.3)

						connection:Disconnect()

					end)

					fd.Size -= Vector3.new(0,1,1); fd1.Size -= Vector3.new(0,1,1); smash.Size -= Vector3.new(0,1,1)

					Tween(fd, {Transparency = fd:GetAttribute("Trans"), Size = fd.Size + Vector3.new(0,1,1)}, .2)
					Tween(fd1, {Transparency = fd1:GetAttribute("Trans"), Size = fd1.Size + Vector3.new(0,1,1)}, .2)
					Tween(smash, {Transparency = smash:GetAttribute("Trans"), Size = smash.Size + Vector3.new(0,1,1)}, .2)
					Tween(sd3, {Transparency = sd3:GetAttribute("Trans"), Size = sd3.Size + Vector3.new(0,.4,8)}, .1)
					Tween(sd4, {Transparency = sd4:GetAttribute("Trans"), Size = sd4.Size + Vector3.new(0,.4,8)}, .1)





				end)

				--- OTHER ---

				TrackAnimation:Play() 
				task.wait(.3)
				Other_HRP.Anchored = false

				OtherHumanoid.WalkSpeed = oldWS

				TrackAnimation:Stop()
				--BodyPosition:Destroy()
			end


			if Client == Caster then
				HitFunction:InvokeServer(OtherCharacter, RasenganInfo.Damage, "Ability")
			end

		end

		-- unpause this code!
		--StartActionDelay()
	end)

end

local Module = {}

Module.Server = function() end
Module.Client = coroutine.create(Rasengan)


return Module
