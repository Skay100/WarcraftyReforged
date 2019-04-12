local function Warcrafty_CreatePanel(parent,name,hidetext)
	local panel = CreateFrame('Frame', parent:GetName() .. name, parent, 'WarcraftyOptionFrameBoxTemplate')
	panel:SetBackdropBorderColor(0.4, 0.4, 0.4)
	panel:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
	if hidetext then else _G[panel:GetName() .. 'Title']:SetText(name) end

	return panel
end

local function Warcrafty_CreateSlider (text, parent, low, high, step)
	local name = parent:GetName() .. text
	local slider = CreateFrame('Slider', name, parent, 'OptionsSliderTemplate')
	slider:SetWidth(160)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	_G[name .. 'Text']:SetText(text)
	_G[name .. 'Low']:SetText('')
	_G[name .. 'High']:SetText('')
	
	local text = slider:CreateFontString(nil, 'BACKGROUND')
	text:SetFontObject('GameFontHighlightSmall')
	text:SetPoint('TOP', slider, 'BOTTOM', 0, 0)
	slider.valText = text

	return slider
end

local function Warcrafty_CreateEditBox(name,parent,width,height)
	local editbox = CreateFrame("EditBox",parent:GetName()..name,parent,"InputBoxTemplate")
	editbox:SetHeight(height)
	editbox:SetWidth(width)
	editbox:SetAutoFocus(false)
	return editbox
end

local function Warcrafty_CreateCheckButton(name, parent)
	local checkbutton = CreateFrame('CheckButton', parent:GetName() .. name, parent, 'OptionsCheckButtonTemplate')
	_G[checkbutton:GetName() .. 'Text']:SetText(name)

	return checkbutton
end

local function Warcrafty_CreateSpacer(parent,width)
	local spacer = parent:CreateTexture(nil,"ARTWORK")
	spacer:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-Spacer")
	spacer:SetHeight(16)
	spacer:SetWidth(width)
	return spacer
end

local function Warcrafty_CreateTab(parent,name,text)
	local tab = CreateFrame("Button",parent:GetName()..name,parent,"OptionsFrameTabButtonTemplate")
	tab:SetText(text)
	PanelTemplates_TabResize(tab,0)
	local spacer = Warcrafty_CreateSpacer(tab,(tab:GetWidth()-20))
	spacer:SetPoint("BOTTOM",tab,"BOTTOM",0,-6)
	tab.spacer = spacer
	return tab
end

