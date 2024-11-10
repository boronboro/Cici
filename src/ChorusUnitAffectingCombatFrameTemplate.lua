--[[--
`ChorusUnitAffectingCombatFrameTemplate` shows a pictogram when the
corresponding unit is engaged in combat.

@submodule chorus
]]

local Chorus = Chorus

local strtrim = strtrim

local UnitAffectingCombat = Chorus.test.UnitAffectingCombat or UnitAffectingCombat
local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitIsConnected = Chorus.test.UnitIsConnected or UnitIsConnected

local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

local function unitAffectingCombatFrameEventProcessor(self)
	assert(self ~= nil)

	local u = SecureButton_GetUnit(self) or 'none'

	assert(u ~= nil)
	assert('string' == type(u))
	u = string.lower(strtrim(u))
	assert(string.len(u) >= 1)
	assert(string.len(u) <= 256)

	if u and UnitExists(u) and UnitIsConnected(u) and UnitAffectingCombat(u) then
		self:Show()
	else
		self:Hide()
	end
end

local function unitAffectingCombatFrameMain(self)
	assert(self ~= nil)

	self:RegisterEvent('PLAYER_ENTER_COMBAT')
	self:RegisterEvent('PLAYER_FOCUS_CHANGED')
	self:RegisterEvent('PLAYER_LEAVE_COMBAT')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('UNIT_COMBAT')
	self:RegisterEvent('PLAYER_LOGIN')

	self:SetScript('OnEvent', unitAffectingCombatFrameEventProcessor)
end

Chorus.unitAffectingCombatFrameMain = function(...)
	return unitAffectingCombatFrameMain(...)
end
