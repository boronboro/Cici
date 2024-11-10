--[[--
@submodule chorus
]]

--[[--
Local preferences for Chorus.
@section local
]]

--[[--
This map contains auras that are prioritized to be shown first in the aura
frames.

Every key is a localized aura name, that `function UnitAura` will accept.

Every value is a positive integer in [1,9], that is the weight. The larger the
weight, the higher the priority the given aura will be shown before others.

This map should be overriden for every game client localization. Only localized
aura names are accepted by the game API. It is much more convenient to list
human-readable aura names, than every integer identifier for every aura rank.

Additionally, users may override this map in accordance with their personal
preference. The default values aim to give reasonable preset for all abilities
usable by player characters in the English version of the game.

@table ChorusAuraWeightMap
@see getAuraWeight
]]
ChorusAuraWeightMap = {
	['Aimed Shot'] = 1,
	['Anti-Magic Shell'] = 2,
	['Aura Mastery'] = 1,
	['Avenging Wrath'] = 3,
	['Bladestorm'] = 3,
	['Blind'] = 3,
	['Chains of Ice'] = 1,
	['Cheap Shot'] = 1,
	['Concussion Blow'] = 1,
	['Cyclone'] = 3,
	['Deterrence'] = 3,
	['Disarm'] = 2,
	['Disarmed'] = 2,
	['Divine Hymn'] = 3,
	['Divine Plea'] = 1,
	['Divine Shield'] = 3,
	['Entangling Roots'] = 1,
	['Evasion'] = 2,
	['Evocation'] = 2,
	['Fear'] = 2,
	['Freezing Trap'] = 2,
	['Gnaw'] = 2,
	['Gouge'] = 2,
	['Grounding Totem Effect'] = 2,
	['Grounding Totem'] = 2,
	['Hammer of Justice'] = 1,
	['Hamstring'] = 1,
	['Hand of Freedom'] = 1,
	['Hand of Protection'] = 2,
	['Hand of Sacrifice'] = 1,
	['Hand of Salvation'] = 1,
	['Hex'] = 2,
	['Hibernation'] = 2,
	['Hymn of Hope'] = 3,
	['Ice Block'] = 3,
	['Icebound Fortitude'] = 3,
	['Inner Focus'] = 1,
	['Kidney Shot'] = 1,
	['Last Stand'] = 3,
	['Mind Control'] = 3,
	['Mortal Strike'] = 1,
	['Pain Suppression'] = 3,
	['Polymorph'] = 2,
	['Power Infusion'] = 3,
	['Psychic Scream'] = 2,
	['Recklessness'] = 3,
	['Sacrifice'] = 2,
	['Sap'] = 3,
	['Seduction'] = 2,
	['Shield Block'] = 2,
	['Shield Wall'] = 3,
	['Sleep'] = 2,
	['Spell Reflection'] = 2,
	['Unstable Affliction'] = 2,
	['Wounding Poison'] = 1,
}
