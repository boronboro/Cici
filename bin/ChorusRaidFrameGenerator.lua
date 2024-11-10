--[[--
A command line program, that takes a few arguments and prints to standard
output ugly XML descriptors.

This script parametrizes XML descriptor template for raid frame GUI widget,
that is only useful for `chorus` project.

There are several plausible configurations of the raid frame a user may
require. At least one per instance type, that is, arena, battleground, raid and
dungeon or party. Possibly more. The user will likely require to switch between
those profiles frequently and automatically.

The original intention of the project is to have the add-on come pre-configured
by the developer, and not require configuration by the user. Hence the need to
define a several useful raid frame profiles.

This script is a tool involved in producing different, but uniform raid
profiles, that are implemented by the project. The primary parameters are the
button template and button dimensions.

The unit button templates, that are hard coded in this script, are declared in
`src/ChorusRaidFrameTemplate.xml`. The specialization of raid profiles is
implemented in those virtual frame templates. This script only arranges the
concrete instances of buttons in a grid using XML descriptors.

The script is intended to be used by build orchestration tools, like `make` or
`gradle` or `ant`, rather than called manually.

The game engine loads XML descriptors quicker than Lua scripts. Therefore,
complex widgets, like raid frames, benefit from being declared with XML rather
than Lua. This does not improve responsiveness, however. This approach is
largely an experiment.

The usage shows how to execute the script on the command line. The first token
is the Lua executable. The second token is the script itself, assuming the
`chorus` source directory is the current working directory. The following
tokens are arguments for the script. The order is significant. See `function
emitRaidFrame`. Finally, the output is redirected to a file.

Formatting and validation of the output XML descriptor is the responsibility of
other tools, like `xmllint`.

@see emitRaidFrame

@usage lua bin/ChorusRaidFrameGenerator.lua ChorusTinyRaidFrame ChorusTinyRaidUnitFrameTemplate 64 16 > ChorusTinyRaidFrame.xml

@script ChorusRaidFrameGenerator

@alias mod
]]

ChorusRaidFrameGenerator = {}

local mod = ChorusRaidFrameGenerator

local header = [[
<?xml version="1.0" encoding="UTF-8"?>
<!-- This file was generated automatically. Never edit it manually.
Instead, see `bin/ChorusRaidFrameGenerator.lua`. -->
<Ui xmlns="http://www.blizzard.com/wow/ui/">
	<!-- See `ChorusRaidFrameTemplate.xml` for the unit button template declarations. -->
	<Frame name="%s" hidden="true" inherits="SecureFrameTemplate" protected="true">
		<Size>
			<AbsDimension x="%d" y="%d"/>
		</Size>
		<Anchors>
			<Anchor point="BOTTOM">
				<Offset x="0" y="200"/>
			</Anchor>
			<Anchor point="CENTER">
				<Offset x="0" y="0"/>
			</Anchor>
		</Anchors>
]]

--[[ TODO Toggle the visibility of the raid group number labels, when
appropriate.]]--

local sectionHeader = [[<Frame name="%s" hidden="true"> <Size> <AbsDimension
x="%d" y="%d" /> </Size><Anchors><Anchor point="BOTTOMLEFT"><Offset x="%d"
y="%d"/></Anchor></Anchors> <Layers> <Layer level="OVERLAY"> <FontString
name="$parentText" inherits="ChorusFontBold13" setAllPoints="true"
justifyH="CENTER" justifyV="MIDDLE" text="%d"/></Layer></Layers></Frame>]]

local section = [[
<Frame name="%s" inherits="%s" id="%d">
	<Anchors>
		<Anchor point="BOTTOMLEFT">
			<Offset>
				<AbsDimension x="%d" y="%d"/>
			</Offset>
		</Anchor>
	</Anchors>
	<Attributes>
		<Attribute name="unit" type="string" value="%s"/>
	</Attributes>
</Frame>
]]

local footer = [[
	</Frame>
</Ui>]]

