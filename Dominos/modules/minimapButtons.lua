assert(Dominos, "Dominos not found!")
local Dominos = Dominos
local L = LibStub("AceLocale-3.0"):GetLocale("Dominos-Config", true)

local select, tinsert, ipairs = select, table.insert, ipairs

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

local minimapButtons = CreateFrame("Frame", "MinimapButtons", MinimapButtonsBar)

-- move the buttons we need to that bar.
local buttonsToMove = {
	"GameTimeFrame",
	"MiniMapTracking",
	"MiniMapWorldMapButton",
	"MiniMapMailFrame",
	"MinimapZoomIn",
	"MinimapZoomOut",
	-- "DominosMinimapButton",
}
for _, name in ipairs(buttonsToMove) do
	local btn = _G[name]
	if btn then
		btn:SetParent(minimapButtons)
		btn:SetSize(34, 34)
	end
end

local menuButtons
do
    local loadButtons = function(...)
    	menuButtons = {}
        for i = 1, select("#", ...) do
            local btn = select(i, ...)
            tinsert(menuButtons, btn)
        end
    end
    loadButtons(minimapButtons:GetChildren())
end

local mod = Dominos:NewModule("buttons")
local class = Dominos:CreateClass("Frame", Dominos.Frame)

function mod:Load()
    self.frame = class:New()
    self.frame:SetFrameStrata("LOW")
end

function mod:Unload()
    self.frame:Free()
end

function class:New()
    local f = self.super.New(self, "Buttons")
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