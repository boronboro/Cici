local Chorus = Chorus

--[[ NOTE SavedVariables do not work for this since they are loaded after all
of the scripts and after all of the API was shadowed. Testing module must be
loaded __before__ shadowing. See each individual script for details. ]]--

--[[ To enable testing mode uncomment the following line and `/run ReloadUI()`. ]]--

--[[ Chorus.debugFlag = true ]]--

if not Chorus.debugFlag then
	Chorus.test = {}
	return
end

if DEFAULT_CHAT_FRAME then
	DEFAULT_CHAT_FRAME:AddMessage(date('%X') .. ' ChorusTest.lua: mock testing mode enabled')
end

local t = {
	focus = {},
	party1 = {
		UnitIsPlayer = true,
		UnitClass = {'Warrior', 'WARRIOR'},
		UnitPowerType = {1, 'RAGE'},
		UnitPower = 13,
		UnitPowerMax = 100,
	},
	party1target = {},
	party2 = {
		UnitIsPlayer = true,
		UnitClass = {'Priest', 'PRIEST'},
		UnitPowerType = {0, 'MANA'},
	},
	party2target = {},
	party3 = {
		UnitIsPlayer = true,
		UnitClass = {'Warlock', 'WARLOCK'},
		UnitPowerType = {0, 'MANA'},
	},
	party3target = {},
	party4 = {
		UnitIsPlayer = true,
		UnitClass = {'Mage', 'MAGE'},
		UnitPowerType = {0, 'MANA'},
		UnitIsDead = true,
		UnitHealth = 0
	},
	party4target = {},
	partypet1 = {},
	partypet2 = {},
	partypet3 = {},
	partypet4 = {},
	pet = {},
	player = {
		UnitIsPlayer = true,
		UnitClass = {'Paladin', 'PALADIN'},
		UnitPowerType = {0, 'MANA'},
	},
	target = {},
}

local function recordGet(u, key)
	local r = t[u]
	if r then
		local e = r[key]
		if e and 'table' == type(e) then
			return unpack(e)
		else
			return e
		end
	end
	return
end

local function GetNumPartyMembers_Mock()
	return 4
end

local function UnitAura_Mock(u, i, filter)
	if u and i > 36 then
		return nil
	end

	if 'HARMFUL' == string.match(filter, 'HARMFUL') then
		return 'Poison',
			'',
			'Interface\\Icons\\Spell_Nature_CorrosiveBreath',
			0,
			'Poison',
			30,
			GetTime(),
			nil,
			nil,
			nil,
			744
	else
		return 'Blessing of Wisdom',
			'Rank 1',
			'Interface\\Icons\\Spell_Holy_SealOfWisdom',
			0,
			'Magic',
			600,
			GetTime(),
			'player',
			nil,
			1,
			19742
	end
end

local function UnitCastingInfo_Mock()
	--[[-- @todo Add UnitCastingInfo mock.
	]]
	return
end

local function UnitChannelInfo_Mock()
	--[[-- @todo Add UnitChannelInfo mock.
	]]
	return
end

local function UnitClass_Mock(u)
	return recordGet(u, 'UnitClass')
end

local function UnitExists_Mock(u)
	if 'none' == u then
		return false
	end
	return true
end

local function UnitHealth_Mock(u)
	local r = recordGet(u, 'UnitHealth')
	if r then
		return r
	end
	return math.random(1, 1000 * 1000)
end

local function UnitHealthMax_Mock(u)
	local r = recordGet(u, 'UnitHealthMax')
	if r then
		return r
	end
	return 1000 * 1000
end

local function UnitInParty_Mock(u)
	return tContains({'player', 'party1', 'party2', 'party3', 'party4',}, u)
end

local function UnitInRaid_Mock(u)
	return 'raid' == string.match(u, 'raid')
end

local function UnitInRange_Mock()
	return true
end

local function UnitIsConnected_Mock(u)
	if 'none' == u then
		return false
	end
	return true
end

local function UnitIsCorpse_Mock(u)
	return recordGet(u, 'UnitIsCorpse') or false
end

