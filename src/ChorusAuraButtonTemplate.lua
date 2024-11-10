--[[--
`ChorusAuraButtonTemplate` handles individual aura pictograms.

Features:
  * show formatted remaining aura duration;
  * highlight auras that were applied by the player character;
  * show remaining charge quantity when applicable;
  * show aura artwork;
  * show aura category (Magic, Poison, Disease, Curse);
  * display tooltip on mouseover;

@submodule chorus
]]

local Chorus = Chorus

local GetTime = GetTime
local UnitAura = Chorus.test.UnitAura or UnitAura
local UnitExists = Chorus.test.UnitExists or UnitExists
local UnitIsConnected = Chorus.test.UnitIsConnected or UnitIsConnected
local UnitIsUnit = Chorus.test.UnitIsUnit or UnitIsUnit

local DebuffTypeColor = DebuffTypeColor

local GameTooltip = GameTooltip

local SecureButton_GetUnit = Chorus.test.SecureButton_GetUnit or SecureButton_GetUnit

--[[--
Check given aura button is configured as expected by the rest of the template.

@function auraButtonValidate
@raise assertion exception
@tparam frame auraButton aura button
@return when successful, nothing; when failed, assertion exception;
]]
local function auraButtonValidate(auraButton)
	assert(auraButton ~= nil)

	assert(auraButton.artwork ~= nil)
	assert(auraButton.label ~= nil)
	assert(auraButton.overlay ~= nil)
end

--[[--
Render pictogram artwork for this aura button.

Fallback to a picture of a question mark if the artwork could not be loaded.
That is, when `artworkFile` is `nil`.

@function applyArtwork

@tparam frame auraButton this aura button

@tparam string artworkFile pathname in Windows format with escape characters;
]]
local function applyArtwork(auraButton, artworkFile)
	auraButtonValidate(auraButton)

	if not artworkFile then
		artworkFile = "Interface\\Icons\\INV_Misc_QuestionMark"
	end
	assert(artworkFile ~= nil)
	assert('string' == type(artworkFile))
	artworkFile = strtrim(artworkFile)
	assert(string.len(artworkFile) >= 1)
	assert(string.len(artworkFile) <= 8192)

	local artwork = auraButton.artwork
	assert(artwork ~= nil)
	artwork:SetTexture(artworkFile)
end

--[[--
Render sanitized and color coded border for this aura button.

@see FrameXML/BuffFrame.lua:DebuffTypeColor

@function applyOverlay

@tparam frame auraButton this aura button

@tparam string category key of `DebuffTypeColor` table

@tparam string owner unit designation of caster of the given aura, used for
color coding; in reality, either `player` or `nil`

@return nothing
]]
local function applyOverlay(auraButton, category, owner)
	auraButtonValidate(auraButton)

	if not category then
		--[[ Empty string is equivalent to 'none' by default for DebuffTypeColor. ]]--
		category = ''
	end

	local r = 1
	local g = 1
	local b = 1
	if category then
		assert(category ~= nil)
		assert('string' == type(category))
		category = strtrim(category)
		--[[ Empty string is permissible ]]--
		assert(string.len(category) >= 0)
		assert(string.len(category) <= 256)

		local colorTuple = DebuffTypeColor[category]
		r = colorTuple.r
		g = colorTuple.g
		b = colorTuple.b
	end

	local overlay = auraButton.overlay
	assert(overlay ~= nil)

	overlay:SetVertexColor(r, g, b)

	--[[ ShadowedUnitFrames recommend this approach for adjusting font size. ]]--
	local label = auraButton.label
	assert(label ~= nil)
	local t = label:GetText()
	if t ~= nil and string.len(t) >= 1 then
		local fontSize = 12
		auraButton:SetScale(label:GetStringHeight() / fontSize)
	end

	if owner and 'player' == owner then
		label:SetTextColor(1, 225 / 255, 0)
	else
		label:SetTextColor(1, 1, 1)
	end
end

--[[--
Format the given amount of seconds into a narrow human readable string.

This is inteded for aura effects. It may be used for any generic duration.

@function formatDuration

@tparam number durationSec positive number and not zero, the remaining seconds
of some effect

@treturn string remaining duration coerced into a string that is human
readeable and narrow for convenient rendering
]]
local function formatDuration(durationSec)
	assert(durationSec ~= nil)
	assert('number' == type(durationSec))

	local t
	local durationSecAbs = math.abs(durationSec)
	if durationSecAbs < 60 then
		t = string.format("%.0f", durationSec)
	elseif durationSecAbs < 3600 then
		t = string.format("%.0f m", durationSec / 60)
	elseif durationSecAbs < 3600 * 24 then
		t = string.format("%.0f h", durationSec / 60 / 60)
	else
		t = string.format("%.0f d", durationSec / 60 / 60 / 24)
	end
	return t
