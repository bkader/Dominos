--[[ Menu.lua ]] --
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

local Menu = Dominos:CreateClass("Frame")
Dominos.Menu = Menu

local L = LibStub("AceLocale-3.0"):GetLocale("Dominos-Config")
local _G = _G
local max = math.max
local min = math.min

Menu.bg = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	insets = {left = 11, right = 11, top = 12, bottom = 11},
	tile = true,
	tileSize = 32,
	edgeSize = 32
}

Menu.extraWidth = 20
Menu.extraHeight = 40

function Menu:New(name)
	local f = self:Bind(CreateFrame("Frame", "DominosFrameMenu" .. name, UIParent))
	f.panels = {}

	f:SetBackdrop(self.bg)
	f:EnableMouse(true)
	f:SetToplevel(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:SetFrameStrata("DIALOG")
	f:SetScript("OnMouseDown", self.StartMoving)
	f:SetScript("OnMouseUp", self.StopMovingOrSizing)

	--title text
	f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	f.text:SetPoint("TOP", 0, -15)

	--close button
	f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	f.close:SetPoint("TOPRIGHT", -5, -5)

	return f
end

--tells the panel what frame we're pointed to
function Menu:SetOwner(owner)
	for _, f in pairs(self.panels) do
		f.owner = owner
	end

	if tonumber(owner.id) then
		self.text:SetFormattedText(L.ActionBarSettings, owner.id)
	else
		self.text:SetFormattedText(L.BarSettings, tostring(owner.id):gsub("^%l", string.upper))
	end

	self:Anchor(owner)
end

function Menu:Anchor(f)
	local ratio = UIParent:GetScale() / f:GetEffectiveScale()
	local x = f:GetLeft() / ratio
	local y = f:GetTop() / ratio

	self:ClearAllPoints()
	self:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x, y)
end

--shows a given panel
function Menu:ShowPanel(name)
	for i, panel in pairs(self.panels) do
		if panel.name == name then
			if self.dropdown then
				UIDropDownMenu_SetSelectedValue(self.dropdown, i)
			end
			panel:Show()
			self:SetWidth(max(200, panel.width + self.extraWidth))
			self:SetHeight(max(40, panel.height + self.extraHeight))
		else
			panel:Hide()
		end
	end
end

function Menu:GetSelectedPanel()
	for i, panel in pairs(self.panels) do
		if panel:IsShown() then
			return i
		end
	end
	return 1
end

function Menu:NewPanel(name)
	local panel = self.Panel:New(name, self)
	panel.name = name
	table.insert(self.panels, panel)

	if not self.dropdown and #self.panels > 1 then
		self.dropdown = self:NewPanelSelector()
	end

	return panel
end

function Menu:AddLayoutPanel()
	local panel = self:NewPanel(L.Layout)

	panel.opacitySlider = panel:NewOpacitySlider()
	panel.fadeSlider = panel:NewFadeSlider()
	panel.scaleSlider = panel:NewScaleSlider()
	panel.spacingSlider = panel:NewSpacingSlider()
	panel.paddingSlider = panel:NewPaddingSlider()
	panel.colsSlider = panel:NewColumnsSlider()

	return panel
end

function Menu:AddAdvancedPanel()
	local panel = self:NewPanel(L.Advanced)

	panel:NewLeftToRightCheckbox()
	panel:NewTopToBottomCheckbox()
	panel:NewSpacingSliders()
	panel:NewPaddingSliders()

	panel.width = 250
	return panel
end

do
	local info = {}
	local function AddItem(text, value, func, checked)
		info.text = text
		info.func = func
		info.value = value
		info.checked = checked
		info.arg1 = text
		UIDropDownMenu_AddButton(info)
	end

	local function Dropdown_OnShow(self)
		UIDropDownMenu_SetWidth(self, 110)
		UIDropDownMenu_Initialize(self, self.Initialize)
		UIDropDownMenu_SetSelectedValue(self, self:GetParent():GetSelectedPanel())
	end

	function Menu:NewPanelSelector()
		local f = CreateFrame("Frame", self:GetName() .. "PanelSelector", self, "UIDropDownMenuTemplate")
		_G[f:GetName() .. "Text"]:SetJustifyH("LEFT")

		f:SetScript("OnShow", Dropdown_OnShow)

		local function Item_OnClick(item, name)
			self:ShowPanel(name)
			UIDropDownMenu_SetSelectedValue(f, item.value)
		end

		function f:Initialize()
			local parent = self:GetParent()
			local selected = parent:GetSelectedPanel()
			for i, panel in ipairs(parent.panels) do
				AddItem(panel.name, i, Item_OnClick, i == selected)
			end
		end

		f:SetPoint("TOPLEFT", 0, -36)
		for _, panel in pairs(self.panels) do
			panel:SetPoint("TOPLEFT", 10, -(32 + f:GetHeight() + 6))
		end

		self.extraHeight = (self.extraHeight or 0) + f:GetHeight() + 6

		return f
	end