--[[--
Print a snippet of XML, that describes a button for a single raid member.

@function emitRaidButton

@tparam string buttonName frame designation, expected to be globally unique

@tparam string buttonTemplate virtual frame designation, all buttons in a
specific raid frame profile are expected to be uniform and share a single
template

@tparam int buttonId positive integer and not zero, a serial number of the
button, expected to be unique per raid frame profile

@tparam number buttonX offset from origin, that is bottom left corner, to the right

@tparam number buttonY offset from origin, that is bottom left corner, upwards

@tparam string unitDesignation unit designation, that is a raid member, like
`raid13`, each button is expected expected to map to units 1:1

@return nothing, the output is printed to standard output
]]
function mod.emitRaidButton(buttonName, buttonTemplate, buttonId, buttonX, buttonY, unitDesignation)
	assert(buttonName ~= nil)
	assert('string' == type(buttonName))
	assert(string.len(buttonName) >= 1)
	assert(string.len(buttonName) <= 256)

	assert(buttonTemplate ~= nil)
	assert('string' == type(buttonTemplate))
	assert(string.len(buttonTemplate) >= 1)
	assert(string.len(buttonTemplate) <= 256)

	assert(buttonId ~= nil)
	assert('number' == type(buttonId))
	assert(buttonId >= 1)
	assert(buttonId <= 60)
	buttonId = math.floor(math.abs(buttonId))

	assert(buttonX ~= nil)
	assert('number' == type(buttonX))
	assert(buttonX >= 0)
	assert(buttonX <= 8192)

	assert(buttonY ~= nil)
	assert('number' == type(buttonY))
	assert(buttonY >= 0)
	assert(buttonY <= 8192)

	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))
	assert(string.len(unitDesignation) >= 5)
	assert(string.len(unitDesignation) <= 6)

	assert('raid' == string.sub(unitDesignation, 1, 4))
	local n = tonumber(string.sub(unitDesignation, 5))
	n = math.abs(math.floor(n))
	assert('number' == type(n))
	assert(n >= 1)
	assert(n <= 60)

	print(string.format(section, buttonName, buttonTemplate, buttonId,
	buttonX, buttonY, unitDesignation))
end

--[[--
Emit exactly `groupSizeMax` quantity of buttons, with given `buttonTemplate`,
and other settings.

To make buttons grow horizontally, set `dirX=1` and `dirY=0`.

To make buttons grow vertically, set `dirX=0` and `dirY=1`.

WARNING: No other combination of `dirX` and `dirY` are permissible.

@function mod.emitRaidGroup
@tparam string raidFrameName the designation by which the root raid frame can be accessed at runtime as a global variable
@tparam string buttonTemplate the designation of one of several permissible button templates
@tparam number buttonWidth the width of a single button
@tparam number buttonHeight the height of a single button
@tparam number padding zero or positive float, the size of the gaps between individual buttons
@tparam number ox the origin point X component
@tparam number oy the origin point Y component
@tparam number dirX movement direction normalized vector X component
@tparam number dirY movement direction normalized vector Y component
@tparam number groupSizeMax positive integer, assumed a constant, the exact number of buttons emitted
@tparam number groupNumber positive integer, the numerical identifier of the group
@return nothing, prints to standard output
]]
function mod.emitRaidGroup(raidFrameName, buttonTemplate, buttonWidth,
	buttonHeight, padding, ox, oy, dirX, dirY, groupSizeMax, groupNumber)

	assert(groupNumber ~= nil)
	assert('number' == type(groupNumber))
	assert(groupNumber >= 1)
	assert(groupNumber <= 8)
	groupNumber = math.abs(math.ceil(groupNumber))

	assert(5 == groupSizeMax)

	assert(ox >= 0)

	assert(oy >= 0)

	assert(padding >= 0)
	assert(padding <= 36)

	assert(dirX ~= nil)
	assert('number' == type(dirX))
	dirX = math.abs(math.ceil(dirX))

	assert(dirY ~= nil)
	assert('number' == type(dirY))
	dirY = math.abs(math.ceil(dirY))

	assert((1 == dirX and 0 == dirY) or
	(0 == dirX and 1 == dirY))

	print(string.format('<!-- Group %d. -->', groupNumber))

	local marginLeft = 16

	print(string.format(sectionHeader, raidFrameName .. 'GroupLabel' ..
	groupNumber, marginLeft, buttonHeight, ox - marginLeft, oy,
	groupNumber))

	--[[ TODO Add margin and raid group number label. ]]--
	local i = 0
	local buttonId = math.abs(math.ceil((groupNumber - 1) * groupSizeMax))
	while (i < groupSizeMax) do
		buttonId = buttonId + 1
		local buttonName = string.format('%sButton%02d', raidFrameName, buttonId)
		--[[ Button template defined earlier. ]]--
		local w = buttonWidth * i + padding * i
		local h = buttonHeight * i + padding * i
		local buttonX = ox + w * dirX
		local buttonY = oy + h * dirY
		local unitDesignation = string.format('raid%d', buttonId)

		mod.emitRaidButton(buttonName, buttonTemplate,
		buttonId, buttonX, buttonY, unitDesignation)

		i = i + 1
	end
