--[[--
@submodule chorus
]]

local GetNumPartyMembers = Chorus.test.GetNumPartyMembers or GetNumPartyMembers
local GetNumRaidMembers = Chorus.test.GetNumRaidMembers or GetNumRaidMembers
local InCombatLockdown = Chorus.test.InCombatLockdown or InCombatLockdown

local MAX_RAID_MEMBERS = MAX_RAID_MEMBERS or 40

local Chorus = Chorus
local ChorusLargeRaidFrame = ChorusLargeRaidFrame
local ChorusPartyFrame = ChorusPartyFrame
local ChorusSmallRaidFrame = ChorusSmallRaidFrame
local ChorusTinyRaidFrame = ChorusTinyRaidFrame

Chorus.groupProfileSet = {
	ChorusPartyFrame,
	ChorusLargeRaidFrame,
	ChorusSmallRaidFrame,
	ChorusTinyRaidFrame
}

local function produceSecureCommand()
	local t = {
		{'arena', 5, ChorusPartyFrame},
		{'party', 4, ChorusPartyFrame},
		{'raid', 5, ChorusLargeRaidFrame},
		{'raid', 25, ChorusSmallRaidFrame},
		{'raid', 40, ChorusTinyRaidFrame},
	}

	local secureCmd = ''
	local i = 0
	while (i < #t) do
		i = i + 1

		local r = t[i]

		assert(r ~= nil)
		assert('table' == type(r))
		assert(3 == #r)

		local j = 0

		local u = r[1]
		assert(u ~= nil)
		assert('string' == type(u))
		--[[ select(2, GetInstanceInfo()) == u ]]--
		assert('arena' == u or 'party' == u or 'raid' == u)

		local n = r[2]
		assert(n ~= nil)
		assert('number' == type(n))
		n = math.abs(math.ceil(n))
		assert(n >= 1)
		assert(n <= MAX_RAID_MEMBERS)

		local statement = ''
		while (j < n) do
			j = j + 1
			local predicate = string.format("[@%s%d,exists]", u, j)
			statement = statement .. predicate
		end

		local f = r[3]
		assert(f ~= nil)
		assert('table' == type(f) and 'userdata' == type(f[0]))

		local m = f:GetName()
		assert(m ~= nil)
		assert('string' == type(m))
		m = strtrim(m)
		assert(string.len(m) >= 1)

		statement = string.format("%s %s;\n", statement, m)

		secureCmd = secureCmd .. statement
	end

	return secureCmd
end


--[[--
Toggle the visibility raid group profile frame.

Evaluate a list of all possible raid frame profiles. Consider current player's
raid size and current zone. Then, show the most appropriate profile and hide
all others.

Each raid frame profile exists in memory from initialization.

This may only be run effectively in unrestricted execution environment, that is
out of combat.

The group frame secure handler implements the same feature. However, it uses
state drivers and secure frames, that may be executed in restricted environment
and during combat.

@function groupFrameToggleInsecure
@return nothing
]]
function Chorus.groupFrameToggleInsecure(...)
	--[[ @fixme ]]--
	if InCombatLockdown() then
		return
	end

	if 'ADDON_LOADED' == select(2, ...)  then
		if 'chorus' ~= select(3, ...) then
			return
		end
	end

	local n = GetNumRaidMembers() or 0

	if n > 25 then
		ChorusLargeRaidFrame:Hide()
		ChorusPartyFrame:Hide()
		ChorusSmallRaidFrame:Hide()
		ChorusTinyRaidFrame:Show()
	elseif n > 5 then
		ChorusLargeRaidFrame:Hide()
		ChorusPartyFrame:Hide()
		ChorusSmallRaidFrame:Show()
		ChorusTinyRaidFrame:Hide()
	elseif n >= 1 then
		ChorusLargeRaidFrame:Show()
		ChorusPartyFrame:Hide()
		ChorusSmallRaidFrame:Hide()
		ChorusTinyRaidFrame:Hide()
	elseif UnitPlayerOrPetInParty('party1') or (GetNumPartyMembers() or 0) > 0 then
		ChorusLargeRaidFrame:Hide()
		ChorusPartyFrame:Show()
		ChorusSmallRaidFrame:Hide()
		ChorusTinyRaidFrame:Hide()
	elseif n <= 0 then
		ChorusLargeRaidFrame:Hide()
		ChorusPartyFrame:Hide()
		ChorusSmallRaidFrame:Hide()
		ChorusTinyRaidFrame:Hide()
	end
end

--[[--
`ChorusGroupFrame` toggles party, raid or solo frames where appropriate
automatically.

Toggling frames in combat is a restricted action. Workarounds are employed to
make it work, similarly to how it is done in `ShadowedUnitFrames`. That is,
with `FrameXML/SecureStateDriver.lua`. It executes a macro-like commands on
demand, instead of the usual event processors, that are then handled by
`FrameXML/SecureHandlers.lua`.

@function groupFrameMain
@tparam self this group frame
]]
function Chorus.groupFrameMain(self)
	assert(self ~= nil)

	local secureHandler = ChorusGroupSecureHandler
	assert(secureHandler ~= nil)

	assert(ChorusLargeRaidFrame ~= nil)
	assert(ChorusPartyFrame ~= nil)
	assert(ChorusSmallRaidFrame ~= nil)
	assert(ChorusTinyRaidFrame ~= nil)

	--[[ NOTE: There is a naming convention quirk. The words "Tiny",
	"Small", "Large" and "Huge" in raid frame designations, refer to the
	__buttons__ being visually large. Therefore, "larger" raid frames are
	intended for raids with __fewer__ members and more details reported per
	unit. ]]--

	secureHandler:SetFrameRef('ChorusPartyFrame', ChorusPartyFrame)
	secureHandler:SetFrameRef('ChorusTinyRaidFrame', ChorusTinyRaidFrame)
	secureHandler:SetFrameRef('ChorusSmallRaidFrame', ChorusSmallRaidFrame)
	secureHandler:SetFrameRef('ChorusLargeRaidFrame', ChorusLargeRaidFrame)

	--[[ When any of the mentioned units exist, set `group` attribute of
	the `secureHandler` protected frame to the name of a raid frame that is
	responsible for reporting that unit to the user. ]]--

	--[[ NOTE: The order of switch cases in the macro is significant. The
	first match takes precedence. ]]--

	local secureCmd = produceSecureCommand()
	RegisterStateDriver(secureHandler, 'group', secureCmd)

	--[[ When the property `group` of the given protected frame
	`secureHandler` changes value, toggle all of the known raid frame
	profiles, and only choose to show the most appropriate one. ]]--

	--[[-- @todo Implement separate or additional arena unit group frame.
	]]

	secureHandler:WrapScript(secureHandler, 'OnAttributeChanged', [[
		local ChorusLargeRaidFrame = self:GetFrameRef('ChorusLargeRaidFrame')
		local ChorusPartyFrame = self:GetFrameRef('ChorusPartyFrame')
		local ChorusSmallRaidFrame = self:GetFrameRef('ChorusSmallRaidFrame')
		local ChorusTinyRaidFrame = self:GetFrameRef('ChorusTinyRaidFrame')

		local i = 0
		local n = 0
		while (i < 40) do
			i = i + 1
			if UnitPlayerOrPetInRaid('raid' .. tostring(i)) then
				n = n + 1
			end
		end

		if n > 25 then
			ChorusLargeRaidFrame:Hide()
			ChorusPartyFrame:Hide()
			ChorusSmallRaidFrame:Hide()
			ChorusTinyRaidFrame:Show()
		elseif n > 5 then
			ChorusLargeRaidFrame:Hide()
			ChorusPartyFrame:Hide()
			ChorusSmallRaidFrame:Show()
			ChorusTinyRaidFrame:Hide()
		elseif n >= 1 then
			ChorusLargeRaidFrame:Show()
			ChorusPartyFrame:Hide()
			ChorusSmallRaidFrame:Hide()
			ChorusTinyRaidFrame:Hide()
		elseif UnitPlayerOrPetInParty('party1') then
			ChorusLargeRaidFrame:Hide()
			ChorusPartyFrame:Show()
			ChorusSmallRaidFrame:Hide()
			ChorusTinyRaidFrame:Hide()
		elseif n <= 0 then
			ChorusLargeRaidFrame:Hide()
			ChorusPartyFrame:Hide()
			ChorusSmallRaidFrame:Hide()
			ChorusTinyRaidFrame:Hide()
		end
	]])

	self:RegisterEvent('PARTY_CONVERTED_TO_RAID')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('ZONE_CHANGED')
	self:RegisterEvent('ADDON_LOADED')

	self:RegisterEvent('RAID_ROSTER_UPDATE')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')

	self:SetScript('OnEvent', Chorus.groupFrameToggleInsecure)
end
