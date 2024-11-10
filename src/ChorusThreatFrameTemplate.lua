--[[--
`ChorusThreatFrameTemplate` displays a color coded pictogram for general threat
situation for the corresponding unit and the player character.

@submodule chorus
]]

local Chorus = Chorus

local GetThreatStatusColor = GetThreatStatusColor
local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitIsConnected = Chorus.test.UnitIsConnected or UnitIsConnected
local UnitIsFriend = Chorus.test.UnitIsFriend or UnitIsFriend
local UnitThreatSituation = UnitThreatSituation

local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

local function threatFrameEventProcessor(self)
	assert(self ~= nil)

	local unitButton = self:GetParent()
	assert(unitButton ~= nil)

	local u = SecureButton_GetUnit(self) or 'none'

	assert(u ~= nil)

	if UnitExists(u) and UnitIsConnected(u) then
		self:Show()
	else
		self:Hide()
		return
	end

	local threatStatus, threatPercentage

	local owner = 'player'
	if UnitIsFriend(owner, u) then
		threatStatus = UnitThreatSituation(u)
	else
		local _, threatStatus0, threatPercentage0 = UnitDetailedThreatSituation(owner, u)
		threatStatus = threatStatus0
		threatPercentage = threatPercentage0
	end

	local r = 0
	local g = 0
	local b = 0
	local a = 0

	if threatStatus then
		r, g, b = GetThreatStatusColor(threatStatus)
		a = 1
	end

	local artwork = self.artwork
	assert (artwork ~= nil)
	artwork:SetVertexColor(r, g, b, a)

	local label = self.label or _G[self:GetName() .. 'Text']
	if label and threatPercentage then
		assert('number' == type(threatPercentage))

		assert(threatPercentage >= 0)

		label:SetText(string.format('%d%%', threatPercentage))
	elseif label then
		label:SetText(nil)
	end
end

local function threatFrameMain(self)
	assert(self ~= nil)

	local artwork = _G[self:GetName() .. 'Artwork']
	assert(artwork ~= nil)
	self.artwork = artwork

	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('PLAYER_ALIVE')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_FOCUS_CHANGED')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('RAID_ROSTER_UPDATE')
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE')
	self:SetScript('OnEvent', threatFrameEventProcessor)
end

Chorus.threatFrameMain = function(...)
	return threatFrameMain(...)
end
