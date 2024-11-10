--[[--
@submodule chorus
]]

local Chorus = Chorus

local GameTooltip = GameTooltip
local GameTooltipTextLeft1 = GameTooltipTextLeft1

local TargetFrameDropDown = TargetFrameDropDown
local PlayerFrameDropDown = PlayerFrameDropDown
local FocusFrameDropDown = FocusFrameDropDown
local PartyMemberFrame1DropDown = PartyMemberFrame1DropDown
local PartyMemberFrame2DropDown = PartyMemberFrame2DropDown
local PartyMemberFrame3DropDown = PartyMemberFrame3DropDown
local PartyMemberFrame4DropDown = PartyMemberFrame4DropDown

local ToggleDropDownMenu = ToggleDropDownMenu

local GameTooltip_SetDefaultAnchor = GameTooltip_SetDefaultAnchor
local GameTooltip_UnitColor = GameTooltip_UnitColor
local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

local function unitButtonLeaveProcessor()
	assert(GameTooltip ~= nil)

	GameTooltip:FadeOut()
end

local function unitButtonEnterProcessor(unitButton)
	assert(GameTooltip ~= nil)

	local unitDesignation = SecureButton_GetUnit(unitButton)
	if unitDesignation then
		GameTooltip_SetDefaultAnchor(GameTooltip, unitButton);
		GameTooltip:SetUnit(unitDesignation)
		local r, g, b = GameTooltip_UnitColor(unitDesignation);
		GameTooltipTextLeft1:SetTextColor(r, g, b);
	end
end

local function contextMenuToggle(self, unitDesignation, buttonDesignation, buttonType)
	assert(self ~= nil)
	assert(unitDesignation ~= nil)
	assert(buttonDesignation ~= nil)
	assert(buttonType ~= nil)

	local offsetX = self:GetWidth() / 2
	local offsetY = self:GetHeight()
	local contextMenu
	if UnitIsUnit('target', unitDesignation) then
		contextMenu = TargetFrameDropDown
	elseif UnitIsUnit('focus', unitDesignation) then
		contextMenu = FocusFrameDropDown
	elseif UnitIsUnit('player', unitDesignation) then
		contextMenu = PlayerFrameDropDown
	elseif UnitIsUnit('party1', unitDesignation) then
		contextMenu = PartyMemberFrame1DropDown
	elseif UnitIsUnit('party2', unitDesignation) then
		contextMenu = PartyMemberFrame2DropDown
	elseif UnitIsUnit('party3', unitDesignation) then
		contextMenu = PartyMemberFrame3DropDown
	elseif UnitIsUnit('party4', unitDesignation) then
		contextMenu = PartyMemberFrame4DropDown
	else
		contextMenu = TargetFrameDropDown
	end

	assert(contextMenu ~= nil, 'ChorusUnitButtonTemplate.lua: count not determine ' ..
	'appropriate context menu to show for ' .. self:GetName())

	--[[ Not sure what `level` is. Maybe menu nesting? ]]--
	local level = 1
	--[[ Don't know what `value` is. Usually it's nil. ]]--
	local value = nil
	local anchorName = self:GetName() or 'ChorusFrame'
	ToggleDropDownMenu(level, value, contextMenu, anchorName, offsetX, offsetY)
end

--[[--
`ChorusUnitButtonTemplate` handles only the secure, clickable portion of unit
buttons, and *none* of the visuals.

The root template for unit buttons is `ChorusUnitFrameTemplate`.

@see FrameXML/UnitPopup.lua:UnitPopupFrames
@see FrameXML/UIDropDownMenu.lua:function ToggleDropDownMenu

@function unitButtonMain
@tparam frame self this unit button
]]
function Chorus.unitButtonMain(self)
	self:RegisterForClicks('AnyUp')

	--[[ NOTE The menu functions are equivalent of PlayerFrame.menu and
	TargetFrame.menu. It is possible to use them direcctly. THe only
	quirk is that the context menu will be displayed at the display point
	of the native unit frames. Hence, the need to define separate menu
	functions. ]]--

	self.menu = contextMenuToggle

	--[[-- @fixme Selecting "Set focus" option in the context menu for Chorus
	unit button results in permission violation exception (restricted
	execution environment issue).]]

	local focuscastModifier = GetModifiedClick('FOCUSCAST')
	if focuscastModifier and 'NONE' ~= focuscastModifier then
		local key = string.lower(focuscastModifier) .. '-type1'
		self:SetAttribute(key, 'focus')
	end

	--[[ Toggle game tooltip on mouseover. ]]--
	self:SetScript('OnEnter', unitButtonEnterProcessor)
	self:SetScript('OnLeave', unitButtonLeaveProcessor)

	RegisterUnitWatch(self)
end
