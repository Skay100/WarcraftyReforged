SLASH_WARCRAFTY1 = "/warcrafty"
local function handler()
	InterfaceOptionsFrame_OpenToCategory(WarcraftyOptions);
end
SlashCmdList["WARCRAFTY"] = handler


function GameTooltip_SetDefaultAnchor(GameTooltip, parent, ...)
	if (WarcraftyConfig.tooltip == 1) then
		GameTooltip:SetOwner(WarcraftyBarFrame, "ANCHOR_TOPRIGHT");
	elseif (WarcraftyConfig.tooltip == 2) then
		GameTooltip:SetOwner(parent, "ANCHOR_CURSOR");
	end
	GameTooltip:SetBackdropColor(.15,.15,.15)
end

function WarcraftyOnLoad(self) 
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("UNIT_POWER_UPDATE")
	self:RegisterEvent("UNIT_DISPLAYPOWER")
	self:RegisterEvent("RAID_TARGET_UPDATE")
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("UNIT_FLAGS")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("UNIT_FACTION")
	self:RegisterEvent("UNIT_LEVEL")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
end 

function WarcraftyPlayerMenu_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local showmenu = function()
		ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "WarcraftyPlayerMenu", 105, 10)
	end
	SecureUnitButton_OnLoad(self, "player", showmenu)
end
function WarcraftyPetMenu_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local showmenu = function()
		ToggleDropDownMenu(1, nil, PetFrameDropDown, "WarcraftyPetMenu", 105, 10)
	end
	SecureUnitButton_OnLoad(self, "pet", showmenu)
end
function WarcraftyTargetMenu_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local showmenu = function()
		ToggleDropDownMenu(1, nil, TargetFrameDropDown, "WarcraftyTargetMenu", 105, 10)
	end
	SecureUnitButton_OnLoad(self, "target", showmenu)
end

function WarcraftyBuffButton_OnClick (self)
	CancelUnitBuff(self.unit, self:GetID(), self.filter)
end


function WarcraftyOnUpdate() 
	CONTAINER_OFFSET_Y = 230; --ugly hack
	local playerHealth = UnitHealth("player")
	if (playerHealth > 99999) then
		playerHealth = round(playerHealth/1000, 0).."K"
	end
	local playerHealthMax = UnitHealthMax("player")
	if (playerHealthMax > 99999) then
		playerHealthMax = round(playerHealthMax/1000, 0).."K"
	end
	local playerPower = UnitPower("player")
	if (playerPower > 99999) then
		playerPower = round(playerPower/1000, 0).."K"
	end
	local playerPowerMax = UnitPowerMax("player")
	if (playerPowerMax > 99999) then
		playerPowerMax = round(playerPowerMax/1000, 0).."K"
	end
	local targetHealth = UnitHealth("target")
	if (targetHealth > 99999) then
		targetHealth = round(targetHealth/1000, 0).."K"
	end
	local targetHealthMax = UnitHealthMax("target")
	if (targetHealthMax > 99999) then
		targetHealthMax = round(targetHealthMax/1000, 0).."K"
	end
	local targetPower = UnitPower("target")
	if (targetPower > 99999) then
		targetPower = round(targetPower/1000, 0).."K"
	end
	local targetPowerMax = UnitPowerMax("target")
	if (targetPowerMax > 99999) then
		targetPowerMax = round(targetPowerMax/1000, 0).."K"
	end

	if (WarcraftyConfig.textstyle == 1) then
		WarcraftyPlayerHealthText:SetText(playerHealth.."/"..playerHealthMax)
		WarcraftyPlayerPowerText:SetText(playerPower.."/"..playerPowerMax)
	elseif (WarcraftyConfig.textstyle == 2) then
		WarcraftyPlayerHealthText:SetText(playerHealth)
		WarcraftyPlayerPowerText:SetText(playerPower)
	elseif (WarcraftyConfig.textstyle == 3) then
		WarcraftyPlayerHealthText:SetText(" ")
		WarcraftyPlayerPowerText:SetText(" ")
	end
	if (WarcraftyConfig.textpercent) then
		WarcraftyPlayerHealthText:SetText(WarcraftyPlayerHealthText:GetText().." "..round((UnitHealth("player")/UnitHealthMax("player"))*100, 0).."%")
		WarcraftyPlayerPowerText:SetText(WarcraftyPlayerPowerText:GetText().." "..round((UnitPower("player")/UnitPowerMax("player"))*100, 0).."%")
	end
	WarcraftyPlayerHealthBar:SetMinMaxValues(0, UnitHealthMax("player"))
    WarcraftyPlayerHealthBar:SetValue(UnitHealth("player"))
	WarcraftyPlayerPowerBar:SetMinMaxValues(0, UnitPowerMax("player"))
    WarcraftyPlayerPowerBar:SetValue(UnitPower("player"))
	
	if ( (UnitHealth("player") <= 0) and UnitIsConnected("player") ) then
		WarcraftyPlayerDeadText:Show()
		WarcraftyPlayerHealthText:Hide()
	else
		WarcraftyPlayerDeadText:Hide()
		WarcraftyPlayerHealthText:Show()
	end
	
	WarcraftyConfigPerChar = WarcraftyConfigPerChar or {}
	
	if (WarcraftyConfigPerChar.druidbar == true) then
		WarcraftyPlayerDruidBar:SetMinMaxValues(0, UnitPowerMax("player", 0))
		WarcraftyPlayerDruidBar:SetValue(UnitPower("player", 0))
	end

	if ( UnitExists("target") ) then
		if (WarcraftyConfig.textstyle == 1) then
			WarcraftyTargetHealthText:SetText(targetHealth.."/"..targetHealthMax)
			WarcraftyTargetPowerText:SetText(targetPower.."/"..targetPowerMax)
		elseif (WarcraftyConfig.textstyle == 2) then
			WarcraftyTargetHealthText:SetText(targetHealth)
			WarcraftyTargetPowerText:SetText(targetPower)
		elseif (WarcraftyConfig.textstyle == 3) then
			WarcraftyTargetHealthText:SetText(" ")
			WarcraftyTargetPowerText:SetText(" ")
		end
		if (WarcraftyConfig.textpercent) then
			WarcraftyTargetHealthText:SetText(WarcraftyTargetHealthText:GetText().." "..round((UnitHealth("target")/UnitHealthMax("target"))*100, 0).."%  ")
			WarcraftyTargetPowerText:SetText(WarcraftyTargetPowerText:GetText().." "..round((UnitPower("target")/UnitPowerMax("target"))*100, 0).."%  ")
		end
		if ( targetPowerMax == 0 ) then
			WarcraftyTargetPowerText:SetText("")
		end
		WarcraftyTargetHealthBar:SetMinMaxValues(0, UnitHealthMax("target"))
		WarcraftyTargetHealthBar:SetValue(UnitHealth("target"))
		WarcraftyTargetPowerBar:SetMinMaxValues(0, UnitPowerMax("target"))
		WarcraftyTargetPowerBar:SetValue(UnitPower("target"))
		if (UnitIsTapDenied("target")) then
			-- Target is tapped by another player
			WarcraftyTargetHealthBar:SetStatusBarColor(.75,.75,.75)
		else
			-- target is not tapped by another player
			WarcraftyTargetHealthBar:SetStatusBarColor(0,1,0)
		end
	end
	if ( (UnitHealth("target") <= 0) and UnitIsConnected("target") ) then
		WarcraftyTargetDeadText:Show()
		WarcraftyTargetHealthText:Hide()
	else
		WarcraftyTargetDeadText:Hide()
		WarcraftyTargetHealthText:Show()
	end
	
	if ( UnitExists("pet") ) then
		if (UnitPowerMax("pet") == 0) then
			WarcraftyPetPowerText:Hide()
		else
			WarcraftyPetPowerText:Show()
		end
		WarcraftyPetHealthText:SetText(round((UnitHealth("pet")/UnitHealthMax("pet"))*100, 0).."%  ")
		WarcraftyPetPowerText:SetText(round((UnitPower("pet")/UnitPowerMax("pet"))*100, 0).."%  ")
		WarcraftyPetHealthBar:SetMinMaxValues(0, UnitHealthMax("pet"))
		WarcraftyPetHealthBar:SetValue(UnitHealth("pet"))
		WarcraftyPetPowerBar:SetMinMaxValues(0, UnitPowerMax("pet"))
		WarcraftyPetPowerBar:SetValue(UnitPower("pet"))
	end
	if ( UnitExists("targettarget") ) then
		if (UnitPowerMax("targettarget") == 0) then
			WarcraftyTargetTargetPowerText:Hide()
		else
			WarcraftyTargetTargetPowerText:Show()
		end
		WarcraftyTargetTargetHealthText:SetText(round((UnitHealth("targettarget")/UnitHealthMax("targettarget"))*100, 0).."%")
		WarcraftyTargetTargetPowerText:SetText(round((UnitPower("targettarget")/UnitPowerMax("targettarget"))*100, 0).."%")
		WarcraftyTargetTargetHealthBar:SetMinMaxValues(0, UnitHealthMax("targettarget"))
		WarcraftyTargetTargetHealthBar:SetValue(UnitHealth("targettarget"))
		WarcraftyTargetTargetPowerBar:SetMinMaxValues(0, UnitPowerMax("targettarget"))
		WarcraftyTargetTargetPowerBar:SetValue(UnitPower("targettarget"))
	end
	
	if (WarcraftyConfig.actionbar) then
		WarcraftyActionbarOnUpdate()
	end
	WarcraftyTempEnchantOnUpdate()
