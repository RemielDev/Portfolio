--[[
///////// Made by remiel430
//// Discord: Rem#0040
]]


-- Services

local ActionService = _G.import("ActionService")
local Tween = ActionService.Tween

local white = Color3.new(0.870588, 0.870588, 0.870588)

return function(Model, time, isDeceasing, parent)
	if not Model then return end
	if isDeceasing then
		for i,v in pairs(Model:GetDescendants()) do
			task.defer(function()
				if v:isA("BasePart") then
					v.Material = Enum.Material.Neon
					Tween(v, {Transparency = 1, Color = white}, .6)
				end
				if v:isA("Decal") or v:isA("Texture") then
					Tween(v, {Transparency = 1, Color3 = white}, .6)
				end
				if v:isA('Shirt') or v:isA("Pants") then
					Tween(v, {Color3 = white}, .1)
				end
				if v:isA("Mesh") then
					v.MeshType = Enum.MeshType.FileMesh
				end
			end)
		end
		task.wait(time)
		Model:Destroy()
	else
		local props = {}
		for i,v in pairs(Model:GetDescendants()) do
			task.defer(function()
				if v:isA("BasePart") then
					props[v] = {Transparency = v.Transparency, Color = v.Color}
					v.Material = Enum.Material.Neon
					v.Transparency = 1
					v.Color = white

				end
				if v:isA("Decal") or v:isA("Texture") then
					props[v] = {Transparency = v.Transparency, Color3 = v.Color3}
					v.Transparency = 1
					v.Color3 = white
				end
				if v:isA('Shirt') or v:isA("Pants") then
					props[v] = {Color3 = v.Color3}
				end
				if v:isA("Mesh") then
					props[v] = {v.MeshType}
					v.MeshType = Enum.MeshType.FileMesh
				end
			end)
		end
		
		task.wait(.1)
		Model.Parent = parent
		for i,v in pairs(Model:GetDescendants()) do
			local vProps = props[v]
			if vProps then
				if v:isA("Mesh") then
					v.MeshType = props[v][1]
				else

					Tween(v, vProps, time)
				end
			end
		end
		
		task.wait(time)
	end
end
