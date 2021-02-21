assert(Dominos, "Dominos not found!")
local Dominos = Dominos

BuffFrame:Hide()

local BuffModule = Dominos:NewModule("Buffs")
local BuffFrame = Dominos:CreateClass("Frame", Dominos.Frame)
local LBF = LibStub("LibButtonFacade", true)
local L

function BuffModule:Load()
    self.frame = BuffFrame:New()
end

function BuffModule:Unload()
    self.frame:Free()
end

function BuffFrame:New()
    local f = self.super.New(self, "buffs")
    if not self.buffs then
        f:CreateBuffs()
        f:SetFrameStrata("LOW")
    end

    f:LoadButtons()
    f:Layout()
    return f
end

function BuffFrame:GetDefaults()
    return {scale = 1, point = "CENTER", numButtons = 32, y = 0, x = 0}
end

function BuffFrame:NumButtons()
    return self.sets.numButtons or 32
end

function BuffFrame:AddButton(i)
	local b = self.buffs[i]
	if not b then return end
	b:SetParent(self.header)
	self.buttons[i] = b
end

function BuffFrame:RemoveButton(i)
    local b = self.buttons[i]
    if not b then return end
    b:SetParent(nil)
    b:Hide()
    self.buttons[i] = nil
end

function BuffFrame:CreateBuffs()
    self.buffs = self.buffs or {}
    for i = 1, 32 do
        self.buffs[i] = self.buffs[i] or self:CreateBuff(i)
    end
end

function BuffFrame:CreateBuff(id)
    local frame, frameName
    local selfName = "DominosBuff"
    local frameName = selfName .. id
    local buff = CreateFrame("Button", frameName, UIParent, "BuffButtonTemplate, TargetBuffFrameTemplate")
    buff:SetSize(34, 34)
    buff.icon = _G[frameName .. "Icon"]
    buff.icon:SetTexCoord(.1, .9, .1, .9)
    buff:SetScript("OnClick", function() CancelUnitBuff("player", id, "HELPFUL") end)
    buff.cooldown = _G[frameName .. "Cooldown"]
    self:SetScript("OnUpdate", function(self, elapsed)
        for i = 1, self:NumButtons() do self:UpdateBuff(i) end
    end)
    return buff
end

function BuffFrame:UpdateBuff(id, elapsed)
	local buff = self.buffs[id]
	if not buff then return end
	BuffFrame:AuraButtonUpdate(buff:GetName(), id, "HELPFUL")
	buff.id = id
end

local function AddSizeSlider(p)
    L = L or LibStub("AceLocale-3.0"):GetLocale("Dominos-Config")
    local size = p:NewSlider(L.Size, 1, 1, 1)
    size.OnShow = function(self)
        self:SetMinMaxValues(1, 32)
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

function BuffFrame:CreateMenu()
    local menu = Dominos:NewMenu(self.id)
    AddLayoutPanel(menu)
    AddAdvancedLayout(menu)
    self.menu = menu
end

function BuffFrame:AuraButtonUpdate(buttonName, index, filter)
	if ConsolidatedBuffs:IsShown() then
		ConsolidatedBuffs:Hide()
	end

    local unit = "player"
    local name, rank, texture, count, debuffType, duration, expirationTime = UnitAura(unit, index, filter)
    local buffName = buttonName
    local buff = _G[buffName]

    if not name then
        -- hide the buff button if it exists
        if buff then
            buff:Hide()
            buff.duration:Hide()
        end
        return nil
    end

    -- Setup Buff
    buff:SetID(index)
    buff.unit = unit
    buff.filter = filter
    buff:SetAlpha(1.0)
    buff.exitTime = nil
    buff:Show()

    if duration > 0 and expirationTime then
        buff.cooldown:Show()
        CooldownFrame_SetTimer(buff.cooldown, expirationTime - duration, duration, 1)

        if SHOW_BUFF_DURATIONS == "1" then
            buff.duration:Show()
        else
            buff.duration:Hide()
        end

        if not buff.timeLeft then
            buff.timeLeft = expirationTime - GetTime()
            buff:SetScript("OnUpdate", AuraButton_OnUpdate)
        else
            buff.timeLeft = expirationTime - GetTime()
        end
        buff.expirationTime = expirationTime
    else
        buff.cooldown:Hide()
        buff.duration:Hide()
        if buff.timeLeft then
            buff:SetScript("OnUpdate", nil)
        end
        buff.timeLeft = nil
    end

    -- set the buff count
    buff.count:SetText(count > 1 and count or "")
    buff.icon:SetTexture(texture)

    if GameTooltip:IsOwned(buff) then
        GameTooltip_SetDefaultAnchor(GameTooltip, buff)
        GameTooltip:SetUnitAura("player", index, filter)
    end
    return 1
end