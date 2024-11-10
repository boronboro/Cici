--[[--
@submodule chorus
]]

local Chorus = Chorus

local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitInParty = Chorus.test.UnitInParty or UnitInParty
local UnitInRaid = Chorus.test.UnitInRaid or UnitInRaid
local UnitInRange = Chorus.test.UnitInRange or UnitInRange
local UnitIsConnected = Chorus.test.UnitIsConnected or UnitIsConnected

--[[ Targets of raid or party members or targets of targets (TOT) do not update
     automatically. The add-on has to poll for it and update the frames
     explicitly. There is no event trigger to do this natively. ]]--
local function applyTOT(self)
	assert(self ~= nil)

	local n = self:GetName()
	assert(n ~= nil)

	local u = self:GetAttribute('unit')

	if not u or not UnitExists(u) or not UnitIsConnected(u) then
		return
	end

	local unitNameFrame = self.unitNameFrame
	if unitNameFrame then
		local callback0 = unitNameFrame:GetScript('OnEvent')
		callback0(unitNameFrame, 'UNIT_NAME_UPDATE', u)
	end

	local healthFrame = self.healthFrame
	if healthFrame then
		local callback1 = healthFrame:GetScript('OnEvent')
		callback1(healthFrame, 'UNIT_HEALTH', u)
	end

	local powerFrame = self.powerFrame
	if powerFrame then
		local callback2 = powerFrame:GetScript('OnEvent')
		callback2(powerFrame, 'UNIT_POWER', u)
	end

	--[[ Notify backdrop to toggle visibility when appropriate. ]]--
	local backdropFrame = self.backdropFrame
	if backdropFrame then
		local callback3 = backdropFrame:GetScript('OnEvent')
		--[[ Skip checks and error handing for performance. ]]--
		callback3(backdropFrame)
	end
end

local function applyUnitInRange(self)
	local u = self:GetAttribute('unit')
	if not u then
		return
	end

	local a = 1
	if UnitExists(u) and UnitIsConnected(u) and (UnitInRaid(u) or UnitInParty(u)) then
		--[[ `function UnitInRange` only works for group members. ]]--
		if not UnitInRange(u) then
			a = 0.6
		end
	else
		self:SetAlpha(1)
		return
	end

	--[[ Only apply transparency to select subset of children or referenced
	frames. Specifically exclude ChorusAuraTooltipFrame instances. ]]--

	local healthFrame = self.healthFrame
	local powerFrame = self.powerFrame
	local buffFrame = self.buffFrame
	local debuffFrame = self.debuffFrame

	if healthFrame then
		healthFrame:SetAlpha(a)
	end

	if powerFrame then
		powerFrame:SetAlpha(a)
	end

	if buffFrame then
		buffFrame:SetAlpha(a)
	end

	if debuffFrame then
		debuffFrame:SetAlpha(a)
	end
end

function Chorus.unitFrameUnitInRangeUpdateProcessor(self)
	--[[ Reduce update frequency to roughly 6 frames per second. ]]--
	if self.lastUpdateInstance and 'number' == type(self.lastUpdateInstance) then
		local now = GetTime()
		if now - self.lastUpdateInstance > 0.1667 then
			self.lastUpdateInstance = now
		else
			return
		end
	else
		self.lastUpdateInstance = GetTime()
	end

	applyUnitInRange(self)
end

function Chorus.unitFrameTOTUpdateProcessor(self)
	--[[ Reduce update frequency to roughly 6 frames per second. ]]--
	if self.lastUpdateInstance and 'number' == type(self.lastUpdateInstance) then
		local now = GetTime()
		if now - self.lastUpdateInstance > 0.1667 then
			self.lastUpdateInstance = now
		else
			return
		end
	else
		self.lastUpdateInstance = GetTime()
	end

	applyTOT(self)
end

