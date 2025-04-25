SLASH_WARCRAFTY1 = "/warcrafty"
WarcraftyConfig = WarcraftyConfig or {}

local function handler()
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(WarcraftyOptions)
    else
        print("InterfaceOptions_AddCategory is not available!")
    end
end

SlashCmdList["WARCRAFTY"] = handler

-- Event handler to ensure options are added after the addon is loaded
local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Warcrafty" then
        -- Now we can safely add the category to the interface options
        if InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(WarcraftyOptions)
        else
            print("Failed to add category to Interface Options!")
        end
        self:UnregisterEvent("ADDON_LOADED")  -- Remove the event after the addon is loaded
    end
end

-- Create an event frame to listen for ADDON_LOADED
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnEvent)

function round(num, idp)
    if idp and idp > 0 then
        local mult = 10^idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function GameTooltip_SetDefaultAnchor(tooltip, parent, ...)
    if (WarcraftyConfig.tooltip == 1) then
        tooltip:SetOwner(WarcraftyBarFrame, "ANCHOR_TOPRIGHT")
    elseif (WarcraftyConfig.tooltip == 2) then
        tooltip:SetOwner(parent, "ANCHOR_CURSOR")
    end

    -- only call SetBackdropColor if the API still provides it
    if tooltip.SetBackdropColor then
        tooltip:SetBackdropColor(0.15, 0.15, 0.15)
    end
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
	CONTAINER_OFFSET_Y = 230
	local function formatValue(val)
		return (val > 99999) and (math.floor(val / 1000) .. "K") or val
	end

	local playerHealth, playerHealthMax = formatValue(UnitHealth("player")), formatValue(UnitHealthMax("player"))
	local playerPower, playerPowerMax = formatValue(UnitPower("player")), formatValue(UnitPowerMax("player"))
	local targetHealth, targetHealthMax = formatValue(UnitHealth("target")), formatValue(UnitHealthMax("target"))
	local targetPower, targetPowerMax = formatValue(UnitPower("target")), formatValue(UnitPowerMax("target"))

	if WarcraftyConfig.textstyle == 1 then
		WarcraftyPlayerHealthText:SetText(playerHealth .. "/" .. playerHealthMax)
		WarcraftyPlayerPowerText:SetText(playerPower .. "/" .. playerPowerMax)
	elseif WarcraftyConfig.textstyle == 2 then
		WarcraftyPlayerHealthText:SetText(playerHealth)
		WarcraftyPlayerPowerText:SetText(playerPower)
	elseif WarcraftyConfig.textstyle == 3 then
		WarcraftyPlayerHealthText:SetText(" ")
		WarcraftyPlayerPowerText:SetText(" ")
	end

	if WarcraftyConfig.textpercent then
		WarcraftyPlayerHealthText:SetText(WarcraftyPlayerHealthText:GetText() .. " " .. math.floor(UnitHealth("player") / UnitHealthMax("player") * 100) .. "%")
		WarcraftyPlayerPowerText:SetText(WarcraftyPlayerPowerText:GetText() .. " " .. math.floor(UnitPower("player") / UnitPowerMax("player") * 100) .. "%")
	end

	WarcraftyPlayerHealthBar:SetMinMaxValues(0, UnitHealthMax("player"))
	WarcraftyPlayerHealthBar:SetValue(UnitHealth("player"))
	WarcraftyPlayerPowerBar:SetMinMaxValues(0, UnitPowerMax("player"))
	WarcraftyPlayerPowerBar:SetValue(UnitPower("player"))

	if UnitHealth("player") <= 0 and UnitIsConnected("player") then
		WarcraftyPlayerDeadText:Show()
		WarcraftyPlayerHealthText:Hide()
	else
		WarcraftyPlayerDeadText:Hide()
		WarcraftyPlayerHealthText:Show()
	end

	if WarcraftyConfigPerChar.druidbar == true then
		WarcraftyPlayerDruidBar:SetMinMaxValues(0, UnitPowerMax("player", 0))
		WarcraftyPlayerDruidBar:SetValue(UnitPower("player", 0))
	end

	if UnitExists("target") then
		if WarcraftyConfig.textstyle == 1 then
			WarcraftyTargetHealthText:SetText(targetHealth .. "/" .. targetHealthMax)
			WarcraftyTargetPowerText:SetText(targetPower .. "/" .. targetPowerMax)
		elseif WarcraftyConfig.textstyle == 2 then
			WarcraftyTargetHealthText:SetText(targetHealth)
			WarcraftyTargetPowerText:SetText(targetPower)
		elseif WarcraftyConfig.textstyle == 3 then
			WarcraftyTargetHealthText:SetText(" ")
			WarcraftyTargetPowerText:SetText(" ")
		end
		if WarcraftyConfig.textpercent then
			WarcraftyTargetHealthText:SetText(WarcraftyTargetHealthText:GetText() .. " " .. math.floor(UnitHealth("target") / UnitHealthMax("target") * 100) .. "%  ")
			WarcraftyTargetPowerText:SetText(WarcraftyTargetPowerText:GetText() .. " " .. math.floor(UnitPower("target") / UnitPowerMax("target") * 100) .. "%  ")
		end
		if targetPowerMax == 0 then WarcraftyTargetPowerText:SetText("") end
		WarcraftyTargetHealthBar:SetMinMaxValues(0, UnitHealthMax("target"))
		WarcraftyTargetHealthBar:SetValue(UnitHealth("target"))
		WarcraftyTargetPowerBar:SetMinMaxValues(0, UnitPowerMax("target"))
		WarcraftyTargetPowerBar:SetValue(UnitPower("target"))
		if UnitIsTapDenied("target") then
			WarcraftyTargetHealthBar:SetStatusBarColor(0.75, 0.75, 0.75)
		else
			WarcraftyTargetHealthBar:SetStatusBarColor(0, 1, 0)
		end
	end

	if UnitHealth("target") <= 0 and UnitIsConnected("target") then
		WarcraftyTargetDeadText:Show()
		WarcraftyTargetHealthText:Hide()
	else
		WarcraftyTargetDeadText:Hide()
		WarcraftyTargetHealthText:Show()
	end

	if UnitExists("pet") then
		if UnitPowerMax("pet") == 0 then
			WarcraftyPetPowerText:Hide()
		else
			WarcraftyPetPowerText:Show()
		end
		WarcraftyPetHealthText:SetText(math.floor(UnitHealth("pet") / UnitHealthMax("pet") * 100) .. "%  ")
		WarcraftyPetPowerText:SetText(math.floor(UnitPower("pet") / UnitPowerMax("pet") * 100) .. "%  ")
		WarcraftyPetHealthBar:SetMinMaxValues(0, UnitHealthMax("pet"))
		WarcraftyPetHealthBar:SetValue(UnitHealth("pet"))
		WarcraftyPetPowerBar:SetMinMaxValues(0, UnitPowerMax("pet"))
		WarcraftyPetPowerBar:SetValue(UnitPower("pet"))
	end

	if UnitExists("targettarget") then
		if UnitPowerMax("targettarget") == 0 then
			WarcraftyTargetTargetPowerText:Hide()
		else
			WarcraftyTargetTargetPowerText:Show()
		end
		WarcraftyTargetTargetHealthText:SetText(math.floor(UnitHealth("targettarget") / UnitHealthMax("targettarget") * 100) .. "%")
		WarcraftyTargetTargetPowerText:SetText(math.floor(UnitPower("targettarget") / UnitPowerMax("targettarget") * 100) .. "%")
		WarcraftyTargetTargetHealthBar:SetMinMaxValues(0, UnitHealthMax("targettarget"))
		WarcraftyTargetTargetHealthBar:SetValue(UnitHealth("targettarget"))
		WarcraftyTargetTargetPowerBar:SetMinMaxValues(0, UnitPowerMax("targettarget"))
		WarcraftyTargetTargetPowerBar:SetValue(UnitPower("targettarget"))
	end

	if WarcraftyConfig.actionbar then
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
C_Timer.After(1, function()
	if RuneFrame and WarcraftyPlayerFrame then
		RuneFrame:ClearAllPoints()
		RuneFrame:SetParent(WarcraftyPlayerFrame)
		RuneFrame:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -88, 150)
	end

	if TotemFrame and WarcraftyPlayerFrame then
		TotemFrame:ClearAllPoints()
		TotemFrame:SetParent(WarcraftyPlayerFrame)
		TotemFrame:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -95, 140)
	end
