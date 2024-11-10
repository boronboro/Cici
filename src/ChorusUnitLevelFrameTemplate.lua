--[[--
@submodule chorus
]]

local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local UnitIsConnected = UnitIsConnected
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local strtrim = strtrim

local SecureButton_GetUnit = SecureButton_GetUnit

local Chorus = Chorus

local function unitLevelFrameEventIsRelevant(self, eventCategory, ...)
	assert(self ~= nil)

	local u = SecureButton_GetUnit(self)
	if not u then
		return true
	end

	if 'UNIT_LEVEL' == eventCategory then
		return UnitIsUnit(u, select(1, ...))
	elseif 'PLAYER_LEVEL_UP' == eventCategory then
		return UnitIsUnit('player', u)
	elseif 'PLAYER_FOCUS_CHANGED' == eventCategory then
		return UnitIsUnit('focus', u)
	elseif 'PLAYER_TARGET_CHANGED' == eventCategory then
		return UnitIsUnit('target', u)
	else
		return true
	end
end

local function applyUnitLevel(self, unitDesignation)
	assert(self ~= nil)

	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))
	unitDesignation = string.lower(strtrim(unitDesignation))
	assert(string.len(unitDesignation) >= 1)
	assert(string.len(unitDesignation) <= 256)

	local n = self:GetName()
	assert(n ~= nil)

	local label = self.label or _G[n .. 'Text']
	assert(label ~= nil)

	local unitLevel = UnitLevel(unitDesignation)
	if unitLevel then
		assert('number' == type(unitLevel))

		local t
		if unitLevel > 0 then
			t = string.format('%d', unitLevel)
		else
			t = '?'
		end

		local c = UnitClassification(unitDesignation)
		if 'elite' == c or 'worldboss' == c or 'rareelite' == c then
			t = t .. '!'
		elseif 'rare' == c then
			t = t .. '~'
		end

		label:SetText(t)

		local r = 1
		local g = 1
		local b = 1
		local colorTuple = GetQuestDifficultyColor(unitLevel)
		if unitLevel <= 0 then
			r = 1
			g = 0
			b = 0
		elseif UnitCanAttack('player', unitDesignation) and colorTuple then
			assert(colorTuple ~= nil)
			assert('table' == type(colorTuple))

			r = math.min(math.max(0, colorTuple.r), 1)
			g = math.min(math.max(0, colorTuple.g), 1)
			b = math.min(math.max(0, colorTuple.b), 1)
		end

		label:SetTextColor(r, g, b)

		self:Show()
	else
		self:Hide()
	end
end

local function unitLevelFrameEventProcessor(self, eventCategory, ...)
	assert(self ~= nil)

	if not unitLevelFrameEventIsRelevant(self, eventCategory, ...) then
		return
	end

	local u = SecureButton_GetUnit(self)
	if not UnitExists(u) or not UnitIsConnected(u)  then
		self:Hide()
		return
	end

	applyUnitLevel(self, u)
end

--[[--
`ChorusUnitLevelFrameTemplate` shows the number of corresponding unit's level,
conditionally decorated for elite and rare enemies.

@function unitLevelFrameMain
@tparam frame self this unit level frame
]]
local function unitLevelFrameMain(self)
	assert(self ~= nil)

	local n = self:GetName()
	assert(n ~= nil)

	local label = self.label or _G[n .. 'Text']
	assert(label ~= nil)
	self.label = label

	self:SetScript('OnEvent', unitLevelFrameEventProcessor)

	self:RegisterEvent('PARTY_CONVERTED_TO_RAID')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('PLAYER_FOCUS_CHANGED')
	self:RegisterEvent('PLAYER_LEVEL_UP')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('RAID_ROSTER_UPDATE')
	self:RegisterEvent('UNIT_LEVEL')
end

Chorus.unitLevelFrameMain = function(...)
	return unitLevelFrameMain(...)
end