end 

function WarcraftyOnEvent(self, event, ...)
	local arg1 = ...
	if ( event == "PLAYER_ENTERING_WORLD") then
		WarcraftyABTest()
		WarcraftySetXPBar()
		WarcraftyTempEnchantOnEvent()
		WarcraftyAuraUpdate("player")
		WarcraftySetStatusColor()
		WarcraftyCheckPlayer()
		WarcraftyCheckTarget()
		WarcraftyTargetClassTexture:SetVertexColor(0, 0, 0)
		WarcraftyPowerBarColor("Player")
		WarcraftyCheckPet()
		WarcraftyCheckTargetTarget()
		WarcraftyUpdateRaidIcon()


		
		if ( WarcraftyConfigPerChar.skin == nil ) then
			if ( UnitFactionGroup("player") == "Horde" ) then
				WarcraftyConfigPerChar.skin = "orc"
			end
			if ( UnitFactionGroup("player") == "Alliance" ) then
				WarcraftyConfigPerChar.skin = "human"
			end
			WarcraftySetSkin(WarcraftyConfigPerChar.skin)
		else
			WarcraftySetSkin(WarcraftyConfigPerChar.skin)
		end
		if ( WarcraftyConfigPerChar.xpbar == nil) then
			local expansion = GetAccountExpansionLevel() -- Returns index of registered expansion. (0=WoW, 1=BC, 2=WotLK)
			local level = UnitLevel("player")
			if ((expansion == 0 and level == 60) or (expansion == 1 and level == 70) or (expansion == 2 and level == 80)) then
				WarcraftyConfigPerChar.xpbar = false
				WarcraftyXPBar:Hide()
			else
				WarcraftyConfigPerChar.xpbar = true
				WarcraftyXPBar:Show()
			end
		else
			if (WarcraftyConfigPerChar.xpbar) then
				WarcraftyXPBar:Show()
			else
				WarcraftyXPBar:Hide()
			end
		end
		if ( WarcraftyConfigPerChar.druidbar == nil ) then
			local _, englishClass = UnitClass("player")
			if ( englishClass == "DRUID" ) then
				WarcraftyConfigPerChar.druidbar = true
				WarcraftyPlayerDruidBar:Show()
			else
				WarcraftyConfigPerChar.druidbar = false
				WarcraftyPlayerDruidBar:Hide()
			end
		else
			if ( WarcraftyConfigPerChar.druidbar == true ) then
				if ( UnitPowerType("player") == 0 ) then
					WarcraftyPlayerDruidBar:Hide()
				else
					WarcraftyPlayerDruidBar:Show()
				end
			else
				WarcraftyPlayerDruidBar:Hide()
			end
		end
		local _, englishClass = UnitClass("player")
		if ( englishClass == "SHAMAN" ) then
			tempEnchantDuration = 1800
		else
			tempEnchantDuration = 3600
		end
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		WarcraftyCheckTargetTarget()
		if ( arg1 == "player" ) then
			WarcraftyPlayerModel:SetUnit("player")
			WarcraftyPlayerModel:SetCamera(0)
		elseif ( arg1 == "target" ) then
			WarcraftyTargetModel:SetUnit("target")
			WarcraftyTargetModel:SetCamera(0)
		elseif ( arg1 == "pet" ) then
			WarcraftyCheckPet()
        end			
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		WarcraftySetStatusColor()
		WarcraftyComboFrame_Update()
		WarcraftyUpdateRaidIcon()
		WarcraftyAuraUpdate("target")
		WarcraftyCheckTargetTarget()
		WarcraftyCheckTarget()
	elseif ( event == "UNIT_AURA" ) then
		WarcraftyAuraUpdate("player")
		WarcraftyAuraUpdate("target")
		WarcraftyTempEnchantOnEvent()
	elseif ( event == "UNIT_INVENTORY_CHANGED" ) then
		WarcraftyAuraUpdate("player")
		WarcraftyAuraUpdate("target")
		WarcraftyTempEnchantOnEvent()
	elseif ( event == "UNIT_PET" ) then
		if ( arg1 == "player") then
			WarcraftyCheckPet()
			WarcraftyPowerBarColor("Pet")
		end
	elseif ( event == "UNIT_TARGET" ) then
		if ( arg1 == "target") then
			WarcraftyCheckTargetTarget()
			WarcraftyPowerBarColor("TargetTarget")
		end
	elseif ( event == "UNIT_POWER_UPDATE" ) then
		if ( arg1 == "player" ) then
			WarcraftyComboFrame_Update()
		end
	elseif ( event == "UNIT_DISPLAYPOWER" ) then
		if (arg1 == "player") then
			WarcraftyPowerBarColor("Player")
		elseif (arg1 == "target") then
			WarcraftyPowerBarColor("Target")
		elseif (arg1 == "pet") then
			WarcraftyPowerBarColor("Pet")
		end
		if ( UnitExists("targettarget") ) then
			WarcraftyPowerBarColor("TargetTarget")
		end
		if ( arg1 == "player" and WarcraftyConfigPerChar.druidbar == true ) then
			if ( UnitPowerType("player") == 0 ) then
				WarcraftyPlayerDruidBar:Hide()
			else
				WarcraftyPlayerDruidBar:Show()
			end
		end
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		WarcraftyUpdateRaidIcon()
	elseif ( (event == "UNIT_FACTION") or (event == "UNIT_LEVEL") ) then
		if (arg1 == "target") then
			WarcraftyCheckTarget()
		elseif (arg1 == "player") then
			WarcraftyCheckPlayer()
		end
	elseif ( event == "UNIT_FLAGS" ) then
		WarcraftySetStatusColor()
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		WarcraftyCheckTarget()
		WarcraftyCheckPlayer()
	elseif ( event == "PLAYER_UPDATE_RESTING") then
		WarcraftySetStatusColor()
	elseif ( event == "PLAYER_XP_UPDATE") then
		WarcraftySetXPBar()
	elseif (event == "UNIT_NAME_UPDATE") then
		WarcraftyCheckPlayer()
		WarcraftyCheckTarget()
		WarcraftyCheckPet()
		WarcraftyCheckTargetTarget()
	elseif ( event == "ADDON_LOADED" ) then
		if ( arg1 == "Warcrafty" ) then
			Warcrafty_AddPanelOptions()
			RuneFrame:ClearAllPoints()
			RuneFrame:SetParent("WarcraftyPlayerFrame")
			RuneFrame:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -88, 150)
			TotemFrame:ClearAllPoints()
			TotemFrame:SetParent("WarcraftyPlayerFrame")
			TotemFrame:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -95, 140)
			if ( WarcraftyConfig == nil) then
				WarcraftyConfig = {}
			end
			if ( WarcraftyConfigPerChar == nil) then
				WarcraftyConfigPerChar = {}
			end
			if ( WarcraftyConfig.scale == nil ) then
				WarcraftyConfig.scale = (UIParent:GetWidth() / UIParent:GetHeight()) * .5647
				WarcraftySetScale()
			else
				WarcraftySetScale()
			end
			if ( WarcraftyConfig.minimap == nil ) then
				WarcraftyConfig.minimap = true
				WarcraftySetMinimap()
			else
				if ( WarcraftyConfig.minimap ) then
					WarcraftySetMinimap()
				end
			end
			if ( WarcraftyConfigPerChar.bars == nil ) then
				WarcraftyConfigPerChar.bars = 1
			end
			if ( WarcraftyConfig.actionbar == nil ) then
				WarcraftyConfig.actionbar = true
				WarcraftySetBars()
			else
				if ( WarcraftyConfig.actionbar == true ) then
					WarcraftySetBars()
				end
			end
			if ( WarcraftyConfig.castbar == nil) then
				WarcraftyConfig.castbar = true
			end
			if ( WarcraftyConfig.textstyle == nil) then
				WarcraftyConfig.textstyle = 1
			end
			if ( WarcraftyConfig.textpercent == nil) then
				WarcraftyConfig.textpercent = false
			end
			if (WarcraftyConfig.tooltip == nil) then
				WarcraftyConfig.tooltip = 1
			end
			
		end
	end
