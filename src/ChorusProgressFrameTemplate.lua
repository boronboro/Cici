--[[--
@submodule chorus
]]

local Chorus = Chorus

local UnitClass = Chorus.test.UnitClass or UnitClass
local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitHealth = Chorus.test.UnitHealth or UnitHealth
local UnitHealthMax = Chorus.test.UnitHealthMax or UnitHealthMax
local UnitIsConnected = Chorus.test.UnitIsConnected or UnitIsConnected
local UnitIsCorpse = Chorus.test.UnitIsCorpse or UnitIsCorpse
local UnitIsDead = Chorus.test.UnitIsDead or UnitIsDead
local UnitIsGhost = Chorus.test.UnitIsGhost or UnitIsGhost
local UnitIsPlayer = Chorus.test.UnitIsPlayer or UnitIsPlayer
local UnitPower = Chorus.test.UnitPower or UnitPower
local UnitPowerMax = Chorus.test.UnitPowerMax or UnitPowerMax
local UnitPowerType = Chorus.test.UnitPowerType or UnitPowerType

--[[ See `FrameXML/GlobalStrings.lua`. ]]--
local CORPSE = CORPSE or 'CORPSE'
local DEAD = DEAD or 'DEAD'
local DEATH_RELEASE = DEATH_RELEASE or 'DEATH_RELEASE'
local PLAYER_OFFLINE = PLAYER_OFFLINE or 'PLAYER_OFFLINE'

local PowerBarColor = PowerBarColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

local function validateProgressFrame(self)
	assert(self ~= nil)

	local artwork = self.artwork
	assert(artwork ~= nil)

	local ratio = self:GetValue()
	assert(ratio ~= nil)
	assert('number' == type(ratio))
	assert(ratio >= 0.0)
	assert(ratio <= 1.0)

	local strategy = self.strategy
	if strategy then
		assert('string' == type(strategy))
		strategy = strtrim(strategy)
		assert(string.len(strategy) >= 1)
		assert(string.len(strategy) <= 8192)
	end
end

local function getRatio(a, b)
	if not a or not b then
		return 0
	end

	assert(a ~= nil)
	assert('number' == type(a))
	assert(a >= 0)

	if a <= 0 or b <= 0 then
		return 0
	end

	assert(b ~= nil)
	assert('number' == type(b))
	assert(b > 0)

	assert(a <= b)

	local x = math.min(math.abs(a), math.abs(b))
	local y = math.max(math.abs(a), math.abs(b))
	y = math.max(y, 1)
	assert(y > 0)

	local ratio = x / y
	ratio = math.min(math.max(0, math.abs(ratio)), 1)

	return ratio
end

local function applyRatio(self, a, b)
	assert(self ~= nil)

	local ratio = 0

	--[[ Strict sanitization to work around WoW API quirks. ]]--
	if a and b then
		assert('number' == type(a))
		assert('number' == type(b))
		local x = math.min(a, b)
		local y = math.max(a, b)
		if x <= y then
			ratio = getRatio(x, y)
		end
	end

	self:SetValue(ratio)
end

local function formatQuantity(quantity)
	assert(quantity ~= nil)
	assert('number' == type(quantity))

	local t
	if math.abs(quantity) < 1000 then
		t = string.format('%d',quantity)
	elseif math.abs(quantity) < 1000000 then
		t = string.format('%.2f K', quantity / 1000)
	else
		t = string.format('%.2f M', quantity /  1000000)
	end

	return t
end

local function applyOverlay(self, a, b)
	assert(self ~= nil)

	assert(a ~= nil)
	assert('number' == type(a))
	assert(a >= 0)

	assert(b ~= nil)
	assert('number' == type(b))
	--[[ Work around quirks of the native API. ]]--
	b = math.max(b, 1)
	assert(b > 0)

	if a > b then
		return
	end
	assert(a <= b)

	local ratio = getRatio(a, b)

	local label1 = self.label1 or _G[self:GetName() .. 'Text1']
	if label1 then
		local e = string.format('%.0f%%', ratio * 100)
		label1:SetText(e)

		--[[ ShadowedUnitFrames recommend this approach for adjusting font size. ]]--
		if e ~= nil and string.len(e) >= 1 then
			local fontSize = 12
			self:SetScale(label1:GetStringHeight() / fontSize)
		end
	else
		return
	end

	local label2 = self.label2 or _G[self:GetName() .. 'Text2']
	if label2 then
		local t = formatQuantity(a)
		label2:SetText(t)

		--[[ ShadowedUnitFrames recommend this approach for adjusting font size. ]]--
		if t ~= nil and string.len(t) >= 1 then
			local fontSize = 12
			self:SetScale(label2:GetStringHeight() / fontSize)
		end
	else
		return
	end
