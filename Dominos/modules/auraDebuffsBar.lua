assert(Dominos, "Dominos not found!")
local Dominos = Dominos

local DebuffModule = Dominos:NewModule("Debuffs")
local DebuffsFrame = Dominos:CreateClass("Frame", Dominos.Frame)
local L

function DebuffModule:OnInitialize()
	if not Dominos:UseAuras() then
		self:Disable()
	end
end

function DebuffModule:Load()
	if not Dominos:UseAuras() then
		self:Unload()
		return
	end

	self.frame = DebuffsFrame:New()
end

function DebuffModule:Unload()
	if self.Frame then
		self.frame:Free()
	end
end

function DebuffsFrame:SkinButton(btn)
	return Dominos:Masque("Debuffs", btn)
end

function DebuffsFrame:New()
	local f = self.super.New(self, "debuffs")

	if not self.debuffs then
		f:CreateDebuffs()
		f:SetFrameStrata("LOW")
	end

	f:LoadButtons()
	f:Layout()

	return f
end

function DebuffsFrame:GetDefaults()
	return {scale = 1, point = "CENTER", numButtons = 36, y = 0, x = 0, isRightToLeft = true}
end

function DebuffsFrame:NumButtons()
	return self.sets.numButtons or 36
end

function DebuffsFrame:AddButton(i)
	local b = self.debuffs[i]
	if not b then
		return
	end
	b:SetParent(self.header)
	self:SkinButton(b)
	self.buttons[i] = b
end

function DebuffsFrame:RemoveButton(i)
	local b = self.buttons[i]
	b:SetParent(nil)
	b:Hide()
	self.buttons[i] = nil
end

function DebuffsFrame:CreateDebuffs()
	self.debuffs = self.debuffs or {}
	for i = 1, 36 do
		self.debuffs[i] = self.debuffs[i] or self:CreateDebuff(i)
	end
end

local lastUpdated = 0
local function OnUpdate(self, elapsed)
	lastUpdated = lastUpdated + elapsed
	if lastUpdated > 0.01 then
		lastUpdated = 0
		for i = 1, self:NumButtons() do
			self:UpdateDebuff(i, elapsed)
		end
	end
end

function DebuffsFrame:CreateDebuff(id)
	local frameName = "DominosDebuffsDebuff" .. id
	local debuff = CreateFrame("Button", frameName, UIParent, "BuffButtonTemplate, TargetDebuffFrameTemplate")
	debuff:SetSize(34, 34)
	debuff.icon = _G[frameName .. "Icon"]
	debuff.icon:SetTexCoord(.1, .9, .1, .9)
	debuff.cooldown = _G[frameName .. "Cooldown"]
	self:SetScript("OnUpdate", OnUpdate)
	return debuff
end

function DebuffsFrame:UpdateDebuff(id, elapsed)
	local debuff = self.debuffs[id]
	if not debuff then
		return
	end
	DebuffsFrame:AuraButtonUpdate(debuff:GetName(), id, "HARMFUL")
	debuff.id = id
end

local function AddSizeSlider(p)
	L = L or LibStub("AceLocale-3.0"):GetLocale("Dominos-Config")
	local size = p:NewSlider(L.Size, 1, 1, 1)
	size.OnShow = function(self)
		self:SetMinMaxValues(1, 36)
		self:SetValue(self:GetParent().owner:NumButtons())
	end
	size.UpdateValue = function(self, value)
		self:GetParent().owner:SetNumButtons(value)
		_G[self:GetParent():GetName() .. L.Columns]:OnShow()
	end
end

local function AddLayoutPanel(menu)
	L = L or LibStub("AceLocale-3.0"):GetLocale("Dominos-Config")
	local p = menu:NewPanel(L.Layout)
	p:NewOpacitySlider()
	p:NewFadeSlider()
	p:NewScaleSlider()
	p:NewPaddingSlider()
	p:NewSpacingSlider()
	p:NewColumnsSlider()
	AddSizeSlider(p)
end

local function AddAdvancedLayout(self)
	self:AddAdvancedPanel()
end

function DebuffsFrame:CreateMenu()
	local menu = self.menu or Dominos:NewMenu(self.id)
	AddLayoutPanel(menu)
	AddAdvancedLayout(menu)
	self.menu = menu
end

function DebuffsFrame:AuraButtonUpdate(buttonName, id, filter)
	local unit = "player"
	local name, rank, texture, count, debuffType, duration, expirationTime, _, _, shouldConsolidate =
		UnitAura(unit, id, filter)
	local debuffName = buttonName
	local debuff = _G[debuffName]

	if not name then
		-- if a debuff exists, we hide it.
		if debuff then
			debuff:Hide()
			debuff.duration:Hide()
		end
		return nil
	end

	-- create the debuff if it doesn't exist.
	if not debuff then
		debuff = CreateFrame("Button", debuffName, self.header, "BuffButtonTemplate")
		debuff.parent = self.header
	end

	-- setup debuff now
	debuff:SetID(id)
	debuff.unit = unit
	debuff.filter = filter
	debuff:SetAlpha(1.0)
	debuff.exitTime = nil
	debuff:Show()
	frameBorder = _G[debuffName .. "Border"]
	frameBorder:Hide()

	if duration > 0 and expirationTime then
		debuff.cooldown:Show()
		CooldownFrame_SetTimer(debuff.cooldown, expirationTime - duration, duration, 1)

		if SHOW_BUFF_DURATIONS == "1" then
			debuff.duration:Show()
		else
			debuff.duration:Hide()
		end

		if not debuff.timeLeft then
			debuff.timeLeft = expirationTime - GetTime()
			debuff:SetScript("OnUpdate", AuraButton_OnUpdate)
		else
			debuff.timeLeft = expirationTime - GetTime()
		end
		debuff.expirationTime = expirationTime
	else
		debuff.cooldown:Hide()
		debuff.duration:Hide()
		if debuff.timeLeft then
			debuff:SetScript("OnUpdate", nil)
		end
		debuff.timeLeft = nil
	end

	-- set debuff count
	debuff.count:SetText(count > 1 and count or "")

	local icon = _G[debuffName .. "Icon"]
	icon:SetTexture(texture)

	if GameTooltip:IsOwned(debuff) then
		GameTooltip_SetDefaultAnchor(GameTooltip, debuff)
		GameTooltip:SetUnitAura("player", id, filter)
	end
	return 1
end