end

--[[--
Print to standard output a valid XML descriptor for a raid frame profile, with
given arguments.

A raid frame consists by default of forty buttons arranged in a grid. First
button is the bottom left most corner of the grid, growing to the right and up.

A raid frame can be split into two blocks of twenty buttons, instead of one
block of forty. See the notes in the source code.

@function emitRaidFrame

@tparam string raidFrameName raid frame designation token, expected to be
globally unique

@tparam string buttonTemplate virtual frame template designation token, that
every button in the raid frame profile will inherit from

@tparam number buttonWidth positive and not zero integer, width of a single button

@tparam number buttonWidth positive and not zero integer, width of a single button

@return nothing, the output is printed to standard output
]]
function mod.emitRaidFrame(raidFrameName, buttonTemplate, buttonWidth, buttonHeight)
	assert(raidFrameName ~= nil)
	assert('string' == type(raidFrameName))
	assert(string.len(raidFrameName) >= 1)
	assert(string.len(raidFrameName) <= 256)

	assert(buttonTemplate ~= nil)
	assert('string' == type(buttonTemplate))
	assert('ChorusTinyRaidUnitFrameTemplate' == buttonTemplate or
	'ChorusSmallRaidUnitFrameTemplate' == buttonTemplate or
	'ChorusLargeRaidUnitFrameTemplate' == buttonTemplate or
	'ChorusHugeRaidUnitFrameTemplate' == buttonTemplate)

	assert(buttonWidth ~= nil)
	buttonWidth = tonumber(buttonWidth)
	assert('number' == type(buttonWidth))
	assert(buttonWidth >= 12)
	assert(buttonWidth <= 320)

	assert(buttonHeight ~= nil)
	buttonHeight = tonumber(buttonHeight)
	assert('number' == type(buttonHeight))
	assert(buttonHeight >= 12)
	assert(buttonHeight <= 320)

	local raidSizeMax = 40
	local groupSizeMax = 5

	local groupQuantity = math.ceil(raidSizeMax / groupSizeMax)

	--[[ Effectively, when `blockQuantity = 2`, the raid frame is split
	into two blocks of 4 groups x 5 members. ]]--

	local blockQuantity = 1
	assert(blockQuantity > 0)
	blockQuantity = math.ceil(math.abs(blockQuantity))

	--[[ Margin to leave space for group number labels. ]]--

	local marginLeft = 16
	local padding = 6
	assert(padding >= 0)

	local raidFrameWidth = marginLeft * blockQuantity + (groupSizeMax *
	buttonWidth + groupSizeMax * padding) * blockQuantity

	local raidFrameHeight =  groupQuantity * buttonHeight + groupQuantity *
	padding

	print(string.format(header, raidFrameName, raidFrameWidth,
	raidFrameHeight))

	print('<Frames>')

	local dirX = 1
	local dirY = 0

	local block = 0
	local groupNumber = 0
	while (block < blockQuantity) do
		print(string.format('<!-- Block %d. -->', block + 1))

		local ox = marginLeft * block + (buttonWidth * groupSizeMax + padding * groupSizeMax) * block
		local i = 0
		while (i < groupQuantity / blockQuantity) do
			groupNumber = groupNumber + 1

			local oy = (padding * i + buttonHeight * i)

			mod.emitRaidGroup(raidFrameName, buttonTemplate,
			buttonWidth, buttonHeight, padding, ox, oy, dirX, dirY,
			groupSizeMax, groupNumber)
			i = i + 1
		end
		block = block + 1
	end

	print('</Frames>')
	print(footer)
end

--[[--
Process command line arguments with builtin global variable `arg`.

@function mod.main
@see emitRaidFrame
@return nothing, prints to standard output
]]
function mod.main()
	if arg ~= nil and 'table' == type(arg) then
		return mod.emitRaidFrame(unpack(arg))
	end
end

do
	mod.main()
	return mod
end