end

function WarcraftySetStatusColor()
	if ( IsResting() ) then
		WarcraftyPlayerRestIcon:Show()
	else
		WarcraftyPlayerRestIcon:Hide()
	end
	if (UnitAffectingCombat("player")) then
		WarcraftyPlayerStatusTexture:Show()
		WarcraftyPlayerStatusTexture:SetVertexColor(1,0,0)
	else
		WarcraftyPlayerStatusTexture:Hide()
	end
	if ( UnitAffectingCombat("target") ) then
		WarcraftyTargetStatusTexture:Show()
		WarcraftyTargetStatusTexture:SetVertexColor(1,0,0)
	else
		WarcraftyTargetStatusTexture:Hide()
	end
end

function WarcraftySetXPBar()
	local currXP = UnitXP("player");
	local nextXP = UnitXPMax("player");
	WarcraftyXPBar:SetMinMaxValues(min(0, currXP), nextXP);
	WarcraftyXPBar:SetValue(currXP);
	
	local restXP = GetXPExhaustion()
	if (restXP ~= nil) then
		WarcraftyXPBarText:SetText("XP: "..currXP.." / "..nextXP.."  Rested XP: "..restXP)
	else
		WarcraftyXPBarText:SetText("XP: "..currXP.." / "..nextXP.."  Rested XP: 0")
	end
end

function WarcraftyCheckPlayer()
	WarcraftyPlayerModel:SetUnit("player")
	WarcraftyPlayerModel:SetCamera(0)
	WarcraftyPlayerNameText:SetText(UnitName("player"))
	WarcraftyUpdateClassColor("Player")


	local factionGroup = UnitFactionGroup("player")
	if ( UnitIsPVPFreeForAll("player") ) then
		WarcraftyPlayerPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		WarcraftyPlayerPVPIcon:Show()
	elseif ( factionGroup and UnitIsPVP("player") ) then
		WarcraftyPlayerPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
		WarcraftyPlayerPVPIcon:Show()
	else
		WarcraftyPlayerPVPIcon:Hide()
	end

	WarcraftyPlayerLevelText:SetText(UnitLevel("player"))
	WarcraftyPlayerLevelText:SetVertexColor(1.0, 0.82, 0.0)

	if ( UnitIsGroupLeader("player") ) then
		WarcraftyPlayerLeaderIcon:Show()
	else
		WarcraftyPlayerLeaderIcon:Hide()
	end
end

function WarcraftyCheckTarget()
	if ( UnitExists("target") ) then
		if (UnitIsVisible("target")) then -- 1 if visible, nil if not
			WarcraftyTargetModel:SetUnit("target")
			WarcraftyTargetModel:SetCamera(0)
		else
			WarcraftyTargetModel:ClearModel()
		end
		WarcraftyUpdateClassColor("Target")
		WarcraftyTargetNameText:Show()
		WarcraftyTargetNameText:SetText(UnitName("target"))
		WarcraftyTargetClassText:Show()
		if (UnitIsPlayer("target")) then
			WarcraftyTargetClassText:SetText(UnitClass("target"))
		else
			local unitType = UnitCreatureType("target")
			if (unitType == "Not specified") then
				unitType = ""
			end
			if (UnitClassification("target") == "elite") then
				WarcraftyTargetClassText:SetText("Elite "..unitType)
			elseif (UnitClassification("target") == "rare") then
				WarcraftyTargetClassText:SetText("Rare "..unitType)
			elseif (UnitClassification("target") == "rareelite") then
				WarcraftyTargetClassText:SetText("Rare-Elite "..unitType)
			elseif (UnitClassification("target") == "worldboss") then
				WarcraftyTargetClassText:SetText("Boss "..unitType)
			else
				WarcraftyTargetClassText:SetText(unitType)
			end
		end
		WarcraftyTargetHealthBar:Show()
		WarcraftyTargetPowerBar:Show()
		WarcraftyPowerBarColor("Target")
		if ( UnitExists("targettarget") ) then
			WarcraftyPowerBarColor("TargetTarget")
		end
	else
		WarcraftyTargetModel:ClearModel()
		WarcraftyTargetHealthBar:Hide()
		WarcraftyTargetPowerBar:Hide()
		WarcraftyTargetNameText:Hide()
		WarcraftyTargetClassText:Hide()
		WarcraftyTargetClassTexture:SetVertexColor(0, 0, 0)
	end

	local factionGroup = UnitFactionGroup("target")
	if ( UnitIsPVPFreeForAll("target") ) then
		WarcraftyTargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		WarcraftyTargetPVPIcon:Show()
	elseif ( factionGroup and UnitIsPVP("target") ) then
		WarcraftyTargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
		WarcraftyTargetPVPIcon:Show()
	else
		WarcraftyTargetPVPIcon:Hide()
	end

	local targetLevel = UnitLevel("target")
	if ( UnitIsCorpse("target") ) then
		WarcraftyTargetLevelText:Hide()
		WarcraftyTargetHighLevelTexture:Show()
	elseif ( targetLevel > 0 ) then
		-- Normal level target
		WarcraftyTargetLevelText:SetText(targetLevel)
		-- Color level number
		if ( UnitCanAttack("player", "target") ) then
		local color
			if (GetQuestDifficultyColor == nil) then
				color = GetDifficultyColor(targetLevel)
			else
				color = GetQuestDifficultyColor(targetLevel)
			end
			WarcraftyTargetLevelText:SetVertexColor(color.r, color.g, color.b)
		else
			WarcraftyTargetLevelText:SetVertexColor(1.0, 0.82, 0.0)
		end
		WarcraftyTargetLevelText:Show()
		WarcraftyTargetHighLevelTexture:Hide()
        elseif ( not UnitExists("target") ) then
                WarcraftyTargetLevelText:Hide()
                WarcraftyTargetHighLevelTexture:Hide()
	else
		-- Target is too high level to tell
		WarcraftyTargetLevelText:Hide()
		WarcraftyTargetHighLevelTexture:Show()
	end

	if ( UnitIsGroupLeader("target") ) then
		WarcraftyTargetLeaderIcon:Show()
	else
		WarcraftyTargetLeaderIcon:Hide()
	end
end

function WarcraftyCheckPet()
	if ( UnitExists("pet") ) then
		WarcraftyPetModel:Show()
		WarcraftyPetModel:SetUnit("pet")
		WarcraftyPetModel:SetCamera(0)
		WarcraftyPetHealthBar:Show()
		WarcraftyPetPowerBar:Show()
		WarcraftyPetNameText:SetText(UnitName("pet"))
		WarcraftyPlayerModel:SetHeight(112)
		WarcraftyPlayerClassTexture:SetHeight(112)
		WarcraftyPlayerModel:SetPoint("BOTTOM", UIParent, "BOTTOM", -247, 38)
	else
		WarcraftyPetModel:Hide()
		WarcraftyPetHealthBar:Hide()
		WarcraftyPetPowerBar:Hide()
		WarcraftyPlayerModel:SetHeight(150)
		WarcraftyPlayerClassTexture:SetHeight(150)
		WarcraftyPlayerModel:SetPoint("BOTTOM", UIParent, "BOTTOM", -247, 0)
	end
end
function WarcraftyCheckTargetTarget()
	if ( UnitExists("TargetTarget") ) then
		WarcraftyTargetTargetModel:Show()
		WarcraftyTargetTargetModel:SetUnit("targettarget")
		WarcraftyTargetTargetModel:SetCamera(0)
		WarcraftyTargetTargetHealthBar:Show()
		WarcraftyTargetTargetPowerBar:Show()
		WarcraftyTargetTargetNameText:SetText(UnitName("targettarget"))
		WarcraftyTargetModel:SetHeight(112)
		WarcraftyTargetClassTexture:SetHeight(112)
		WarcraftyTargetModel:SetPoint("BOTTOM", UIParent, "BOTTOM", 247, 38)
	else
		WarcraftyTargetTargetModel:Hide()
		WarcraftyTargetTargetHealthBar:Hide()
		WarcraftyTargetTargetPowerBar:Hide()
		WarcraftyTargetModel:SetHeight(150)
		WarcraftyTargetClassTexture:SetHeight(150)
		WarcraftyTargetModel:SetPoint("BOTTOM", UIParent, "BOTTOM", 247, 0)
	end
