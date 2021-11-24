--[[
general.lua
The general panel of the Dominos options menu
--]]
--[[
	Copyright (c) 2008-2009 Jason Greer
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

		* Redistributions of source code must retain the above copyright notice,
		  this list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright
		  notice, this list of conditions and the following disclaimer in the
		  documentation and/or other materials provided with the distribution.
		* Neither the name of the author nor the names of its contributors may
		  be used to endorse or promote products derived from this software
		  without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
	LIABLE FORANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
--]]
local Dominos = Dominos
local Options = Dominos.Options
local L = LibStub("AceLocale-3.0"):GetLocale("Dominos-Config")

--[[ Buttons ]]--
--toggle config mode
local lock = Options:NewButton(L.EnterConfigMode, 131, 22)
lock:SetScript("OnClick", function(self)
	Dominos:ToggleLockedFrames()
	HideUIPanel(InterfaceOptionsFrame)
end)
lock:SetPoint("TOPLEFT", 12, -60)

--toggle keybinding mode
local bind = Options:NewButton(L.EnterBindingMode, 126, 22)
bind:SetScript("OnClick", function(self)
	Dominos:ToggleBindingMode()
	HideUIPanel(InterfaceOptionsFrame)
end)
bind:SetPoint("LEFT", lock, "RIGHT", 4, 0)

--reload ui
local reload = Options:NewButton(L.ReloadUI, 126, 22)
reload:SetScript("OnClick", function(self) ReloadUI() end)
reload:SetPoint("LEFT", bind, "RIGHT", 4, 0)

--[[ Check Buttons ]]--
--[[ General Settings ]]--
local stickyBars = Options:NewCheckButton(L.StickyBars)
stickyBars:SetScript("OnShow", function(self) self:SetChecked(Dominos:Sticky()) end)
stickyBars:SetScript("OnClick", function(self) Dominos:SetSticky(self:GetChecked()) end
)
stickyBars:SetPoint("TOPLEFT", lock, "BOTTOMLEFT", 0, -5)

local linkedOpacity = Options:NewSmallCheckButton(L.LinkedOpacity)
linkedOpacity:SetScript("OnShow", function(self) self:SetChecked(Dominos:IsLinkedOpacityEnabled()) end)
linkedOpacity:SetScript("OnClick", function(self) Dominos:SetLinkedOpacity(self:GetChecked()) end)
linkedOpacity:SetPoint("TOP", stickyBars, "BOTTOM", 8, 3)

local showMinimapButton = Options:NewCheckButton(L.ShowMinimapButton)
showMinimapButton:SetScript("OnShow", function(self) self:SetChecked(Dominos:ShowingMinimap()) end)
showMinimapButton:SetScript("OnClick", function(self) Dominos:SetShowMinimap(self:GetChecked()) end)
showMinimapButton:SetPoint("TOP", linkedOpacity, "BOTTOM", -8, 0)

--[[ Action Bar Settings ]]--
--lock action button positions
--this option causes taint, but only for the session that the option is set in
local lockButtons = Options:NewCheckButton(L.LockActionButtons)
lockButtons:SetScript("OnShow", function(self) self:SetChecked(LOCK_ACTIONBAR == "1") end)
lockButtons:SetScript("OnClick", function(self, ...)
	_G["InterfaceOptionsActionBarsPanelLockActionBars"]:Click(...)
	self:SetChecked(LOCK_ACTIONBAR == "1")
end)
lockButtons:SetPoint("TOP", showMinimapButton, "BOTTOM", 0, 3)

--show empty buttons
local showEmpty = Options:NewCheckButton(L.ShowEmptyButtons)
showEmpty:SetScript("OnShow", function(self) self:SetChecked(Dominos:ShowGrid()) end)
showEmpty:SetScript("OnClick", function(self) Dominos:SetShowGrid(self:GetChecked()) end)
showEmpty:SetPoint("TOP", lockButtons, "BOTTOM", 0, 3)

