--[[--
`ChorusCastFrameTemplate` is a primitive unit cast bar.
@submodule chorus
]]

local Chorus = Chorus

local GetTime = GetTime
local UnitCastingInfo = Chorus.test.UnitCastingInfo or UnitCastingInfo
local UnitChannelInfo = Chorus.test.UnitChannelInfo or UnitChannelInfo
local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitIsUnit = Chorus.test.UnitIsUnit or UnitIsUnit

local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

local function applyArtworkSpellIcon(self, pictureFile)
	assert(self ~= nil)

	if not pictureFile then
		pictureFile = 'Interface\\Icons\\INV_Misc_QuestionMark'
	end

	assert(pictureFile ~= nil)
	assert('string' == type(pictureFile))
	pictureFile = strtrim(pictureFile)
	assert(string.len(pictureFile) >= 1)
	assert(string.len(pictureFile) <= 8192)

	--[[ Artwork1: spell icon ]]--
	local artwork1 = self.artwork1 or _G[self:GetName() .. 'Artwork1']
	assert(artwork1 ~= nil)

	artwork1:SetTexture(pictureFile)
end

local function applySpellName(self, spellName)
	assert(self ~= nil)

	if not spellName then
		spellName = 'Unknown'
	end

	assert(spellName ~= nil)
	assert('string' == type(spellName))
	spellName = strtrim(spellName)
	assert(string.len(spellName) >= 1)
	assert(string.len(spellName) <= 8192)

	local label1 = self.label1 or _G[self:GetName() .. 'Text1']
	assert(label1 ~= nil)

	label1:SetText(spellName)
end

local function applyArtworkCastBar(self, unitDesignation, shieldedFlag)
	assert(self ~= nil)

	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))
	unitDesignation = string.lower(strtrim(unitDesignation))
	assert(string.len(unitDesignation) >= 1)
	assert(string.len(unitDesignation) <= 256)

	local label1 = self.label1 or _G[self:GetName() .. 'Text1']
	assert(label1 ~= nil)

	--[[ Artwork2: bar texture ]]--
	local artwork2 = self.artwork2 or _G[self:GetName() .. 'Artwork2']
	assert(artwork2 ~= nil)

	if shieldedFlag then
		artwork2:SetVertexColor(248 / 255, 248 / 255, 1)
		label1:SetTextColor(1, 215 / 255, 0)
	elseif UnitIsFriend('player', unitDesignation) then
		artwork2:SetVertexColor(143 / 255, 188 / 255, 143 / 255)
		label1:SetTextColor(248 / 255, 248 / 255, 1)
	else
		artwork2:SetVertexColor(1, 69 / 255, 0)
		label1:SetTextColor(248 / 255, 248 / 255, 1)
	end
end

local function applyDurationRemainingSec(self, durationRemainingSec)
	assert(self ~= nil)

	assert(durationRemainingSec ~= nil)
	assert('number' == type(durationRemainingSec))

	local label2 = self.label2 or _G[self:GetName() .. 'Text2']
	assert(label2 ~= nil)

	local t = string.format('%.1f', durationRemainingSec)
	label2:SetText(t)
end

local function unitFilter(castFrame, targetUnit)
	assert(castFrame ~= nil)

	if not targetUnit then
		return false
	end

	local u = SecureButton_GetUnit(castFrame)
	if u then
		if UnitIsUnit(u, targetUnit) then
			return true
		end
	end
	return false
end

local function durationUpdateProcessor(castFrame)
	assert(castFrame ~= nil)

	local _, b = castFrame:GetMinMaxValues()
	local now = GetTime()

	local durationRemainingSec = b - now

	applyDurationRemainingSec(castFrame, durationRemainingSec)
	if durationRemainingSec < -2 then
		castFrame:Hide()
	elseif durationRemainingSec < 0 then
		castFrame:SetAlpha(2 - math.abs(durationRemainingSec))
	end
end

local function castingUpdateProcessor(castFrame)
	assert(castFrame ~= nil)

	local now = GetTime()
	castFrame:SetValue(now)

	durationUpdateProcessor(castFrame)
