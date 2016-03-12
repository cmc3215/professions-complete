--------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize Variables
--------------------------------------------------------------------------------------------------------------------------------------------
local NS = select( 2, ... );
local L = NS.localization;
--
NS.initialized = false;
NS.updateRequestTime = nil;
--
NS.selectedCharacterKey = nil;
--
NS.currentCharacter = {
	name = UnitName( "player" ) .. "-" .. GetRealmName(),
	race = UnitRace( "player" ),
	sex = UnitSex( "player" ) == 2 and "male" or "female", -- unknown = 1, male = 2, female = 3 / Players will only be male or female
	classColorCode = "|c" .. RAID_CLASS_COLORS[select( 2, UnitClass( "player" ) )].colorStr,
	faction = UnitFactionGroup( "player" ), -- Updated later with character for Pandaren
	key = nil,
};
--
NS.buildingInfo = {
	-- Gem Boutique
	[select( 2, C_Garrison.GetBuildingInfo( 132 ) )] = { icon = "Interface\\ICONS\\inv_misc_gem_01", rank = 2,
		quests = {
			-- Both
			{ questID = 37319, title = L["Jewelcrafting Special Order: Wedding Bands"], name = GetSpellInfo( 170710 ), icon = GetItemIcon( 115993 ) }, -- Glowing Blackrock Band x 2
			{ questID = 37320, title = L["Jewelcrafting Special Order: A Fine Choker"], name = GetSpellInfo( 170709 ), icon = GetItemIcon( 115992 ) }, -- Whispering Iron Choker x 1
			{ questID = 37321, title = L["Jewelcrafting Special Order: A Yellow Brighter Than Gold"], name = GetSpellInfo( 170719 ), icon = GetItemIcon( 115803 ) }, -- Critical Strike Taladite x 1
			{ questID = 37323, title = L["Jewelcrafting Special Order: Blue the Shade of Sky and Sea"], name = GetSpellInfo( 170720 ), icon = GetItemIcon( 115804 ) }, -- Haste Taladite x 2
			{ questID = 37324, title = L["Out of Stock: Blackrock Ore"], icon = GetItemIcon( 109118 ) }, -- Blackrock Ore x 20
			{ questID = 37325, title = L["Out of Stock: True Iron Ore"], icon = GetItemIcon( 109119 ) }, -- True Iron Ore x 20
		},
		skillName = GetSpellInfo( 25229 ), -- Jewelcrafting
	},
	-- Alchemy Lab
	[select( 2, C_Garrison.GetBuildingInfo( 120 ) )] = { icon = "Interface\\ICONS\\trade_alchemy", rank = 2,
		quests = {
			-- Both
			{ questID = 37270 }, -- Alchemy Experiment - Not stored in log, no item to craft
		},
	},
	-- Scribe's Quarters
	[select( 2, C_Garrison.GetBuildingInfo( 130 ) )] = { icon = "Interface\\ICONS\\inv_inscription_tradeskill01", rank = 2,
		cooldown = { spellID = 176513, name = GetSpellInfo( 176513 ), icon = GetItemIcon( 119126 ) }, -- Draenor Merchant Order
		skillName = GetSpellInfo( 45357 ), -- Inscription
	},
	-- Fishing Shack
	[select( 2, C_Garrison.GetBuildingInfo( 135 ) )] = { icon = "Interface\\ICONS\\trade_fishing", rank = 1,
		quests = {
			-- Alliance
			{ questID = 36517, title = L["Abyssal Gulper Eel"], icon = GetItemIcon( 112627 ) }, -- Abyssal Gulper Eel
			{ questID = 36515, title = L["Blackwater Whiptail"], icon = GetItemIcon( 112626 ) }, -- Blackwater Whiptail
			{ questID = 36514, title = L["Blind Lake Sturgeon"], icon = GetItemIcon( 112629 ) }, -- Blind Lake Sturgeon
			{ questID = 36513, title = L[" Fat Sleeper"], icon = GetItemIcon( 112631 ) }, -- Fat Sleeper
			{ questID = 36510, title = L["Fire Ammonite"], icon = GetItemIcon( 112628 ) }, -- Fire Ammonite
			{ questID = 36511, title = L["Jawless Skulker"], icon = GetItemIcon( 112630 ) }, -- Jawless Skulker
			-- Horde
			{ questID = 35075, title = L["Abyssal Gulper Eel"], icon = GetItemIcon( 112627 ) }, -- Abyssal Gulper Eel
			{ questID = 35074, title = L["Blackwater Whiptail"], icon = GetItemIcon( 112626 ) }, -- Blackwater Whiptail
			{ questID = 35073, title = L["Blind Lake Sturgeon"], icon = GetItemIcon( 112629 ) }, -- Blind Lake Sturgeon
			{ questID = 35072, title = L["Fat Sleeper"], icon = GetItemIcon( 112631 ) }, -- Fat Sleeper
			{ questID = 35066, title = L["Fire Ammonite"], icon = GetItemIcon( 112628 ) }, -- Fire Ammonite
			{ questID = 35071, title = L["Jawless Skulker"], icon = GetItemIcon( 112630 ) }, -- Jawless Skulker
		},
	},
};
--
NS.skillInfo = {
	-- Alchemy
	[GetSpellInfo( 2259 )] = { icon = "Interface\\ICONS\\trade_alchemy", maxRank = 700, skillLine = 171,
		cooldowns = {
			{ spellID = 156587, name = GetSpellInfo( 156587 ), icon = GetItemIcon( 108996 ) }, -- Alchemical Catalyst
			{ spellID = 175880, name = GetSpellInfo( 175880 ), icon = GetItemIcon( 118700 ) }, -- Secrets
			{ spellID = 181643, name = GetSpellInfo( 181643 ), icon = GetItemIcon( 118472 ) }, -- Savage Blood
		},
	},
	-- Blacksmithing
	[GetSpellInfo( 2018 )] = { icon = "Interface\\ICONS\\trade_blacksmithing", maxRank = 700, skillLine = 164,
		cooldowns = {
			{ spellID = 171690, name = GetSpellInfo( 171690 ), icon = GetItemIcon( 108257 ) }, -- Truesteel Ingot
			{ spellID = 176090, name = GetSpellInfo( 176090 ), icon = GetItemIcon( 118720 ) }, -- Secrets
		},
	},
	-- Enchanting
	[GetSpellInfo( 7411 )] = { icon = "Interface\\ICONS\\trade_engraving", maxRank = 700, skillLine = 333,
		cooldowns = {
			{ spellID = 169092, name = GetSpellInfo( 169092 ), icon = GetItemIcon( 113588 ) }, -- Temporal Crystal
			{ spellID = 177043, name = GetSpellInfo( 177043 ), icon = GetItemIcon( 119293 ) }, -- Secrets
		},
	},
	-- Engineering
	[GetSpellInfo( 4036 )] = { icon = "Interface\\ICONS\\trade_engineering", maxRank = 700, skillLine = 202,
		cooldowns = {
			{ spellID = 169080, name = GetSpellInfo( 169080 ), icon = GetItemIcon( 111366 ) }, -- Gearspring Parts
			{ spellID = 177054, name = GetSpellInfo( 177054 ), icon = GetItemIcon( 119299 ) }, -- Secrets
		},
	},
	-- Inscription
	[GetSpellInfo( 45357 )] = { icon = "Interface\\ICONS\\inv_inscription_tradeskill01", maxRank = 700, skillLine = 773,
		cooldowns = {
			{ spellID = 169081, name = GetSpellInfo( 169081 ), icon = GetItemIcon( 112377 ) }, -- War Paints
			{ spellID = 177045, name = GetSpellInfo( 177045 ), icon = GetItemIcon( 119297 ) }, -- Secrets
		},
	},
	-- Jewelcrafting
	[GetSpellInfo( 25229 )] = { icon = "Interface\\ICONS\\inv_misc_gem_01", maxRank = 700, skillLine = 755,
		cooldowns = {
			{ spellID = 170700, name = GetSpellInfo( 170700 ), icon = GetItemIcon( 115524 ) }, -- Taladite Crystal
			{ spellID = 176087, name = GetSpellInfo( 176087 ), icon = GetItemIcon( 118723 ) }, -- Secrets
		},
	},
	-- Leatherworking
	[GetSpellInfo( 2108 )] = { icon = "Interface\\ICONS\\inv_misc_armorkit_17", maxRank = 700, skillLine = 165,
		cooldowns = {
			{ spellID = 171391, name = GetSpellInfo( 171391 ), icon = GetItemIcon( 110611 ) }, -- Burnished Leather
			{ spellID = 176089, name = GetSpellInfo( 176089 ), icon = GetItemIcon( 118721 ) }, -- Secrets
		},
	},
	-- Tailoring
	[GetSpellInfo( 3908 )] = { icon = "Interface\\ICONS\\trade_tailoring", maxRank = 700, skillLine = 197,
		cooldowns = {
			{ spellID = 168835, name = GetSpellInfo( 168835 ), icon = GetItemIcon( 111556 ) }, -- Hexweave Cloth
			{ spellID = 176058, name = GetSpellInfo( 176058 ), icon = GetItemIcon( 118722 ) }, -- Secrets
		},
	},
};
--------------------------------------------------------------------------------------------------------------------------------------------
-- SavedVariables(PerCharacter)
--------------------------------------------------------------------------------------------------------------------------------------------
NS.DefaultSavedVariables = function()
	return {
		["version"] = NS.version,
		["characters"] = {},
		["showCharacterRealms"] = true,
	};