end

--[[--
Compute remaining aura duration for this aura button, given time instances,
then sanitize, format and render it.

@function applyDuration

@tparam frame auraButton this aura button

@tparam number now time instance, in the format of `function GetTime`, current
real time

@tparam number totalDurationSec positive number, the total duration in seconds
of the aura

@tparam number expirationInstance  time instance, in the format of `function
GetTime`, the instance when the aura effect ends

@return nothing
]]
local function applyDuration(auraButton, now, totalDurationSec, expirationInstance)
	auraButtonValidate(auraButton)

	assert(now ~= nil)
	assert('number' == type(now))
	assert(now >= 0)

	assert(totalDurationSec ~= nil)
	assert('number' == type(totalDurationSec))
	assert(totalDurationSec >= 0)

	assert(expirationInstance ~= nil)
	assert('number' == type(expirationInstance))
	assert(expirationInstance >= 0)

	local label = auraButton.label
	assert (label ~= nil)

	local durationRemainingSec
	if totalDurationSec and now < expirationInstance then
		durationRemainingSec = expirationInstance - now
	end

	local t
	if durationRemainingSec then
		t = formatDuration(durationRemainingSec)
	else
		--[[ The aura button text is color coded to report if the owner
		     of the aura is the user or another player. Therefore, the
		     label should never be empty. ]]--
		t = '∞'
	end

	label:SetText(t)

	local artwork = auraButton.artwork
	if artwork and totalDurationSec and durationRemainingSec and totalDurationSec >= 12 and durationRemainingSec <= 3 then
		artwork:SetAlpha(0.6)
	else
		artwork:SetAlpha(1)
	end
end

--[[--
Sanitize, format and render the charge quantity for this aura button.

@function applyChargeQuantity

@tparam frame auraButton this aura button

@tparam integer chargeQuantity positive integer and not zero, the remaining
charges (stacks) of the aura

@return nothing
]]
local function applyChargeQuantity(auraButton, chargeQuantity)
	auraButtonValidate(auraButton)

	local label = auraButton.label2
	assert (label ~= nil)

	local t = nil
	if chargeQuantity then
		assert(chargeQuantity ~= nil)
		assert('number' == type(chargeQuantity))
		chargeQuantity = math.abs(math.floor(chargeQuantity))
		if chargeQuantity < 2 then
			t = nil
		elseif chargeQuantity < 100 then
			t = string.format('%d', chargeQuantity)
		else
			t = '>99'
		end
	end
	label:SetText(t)
end

--[[--
Every frame, update the remaining duration and remaining stack quantity of the
aura, of this aura button.

Update scripts like this should be optimized for performance. Update scripts
also rely on the current real time and implicit game state.

Remaining duration of an aura cannot be queried. It must be computed, given
time instances that could be queried. This is the purpose of the update
processor function.

@see FrameXML/SecureTemplates.lua:function SecureButton_GetUnit
@function auraButtonUpdateProcessor
@tparam frame self aura button
@return nothing
]]
local function auraButtonUpdateProcessor(self)
	local unitDesignation = SecureButton_GetUnit(self)
	local index = self.index
	local filter = SecureButton_GetAttribute(self, 'filter')
	if not unitDesignation or not index then
		return
	end
	local name, _, _, chargeQuantity, _, durationSec, expirationInstance = UnitAura(unitDesignation, index, filter)
	if not name then
		return
	end
	applyDuration(self, GetTime(), durationSec, expirationInstance)
	applyChargeQuantity(self, chargeQuantity)
end

--[[--
Request relevant aura details, then apply them to the aura button.

@function apply

@see auraButtonUpdateProcessor

@tparam frame auraButton

@tparam string unitDesignation corresponding unit

@tparam integer auraIndex positive integer and not zero, sequantial number of a
single aura from the list relevant to the unit

@tparam string filter usually either BUFF or DEBUFF, mutually exclusive

@return nothing
]]
local function apply(auraButton, unitDesignation, auraIndex, filter)
	auraButtonValidate(auraButton)

	assert(unitDesignation ~= nil)
	assert('string' == type(unitDesignation))
	unitDesignation = string.lower(strtrim(unitDesignation))
	assert(string.len(unitDesignation) >= 1)
	assert(string.len(unitDesignation) <= 256)

	assert(auraIndex ~= nil)
	assert('number' == type(auraIndex))
	auraIndex = math.min(math.max(0, math.abs(math.floor(auraIndex))), 8192)

	assert(filter ~= nil)
	assert('string' == type(filter))
	filter = string.upper(strtrim(filter))
	assert(string.len(filter) >= 1)
	assert(string.len(filter) <= 256)

	--[[ @warning Aura button event processor might fail in restricted
	environment. ]]--

	if not UnitExists(unitDesignation) or not UnitIsConnected(unitDesignation) then
		auraButton:Hide()
		auraButton:SetScript('OnUpdate', nil)
		return
	end

	local name, _, artworkFile, chargeQuantity, category, durationSec, expirationInstance,
	      owner = UnitAura(unitDesignation, auraIndex, filter)
	if name then
		auraButton:Show()
		auraButton:SetScript('OnUpdate', auraButtonUpdateProcessor)
	else
		auraButton:Hide()
		auraButton:SetScript('OnUpdate', nil)
		return
	end

	applyArtwork(auraButton, artworkFile)
	applyDuration(auraButton, GetTime(), durationSec, expirationInstance)
	applyOverlay(auraButton, category, owner)
	applyChargeQuantity(auraButton, chargeQuantity)