end

local function channelUpdateProcessor(castFrame)
	assert(castFrame ~= nil)

	local a, b = castFrame:GetMinMaxValues()
	local now = GetTime()
	castFrame:SetValue(a + b - now)

	durationUpdateProcessor(castFrame)
end

local function spellcastBegin(castFrame, eventCategory, targetUnit)
	assert(castFrame ~= nil)

	local t = {
		'ADDON_LOADED',
		'PLAYER_ENTERING_WORLD',
		'PLAYER_FOCUS_CHANGED',
		'PLAYER_LOGIN',
		'PLAYER_TARGET_CHANGED',
		'UNIT_SPELLCAST_CHANNEL_START',
		'UNIT_SPELLCAST_START',
		'ZONE_CHANGED',
	}

	if not tContains(t, eventCategory) then
		return false
	end

	targetUnit = targetUnit or SecureButton_GetUnit(castFrame) or 'none'
	if 'ADDON_LOADED' == eventCategory then
		targetUnit = SecureButton_GetUnit(castFrame)
	elseif 'PLAYER_ENTERING_WORLD' == eventCategory then
		targetUnit = SecureButton_GetUnit(castFrame)
	elseif 'PLAYER_LOGIN' == eventCategory then
		targetUnit = SecureButton_GetUnit(castFrame)
	elseif 'ZONE_CHANGED' == eventCategory then
		targetUnit = SecureButton_GetUnit(castFrame)
	end

	if not unitFilter(castFrame, targetUnit) then
		return false
	end

	local spellName0, _, _, pictureFile0, startInstanceMili0,
	endInstanceMili0, _, _, shieldedFlag0 = UnitCastingInfo(targetUnit)

	local spellName1, _, _, pictureFile1, startInstanceMili1,
	endInstanceMili1, _, _, shieldedFlag1 = UnitChannelInfo(targetUnit)

	if spellName0 then
		castFrame:SetScript('OnUpdate', castingUpdateProcessor)
	elseif spellName1 then
		castFrame:SetScript('OnUpdate', channelUpdateProcessor)
	else
		castFrame:SetScript('OnUpdate', durationUpdateProcessor)
	end

	if not spellName0 and not spellName1 then
		castFrame:Hide()
		return false
	end

	local spellName = spellName0 or spellName1
	local pictureFile = pictureFile0 or pictureFile1
	local startInstanceMili = startInstanceMili0 or startInstanceMili1
	local endInstanceMili = endInstanceMili0 or endInstanceMili1
	local shieldedFlag = shieldedFlag0 or shieldedFlag1

	local endInstanceSec = endInstanceMili / 1000
	local startInstanceSec = startInstanceMili / 1000

	castFrame:SetMinMaxValues(startInstanceSec, endInstanceSec)
	local now = GetTime()
	castFrame:SetValue(now)

	applyArtworkSpellIcon(castFrame, pictureFile)
	applyArtworkCastBar(castFrame, targetUnit, shieldedFlag)
	applySpellName(castFrame, spellName)
	castFrame:Show()
	castFrame:SetAlpha(1)

	return true
end

local function getSpellName(castFrame)
	assert(castFrame ~= nil)

	--[[ Dirty reads are forbidden. ]]--

	if not castFrame:IsShown() then
		return nil
	end

	local n = castFrame:GetName() or ''
	assert(n ~= nil)

	local label1 = castFrame.label1 or _G[tostring(n) .. 'Text1']
	assert(label1 ~= nil)

	local lastSpellName = label1:GetText()

	if lastSpellName ~= nil then
		assert('string' == type(lastSpellName))
		lastSpellName = strtrim(lastSpellName)
		assert(string.len(lastSpellName) >= 1)
		assert(string.len(lastSpellName) <= 512)
	end

	return lastSpellName
end