end)
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
    -- ensure UnitBuff and UnitDebuff exist
    if not UnitBuff or not UnitDebuff then
        return
    end

    local button, buttonName
    local name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable
    local buttonIcon, buttonCount, buttonCooldown, buttonStealable, buttonBorder

    local hasMainHandEnchant, mainHandExpiration, mainHandCharges,
          hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
    local numWeaponEnchants = (hasMainHandEnchant and 1 or 0) + (hasOffHandEnchant and 1 or 0)

    local xoffset = (unit == "player") and -185 or (unit == "target") and 0

    local numPlayerBuffs, numTargetBuffs = 0, 0

    for i = 1, MAX_TARGET_BUFFS do
        -- safely call UnitBuff
        name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff(unit, i)
        if not icon then break end

        buttonName = "Warcrafty" .. unit .. "Buff" .. i
        button = _G[buttonName]
        if not button then
            button = CreateFrame("Button", buttonName, WarcraftyTargetFrame, "WarcraftyBuffButtonTemplate")
            button.unit = unit
        end

        button:SetID(i)
        buttonIcon = _G[buttonName .. "Icon"]
        buttonIcon:SetTexture(icon)

        buttonCount = _G[buttonName .. "Count"]
        if count > 1 then buttonCount:SetText(count); buttonCount:Show() else buttonCount:Hide() end

        buttonCooldown = _G[buttonName .. "Cooldown"]
        if duration and duration > 0 then
            buttonCooldown:Show()
            CooldownFrame_SetTimer(buttonCooldown, expirationTime - duration, duration, 1)
        else
            buttonCooldown:Hide()
        end

        buttonStealable = _G[buttonName .. "Stealable"]
        if isStealable then buttonStealable:Show() else buttonStealable:Hide() end

        if isMine == "player" then button:SetSize(20, 20) else button:SetSize(17, 17) end

        if unit == "player" then numPlayerBuffs = numPlayerBuffs + 1 else numTargetBuffs = numTargetBuffs + 1 end

        button:ClearAllPoints()
        if unit == "player" then
            local idx = i + numWeaponEnchants
            if idx <= 8 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", idx * 20 + xoffset, 70)
            elseif idx <= 16 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (idx - 8) * 20 + xoffset, 50)
            elseif idx <= 24 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (idx - 16) * 20 + xoffset, 30)
            end
        else
            if i <= 8 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", i * 20 + xoffset, 70)
            elseif i <= 16 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i - 8) * 20 + xoffset, 50)
            elseif i <= 24 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i - 16) * 20 + xoffset, 30)
            end
        end
        button:Show()
    end

    -- Debuffs
    local numPlayerDebuffs, numTargetDebuffs = 0, 0
    for i = 1, MAX_TARGET_DEBUFFS do
        name, rank, icon, count, debuffType, duration, expirationTime, isMine = UnitDebuff(unit, i)
        if not icon then break end

        buttonName = "Warcrafty" .. unit .. "Debuff" .. i
        button = _G[buttonName] or CreateFrame("Button", buttonName, WarcraftyTargetFrame, "WarcraftyDebuffButtonTemplate")
        button.unit = unit
        button:SetID(i)

        buttonIcon = _G[buttonName .. "Icon"]
        buttonIcon:SetTexture(icon)

        buttonCount = _G[buttonName .. "Count"]
        if count > 1 then buttonCount:SetText(count); buttonCount:Show() else buttonCount:Hide() end

        buttonCooldown = _G[buttonName .. "Cooldown"]
        if duration and duration > 0 then
            buttonCooldown:Show()
            CooldownFrame_SetTimer(buttonCooldown, expirationTime - duration, duration, 1)
        else
            buttonCooldown:Hide()
        end

        local color = debuffType and DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
        buttonBorder = _G[buttonName .. "Border"]
        buttonBorder:SetVertexColor(color.r, color.g, color.b)

        if isMine == "player" then button:SetSize(20, 20); buttonBorder:SetSize(20, 20)
        else button:SetSize(17, 17); buttonBorder:SetSize(17, 17) end

        if unit == "player" then numPlayerDebuffs = numPlayerDebuffs + 1 else numTargetDebuffs = numTargetDebuffs + 1 end

        button:ClearAllPoints()
        if unit == "player" then
            if i <= 8 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", i * 20 + xoffset, 50)
            elseif i <= 16 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i - 8) * 20 + xoffset, 30)
            elseif i <= 24 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i - 16) * 20 + xoffset, 10)
            end
        else
            if i <= 8 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", i * 20 + xoffset, 50)
            elseif i <= 16 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i - 8) * 20 + xoffset, 30)
            elseif i <= 24 then
                button:SetPoint("CENTER", WarcraftyTargetFrame, "BOTTOM", (i - 16) * 20 + xoffset, 10)
            end
        end
        button:Show()
    end