end

--
NS.DefaultSavedVariablesPerCharacter = function()
	return {
		["version"] = NS.version,
		["showMinimapButton"] = true,
		["minimapButtonPosition"] = 60,
		["openWithTradeSKill"] = true,
	};
end

--
NS.Upgrade = function()
	local vars = NS.DefaultSavedVariables();
	local version = NS.db["version"];
	-- 1.x
	--if version < 1.x then
		-- No upgrades
	--end
	--
	NS.db["version"] = NS.version;
end

--
NS.UpgradePerCharacter = function()
	local varspercharacter = NS.DefaultSavedVariablesPerCharacter();
	local version = NS.dbpc["version"];
	-- 1.x
	--if version < 1.x then
		-- No upgrades
	--end
	--
	NS.dbpc["version"] = NS.version;
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- Updates
--------------------------------------------------------------------------------------------------------------------------------------------
NS.UpdateCharacter = function()
	local newCharacter = false;
	-- Find/Add Character
	local k = NS.FindKeyByName( NS.db["characters"], NS.currentCharacter.name ) or #NS.db["characters"] + 1;
	if not NS.db["characters"][k] then
		newCharacter = true; -- Flag for sort
		NS.db["characters"][k] = {
			["name"] = NS.currentCharacter.name,					-- No need to update, if name changes, it'll be added as a new character
			["realm"] = GetRealmName(),								-- No need to update, if realm changes, it'll be added as a new character
			["classColorCode"] = NS.currentCharacter.classColorCode,
			--["skills"] = {},										-- Set below each update
			--["buildings"] = {},									-- Set below each update
			["monitor"] = {},										-- Each building and cooldown set below when first added
		};
	end
	-- Faction (Pandaren start neutral)
	NS.currentCharacter.faction = UnitFactionGroup( "player" );
	-- Skills
	NS.db["characters"][k]["skills"] = {}; -- Start fresh
	local skill1, skill2 = GetProfessions();
	local skills = { skill1, skill2 };
	for sk,index in ipairs( skills ) do
		if index then -- can be nil if character doesn't have skill 1 or 2
			local skillName,_,_,maxRank = GetProfessionInfo( index );
			if NS.skillInfo[skillName] and maxRank >= NS.skillInfo[skillName].maxRank then -- Only store skills that have level cap for current expansion
				-- Add Skill
				NS.db["characters"][k]["skills"][sk] = {
					["name"] = skillName,	-- Jewelcrafting, etc.
					["cooldowns"] = {},		-- Set below each update
				};
				-- Add Cooldowns
				for cdk,cd in ipairs( NS.skillInfo[skillName].cooldowns ) do
					NS.db["characters"][k]["skills"][sk]["cooldowns"][cdk] = IsPlayerSpell( cd.spellID ) and ( select( 2, GetSpellCooldown( cd.spellID ) ) > 0 and "complete" or "incomplete" ) or "unknown";
					if NS.db["characters"][k]["monitor"][cd.name] == nil then
						NS.db["characters"][k]["monitor"][cd.name] = true; -- All cooldowns monitored (true) by default, false when unchecked
					end
				end
			end
		end
	end
	-- Buildings
	NS.db["characters"][k]["buildings"] = {}; -- Start fresh
	for _,building in ipairs( C_Garrison.GetBuildings() ) do
		local _,buildingName,_,_,_,rank = C_Garrison.GetOwnedBuildingInfo( building.plotID );
		if NS.buildingInfo[buildingName] and rank >= NS.buildingInfo[buildingName].rank then -- Only store buildings that can complete a daily cooldown/quest
			-- Add Building
			local bk = #NS.db["characters"][k]["buildings"] + 1;
			NS.db["characters"][k]["buildings"][bk] = {
				["name"] = buildingName,	-- Gem Boutique, etc.
				--["cooldown"] = ,			-- Set below each update
				--["quest"] = ,				-- Set below each update
			};
			-- Add Cooldown or Quest
			if NS.buildingInfo[buildingName].cooldown then
				-- Cooldown
				NS.db["characters"][k]["buildings"][bk]["cooldown"] = select( 2, GetSpellCooldown( NS.buildingInfo[buildingName].cooldown.spellID ) ) > 0 and "complete" or "incomplete";
			else
				-- Quest
				for qk,q in ipairs( NS.buildingInfo[buildingName].quests ) do
					if IsQuestFlaggedCompleted( q.questID ) then
						NS.db["characters"][k]["buildings"][bk]["quest"] = "complete"; -- Quest complete
						break; -- End loop
					elseif GetQuestLogIndexByID( q.questID ) > 0 then
						NS.db["characters"][k]["buildings"][bk]["quest"] = qk; -- Quest in log
						break; -- End loop
					else
						NS.db["characters"][k]["buildings"][bk]["quest"] = "incomplete"; -- Quest incomplete, not in log
					end
				end
			end
			if NS.db["characters"][k]["monitor"][buildingName] == nil then
				NS.db["characters"][k]["monitor"][buildingName] = true; -- All buildings monitored (true) by default, false when unchecked
			end
		end
	end
	-- Sort character's buildings by name
	NS.Sort( NS.db["characters"][k]["buildings"], "name", "ASC" );
	-- Reset Time
	NS.db["characters"][k]["resetTime"] = time() + GetQuestResetTime();
	-- Sort Characters by realm and name, but only when adding a new character
	if newCharacter then
		table.sort ( NS.db["characters"],
			function ( char1, char2 )
				if char1["realm"] == char2["realm"] then
					return char1["name"] < char2["name"];
				else
					return char1["realm"] < char2["realm"];
				end
			end
		);
	end