end


function WarcraftyUpdateRaidIcon()
	local targetindex = GetRaidTargetIndex("target")
	if ( targetindex ) then
		targetindex = targetindex - 1
		local left, right, top, bottom
		left = mod(targetindex , 4) * .25
		right = left + .25
		top = floor(targetindex / 4) * .25
		bottom = top + .25
		WarcraftyTargetRaidTargetIcon:SetTexCoord(left, right, top, bottom)
		WarcraftyTargetRaidTargetIcon:Show()
	else
		WarcraftyTargetRaidTargetIcon:Hide()
	end
	local playerindex = GetRaidTargetIndex("player")
	if ( playerindex ) then
		playerindex = playerindex - 1
		local left, right, top, bottom
		left = mod(playerindex , 4) * .25
		right = left + .25
		top = floor(playerindex / 4) * .25
		bottom = top + .25
		WarcraftyPlayerRaidTargetIcon:SetTexCoord(left, right, top, bottom)
		WarcraftyPlayerRaidTargetIcon:Show()
	else
		WarcraftyPlayerRaidTargetIcon:Hide()
	end
end


function WarcraftyUpdateClassColor(unit)
	if ( UnitIsPlayer(unit) ) then
		local _, targetclass = UnitClass(unit)
		if ( targetclass == 'WARRIOR' ) then
			_G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(.78, .61, .43)
		end
		if ( targetclass == 'MAGE' ) then
			_G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(.41, .80, .94)
		end
		if ( targetclass == 'ROGUE' ) then
			_G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(1, .96, .41)
		end
		if ( targetclass == 'DRUID' ) then
			_G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(1, .49, .04)
		end
		if ( targetclass == 'HUNTER' ) then
			_G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(.67, .83, .45)
		end
		if ( targetclass == 'SHAMAN' ) then
			_G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(.14, .35, 1.00)
		end
		if ( targetclass == 'PRIEST' ) then
			_G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(1, 1, 1)
		end
		if ( targetclass == 'WARLOCK' ) then
		    _G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(.58, .51, .79)
		end
		if ( targetclass == 'PALADIN' ) then
		    _G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(.96, .55, .73)
		end
		if ( targetclass == 'DEATHKNIGHT' ) then
		    _G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(0.77, 0.12, 0.23)
		end
	else
		_G["Warcrafty"..unit.."ClassTexture"]:SetVertexColor(0, 0, 0)
	end
end

function WarcraftyPowerBarColor(unit)
	local powerType = UnitPowerType(unit)
	if ( powerType == 0 ) then
		_G["Warcrafty"..unit.."PowerBar"]:SetStatusBarColor(0, 0, 1)
	end
	if ( powerType == 1 ) then
		_G["Warcrafty"..unit.."PowerBar"]:SetStatusBarColor(1, 0, 0)
	end
	if ( powerType == 2 ) then
		_G["Warcrafty"..unit.."PowerBar"]:SetStatusBarColor(1, .5, .25)
	end
	if ( powerType == 3 ) then
		_G["Warcrafty"..unit.."PowerBar"]:SetStatusBarColor(1, 1, 0)
	end
	if ( powerType == 4 ) then
		_G["Warcrafty"..unit.."PowerBar"]:SetStatusBarColor(0, 1, 1)
	end
	if ( powerType == 5 ) then
		_G["Warcrafty"..unit.."PowerBar"]:SetStatusBarColor(.5, .5, .5)
	end
	if ( powerType == 6 ) then
		_G["Warcrafty"..unit.."PowerBar"]:SetStatusBarColor(0, .82, 1)
	end
end

MAX_TARGET_DEBUFFS = 24
MAX_TARGET_BUFFS = 24