end




function WarcraftyComboFrame_Update()
    -- get combo points: player on target
    local comboPoints = 0
    if GetComboPoints then
        comboPoints = GetComboPoints("player", "target")
    end

    if comboPoints > 0 then
        if not WarcraftyCombo:IsShown() then
            WarcraftyCombo:Show()
            UIFrameFadeIn(WarcraftyCombo, 0.3)
        end
        if comboPoints >= 1 then
            WarcraftyComboPoint1Shine:Show()
            UIFrameFlash(WarcraftyComboPoint1Shine, 0.3, 0.4, 0.7, false, 0, 0)
            WarcraftyComboPoint1Highlight:Show()
        end
        if comboPoints >= 2 then
            WarcraftyComboPoint2Shine:Show()
            UIFrameFlash(WarcraftyComboPoint2Shine, 0.3, 0.4, 0.7, false, 0, 0)
            WarcraftyComboPoint2Highlight:Show()
        end
        if comboPoints >= 3 then
            WarcraftyComboPoint3Shine:Show()
            UIFrameFlash(WarcraftyComboPoint3Shine, 0.3, 0.4, 0.7, false, 0, 0)
            WarcraftyComboPoint3Highlight:Show()
        end
        if comboPoints >= 4 then
            WarcraftyComboPoint4Shine:Show()
            UIFrameFlash(WarcraftyComboPoint4Shine, 0.3, 0.4, 0.7, false, 0, 0)
            WarcraftyComboPoint4Highlight:Show()
        end
        if comboPoints >= 5 then
            WarcraftyComboPoint5Shine:Show()
            UIFrameFlash(WarcraftyComboPoint5Shine, 0.3, 0.4, 0.7, false, 0, 0)
            WarcraftyComboPoint5Highlight:Show()
        end
    else
        -- hide all combo point indicators
        for i = 1, 5 do
            _G["WarcraftyComboPoint"..i.."Highlight"]:Hide()
            _G["WarcraftyComboPoint"..i.."Shine"]:Hide()
        end
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
	-- Safe hide for removed frames
	if MinimapBorderTop then MinimapBorderTop:Hide() end
	if MinimapBorder then MinimapBorder:SetTexture('') end
	if MiniMapWorldMapButton then MiniMapWorldMapButton:Hide() end
	if MinimapNorthTag then MinimapNorthTag:SetAlpha(0) end

	if MinimapZoneTextButton and Minimap then
		MinimapZoneTextButton:SetParent(Minimap)
		MinimapZoneTextButton:ClearAllPoints()
		MinimapZoneTextButton:SetPoint("TOP", Minimap, "TOP", 0, 0)
		MinimapZoneTextButton:SetWidth(Minimap:GetWidth())
	end

	if MinimapZoneText then
		MinimapZoneText:ClearAllPoints()
		MinimapZoneText:SetAllPoints(MinimapZoneTextButton)
	end

	-- Adjust minimap and related buttons
	Minimap:SetScale(1.25)
	Minimap:SetWidth(140)
	Minimap:SetHeight(140)
	Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
	Minimap:SetFrameLevel(3)
	Minimap:SetFrameStrata("BACKGROUND")
	Minimap:ClearAllPoints()
	Minimap:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -463, 7)
	Minimap:SetParent(WarcraftyPlayerFrame)

	-- Scale and position minimap elements
	if GameTimeFrame then
		GameTimeFrame:SetScale(0.8)
		GameTimeFrame:ClearAllPoints()
		GameTimeFrame:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -466, 145)
	end

	if MinimapZoomIn and MinimapZoomOut then
		MinimapZoomIn:SetScale(0.8)
		MinimapZoomOut:SetScale(0.8)
		MinimapZoomIn:ClearAllPoints()
		MinimapZoomIn:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -467, 40)
		MinimapZoomOut:ClearAllPoints()
		MinimapZoomOut:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -467, 5)
	end

	if MiniMapTracking then
		MiniMapTracking:SetScale(0.8)
		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -466, 113)
	end

	if QueueStatusMinimapButton then
		QueueStatusMinimapButton:SetScale(0.8)
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -465, 85)
	end

	if MiniMapMailFrame then
		MiniMapMailFrame:SetScale(0.8)
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:SetPoint("BOTTOM", WarcraftyPlayerFrame, "BOTTOM", -498, 159)
	end

	-- Time manager clock
		if not C_AddOns.IsAddOnLoaded("Blizzard_TimeManager") then
		C_AddOns.LoadAddOn("Blizzard_TimeManager")
	end
	if TimeManagerClockButton then
		TimeManagerClockButton:ClearAllPoints()
		TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -5)
		local region = TimeManagerClockButton:GetRegions()
		if region then region:Hide() end
		TimeManagerClockButton:Show()
	end

	-- Hide cluster
	if MinimapCluster then
		MinimapCluster:Hide()
	end