end

--[[ Panel Components ]]--
--a panel is a subframe of a menu, basically
local Panel = Dominos:CreateClass("Frame")
Menu.Panel = Panel

Panel.width = 0
Panel.height = 0

function Panel:New(name, parent)
	local f = self:Bind(CreateFrame("Frame", parent:GetName() .. name, parent))
	if parent.dropdown then
		f:SetPoint("TOPLEFT", 10, -(32 + parent.dropdown:GetHeight() + 4))
	else
		f:SetPoint("TOPLEFT", 10, -32)
	end
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:Hide()

	return f
end

--[[ Checkbuttons ]]--
function Panel:NewCheckButton(name)
	local button = CreateFrame("CheckButton", self:GetName() .. name, self, "InterfaceOptionsCheckButtonTemplate")
	_G[button:GetName() .. "Text"]:SetText(name)

	local prev = self.checkbutton
	if prev then
		button:SetPoint("TOP", prev, "BOTTOM", 0, -2)
	else
		button:SetPoint("TOPLEFT", 2, 0)
	end
	self.height = self.height + 28
	self.checkbutton = button

	return button
end

--[[ Sliders ]]--
do
	local function Slider_OnMouseWheel(self, arg1)
		local step = self:GetValueStep() * arg1
		local value = self:GetValue()
		local minVal, maxVal = self:GetMinMaxValues()

		if step > 0 then
			self:SetValue(min(value + step, maxVal))
		else
			self:SetValue(max(value + step, minVal))
		end
	end

	local function Slider_OnShow(self)
		self.showing = true

		if self.OnShow then
			self:OnShow()
		end

		self.showing = nil
	end

	local function Slider_OnValueChanged(self, value)
		if not self.showing then
			self:UpdateValue(value)
		end

		if self.UpdateText then
			self:UpdateText(value)
		else
			self.valText:SetText(value)
		end
	end

	function Panel:NewSlider(text, low, high, step, OnShow, UpdateValue, UpdateText)
		local name = self:GetName() .. text

		local slider = CreateFrame("Slider", name, self, "OptionsSliderTemplate")
		slider:SetMinMaxValues(low, high)
		slider:SetValueStep(step)
		slider:EnableMouseWheel(true)
		BlizzardOptionsPanel_Slider_Enable(slider) --colors the slider properly

		_G[name .. "Text"]:SetText(text)
		_G[name .. "Low"]:SetText("")
		_G[name .. "High"]:SetText("")

		local t = slider:CreateFontString(nil, "BACKGROUND")
		t:SetFontObject("GameFontHighlightSmall")
		t:SetPoint("LEFT", slider, "RIGHT", 7, 0)
		slider.valText = t

		slider.OnShow = OnShow
		slider.UpdateValue = UpdateValue
		slider.UpdateText = UpdateText

		slider:SetScript("OnShow", Slider_OnShow)
		slider:SetScript("OnValueChanged", Slider_OnValueChanged)
		slider:SetScript("OnMouseWheel", Slider_OnMouseWheel)

		local prev = self.slider
		if prev then
			slider:SetPoint("BOTTOM", prev, "TOP", 0, 16)
			self.height = self.height + 34
		else
			slider:SetPoint("BOTTOMLEFT", 4, 4)
			self.height = self.height + 38
		end
		self.slider = slider

		return slider
	end
end

--scale
do
	local function Slider_OnShow(self)
		self:SetValue(self:GetParent().owner:GetScale() * 100)
	end

	local function Slider_UpdateValue(self, value)
		self:GetParent().owner:SetFrameScale(value / 100)
	end

	function Panel:NewScaleSlider()
		return self:NewSlider(L.Scale, 50, 150, 1, Slider_OnShow, Slider_UpdateValue)
	end
end

--opacity
do
	local function Slider_OnShow(self)
		self:SetValue(self:GetParent().owner:GetFrameAlpha() * 100)
	end

	local function Slider_UpdateValue(self, value)
		self:GetParent().owner:SetFrameAlpha(value / 100)
	end

	function Panel:NewOpacitySlider()
		return self:NewSlider(L.Opacity, 0, 100, 1, Slider_OnShow, Slider_UpdateValue)
	end
end