local function Warcrafty_CreateTab1Page(frame)
	frame:SetWidth(400)
	frame:SetHeight(400)
	frame:SetPoint("TOPLEFT",WarcraftyOptionsTab1,"BOTTOMLEFT",-3,0)
	
	local checkbutton1 = Warcrafty_CreateCheckButton("Relocate Default MiniMap on Startup", frame)
	checkbutton1:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-10)
	checkbutton1:SetScript('OnShow', function(self) self:SetChecked(WarcraftyConfig.minimap) end)
	checkbutton1:SetScript('OnClick', function(self) 
		if (self:GetChecked() == nil) then
			WarcraftyConfig.minimap = false
		else
			WarcraftyConfig.minimap = true
		end
		WarcraftySetMinimap()
	end)
	
	local checkbutton2 = Warcrafty_CreateCheckButton("Relocate Default ActionBars on Startup", frame)
	checkbutton2:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-40)
	checkbutton2:SetScript('OnShow', function(self) self:SetChecked(WarcraftyConfig.actionbar) end)
	checkbutton2:SetScript('OnClick', function(self) 
		if (self:GetChecked() == nil) then
			WarcraftyConfig.actionbar = false
		else
			WarcraftyConfig.actionbar = true
		end
		WarcraftySetBars()
	end)
	
	local checkbutton3 = Warcrafty_CreateCheckButton("Enable Warcrafty CastBars", frame)
	checkbutton3:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-70)
	checkbutton3:SetScript('OnShow', function(self) self:SetChecked(WarcraftyConfig.castbar) end)
	checkbutton3:SetScript('OnClick', function(self) 
		if (self:GetChecked() == nil) then
			WarcraftyConfig.castbar = false
		else
			WarcraftyConfig.castbar = true
		end
	end)
	
	local slider1 = Warcrafty_CreateSlider ("Scale", frame, .5, 1.5, .01)
	slider1:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-120)
	slider1:SetScript('OnShow', function(self)
		self:SetValue(WarcraftyConfig.scale)
	end)
	slider1:SetScript('OnValueChanged', function(self, value)
		self.valText:SetText(round(value,2))
		WarcraftyConfig.scale=round(value,2)
		WarcraftySetScale()
		WarcraftyAuraUpdate("player")
		WarcraftyAuraUpdate("target")
	end)
	
	local panel1 = Warcrafty_CreatePanel(frame,"Health/Mana Text Settings:",false)
	panel1:SetWidth(375)
	panel1:SetHeight(80)
	panel1:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-170)
	
	local checkbutton4 = Warcrafty_CreateCheckButton("Current / Max",frame)
	checkbutton4:SetPoint("TOPLEFT",frame,"TOPLEFT",25,-180)
	local checkbutton5 = Warcrafty_CreateCheckButton("Current",frame)
	checkbutton5:SetPoint("TOPLEFT",frame,"TOPLEFT",150,-180)
	local checkbutton6 = Warcrafty_CreateCheckButton("None",frame)
	checkbutton6:SetPoint("TOPLEFT",frame,"TOPLEFT",275,-180)
	
	checkbutton4:SetScript('OnShow', function(self)
		if (WarcraftyConfig.textstyle == 1) then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton4:SetScript('OnClick', function(self) 
		if (WarcraftyConfig.textstyle == 2) then
			checkbutton5:SetChecked(false)
		elseif (WarcraftyConfig.textstyle == 3) then
			checkbutton6:SetChecked(false)
		end
		self:SetChecked(true)
		WarcraftyConfig.textstyle = 1
	end)
	checkbutton5:SetScript('OnShow', function(self)
		if (WarcraftyConfig.textstyle == 2) then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton5:SetScript('OnClick', function(self) 
		if (WarcraftyConfig.textstyle == 1) then
			checkbutton4:SetChecked(false)
		elseif (WarcraftyConfig.textstyle == 3) then
			checkbutton6:SetChecked(false)
		end
		self:SetChecked(true)
		WarcraftyConfig.textstyle = 2
	end)
	checkbutton6:SetScript('OnShow', function(self)
		if (WarcraftyConfig.textstyle == 3) then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton6:SetScript('OnClick', function(self) 
		if (WarcraftyConfig.textstyle == 1) then
			checkbutton4:SetChecked(false)
		elseif (WarcraftyConfig.textstyle == 2) then
			checkbutton5:SetChecked(false)
		end
		self:SetChecked(true)
		WarcraftyConfig.textstyle = 3
	end)
	
	local checkbutton7 = Warcrafty_CreateCheckButton("Append % to End of Text", frame)
	checkbutton7:SetPoint("TOPLEFT",frame,"TOPLEFT",25,-210)
	checkbutton7:SetScript('OnShow', function(self) 
		self:SetChecked(WarcraftyConfig.textpercent) 
	end)
	checkbutton7:SetScript('OnClick', function(self) 
		if (self:GetChecked() == nil) then
			WarcraftyConfig.textpercent = false
		else
			WarcraftyConfig.textpercent = true
		end
	end)
	
	local panel2 = Warcrafty_CreatePanel(frame,"Tooltip Location:",false)
	panel2:SetWidth(270)
	panel2:SetHeight(45)
	panel2:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-270)
	
	local checkbutton8 = Warcrafty_CreateCheckButton("Bottom Right",frame)
	checkbutton8:SetPoint("TOPLEFT",frame,"TOPLEFT",25,-280)
	local checkbutton9 = Warcrafty_CreateCheckButton("Cursor",frame)
	checkbutton9:SetPoint("TOPLEFT",frame,"TOPLEFT",150,-280)
	
	checkbutton8:SetScript('OnShow', function(self)
		if (WarcraftyConfig.tooltip == 1) then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton8:SetScript('OnClick', function(self) 
		if (WarcraftyConfig.tooltip == 2) then
			checkbutton9:SetChecked(false)
		end
		self:SetChecked(true)
		WarcraftyConfig.tooltip = 1
	end)
	checkbutton9:SetScript('OnShow', function(self)
		if (WarcraftyConfig.tooltip == 2) then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton9:SetScript('OnClick', function(self) 
		if (WarcraftyConfig.tooltip == 1) then
			checkbutton8:SetChecked(false)
		end
		self:SetChecked(true)
		WarcraftyConfig.tooltip = 2
	end)
	
end

local function Warcrafty_CreateTab2Page(frame)
	frame:SetWidth(400)
	frame:SetHeight(400)
	frame:SetPoint("TOPLEFT",WarcraftyOptionsTab1,"BOTTOMLEFT",-3,0)
	
	local panel1 = Warcrafty_CreatePanel(frame,"Skin:",false)
	panel1:SetWidth(270)
	panel1:SetHeight(65)
	panel1:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-30)
	
	local checkbutton1 = Warcrafty_CreateCheckButton("Orc",frame)
	checkbutton1:SetPoint("TOPLEFT",frame,"TOPLEFT",25,-38)
	local checkbutton2 = Warcrafty_CreateCheckButton("Human",frame)
	checkbutton2:SetPoint("TOPLEFT",frame,"TOPLEFT",150,-38)
	local checkbutton8 = Warcrafty_CreateCheckButton("Night Elf",frame)
	checkbutton8:SetPoint("TOPLEFT",frame,"TOPLEFT",25,-62)
	local checkbutton9 = Warcrafty_CreateCheckButton("Undead",frame)
	checkbutton9:SetPoint("TOPLEFT",frame,"TOPLEFT",150,-62)
	
	
	checkbutton1:SetScript('OnShow', function(self)
		if (WarcraftyConfigPerChar.skin == "orc") then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton1:SetScript('OnClick', function(self) 
		if (WarcraftyConfigPerChar.skin ~= "orc") then
			self:SetChecked(true)
			checkbutton2:SetChecked(false)
			checkbutton8:SetChecked(false)
			checkbutton9:SetChecked(false)
			WarcraftyConfigPerChar.skin = "orc"
			WarcraftySetSkin(WarcraftyConfigPerChar.skin)
		end
	end)
	checkbutton2:SetScript('OnShow', function(self)
		if (WarcraftyConfigPerChar.skin == "human") then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton2:SetScript('OnClick', function(self) 
		if (WarcraftyConfigPerChar.skin ~= "human") then
			self:SetChecked(true)
			checkbutton1:SetChecked(false)
			checkbutton8:SetChecked(false)
			checkbutton9:SetChecked(false)
			WarcraftyConfigPerChar.skin = "human"
			WarcraftySetSkin(WarcraftyConfigPerChar.skin)
		end
	end)
	checkbutton8:SetScript('OnShow', function(self)
		if (WarcraftyConfigPerChar.skin == "nightelf") then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton8:SetScript('OnClick', function(self) 
		if (WarcraftyConfigPerChar.skin ~= "nightelf") then
			self:SetChecked(true)
			checkbutton1:SetChecked(false)
			checkbutton2:SetChecked(false)
			checkbutton9:SetChecked(false)
			WarcraftyConfigPerChar.skin = "nightelf"
			WarcraftySetSkin(WarcraftyConfigPerChar.skin)
		end
	end)
	checkbutton9:SetScript('OnShow', function(self)
		if (WarcraftyConfigPerChar.skin == "undead") then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton9:SetScript('OnClick', function(self) 
		if (WarcraftyConfigPerChar.skin ~= "undead") then
			self:SetChecked(true)
			checkbutton1:SetChecked(false)
			checkbutton2:SetChecked(false)
			checkbutton8:SetChecked(false)
			WarcraftyConfigPerChar.skin = "undead"
			WarcraftySetSkin(WarcraftyConfigPerChar.skin)
		end
	end)
	
	local checkbutton3 = Warcrafty_CreateCheckButton("Show Druid Mana in Forms", frame)
	checkbutton3:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-103)
	checkbutton3:SetScript('OnShow', function(self) 
		self:SetChecked(WarcraftyConfigPerChar.druidbar) 
		local _, englishClass = UnitClass("player")
		if (englishClass == "DRUID") then
			self:Enable()
		else
			self:Disable()
		end
	end)
	checkbutton3:SetScript('OnClick', function(self) 
		if (self:GetChecked() == nil) then
			WarcraftyConfigPerChar.druidbar = false
			WarcraftyPlayerDruidBar:Hide()
		else
			WarcraftyConfigPerChar.druidbar = true
			if ( UnitPowerType("player") == 0 ) then
				WarcraftyPlayerDruidBar:Hide()
			else
				WarcraftyPlayerDruidBar:Show()
			end
		end
	end)
	
	local panel2 = Warcrafty_CreatePanel(frame,"Bar Texture: (Enable bottomleft/right bars for more bars.)",false)
	panel2:SetWidth(375)
	panel2:SetHeight(45)
	panel2:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-170)
	
	local checkbutton4 = Warcrafty_CreateCheckButton("1 Bar",frame)
	checkbutton4:SetPoint("TOPLEFT",frame,"TOPLEFT",25,-180)
	local checkbutton5 = Warcrafty_CreateCheckButton("2 Bars",frame)
	checkbutton5:SetPoint("TOPLEFT",frame,"TOPLEFT",150,-180)
	local checkbutton6 = Warcrafty_CreateCheckButton("3 Bars",frame)
	checkbutton6:SetPoint("TOPLEFT",frame,"TOPLEFT",275,-180)
	
	checkbutton4:SetScript('OnShow', function(self)
		if (WarcraftyConfigPerChar.bars == 1) then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton4:SetScript('OnClick', function(self) 
		if (WarcraftyConfigPerChar.bars == 2) then
			checkbutton5:SetChecked(false)
		elseif (WarcraftyConfigPerChar.bars == 3) then
			checkbutton6:SetChecked(false)
		end
		self:SetChecked(true)
		WarcraftyConfigPerChar.bars = 1
		WarcraftySetSkin(WarcraftyConfigPerChar.skin)
	end)
	checkbutton5:SetScript('OnShow', function(self)
		if (WarcraftyConfigPerChar.bars == 2) then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton5:SetScript('OnClick', function(self) 
		if (WarcraftyConfigPerChar.bars == 1) then
			checkbutton4:SetChecked(false)
		elseif (WarcraftyConfigPerChar.bars == 3) then
			checkbutton6:SetChecked(false)
		end
		self:SetChecked(true)
		WarcraftyConfigPerChar.bars = 2
		WarcraftySetSkin(WarcraftyConfigPerChar.skin)
	end)
	checkbutton6:SetScript('OnShow', function(self)
		if (WarcraftyConfigPerChar.bars == 3) then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	checkbutton6:SetScript('OnClick', function(self) 
		if (WarcraftyConfigPerChar.bars == 1) then
			checkbutton4:SetChecked(false)
		elseif (WarcraftyConfigPerChar.bars == 2) then
			checkbutton5:SetChecked(false)
		end
		self:SetChecked(true)
		WarcraftyConfigPerChar.bars = 3
		WarcraftySetSkin(WarcraftyConfigPerChar.skin)
	end)
	
	local checkbutton7 = Warcrafty_CreateCheckButton("Enable Warcrafty XP Bar", frame)
	checkbutton7:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-128)
	checkbutton7:SetScript('OnShow', function(self) 
		self:SetChecked(WarcraftyConfigPerChar.xpbar) 
	end)
	checkbutton7:SetScript('OnClick', function(self) 
		if (self:GetChecked() == nil) then
			WarcraftyConfigPerChar.xpbar = false
			WarcraftyXPBar:Hide()
		else
			WarcraftyConfigPerChar.xpbar = true
			WarcraftyXPBar:Show()
		end
	end)
end

function Warcrafty_AddPanelOptions()
	local WarcraftyOptions = CreateFrame("Frame","WarcraftyOptions",UIParent)
	WarcraftyOptions.name = "Warcrafty"
	
	local WarcraftyOptionsTab1 = Warcrafty_CreateTab(WarcraftyOptions,"Tab1","Global Settings")
	WarcraftyOptionsTab1:SetPoint("TOPLEFT",10,-2)
	local WarcraftyOptionsTab2 = Warcrafty_CreateTab(WarcraftyOptions,"Tab2","Character Settings")
	WarcraftyOptionsTab2:SetPoint("TOPLEFT",125,-2)

	local WarcraftyOptionsTab1Page = CreateFrame("Frame","WarcraftyOptionsTab1Page",WarcraftyOptionsTab1)
	local WarcraftyOptionsTab2Page = CreateFrame("Frame","WarcraftyOptionsTab2Page",WarcraftyOptionsTab2)

	Warcrafty_CreateTab1Page(WarcraftyOptionsTab1Page)
	Warcrafty_CreateTab2Page(WarcraftyOptionsTab2Page)

	local LastTabRightSideSpacer = Warcrafty_CreateSpacer(WarcraftyOptions,160)
	LastTabRightSideSpacer:SetPoint("LEFT",WarcraftyOptionsTab2,"BOTTOMRIGHT",-10,2)
	local Tab1Tab2Spacer = Warcrafty_CreateSpacer(WarcraftyOptions,16)
	Tab1Tab2Spacer:SetPoint("LEFT",WarcraftyOptionsTab1,"BOTTOMRIGHT",-10,2)
	local LeftSideFirstTabSpacer = Warcrafty_CreateSpacer(WarcraftyOptions,16)
	LeftSideFirstTabSpacer:SetPoint("RIGHT",WarcraftyOptionsTab1,"BOTTOMLEFT",10,2)

	PanelTemplates_SetNumTabs(WarcraftyOptions,2)
	PanelTemplates_SetTab(WarcraftyOptions,WarcraftyOptionsTab1)
	
	WarcraftyOptionsTab1:SetScript("OnClick",function()	
		PanelTemplates_SetTab(WarcraftyOptions, 1); 
		WarcraftyOptionsTab1.spacer:Hide(); 
		WarcraftyOptionsTab1Page:Show(); 
		WarcraftyOptionsTab2Page:Hide(); 
		WarcraftyOptionsTab2.spacer:Show(); 
	end)
	WarcraftyOptionsTab2:SetScript("OnClick",function() 
		PanelTemplates_SetTab(WarcraftyOptions, 2); 
		WarcraftyOptionsTab2.spacer:Hide(); 
		WarcraftyOptionsTab2Page:Show(); 
		WarcraftyOptionsTab1Page:Hide(); 
		WarcraftyOptionsTab1.spacer:Show(); 
	end)
	WarcraftyOptions:SetScript("OnShow",function() 
		PanelTemplates_SetTab(WarcraftyOptions, 1); 
		WarcraftyOptionsTab1.spacer:Hide(); 
		WarcraftyOptionsTab1Page:Show(); 
		WarcraftyOptionsTab2Page:Hide(); 
		WarcraftyOptionsTab2.spacer:Show(); 
	end)
	
	InterfaceOptions_AddCategory(WarcraftyOptions)
end

function round(num, idp)
	if idp and idp>0 then
		local mult = 10^idp
		return math.floor(num * mult + 0.5) / mult
	end
	return math.floor(num + 0.5)
end