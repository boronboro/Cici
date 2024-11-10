local pattern = "^([A-Za-z]+[A-Za-z0-9/\\_. ]*):([A-Za-z]+[A-Za-z0.9_\(\) ]*)$"

--[[
LDoc custom see tag handler.

When an unknown \@see tag is encountered, `string.match` the string against the
pattern. If it suceeds, it passes the results to the function. The function
must return first a token, second a valid URL of the documentation page.

@function chorus_custom_see_handler
@tparam string pathname valid file pathname where the tag definition is found
@tparam string token tag that see points to
@treturn string label token to be found on the documentation page
@treturn string href valid URL that points to documentation page
]]--
local function chorus_custom_see_handler(pathname, label)
	--[[ FIXME Set vaid URL for the FrameXML 3.3.5a. Repository branch and
	tags must be accounted for. ]]--

	local fmt = 'https://github.com/tekkub/wow-ui-source/tree/3.3.5/%s'
	local href = fmt:format(pathname)

	return label, href
end

custom_see_handler(pattern, chorus_custom_see_handler)