end

--
NS.Update = function( event )
	if NS.updateRequestTime and ( time() - NS.updateRequestTime ) == 0 then return end -- Ignore multiple update requests in the same second
	NS.updateRequestTime = time();
	C_Timer.After( 1, function() -- Delay 1 second to allow time for any changes made to be included in our new data
		NS.UpdateCharacter();
		if NS.UI.SubFrames[1]:IsShown() then
			NS.UI.SubFrames[1]:Refresh();
		end
	end );
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------------------------------------------------------------------
NS.MinimapButton( "PCMinimapButton", "Interface\\ICONS\\inv_misc_enggizmos_swissarmy", {
	dbpc = "minimapButtonPosition",
	tooltip = function()
		GameTooltip:SetText( HIGHLIGHT_FONT_COLOR_CODE .. NS.title .. FONT_COLOR_CODE_CLOSE .. " v" .. NS.versionString );
		GameTooltip:AddLine( L["Left-Click to open and close"] );
		GameTooltip:AddLine( L["Drag to move this button"] );
		GameTooltip:Show();
	end,
	OnLeftClick = function( self )
		NS.SlashCmdHandler();
	end,
} );
--------------------------------------------------------------------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------------------------------------------------------------------
NS.SlashCmdHandler = function( cmd )
	if not NS.initialized then return end
	--
	if NS.UI.MainFrame:IsShown() then
		NS.UI.MainFrame:Hide();
	elseif not cmd or cmd == "" or cmd == "monitor" then
		NS.UI.MainFrame:ShowTab( 1 );
	elseif cmd == "characters" then
		NS.UI.MainFrame:ShowTab( 2 );
	elseif cmd == "options" then
		NS.UI.MainFrame:ShowTab( 3 );
	elseif cmd == "help" then
		NS.UI.MainFrame:ShowTab( 4 );
	else
		NS.UI.MainFrame:ShowTab( 4 );
		NS.Print( L["Unknown command, opening Help"] );
	end
