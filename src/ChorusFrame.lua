--[[--
@submodule chorus
]]

local UIParent = UIParent

local Chorus = Chorus

local function disableNativeFrames()
	local t = {
		FocusFrame,
		PlayerFrame,
		TargetFrame,
		PartyMemberFrame1,
		PartyMemberFrame2,
		PartyMemberFrame3,
		PartyMemberFrame4,
		PartyMemberBackground,
	}
	local i = 0
	while (i < #t) do
		i = i + 1
		local e = t[i]
		if e then
			e:Hide()
			e:HookScript('OnShow', function(self)
				self:Hide()
			end)
			--[[ Post-hook hack ]]--
			local v = e:GetScript('OnEvent')
			e:SetScript('OnEvent', function(self, ...)
				v(self, ...)
				self:Hide()
			end)
		end
	end
end

local function applyLayout(self)
	assert(self ~= nil)
	assert(UIParent ~= nil)

	self:UnregisterAllEvents();
	self:SetScript('OnEvent', nil)

	ChorusPlayerFrameHealthFrame.strategy = 'UnitClass'
	ChorusFocusFrameHealthFrame.strategy = 'UnitIsFriend'
	ChorusFocusFrameUnitNameFrame.strategy = 'UnitClass'

	ChorusTargetFrameHealthFrame.strategy = 'UnitIsFriend'
	ChorusTargetFrameUnitNameFrame.strategy = 'UnitClass'

end

--[[--
`ChorusFrame` is a concrete (not virtual tempalte) frame instance, that
orchestrates all over frames.

`ChorusFrame` is effectively a singleton.

@function chorusFrameMain
@tparam fram self
]]
local function chorusFrameMain(self)
	--[[ Wait for the game to finish loading completely, only then apply
	changes. ]]--

	self:SetScript('OnEvent', applyLayout)

	self:RegisterEvent('PLAYER_LOGIN');

	disableNativeFrames()
end

Chorus.chorusFrameMain = function(...)
	return chorusFrameMain(...)
end