--faded opacity
do
	local function Slider_OnShow(self)
		self:SetValue(self:GetParent().owner:GetFadeMultiplier() * 100)
	end

	local function Slider_UpdateValue(self, value)
		self:GetParent().owner:SetFadeMultiplier(value / 100)
	end

	function Panel:NewFadeSlider()
		return self:NewSlider(L.FadedOpacity, 0, 100, 1, Slider_OnShow, Slider_UpdateValue)
	end
end

--padding
do
	local function Slider_OnShow(self)
		self:SetValue(self:GetParent().owner:GetPadding())
	end

	local function Slider_UpdateValue(self, value)
		self:GetParent().owner:SetPadding(value)
	end

	function Panel:NewPaddingSlider()
		return self:NewSlider(L.Padding, -16, 32, 1, Slider_OnShow, Slider_UpdateValue)
	end
end

--padding (horizontal and vertical)
do
	local function HSlider_OnShow(self)
		self:SetValue(self:GetParent().owner:GetPadding())
	end

	local function HSlider_UpdateValue(self, value)
		local _, padH = self:GetParent().owner:GetPadding()
		self:GetParent().owner:SetPadding(value, padH)
	end

	local function VSlider_OnShow(self)
		local _, padH = self:GetParent().owner:GetPadding()
		self:SetValue(padH)
	end

	local function VSlider_UpdateValue(self, value)
		local padW = self:GetParent().owner:GetPadding()
		self:GetParent().owner:SetPadding(padW, value)
	end

	function Panel:NewPaddingSliders()
		local hslider = self:NewSlider(L.PaddingHor, -16, 32, 1, HSlider_OnShow, HSlider_UpdateValue)
		local vslider = self:NewSlider(L.PaddingVer, -16, 32, 1, VSlider_OnShow, VSlider_UpdateValue)
		return hslider, vslider
	end
end

--spacing
do
	local function Slider_OnShow(self)
		self:SetValue(self:GetParent().owner:GetSpacing())
	end

	local function Slider_UpdateValue(self, value)
		self:GetParent().owner:SetSpacing(value)
	end

	function Panel:NewSpacingSlider()
		return self:NewSlider(L.Spacing, -8, 32, 1, Slider_OnShow, Slider_UpdateValue)
	end
end

--spacing (horizontal and vertical)
do
	local function HSlider_OnShow(self)
		self:SetValue(self:GetParent().owner:GetSpacing())
	end

	local function HSlider_UpdateValue(self, value)
		local _, vspacing = self:GetParent().owner:GetSpacing()
		self:GetParent().owner:SetSpacing(value, vspacing)
	end

	local function VSlider_OnShow(self)
		local _, vspacing = self:GetParent().owner:GetSpacing()
		self:SetValue(vspacing)
	end

	local function VSlider_UpdateValue(self, value)
		local hspacing = self:GetParent().owner:GetSpacing()
		self:GetParent().owner:SetSpacing(hspacing, value)
	end

	function Panel:NewSpacingSliders()
		local hslider = self:NewSlider(L.SpacingHor, -8, 32, 1, HSlider_OnShow, HSlider_UpdateValue)
		local vslider = self:NewSlider(L.SpacingVer, -8, 32, 1, VSlider_OnShow, VSlider_UpdateValue)
		return hslider, vslider
	end
end

--columns
do
	local function Slider_OnShow(self)
		local min, max = 1, self:GetParent().owner:NumButtons()
		if max > min then
			BlizzardOptionsPanel_Slider_Enable(self)
			self:SetMinMaxValues(min, max)
		else
			BlizzardOptionsPanel_Slider_Disable(self)
			self:SetMinMaxValues(1, 1)
		end
		self:SetValue(self:GetParent().owner:NumColumns())
	end

	local function Slider_UpdateValue(self, value)
		self:GetParent().owner:SetColumns(value)
	end

	function Panel:NewColumnsSlider()
		return self:NewSlider(L.Columns, 1, 1, 1, Slider_OnShow, Slider_UpdateValue)
	end
end

--right to left & left to right checkboxes
do
	function Panel:NewLeftToRightCheckbox()
		local b = self:NewCheckButton(L.LeftToRight)
		b:SetScript("OnShow", function(self) self:SetChecked(self:GetParent().owner:GetLeftToRight()) end)
		b:SetScript("OnClick", function(self) self:GetParent().owner:SetLeftToRight(self:GetChecked()) end)
	end

	function Panel:NewTopToBottomCheckbox()
		local b = self:NewCheckButton(L.TopToBottom)
		b:SetScript("OnShow", function(self) self:SetChecked(self:GetParent().owner:GetTopToBottom()) end)

		b:SetScript("OnClick", function(self) self:GetParent().owner:SetTopToBottom(self:GetChecked()) end)
	end
end