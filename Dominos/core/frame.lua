--[[
frame.lua
	A dominos frame, a generic container object
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
assert(Dominos, "Dominos not found!")
local Dominos = Dominos
local FlyPaper = _G.FlyPaper

local Frame = Dominos:CreateClass("Frame")
Dominos.Frame = Frame

local FadeManager = Dominos.FadeManager
local active = {}
local unused = {}

--constructor
function Frame:New(id, tooltipText)
	id = tonumber(id) or id
	local f = self:Restore(id) or self:Create(id)
	f:LoadSettings()
	f.buttons = {}
	f:SetTooltipText(tooltipText)

	active[id] = f
	return f
end

function Frame:Create(id)
	local f = self:Bind(CreateFrame("Frame", nil, UIParent))
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f.id = id

	f.header = CreateFrame("Frame", nil, f, "SecureHandlerStateTemplate")
	f.header:SetAttribute("_onstate-display", [[
		local newstate = newstate or 'show'
		if newstate == 'hide' then
			self:SetAttribute('frame-alpha', nil)
			self:Hide()
		else
			local stateAlpha = tonumber(newstate)
			if stateAlpha then
				self:SetAttribute('frame-alpha', stateAlpha/100)
			else
				self:SetAttribute('frame-alpha', nil)
			end
			self:Show()
		end
	]])
	f.header:SetAllPoints(f)

	f.drag = Dominos.DragFrame:New(f)

	return f
end

function Frame:Restore(id)
	local f = unused[id]
	if f then
		unused[id] = nil
		return f
	end
end

--destructor
function Frame:Free()
	active[self.id] = nil

	UnregisterStateDriver(self.header, "display", "show")
	FadeManager:Remove(self)

	if self.buttons then
		for i in pairs(self.buttons) do
			self:RemoveButton(i)
		end
	end
	self.buttons = nil
	self.docked = nil

	self:ClearAllPoints()
	self:SetUserPlaced(nil)
	self.drag:Hide()
	self:Hide()

	unused[self.id] = self
	Dominos.callbacks:Fire("DOMINOS_FREE", self)
end

function Frame:Delete()
	self:Free()
	Dominos:SetFrameSets(self.id, nil)
end

function Frame:LoadSettings(defaults)
	self.sets = Dominos:GetFrameSets(self.id) or Dominos:SetFrameSets(self.id, self:GetDefaults()) --get defaults must be provided by anything implementing the Frame type
	self:Reposition()

	if self.sets.hidden then
		self:HideFrame()
	else
		self:ShowFrame()
	end

	if Dominos:Locked() then
		self:Lock()
	else
		self:Unlock()
	end

	self:UpdateShowStates()
	self:UpdateAlpha()
	self:UpdateFader()
end

--[[ Layout ]]--
--this function is used in a lot of places, but never called in Frame
function Frame:LoadButtons()
	for i = 1, self:NumButtons() do
		self:AddButton(i)
	end
end

function Frame:AddButton(i)
	--placeholder
end

function Frame:RemoveButton(i)
	local b = self.buttons and self.buttons[i]
	if b and b.Free then
		b:Free()
		self.buttons[i] = nil
	end
end

function Frame:UpdateButtonCount(numButtons)
	for i = numButtons + 1, #self.buttons do
		self:RemoveButton(i)
	end

	for i = #self.buttons + 1, numButtons do
		self:AddButton(i)
	end
end

function Frame:SetNumButtons(numButtons)
	self.sets.numButtons = numButtons
	self:UpdateButtonCount(self:NumButtons())
	self:Layout()
	Dominos.callbacks:Fire("DOMINOS_SETNUMBUTTONS", self, self.sets.numButtons)
end

function Frame:NumButtons()
	return self.sets.numButtons or 0
end

function Frame:SetColumns(columns)
	self.sets.columns = columns ~= self:NumButtons() and columns or nil
	self:Layout()
	Dominos.callbacks:Fire("DOMINOS_SETCOLUMNS", self, self.sets.columns)
end

function Frame:NumColumns()
	return self.sets.columns or self:NumButtons()
end

function Frame:SetSpacing(hspacing, vspacing)
	if hspacing and not vspacing then
		self.sets.spacing = hspacing
		self.sets.hspacing = hspacing
		self.sets.vspacing = vspacing
	else
		self.sets.hspacing = hspacing or self.sets.hspacing or self.sets.spacing
		self.sets.vspacing = vspacing or self.sets.vspacing or self.sets.spacing
	end

	self:Layout()
	Dominos.callbacks:Fire("DOMINOS_SETSPACING", self, hspacing, vspacing)
end

function Frame:GetSpacing()
	return self.sets.hspacing or self.sets.spacing or 0, self.sets.vspacing or self.sets.spacing or 0
end

function Frame:SetPadding(padW, padH)
	self.sets.padW = padW
	self.sets.padH = padH or padW
	self:Layout()
	Dominos.callbacks:Fire("DOMINOS_SETPADDING", self, self.sets.padW, self.sets.padH)
end

function Frame:GetPadding()
	return self.sets.padW or 0, self.sets.padH or self.sets.padW or 0
end

--the wackiness here is for backward compaitbility reasons, since I did not implement true defaults
function Frame:SetLeftToRight(isLeftToRight)
	local isRightToLeft = not isLeftToRight

	self.sets.isRightToLeft = isRightToLeft and true or nil
	self:Layout()
end

function Frame:GetLeftToRight()
	return not self.sets.isRightToLeft
end

function Frame:SetTopToBottom(isTopToBottom)
	local isBottomToTop = not isTopToBottom

	self.sets.isBottomToTop = isBottomToTop and true or nil
	self:Layout()
end

function Frame:GetTopToBottom()
	return not self.sets.isBottomToTop
end

function Frame:Layout()
	local width, height
	if #self.buttons > 0 then
		local cols = min(self:NumColumns(), #self.buttons)
		local rows = ceil(#self.buttons / cols)
		local padW, padH = self:GetPadding()
		local hspacing, vspacing = self:GetSpacing()
		local isLeftToRight = self:GetLeftToRight()
		local isTopToBottom = self:GetTopToBottom()

		local b = self.buttons[1]
		local w = b:GetWidth() + hspacing
		local h = b:GetHeight() + vspacing

		for i, btn in pairs(self.buttons) do
			local col
			local row
			if isLeftToRight then
				col = (i - 1) % cols
			else
				col = (cols - 1) - (i - 1) % cols
			end

			if isTopToBottom then
				row = ceil(i / cols) - 1
			else
				row = rows - ceil(i / cols)
			end

			btn:ClearAllPoints()
			btn:SetPoint("TOPLEFT", w * col + padW, -(h * row + padH))
		end

		width = w * cols - hspacing + padW * 2
		height = h * ceil(#self.buttons / cols) - vspacing + padH * 2
	else
		width = 30
		height = 30
	end

	self:SetWidth(max(width, 8))
	self:SetHeight(max(height, 8))
end

--[[ Scaling ]]--
function Frame:GetScaledCoords(scale)
	local ratio = self:GetScale() / scale
	return (self:GetLeft() or 0) * ratio, (self:GetTop() or 0) * ratio
end

function Frame:SetFrameScale(scale, scaleAnchored)
	local x, y = self:GetScaledCoords(scale)

	self.sets.scale = scale
	self:Rescale()

	if not self.sets.anchor then
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", x, y)
		self:SavePosition()
	end

	if scaleAnchored then
		for _, f in self:GetAll() do
			if f:GetAnchor() == self then
				f:SetFrameScale(scale, true)
			end
		end
	end
end

function Frame:Rescale()
	self:SetScale(self:GetScale())
	self.drag:SetScale(self:GetScale())
	Dominos.callbacks:Fire("DOMINOS_RESCALE", self)
end

function Frame:GetScale()
	return self.sets.scale or 1
end

--[[ Opacity ]]--
function Frame:SetFrameAlpha(alpha)
	if alpha == 1 then
		self.sets.alpha = nil
	else
		self.sets.alpha = alpha
	end
	self:UpdateAlpha()
end

function Frame:GetFrameAlpha()
	return self.sets.alpha or 1
end

--faded opacity (mouse not over the f)
function Frame:SetFadeMultiplier(alpha)
	alpha = alpha or 1
	if alpha == 1 then
		self.sets.fadeAlpha = nil
	else
		self.sets.fadeAlpha = alpha
	end
	self:UpdateAlpha()
	self:UpdateFader()
end

function Frame:GetFadeMultiplier()
	return self.sets.fadeAlpha or 1
end

--returns fadedOpacity, fadePercentage
--fadedOpacity is what opacity the f will be at when faded
--fadedPercentage is what modifier we use on normal opacity
function Frame:UpdateAlpha()
	self:SetAlpha(self:GetExpectedAlpha())
	Dominos.callbacks:Fire("DOMINOS_SETALPHA", self)
end

function Frame:GetExpectedAlpha()
	if Dominos:IsLinkedOpacityEnabled() then
		local anchor = (self:GetAnchor())
		if anchor then
			return anchor:GetExpectedAlpha()
		end
	end

	local stateAlpha = self.header:GetAttribute("frame-alpha")
	if stateAlpha then
		return stateAlpha
	end

	local alpha = self:GetFrameAlpha()
	local fadeMultiplier = self:GetFadeMultiplier()
	if fadeMultiplier >= 1 or self:IsFocus() then
		return alpha
	end
	return alpha * fadeMultiplier
end

local function isChildFocus(...)
	local focus = GetMouseFocus()
	for i = 1, select("#", ...) do
		if focus == select(i, ...) then
			return true
		end
	end
	for i = 1, select("#", ...) do
		local f = select(i, ...)
		if f:IsShown() and isChildFocus(f:GetChildren()) then
			return true
		end
	end
	return false
end

--returns all frames docked to the given frame
if Frame.IsMouseOver then
	function Frame:IsFocus()
		if self:IsMouseOver(1, -1, -1, 1) then
			return (GetMouseFocus() == _G["WorldFrame"]) or isChildFocus(self:GetChildren())
		end
		return Dominos:IsLinkedOpacityEnabled() and self:IsDockedFocus()
	end
else
	function Frame:IsFocus()
		if MouseIsOver(self, 1, -1, -1, 1) then
			return (GetMouseFocus() == _G["WorldFrame"]) or isChildFocus(self:GetChildren())
		end
		return Dominos:IsLinkedOpacityEnabled() and self:IsDockedFocus()
	end
end

function Frame:IsDockedFocus()
	local docked = self.docked
	if docked then
		for _, f in pairs(docked) do
			if f:IsFocus() then
				return true
			end
		end
	end
	return false
end

--[[ Visibility ]]--
function Frame:ShowFrame()
	self.sets.hidden = nil
	self:Show()
	self:UpdateFader()
	self.drag:UpdateColor()
	Dominos.callbacks:Fire("DOMINOS_SHOW", self)
end

function Frame:HideFrame()
	self.sets.hidden = true
	self:Hide()
	self:UpdateFader()
	self.drag:UpdateColor()
	Dominos.callbacks:Fire("DOMINOS_HIDE", self)
end

function Frame:ToggleFrame()
	if self:FrameIsShown() then
		self:HideFrame()
	else
		self:ShowFrame()
	end
end

function Frame:FrameIsShown()
	return not self.sets.hidden
end

--[[ Show states ]]--
function Frame:SetShowStates(states)
	self.sets.showstates = states
	self:UpdateShowStates()
end

function Frame:GetShowStates()
	local states = self.sets.showstates

	--hack to convert [combat] into [combat]show;hide in case a user is using the old style of showstates
	if states then
		if states:sub(#states) == "]" then
			states = states .. "show;hide"
			self.sets.showstates = states
		end
	end

	return states
end

function Frame:UpdateShowStates()
	local showstates = self:GetShowStates()
	if showstates then
		RegisterStateDriver(self.header, "display", showstates)
		self.header:SetAttribute("state-display", SecureCmdOptionParse(showstates))
	else
		UnregisterStateDriver(self.header, "display")
		self.header:Show()
	end
end

--[[ Lock/Unlock ]]--
function Frame:Lock()
	self.drag:Hide()
	Dominos.callbacks:Fire("DOMINOS_LOCK", self)
end

function Frame:Unlock()
	self.drag:Show()
	Dominos.callbacks:Fire("DOMINOS_UNLOCK", self)
end

--[[ Sticky Bars ]]--
Frame.stickyTolerance = 16

function Frame:StickToEdge()
	local point, x, y = self:GetRelPosition()
	local s = self:GetScale()
	local w = self:GetParent():GetWidth() / s
	local h = self:GetParent():GetHeight() / s
	local rTolerance = self.stickyTolerance / s
	local changed = false

	--sticky edges
	if abs(x) <= rTolerance then
		x = 0
		changed = true
	end

	if abs(y) <= rTolerance then
		y = 0
		changed = true
	end

	-- auto centering
	local cX, cY = self:GetCenter()
	if y == 0 then
		if abs(cX - w / 2) <= rTolerance * 2 then
			if point == "TOPLEFT" or point == "TOPRIGHT" then
				point = "TOP"
			else
				point = "BOTTOM"
			end

			x = 0
			changed = true
		end
	elseif x == 0 then
		if abs(cY - h / 2) <= rTolerance * 2 then
			if point == "TOPLEFT" or point == "BOTTOMLEFT" then
				point = "LEFT"
			else
				point = "RIGHT"
			end

			y = 0
			changed = true
		end
	end

	--save this junk if we've done something
	if changed then
		self.sets.point = point
		self.sets.x = x
		self.sets.y = y

		self:ClearAllPoints()
		self:SetPoint(point, x, y)
	end
end

function Frame:ClearAnchor()
	local anchor, point = self:GetAnchor()
	if anchor and anchor.docked then
		for i, f in pairs(anchor.docked) do
			if f == self then
				tremove(anchor.docked, i)
				break
			end
		end
		if not next(anchor.docked) then
			anchor.docked = nil
		end
	end

	self.sets.anchor = nil
	self:UpdateFader()
	Dominos.callbacks:Fire("DOMINOS_CLEARANCHOR", self, anchor, point)
end

function Frame:SetAnchor(anchor, point)
	self:ClearAnchor()

	if anchor.docked then
		local found = false
		for i, f in pairs(anchor.docked) do
			if f == self then
				found = i
				break
			end
		end
		if not found then
			tinsert(anchor.docked, self)
		end
	else
		anchor.docked = {self}
	end

	self.sets.anchor = anchor.id .. point
	self:UpdateFader()
	Dominos.callbacks:Fire("DOMINOS_SETANCHOR", self, anchor, point)
end

function Frame:Stick()
	self:ClearAnchor()

	--only do sticky code if the alt key is not currently down
	if Dominos:Sticky() and not IsAltKeyDown() then
		--try to stick to a bar, then try to stick to a screen edge
		for _, f in self:GetAll() do
			if f ~= self then
				local point = FlyPaper.Stick(self, f, self.stickyTolerance)
				if point then
					self:SetAnchor(f, point)
					break
				end
			end
		end

		if not self.sets.anchor then
			self:StickToEdge()
		end
	end

	self:SavePosition()
	self.drag:UpdateColor()
	Dominos.callbacks:Fire("DOMINOS_STICK", self)
end

function Frame:Reanchor()
	local f, point = self:GetAnchor()
	if not (f and FlyPaper.StickToPoint(self, f, point)) then
		self:ClearAnchor()
		if not self:Reposition() then
			self:ClearAllPoints()
			self:SetPoint("CENTER")
		end
	else
		self:SetAnchor(f, point)
	end
	self.drag:UpdateColor()
	Dominos.callbacks:Fire("DOMINOS_REANCHOR", self, point)
end

function Frame:GetAnchor()
	local anchorString = self.sets.anchor
	if anchorString then
		local pointStart = #anchorString - 1
		return self:Get(anchorString:sub(1, pointStart - 1)), anchorString:sub(pointStart)
	end
end

--[[ Positioning ]]--
function Frame:GetRelPosition()
	local parent = self:GetParent()
	local w, h = parent:GetWidth(), parent:GetHeight()
	local x, y = self:GetCenter()
	local s = self:GetScale()
	w = w / s
	h = h / s

	local dx, dy
	local hHalf = (x > w / 2) and "RIGHT" or "LEFT"
	if hHalf == "RIGHT" then
		dx = self:GetRight() - w
	else
		dx = self:GetLeft()
	end

	local vHalf = (y > h / 2) and "TOP" or "BOTTOM"
	if vHalf == "TOP" then
		dy = self:GetTop() - h
	else
		dy = self:GetBottom()
	end

	return vHalf .. hHalf, dx, dy
end

function Frame:SavePosition()
	local point, x, y = self:GetRelPosition()
	local sets = self.sets

	sets.point = point
	sets.x = x
	sets.y = y

	Dominos.callbacks:Fire("DOMINOS_SAVEPOSITION", self, point, x, y)
end

--place the frame at it's saved position
function Frame:Reposition()
	self:Rescale()

	local sets = self.sets
	local point, x, y = sets.point, sets.x, sets.y

	if point then
		self:ClearAllPoints()
		self:SetPoint(point, x, y)
		self:SetUserPlaced(true)
		Dominos.callbacks:Fire("DOMINOS_REPOSITION", self, point, x, y)
		return true
	end
end

function Frame:SetFramePoint(...)
	self:ClearAllPoints()
	self:SetPoint(...)
	self:SavePosition()
	Dominos.callbacks:Fire("DOMINOS_SETPOINT", self)
end

--[[ Menus ]]--
function Frame:CreateMenu()
	self.menu = self.menu or Dominos:NewMenu(self.id)
	self.menu:AddLayoutPanel()
	self.menu:AddAdvancedPanel()
end

function Frame:ShowMenu()
	local enabled = select(4, GetAddOnInfo("Dominos_Config"))
	if enabled then
		if not self.menu then
			self:CreateMenu()
		end

		local menu = self.menu
		if menu then
			menu:Hide()
			menu:SetOwner(self)
			menu:ShowPanel(LibStub("AceLocale-3.0"):GetLocale("Dominos-Config").Layout)
			menu:Show()
		end
	end
end

--[[ Tooltip Text ]]--
function Frame:SetTooltipText(text)
	self.tooltipText = text
end

function Frame:GetTooltipText()
	return self.tooltipText
end

--[[ Utility ]]--
--run the fade onupdate checker if only if there are mouseover fs to check
function Frame:UpdateFader()
	if self.sets.hidden then
		FadeManager:Remove(self)
	else
		FadeManager:Add(self)
	end
end

--[[ Metafunctions ]]--
function Frame:Get(id)
	return active[tonumber(id) or id]
end

function Frame:GetAll()
	return pairs(active)
end

function Frame:ForAll(method, ...)
	for _, f in self:GetAll() do
		local action = f[method]
		if action then
			action(f, ...)
		end
	end
end

--takes a fID, and performs the specified action on that f
--this adds two special IDs, 'all' for all fs and number-number for a range of IDs
function Frame:ForFrame(id, method, ...)
	if id == "all" then
		self:ForAll(method, ...)
	else
		local startID, endID = tostring(id):match("(%d+)-(%d+)")
		startID = tonumber(startID)
		endID = tonumber(endID)

		if startID and endID then
			if startID > endID then
				local t = startID
				startID = endID
				endID = t
			end

			for i = startID, endID do
				local f = self:Get(i)
				if f then
					local action = f[method]
					if action then
						action(f, ...)
					end
				end
			end
		else
			local f = self:Get(id)
			if f then
				local action = f[method]
				if action then
					action(f, ...)
				end
			end
		end
	end
end