assert(Dominos, "Dominos not found!")
local Dominos = Dominos

local zoneText = CreateFrame("Frame", "ZoneText", UIParent)
MinimapZoneTextButton:SetParent(zoneText)

local menuButtons = {}
do
    local loadButtons = function(...)
        for i = 1, select("#", ...) do
            local btn = select(i, ...)
            if btn and btn.GetName then
                tinsert(menuButtons, btn)
            end
        end
    end
    loadButtons(zoneText:GetChildren())
end

local mod = Dominos:NewModule("Zone-Text")
local class = Dominos:CreateClass("Frame", Dominos.Frame)

function mod:Load()
	if not Dominos:UseMinimap() then
		if self.frame then self:Unload() end
		MinimapZoneTextButton:SetParent(MinimapCluster)
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
    local f = self.super.New(self, "Zone-Text")
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
    if not btn then
        return
    end
    btn:SetParent(self.header)
    btn:Show()
    self.buttons[i] = btn
end

function class:RemoveButton(i)
    local btn = self.buttons[i]
    if not btn then
        return
    end
    btn:SetParent(nil)
    btn:Hide()
    self.buttons[i] = nil
end

local function AddLayoutPanel(menu)
    local p = menu:NewPanel(LibStub("AceLocale-3.0"):GetLocale("Dominos-Config").Layout)
    p:NewPaddingSlider()
    p:NewOpacitySlider()
    p:NewFadeSlider()
    p:NewScaleSlider()
end

local function AddShowState(self)
    local L = LibStub("AceLocale-3.0"):GetLocale("Dominos-Config")
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
    local menu = Dominos:NewMenu(self.id)
    AddLayoutPanel(menu)
    AddShowState(menu)
    self.menu = menu
end