local function UnitIsDead_Mock(u)
	return recordGet(u, 'UnitIsDead') or false
end

local function UnitIsFriend_Mock(u)
	if 'target' == u or 'focus' == u then
		return false
	elseif string.len(u) > string.len('target') and 'target' == string.match(u, 'target') then
		return false
	else
		return true
	end
end

local function UnitIsGhost_Mock()
	return false
end

local function UnitIsPlayer_Mock(u)
	if 'target' == u or 'focus' == u or  'pet' == u then
		return false
	elseif string.len(u) > string.len('pet') and 'pet' == string.match(u, 'pet') then
		return false
	elseif string.len(u) > string.len('target') and 'target' == string.match(u, 'target') then
		return false
	else
		return true
	end
end

local function UnitIsUnit_Mock(u0, u1)
	return u0 == u1
end

local function UnitLevel_Mock(u)
	local r = recordGet(u, 'UnitLevel')
	if r then
		return r
	end

	return 81
end

local function UnitName_Mock(u)
	return string.upper(string.sub(u, 1, 1)) .. string.lower(string.sub(u, 2, string.len(u)))
end

local function UnitPower_Mock(u)
	local r = recordGet(u, 'UnitPower')
	if r then
		return recordGet(u, 'UnitPower')
	end
	return math.random(1, 1000 * 1000)
end

local function UnitPowerMax_Mock(u)
	local r = recordGet(u, 'UnitPowerMax')
	if r then
		return recordGet(u, 'UnitPowerMax')
	end
	return 1000 * 1000
end

local function UnitPowerType_Mock(u)
	local r = recordGet(u, 'UnitPowerType')
	if r then
		return recordGet(u, 'UnitPowerType')
	end
	return 0, 'MANA'
end

local function RegisterUnitWatch_Mock(self)
	self:Show()
end

local function SecureButton_GetUnit_Mock(self)
	local i = 0
	local f = self
	local u = nil
	while (i < 8192) do
		u = f:GetAttribute('unit')
		if u ~= nil and 'string' == type(u) then
			break
		elseif f:GetAttribute('useparent-unit') or f:GetAttribute('useparent*') then
			local p = f:GetParent()
			if p then
				f = p
			else
				break
			end
		else
			break
		end
		i = i + 1
	end

	return u
end

local function UnregisterUnitWatch_Mock()
	--[[ call DoNothing() ]]--
	return
end

local function UnitGroupRolesAssigned_Mock()
	return 'DAMAGER'
end

Chorus.test = {
	GetNumPartyMembers = GetNumPartyMembers_Mock,
	UnitAura = UnitAura_Mock,
	UnitCastingInfo = UnitCastingInfo_Mock,
	UnitChannelInfo = UnitChannelInfo_Mock,
	UnitClass = UnitClass_Mock,
	UnitExists = UnitExists_Mock,
	UnitGroupRolesAssigned = UnitGroupRolesAssigned_Mock,
	UnitHealth = UnitHealth_Mock,
	UnitHealthMax = UnitHealthMax_Mock,
	UnitInParty = UnitInParty_Mock,
	UnitInRaid = UnitInRaid_Mock,
	UnitInRange = UnitInRange_Mock,
	UnitIsConnected = UnitIsConnected_Mock,
	UnitIsCorpse = UnitIsCorpse_Mock,
	UnitIsDead = UnitIsDead_Mock,
	UnitIsFriend = UnitIsFriend_Mock,
	UnitIsGhost = UnitIsGhost_Mock,
	UnitIsPlayer = UnitIsPlayer_Mock,
	UnitIsUnit = UnitIsUnit_Mock,
	UnitLevel = UnitLevel_Mock,
	UnitName = UnitName_Mock,
	UnitPower = UnitPower_Mock,
	UnitPowerMax = UnitPowerMax_Mock,
	UnitPowerType = UnitPowerType_Mock,

	RegisterUnitWatch = RegisterUnitWatch_Mock,
	SecureButton_GetUnit = SecureButton_GetUnit_Mock,
	UnregisterUnitWatch = UnregisterUnitWatch_Mock,
}