end


function Warcrafty_Spellbar_OnLoad(self)
    -- always watch for target‐changed
    self:RegisterEvent("PLAYER_TARGET_CHANGED")

    -- Determine which unit this spellbar belongs to
    local name = self:GetName()
    local unit
    if name == "WarcraftyPlayerFrameSpellBar" then
        unit = "player"
    elseif name == "WarcraftyTargetFrameSpellBar" then
        unit = "target"
    end

    if unit then
        -- store unit on the frame for event handling
        self.unit = unit
        if CastingBarFrame_OnLoad then
            -- use Blizzard’s default loader if present
            CastingBarFrame_OnLoad(self, unit, true)
        else
            -- fallback: register core spellcast events manually
            local events = {
                "UNIT_SPELLCAST_START",
                "UNIT_SPELLCAST_STOP",
                "UNIT_SPELLCAST_FAILED",
                "UNIT_SPELLCAST_INTERRUPTED",
                "UNIT_SPELLCAST_DELAYED",
                "UNIT_SPELLCAST_CHANNEL_START",
                "UNIT_SPELLCAST_CHANNEL_UPDATE",
                "UNIT_SPELLCAST_CHANNEL_STOP",
            }
            for _, evt in ipairs(events) do
                self:RegisterUnitEvent(evt, unit)
            end
        end
    end

    -- Icon
    local barIcon = _G[name .. "Icon"]
    if barIcon then
        barIcon:Show()
        barIcon:SetWidth(20)
        barIcon:SetHeight(20)
        barIcon:ClearAllPoints()
        barIcon:SetPoint("RIGHT", _G[name], "LEFT", -2, 0)
    end

    -- Cast time text
    local frameText = _G[name .. "Text"]
    if frameText then
        frameText:SetFontObject(SystemFont_Shadow_Small)
        frameText:ClearAllPoints()
        frameText:SetPoint("CENTER", _G[name], "CENTER", 0, 0)
        frameText:SetWidth(140)
    end

    -- Border
    local frameBorder = _G[name .. "Border"]
    if frameBorder then
        frameBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small")
        frameBorder:SetWidth(188)
        frameBorder:SetHeight(70)
        frameBorder:ClearAllPoints()
        frameBorder:SetPoint("CENTER", _G[name], "CENTER", 0, 0)
    end

    -- Flash effect
    local frameFlash = _G[name .. "Flash"]
    if frameFlash then
        frameFlash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small")
        frameFlash:SetWidth(188)
        frameFlash:SetHeight(70)
        frameFlash:ClearAllPoints()
        frameFlash:SetPoint("CENTER", _G[name], "CENTER", 0, 0)
    end

    -- Spark effect
    local frameSpark = _G[name .. "Spark"]
    if frameSpark then
        frameSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
        frameSpark:SetWidth(60)
        frameSpark:SetHeight(60)
        frameSpark:ClearAllPoints()
        frameSpark:SetPoint("BOTTOM", _G[name], "BOTTOM", 0, -22)
    end
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

