local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CloseRangeWeapon = require(script.Parent.Parent.CloseRangeWeapon)

local SlapHand = {}
SlapHand.__index = SlapHand
setmetatable(SlapHand, { __index = CloseRangeWeapon })

function SlapHand.new()
	local template = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Weapons"):WaitForChild("Slap Hand")
	assert(template:IsA("Tool"), "Slap Hand must be a Tool")
	local weapon = CloseRangeWeapon.new({
		ToolTemplate = template,
		HitboxSize = Vector3.new(5, 5, 4),
		Damage = 20,
	})
	return setmetatable(weapon, SlapHand)
end

return SlapHand
