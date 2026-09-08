local Players = game:GetService("Players")

Players.LocalPlayer.CharacterAdded:Connect(function(char: Model)
	local test = require(script.Classes.CloseRangeWeapon).new()
	test:GiveTo(Players.LocalPlayer)
end)

task.wait(5)
local warninghb = require(script.Classes.WarningHitbox)
local new = warninghb.new({
	HitboxCFrame = workspace.Part.CFrame,
})
new:Start()
