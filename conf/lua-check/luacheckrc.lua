--[[ http://luacheck.readthedocs.io/en/stable/config.html ]]--

--[[ Functions defined in World of Warcraft client Lua environment. It is
distinct from default Lua 5.1 environment. For example, `os` package is
excluded. Only globals used by this project are included, therefore the list is
only a subset and not exhaustive. ]]--

--[[ Functions defined since Cata. ]]--
stds.cata = {
	globals = {
		'UnitSetRole',
	}
}

--[[ Functions defined since Wrath or earlier. ]]--
stds.wrath = {
	read_globals = {
		'CreateFrame',
		'GetBuildInfo',
		'GetInstanceInfo',
		'GetModifiedClick',
		'GetNumPartyMembers',
		'GetNumRaidMembers',
		'GetPlayerInfoByGUID',
		'GetQuestDifficultyColor',
		'GetRaidTargetIndex',
		'GetSpellCooldown',
		'GetSpellInfo',
		'GetSpellName',
		'GetSpellTexture',
		'GetThreatStatusColor',
		'GetTime',
		'InCombatLockdown',
		'IsSpellInRange',
		'MAX_RAID_MEMBERS',
		'UnitAffectingCombat',
		'UnitAura',
		'UnitCanAttack',
		'UnitCastingInfo',
		'UnitChannelInfo',
		'UnitClass',
		'UnitClassification',
		'UnitDetailedThreatSituation',
		'UnitExists',
		'UnitGUID',
		'UnitGroupRolesAssigned',
		'UnitHealth',
		'UnitHealthMax',
		'UnitInParty',
		'UnitInRaid',
		'UnitInRange',
		'UnitIsConnected',
		'UnitIsCorpse',
		'UnitIsDead',
		'UnitIsEnemy',
		'UnitIsFriend',
		'UnitIsGhost',
		'UnitIsPlayer',
		'UnitIsTapped',
		'UnitIsUnit',
		'UnitLevel',
		'UnitName',
		'UnitPlayerOrPetInParty',
		'UnitPlayerOrPetInRaid',
		'UnitPower',
		'UnitPowerMax',
		'UnitPowerType',
		'UnitThreatSituation',
		'assert',
		'date',
		'error',
		'format',
		'math',
		'pairs',
		'print',
		'select',
		'string',
		'strtrim',
		'tContains',
		'table',
		'time',
		'tostring',
		'type',
		'unpack',
	},
	globals = {
		'_G',
	},
}

--[[ Functions defined in FrameXML or AddOns natively. ]]--

--[[ The distinction between FrameXML and Lua environment is made, so that
testing mockups may be created more easily. The Lua environmenet is uniform
between game versions, and even game versions can be made compatible among each
other. On the other hand, FrameXML may be extensively modified by individual
users, making each installation unique and reliance on FrameXML undesireable.
Author still chose to use FrameXML for convenience.  ]]--

stds.framexml = {
	read_globals = {
		'DEAD',
		'CORPSE',
		'PLAYER_OFFLINE',
		'DEATH_RELEASE',
		'BUFF_MAX_DISPLAY',
		'CastingBarFrame',
		'ComboFrame',
		'DEBUFF_MAX_DISPLAY',
		'DEFAULT_CHAT_FRAME',
		'DebuffTypeColor',
		'FocusFrame',
		'FocusFrameDropDown',
		'FocusFrameHealthBar',
		'FocusFrameManaBar',
		'FocusFrameSpellBar',
		'GameFontWhite',
		'GameTooltip',
		'GameTooltipTextLeft1',
		'GameTooltip_SetDefaultAnchor',
		'GameTooltip_UnitColor',
		'MAX_PARTY_MEMBERS',
		'MAX_SPELLS',
		'NumberFontNormalSmall',
		'PartyMemberBackground',
		'PartyMemberFrame1',
		'PartyMemberFrame1DropDown',
		'PartyMemberFrame2',
		'PartyMemberFrame2DropDown',
		'PartyMemberFrame3',
		'PartyMemberFrame3DropDown',
		'PartyMemberFrame4',
		'PartyMemberFrame4DropDown',
		'PetCastingBarFrame',
		'PetFrame',
		'PetFrameHealthBar',
		'PetFrameManaBar',
		'PlayerFrame',
		'PlayerFrameDropDown',
		'PlayerFrameHealthBar',
		'PlayerFrameManaBar',
		'PlayerFrameSpellBar',
		'PowerBarColor',
		'RAID_CLASS_COLORS',
		'RegisterStateDriver',
		'RegisterUnitWatch',
		'RuneFrame',
		'SecureButton_GetAttribute',
		'SecureButton_GetUnit',
		'SetRaidTargetIconTexture',
		'TargetFrame',
		'TargetFrameDropDown',
		'TargetFrameHealthBar',
		'TargetFrameManaBar',
		'TargetFrameSpellBar',
		'ToggleDropDownMenu',
		'UIParent',
		'UnregisterUnitWatch',
	},
	globals = {
	},
}

--[[ Functions and globals defined by authors of this add-on. This list is not exhaustive. ]]--

stds.chorus = {
	read_globals = {
		'ChorusFocusFrame',
		'ChorusFrame',
		'ChorusGroupFrame',
		'ChorusGroupSecureHandler',
		'ChorusPartyFrame',
		'ChorusPlayerFrame',
		'ChorusRaidFrame',
		'ChorusTargetFrame',
	},
	globals = {
		--[[ TODO Add script that populates created frames at runtime
		--and saves the variables to a file, to make this name set
		--exact. ]]--
		'Chorus',
		'ChorusAuraWeightMap',
		'ChorusFocusFrameHealthFrame',
		'ChorusFocusFrameUnitNameFrame',
		'ChorusLuacheckrcDump',
		'ChorusPlayerFrameHealthFrame',
		'ChorusPlayerFrameUnitNameFrame',
		'ChorusTargetFrameHealthFrame',
		'ChorusTargetFrameUnitNameFrame',
		'ChorusUnitGroupRoleMap',
		'ChorusTinyRaidFrame',
		'ChorusSmallRaidFrame',
		'ChorusLargeRaidFrame',
		'ChorusHugeRaidFrame',
	},
}

std = 'wrath+cata+framexml+chorus'
