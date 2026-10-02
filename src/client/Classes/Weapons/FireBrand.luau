local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CloseRangeWeapon = require(script.Parent.Parent.CloseRangeWeapon)

local FireBrand = {}
FireBrand.__index = FireBrand
setmetatable(FireBrand, { __index = CloseRangeWeapon })

function FireBrand.new()
	local template = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Weapons"):WaitForChild("Fire Brand")
	assert(template:IsA("Tool"), "Fire Brand must be a Tool")
	local weapon = CloseRangeWeapon.new({
		ToolTemplate = template,
		HitboxSize = Vector3.new(4, 5, 7),
		Damage = 50,
	})
	return setmetatable(weapon, FireBrand)
end

return FireBrand