--show keybinding text
local showBindings = Options:NewCheckButton(L.ShowBindingText)
showBindings:SetScript("OnShow", function(self) self:SetChecked(Dominos:ShowBindingText()) end)
showBindings:SetScript("OnClick", function(self) Dominos:SetShowBindingText(self:GetChecked()) end)
showBindings:SetPoint("TOP", showEmpty, "BOTTOM", 0, 3)

--show macro text
local showMacros = Options:NewCheckButton(L.ShowMacroText)
showMacros:SetScript("OnShow", function(self) self:SetChecked(Dominos:ShowMacroText()) end)
showMacros:SetScript("OnClick", function(self) Dominos:SetShowMacroText(self:GetChecked()) end)
showMacros:SetPoint("TOP", showBindings, "BOTTOM", 0, 3)

--show tooltips
local showTooltips = Options:NewCheckButton(L.ShowTooltips)
showTooltips:SetScript("OnShow", function(self) self:SetChecked(Dominos:ShowTooltips()) end)
showTooltips:SetScript("OnClick", function(self) Dominos:SetShowTooltips(self:GetChecked()) end)
showTooltips:SetPoint("TOP", showMacros, "BOTTOM", 0, 3)

--use Dominos castbar
local useCastbar = Options:NewCheckButton(L.UseCastbar)
useCastbar:SetScript("OnShow", function(self) self:SetChecked(Dominos:UseCastbar()) end)
useCastbar:SetScript("OnClick", function(self) Dominos:SetUseCastbar(self:GetChecked()) end)
useCastbar:SetPoint("TOP", showTooltips, "BOTTOM", 0, 3)

--use Dominos minimap
local useMinimap = Options:NewCheckButton(L.UseMinimap)
useMinimap:SetScript("OnShow", function(self) self:SetChecked(Dominos:UseMinimap()) end)
useMinimap:SetScript("OnClick", function(self) Dominos:SetUseMinimap(self:GetChecked()) end)
useMinimap:SetPoint("TOP", useCastbar, "BOTTOM", 0, 3)

--use Dominos buffs
local useBuffs = Options:NewCheckButton(L.UseAuras)
useBuffs:SetScript("OnShow", function(self) self:SetChecked(Dominos:UseAuras()) end)
useBuffs:SetScript("OnClick", function(self) Dominos:SetUseAuras(self:GetChecked()) end)
useBuffs:SetPoint("TOP", useMinimap, "BOTTOM", 0, 3)

--use Dominos quest
local useQuest = Options:NewCheckButton(L.UseQuest)
useQuest:SetScript("OnShow", function(self) self:SetChecked(Dominos:UseQuest()) end)
useQuest:SetScript("OnClick", function(self) Dominos:SetUseQuest(self:GetChecked()) end)
useQuest:SetPoint("TOP", useBuffs, "BOTTOM", 0, 3)

--use Default totem bar
if select(2, UnitClass("player")) == "SHAMAN" then
	local aTotemBar = Options:NewCheckButton(L.ATotemBar)
	aTotemBar:SetScript("OnShow", function(self) self:SetChecked(Dominos:ATotemBar()) end)
	aTotemBar:SetScript("OnClick", function(self) Dominos:SetATotemBar(self:GetChecked()) end)
	aTotemBar:SetPoint("TOP", useQuest, "BOTTOM", 0, 3)

	local aTotemBarScale = Options:NewSlider(L.Scale, 0.5, 3, 0.1, true)
	aTotemBarScale:SetWidth(250)
	aTotemBarScale:SetScript("OnShow", function(self)
		self:SetValue(Dominos.db.profile.totemBar and Dominos.db.profile.totemBar.Scale or 1)
	end)
	aTotemBarScale:SetScript("OnValueChanged", function(self, value)
		Dominos.db.profile.totemBar = Dominos.db.profile.totemBar or {}
		Dominos.db.profile.totemBar.Scale = value
		if Dominos.aTotemBar then
			Dominos.aTotemBar:SetScale(value)
			Dominos.aTotemBar:RestorePosition()
		end
	end)
	aTotemBarScale:SetPoint("TOPLEFT", aTotemBar, "BOTTOMLEFT", 0, -10)