end
--
SLASH_PROFESSIONSCOMPLETE1 = "/professionscomplete";
SLASH_PROFESSIONSCOMPLETE2 = "/pc";
SlashCmdList["PROFESSIONSCOMPLETE"] = function( msg ) NS.SlashCmdHandler( msg ) end;
--------------------------------------------------------------------------------------------------------------------------------------------
-- Event/Hook Handlers
--------------------------------------------------------------------------------------------------------------------------------------------
NS.OnAddonLoaded = function( event ) -- ADDON_LOADED
	if IsAddOnLoaded( NS.addon ) and not NS.db then
		-- SavedVariables
		if not PROFESSIONSCOMPLETE_SAVEDVARIABLES then
			PROFESSIONSCOMPLETE_SAVEDVARIABLES = NS.DefaultSavedVariables();
		end
		-- SavedVariablesPerCharacter
		if not PROFESSIONSCOMPLETE_SAVEDVARIABLESPERCHARACTER then
			PROFESSIONSCOMPLETE_SAVEDVARIABLESPERCHARACTER = NS.DefaultSavedVariablesPerCharacter();
		end
		-- Localize SavedVariables
		NS.db = PROFESSIONSCOMPLETE_SAVEDVARIABLES;
		NS.dbpc = PROFESSIONSCOMPLETE_SAVEDVARIABLESPERCHARACTER;
		-- Upgrade db
		if NS.db["version"] < NS.version then
			NS.Upgrade();
		end
		-- Upgrade dbpc
		if NS.dbpc["version"] < NS.version then
			NS.UpgradePerCharacter();
		end
	elseif IsAddOnLoaded( "Blizzard_TradeSkillUI" ) then
		PCEventsFrame:UnregisterEvent( event );
		TradeSkillFrame:HookScript( "OnShow", function()
			if not IsTradeSkillLinked() and not IsTradeSkillGuild() and NS.dbpc["openWithTradeSKill"] then
				NS.UI.MainFrame:SetParent( TradeSkillFrame ); -- Put into TradeSkillFrame for positioning
				NS.UI.MainFrame:Reposition();
				NS.UI.MainFrame:ShowTab( 1 );
			end
		end );
	end
