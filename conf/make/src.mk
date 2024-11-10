# The order in which Lua snippets are processed is sometimes relevant.
# Specifically, `ldoc` requires `Chorus.lua` file to be first, since it
# contains the master module definition. Hence this list of source files.

# It is possible to accomplish the same task using `vpath` or `addprefix`. This
# blunt approch is more portable and more easily understood by developers not
# familiar with the `make` tool.

LUAFILES = \
${srcdir}src/Chorus.lua \
${srcdir}src/ChorusTest.lua \
${srcdir}src/local.lua \
${srcdir}src/ChorusAuraButtonTemplate.lua \
${srcdir}src/ChorusAuraFrameTemplate.lua \
${srcdir}src/ChorusAuraTooltipFrameTemplate.lua \
${srcdir}src/ChorusCastFrameTemplate.lua \
${srcdir}src/ChorusProgressFrameTemplate.lua \
${srcdir}src/ChorusRaidTargetIconFrameTemplate.lua \
${srcdir}src/ChorusRangeFrameTemplate.lua \
${srcdir}src/ChorusThreatFrameTemplate.lua \
${srcdir}src/ChorusUnitAffectingCombatFrameTemplate.lua \
${srcdir}src/ChorusUnitBackdropTemplate.lua \
${srcdir}src/ChorusUnitBackgroundTemplate.lua \
${srcdir}src/ChorusUnitButtonTemplate.lua \
${srcdir}src/ChorusUnitFrameTemplate.lua \
${srcdir}src/ChorusUnitGroupRoleFrameTemplate.lua \
${srcdir}src/ChorusUnitLevelFrameTemplate.lua \
${srcdir}src/ChorusUnitNameFrameTemplate.lua \
${srcdir}src/ChorusPartyFrame.lua \
${srcdir}src/ChorusGroupFrame.lua \
${srcdir}src/ChorusFrame.lua

XMLFILES = \
${srcdir}src/Chorus.xml \
${srcdir}src/ChorusFont.xml \
${srcdir}src/ChorusAuraButtonTemplate.xml \
${srcdir}src/ChorusAuraFrameTemplate.xml \
${srcdir}src/ChorusAuraTooltipFrameTemplate.xml \
${srcdir}src/ChorusCastFrameTemplate.xml \
${srcdir}src/ChorusHealthFrameTemplate.xml \
${srcdir}src/ChorusHugeUnitFrameTemplate.xml \
${srcdir}src/ChorusLargeUnitFrameTemplate.xml \
${srcdir}src/ChorusPowerFrameTemplate.xml \
${srcdir}src/ChorusProgressFrameTemplate.xml \
${srcdir}src/ChorusRaidTargetIconFrameTemplate.xml \
${srcdir}src/ChorusRangeFrameTemplate.xml \
${srcdir}src/ChorusSmallUnitFrameTemplate.xml \
${srcdir}src/ChorusThreatFrameTemplate.xml \
${srcdir}src/ChorusTinyUnitFrameTemplate.xml \
${srcdir}src/ChorusUnitAffectingCombatFrameTemplate.xml \
${srcdir}src/ChorusUnitBackdropTemplate.xml \
${srcdir}src/ChorusUnitBackgroundTemplate.xml \
${srcdir}src/ChorusUnitButtonTemplate.xml \
${srcdir}src/ChorusUnitFrameTemplate.xml \
${srcdir}src/ChorusUnitGroupRoleFrameTemplate.xml \
${srcdir}src/ChorusUnitLevelFrameTemplate.xml \
${srcdir}src/ChorusUnitNameFrameTemplate.xml \
${srcdir}src/ChorusRaidFrameTemplate.xml \
${srcdir}src/ChorusFocusFrame.xml \
${srcdir}src/ChorusPlayerFrame.xml \
${srcdir}src/ChorusTargetFrame.xml \
${srcdir}src/ChorusPartyFrame.xml \
${srcdir}src/ChorusTinyRaidFrame.xml \
${srcdir}src/ChorusSmallRaidFrame.xml \
${srcdir}src/ChorusLargeRaidFrame.xml \
${srcdir}src/ChorusGroupFrame.xml \
${srcdir}src/ChorusFrame.xml
