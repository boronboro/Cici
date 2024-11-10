--[[--
@submodule chorus

@todo Since `function UnitSetRole` is backported, implement mechanism to set it
automatically, inferred from talents.
]]

local Chorus = Chorus

local strtrim = strtrim

local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitGroupRolesAssigned = Chorus.test.UnitGroupRolesAssigned or UnitGroupRolesAssigned
local UnitIsConnected = Chorus.test.UnitIsConnected or UnitIsConnected

local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

local fallbackRoleMap

local cache = {}

local function updateEveryRoleWidget()
	assert(cache ~= nil)
	assert('table' == type(cache))

	for _, frame in pairs(cache) do
		if frame then
			local callback = frame:GetScript('OnEvent')
			if callback then
				callback(frame, 'PARTY_MEMBERS_CHANGED')
			end
		end
	end
end

--[[
Set fallback unit group role for given unit.

When unit role is checked by role widget that this module implements, given
role could not be determined by any other means, use the role that was assigned
using this function.

It is expected from the user to call this function manually or at least
explicitly with a thin layer of graphical buttons.

@function UnitSetRole
@tparam string unitDesignation unit to which assign the role
@tparam string unitDesignation either `DAMAGER`, `HEALER` or `TANK`
@treturn bool
]]
function Chorus.UnitSetRole(unitDesignation, roleDesignation)
	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))
	unitDesignation = string.lower(strtrim(unitDesignation))
	assert(string.len(unitDesignation) >= 1)
	assert(string.len(unitDesignation) <= 256)

	assert(roleDesignation ~= nil)
	assert('string' == type(roleDesignation))
	roleDesignation = string.upper(strtrim(roleDesignation))
	assert(string.len(roleDesignation) >= 1)
	assert(string.len(roleDesignation) <= 256)

	assert('TANK' == roleDesignation or 'HEALER' ==
	roleDesignation or 'DAMAGER' == roleDesignation,
	'invalid argument: invalid enum: must be valid player ' ..
	'group role string')

	if not UnitExists(unitDesignation) then
		return false
	end

	local i = UnitGUID(unitDesignation)
	if not i then
		return false
	end

	fallbackRoleMap[i] = roleDesignation

	updateEveryRoleWidget()

	return true
end

do
	--[[ Backport `function UnitSetRole` from Cata back to Wrath. ]]--
	if not UnitSetRole and 40000 > select(4, GetBuildInfo()) then
		UnitSetRole = Chorus.UnitSetRole
	end
end

--[[--
Query the role designation of the given unit.

This function is intended to work for both Cataclysm and Wrath clients equally.

First, this function will query the game with native API. Second, if there is a
override explicitly set by the user, the function will evaluate the override.

@function getUnitGroupRoleDesignation
@tparam string unitDesignation unit to query the role of
@treturn string either `TANK`, `HEALER` or `DAMAGER`.
]]
local function getUnitGroupRoleDesignation(unitDesignation)
	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))

	assert(fallbackRoleMap ~= nil)
	assert('table' == type(fallbackRoleMap))

	local roleDesignation

	local interfaceNumber = select(4, GetBuildInfo())
	if 40000 > interfaceNumber then
		--[[ Is Wrath ]]--
		local isTank, isHealer, isDamage = UnitGroupRolesAssigned(unitDesignation)

		if isTank then
			roleDesignation = 'TANK'
		elseif isHealer then
			roleDesignation = 'HEALER'
		elseif isDamage then
			roleDesignation = 'DAMAGER'
		end
	else
		--[[ Is Cata ]]--
		--[[ TODO Test if the role widget implementation works on both 30300 and 40000. ]]--
		roleDesignation = UnitGroupRolesAssigned(unitDesignation)
	end

	if not roleDesignation then
		local i = UnitGUID(unitDesignation)
		if i then
			roleDesignation = fallbackRoleMap[i]
		else
			roleDesignation = nil
		end
	end

	return roleDesignation
end

local function setArtwork(artwork, a, b, c, d)
	assert(artwork ~= nil)
	a = math.min(math.max(0, a), 1)
	b = math.min(math.max(0, b), 1)
	c = math.min(math.max(0, c), 1)
	d = math.min(math.max(0, d), 1)
	artwork:SetTexCoord(a, b, c, d)
end

local function setArtworkTank(artwork)
	local size = 64
	setArtwork(artwork, 0 / size, 19 / size, 22 / size, 41 / size)
end

local function setArtworkHealer(artwork)
	local size = 64
	setArtwork(artwork, 20 / size, 39 / size, 1 / size, 20 / size)
end

local function setArtworkDamager(artwork)
	local size = 64
	setArtwork(artwork, 20 / size, 39 / size, 22 / size, 41 / size)
end

local function applyRole(self, roleDesignation)
	assert(self ~= nil)

	if not roleDesignation then
		self:Hide()
		return
	end

	assert(roleDesignation ~= nil)

	assert('TANK' == roleDesignation or 'HEALER' == roleDesignation or
	'DAMAGER' == roleDesignation, 'invalid argument: invalid enum')

	local artwork = self.artwork or _G[self:GetName() .. 'Artwork']
	assert(artwork ~= nil)

	if 'TANK' == roleDesignation then
		setArtworkTank(artwork)
	elseif 'HEALER' == roleDesignation then
		setArtworkHealer(artwork)
	elseif 'DAMAGER' == roleDesignation then
		setArtworkDamager(artwork)
	else
		self:Hide()
		return
	end
	self:Show()
end

local function eventProcessor(self)
	assert(self ~= nil)

	local unitDesignation = SecureButton_GetUnit(self)

	if not unitDesignation or not UnitExists(unitDesignation) or not
		UnitIsConnected(unitDesignation) then
		self:Hide()
		return
	end

	local roleDesignation = getUnitGroupRoleDesignation(unitDesignation)
	applyRole(self, roleDesignation)
end

local function roleMapFrameMain(self)
	assert(self ~= nil)

	self:RegisterEvent('VARIABLES_LOADED')
	self:SetScript('OnEvent', function()
		if not ChorusUnitGroupRoleMap then
			ChorusUnitGroupRoleMap = {}
		end
		fallbackRoleMap = ChorusUnitGroupRoleMap or {}
		assert(fallbackRoleMap ~= nil)
		assert('table' == type(fallbackRoleMap))
	end)
end

--[[--
@function unitGroupRoleFrameMain
@tparam frame self this unit group role frame
]]
local function unitGroupRoleFrameMain(self)
	assert(self ~= nil)

	local artwork = _G[self:GetName() .. 'Artwork']
	assert(artwork ~= nil)
	self.artwork = artwork

	self:RegisterEvent('PARTY_CONVERTED_TO_RAID')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('RAID_ROSTER_UPDATE')

	self:SetScript('OnEvent', eventProcessor)

	cache[self:GetName()] = self
end

Chorus.unitGroupRoleMapFrameMain = function(...)
	return roleMapFrameMain(...)
end
Chorus.unitGroupRoleFrameMain = function(...)
	return unitGroupRoleFrameMain(...)
end
