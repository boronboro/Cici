--[[--
@submodule chorus
]]

local Chorus = Chorus

local strtrim = strtrim

local function getButtonAssociatedTooltipFrame(self)
	assert(self ~= nil)

	local p = self:GetParent()

	assert(p ~= nil, 'invalid state: aura tooltip toggle button ' ..
	'must have siblings and therefore must have a parent')

	local tooltipFrame = _G[p:GetName() .. 'AuraTooltipFrame']

	return tooltipFrame
end

--[[--
Initialize the button to toggle `ChorusAuraTooltipFrame` in restricted
environment.

When this button is clicked, it must show a frame, that contains an exhaustive
list of auras that effect the corresponding unit.

@function auraTooltipToggleButtonMain
@tparam frame self this aura tooltip toggle button
]]
local function auraTooltipToggleButtonMain(self)
	assert(self ~= nil)

	--[[ @warning For some bizzare reason, only programmatically created
	secure handlers, or secure handlers that descend from secure frames,
	define the required method of `SetFrameRef`. ]]--

	local nama = (self:GetName() or '') .. 'SecureClickHandlerFrame'

	local secureClickHandler = _G[nama] or CreateFrame('FRAME', nama, self,
	'SecureHandlerClickTemplate')

	assert(secureClickHandler ~= nil)

	local tooltipFrame = getButtonAssociatedTooltipFrame(self)
	assert(tooltipFrame ~= nil, 'invalid state: sibling aura tooltip frame must exist');

	secureClickHandler:SetFrameRef('ChorusAuraTooltipFrame', tooltipFrame);

	secureClickHandler:WrapScript(self, 'OnClick', [=[
		local tooltipFrame = self:GetFrameRef('ChorusAuraTooltipFrame')
		if not tooltipFrame then
			tooltipFrame = owner:GetFrameRef('ChorusAuraTooltipFrame')
		end
		if tooltipFrame then
			tooltipFrame:Show()
		else
			error('ChorusAuraTooltipFrameTemplate.lua: invalid state ' ..
				'could not access aura tooltip frame')
			return
		end
	]=]);

	--[[ Aura tooltip toggle button is a protected frame. It's visibility
	must be toggled with a unit watch. Most likely. ]]--

	RegisterUnitWatch(self)
end

--[[--
`ChorusAuraTooltipFrameTemplate` is *not* the familiar tooltip frame. Instead,
it is intended to conditionally show all auras on a given unit.

`ChorusAuraFrameTemplate` is intended to show only a relevant subset of auras
on a given unit at a time. Almost never all of the auras. When the need arises
for the user to read all auras on a particular unit, they click a specific
button, and it displays a detailed tooltip for all auras.
`ChorusAuraTooltipFrameTemplate` that is this module handles this tooltip.

Note that showing a frame in combat is a restricted action. This template
accounts for that and must work in combat as expected.

@function auraTooltipFrameMain
@tparam frame self this Chorus aura tooltip frame
]]
local function auraTooltipFrameMain(self)
	assert(self ~= nil)

	local n = self:GetName()
	assert(n ~= nil)
	assert('string' == type(n))
	n = strtrim(n)
	assert(string.len(n) >= 1)
	assert(string.len(n) <= 8192)

	local secureToggleHandler = _G[n .. 'SecureHandlerShowHideFrame']
	assert(secureToggleHandler ~= nil)

	local secureClickHandler = _G[n .. 'SecureHandlerClickFrame']
	assert(secureClickHandler ~= nil)

	local closeButton = _G[n .. 'CloseButton']
	assert(closeButton ~= nil)

	--[[ When button is shown, ESCAPE key press will always click this button first. ]]--
	secureToggleHandler:WrapScript(closeButton, 'OnShow', [=[
		self:SetBindingClick(true, 'ESCAPE', self)
		self:SetBindingClick(true, 'CTRL-W', self)
	]=])

	secureToggleHandler:WrapScript(closeButton, 'OnHide', [=[
		self:ClearBindings()
	]=])

	secureClickHandler:WrapScript(closeButton, 'OnClick', [=[
		local p = self:GetFrameRef('closeframe') or self:GetParent()
		if p then
			p:Hide()
		end
	]=])
end

Chorus.auraTooltipToggleButtonMain = function(...)
	return auraTooltipToggleButtonMain(...)
end

Chorus.auraTooltipFrameMain = function(...)
	return auraTooltipFrameMain(...)
end
