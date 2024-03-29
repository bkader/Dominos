assert(Dominos, "Dominos not found!")
local Dominos = Dominos

local _G = _G
local format = string.format

local KeyBound = LibStub("LibKeyBound-1.0")
local unused, hooked

--[[ Pet Button ]]
local PetButton = Dominos:CreateClass("CheckButton", Dominos.BindableButton)

local function Dominos_RestoreSaturation(self, icon)
	if icon and icon:IsDesaturated() then
		icon:SetDesaturated(false)
	end
end

local function Dominos_PetActionBar_UpdateCooldowns(self)
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		local icon = _G["PetActionButton" .. i .. "Icon"]
		if icon then
			local start, duration = GetPetActionCooldown(i)
			if duration and duration >= 2.01 then
				local nextTime = math.ceil(start + duration - GetTime())
				Dominos:Delay(math.min(duration, nextTime), Dominos_RestoreSaturation, self, icon)

				if not icon:IsDesaturated() then
					icon:SetDesaturated(true)
				end
			else
				Dominos_RestoreSaturation(self)
			end
		end
	end
end

function PetButton:New(id)
	local b = self:Restore(id) or self:Create(id)
	b:UpdateHotkey()

	if not hooked then
		hooksecurefunc("PetActionBar_UpdateCooldowns", Dominos_PetActionBar_UpdateCooldowns)
		hooked = true
	end

	return b
end

function PetButton:Create(id)
	local b = self:Bind(_G["PetActionButton" .. id])
	b.buttonType = "BONUSACTIONBUTTON"
	b:SetScript("OnEnter", self.OnEnter)
	b:Skin()

	return b
end

--if we have button facade support, then skin the button that way
--otherwise, apply the dominos style to the button to make it pretty
function PetButton:Skin()
	if not Dominos:Masque("Pet Bar", self) then
		_G[self:GetName() .. "Icon"]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		self:GetNormalTexture():SetVertexColor(1, 1, 1, 0.5)
	end
end

function PetButton:Restore(id)
	local b = unused and unused[id]
	if b then
		unused[id] = nil
		b:Show()

		return b
	end
end

--saving them thar memories
function PetButton:Free()
	if not unused then
		unused = {}
	end
	unused[self:GetID()] = self

	self:SetParent(nil)
	self:Hide()
end

--keybound support
function PetButton:OnEnter()
	if Dominos:ShowTooltips() then
		PetActionButton_OnEnter(self)
	end
	KeyBound:Set(self)
end

--override keybinding display
hooksecurefunc("PetActionButton_SetHotkeys", PetButton.UpdateHotkey)

--[[ Pet Bar ]]
local PetBar = Dominos:CreateClass("Frame", Dominos.Frame)
Dominos.PetBar = PetBar

function PetBar:New()
	local f = self.super.New(self, "pet")
	f:LoadButtons()
	f:Layout()

	return f
end

function PetBar:GetShowStates()
	return "[target=pet,exists,nobonusbar:5]show;hide"
end

function PetBar:GetDefaults()
	return {point = "CENTER", x = 0, y = -32, spacing = 6}
end

--dominos frame method overrides
function PetBar:NumButtons()
	return NUM_PET_ACTION_SLOTS
end

function PetBar:AddButton(i)
	local b = PetButton:New(i)
	b:SetParent(self.header)
	self.buttons[i] = b
end

function PetBar:RemoveButton(i)
	local b = self.buttons[i]
	self.buttons[i] = nil
	b:Free()
end

--[[ keybound  support ]]
function PetBar:KEYBOUND_ENABLED()
	self.header:SetAttribute("state-visibility", "display")

	for _, button in pairs(self.buttons) do
		button:Show()
	end
end

function PetBar:KEYBOUND_DISABLED()
	self:UpdateShowStates()

	local petBarShown = PetHasActionBar()
	for _, button in pairs(self.buttons) do
		if petBarShown and GetPetActionInfo(button:GetID()) then
			button:Show()
		else
			button:Hide()
		end
	end
end