end

--[[ Dropdowns ]]--
do
	local info = {}
	local function AddItem(text, value, func, checked, arg1)
		info.text = text
		info.func = func
		info.value = value
		info.checked = checked
		info.arg1 = arg1
		UIDropDownMenu_AddButton(info)
	end

	local function AddClickActionSelector(self, name, action)
		local dd = self:NewDropdown(name)

		dd:SetScript("OnShow", function(self)
			UIDropDownMenu_SetWidth(self, 110)
			UIDropDownMenu_Initialize(self, self.Initialize)
			UIDropDownMenu_SetSelectedValue(self, GetModifiedClick(action) or "NONE")
		end)

		local function Item_OnClick(self)
			SetModifiedClick(action, self.value)
			UIDropDownMenu_SetSelectedValue(dd, self.value)
			SaveBindings(GetCurrentBindingSet())
		end

		function dd:Initialize()
			local selected = GetModifiedClick(action) or "NONE"

			AddItem(ALT_KEY, "ALT", Item_OnClick, "ALT" == selected)
			AddItem(CTRL_KEY, "CTRL", Item_OnClick, "CTRL" == selected)
			AddItem(SHIFT_KEY, "SHIFT", Item_OnClick, "SHIFT" == selected)
			AddItem(NONE_KEY, "NONE", Item_OnClick, "NONE" == selected)
		end
		return dd
	end

	local function AddRightClickTargetSelector(self)
		local dd = self:NewDropdown(L.RightClickUnit)

		dd:SetScript("OnShow", function(self)
			UIDropDownMenu_SetWidth(self, 110)
			UIDropDownMenu_Initialize(self, self.Initialize)
			UIDropDownMenu_SetSelectedValue(self, Dominos:GetRightClickUnit() or "NONE")
		end)

		local function Item_OnClick(self)
			Dominos:SetRightClickUnit(self.value ~= "NONE" and self.value or nil)
			UIDropDownMenu_SetSelectedValue(dd, self.value)
		end

		function dd:Initialize()
			local selected = Dominos:GetRightClickUnit() or "NONE"

			AddItem(L.RCUPlayer, "player", Item_OnClick, "player" == selected)
			AddItem(L.RCUFocus, "focus", Item_OnClick, "focus" == selected)
			AddItem(L.RCUToT, "targettarget", Item_OnClick, "targettarget" == selected)
			AddItem(NONE_KEY, "NONE", Item_OnClick, "NONE" == selected)
		end
		return dd
	end

	local function AddPossessBarSelector(self)
		local dd = self:NewDropdown(L.PossessBar)

		dd:SetScript("OnShow", function(self)
			UIDropDownMenu_SetWidth(self, 110)
			UIDropDownMenu_Initialize(self, self.Initialize)
			UIDropDownMenu_SetSelectedValue(self, Dominos:GetPossessBar().id)
		end)

		local function Item_OnClick(self)
			Dominos:SetPossessBar(self.value)
			UIDropDownMenu_SetSelectedValue(dd, self.value)
		end

		function dd:Initialize()
			local selected = Dominos:GetPossessBar().id

			for i = 1, Dominos:NumBars() do
				AddItem("Action Bar " .. i, i, Item_OnClick, i == selected)
			end
		end
		return dd
	end

	local quickMove = AddClickActionSelector(Options, L.QuickMoveKey, "PICKUPACTION")
	quickMove:SetPoint("TOPRIGHT", -10, -120)

	local rightClickUnit = AddRightClickTargetSelector(Options)
	rightClickUnit:SetPoint("TOP", quickMove, "BOTTOM", 0, -16)

	local possess = AddPossessBarSelector(Options)
	possess:SetPoint("TOP", rightClickUnit, "BOTTOM", 0, -16)
end