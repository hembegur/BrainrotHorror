local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hitbox = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Classes"):WaitForChild("Hitbox"))
local packets = require(ReplicatedStorage.Shared.Modules.Packets)

local WarningHitbox = {}
WarningHitbox.__index = WarningHitbox

export type Config = {
	HitboxCFrame: CFrame?,
	HitboxSize: Vector3?,
	Startup: number?,
	Linger: number?,
	VisualCFrame: CFrame?,
	VisualSize: Vector3?,
	Damage: number?,
}

export type WarningHitbox = typeof(setmetatable(
	{} :: {
		HitboxCFrame: CFrame?,
		HitboxSize: Vector3?,
		Startup: number?,
		Linger: number?,
		Damage: number?,
		VisualCFrame: CFrame?,
		VisualSize: Vector3?,
		_visualPart: Part?,
		_hitbox: any?,
		_destroyed: boolean?,
	},
	WarningHitbox
))

function WarningHitbox.new(config: Config?): WarningHitbox
	local resolved: Config = config or {}
	local self = setmetatable({
		HitboxCFrame = resolved.HitboxCFrame or CFrame.new(0, 0, 0),
		HitboxSize = resolved.HitboxSize or Vector3.new(5, 5, 5),
		Startup = resolved.Startup or 1.5,
		Linger = resolved.Linger or 0.5,
		Damage = resolved.Damage or 10,
		VisualCFrame = resolved.VisualCFrame or resolved.HitboxCFrame,
		VisualSize = resolved.VisualSize or Vector3.new(5, 5, 5),
		_visualPart = nil,
		_hitbox = nil,
		_destroyed = false,
	}, WarningHitbox)
	self.VisualSize = self.HitboxSize / Vector3.new(1, 5, 1)

	return self
end

function WarningHitbox.Start(self: WarningHitbox)
	local visualPart = Instance.new("Part")
	visualPart.Parent = workspace
	visualPart.Transparency = 0.5
	visualPart.Color = Color3.fromRGB(255, 0, 0)
	visualPart.CanCollide = false
	visualPart.Size = self.VisualSize
	visualPart.CFrame = self.HitboxCFrame
	visualPart.Anchored = true

	local hitbox = Hitbox.new(visualPart, {
		Size = self.HitboxSize,
		Offset = self.HitboxOffset,
		Visualize = true,
	})

	hitbox.OnHit:Connect(function(_model, hitHumanoid)
		local damage = self.Damage
		packets.DealDamage:Fire(hitHumanoid, damage)
	end)
	self._hitbox = hitbox

	task.spawn(function()
		task.wait(self.Startup - 0.5)
		visualPart.Color = Color3.fromRGB(255, 255, 255)
		visualPart.Transparency = 0
		hitbox:Start(self.Linger)
	end)
end

function WarningHitbox.Destroy(self: WarningHitbox)
	if self._destroyed then
		return
	end
	self._destroyed = true
	self._hitbox:Destroy()
	for _, connection in self._connections do
		connection:Disconnect()
	end
	table.clear(self._connections)
end

return WarningHitbox
