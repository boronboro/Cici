--[[--
@submodule chorus
]]

local UnitExists = Chorus.test.UnitExists or UnitExists

local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

local function unitBackgroundEventProcessor(unitBackground)
	assert(unitBackground ~= nil)

	local u = SecureButton_GetUnit(unitBackground) or 'none'

	if UnitExists(u) then
		unitBackground:Show()
	else
		unitBackground:Hide()
		return
	end

	local textureEnemy = unitBackground.textureEnemy
	assert(textureEnemy ~= nil)

	local textureFriend = unitBackground.textureFriend
	assert(textureFriend ~= nil)

	local textureNeutral = unitBackground.textureNeutral
	assert(textureNeutral ~= nil)

	if UnitIsFriend('player', u) then
		textureFriend:Show()
		textureEnemy:Hide()
		textureNeutral:Hide()
	elseif UnitIsEnemy('player', u) then
		textureFriend:Show()
		textureEnemy:Show()
		textureNeutral:Hide()
	elseif UnitIsTapped(u) then
		textureFriend:Show()
		textureEnemy:Show()
		textureNeutral:Hide()
	else
		textureFriend:Hide()
		textureEnemy:Hide()
		textureNeutral:Show()
	end
end

--[[--
Frame with simple texture that is toggled with the corresponding unit.

This frame is composed with unit frames and unit buttons.

@function unitBackgroundMain
@tparam frame unitBackground this unit background
]]
local function unitBackgroundMain(unitBackground)
	assert(unitBackground ~= nil)

	local n = unitBackground:GetName() or ''
	unitBackground.textureFriend = _G[string.format('%sTexture1', n)]
	unitBackground.textureEnemy = _G[string.format('%sTexture2', n)]
	unitBackground.textureNeutral = _G[string.format('%sTexture3', n)]

	unitBackground:RegisterEvent('ADDON_LOADED')
	unitBackground:RegisterEvent('PARTY_CONVERTED_TO_RAID')
	unitBackground:RegisterEvent('PARTY_MEMBERS_CHANGED')
	unitBackground:RegisterEvent('PLAYER_FOCUS_CHANGED')
	unitBackground:RegisterEvent('PLAYER_LOGIN')
	unitBackground:RegisterEvent('PLAYER_TARGET_CHANGED')
	unitBackground:RegisterEvent('RAID_ROSTER_UPDATE')
	unitBackground:RegisterEvent('ZONE_CHANGED')

	unitBackground:SetScript('OnEvent', unitBackgroundEventProcessor)
end

Chorus.unitBackgroundMain = function(...)
	return unitBackgroundMain(...)
end
