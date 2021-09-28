assert(Dominos, "Dominos not found!")
local Dominos = Dominos

--libs and omgspeed
local _G = _G
local format = string.format

local BUTTON_SIZE = 30
local NT_SIZE = (66 / 36) * BUTTON_SIZE
local KeyBound = LibStub("LibKeyBound-1.0")

--[[ Class Button ]]
local ClassButton = Dominos:CreateClass("CheckButton", Dominos.BindableButton)

--[[ Constructor ]]
function ClassButton:New(id)
	return self:Restore(id) or self:Create(id)
end

function ClassButton:Create(id)
	local name = format("DominosClassButton%d", id)

	local b = self:Bind(CreateFrame("CheckButton", name, nil, "SecureActionButtonTemplate"))
	b:SetWidth(BUTTON_SIZE)
	b:SetHeight(BUTTON_SIZE)
	b:SetID(id)

	b.icon = b:CreateTexture(name .. "Icon", "BACKGROUND")
	b.icon:SetAllPoints(b)

	b:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")

	local nt = b:GetNormalTexture()
	nt:ClearAllPoints()
	nt:SetPoint("CENTER", 0, -1)
	nt:SetWidth(NT_SIZE)
	nt:SetHeight(NT_SIZE)
	_G[name .. "NormalTexture"] = nt

	b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	b:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")

	b.hotkey = b:CreateFontString(name .. "HotKey", "ARTWORK")
	b.hotkey:SetFontObject("NumberFontNormalSmallGray")
	b.hotkey:SetPoint("TOPRIGHT", 2, -2)
	b.hotkey:SetJustifyH("RIGHT")
	b.hotkey:SetWidth(BUTTON_SIZE)
	b.hotkey:SetHeight(10)

	b.cooldown = CreateFrame("Cooldown", name .. "Cooldown", b, "CooldownFrameTemplate")
	b.cooldown:SetAllPoints(b)

	b:SetAttribute("type", "spell")
	b:SetScript("PostClick", b.PostClick)
	b:SetScript("OnEvent", b.OnEvent)
	b:SetScript("OnEnter", b.OnEnter)
	b:SetScript("OnLeave", b.OnLeave)
	b:SetScript("OnShow", b.UpdateEvents)
	b:SetScript("OnHide", b.UpdateEvents)

	b:UpdateSpell()
	b:UpdateEvents()
	b:UpdateHotkey()
	b:Skin()

	return b
end

function ClassButton:Skin()
	if not Dominos:Masque("Class Bar", self) then
		self.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		self:GetNormalTexture():SetVertexColor(1, 1, 1, 0.5)
	end
end

function ClassButton:Restore(id)
	local unused = self.unused
	if unused then
		local b = unused[id]
		if b then
			unused[id] = nil
			b:Show()
			return b
		end
	end
end

function ClassButton:Free()
	local unused = ClassButton.unused or {}
	unused[self:GetID()] = self
	ClassButton.unused = unused

	self:SetParent(nil)
	self:Hide()
end

--[[ Frame Events ]]
function ClassButton:UpdateEvents()
	if self:IsShown() then
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
		self:RegisterEvent("SPELL_UPDATE_USABLE")
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UPDATE_BINDINGS")
	else
		self:UnregisterAllEvents()
	end
end

function ClassButton:OnEvent(event, arg1)
	if event == "UPDATE_BINDINGS" then
		self:UpdateHotkey()
	elseif event == "UPDATE_SHAPESHIFT_FORMS" and (self:GetID() > GetNumShapeshiftForms()) then
		self:Hide()
	elseif event == "UNIT_AURA" then
		if arg1 == "player" then
			self:Update()
		end
	else
		self:Update()
	end
end

function ClassButton:OnEnter()
	if Dominos:ShowTooltips() then
		if GetCVar("UberTooltips") == "1" then
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		end
		GameTooltip:SetShapeshift(self:GetID())
	end
	KeyBound:Set(self)
end

function ClassButton:OnLeave()
	GameTooltip:Hide()
end

function ClassButton:PostClick()
	self:SetChecked(not self:GetChecked())
end

--[[ Update Functions ]]
function ClassButton:Update()
	local texture, name, isActive, isCastable = GetShapeshiftFormInfo(self:GetID())
	self:SetChecked(isActive)

	--update icon
	local icon = self.icon
	icon:SetTexture(texture)
	if isCastable then
		icon:SetVertexColor(1, 1, 1)
	else
		icon:SetVertexColor(0.4, 0.4, 0.4)
	end

	--update cooldown
	if texture then
		local start, duration, enable = GetShapeshiftFormCooldown(self:GetID())
		CooldownFrame_SetTimer(self.cooldown, start, duration, enable)
	else
		self.cooldown:Hide()
	end
end

function ClassButton:UpdateSpell()
	self:SetAttribute("spell", select(2, GetShapeshiftFormInfo(self:GetID())))
	self:Update()
end

--[[ Class Bar ]]
local ClassBar = Dominos:CreateClass("Frame", Dominos.Frame)
Dominos.ClassBar = ClassBar

function ClassBar:New()
	local f = self.super.New(self, "class")
	f:SetScript("OnEvent", f.UpdateForms)
	f:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	f:UpdateForms()

	return f
end

function ClassBar:GetDefaults()
	return {point = "CENTER", spacing = 2}
end

function ClassBar:Free()
	self:UnregisterAllEvents()
	self.super.Free(self)
end

--[[ button stuff]]
function ClassBar:LoadButtons()
	self:UpdateForms()
end

function ClassBar:AddButton(i)
	local b = ClassButton:New(i)
	b:SetParent(self.header)
	self.buttons[i] = b

	return b
end

function ClassBar:RemoveButton(i)
	local b = self.buttons[i]
	self.buttons[i] = nil
	b:Free()
end

function ClassBar:UpdateForms()
	for i = 1, GetNumShapeshiftForms() do
		local b = self.buttons[i] or self:AddButton(i)
		b:UpdateSpell()
		b:Show()
	end
	self:SetNumButtons(GetNumShapeshiftForms() or 0)
end