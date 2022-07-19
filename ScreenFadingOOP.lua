--[[
///////// Made by remiel430
//// Discord: Rem#0040
]]


-- Services

local RP = game:GetService("ReplicatedStorage")
local Modules = RP:WaitForChild("Modules")
local ActionService = _G.import("ActionService")
local Tween = ActionService.Tween

local plr = game.Players.LocalPlayer
local playergui = plr:WaitForChild("PlayerGui")

local fade_module = {Configure = {};}

function fade_module.new()
	
	local fx = playergui:WaitForChild("Effects")
	local frame = fx.Fade
	frame.Size = UDim2.new(1,0,1,0)
	frame.Position = UDim2.new(.5,0,.5,0)
	
	local self = setmetatable(fade_module, {})
	self.frame = frame
	self.running = false
	self._tween = nil
	
	
	return self
end

function fade_module:Enable(time)
	time = time or 1/3
	self.running = true
	self._tween = Tween(self.frame, {BackgroundTransparency = 0}, time)
	self._tween.Completed:Connect(function() self.running = false end)
end

function fade_module:Disable(time)
	if self.running then return end
	time = time or 1/3
	self._tween = Tween(self.frame, {BackgroundTransparency = 1}, time)
	self._tween.Completed:Connect(function() self.running = false end)
end

function fade_module:ForceDisable(time)
	if self.running then self._tween:Cancel() end
	time = time or 1/3
	self._tween = Tween(self.frame, {BackgroundTransparency = 1}, time)
	self._tween.Completed:Connect(function() self.running = false end)
end

function fade_module:FadeCycle(time)
	if self.running then return end
	time = time or 1
	self._tween = Tween(self.frame, {BackgroundTransparency = 0}, time/3)
	self._tween.Completed:Connect(function() self.running = false end)
	task.delay(time/2, function()
		self._tween = Tween(self.frame, {BackgroundTransparency = 1}, time/3)
		self._tween.Completed:Connect(function() self.running = false end)
	end)
end

function fade_module:Destroy()
	self.frame:Destroy()
	self.frame = nil
	self.running = nil
	if self._tween then
		self._tween:Cancel()
	end
	self._tween = nil
	return true
end

return fade_module
