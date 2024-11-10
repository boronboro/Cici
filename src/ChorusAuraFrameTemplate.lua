--[[--
`ChorusAuraFrameTemplate` handles subsets of unit auras, individual aura
buttons are handled by `ChorusAuraButtonTemplate`.

@submodule chorus
]]

local Chorus = Chorus

local auraButtonEventProcessor = Chorus.auraButtonEventProcessor

local UnitAura = Chorus.test.UnitAura or UnitAura
local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitIsConnected = Chorus.test.UnitIsConnected or UnitIsConnected

local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

--[[ See `FrameXML/BuffFrame.lua:BUFF_MAX_DISPLAY`. ]]--
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY or 36
--[[ See `FrameXML/BuffFrame.lua:DEBUFF_MAX_DISPLAY`. ]]--
local DEBUFF_MAX_DISPLAY = DEBUFF_MAX_DISPLAY or 36

local auraWeightMap = ChorusAuraWeightMap

--[[--
Query the game for a given aura, then compute the weight for it, that is used
in when aura frame is sorted.

The weight is computed using remaining duration, owner of the aura (player
auras take priority), and special exceptions.

@function getAuraWeight
@see ChorusAuraWeightMap
@string unitDesignation unit as in `function UnitAura`
@int auraIndex sequential number starting from 1 as in `function UnitAura`
@string filter aura filter descriptor, usually either `HELPFUL` or `HARMFUL`, as in `function UnitAura`
@treturn int aura weight in [0,90000], the larger the number the more likely the aura is to be shown first
]]
local function getAuraWeight(unitDesignation, auraIndex, filter)
	local name, _, _, _, _, durationSec, owner = UnitAura(unitDesignation, auraIndex, filter)
	if not name then
		return 0
	end

	local specialPrio = auraWeightMap[name] or 0
	specialPrio = math.min(math.max(1, math.floor(math.abs(specialPrio))), 9)

	local durationIsLimited = 1
	if not durationSec or durationSec < 1 then
		durationIsLimited = 0
	end

	local ownerPrio = 1
	if 'player' == owner then
		ownerPrio = 2
	end

	local weight = 100000 * ownerPrio +
	               10000 * specialPrio +
		       durationIsLimited * (7201 - math.min(durationSec, 7200))
	return math.abs(math.floor(weight))
end

local function getAuraPriorityList(unitDesignation, filter)
	local t = {}
	local i = 0
	while (i < 8192) do
		i = i + 1
		local name = UnitAura(unitDesignation, i, filter)
		if not name then
			break
		end
		t[i] = i
	end

	table.sort(t, function(a, b)
		local p = getAuraWeight(unitDesignation, a, filter)
		local q = getAuraWeight(unitDesignation, b, filter)
		return p > q
	end)

	return t
end

local function auraFrameEventProcessor(self, eventCategory, ...)
	assert(self ~= nil)

	--[[ Optimization hack ]]--
	--[[ Make it use table value if it lags again. ]]--
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

	if 'UNIT_AURA' == eventCategory then
		local u = select(1, ...)
		if u and 'string' == type(u) and unitDesignation ~= u then
			return
		end
	end

	--[[ Make it use table value if it lags again. ]]--
	local filter = SecureButton_GetAttribute(self, 'filter')
	assert(filter ~= nil)
	assert('string' == type(filter))
	filter = string.upper(strtrim(filter))
	assert(string.len(filter) >= 1)
	assert(string.len(filter) <= 256)

	local q = getAuraPriorityList(unitDesignation, filter)
	assert(q ~= nil)
	assert('table' == type(q))

	local i = 0
	local t = {self:GetChildren()}
	while (i < #q) do
		i = i + 1
		local b = t[i]
		if not b then
			break
		end
		assert(b ~= nil)

		local k = q[i]
		assert(k ~= nil)
		assert('number' == type(k))
		k = math.floor(math.abs(k))
		assert(k >= 0)
		b.index = k

		auraButtonEventProcessor(b, eventCategory, ...)
	end

	while (i < #t) do
		i = i + 1
		local b = t[i]
		assert(b ~= nil)
		b.index = 0

		auraButtonEventProcessor(b, eventCategory, ...)
	end
end

local function createEveryAuraButton(auraFrame)
	local self = auraFrame
	assert(self ~= nil)

	local n = self:GetName()
	assert(n ~= nil)

	local max = math.max(BUFF_MAX_DISPLAY or 36, DEBUFF_MAX_DISPLAY or 36) or 36
	local i = 0
	local w = math.max(self:GetWidth(), 30)
	local bmaxh = 30
	local x = 0
	local y = 0
	while (i < max) do
		i = i + 1

		local m = string.format('%sAuraButton%02d', n, i)
		local b = CreateFrame('FRAME', m, self, 'ChorusAuraButtonTemplate')
		b:SetPoint('TOPLEFT', x, -y)
		x = x + b:GetWidth()
		bmaxh = math.max(bmaxh, b:GetHeight())
		if x > w then
			x = 0
			y = y + bmaxh
		end
	end
end

local function validateAuraWeightMap(t)
	assert(t ~= nil)
	assert('table' == type(t))
	for spellName, weightNumber in pairs(t) do
		assert(spellName ~= nil)
		assert('string' == type(spellName))
		spellName = strtrim(spellName)
		assert(string.len(spellName) >= 1)
		assert(string.len(spellName) <= 256)

		assert(weightNumber ~= nil)
		assert('number' == type(weightNumber))
		assert(weightNumber >= 1)
		assert(weightNumber <= 9)
	end
end

--[[--
Initialize the aura frame. Given no aura buttons were explicitly decalred in an
XML descriptor, then allocate them with a best guess.

@function auraFrameMain
@tparam frame self the aura frame
@return nothing
]]
function Chorus.auraFrameMain(self)
	assert(self ~= nil)

	--[[ `main` function is called on frame load. Frames declared in the
	XML descriptor are allocated before that. It is preferrable to use
	the XML descriptor for performance and separation of concerns. When
	no descendant frames were declared in this manner or another,
	fallback to allocating required aura buttons dynamically. ]]--

	local createAuraButtonsDynamically = nil == self:GetChildren()
	if createAuraButtonsDynamically then
		createEveryAuraButton(self)
	end

	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('PLAYER_FOCUS_CHANGED')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('UNIT_AURA')

	--[[ Disable redundant aura updates. ]]--
	local t = {self:GetChildren()}
	local i = 0
	while (i < #t) do
		i = i + 1
		local b = t[i]
		if b then
			b:UnregisterEvent('UNIT_AURA')
		end
	end

	--[[ Optimization hack. This function call is expensive. Probably. ]]--
	self.unit = SecureButton_GetUnit(self)
	self.filter = SecureButton_GetAttribute(self, 'filter')

	self:SetScript('OnEvent', auraFrameEventProcessor)
	self:SetScript('OnShow', auraFrameEventProcessor)

	if auraWeightMap then
		validateAuraWeightMap(auraWeightMap)
	else
		print('ChorusAuraFrameTemplate.lua: warning: aura weight map empty or missing')
	end
end

function Chorus.getAuraWeight(...)
	return getAuraWeight(...)
end

function Chorus.getAuraPriorityList(...)
	return getAuraPriorityList(...)
end