function WarcraftyAuraUpdate(unit)
	local button, buttonName
	local name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable
	local buttonIcon, buttonCount, buttonCooldown, buttonStealable, buttonBorder
	
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
	local numWeaponEnchants = 0
	if (hasMainHandEnchant) then
		numWeaponEnchants = numWeaponEnchants + 1
	end
	if (hasOffHandEnchant) then
		numWeaponEnchants = numWeaponEnchants + 1
	end
	
	local xoffset
	if (unit == "player") then
		xoffset = -185
	elseif (unit == "target") then
		xoffset = 0
	end
	
	numPlayerBuffs = 0
	numTargetBuffs = 0
	
	
	for i=1, MAX_TARGET_BUFFS do
		name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff(unit, i)
		buttonName = "Warcrafty"..unit.."Buff"..i
		button = _G[buttonName]
		
		if ( not button ) then
			if ( not icon ) then
				break
			else
				button = CreateFrame("Button", buttonName, WarcraftyTargetFrame, "WarcraftyBuffButtonTemplate")
				button.unit = unit
			end
		end

		if ( icon ) then
			button:SetID(i)

			-- set the icon
			buttonIcon = _G[buttonName.."Icon"]
			buttonIcon:SetTexture(icon)

			-- set the count
			buttonCount = _G[buttonName.."Count"]
			if ( count > 1 ) then
				buttonCount:SetText(count)
				buttonCount:Show()
			else
				buttonCount:Hide()
			end

			-- Handle cooldowns
			buttonCooldown = _G[buttonName.."Cooldown"]
			if ( duration > 0 ) then
				buttonCooldown:Show()
				CooldownFrame_SetTimer(buttonCooldown, expirationTime - duration, duration, 1)
			else
				buttonCooldown:Hide()
			end

			-- Show stealable frame if the target is not a player, the buff is stealable.
			buttonStealable = _G[buttonName.."Stealable"]
			if ( not playerIsTarget and isStealable ) then
				buttonStealable:Show()
			else
				buttonStealable:Hide()
			end

			-- Set the buff to be big if the buff is cast by the player and the target is not the player
			if (isMine == "player") then
				button:SetWidth(20)
				button:SetHeight(20)
			else
				button:SetWidth(17)
				button:SetHeight(17)
			end
			if (unit == "player") then
				numPlayerBuffs = numPlayerBuffs + 1
			elseif (unit == "target") then
				numTargetBuffs = numTargetBuffs +1
			end
			button:ClearAllPoints()
			if (unit == "player") then
				if ( (i+numWeaponEnchants) <= 8 ) then --put buffs 1-8 in row 1
					button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i+numWeaponEnchants)*20 + xoffset, 70)
					button:Show()
				elseif ( (i+numWeaponEnchants) >= 9 and (i+numWeaponEnchants) <= 16) then --put buffs 8-16 in row 2
					button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", ((i+numWeaponEnchants)-8)*20 + xoffset, 50)
					button:Show()
				elseif ( ((i+numWeaponEnchants) >= 17 and (i+numWeaponEnchants) <= 24) and numPlayerDebuffs <= 8 ) then --put buffs 17-24 in row 3
					button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", ((i+numWeaponEnchants)-16)*20 + xoffset, 30)
					button:Show()
				else
					button:Hide()
				end
			elseif (unit == "target") then
				if ( i <= 8 ) then --put buffs 1-8 in row 1
					button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", i*20 + xoffset, 70)
					button:Show()
				elseif ( i >= 9 and i <= 16) then --put buffs 8-16 in row 2
					button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-8)*20 + xoffset, 50)
					button:Show()
				elseif ( (i >= 17 and i <= 24) and numTargetDebuffs <= 8 ) then --put buffs 17-24 in row 3
					button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-16)*20 + xoffset, 30)
					button:Show()
				else
					button:Hide()
				end
			end
		else
			button:Hide()
		end  
	end

	local color
	numPlayerDebuffs = 0
	numTargetDebuffs = 0
	for i=1, MAX_TARGET_DEBUFFS do
		name, rank, icon, count, debuffType, duration, expirationTime, isMine = UnitDebuff(unit, i)
		buttonName = "Warcrafty"..unit.."Debuff"..i
		button = _G[buttonName]
		if ( not button ) then
			if ( not icon ) then
				break
			else
				button = CreateFrame("Button", buttonName, WarcraftyTargetFrame, "WarcraftyDebuffButtonTemplate")
				button.unit = unit
			end
		end
		if ( icon ) then
			button:SetID(i)

			-- set the icon
			buttonIcon = _G[buttonName.."Icon"]
			buttonIcon:SetTexture(icon)

			-- set the count
			buttonCount = _G[buttonName.."Count"]
			if ( count > 1 ) then
				buttonCount:SetText(count)
				buttonCount:Show()
			else
				buttonCount:Hide()
			end

			-- Handle cooldowns
			buttonCooldown = _G[buttonName.."Cooldown"]
			if ( duration > 0 ) then
				buttonCooldown:Show()
				CooldownFrame_SetTimer(buttonCooldown, expirationTime - duration, duration, 1)
			else
				buttonCooldown:Hide()
			end

			-- set debuff type color
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType]
			else
				color = DebuffTypeColor["none"]
			end
			buttonBorder = _G[buttonName.."Border"]
			buttonBorder:SetVertexColor(color.r, color.g, color.b)

			-- Set the buff to be big if the buff is cast by the player

			if (isMine == "player") then
				button:SetWidth(20)
				button:SetHeight(20)
				buttonBorder:SetWidth(20)
				buttonBorder:SetHeight(20)
			else
				button:SetWidth(17)
				button:SetHeight(17)
				buttonBorder:SetWidth(17)
				buttonBorder:SetHeight(17)
			end

			if (unit == "player") then
				numPlayerDebuffs = numPlayerDebuffs + 1
			elseif (unit == "target") then
				numTargetDebuffs = numTargetDebuffs +1
			end

			button:ClearAllPoints()
			
			if (unit == "player") then
				if ((numPlayerBuffs+numWeaponEnchants) <= 8) then
					if (i <= 8) then --put debuffs 1-8 in row 2
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", i*20 + xoffset, 50)
						button:Show()
					elseif (i > 8 and i <=16) then --put debuffs 9-16 in row 3
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-8)*20 + xoffset, 30)
						button:Show()
					elseif (i >= 16) then --put debuffs 17-24 in row 4 
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-16)*20 + xoffset, 10)
						button:Show()
					end
				elseif ((numPlayerBuffs+numWeaponEnchants) <=16) then
					if (i <= 8) then --put debuffs 1-8 in row 3
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i)*20 + xoffset, 30)
						button:Show()
					elseif (i > 8 and i <=16) then --put debuffs 7-16 in row 4
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-8)*20 + xoffset, 10)
						button:Show()
					end
				elseif ((numPlayerBuffs+numWeaponEnchants) <=24) then
					if (i <= 8 and (numPlayerDebuffs <= 8 and unit == "player") or (numTargetDebuffs <= 8 and unit == "target")) then --put debuffs 1-8 in row 4
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i)*20 + xoffset, 10)
						button:Show()
					elseif (i <= 8 and (numPlayerDebuffs > 8 and unit == "player") or (numTargetDebuffs > 8 and unit == "target")) then --put debuffs 1-8 in row 3
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i)*20 + xoffset, 30)
						button:Show()
					elseif (i <= 16 and (numPlayerDebuffs > 8 and unit == "player") or (numTargetDebuffs > 8 and unit == "target")) then --put debuffs 7-16 in row 4
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-8)*20 + xoffset, 10)
						button:Show()
					end
				else
					button.Hide()
				end
			elseif (unit == "target") then
				if (numTargetBuffs <= 8) then
					if (i <= 8) then --put debuffs 1-8 in row 2
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", i*20 + xoffset, 50)
						button:Show()
					elseif (i > 8 and i <=16) then --put debuffs 9-16 in row 3
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-8)*20 + xoffset, 30)
						button:Show()
					elseif (i >= 16) then --put debuffs 17-24 in row 4 
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-16)*20 + xoffset, 10)
						button:Show()
					end
				elseif (numTargetBuffs <=16) then
					if (i <= 8) then --put debuffs 1-8 in row 3
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i)*20 + xoffset, 30)
						button:Show()
					elseif (i > 8 and i <=16) then --put debuffs 7-16 in row 4
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-8)*20 + xoffset, 10)
						button:Show()
					end
				elseif (numTargetBuffs <=24) then
					if (i <= 8 and (numPlayerDebuffs <= 8 and unit == "player") or (numTargetDebuffs <= 8 and unit == "target")) then --put debuffs 1-8 in row 4
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i)*20 + xoffset, 10)
						button:Show()
					elseif (i <= 8 and (numPlayerDebuffs > 8 and unit == "player") or (numTargetDebuffs > 8 and unit == "target")) then --put debuffs 1-8 in row 3
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i)*20 + xoffset, 30)
						button:Show()
					elseif (i <= 16 and (numPlayerDebuffs > 8 and unit == "player") or (numTargetDebuffs > 8 and unit == "target")) then --put debuffs 7-16 in row 4
						button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i-8)*20 + xoffset, 10)
						button:Show()
					end
				else
					button.Hide()
				end
			end
		else
			button:Hide()
		end
	end
end



function WarcraftyComboFrame_Update()
	local comboPoints = GetComboPoints("player")
	if ( comboPoints > 0 ) then
		if ( not WarcraftyCombo:IsShown() ) then
			WarcraftyCombo:Show()
			UIFrameFadeIn(WarcraftyCombo, 0.3)
		end
		if ( comboPoints == 1 ) then
			WarcraftyComboPoint1Shine:Show()
			UIFrameFlash(WarcraftyComboPoint1Shine, 0.3, 0.4, 0.7, false, 0, 0)
			WarcraftyComboPoint1Highlight:Show()
		end
		if ( comboPoints == 2 ) then
			WarcraftyComboPoint2Shine:Show()
			UIFrameFlash(WarcraftyComboPoint2Shine, 0.3, 0.4, 0.7, false, 0, 0)
			WarcraftyComboPoint1Highlight:Show()
			WarcraftyComboPoint2Highlight:Show()
		end
		if ( comboPoints == 3 ) then
			WarcraftyComboPoint3Shine:Show()
			UIFrameFlash(WarcraftyComboPoint3Shine, 0.3, 0.4, 0.7, false, 0, 0)
			WarcraftyComboPoint1Highlight:Show()
			WarcraftyComboPoint2Highlight:Show()
			WarcraftyComboPoint3Highlight:Show()
		end
		if ( comboPoints == 4 ) then
			WarcraftyComboPoint4Shine:Show()
			UIFrameFlash(WarcraftyComboPoint4Shine, 0.3, 0.4, 0.7, false, 0, 0)
			WarcraftyComboPoint1Highlight:Show()
			WarcraftyComboPoint2Highlight:Show()
			WarcraftyComboPoint3Highlight:Show()
			WarcraftyComboPoint4Highlight:Show()
		end
		if ( comboPoints == 5 ) then
			WarcraftyComboPoint5Shine:Show()
			UIFrameFlash(WarcraftyComboPoint5Shine, 0.3, 0.4, 0.7, false, 0, 0)
			WarcraftyComboPoint1Highlight:Show()
			WarcraftyComboPoint2Highlight:Show()
			WarcraftyComboPoint3Highlight:Show()
			WarcraftyComboPoint4Highlight:Show()
			WarcraftyComboPoint5Highlight:Show()
		end
	else
		WarcraftyComboPoint1Highlight:Hide()
		WarcraftyComboPoint2Highlight:Hide()
		WarcraftyComboPoint3Highlight:Hide()
		WarcraftyComboPoint4Highlight:Hide()
		WarcraftyComboPoint5Highlight:Hide()
		WarcraftyComboPoint1Shine:Hide()
		WarcraftyComboPoint2Shine:Hide()
		WarcraftyComboPoint3Shine:Hide()
		WarcraftyComboPoint4Shine:Hide()
		WarcraftyComboPoint5Shine:Hide()
		WarcraftyCombo:Hide()
	end
end

function WarcraftySetScale()
	WarcraftyPlayerModel:SetScale(WarcraftyConfig.scale)
	WarcraftyPetModel:SetScale(WarcraftyConfig.scale)
	WarcraftyTargetModel:SetScale(WarcraftyConfig.scale)
	WarcraftyTargetTargetModel:SetScale(WarcraftyConfig.scale)
	WarcraftyPlayerFrame:SetScale(WarcraftyConfig.scale)
	WarcraftyTargetFrame:SetScale(WarcraftyConfig.scale)
	WarcraftyPlayerMenu:SetScale(WarcraftyConfig.scale)
	WarcraftyTargetMenu:SetScale(WarcraftyConfig.scale)
	WarcraftyPetMenu:SetScale(WarcraftyConfig.scale)
	WarcraftyCombo:SetScale(WarcraftyConfig.scale)
	WarcraftyBarFrame:SetScale(WarcraftyConfig.scale)
	if (WarcraftyConfig.minimap) then
		WarcraftySetMinimap()
	end