local function spellcastSucceeded(castFrame, eventCategory, targetUnit, spellName)
	assert(castFrame ~= nil)

	assert(eventCategory ~= nil)

	if not ('UNIT_SPELLCAST_SUCCEEDED' == eventCategory or
		'UNIT_SPELLCAST_FAILED' == eventCategory or
		'UNIT_SPELLCAST_INTERRUPTED' == eventCategory or
		'UNIT_SPELLCAST_CHANNEL_STOP' == eventCategory) then
		return false
	end

	local oldSpellName = getSpellName(castFrame)

	local pictureFile = nil

	if UnitIsUnit('player', targetUnit) then
		local _, _, pictureFile0 = GetSpellInfo(spellName or oldSpellName)
		pictureFile = pictureFile or pictureFile0

	end

	if 'UNIT_SPELLCAST_SUCCEEDED' == eventCategory or
		'UNIT_SPELLCAST_CHANNEL_STOP' == eventCategory then
		pictureFile = pictureFile or "Interface\\Icons\\Spell_ChargePositive"
	elseif 'UNIT_SPELLCAST_FAILED' == eventCategory or
		'UNIT_SPELLCAST_INTERRUPTED' == eventCategory then
		pictureFile = pictureFile or "Interface\\Icons\\Spell_ChargeNegative"
	end

	local now = GetTime()
	castFrame:SetMinMaxValues(now - 0.01, now + 0.01)
	castFrame:SetValue(now)

	--[[-- @todo Render shield pictogram for spell cast that cannot be interrupted by the user.
	]]

	applyArtworkSpellIcon(castFrame, pictureFile)
	applyArtworkCastBar(castFrame, targetUnit, false)
	applySpellName(castFrame, spellName or oldSpellName)
	castFrame:Show()
	castFrame:SetAlpha(1)

	return true
end

local function spellcastEnd(castFrame, eventCategory, targetUnit, spellName)
	assert(castFrame ~= nil)

	local t = {
		'UNIT_SPELLCAST_CHANNEL_STOP',
		'UNIT_SPELLCAST_FAILED',
		'UNIT_SPELLCAST_INTERRUPTED',
		'UNIT_SPELLCAST_STOP',
		'UNIT_SPELLCAST_SUCCEEDED',
	}

	if not tContains(t, eventCategory) then
		return false
	end

	if not unitFilter(castFrame, targetUnit) then
		return false
	end

	--[[ Prevent cast bar being obscured by repeatedly pressing the
	hotkey. ]]--

	if 'UNIT_SPELLCAST_FAILED' == eventCategory and
		UnitIsUnit('player', targetUnit) and
		castFrame:IsShown() then

		if spellName and GetSpellInfo(spellName) then
			local cooldownDuration = GetSpellCooldown(spellName)
			if cooldownDuration and cooldownDuration > 0 then
				return false
			end
		end
	end

	spellcastSucceeded(castFrame, eventCategory, targetUnit, spellName)

	local _, boundaryMax = castFrame:GetMinMaxValues()
	castFrame:SetValue(boundaryMax)
	castFrame:SetScript('OnUpdate', durationUpdateProcessor)

	local r = 1
	local g = 1
	local b = 0

	if 'UNIT_SPELLCAST_FAILED' == eventCategory or
		'UNIT_SPELLCAST_INTERRUPTED' == eventCategory then

		r = 1
		g = 0
		b = 1
	end
	castFrame:SetStatusBarColor(r, g, b)

	return true
end

local function spellcastUpdate(castFrame, eventCategory, targetUnit)
	assert(castFrame ~= nil)

	local t = {
		'UNIT_SPELLCAST_CHANNEL_UPDATE',
		'UNIT_SPELLCAST_DELAYED',
		'UNIT_SPELLCAST_INTERRUPTIBLE',
		'UNIT_SPELLCAST_NOT_INTERRUPTIBLE',
	}

	if not tContains(t, eventCategory) then
		return false
	end

	targetUnit = targetUnit or SecureButton_GetUnit(castFrame) or 'none'

	if not unitFilter(castFrame, targetUnit) then
		return false
	end

	local _, _, _, _, startInstanceMili0, endInstanceMili0 =
	UnitCastingInfo(targetUnit)

	local _, _, _, _, startInstanceMili1, endInstanceMili1 =
	UnitChannelInfo(targetUnit)

	local endInstanceMili = endInstanceMili0 or endInstanceMili1 or 0
	local startInstanceMili = startInstanceMili0 or startInstanceMili1 or 0

	local endInstanceSec = endInstanceMili / 1000
	local startInstanceSec = startInstanceMili / 1000

	castFrame:SetMinMaxValues(startInstanceSec, endInstanceSec)
	local now = GetTime()
	castFrame:SetValue(now)

	return true
