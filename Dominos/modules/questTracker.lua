assert(Dominos, "Dominos not found!")
local mod = Dominos:NewModule("QuestLog")
local class = Dominos:CreateClass("Frame", Dominos.Frame)
local LD, L = LibStub("AceLocale-3.0"):GetLocale("Dominos")

function mod:Load()
	if not Dominos:UseQuest() then
		self:Unload()
		return
	end

	self.frame = class:New()
	self.frame:SetFrameStrata("LOW")
end

function mod:Unload()
	if self.frame then
		self.frame:Free()
	end
end

function class:New()
	local f = self.super.New(self, "QuestTracker")
	f:OnLoad()
	f:Layout()
	return f
end

local function TitleBoxMaker(parent)
	local header = parent:CreateTexture(parent:GetName() .. "TitleBox", "ARTWORK")
	header:SetHeight(32)
	header:SetPoint("LEFT", parent, "TOPLEFT", 7, -4)
	header:SetPoint("RIGHT", parent, "TOPRIGHT", -7, -4)
	header.text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	header.text:SetPoint("TOP", header, 0, -14)
	return header
end

function class:GetDefaults()
	return {scale = 1, point = "RIGHT", x = 0, y = 0, width = 100, height = 300, padding = 0}
end

function class:OnLoad()
	self.WFC = CreateFrame("Frame", "DominosQuestFrame", self)
	self.WFC.title = TitleBoxMaker(self.WFC)
	self.WFC.scrollframe = CreateFrame("ScrollFrame", nil, self.WFC)
	self.WFC.scrollframe:SetPoint("BOTTOMRIGHT", -17, 14)
	self.WFC.scrollframe:SetPoint("TOPLEFT", 12, -18)

	self.WFC.scrollframe.scroll = CreateFrame("Slider", "DominosQuestFrameScrollBar", self.WFC.scrollframe, "OptionsSliderTemplate")
	self.WFC.scrollframe.scroll:SetPoint("BOTTOMLEFT", self.WFC.scrollframe, "BOTTOMRIGHT", 2, 6)
	self.WFC.scrollframe.scroll:SetPoint("TOPLEFT", self.WFC.scrollframe, "TOPRIGHT", 2, 3)
	self.WFC.scrollframe.scroll:SetMinMaxValues(1, (75 / 131) * self.sets.height)
	self.WFC.scrollframe.scroll:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\DialogFrame-Left",
		insets = {left = 0, right = 0, top = 15, bottom = 15}
	})
	_G[self.WFC.scrollframe.scroll:GetName() .. "High"]:SetText("")
	_G[self.WFC.scrollframe.scroll:GetName() .. "Low"]:SetText("")
	self.WFC.scrollframe.scroll:SetOrientation("VERTICAL")
	self.WFC.scrollframe.scroll:SetValueStep(5)
	self.WFC.scrollframe.scroll.scrollStep = 1
	self.WFC.scrollframe.scroll:SetWidth(15)

	self.WFC.scrollframe.scroll:SetScript("OnValueChanged", function(self, value) self:GetParent():SetVerticalScroll(value) end)

	class:EnableScroll(self)
	self.scrollchild = CreateFrame("Frame", "scrollchild", self.WFC.scrollframe)
	self.WFC.scrollframe:SetScrollChild(self.scrollchild)
	self.scrollchild:SetHeight(self.sets.height)
	self.WFC:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.WFC:RegisterEvent("QUEST_LOG_UPDATE")
	self.WFC:SetScript("OnEvent", function() class:SetUpContainer(self) end)
end

--[[Layout]]--
function class:Layout()
	self.WFC:SetParent(self)
	local pad = self.sets.padding - 4
	local width = (self.sets.width) + self.sets.padding
	local height = (self.sets.height) + pad

	self:SetSize(width, height)
	self.WFC:SetPoint("TOPLEFT", pad / 2, -pad / 2)
	self.WFC:SetPoint("BOTTOMRIGHT", -pad / 2, pad / 2)
	local w = self.WFC.scrollframe:GetWidth() - 14
	self.scrollchild:SetWidth(w)

	_G.WATCHFRAME_EXPANDEDWIDTH = w
	_G.WATCHFRAME_MAXLINEWIDTH = _G.WATCHFRAME_EXPANDEDWIDTH - 12

	_G.RANDOM_WIDTH_THAT_WONT_BE_OVER_WRITTEN = self.scrollchild:GetWidth()
	WatchFrame:SetWidth(w - 5)
	WatchFrame_Update()
