--[[--
This module contains all functions that are accessible from global scope
defined by this project.

All relevant frames or globals that belong to this project, but for convenience
or necessity are not contained in this module, are allocated with names that
are prefixed with the module's name that is `Chorus`.

@module chorus
]]--

Chorus = {}

Chorus.test = {}

--[[--
Utility function for developers that lists and caches, using SavedVariables
mechanism, all function names that were defined by this project.

The output is used as a definitive list of all dynamically allocated frames.

@function Chorus.luacheckrcDump
]]
function Chorus.luacheckrcDump()
	if not ChorusLuacheckrcDump then
		ChorusLuacheckrcDump = {}
	end
	local dump = ChorusLuacheckrcDump
	assert(dump ~= nil)
	assert('table' == type(dump))
	local i = 0
	for name, e in pairs(_G) do
		local y = type(e)
		if string.match(name, 'Chorus') then
			if ('function' == y or 'table' == y) then
				i = i + 1
				dump[i] = name
			end
		end
	end
	table.sort(dump)
end
