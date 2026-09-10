local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local StudioScriptDebugEventListener = game:GetService("StudioScriptDebugEventListener")
local baseCurrStats = ServerScriptService.BaseStats
local Brainrots = require(script.Parent.Parent.Brainrot)
local packets = require(ReplicatedStorage.Shared.Modules.Packets)
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
	AttackCD: number?,
	AttackRange: number?,
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
		AttackCD: number?,
		AttackRange: number?,
		_hum: Humanoid?,
		_connections: { RBXScriptConnection },
		_destroyed: boolean,
		_hasBrainrot: boolean,
		_spawnPos: Vector3,
		_stolenBrainrot: any?,
		_lastAttack: number?,
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
	local now = os.clock()
	local self = setmetatable({
		Model = resolved.Model or generateModel(),
		Name = resolved.Name or getRandomName(),
		Health = resolved.Health or 100,
		WalkSpeed = resolved.WalkSpeed or 20,
		Weapon = resolved.Weapon or ReplicatedStorage.Models.Weapons.Sword,
		AggroRange = resolved.AggroRange or 20,
		Animations = resolved.Animations or {} :: { AnimationClip },
		AttackCD = resolved.AttackCD or 2,
		AttackRange = resolved.AttackRange or 7,
		_connections = {} :: { RBXScriptConnection },
		_destroyed = false,
		_hasBrainrot = false,
		_spawnPos = Vector3.new(0, 0, 0),
		_stolenBrainrot = nil,
		_lastAttack = now,
	}, npc)
	self.Model.Name = self.Name
	self.Model.Parent = workspace.Map.NPCs.EnemyNPCs
	self._hum = self.Model.Humanoid :: Humanoid
	self._hum.MaxHealth = self.Health
	self._hum.Health = self.Health
	self._hum.WalkSpeed = self.WalkSpeed
	self.Weapon:Clone().Parent = self.Model

	for _, p in pairs(self.Model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CollisionGroup = "Brainrots"
			p:SetNetworkOwner(nil)
		end
	end

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
	for _, br in pairs(Brainrots.InBase) do
		if not br._destroyed then
			br.Model.BillboardGuis.StolenGui.Enabled = true
			self._stolenBrainrot = br
			break
		end
	end
end

function npc.StealBrainrot(self: npc)
	local hum = self._hum :: Humanoid
	local hrp = self.Model.HumanoidRootPart :: Part
	local walkAnim = hum.Animator:LoadAnimation(
		(self.Animations and self.Animations["Walk"]) or ReplicatedStorage.Animations.Brainrot.WalkAnimation
	) :: AnimationTrack
	local attackAnim = hum.Animator:LoadAnimation(
		(self.Animations and self.Animations["Attack"]) or ReplicatedStorage.Animations.Weapons.SlashAnim2
	) :: AnimationTrack

	table.insert(
		self._connections,
		RunService.Heartbeat:Connect(function(dt)
			if self._stolenBrainrot then
				self._stolenBrainrot.Model:PivotTo(hrp.CFrame * CFrame.new(0, 5, 0))

				if self._stolenBrainrot._destroyed then
					self._hasBrainrot = false
				end
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
				local target = chosenChar:GetPivot().Position
				if (hrp.Position - chosenChar:GetPivot().Position).Magnitude > self.AttackRange then
					hum:MoveTo(target)
				end

				local now = os.clock()

				if
					self._lastAttack + self.AttackCD <= now
					and (hrp.Position - chosenChar:GetPivot().Position).Magnitude <= self.AttackRange
				then
					walkAnim:Stop()
					hum.WalkSpeed = 0

					local prevAuto = hum.AutoRotate
					hum.AutoRotate = false
					hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.X, hrp.Position.Y, target.Z))
					hum.AutoRotate = prevAuto

					packets.SpawnHitbox:Fire({
						Startup = 0.5,
						Linger = 0.2,
						WarningWindow = 0.3,
						HitboxCFrame = hrp.CFrame * CFrame.new(0, -2.5, -5),
						HitboxSize = Vector3.new(10, 5, 10),
						Filter = workspace.Map.NPCs.EnemyNPCs:GetChildren(),
					})

					task.spawn(function()
						task.wait(0.5)
						attackAnim:Play()
						task.wait(0.5)
						walkAnim:Play()
						hum.WalkSpeed = self.WalkSpeed
					end)

					self._lastAttack = now
				end
			elseif baseCurrStats.BrainrotCount.Value ~= 0 then
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
						if self._stolenBrainrot then
							self._hasBrainrot = false
							self._stolenBrainrot:Destroy()
						end
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
	if self._stolenBrainrot and not self._stolenBrainrot._destroyed then
		self._stolenBrainrot.Model.BillboardGuis.StolenGui.Enabled = false
		if self._stolenBrainrot._chosenSlot then
			self._stolenBrainrot.Model:PivotTo(self._stolenBrainrot._chosenSlot.Spawn.CFrame)
		end
		self._hasBrainrot = false
	end
end

return npc