end

--[[--
Process stream of events, filter events only relevant to the aura button.

When aura is added or removed from a unit, given the aura button is assigned to
watch that unit, then apply relevant changes to the aura button.

@function auraButtonEventProcessor
@see FrameXML/SecureTemplates.lua:function SecureButton_GetUnit
@see apply
@tparam frame self the aura button
@tparam string eventCategory event category designation of the given event
@param unitDesignation vararg, given `UNIT_AURA`, the relevant unit
@return nothing
]]
function Chorus.auraButtonEventProcessor(self, eventCategory, ...)
	auraButtonValidate(self)

	local u = SecureButton_GetUnit(self) or 'none'
	assert(u ~= nil)
	assert('string' == type(u))
	u = string.lower(strtrim(u))
	assert(string.len(u) >= 1)
	assert(string.len(u) <= 256)

	--[[ Break if unit doesn't exist. ]]--
	if UnitExists(u) and UnitIsConnected(u) then
		self:Show()
	else
		self:Hide()
		return
	end

	--[[ Break if event is not relevant to this button. ]]--
	if eventCategory then
		assert(eventCategory ~= nil)
		assert('string' == type(eventCategory))
		eventCategory = string.upper(strtrim(eventCategory))
		assert(string.len(eventCategory) >= 1)
		assert(string.len(eventCategory) <= 256)

		local o = select(1, ...)
		if eventCategory == 'UNIT_AURA' and o and not UnitIsUnit(u, o) then
			self:Hide()
			return
		end
	end

	--[[ Do work. ]]--
	local i = self.index or 0
	assert(i ~= nil)
	assert('number' == type(i))
	i = math.min(math.max(0, math.abs(math.floor(i))), 8192)

	local filter = SecureButton_GetAttribute(self, 'filter')
	assert(filter ~= nil)
	assert('string' == type(filter))
	filter = string.upper(strtrim(filter))
	assert(string.len(filter) >= 1)
	assert(string.len(filter) <= 256)

	apply(self, u, i, filter)
end

--[[--
Process the state of given aura button, then apply the details to the native
`GameTooltip`.

@see FrameXML/GameTooltip.lua:GameTooltip
@see FrameXML/SecureTemplates.lua:function SecureButton_GetUnit
@function auraButtonGameTooltipShow
@tparam frame self the aura button
@return nothing
]]
function Chorus.auraButtonGameTooltipShow(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetFrameLevel(self:GetFrameLevel() + 2);
	local unitDesignation = SecureButton_GetUnit(self) or 'none'
	local filter = SecureButton_GetAttribute(self, 'filter') or self.filter
	local index = self.index
	local spellName = SecureButton_GetAttribute(self, 'spell') or self.spell
	if index then
		GameTooltip:SetUnitAura(unitDesignation, index, filter)
	elseif spellName then
		local rank = nil
		GameTooltip:SetUnitAura(unitDesignation, spellName, rank, filter)
	end
end

--[[--
Hide the tooltip associated with the aura button, if necessary.

Effectively, simply hides the native `GameTooltip`.

@see FrameXML/GameTooltip.lua:GameTooltip
@function auraButtonGameTooltipHide
@return nothing
]]
function Chorus.auraButtonGameTooltipHide()
	GameTooltip:Hide();
end

--[[--
Initialize the aura button frame with callbacks and children.

@function auraButtonMain
@tparam frame self
@return nothing
]]
function Chorus.auraButtonMain(self)
	local n = self:GetName()
	if n then
		self.artwork = _G[n .. 'Artwork']
		self.label = _G[n .. 'Text1']
		self.label2 = _G[n .. 'Text2']
		self.overlay = _G[n .. 'Overlay']
	end
	self:SetScript('OnEvent', Chorus.auraButtonEventProcessor)
	self:RegisterEvent('ADDON_LOADED')
	self:RegisterEvent('UNIT_AURA')
	auraButtonValidate(self)
end