function Warcrafty_AddPanelOptions()
    local WarcraftyOptions = CreateFrame("Frame", "WarcraftyOptions", UIParent)
    WarcraftyOptions.name = "Warcrafty"

    -- Create tabs
    local WarcraftyOptionsTab1 = Warcrafty_CreateTab(WarcraftyOptions, "Tab1", "Global Settings")
    WarcraftyOptionsTab1:SetPoint("TOPLEFT", 10, -2)
    local WarcraftyOptionsTab2 = Warcrafty_CreateTab(WarcraftyOptions, "Tab2", "Character Settings")
    WarcraftyOptionsTab2:SetPoint("TOPLEFT", 125, -2)

    -- Create tab pages
    local WarcraftyOptionsTab1Page = CreateFrame("Frame", "WarcraftyOptionsTab1Page", WarcraftyOptionsTab1)
    local WarcraftyOptionsTab2Page = CreateFrame("Frame", "WarcraftyOptionsTab2Page", WarcraftyOptionsTab2)

    -- Create the frame using the template from XML
    local frame = CreateFrame("Frame", "WarcraftyOptionFrameBoxTemplate", UIParent, "WarcraftyOptionFrameBoxTemplate")
    frame:SetSize(400, 200)  -- Set desired size
    frame:SetPoint("CENTER")  -- Set desired position

    -- Add other components and logic as needed (e.g., tabs, buttons, etc.)
    -- You can now use the created frame and other UI elements

    -- Final setup for the Warcrafty options panel
    PanelTemplates_SetNumTabs(WarcraftyOptions, 2)
    PanelTemplates_SetTab(WarcraftyOptions, WarcraftyOptionsTab1)
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
	if not WarcraftyBarFrame then return end

	local WarcraftyExitButton = CreateFrame("Frame", "ExitButtonHolder", WarcraftyBarFrame)
	WarcraftyExitButton:SetSize(70, 70)
	WarcraftyExitButton:SetPoint("BOTTOM", 385, 155)

	local veb = CreateFrame("BUTTON", "Warcrafty_VehicleExitButton", WarcraftyExitButton, "SecureActionButtonTemplate")
	veb:SetSize(50, 50)
	veb:SetPoint("CENTER", 0, 0)
	veb:RegisterForClicks("AnyUp")
	veb:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	veb:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	veb:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	veb:SetScript("OnClick", function() VehicleExit() end)
	veb:SetAlpha(0)

	veb:RegisterEvent("UNIT_ENTERING_VEHICLE")
	veb:RegisterEvent("UNIT_ENTERED_VEHICLE")
	veb:RegisterEvent("UNIT_EXITING_VEHICLE")
	veb:RegisterEvent("UNIT_EXITED_VEHICLE")
	veb:SetScript("OnEvent", function(self, event, arg1)
		if arg1 == "player" then
			if event == "UNIT_ENTERING_VEHICLE" or event == "UNIT_ENTERED_VEHICLE" then
				self:SetAlpha(1)
			elseif event == "UNIT_EXITING_VEHICLE" or event == "UNIT_EXITED_VEHICLE" then
				self:SetAlpha(0)
			end
		end
	end)

	-- Update action buttons without setting unsafe parents
	for i = 1, 12 do
		local actionButton = _G["ActionButton" .. i]
		if actionButton and WarcraftyBarFrame then
			actionButton:SetScale(1.325)
		end
	end

	if BonusActionBarFrame and WarcraftyBarFrame then
		BonusActionBarFrame:SetParent(WarcraftyBarFrame)
		BonusActionBarFrame:SetWidth(0)
		BonusActionBarFrame:SetShown(WarcraftyConfigPerChar.bars == 1)
		if BonusActionBarTexture0 then BonusActionBarTexture0:Hide() end
		if BonusActionBarTexture1 then BonusActionBarTexture1:Hide() end
	end

	-- Remove hook to ShapeshiftBar_Update (no longer exists)
	-- Replaced with a basic frame alignment (placeholder)
	if ShapeshiftBarFrame and MultiCastActionBarFrame then
		ShapeshiftBarFrame:SetParent(WarcraftyBarFrame)
		MultiCastActionBarFrame:SetParent(WarcraftyBarFrame)
	end
