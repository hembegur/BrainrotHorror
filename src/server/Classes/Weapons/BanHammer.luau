local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CloseRangeWeapon = require(script.Parent.CloseRangeWeapon)

local BanHammer = {}
BanHammer.__index = BanHammer
setmetatable(BanHammer, { __index = CloseRangeWeapon })

function BanHammer.new()
	local template = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Weapons"):WaitForChild("Ban Hammer")
	assert(template:IsA("Tool"), "Ban Hammer must be a Tool")
	local weapon = CloseRangeWeapon.new({
		ToolTemplate = template,
		HitboxSize = Vector3.new(5, 5, 6),
		Damage = 35,
	})
	return setmetatable(weapon, BanHammer)
end

return BanHammer