end

local function applyRatioHealth(self, unitDesignation)
	assert(self ~= nil)

	assert(unitDesignation ~= nil)

	local a
	local b
	if not UnitExists(unitDesignation) or
	   not UnitIsConnected(unitDesignation) or
	   UnitIsDead(unitDesignation) or
	   UnitIsCorpse(unitDesignation) or
	   UnitIsGhost(unitDesignation) then
		a = 0
		b = 1
	else
		a = UnitHealth(unitDesignation) or 0
		b = UnitHealthMax(unitDesignation) or 1
	end

	applyRatio(self, a, b)
end

local function applyOverlayHealthDeficit(self, a, b)
	assert(self ~= nil)

	local label3 = self.label3 or _G[self:GetName() .. 'Text3']
	if not label3 then
		return
	end

	if a and b and a >= 1 and b >= 1 and a < b then
		local c = a - b
		local t = formatQuantity(c)
		label3:SetText(t)
	else
		label3:SetText(nil)
	end
end

--[[--
Update this health frame with the state of the given unit.

@see FrameXML/GlobalStrings.lua:CORPSE

@function applyOverlayHealth
@tparam frame self this health frame
@tparam string unitDesignation given unit
]]
local function applyOverlayHealth(self, unitDesignation)
	assert(self ~= nil)

	assert(unitDesignation ~= nil)

	local u = unitDesignation
	local a = UnitHealth(u)
	local b = UnitHealthMax(u)

	if a and b and a <= b and b >= 1 and
	   UnitExists(u) and
	   UnitIsConnected(u) and
	   not UnitIsDead(u) and
	   not UnitIsCorpse(u) and
	   not UnitIsGhost(u) then
		applyOverlay(self, a, b)
		applyOverlayHealthDeficit(self, a, b)
	else
		--[[-- @todo Separate health status bar and unit statues.
		]]
		local t = {self.label1, self.label2, self.label3}
		local i = 0
		while (i < #t) do
			i = i + 1
			local label = t[i]
			if label then
				label:SetText(nil)
			end
		end

		local label1 = self.label1
		if not label1 then
			return
		end

		local s = nil
		if UnitIsCorpse(unitDesignation) then
			s = '(' .. (CORPSE or 'CORPSE') .. ')'
		elseif UnitIsGhost(unitDesignation) then
			s = '(' .. (DEATH_RELEASE or 'GHOST') .. ')'
		elseif UnitIsDead(unitDesignation) then
			s = '(' .. (DEAD or 'DEAD') .. ')'
		elseif not UnitIsConnected(unitDesignation) then
			---- @fixme The 'Player offline' label is never rendered.

			---- @todo Add separate offline indicator widget.
			s = '(' .. (PLAYER_OFFLINE or 'PLAYER_OFFLINE') .. ')'
		end
		label1:SetText(s)
	end
end

local function applyRatioPower(self, unitDesignation, powerTypeEnum)
	assert(self ~= nil)
	assert(unitDesignation ~= nil)
	assert(powerTypeEnum ~= nil)

	local a = UnitPower(unitDesignation, powerTypeEnum) or 0
	local b = UnitPowerMax(unitDesignation, powerTypeEnum) or 1
	applyRatio(self, a, b)
end

local function applyOverlayPower(self, unitDesignation, powerTypeEnum)
	assert(self ~= nil)
	assert(unitDesignation ~= nil)
	assert(powerTypeEnum ~= nil)

	local a = UnitPower(unitDesignation, powerTypeEnum) or 0
	local b = UnitPowerMax(unitDesignation, powerTypeEnum) or 1
	applyOverlay(self, a, b)
end

local function applyHealthFrameColorUnitClass(self, unitDesignation)
	assert(self ~= nil)
	assert(unitDesignation ~= nil)

	local _, classDesignation = UnitClass(unitDesignation)
	if not classDesignation then
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

	local artwork = self.artwork
	assert(artwork ~= nil)

	local image = artwork:GetTexture()
	if  image then
		artwork:SetVertexColor(r, g, b)
	else
		artwork:SetTexture(r, g, b)
	end
end

local function applyHealthFrameColorUnitIsFriend(self, unitDesignation)
	assert(self ~= nil)
	assert(unitDesignation ~= nil)

	local r = 255 / 255
	local g = 215 / 255
	local b = 0 / 255

	if UnitIsFriend('player', unitDesignation) then
		r = 124 / 255
		g = 252 / 255
		b = 0 / 255
	elseif UnitIsEnemy('player', unitDesignation) then
		r = 255 / 255
		g = 69 / 255
		b = 0 / 255
	end

	local artwork = self.artwork
	assert(artwork ~= nil)

	local image = artwork:GetTexture()
	if  image then
		artwork:SetVertexColor(r, g, b)
	else
		artwork:SetTexture(r, g, b)
	end
end

local function healthFrameEventIsRelevant(self, eventCategory, ...)
	assert(self ~= nil)

	assert(eventCategory ~= nil)

	local targetUnit = select(1, ...)
	if targetUnit then
		local unitDesignation = SecureButton_GetUnit(self) or 'none'
		return UnitIsUnit(unitDesignation, targetUnit)
	end
	return true
end

local function healthFrameEventProcessor(self, eventCategory, ...)
	validateProgressFrame(self)

	if not healthFrameEventIsRelevant(self, eventCategory, ...) then
		return
	end

	local unitDesignation = SecureButton_GetUnit(self) or 'none'

	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))
	unitDesignation = string.lower(strtrim(unitDesignation))
	assert(string.len(unitDesignation) >= 1)
	assert(string.len(unitDesignation) <= 256)

	if UnitExists(unitDesignation) and UnitIsConnected(unitDesignation) then
		self:Show()
	else
		self:Hide()
		return
	end

	applyRatioHealth(self, unitDesignation)
	applyOverlayHealth(self, unitDesignation)

	local strategy = self.strategy
	assert(strategy ~= nil)
	assert('string' == type(strategy))
	strategy = strtrim(strategy)
	assert(string.len(strategy) >= 1)
	assert(string.len(strategy) <= 256)

	assert(strategy == 'UnitClass' or strategy == 'UnitIsFriend')

	if 'UnitClass' == strategy then
		--[[ `function UnitClass` only works for player units. ]]--
		if UnitIsPlayer(unitDesignation) then
			applyHealthFrameColorUnitClass(self, unitDesignation)
		else
			applyHealthFrameColorUnitIsFriend(self, unitDesignation)
		end
	elseif 'UnitIsFriend' == strategy then
		applyHealthFrameColorUnitIsFriend(self, unitDesignation)
	else
		error('invalid enum: strategy must be either UnitClass or UnitIsFriend')
	end