--[[
Inherit given property from self to all it's children once unprotected. Used at
initialization for performance considerations. This is a property access
optimization for children frame implementations.  ]]
local function applyCascadeProperty(self, attributeName, value)
	assert(self ~= nil)

	assert(attributeName ~= nil)
	assert('string' == type(attributeName))

	value = value or self:GetAttribute(attributeName)

	local useparentKey = string.format('useparent-%s', attributeName)

	local t = {self:GetChildren()}
	local i = 0
	while (i < #t) do
		i = i + 1
		local f = t[i]
		if f then
			local superFlag = f:GetAttribute(useparentKey) or f:GetAttribute('useparent*')
			if superFlag then
				f:SetAttribute(attributeName, value)
			end
		end
	end
end

--[[
Inherit unit property from self to all it's children every time the property is
changed in a protected manner. This is a robustness feature used dynamically at
runtime, to make sure the frame behaves as expected even in somewhat unforseen
configurations. This is part of a performance optimization aspect for property
access. ]]
local function applySecureInheritance(self, secureHandler)
	assert(self ~= nil)

	local n = self:GetName()
	assert(n ~= nil)

	secureHandler = secureHandler or _G[n .. 'SecureHandlerAttributeFrame']
	assert(secureHandler ~= nil)

	secureHandler:WrapScript(self, 'OnAttributeChanged', [=[
		print('protected', self:GetName(), name, value)
		if not name then
			return
		end
		if 'unit' ~= name then
			return
		end
		local t = self:GetChildList(newtable())
		local i = 0
		local useparentKey = string.format('useparent-%s', name)
		while (i < #t) do
			i = i + 1
			local f = t[i]
			if f and (f:GetAttribute(useparentKey) or f:GetAttribute('useparent*')) then
				f:SetAttribute(name, value)
				print('protected', f:GetName(), name, f:GetAttribute(name))
			end
		end
	]=])
end

local function attributeProcessor(self, name, value)
	assert(self ~= nil)

	if 'unit' == name then
		applyCascadeProperty(self, name, value)
	end
end

--[[--
`ChorusUnitFrameTemplate` is the root template for all unit button variations.

All widgets are conditionally included as children to instances of this
template. For example health bars, power bars, aura frames, combat indicator,
range indicator. These widgets are separated into their own templates.

The template is further specialized into the following profiles.

  * `ChorusTinyUnitFrameTemplate`;
  * `ChorusSmallUnitFrameTemplate`;
  * `ChorusLargeUnitFrameTemplate`;
  * `ChorusHugeUnitFrameTemplate`;

When instancing a unit button, one of these specializations is to be used.

Group frame templates may define further specialized templates.

@function unitFrameMain
]]
local function unitFrameMain(self)
	assert(self ~= nil)

	local n = self:GetName()
	assert(n ~= nil)

	local secureHandler =  _G[n .. 'SecureHandlerAttributeFrame']
	assert(secureHandler ~= nil)

	local _, explicitlySecureFlag = self:IsProtected()
	if explicitlySecureFlag then
		applySecureInheritance(self, secureHandler)
	end

	--[[ Initialize frames. Does not work in restricted environment. Never
	rely on this at runtime. ]]--

	if self:GetAttribute('unit') then
		applyCascadeProperty(self, 'unit')
	end
	self:SetScript('OnAttributeChanged', attributeProcessor)

	local unitNameFrame = _G[self:GetName() .. 'UnitNameFrame']
	self.unitNameFrame = unitNameFrame
	local healthFrame = _G[self:GetName() .. 'HealthFrame']
	self.healthFrame = healthFrame
	local powerFrame = _G[self:GetName() .. 'PowerFrame']
	self.powerFrame = powerFrame
	local buffFrame = _G[self:GetName() .. 'BuffFrame']
	self.buffFrame = buffFrame
	local debuffFrame = _G[self:GetName() .. 'DebuffFrame']
	self.debuffFrame = debuffFrame
	local backdropFrame = _G[string.format('%sBackdrop', self:GetName() or '')]
	self.backdropFrame = backdropFrame
end

local function unitMemberFrameMain(self, ...)
	unitFrameMain(self, ...)

	local healthFrame = self.healthFrame
	if healthFrame then
		healthFrame.strategy = 'UnitClass'
	end
end

Chorus.unitFrameMain = function(...)
	return unitFrameMain(...)
end

Chorus.unitMemberFrameMain = function(...)
	return unitMemberFrameMain(...)
end
