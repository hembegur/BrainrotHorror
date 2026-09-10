local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Hitbox = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Classes"):WaitForChild("Hitbox"))
local packets = require(ReplicatedStorage.Shared.Modules.Packets)

local WarningHitbox = {}
WarningHitbox.__index = WarningHitbox

export type Config = {
	HitboxCFrame: CFrame?,
	HitboxSize: Vector3?,
	Startup: number?,
	Linger: number?,
	VisualSize: Vector3?,
	Damage: number?,
	WarningWindow: number?,
	Filter: { Model }?,
}

export type WarningHitbox = typeof(setmetatable(
	{} :: {
		HitboxCFrame: CFrame?,
		HitboxSize: Vector3?,
		Startup: number?,
		Linger: number?,
		Damage: number?,
		VisualSize: Vector3?,
		Filter: { Model }?,
		WarningWindow: number?,
		_visualPart: Part?,
		_hitbox: any?,
		_destroyed: boolean?,
		_connections: { RBXScriptConnection }?,
	},
	WarningHitbox
))

function WarningHitbox.new(config: Config?): WarningHitbox
	local resolved: Config = config or {}
	local self = setmetatable({
		HitboxCFrame = resolved.HitboxCFrame or CFrame.new(0, 0, 0),
		HitboxSize = resolved.HitboxSize or Vector3.new(5, 5, 5),
		Startup = resolved.Startup or 1,
		Linger = resolved.Linger or 0.2,
		Damage = resolved.Damage or 10,
		WarningWindow = resolved.WarningWindow or 0.4,
		VisualSize = resolved.VisualSize or Vector3.new(5, 5, 5),
		Filter = resolved.Filter or {},
		_connections = {} :: { RBXScriptConnection },
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
	visualPart.Material = Enum.Material.Neon
	self._visualPart = visualPart

	local hitbox = Hitbox.new(visualPart, {
		Size = self.HitboxSize,
		Offset = CFrame.new(0, self.HitboxSize.Y * 2 / 5, 0),
		Visualize = false,
		Filter = self.Filter,
	})

	table.insert(
		self._connections,
		hitbox.OnHit:Connect(function(_model, hitHumanoid)
			local damage = self.Damage
			packets.DealDamage:Fire(hitHumanoid, damage)
		end)
	)
	self._hitbox = hitbox

	task.spawn(function()
		task.wait(self.Startup - self.WarningWindow)

		TweenService:Create(visualPart, TweenInfo.new(0.3), {
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0,
		}):Play()

		task.wait(self.WarningWindow)
		hitbox:Start(self.Linger)

		TweenService:Create(visualPart, TweenInfo.new(0.5), {
			Transparency = 1,
		}):Play()

		task.wait(self.Linger + 0.5)
		self:Destroy()
	end)
end

function WarningHitbox.Destroy(self: WarningHitbox)
	if self._destroyed then
		return
	end
	self._destroyed = true
	self._hitbox:Destroy()
	self._visualPart:Destroy()
	for _, connection in self._connections do
		connection:Disconnect()
	end
	table.clear(self._connections)
end

return WarningHitbox