end

local function applyPowerFrameColor(self, powerTypeEnum)
	assert(self ~= nil)

	local r = 1
	local g = 0
	local b = 1
	if powerTypeEnum then
		--[[ See FrameXML/UnitFrame.lua:PowerBarColor ]]--
		local map = PowerBarColor
		assert(map ~= nil)
		assert('table' == type(map))

		local colorTuple = map[powerTypeEnum]
		if colorTuple then
			assert('table' == type(colorTuple))
			r = math.min(math.max(0, math.abs(colorTuple.r)), 1)
			g = math.min(math.max(0, math.abs(colorTuple.g)), 1)
			b = math.min(math.max(0, math.abs(colorTuple.b)), 1)
		end
	end

	local artwork = self.artwork
	assert(artwork ~= nil)

	local image = artwork:GetTexture()
	if  image then
		artwork:SetVertexColor(r, g, b)
	else
		artwork:SetTexture(r, g, b)
	end
end

local function powerFrameEventProcessor(self, eventCategory, ...)
	validateProgressFrame(self)

	if not healthFrameEventIsRelevant(self, eventCategory, ...) then
		return
	end

	local unitDesignation = SecureButton_GetUnit(self) or 'none'

	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))
	unitDesignation = string.lower(strtrim(unitDesignation))
	assert(string.len(unitDesignation) >= 1)
	assert(string.len(unitDesignation) <= 256)

	if UnitExists(unitDesignation) and UnitIsConnected(unitDesignation) and UnitPowerMax(unitDesignation) >= 1 then
		self:Show()
	else
		self:Hide()
		return
	end

	local powerTypeEnum
	local strategy = self.strategy
	assert(strategy ~= nil)
	assert('string' == type(strategy))
	strategy = strtrim(strategy)
	assert(string.len(strategy) >= 1)
	assert(string.len(strategy) <= 256)
	if 'UnitPowerType' == strategy then
		local enum, category = UnitPowerType(unitDesignation)
		if category then
			powerTypeEnum = enum
		else
			self:Hide()
			return
		end
	else
		--[[ See FrameXML/Constants.lua:SPELL_POWER_MANA ]]--
		powerTypeEnum = _G[strategy]
	end
	assert(powerTypeEnum ~= nil)
	assert('number' == type(powerTypeEnum))
	assert(powerTypeEnum >= 0)
	powerTypeEnum = math.min(math.max(0, math.floor(math.abs(powerTypeEnum))), 8192)

	if UnitPowerMax(unitDesignation, powerTypeEnum) >= 1 then
		self:Show()
		applyRatioPower(self, unitDesignation, powerTypeEnum)
		applyOverlayPower(self, unitDesignation, powerTypeEnum)
		applyPowerFrameColor(self, powerTypeEnum)
	else
		self:Hide()
	end
