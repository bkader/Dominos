assert(Dominos, "Dominos not found!")
local Dominos = Dominos
local L

-- used to kill old function
local function noFunc() return end
local function killFrame(frame)
	if frame then
		frame.SetParent = noFunc
		frame.ClearAllPoints = noFunc
		frame.SetPoint = noFunc
		frame.SetFrameStrata = noFunc
	end
end

local minimapBar = CreateFrame("Frame", "MinimapBar", _G.MinimapClusterBar)

local select = select

local mod = Dominos:NewModule("minimap")
local class = Dominos:CreateClass("Frame", Dominos.Frame)

local menuButtons = {}
do
	local loadButtons = function(...)
		for i = 1, select("#", ...) do
			local btn = select(i, ...)
			tinsert(menuButtons, btn)
		end
	end

	function mod:OnInitialize()
		if Dominos:UseMinimap() then
			MinimapBorderTop:SetParent(MainMenuBarArtFrame)
			MinimapBackdrop:SetParent(MainMenuBarArtFrame)
			Minimap:SetParent(minimapBar)
			loadButtons(minimapBar:GetChildren())
		else
			self:Disable()
		end
	end
end

function mod:Load()
	Minimap:SetBackdrop({
		bgFile = [[Interface\AddOns\Dominos\textures\minimap.blp]],
		insets = {top = -3, bottom = -2, left = -3, right = -2}
	})
	Minimap:SetBackdropColor(0, 0, 0, 1)

	self.frame = class:New()
	self.frame:SetFrameStrata("LOW")

	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap)
	MiniMapInstanceDifficulty:SetFrameStrata("LOW")
	killFrame(MiniMapInstanceDifficulty)
	MiniMapInstanceDifficulty:SetScale(self.frame:GetScale() * 0.75)

	MiniMapLFGFrame:SetParent(minimapBar)
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetPoint("BOTTOMLEFT", Minimap)
	killFrame(MiniMapLFGFrame)
	MiniMapLFGFrame:SetScale(self.frame:GetScale() * 0.75)

	Dominos.RegisterCallback(self, "DOMINOS_RESCALE")
end

function mod:DOMINOS_RESCALE()
	MiniMapInstanceDifficulty:SetScale(self.frame:GetScale() * 0.75)
	MiniMapLFGFrame:SetScale(self.frame:GetScale() * 0.75)
end

function mod:Unload()
	if self.frame then
		self.frame:Free()
	end
end

function class:New()
	local f = self.super.New(self, "minimap")
	if not f.value then
		f:SetFrameStrata("BACKGROUND")
		f:LoadButtons()
	end
	f:Layout()
	return f
end

function class:GetDefaults()
	return {scale = 1, point = "TOPRIGHT", y = 0, x = 0}
end

function class:NumButtons()
	return #menuButtons
end

function class:AddButton(i)
	local btn = menuButtons[i]
	if not btn then return end
	btn:SetParent(self.header)
	btn:Show()
	self.buttons[i] = btn
end

function class:RemoveButton(i)
	local btn = self.buttons[i]
	if not btn then return end
	btn:SetParent(nil)
	btn:Hide()
	self.buttons[i] = nil
end

local function AddLayoutPanel(menu)
	local p = menu:NewPanel(L.Layout)
	p:NewPaddingSlider()
	p:NewOpacitySlider()
	p:NewFadeSlider()
	p:NewScaleSlider()
end

local function AddShowState(self)
	local p = self:NewPanel(L.ShowStates)
	p.height = 56

	local editBox = CreateFrame("EditBox", p:GetName() .. "StateText", p, "InputBoxTemplate")
	editBox:SetWidth(148)
	editBox:SetHeight(20)
	editBox:SetPoint("TOPLEFT", 12, -10)
	editBox:SetAutoFocus(false)
	editBox:SetScript("OnShow", function(self)
		self:SetText(self:GetParent().owner:GetShowStates() or "")
	end)
	editBox:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		self:GetParent().owner:SetShowStates(text ~= "" and text or nil)
	end)
	editBox:SetScript("OnEditFocusLost", function(self) self:HighlightText(0, 0) end)
	editBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)

	local set = CreateFrame("Button", p:GetName() .. "Set", p, "UIPanelButtonTemplate")
	set:SetWidth(30)
	set:SetHeight(20)
	set:SetText(L.Set)
	set:SetScript("OnClick", function(self)
		local text = editBox:GetText()
		self:GetParent().owner:SetShowStates(text ~= "" and text or nil)
		editBox:SetText(self:GetParent().owner:GetShowStates() or "")
	end)
	set:SetPoint("BOTTOMRIGHT", -8, 2)

	return p
end

function class:CreateMenu()
	local menu = self.menu or Dominos:NewMenu(self.id)
	L = LibStub("AceLocale-3.0"):GetLocale("Dominos-Config")
	AddLayoutPanel(menu)
	AddShowState(menu)
	self.menu = menu
end