end



-- Track last known number of bars
lastBars = 0
function WarcraftyActionbarOnUpdate()
	if not WarcraftyBarFrame or not WarcraftyBarFrame:IsShown() then return end

	local showBar1, showBar2, showBar3, showBar4 = GetActionBarToggles()
	local bars = 1
	if showBar1 then bars = bars + 1 end
	if showBar2 then bars = bars + 1 end
	if showBar3 then bars = bars + 1 end
	if showBar4 then bars = bars + 1 end

	if bars ~= lastBars then
		WarcraftyConfigPerChar.bars = (showBar1 and 1 or 0) + (showBar2 and 1 or 0) + 1
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

-- Manually initialize the temporary enchant buttons (since we removed Blizzard's handler)
function WarcraftyTempEnchantButton_OnLoad(self)
    -- Register any events you need, like PLAYER_ENTERING_WORLD, UNIT_INVENTORY_CHANGED, etc.
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- Add any other initialization here, like updating textures or cooldowns
end

-- Handle the events for the temp enchant button
function WarcraftyTempEnchant_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Logic for setting up or hiding the temporary enchant buttons
        self:Hide()  -- or do other initializations if needed
    elseif event == "UNIT_INVENTORY_CHANGED" then
        -- Update logic when the player's inventory changes (e.g., when temporary enchants expire)
        -- self:Show() or update the enchant icon/cooldown here
    end
end

-- This is where you set the backdrop for your frame
local function setBackdrop(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",  -- Background texture
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  -- Border texture
        tile = true,
        edgeSize = 16,  -- Border size
        tileSize = 16,  -- Tile size
        insets = {left = 5, right = 5, top = 5, bottom = 5}  -- Insets for background padding
    })

    -- You can also set the border and background colors here
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4)  -- Border color
    frame:SetBackdropColor(0.5, 0.5, 0.5)  -- Background color