end

do
	-- the following function doesn't work for some reason, i need
	-- to check more why and try to fix it.
	local function scrollbar_OnScroll(self, arg1)
		local WFC = self.WFC
		if not WFC or WFC:GetName() ~= "DominosQuestFrame" then
			WFC = self
		end
		if not WFC or WFC:GetName() ~= "DominosQuestFrame" then
			WFC = WFC:GetParent()
		end
		if not WFC or WFC:GetName() ~= "DominosQuestFrame" then
			WFC = WFC:GetParent()
		end

		local step = (WFC.scrollframe.scroll:GetValueStep() * arg1)
		local value = WFC.scrollframe.scroll:GetValue()
		local minVal, maxVal = WFC.scrollframe.scroll:GetMinMaxValues()
		if step > 0 then
			WFC.scrollframe.scroll:SetValue(min(value - step, maxVal))
		else
			WFC.scrollframe.scroll:SetValue(max(value - step, minVal))
		end
	end

	function class:EnableScroll(f)
		if not f.sets.disablescroll then
			f.WFC.scrollframe.scroll:Show()
			f.WFC.scrollframe:EnableMouseWheel(true)
			f.WFC.scrollframe.scroll:EnableMouseWheel(true)
			f.WFC.scrollframe:SetScript("OnMouseWheel", scrollbar_OnScroll)
			f.WFC.scrollframe.scroll:SetScript("OnMouseWheel", scrollbar_OnScroll)
			f:EnableMouseWheel(false)
			f:SetScript("OnMouseWheel", nil)
		else
			f.WFC.scrollframe.scroll:SetValue(1)
			f.WFC.scrollframe.scroll:Hide()
			f.WFC.scrollframe:EnableMouseWheel(false)
			f.WFC.scrollframe.scroll:EnableMouseWheel(false)
			f.WFC.scrollframe:SetScript("OnMouseWheel", nil)
			f.WFC.scrollframe.scroll:SetScript("OnMouseWheel", nil)
			f:EnableMouseWheel(true)
			f:SetScript("OnMouseWheel", scrollbar_OnScroll)
		end
	end
end

function class:ToggleScroll(enable)
	self.sets.disablescroll = enable or nil
	class:EnableScroll(self)
end

