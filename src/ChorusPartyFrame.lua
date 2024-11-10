--[[--
@submodule chorus
]]

local SecureButton_GetUnit = SecureButton_GetUnit

local Chorus = Chorus

--[[--
Given valid player unit designation, infer from it corresponding pet and target unit designations.

Does not check if unit exists.
Used in party frame initialization.

@function mapUnitDesignation

@tparam string unitDesignation unit designation in the same format as native
unit functions, specifically party, arena or raid members (party3, raid13,
arena2)

@treturn string sanitized given unit designation, for example party3

@treturn string given unit pet designation, for example partypet3

@treturn string given unit target designation, for example party3target
]]
local function mapUnitDesignation(unitDesignation)
	assert(unitDesignation ~= nil)

	if 'player' == unitDesignation then
		return 'player', 'pet', 'target'
	elseif string.match(unitDesignation, 'raid') then
		local raidUnit = string.match(unitDesignation, 'raid%d+')
		local raidPet = 'raidpet' .. string.match(unitDesignation, 'raid(%d+)')
		local raidTarget = 'raid' .. string.match(unitDesignation, 'raid(%d+)') .. 'target'
		return raidUnit, raidPet, raidTarget
	elseif string.match(unitDesignation, 'party') then
		local partyUnit = string.match(unitDesignation, 'party%d+')
		local partyPet = 'partypet' .. string.match(unitDesignation, 'party(%d+)')
		local partyTarget = 'party' .. string.match(unitDesignation, 'party(%d+)') .. 'target'
		return partyUnit, partyPet, partyTarget
	elseif string.match(unitDesignation, 'arena') then
		local arenaUnit = string.match(unitDesignation, 'arena%d+')
		local arenaPet = 'arenapet' .. string.match(unitDesignation, 'arena(%d+)')
		local arenaTarget = 'arena' .. string.match(unitDesignation, 'arena(%d+)') .. 'target'
		return arenaUnit, arenaPet, arenaTarget
	else
		error('invalid argument: must be a unit designation of a player character or a group member')
	end
end

local function partyMemberFrameInit(partyMemberFrame)
	assert(partyMemberFrame ~= nil)

	local n = partyMemberFrame:GetName()
	assert(n ~= nil)

	local u = partyMemberFrame:GetAttribute('unit')

	if not u then
		u = SecureButton_GetUnit(partyMemberFrame)
	end

	local _, upet, utarget = mapUnitDesignation(u)

	local unitFrame = _G[n .. 'UnitFrame']
	local petFrame = _G[n .. 'PetFrame']
	local targetFrame = _G[n .. 'TargetFrame']
	assert(unitFrame ~= nil)
	assert(petFrame ~= nil)
	assert(targetFrame ~= nil)

	unitFrame:SetAttribute('unit', u)
	petFrame:SetAttribute('unit', upet)
	targetFrame:SetAttribute('unit', utarget)
end

function Chorus.partyMemberFrameMain(partyMemberFrame)
	assert(partyMemberFrame ~= nil)

	partyMemberFrame:RegisterEvent('ADDON_LOADED')
	partyMemberFrame:SetScript('OnEvent', partyMemberFrameInit)
	partyMemberFrame:SetScript('OnAttributeChanged', partyMemberFrameInit)
end

--[[--
`ChorusPartyFrame` holds all frames necessary to show player's current party
members, if any.

It is intended to be disabled in raid groups.

Currently, it is also used in arenas.

Logic to toggle the frame is handled in a separate frame, that is
`ChorusGroupFrame`.

@function partyFrameMain
@tparam frame self this party frame
]]
function Chorus.partyFrameMain(self)
	assert(self ~= nil)
end
