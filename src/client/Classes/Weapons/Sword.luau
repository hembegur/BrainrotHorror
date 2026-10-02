local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CloseRangeWeapon = require(script.Parent.Parent.CloseRangeWeapon)

local Sword = {}
Sword.__index = Sword
setmetatable(Sword, { __index = CloseRangeWeapon })

function Sword.new()
	local template = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Weapons"):WaitForChild("Sword")
	assert(template:IsA("Tool"), "Sword must be a Tool")
	local weapon = CloseRangeWeapon.new({
		ToolTemplate = template,
		HitboxSize = Vector3.new(4, 5, 5),
		Damage = 15,
	})
	return setmetatable(weapon, Sword)
end

return Sword