end

--[[--
`ChorusProgressFrameTemplate` is a generalization for health bars and power
(mana) bars.

The features are shared between both health and power bars, but there exist
separate corresponding templates: `ChorusHealthFrameTemplate` and
`ChorusPowerFrameTemplate`.

Frames that inherit from this template may define field `strategy`. This field
may be either `UnitIsFriend` or `UnitPowerType`. The bar will be colored by
either unit reaction to the player, or the power type (blue for mana, red for
rage, etc.).

@function progressFrameMain
]]
function Chorus.progressFrameMain(self)
	assert(self ~= nil)

	local frameDesignation = self:GetName()
	assert(frameDesignation ~= nil)
	assert('string' == type(frameDesignation))
	frameDesignation = strtrim(frameDesignation)
	assert(string.len(frameDesignation) >= 1)
	assert(string.len(frameDesignation) <= 256)

	local artwork = _G[frameDesignation .. 'Artwork']
	assert(artwork ~= nil, self:GetName() .. ': invalid state')
	self.artwork = artwork

	local label1 = _G[frameDesignation .. 'Text1'] or nil
	self.label1 = label1

	local label2 = _G[frameDesignation .. 'Text2'] or nil
	self.label2 = label2

	local label3 = _G[frameDesignation .. 'Text3'] or nil
	self.label3 = label3

	self:RegisterEvent('PARTY_CONVERTED_TO_RAID')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('PARTY_MEMBER_DISABLE')
	self:RegisterEvent('PARTY_MEMBER_ENABLE')
	self:RegisterEvent('PLAYER_ALIVE')
	self:RegisterEvent('PLAYER_FOCUS_CHANGED')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('RAID_ROSTER_UPDATE')

	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
end

function Chorus.healthFrameMain(self, ...)
	Chorus.progressFrameMain(self, ...)
	self.strategy = 'UnitIsFriend'
	self:SetScript('OnEvent', healthFrameEventProcessor)

	self:RegisterEvent('UNIT_HEALTH')
end

function Chorus.powerFrameMain(self, ...)
	Chorus.progressFrameMain(self, ...)
	self.strategy = 'UnitPowerType'
	self:SetScript('OnEvent', powerFrameEventProcessor)

	self:RegisterEvent('UNIT_ENERGY')
	self:RegisterEvent('UNIT_MANA')
	self:RegisterEvent('UNIT_MAXPOWER')
	self:RegisterEvent('UNIT_POWER')
	self:RegisterEvent('UNIT_RAGE')
	self:RegisterEvent('UNIT_RUNIC_POWER')
end