end


-- Set tex coords for the status bar textures (Player Health Bar and Power Bar)
local healthBar = WarcraftyPlayerHealthBar  -- The status bar object
local texture = healthBar:GetStatusBarTexture()  -- Get the texture

-- Set the texCoords for the texture
texture:SetTexCoord(0, 1, 0, 1)  -- You can adjust the coordinates as needed

local powerBarTexture = WarcraftyPlayerPowerBar:GetStatusBarTexture()  -- Get the power bar texture
powerBarTexture:SetTexCoord(0, 1, 0, 1)  -- Set texture coordinates (you can adjust these values)




if TemporaryEnchantFrame then
    TemporaryEnchantFrame:Hide()
    TemporaryEnchantFrame:UnregisterAllEvents()
end
if CastingBarFrame then
    CastingBarFrame:Hide()
    CastingBarFrame:UnregisterAllEvents()
end
if PlayerFrame and PlayerFrame:IsShown() then
    PlayerFrame:Hide()
    PlayerFrame:UnregisterAllEvents()
end
if ComboFrame then
    ComboFrame:Hide()
    ComboFrame:UnregisterAllEvents()
end
if TargetFrame then
    TargetFrame:Hide()
    TargetFrame:UnregisterAllEvents()
end
if BuffFrame then
    BuffFrame:Hide()
    BuffFrame:UnregisterAllEvents()
end