end

function WarcraftySetSkin(skin)
	if (skin == "orc") then
		WarcraftyPlayerTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftyplayerorc")
		WarcraftyTargetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftytargetorc")
		WarcraftyPetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftysmallframeorc")
		WarcraftyTargetTargetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftysmallframeorc")
		if (WarcraftyConfigPerChar.bars == 2) then
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarorc2")
		elseif (WarcraftyConfigPerChar.bars == 3) then
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarorc3")
		else
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarorc1")
		end
	end
	if (skin == "human") then
		WarcraftyPlayerTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftyplayerhuman")
		WarcraftyTargetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftytargethuman")
		WarcraftyPetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftysmallframehuman")
		WarcraftyTargetTargetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftysmallframehuman")
		if (WarcraftyConfigPerChar.bars == 2) then
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarhuman2")
		elseif (WarcraftyConfigPerChar.bars == 3) then
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarhuman3")
		else
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarhuman1")
		end
	end
	
	if (skin == "nightelf") then
		WarcraftyPlayerTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftyplayernightelf")
		WarcraftyTargetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftytargetnightelf")
		WarcraftyPetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftysmallframenightelf")
		WarcraftyTargetTargetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftysmallframenightelf")
		if (WarcraftyConfigPerChar.bars == 2) then
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarnightelf2")
		elseif (WarcraftyConfigPerChar.bars == 3) then
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarnightelf3")
		else
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarnightelf1")
		end
	end
	if (skin == "undead") then
		WarcraftyPlayerTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftyplayerundead")
		WarcraftyTargetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftytargetundead")
		WarcraftyPetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftysmallframeundead")
		WarcraftyTargetTargetTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftysmallframeundead")
		if (WarcraftyConfigPerChar.bars == 2) then
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarundead2")
		elseif (WarcraftyConfigPerChar.bars == 3) then
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarundead3")
		else
			WarcraftyBarTexture:SetTexture("Interface\\AddOns\\Warcrafty\\textures\\warcraftybarundead1")
		end
	end
	
end


function WarcraftySetMinimap()
	MinimapBorderTop:Hide()
	--MinimapToggleButton:Hide()
	MinimapZoneTextButton:SetParent(Minimap)
	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("TOP", Minimap, "TOP", 0, 0)
	MinimapZoneTextButton:SetWidth(Minimap:GetWidth())
	MinimapZoneText:ClearAllPoints()
	MinimapZoneText:SetAllPoints(MinimapZoneTextButton)

	Minimap:SetScale(1.25)
	GameTimeFrame:SetScale(.8)
	MinimapZoomIn:SetScale(.8)
	MinimapZoomOut:SetScale(.8)
	MiniMapTracking:SetScale(.8)
	MiniMapBattlefieldFrame:SetScale(.8)
	MiniMapMailFrame:SetScale(.8)
	
	MinimapZoomIn:ClearAllPoints()
	MinimapZoomOut:ClearAllPoints()
	MinimapZoomIn:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -467, 40)
	MinimapZoomOut:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -467, 5)
	
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -466, 113)
	
	MiniMapWorldMapButton:Hide()
	
	MinimapNorthTag:SetAlpha(0)
	
	GameTimeFrame:ClearAllPoints()
	GameTimeFrame:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -466, 145)
	
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -465, 85)
	
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -498, 159)
	
	TimeManager_LoadUI()
	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -5)
	TimeManagerClockButton:GetRegions():Hide()
	TimeManagerClockButton:Show()
	
	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	MinimapBorder:SetTexture('')
	Minimap:ClearAllPoints()
	Minimap:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -463, 7)
	Minimap:SetWidth(140)
	Minimap:SetHeight(140)
	Minimap:SetFrameLevel(3)
	Minimap:SetFrameStrata("BACKGROUND")
	
	Minimap:SetParent("WarcraftyPlayerFrame")
	MinimapCluster:Hide()
end

