${srcdir}src/ChorusTinyRaidFrame.xml: ${srcdir}bin/ChorusRaidFrameGenerator.lua ${srcdir}src/ChorusRaidFrameTemplate.xml
	${LUA} ${LUAFLAGS} ${srcdir}bin/ChorusRaidFrameGenerator.lua ChorusTinyRaidFrame ChorusTinyRaidUnitFrameTemplate 64 16 | ${FORMAT_XML} > $@

${srcdir}src/ChorusSmallRaidFrame.xml: ${srcdir}bin/ChorusRaidFrameGenerator.lua ${srcdir}src/ChorusRaidFrameTemplate.xml
	${LUA} ${LUAFLAGS} ${srcdir}bin/ChorusRaidFrameGenerator.lua ChorusSmallRaidFrame ChorusSmallRaidUnitFrameTemplate 96 32 | ${FORMAT_XML} > $@

${srcdir}src/ChorusLargeRaidFrame.xml: ${srcdir}bin/ChorusRaidFrameGenerator.lua ${srcdir}src/ChorusRaidFrameTemplate.xml
	${LUA} ${LUAFLAGS} ${srcdir}bin/ChorusRaidFrameGenerator.lua ChorusLargeRaidFrame ChorusLargeRaidUnitFrameTemplate 160 100 | ${FORMAT_XML} > $@

${srcdir}src/ChorusHugeRaidFrame.xml: ${srcdir}bin/ChorusRaidFrameGenerator.lua ${srcdir}src/ChorusRaidFrameTemplate.xml
	${LUA} ${LUAFLAGS} ${srcdir}bin/ChorusRaidFrameGenerator.lua ChorusHugeRaidFrame ChorusHugeRaidUnitFrameTemplate 200 150 | ${FORMAT_XML} > $@