function class:SetUpContainer(f)
	f.WFC.scrollframe.scroll:SetValue(1)
	WatchFrame_Update()
	WatchFrame:ClearAllPoints()
	WatchFrame:SetHeight(f.sets.height)
	WatchFrame:SetMovable(true)
	WatchFrame:SetUserPlaced(true)

	WatchFrame:SetParent(f.scrollchild)
	WatchFrame:SetClampedToScreen(false)
	WatchFrame:SetPoint("TOPLEFT", 24, 0)

	WatchFrameCollapseExpandButton:SetParent(f.WFC)
	WatchFrameCollapseExpandButton:ClearAllPoints()
	WatchFrameCollapseExpandButton:SetPoint("TOPRIGHT", -1, 0)

	WatchFrameCollapseExpandButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self)
		GameTooltip:AddLine(LD.QuestTracker, 1, 1, 1)
		GameTooltip:AddLine(WatchFrame.collapsed and LD.QuestLClick1 or LD.QuestLClick2)
		GameTooltip:AddLine(LD.QuestRClick)
		GameTooltip:AddLine(LD.QuestSClick)
		GameTooltip:Show()
	end)

	WatchFrameCollapseExpandButton:Show()
	--Had to increase the frame level so
	--the button would stay on top of the scroll bar
	WatchFrameCollapseExpandButton:SetFrameLevel(f.WFC.scrollframe.scroll:GetFrameLevel() + 3)
	WatchFrameCollapseExpandButton.Hide = function() end
	WatchFrameCollapseExpandButton.Disable = function() end
	WatchFrameCollapseExpandButton:RegisterForClicks("AnyDown")
	WatchFrameCollapseExpandButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	WatchFrameCollapseExpandButton:SetScript("OnClick", function(_, btn)
		if IsShiftKeyDown() then
			ToggleAchievementFrame()
		elseif btn == "RightButton" then
			ToggleFrame(QuestLogFrame)
		else
			WatchFrame_CollapseExpandButton_OnClick()
			if not f.sets.disablescroll then
				local scroll = f.WFC.scrollframe.scroll
				if scroll:IsVisible() then
					scroll:Hide()
				else
					scroll:Show()
				end
			end
		end
	end)

	WatchFrameHeader:ClearAllPoints()
	WatchFrameHeader:SetAllPoints(f.WFC.title)
	WatchFrameHeader:SetParent(f.WFC)
	WatchFrameHeader:SetFrameLevel(WatchFrameHeader:GetParent():GetFrameLevel() + 2)
	WatchFrameTitle:ClearAllPoints()
	WatchFrameTitle:SetPoint("CENTER")
	WatchFrameTitle.Hide = function() end
	WatchFrameTitle:SetParent(WatchFrameHeader)
	WatchFrameLines:ClearAllPoints()
	WatchFrameLines:SetPoint("TOPLEFT", WatchFrame, "TOPLEFT", 0, 0)
	WatchFrameLines:SetPoint("BOTTOMRIGHT", WatchFrame, "BOTTOMRIGHT", -24, 12)
end

--[[ Layout Panel ]]--
local function CreateWidthSlider(p)
	local s = p:NewSlider("Width", 1, 160, 1)
	s.OnShow = function(self)
		self:SetValue(self:GetParent().owner.sets.width - 134)
	end
	s.UpdateValue = function(self, value)
		local f = self:GetParent().owner
		f.sets.width = value + 134
		f:Layout()
	end
end

local function CreateHeightSlider(p)
	local s = p:NewSlider("Height", 50, math.floor(GetScreenHeight()), 1)
	s.OnShow = function(self)
		self:SetValue(self:GetParent().owner.sets.height)
	end
	s.UpdateValue = function(self, value)
		local f = self:GetParent().owner
		f.sets.height = value
		f:Layout()
	end
end

local function CreatePaddingSlider(p)
	local s = p:NewSlider("Padding", -10, 90, 1)
	s.OnShow = function(self)
		self:SetValue(self:GetParent().owner.sets.padding)
	end
	s.UpdateValue = function(self, value)
		local f = self:GetParent().owner
		f.sets.padding = value

		f:Layout()
	end
end

local function AddLayoutPanel(menu)
	local p = menu:NewPanel(LibStub("AceLocale-3.0"):GetLocale("Dominos-Config").Layout)
	p:NewOpacitySlider()
	p:NewFadeSlider()
	CreateWidthSlider(p)
	CreateHeightSlider(p)
	CreatePaddingSlider(p)
	p:NewScaleSlider()

	local ToggleScroll = p:NewCheckButton("Disable ScrollBar")
	ToggleScroll:SetScript("OnClick", function(self) self:GetParent().owner:ToggleScroll(self:GetChecked()) end)
	ToggleScroll:SetScript("OnShow", function(self) self:SetChecked(self:GetParent().owner.sets.disablescroll) end)
end

--[[ Menu Code ]]
function class:CreateMenu()
	local menu = self.menu or Dominos:NewMenu(self.id)
	L = L or LibStub("AceLocale-3.0"):GetLocale("Dominos-Config")
	AddLayoutPanel(menu)
	self.menu = menu
end

--[[ Override of the Default Tracker Width ]]
--[[ Need to make this a secure hook! HOW???? ]]
local oldSetWidth = WatchFrame.SetWidth
WatchFrame.SetWidth = function(self, width)
	oldSetWidth(self, width)
end