function Warcrafty_Spellbar_OnLoad (self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");

	local name = self:GetName();
	
	if (name == "WarcraftyPlayerFrameSpellBar") then
		CastingBarFrame_OnLoad(self, "player", true);
	elseif (name == "WarcraftyTargetFrameSpellBar") then
		CastingBarFrame_OnLoad(self, "target", true);
	end

	local barIcon =_G[name.."Icon"];
	barIcon:Show();
	barIcon:SetWidth(20)
	barIcon:SetHeight(20)
	barIcon:ClearAllPoints()
	barIcon:SetPoint("RIGHT", _G[name], "LEFT", -2, 0)

	local frameText = _G[name.."Text"];
	if ( frameText ) then
		frameText:SetFontObject(SystemFont_Shadow_Small);
		frameText:ClearAllPoints();
		frameText:SetPoint("CENTER", _G[name], "CENTER", 0, 0);
	end

	local frameBorder = _G[name.."Border"];
	if ( frameBorder ) then
		frameBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small");
		frameBorder:SetWidth(188);
		frameBorder:SetHeight(70);
		frameBorder:ClearAllPoints();
		frameBorder:SetPoint("CENTER", _G[name], "CENTER", 0, 0);
	end

	local frameFlash = _G[name.."Flash"];
	if ( frameFlash ) then
		frameFlash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small");
		frameFlash:SetWidth(188);
		frameFlash:SetHeight(70);
		frameFlash:ClearAllPoints();
		frameFlash:SetPoint("CENTER", _G[name], "CENTER", 0, 0);
	end
	
	local frameSpark = _G[name.."Spark"];
	if ( frameSpark ) then
		frameSpark:SetTexture("Interface\CastingBar\UI-CastingBar-Spark");
		frameSpark:SetWidth(60);
		frameSpark:SetHeight(60);
		frameSpark:ClearAllPoints();
		frameSpark:SetPoint("BOTTOM", _G[name], "BOTTOM", 0, -22);
	end
	_G[name.."Text"]:SetWidth(140)

end

function Warcrafty_Spellbar_OnEvent (self, event, ...)
	local arg1 = ...
	--	Check for target specific events
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		-- check if the new target is casting a spell
		local nameChannel  = UnitChannelInfo(self.unit);
		local nameSpell  = UnitCastingInfo(self.unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = "target";
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = "target";
		else
			self.casting = nil;
			self.channeling = nil;
			self:SetMinMaxValues(0, 0);
			self:SetValue(0);
			self:Hide();
			return;
		end
	end
	
	WarcraftyConfig = WarcraftyConfig or {}
	
	if (WarcraftyConfig.castbar) then
		CastingBarFrame_OnEvent(self, event, arg1, select(2, ...));
	end
end


function WarcraftyTempEnchantOnEvent()
	local textureName
	local enchantIndex = 0
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()

	if ( hasOffHandEnchant ) then
		enchantIndex = enchantIndex + 1
		WarcraftyTempEnchant1:SetID(17)	
		textureName = GetInventoryItemTexture("player", 17)
		WarcraftyTempEnchant1Icon:SetTexture(textureName)
		WarcraftyTempEnchant1:ClearAllPoints()
		WarcraftyTempEnchant1:SetPoint("CENTER", WarcraftyPlayerFrame, "BOTTOM", -185+(20*enchantIndex), 70)
		WarcraftyTempEnchant1:Show()
	else
		WarcraftyTempEnchant1:Hide()
	end
	if ( hasMainHandEnchant ) then		
		enchantIndex = enchantIndex + 1
		WarcraftyTempEnchant2:SetID(16)
		textureName = GetInventoryItemTexture("player", 16)
		WarcraftyTempEnchant2Icon:SetTexture(textureName)
		WarcraftyTempEnchant2:ClearAllPoints()
		WarcraftyTempEnchant2:SetPoint("CENTER", WarcraftyPlayerFrame, "BOTTOM", -185+(20*enchantIndex), 70)
		WarcraftyTempEnchant2:Show()
	else
		WarcraftyTempEnchant2:Hide()
	end
end


lastmainHandExpiration = 0
lastoffHandExpiration = 0
tempEnchantDuration = 0
function WarcraftyTempEnchantOnUpdate()
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
	if (hasOffHandEnchant) then
		if (lastoffHandExpiration < offHandExpiration) then
			if ( offHandExpiration > 0 ) then
				WarcraftyTempEnchant1Cooldown:Show()
				CooldownFrame_SetTimer(WarcraftyTempEnchant1Cooldown, (GetTime()-(tempEnchantDuration-offHandExpiration/1000)), tempEnchantDuration, 1)
			else
				WarcraftyTempEnchant1Cooldown:Hide()
			end
		end
		lastoffHandExpiration = offHandExpiration
	end
	if (hasMainHandEnchant) then
		if (lastmainHandExpiration < mainHandExpiration) then
			if ( mainHandExpiration > 0 ) then
				WarcraftyTempEnchant2Cooldown:Show()
				CooldownFrame_SetTimer(WarcraftyTempEnchant2Cooldown, (GetTime()-(tempEnchantDuration-mainHandExpiration/1000)), tempEnchantDuration, 1)
			else
				WarcraftyTempEnchant2Cooldown:Hide()
			end
		end
		lastmainHandExpiration = mainHandExpiration
	end
end


function WarcraftySetBars()
	--TEMP CODE UNTIL I MAKE NEW ACTION BARS
	
	local WarcraftyExitButton = CreateFrame("Frame","ExitButtonHolder",WarcraftyBarFrame)
	WarcraftyExitButton:SetWidth(70)
	WarcraftyExitButton:SetHeight(70)

	WarcraftyExitButton:SetPoint("BOTTOM",385,155) 
	  
	local veb = CreateFrame("BUTTON", "Warcrafty_VehicleExitButton", WarcraftyExitButton, "SecureActionButtonTemplate");
	veb:SetWidth(50)
	veb:SetHeight(50)
	veb:SetPoint("CENTER",0,0)
	veb:RegisterForClicks("AnyUp")
	veb:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	veb:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	veb:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	veb:SetScript("OnClick", function(self) VehicleExit() end)
	veb:RegisterEvent("UNIT_ENTERING_VEHICLE")
	veb:RegisterEvent("UNIT_ENTERED_VEHICLE")
	veb:RegisterEvent("UNIT_EXITING_VEHICLE")
	veb:RegisterEvent("UNIT_EXITED_VEHICLE")
	veb:SetScript("OnEvent", function(self,event,...)
	local arg1 = ...;
		if(((event=="UNIT_ENTERING_VEHICLE") or (event=="UNIT_ENTERED_VEHICLE")) and arg1 == "player") then
			veb:SetAlpha(1)
		elseif(((event=="UNIT_EXITING_VEHICLE") or (event=="UNIT_EXITED_VEHICLE")) and arg1 == "player") then
			veb:SetAlpha(0)
		end
	end)  
	veb:SetAlpha(0)
 

	local i,f

	for i=1, 12 do
		_G["ActionButton"..i]:SetParent("WarcraftyBarFrame");
		_G["ActionButton"..i.."NormalTexture"]:SetTexCoord(0,0,0,0)
		_G["ActionButton"..i.."Icon"]:SetTexCoord(.1,.9,.1,.9)
		_G["BonusActionButton"..i.."NormalTexture"]:SetTexCoord(0,0,0,0)
		_G["BonusActionButton"..i.."Icon"]:SetTexCoord(.1,.9,.1,.9)
		_G["MultiBarBottomRightButton"..i.."NormalTexture"]:SetTexCoord(0,0,0,0)
		_G["MultiBarBottomRightButton"..i.."Icon"]:SetTexCoord(.1,.9,.1,.9)
		_G["MultiBarBottomLeftButton"..i.."NormalTexture"]:SetTexCoord(0,0,0,0)
		_G["MultiBarBottomLeftButton"..i.."Icon"]:SetTexCoord(.1,.9,.1,.9)
	end
	BonusActionBarFrame:SetParent("WarcraftyBarFrame")
	BonusActionBarFrame:SetWidth(0)
	BonusActionBarTexture0:Hide()
	BonusActionBarTexture1:Hide()
	

	
	if (WarcraftyConfigPerChar.bars == 1) then
		ActionButton1:ClearAllPoints()
		ActionButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",355,91);   
		ActionButton5:ClearAllPoints()
		ActionButton5:SetPoint("TOP","ActionButton1","BOTTOM",0,-6);
		ActionButton9:ClearAllPoints()
		ActionButton9:SetPoint("TOP","ActionButton5","BOTTOM",0,-6);
		ActionButton7:ClearAllPoints()
		ActionButton7:SetPoint("LEFT","ActionButton6","RIGHT",6,0);
		for i=1, 12 do
			_G["ActionButton"..i]:SetScale(1.325)
		end	
		
		BonusActionButton1:ClearAllPoints()
		BonusActionButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",355,91);   
		BonusActionButton5:ClearAllPoints()
		BonusActionButton5:SetPoint("TOP","BonusActionButton1","BOTTOM",0,-6);
		BonusActionButton9:ClearAllPoints()
		BonusActionButton9:SetPoint("TOP","BonusActionButton5","BOTTOM",0,-6);
		BonusActionButton7:ClearAllPoints()
		BonusActionButton7:SetPoint("LEFT","BonusActionButton6","RIGHT",6,0);
		BonusActionBarFrame:SetScale(1.325)
	else
		ActionButton1:ClearAllPoints()
		ActionButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",525,52);   
		ActionButton7:ClearAllPoints()
		ActionButton7:SetPoint("TOP","ActionButton1","BOTTOM",0,-6);
		ActionButton5:ClearAllPoints()
		ActionButton5:SetPoint("LEFT","ActionButton4","RIGHT",6,0);
		ActionButton9:ClearAllPoints()
		ActionButton9:SetPoint("LEFT","ActionButton8","RIGHT",6,0);
		for i=1, 12 do
			_G["ActionButton"..i]:SetScale(.88)
		end	
		
		BonusActionButton1:ClearAllPoints()
		BonusActionButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",525,52);   
		BonusActionButton7:ClearAllPoints()
		BonusActionButton7:SetPoint("TOP","BonusActionButton1","BOTTOM",0,-6);
		BonusActionButton5:ClearAllPoints()
		BonusActionButton5:SetPoint("LEFT","BonusActionButton4","RIGHT",6,0);
		BonusActionButton9:ClearAllPoints()
		BonusActionButton9:SetPoint("LEFT","BonusActionButton8","RIGHT",6,0);
		BonusActionBarFrame:SetScale(.88)
	end
	

	ShapeshiftBarFrame:SetParent("WarcraftyBarFrame")
	MultiCastActionBarFrame:SetParent("WarcraftyBarFrame")
	ShapeshiftBarFrame:SetWidth(0)
	ShapeshiftBarLeft:SetAlpha(0)
	ShapeshiftBarMiddle:SetAlpha(0)
	ShapeshiftBarRight:SetAlpha(0)
	local function rABS_MoveShapeshift()
		ShapeshiftButton1NormalTexture:SetAlpha(0)
		ShapeshiftButton2NormalTexture:SetAlpha(0)
		ShapeshiftButton3NormalTexture:SetAlpha(0)
		ShapeshiftButton4NormalTexture:SetAlpha(0)
		ShapeshiftButton5NormalTexture:SetAlpha(0)
		ShapeshiftButton6NormalTexture:SetAlpha(0)
		ShapeshiftButton7NormalTexture:SetAlpha(0)
		ShapeshiftButton1:ClearAllPoints()
		MultiCastActionBarFrame:ClearAllPoints()
		if (WarcraftyConfigPerChar.bars == 1) then
			ShapeshiftButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",440,190)
			MultiCastActionBarFrame:SetPoint("BOTTOMLEFT","WarcraftyBarFrame","BOTTOM",440,190)
		elseif (WarcraftyConfigPerChar.bars == 2) then
			ShapeshiftButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",440,170)
			MultiCastActionBarFrame:SetPoint("BOTTOMLEFT","WarcraftyBarFrame","BOTTOM",440,170)
		else
			ShapeshiftButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",440,245)
			MultiCastActionBarFrame:SetPoint("BOTTOMLEFT","WarcraftyBarFrame","BOTTOM",440,245)
		end
	end
	hooksecurefunc("ShapeshiftBar_Update", rABS_MoveShapeshift);  
	rABS_MoveShapeshift()

	PossessBarFrame:SetParent("WarcraftyBarFrame")
	PossessBackground1:SetAlpha(0)
	PossessBackground2:SetAlpha(0)
	PossessButton1:ClearAllPoints()
	if (WarcraftyConfigPerChar.bars == 1) then
		PossessButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",440,190)
	elseif (WarcraftyConfigPerChar.bars == 2) then
		PossessButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",440,170)
	else
		PossessButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",440,245)
	end
	
	local showBar1, showBar2 = GetActionBarToggles()

	if ((showBar1 == nil) and (showBar2 ~= nil)) then

		MultiBarBottomRight:SetParent("WarcraftyBarFrame")
		MultiBarBottomRightButton1:ClearAllPoints()
		MultiBarBottomRightButton1:SetPoint("BOTTOM", "WarcraftyBarFrame", "BOTTOM", 525,136);
		MultiBarBottomRightButton7:ClearAllPoints()
		MultiBarBottomRightButton7:SetPoint("TOP","MultiBarBottomRightButton1","BOTTOM",0,-6);
		MultiBarBottomRight:SetScale(.88)
	else

		MultiBarBottomLeft:SetParent("WarcraftyBarFrame")
		MultiBarBottomLeftButton1:ClearAllPoints()
		MultiBarBottomLeftButton1:SetPoint("BOTTOM", "WarcraftyBarFrame", "BOTTOM", 525, 136);
		MultiBarBottomLeftButton7:ClearAllPoints()
		MultiBarBottomLeftButton7:SetPoint("TOP","MultiBarBottomLeftButton1","BOTTOM",0,-6);
		MultiBarBottomLeft:SetScale(.88)
			

		MultiBarBottomRight:SetParent("WarcraftyBarFrame")
		MultiBarBottomRightButton1:ClearAllPoints()
		MultiBarBottomRightButton1:SetPoint("BOTTOM", "WarcraftyBarFrame", "BOTTOM", 525, 220);
		MultiBarBottomRightButton7:ClearAllPoints()
		MultiBarBottomRightButton7:SetPoint("TOP","MultiBarBottomRightButton1","BOTTOM",0,-6);
		MultiBarBottomRight:SetScale(.88)
	end

	
  --right bars
  
	local RightBarHolder = CreateFrame("Frame","WarcraftyRightBarHolder",UIParent)
	RightBarHolder:SetWidth(100) -- size the width here
	RightBarHolder:SetHeight(518) -- size the height here
	RightBarHolder:SetPoint("RIGHT",0,0) 
	MultiBarRight:SetParent(RightBarHolder);
	MultiBarLeft:SetParent(RightBarHolder);
	MultiBarRight:ClearAllPoints()
	MultiBarRight:SetPoint("TOPRIGHT",-10,-10)
	MultiBarRight:SetScale(.75)
	MultiBarLeft:SetScale(.75)
	
  --bags
	local BagButtons = {
		MainMenuBarBackpackButton,
		CharacterBag0Slot,
		CharacterBag1Slot,
		CharacterBag2Slot,
		CharacterBag3Slot,
		KeyRingButton,
	}  
	local function WarcraftySetBag()
		for _, f in pairs(BagButtons) do
			f:SetParent("WarcraftyBarFrame");
		end
		MainMenuBarBackpackButton:ClearAllPoints();
		MainMenuBarBackpackButton:SetPoint("BOTTOM", "WarcraftyBarFrame", "BOTTOM", 337, 105);
		CharacterBag0Slot:ClearAllPoints();
		CharacterBag0Slot:SetPoint("LEFT", "MainMenuBarBackpackButton", "RIGHT", 9, 0);
		CharacterBag0Slot:SetScale(1.28);
		CharacterBag1Slot:ClearAllPoints();
		CharacterBag1Slot:SetPoint("TOP", "MainMenuBarBackpackButton", "BOTTOM", 0, -9);
		CharacterBag1Slot:SetScale(1.28);
		CharacterBag2Slot:ClearAllPoints();
		CharacterBag2Slot:SetPoint("LEFT", "CharacterBag1Slot", "RIGHT", 9, 0);
		CharacterBag2Slot:SetScale(1.28);
		CharacterBag3Slot:ClearAllPoints();
		CharacterBag3Slot:SetPoint("TOP", "CharacterBag1Slot", "BOTTOM", 0, -9);
		CharacterBag3Slot:SetScale(1.28);
		KeyRingButton:ClearAllPoints();
		KeyRingButton:SetPoint("LEFT", "CharacterBag3Slot", "RIGHT", 9, 0);

	end  
	WarcraftySetBag();  
		-- KeyRingButtonNormalTexture:SetTexture('Interface\\ContainerFrame\\KeyRing-Bag-Icon')
		-- KeyRingButtonNormalTexture:SetTexCoord(0, 0.9, 0.1, 1)
  
  --mircro menu
	local MicroButtons = {
		CharacterMicroButton,
		SpellbookMicroButton,
		TalentMicroButton,
		AchievementMicroButton,
		QuestLogMicroButton,
		SocialsMicroButton,
		PVPMicroButton,
		LFDMicroButton,
		MainMenuMicroButton,
		HelpMicroButton,
	}  
	local function Warcrafty_MoveMicroButtons(skinName)
		for _, f in pairs(MicroButtons) do
		  f:SetParent("WarcraftyBarFrame");
		end
		CharacterMicroButton:ClearAllPoints();
		CharacterMicroButton:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, 20);
		--SocialsMicroButton:ClearAllPoints();
		--SocialsMicroButton:SetPoint("LEFT", QuestLogMicroButton, "RIGHT", -3, 0);
		UpdateMicroButtons();
	end
	hooksecurefunc("VehicleMenuBar_MoveMicroButtons", Warcrafty_MoveMicroButtons);  
	Warcrafty_MoveMicroButtons();

	PetActionBarFrame:SetParent("WarcraftyBarFrame")
	PetActionBarFrame:SetWidth(0)
	PetActionButton1:ClearAllPoints()
	PetActionButton1:SetPoint("BOTTOM","WarcraftyBarFrame","BOTTOM",-520,130)
	PetActionButton4:ClearAllPoints()
	PetActionButton4:SetPoint("TOP","PetActionButton1","BOTTOM",-20,-10)
	PetActionButton8:ClearAllPoints()
	PetActionButton8:SetPoint("TOP","PetActionButton4","BOTTOM",20,-10)
	PetActionBarFrame:SetScale(.75)
	SlidingActionBarTexture0:SetTexture("")
	SlidingActionBarTexture1:SetTexture("")

	local function Warcrafty_showhideactionbuttons(alpha)
		local f = "ActionButton"
		for i=1, 12 do
			_G[f..i]:SetAlpha(alpha)
		end
	end
	BonusActionBarFrame:HookScript("OnShow", function(self) Warcrafty_showhideactionbuttons(0) end)
	BonusActionBarFrame:HookScript("OnHide", function(self) Warcrafty_showhideactionbuttons(1) end)
	if BonusActionBarFrame:IsShown() then
		Warcrafty_showhideactionbuttons(0)
	end

	MainMenuBar:SetScale(0.001)
	MainMenuBar:SetAlpha(0)
	VehicleMenuBar:SetScale(0.001)
	VehicleMenuBar:SetAlpha(0)

end

lastBars = 0
function WarcraftyActionbarOnUpdate()
	local showBar1, showBar2, showBar3, showBar4 = GetActionBarToggles()
	local bars = 1
	if (showBar1 ~= nil) then
		bars = bars + 1
	else
		showBar1 = 0
	end
	if (showBar2 ~= nil) then
		bars = bars + 1
	else
		showBar2 = 0
	end
	if (showBar3 ~= nil) then
		bars = bars + 1
	end
	if (showBar4 ~= nil) then
		bars = bars + 1
	end
	if (bars ~= lastBars) then
		if showBar1 then
			bars = bars + 1
			showBar1 = 1
	else
			showBar1 = 0
	end
	if showBar2 then
			bars = bars + 1
			showBar2 = 1
	else
			showBar2 = 0
	end
		WarcraftyConfigPerChar.bars = showBar1 + showBar2 + 1
		WarcraftySetBars()
		WarcraftySetSkin(WarcraftyConfigPerChar.skin)
	end
	lastBars = bars
end

function WarcraftyABTest()
	-- CreateFrame("Checkbutton", "ActionTest", UIParent, "ActionBarButtonTemplate")
	-- ActionTest:SetPoint("CENTER")
	-- ActionTest:SetAttribute("type", "action")
	-- ActionTest:SetAttribute("action", 2)
	
	-- ActionTest:SetButtonState("PUSHED");
	

end

TemporaryEnchantFrame:Hide()
TemporaryEnchantFrame:UnregisterAllEvents()
CastingBarFrame:Hide()
CastingBarFrame:UnregisterAllEvents()
PlayerFrame:Hide()
PlayerFrame:UnregisterAllEvents()
ComboFrame:Hide()
ComboFrame:UnregisterAllEvents()
TargetFrame:Hide()
TargetFrame:UnregisterAllEvents()
BuffFrame:Hide()
BuffFrame:UnregisterAllEvents()