end

--
NS.OnPlayerLogin = function( event ) -- PLAYER_LOGIN
	PCEventsFrame:UnregisterEvent( event );
	C_Timer.After( 2, function()
		-- Call initial character update directly to avoid delay which would run intialize prematurely
		NS.UpdateCharacter();
		-- Initialize some variables and register events
		NS.currentCharacter.key = NS.FindKeyByName( NS.db["characters"], NS.currentCharacter.name ); -- Must be reset when character is deleted
		NS.selectedCharacterKey = NS.currentCharacter.key; -- Sets selected character to current character
		--
		PCEventsFrame:RegisterEvent( "QUEST_ACCEPTED" );
		PCEventsFrame:RegisterEvent( "QUEST_TURNED_IN" );
		PCEventsFrame:RegisterEvent( "QUEST_REMOVED" );
		PCEventsFrame:RegisterEvent( "CHAT_MSG_TRADESKILLS" );
		PCEventsFrame:RegisterEvent( "GARRISON_BUILDING_PLACED" );
		PCEventsFrame:RegisterEvent( "SKILL_LINES_CHANGED" );
		--
		NS.initialized = true; -- Slash command handler won't open GUI until intialized
	end );
	-- Minimap Button
	PCMinimapButton:UpdatePos(); -- Resets to last drag position
	if not NS.dbpc["showMinimapButton"] then
		PCMinimapButton:Hide(); -- Hide if unchecked in options
	end
end

--
NS.OnChatMsgTradeskills = function( event, ... ) -- CHAT_MSG_TRADESKILLS
	local arg1 = select( 1, ... );
	if not arg1 then return end
	if arg1:match( string.gsub( TRADESKILL_LOG_FIRSTPERSON, "%%s%.", "" ) ) then -- You create %s.
		NS.Update( event );
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- PCEventsFrame
--------------------------------------------------------------------------------------------------------------------------------------------
NS.Frame( "PCEventsFrame", UIParent, {
	topLevel = true,
	OnEvent = function ( self, event, ... )
		if		event == "ADDON_LOADED"				then	NS.OnAddonLoaded( event );
		elseif	event == "PLAYER_LOGIN"				then	NS.OnPlayerLogin( event );
		elseif	event == "QUEST_ACCEPTED"			then	NS.Update( event );
		elseif	event == "QUEST_TURNED_IN"			then	NS.Update( event );
		elseif	event == "QUEST_REMOVED"			then	NS.Update( event );
		elseif	event == "CHAT_MSG_TRADESKILLS"		then	NS.OnChatMsgTradeskills( event, ... );
		elseif	event == "GARRISON_BUILDING_PLACED"	then	NS.Update( event );
		elseif	event == "SKILL_LINES_CHANGED"		then	NS.Update( event );
		end
	end,
	OnLoad = function( self )
		self:RegisterEvent( "ADDON_LOADED" );
		self:RegisterEvent( "PLAYER_LOGIN" );
	end,
} );
