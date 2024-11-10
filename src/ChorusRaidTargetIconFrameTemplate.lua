--[[--
@submodule chorus
]]

local Chorus = Chorus

local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitIsConnected = Chorus.test.UnitIsConnected or UnitIsConnected
local GetRaidTargetIndex = GetRaidTargetIndex

local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit
--[[ See FrameXML/TargetFrame.lua:682 ]]--
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

local function raidTargetIconFrameEventProcessor(self)
	assert(self ~= nil)

	local u = SecureButton_GetUnit(self) or 'none'

	assert(u ~= nil)
	assert('string' == type(u))
	u = string.lower(strtrim(u))
	assert(string.len(u) >= 1)
	assert(string.len(u) <= 256)

	local raidIconIndex = GetRaidTargetIndex(u)

	local artwork = self.artwork or _G[self:GetName() .. 'Artwork']
	assert(artwork ~= nil)

	if UnitExists(u) and UnitIsConnected(u) and raidIconIndex then
		SetRaidTargetIconTexture(artwork, raidIconIndex)
		self:Show()
	else
		SetRaidTargetIconTexture(artwork, 0)
		self:Hide()
	end
end

--[[--
`ChorusRaidTargetIconFrameTemplate` shows the corresponding unit raid marker,
like {skull}, {diamond}, {moon}, {star}, etc.

@function raidTargetIconFrameMain
@tparam frame self this raid target icon frame
]]
function Chorus.raidTargetIconFrameMain(self)
	assert(self ~= nil)

	local artwork = _G[self:GetName() .. 'Artwork']
	assert(artwork ~= nil)
	self.artwork = artwork

	--artwork:SetSize(RAID_TARGET_ICON_DIMENSION, RAID_TARGET_ICON_DIMENSION)
	SetRaidTargetIconTexture(artwork, 0)

	self:SetScript('OnEvent', raidTargetIconFrameEventProcessor)

	self:RegisterEvent('ADDON_LOADED')
	self:RegisterEvent('PARTY_CONVERTED_TO_RAID')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('PLAYER_FOCUS_CHANGED')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('RAID_ROSTER_UPDATE')
	self:RegisterEvent('RAID_TARGET_UPDATE')
end
