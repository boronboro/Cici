--[[--
@submodule chorus
]]

local GetSpellName = GetSpellName
local IsSpellInRange = IsSpellInRange

local MAX_SPELLS = MAX_SPELLS

local Chorus = Chorus

--[[--
Map of localized spell names to their maximum reach in yards.

@table spellRangeMap
@see spellRangeMapUpdate
@see rangeFrameUpdate
]]
local spellRangeMap = {}

Chorus.spellRangeMap = spellRangeMap

--[[--
Read player spell book and initialize `spellRangeMap` appropriately.

@see FrameXML/SpellBookFrame.lua:MAX_SPELLS
@see spellRangeMap
@function spellRangeMapUpdate
]]
local function spellRangeMapUpdate()
	local maxSpells = MAX_SPELLS or 1024
	maxSpells = math.min(math.max(1, math.abs(math.floor(maxSpells)), 8192))

	local buffer = {}

	local i = 0
	while (i < maxSpells) do
		i = i + 1

		--[[ Get player spell book button number "i", and request it's
		     corresponding spell name. This is NOT a unique spell
		     identifier. Every spell rank is a separate button. ]]--

		--[[-- @fixme Currently range indicator does not work in
		Cataclysm client (interface 40300). Specifically, `function
		GetSpellName` is not defined for that client.  Additionally,
		the current implementation may violate some additional
		restrictions found in interface `40300` but not in interface
		`30300`.]]

		--[[-- @fixme function GetSpellName is not available in Cata
		client.]]

		local spellName = GetSpellName(i, 'player')
		if not spellName then
			break
		end

		--[[ When GetSpellInfo is called with localized spell name
		     string, it only returns data on the spells stored in the
		     current player character's spell book. ]]--
		local _, _, _, _, _, _, _, _, maxRangeYards = GetSpellInfo(spellName)
		if spellName and maxRangeYards then
			assert(spellName ~= nil)
			assert('string' == type(spellName))
			spellName = strtrim(spellName)
			assert(string.len(spellName) >= 1)
			assert(string.len(spellName) <= 8192)

			assert(maxRangeYards ~= nil)
			assert('number' == type(maxRangeYards))
			maxRangeYards = math.abs(math.floor(maxRangeYards))

			if maxRangeYards >= 1 then
				local oldRangeYards = spellRangeMap[spellName]

				--[[
				Previous rank of the spell already mapped.
				Only the most potentially efficient spell rank
				will be mapped. ]]--

				if oldRangeYards then
					maxRangeYards = math.max(maxRangeYards, oldRangeYards)
				end

				--[[
				Priest spell "Mind Vision" has range of 50_000
				yards. This isn't a useful specificity, so
				filter it out. Only allow spell ranges that can
				be reasonably displayed and understood by the
				user during game combat play. Do not round down
				the value itself. Only store correct
				values.]]--
				if maxRangeYards < 99 then
					buffer[spellName] = maxRangeYards
				end
			end
		end
	end

	--[[ At this point assume no errors occurred. Re-write the actual spell
	     range map. ]]--
	spellRangeMap = buffer
end

--[[--
Update range frame to show approximate amount of yards to the given unit.

@see spellRangeMap

@function rangeFrameUpdate
@tparam frame self this range frame
]]
local function rangeFrameUpdate(self)
	assert(self ~= nil)

	local unitDesignation = SecureButton_GetUnit(self) or 'none'

	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))
	unitDesignation = string.lower(strtrim(unitDesignation))
	assert(string.len(unitDesignation) >= 1)
	assert(string.len(unitDesignation) <= 256)

	local label = self.label or _G[self:GetName() .. 'Text']
	assert(label ~= nil)

	--[[ Frame must be always shown to keep update processor running. ]]--
	if not UnitExists(unitDesignation) or UnitIsUnit('player', unitDesignation) then
		label:SetText(nil)
		return
	end

	local rangeFlag = nil
	local distanceYards = nil
	local maxRangeYards = 0
	for spellName, rangeYards in pairs(spellRangeMap) do
		local flag = IsSpellInRange(spellName, unitDesignation)
		--[[ 1 == flag: in range; ]]--
		--[[ 0 == flag: out of range; ]]--
		--[[ nil == flag: not applicable or cannot be cast on given target. ]]--
		if not rangeFlag and flag then
			rangeFlag = flag
		end
		if nil ~= flag then
			maxRangeYards = math.max(rangeYards, maxRangeYards)
		end
		if 1 == flag then
			rangeFlag = 1
			if not distanceYards then
				distanceYards = rangeYards
			end
			distanceYards = math.min(distanceYards, rangeYards)
		end
	end

	local t
	if 1 == rangeFlag then
		t = string.format('<%d yd', distanceYards)
		label:SetTextColor(1, 1, 1)
	elseif 0 == rangeFlag then
		t = string.format('>%d yd', maxRangeYards)
		label:SetTextColor(1, 0, 0)
	else
		t = nil
	end
	label:SetText(t)
end

local function rangeFrameUpdateProcessor(self)
	assert(self ~= nil)

	--[[ Reduce update frequency to roughly 6 frames per second. ]]--
	if self.lastUpdateInstance and 'number' == type(self.lastUpdateInstance) then
		local now = GetTime()
		if now - self.lastUpdateInstance > 0.1667 then
			self.lastUpdateInstance = now
		else
			return
		end
	end

	rangeFrameUpdate(self)
end

local function rangeFrameMain(self)
	assert(self ~= nil)

	self.label = _G[self:GetName() .. 'Text']
	self:SetScript('OnUpdate', rangeFrameUpdateProcessor)
end

--[[--
`ChorusRangeFrameTemplate` displays approximate distance from player character
to the corresponding unit, in yards.

This works by checking the reach of each spell in the player's character's
current spell book. This ensures that the range approximation feature works in
any client, regardless of localization. This also allows the feature to span
several different WoW API interface versions more easily.

The spell range map is updated every time the player character learns a new
spell or enters the world.

@function rangeSpellMapFrameMain
@tparam frame self this spell map frame
]]--
local function rangeSpellMapFrameMain(self)
	assert(self ~= nil)

	self:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	self:RegisterEvent('LEARNED_SPELL_IN_TAB')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('PLAYER_TALENT_UPDATE')
	self:RegisterEvent('SPELLS_CHANGED')
	self:SetScript('OnEvent', spellRangeMapUpdate)
end

--[[ Hide reference to the internal function, for some reason. ]]--
Chorus.rangeFrameMain = function(...)
	return rangeFrameMain(...)
end

Chorus.rangeSpellMapFrameMain = function(...)
	return rangeSpellMapFrameMain(...)
end
