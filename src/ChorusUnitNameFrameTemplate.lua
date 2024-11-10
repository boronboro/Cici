--[[--
@submodule chorus
]]

local Chorus = Chorus

local UnitClass = Chorus.test.UnitClass or UnitClass
local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitIsConnected = Chorus.test.UnitIsConnected or UnitIsConnected
local UnitIsPlayer = Chorus.test.UnitIsPlayer or UnitIsPlayer
local UnitName = Chorus.test.UnitName or UnitName

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

--[[--
Update this unit name frame.

@see FrameXML/Constants.lua:RAID_CLASS_COLORS
@function unitNameEventProcessor
@tparam frame self this unit name frame
]]
local function unitNameEventProcessor(self)
	assert(self ~= nil)

	local label = self.label
	assert(label ~= nil)

	local unitDesignation = SecureButton_GetUnit(self) or 'none'
	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))
	unitDesignation = string.lower(strtrim(unitDesignation))
	assert(string.len(unitDesignation) >= 1)
	assert(string.len(unitDesignation) <= 256)

	local name = UnitName(unitDesignation)
	label:SetText(name)

	if UnitIsConnected(unitDesignation) and UnitExists(unitDesignation) then
		label:SetTextColor(1, 1, 1)
	else
		label:SetTextColor(0.7, 0.7, 0.7)
		return
	end

	if not self.strategy then
		return
	elseif 'UnitClass' ~= self.strategy then
		return
	end

	local _, classDesignation = UnitClass(unitDesignation)
	if not classDesignation or not UnitIsPlayer(unitDesignation) then
		label:SetTextColor(1, 1, 1)
		return
	end

	local map = RAID_CLASS_COLORS
	assert(map ~= nil)
	assert('table' == type(map))
	local colorTuple = map[classDesignation]

	local r = 1
	local g = 1
	local b = 1
	if colorTuple then
		assert('table' == type(colorTuple))
		r = math.min(math.max(0, math.abs(colorTuple.r)), 1)
		g = math.min(math.max(0, math.abs(colorTuple.g)), 1)
		b = math.min(math.max(0, math.abs(colorTuple.b)), 1)
	end

	label:SetTextColor(r, g, b)
end

--[[--
`ChorusUnitNameFrameTemplate` shows corresponding unit's human readable
localized name, conditionally color coded.

@function unitNameFrameMain
@tparam frame self this unit name frame
]]
function Chorus.unitNameFrameMain(self)
	assert(self ~= nil)

	local label = _G[self:GetName() .. 'Text']
	assert(label ~= nil)
	self.label = label

	--[[-- @fixme Sometimes some unit buttons in raid frames cannot be
	clicked.]]

	self:SetScript('OnEvent', unitNameEventProcessor)

	self:RegisterEvent('PARTY_CONVERTED_TO_RAID')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('PARTY_MEMBER_DISABLE')
	self:RegisterEvent('PARTY_MEMBER_ENABLE')
	self:RegisterEvent('PLAYER_ALIVE')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_FOCUS_CHANGED')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('PLAYER_LOGOUT')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('RAID_ROSTER_UPDATE')
	self:RegisterEvent('UNIT_NAME_UPDATE')
end