end

local function guessTargetUnit(castFrame, eventCategory, targetUnit)
	assert(castFrame ~= nil)

	if targetUnit ~= nil then
		return targetUnit
	end

	if 'PLAYER_FOCUS_CHANGED' == eventCategory then
		return 'focus'
	elseif 'PLAYER_TARGET_CHANGED' == eventCategory  then
		return 'target'
	end

	return targetUnit
end

local function castFrameEventProcessor(castFrame, eventCategory, targetUnit, ...)
	assert(castFrame ~= nil)

	assert(eventCategory ~= nil)

	local u = SecureButton_GetUnit(castFrame) or 'none'

	if not UnitExists(u) then
		castFrame:Hide()
		return
	end

	targetUnit = targetUnit or guessTargetUnit(castFrame, eventCategory, targetUnit)

	spellcastBegin(castFrame, eventCategory, targetUnit, ...)
	spellcastEnd(castFrame, eventCategory, targetUnit, ...)
	spellcastUpdate(castFrame, eventCategory, targetUnit, ...)
end

local function castFrameUpdateProcessor(castFrame)
	assert(castFrame ~= nil)

	local now = GetTime()

	local a, b = castFrame:GetMinMaxValues()

	if 2 == castFrame.strategy then
		castFrame:SetValue(a + b - now)
	else
		castFrame:SetValue(now)
	end
end

--[[--
Initialize the spell cast progress frame.

This is a minimalist naive spell cast bar, used for larger unit buttons.

@function castFrameMain
@tparam frame self this cast frame
]]
local function castFrameMain(self)
	assert(self ~= nil)

	local n = self:GetName() or ''
	assert(n ~= nil)

	self.artwork1 = _G[n .. 'Artwork1']
	assert(self.artwork1 ~= nil)

	self.label1 = _G[n .. 'Text1']
	assert(self.label1 ~= nil)

	self.label2 = _G[n .. 'Text2']
	assert(self.label2 ~= nil)

	local statusBarName = string.format('%sStatusBar', n)
	local statusBar = _G[statusBarName]
	assert(statusBar ~= nil)
	self.statusBar = statusBar

	self.SetValue = function(...)
		return statusBar:SetValue(select(2, ...))
	end

	self.GetValue = function()
		return statusBar:GetValue()
	end

	self.SetMinMaxValues = function(...)
		return statusBar:SetMinMaxValues(select(2, ...))
	end

	self.GetMinMaxValues = function()
		return statusBar:GetMinMaxValues()
	end

	self.SetStatusBarColor = function(...)
		return statusBar:SetStatusBarColor(select(2, ...))
	end

	statusBar:SetFrameLevel(0)
	self:SetFrameLevel(statusBar:GetFrameLevel() + 2)

	self.artwork2 = _G[string.format('%sArtwork', statusBar:GetName())]

	--[[-- @fixme When owner unit changes, the cast bar must update, but does not.
	]]

	self:SetScript('OnEvent', castFrameEventProcessor)
	self:SetScript('OnUpdate', castFrameUpdateProcessor)

	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_FOCUS_CHANGED");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	self:RegisterEvent("UNIT_SPELLCAST_DELAYED");
	self:RegisterEvent("UNIT_SPELLCAST_FAILED");
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
	self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
	self:RegisterEvent("UNIT_SPELLCAST_START");
	self:RegisterEvent("UNIT_SPELLCAST_STOP");
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	self:RegisterEvent("ZONE_CHANGED");
end

Chorus.castFrameMain = function(...)
	return castFrameMain(...)
end
