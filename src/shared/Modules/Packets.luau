--!strict
-- Every cross-network packet definition, required by both server and client so
-- the schemas always match. Slot indices are 1-based and shared between sides:
-- 1..HotbarSlots are the hotbar, the rest is the inventory grid.

--[[
	S8		Minimum: -128			Maximum: 127
	S16		Minimum: -32768			Maximum: 32767
	S24		Minimum: -8388608		Maximum: 8388607
	S32		Minimum: -2147483648	Maximum: 2147483647

	U8		Minimum: 0				Maximum: 255
	U16		Minimum: 0				Maximum: 65535
	U24		Minimum: 0				Maximum: 16777215
	U32		Minimum: 0				Maximum: 4294967295

	F16		±2048					[65520]
	F24		±262144					[4294959104]
	F32		±16777216				[170141183460469231731687303715884105728]
	F64		±9007199254740992		[huge]
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packet = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Packet"))

export type Stack = { Id: string, Count: number }

local Packets = {
	DealDamage = Packet("DealDamage", Packet.Any, Packet.NumberS16), --Humanoid / Damage
}

return Packets
