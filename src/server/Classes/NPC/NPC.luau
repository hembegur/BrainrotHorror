local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local baseCurrStats = ServerScriptService.BaseStats
local Brainrots = require(script.Parent.Parent.Brainrot)
local npc = {}
npc.__index = npc

export type Config = {
	Model: Model?,
	Name: string?,
	Health: number?,
	Damage: number?,
	Weapon: any?,
	WalkSpeed: number?,
	AggroRange: number?,
	Animations: { [string]: Animation }?,
}

export type npc = typeof(setmetatable(
	{} :: {
		Model: Model?,
		Name: string?,
		Health: number?,
		Damage: number?,
		Weapon: any?,
		WalkSpeed: number?,
		AggroRange: number?,
		Animations: { [string]: Animation }?,
		_hum: Humanoid?,
		_connections: { RBXScriptConnection },
		_destroyed: boolean,
		_hasBrainrot: boolean,
		_spawnPos: Vector3,
	},
	npc
))

local random = Random.new()
local function generateModel()
	local clone = ReplicatedStorage.Models.NPCTemplate:Clone() :: Model
	local avatars = ReplicatedStorage.Models.NPCAvatars:GetChildren()
	local avatar = avatars[random:NextInteger(1, #avatars)]
	for _, p in pairs(avatar:GetChildren()) do
		if not (p:IsA("Part") or p:IsA("MeshPart") or p:IsA("Humanoid")) then
			p:Clone().Parent = clone
		end
	end

	return clone
end
local function getRandomName()
	local names = require(script.Parent.NPCNames)
	return names[random:NextInteger(1, #names)]
end

function npc.new(config: Config?): npc
	local resolved: Config = config or {}
	local self = setmetatable({
		Model = resolved.Model or generateModel(),
		Name = resolved.Name or getRandomName(),
		Health = resolved.Health or 100,
		WalkSpeed = resolved.WalkSpeed or 10,
		Weapon = resolved.Weapon,
		AggroRange = resolved.AggroRange or 30,
		Animations = resolved.Animations or {} :: { AnimationClip },
		_connections = {} :: { RBXScriptConnection },
		_destroyed = false,
		_hasBrainrot = false,
		_spawnPos = Vector3.new(0, 0, 0),
	}, npc)
	for _, p in pairs(self.Model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CollisionGroup = "Brainrots"
		end
	end
	self.Model.Name = self.Name
	self.Model.Parent = workspace
	self._hum = self.Model.Humanoid :: Humanoid
	self._hum.MaxHealth = self.Health
	self._hum.Health = self.Health
	self._hum.WalkSpeed = self.WalkSpeed

	table.insert(
		self._connections,
		self._hum.Died:Connect(function()
			self:Destroy()
		end)
	)

	return self
end

function npc.SetCFrame(self: npc, cframe: CFrame)
	self.Model:PivotTo(cframe)
	self._spawnPos = cframe.Position
end

function npc.GoToSpawn(self: npc)
	local spawns = workspace.Map.NPCs.NPCSpawns:GetChildren()
	self.Model:PivotTo(spawns[random:NextInteger(1, #spawns)].CFrame)
	self._spawnPos = self.Model:GetPivot()
end

function npc.GetBrainrot(self: npc)
	self._hasBrainrot = true
end

function npc.StealBrainrot(self: npc)
	local hum = self._hum :: Humanoid
	local hrp = self.Model.HumanoidRootPart :: Part
	local walkAnim = hum.Animator:LoadAnimation(
		(self.Animations and self.Animations["Walk"]) or ReplicatedStorage.Animations.Brainrot.WalkAnimation
	) :: AnimationTrack

	table.insert(
		self._connections,
		RunService.Heartbeat:Connect(function()
			if baseCurrStats.BrainrotCount.Value == 0 then
				return
			end

			local shortestDis = 9999
			local chosenChar = nil
			for _, char in pairs(workspace.Map.PlayerCharacters:GetChildren()) do
				local dis = (hrp.Position - char.HumanoidRootPart.Position).Magnitude
				if dis <= self.AggroRange and dis < shortestDis then
					chosenChar = char
				end
			end

			if chosenChar then
				--attack
				walkAnim:Stop()
			else
				--steal breainrot
				if not walkAnim.IsPlaying then
					walkAnim:Play()
				end

				if not self._hasBrainrot then
					local target = workspace.Map.PlayerBase.Middle.Position
					hum:MoveTo(target)

					if (hrp.Position - target).Magnitude < 20 then
						self:GetBrainrot()
					end
				else
					local target = self._spawnPos
					hum:MoveTo(target)

					if (hrp.Position - target).Magnitude < 10 then
						self:Destroy()
					end
				end
			end
		end)
	)
end

function npc.Destroy(self: npc)
	if self._destroyed then
		return
	end
	self._destroyed = true
	for _, connection in self._connections do
		connection:Disconnect()
	end
	self.Model:Destroy()
	table.clear(self._connections)
end

return npc
