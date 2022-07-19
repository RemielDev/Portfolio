--[[
///////// Made by remiel430
//// Discord: Rem#0040
]]


-- Services

local ReplicatedFirst = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local plr = game.Players.LocalPlayer
local cam = workspace.CurrentCamera



local loadingScreen = script:WaitForChild("Loading Screen")
local PlayButton = loadingScreen.Play
local SkipButton = loadingScreen.Skip

local vignette = loadingScreen.Vignette
loadingScreen.Parent = plr:WaitForChild("PlayerGui")
PlayButton.Position = PlayButton.Position + UDim2.new(0,0,1,0)
SkipButton.Position = SkipButton.Position + UDim2.new(0,0,1,0)
local warning = loadingScreen.Warning

local pbSize = PlayButton.Size

local connection
local speed, range 		= 1.4, 0.2
local play :boolean		= true
local skipped : boolean = false

local barBase			= loadingScreen.Bar
local barBG 			= barBase.Clipping
local bar 				= barBG.Top
local txt 				= barBase.txt

local RPLogo = loadingScreen.Logo


repeat task.wait() 
	cam.CameraType = Enum.CameraType.Scriptable
until cam.CameraType == Enum.CameraType.Scriptable and #workspace:GetDescendants() > 20

local Modules = ReplicatedStorage:WaitForChild("Modules")

repeat task.wait()
	
until #Modules:GetChildren() > 10

local Dummies = workspace:WaitForChild("Dummies")
local Animations = ReplicatedStorage:WaitForChild("Animations"):GetDescendants()
local Fighting = Dummies:WaitForChild("Fighting"):GetDescendants()
local ProgressDummies = Dummies:WaitForChild("Progress"):GetChildren()
local TrainingLogs = Dummies:WaitForChild("TrainingLogs"):GetChildren()
local guis = plr:WaitForChild("PlayerGui"):GetDescendants()
Modules = Modules:GetDescendants()

local blur = script:WaitForChild("Blur")
blur.Parent = game.Lighting


connection = runService.Heartbeat:Connect(function()
	local NonEssentials = workspace:FindFirstChild("NonEssentials")
	local CamView = NonEssentials:FindFirstChild("Camera View")
	
	if play then
		if CamView then
			cam.CameraType = Enum.CameraType.Scriptable
			local sin = math.sin(tick()*speed) * range
			local cos = math.cos(tick()*speed)*range
			cam.CFrame = CamView.CFrame + Vector3.new(0, sin, cos)
		end
	else
		connection:Disconnect()
		repeat
			task.wait()
			cam.CameraType = Enum.CameraType.Custom
		until cam.CameraType == Enum.CameraType.Custom
	end
end)


local function Tween(Item, Params, time, style, compFunction)
	local ts = game:GetService("TweenService")
	style = style or Enum.EasingStyle.Linear
	local info = TweenInfo.new(time, style)
	local track = ts:Create(Item, info, Params)
	track:Play()
	if compFunction then
		track.Completed:Connect(compFunction)
	end
end

local Events = ReplicatedStorage:WaitForChild("Events")
local CustomizeEvents = Events:WaitForChild("Customization")
local ServerEvent = CustomizeEvents:WaitForChild("Server")

local ContentProviderService = game:GetService("ContentProvider")


--[[
local EnabledValue = {}
for i,v in pairs(plr:WaitForChild("PlayerGui"):GetChildren()) do
	if v:IsA("ScreenGui") and v ~= loadingScreen then
	EnabledValue[v] = v.Enabled
	v.Enabled = false
		
	end
end
]]

local totalAssets = #Modules + #TrainingLogs + #ProgressDummies + #Fighting + #guis + #Animations
local ast = {Modules, TrainingLogs, ProgressDummies, Fighting, guis, Animations}

local tbl_idx = 0
local function preload(Placement, item)
	if not skipped then
		Placement += tbl_idx
		local amt = Placement/totalAssets
		txt.Text = "Assets: "..Placement.." / "..totalAssets
		bar.Size = UDim2.new(amt,0,1,0)
	end
	ContentProviderService:PreloadAsync({item})
end


local clickSound = loadingScreen:WaitForChild("click")


local playDebounce = false
local function Complete()
	if not playDebounce then
		playDebounce = true
		clickSound:Play()
		Tween(PlayButton, {Position = PlayButton.Position + UDim2.new(0,0,1,0)}, .5)
		Tween(vignette, {ImageTransparency = 1}, .5)
		Tween(warning, {TextTransparency = 1, TextStrokeTransparency = 1}, .5)
		Tween(RPLogo, {ImageTransparency = 1}, .5)

		task.wait(.5)

		local Events = ReplicatedStorage:WaitForChild("Events")
		local CustomizationEvents = Events:WaitForChild("Customization")
		local ServerEvent = CustomizeEvents.Server

		Tween(blur, {Size = 0}, .5)
		task.wait(.5)
		play = false
		loadingScreen:Destroy()
		blur:Destroy()
		local autoLoad = ReplicatedStorage:WaitForChild("GameSettings"):WaitForChild("AutoSelectCharacter").Value

		--[[
		for i,v in pairs(plr:WaitForChild("PlayerGui"):GetChildren()) do
			if v:IsA("ScreenGui") and v ~= loadingScreen then
				v.Enabled = EnabledValue[v]
			end
		end
		]]
		
		if not autoLoad then
			ServerEvent:FireServer("Begin Customization")
		else
			ServerEvent:FireServer("Load")
			StarterGui:SetCore("ResetButtonCallback", true)
		end
		
		
	end
end

Tween(SkipButton, {Position = SkipButton.Position - UDim2.new(0,0,1,0)}, .5)

PlayButton.MouseEnter:Connect(function()
	if playDebounce then return end
	clickSound:Play()
	PlayButton:TweenSize(pbSize + UDim2.new(.01,0,.01,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.2, true)

end)
PlayButton.MouseLeave:Connect(function()
	if playDebounce then return end
	clickSound:Play()
	PlayButton:TweenSize(pbSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.2, true)

end)
PlayButton.Activated:Connect(Complete)

SkipButton.Activated:Connect(function()
	if not skipped then
		skipped = true
		Tween(SkipButton, {Position = SkipButton.Position + UDim2.new(0,0,1,0)}, .5)
		Tween(barBase, {Position = barBase.Position + UDim2.new(0,0,1,0)}, .5)
		Tween(PlayButton, {Position = PlayButton.Position - UDim2.new(0,0,1,0)}, .5)
	end
end)

for _ : number?,tbl in pairs(ast) do
	for i,v in pairs(tbl) do
		preload(i, v)
	end
	tbl_idx += #tbl
end
task.wait(1)
if not skipped then
	
	Tween(barBase, {Position = barBase.Position + UDim2.new(0,0,1,0)}, .5)
	Tween(PlayButton, {Position = PlayButton.Position - UDim2.new(0,0,1,0)}, .5)
	Tween(SkipButton, {Position = SkipButton.Position - UDim2.new(0,0,-1,0)}, .5)
end
