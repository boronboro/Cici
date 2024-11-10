--[[--
`ChorusUnitBackdropTemplate` handles the visuals and dynamic changes to unit
frame borders.

@submodule chorus
]]

local UnitExists = Chorus.test.UnitExists or UnitExists

local SecureButton_GetUnit = SecureButton_GetUnit

local function getDefaultBackdropColorMap()

	--[[ player: gold; target: magenta; focus: cyan; none: grey; ]]--

	return {
		target = {
			1, 0, 1, 1,
		},
		focus = {
			0, 1, 1, 1,
		},
		player = {
			1, 225 / 255, 0, 1,
		},
	}
end

local function unitBackdropEventProcessor(unitBackdrop)
	assert(unitBackdrop ~= nil)

	local unitDesignation = unitBackdrop:GetAttribute('unit')
	if not unitDesignation then
		unitDesignation = SecureButton_GetUnit(unitBackdrop)
	end
	assert(unitDesignation ~= nil)

	if UnitExists(unitDesignation) then
		unitBackdrop:Show()
	else
		unitBackdrop:Hide()
		return
	end

	--[[ Load backdrop color configuration options. ]]--

	local colorMap = Chorus.backdropColorMap or getDefaultBackdropColorMap()
	assert(colorMap ~= nil)
	assert('table' == type(colorMap))

	local r = 1.0
	local g = 1.0
	local b = 1.0
	local a = 1.0

	--[[ Find valid setting. ]]--

	--[[ Order is important. The first matching unit category will yield
	corresponding color. ]]--

	local t = {'player', 'target', 'focus',}
	local i = 0
	while (i < #t) do
		i = i + 1
		local u = t[i]
		assert(u ~= nil)
		assert('string' == type(u))
		if UnitIsUnit(unitDesignation, u) then
			local e = colorMap[u] or {1.0, 1.0, 1.0, 1.0}
			if e ~= nil and 'table' == type(e) then
				r = e[1] or 1.0
				g = e[2] or 1.0
				b = e[3] or 1.0
				a = e[4] or 1.0
			end
			break
		end
	end

	--[[ Apply setting. ]]--

	unitBackdrop:SetBackdropBorderColor(r, g, b, a)
	unitBackdrop:SetBackdropColor(r / 6.0, g / 6.0, b / 6.0, a)
end

--[[
When initializing a backdrop frame, given no explicit anchors were set in XML,
or `setAllPoints` is `false, then fallback to these hardcoded default anchors.
@function applyDefaultDimensionsIfNecessary
]]
local function applyDefaultDimensionsIfNecessary(unitBackdrop)
	assert(unitBackdrop ~= nil)

	local backdropTable = unitBackdrop:GetBackdrop()
	assert(backdropTable ~= nil)
	assert('table' == type(backdropTable))

	local p = unitBackdrop:GetParent()
	local w = unitBackdrop:GetWidth()
	local h = unitBackdrop:GetHeight()
	local fallbackFlag = (math.abs(w) <= 0 or math.abs(h) <= 0) and p ~= nil
	if fallbackFlag then
		local offset = (backdropTable.edgeSize or 24) / 4
		unitBackdrop:SetPoint('TOPRIGHT', offset, offset)
		unitBackdrop:SetPoint('TOPLEFT', -offset, offset)
		unitBackdrop:SetPoint('BOTTOMLEFT', -offset, -offset)
		unitBackdrop:SetPoint('BOTTOMRIGHT', offset, -offset)
	end
end

--[[--
Initialize backdrop.

Unit backdrop frame is intended to be composed with unit frames and unit
buttons. It is intended to handle the render of tiled background and edge
textures.

@function unitBackdropMain
@tparam frame unitBackdrop this unit backdrop frame
]]
function Chorus.unitBackdropMain(unitBackdrop)
	assert(unitBackdrop ~= nil)

	local colorMap = Chorus.backdropColorMap
	if not colorMap then
		colorMap = getDefaultBackdropColorMap()
	end
	Chorus.backdropColorMap = colorMap

	applyDefaultDimensionsIfNecessary(unitBackdrop)

	unitBackdrop:SetBackdropBorderColor(1, 1, 1, 1)
	unitBackdrop:SetBackdropColor(0, 0, 0, 0.8)

	unitBackdrop:RegisterEvent('ADDON_LOADED')
	unitBackdrop:RegisterEvent('PARTY_CONVERTED_TO_RAID')
	unitBackdrop:RegisterEvent('PARTY_MEMBERS_CHANGED')
	unitBackdrop:RegisterEvent('PLAYER_FOCUS_CHANGED')
	unitBackdrop:RegisterEvent('PLAYER_TARGET_CHANGED')
	unitBackdrop:RegisterEvent('RAID_ROSTER_UPDATE')
	unitBackdrop:SetScript('OnEvent', unitBackdropEventProcessor)
	unitBackdrop:SetScript('OnAttributeChanged', unitBackdropEventProcessor)
end
