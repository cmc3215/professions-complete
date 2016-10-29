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
NS.selectedSkillLine = nil;
NS.charactersTabItems = {};
--
NS.currentCharacter = {
	name = UnitName( "player" ) .. "-" .. GetRealmName(),
	classColorCode = "|c" .. RAID_CLASS_COLORS[select( 2, UnitClass( "player" ) )].colorStr,
	key = nil,
};
--
NS.professionInfo = {
	-- Alchemy
	[171] = { name = GetSpellInfo( 2259 ),
		cooldowns = {
			{ spellID = 156587, name = GetSpellInfo( 156587 ), itemID = 108996, icon = GetItemIcon( 108996 ) }, -- Alchemical Catalyst
			{ spellID = 175880, name = GetSpellInfo( 175880 ), itemID = 118700, icon = GetItemIcon( 118700 ) }, -- Secrets of Draenor Alchemy
			{ spellID = 213257, name = GetSpellInfo( 213257 ), itemID = 124124, icon = GetItemIcon( 124124 ) }, -- Transmute: Blood of Sargeras
			{ spellID = 213252, name = GetSpellInfo( 213252 ), itemID = 137593, icon = GetItemIcon( 137593 ) }, -- Transmute: Cloth to Herbs
			{ spellID = 213249, name = GetSpellInfo( 213249 ), itemID = 137591, icon = GetItemIcon( 137591 ) }, -- Transmute: Cloth to Skins
			{ spellID = 213254, name = GetSpellInfo( 213254 ), itemID = 137594, icon = GetItemIcon( 137594 ) }, -- Transmute: Fish to Gems
			{ spellID = 78866,  name = GetSpellInfo( 78866 ),  itemID = 54464,  icon = GetItemIcon( 54464 )  },	-- Transmute: Living Elements
			{ spellID = 114780, name = GetSpellInfo( 114780 ), itemID = 72104,  icon = GetItemIcon( 72104 )  },	-- Transmute: Living Steel
			{ spellID = 213255, name = GetSpellInfo( 213255 ), itemID = 137600, icon = GetItemIcon( 137600 ) }, -- Transmute: Meat to Pants
			{ spellID = 213256, name = GetSpellInfo( 213256 ), itemID = 137599, icon = GetItemIcon( 137599 ) }, -- Transmute: Meat to Pet
			{ spellID = 213248, name = GetSpellInfo( 213248 ), itemID = 137590, icon = GetItemIcon( 137590 ) }, -- Transmute: Ore to Cloth
			{ spellID = 213251, name = GetSpellInfo( 213251 ), itemID = 137593, icon = GetItemIcon( 137593 ) }, -- Transmute: Ore to Herbs
			{ spellID = 80244,  name = GetSpellInfo( 80244 ),  itemID = 51950,  icon = GetItemIcon( 51950 )  },	-- Transmute: Pyrium Bar
			{ spellID = 181643, name = GetSpellInfo( 181643 ), itemID = 118472, icon = GetItemIcon( 118472 ) }, -- Transmute: Savage Blood
			{ spellID = 213253, name = GetSpellInfo( 213253 ), itemID = 137593, icon = GetItemIcon( 137593 ) }, -- Transmute: Skins to Herbs
			{ spellID = 213250, name = GetSpellInfo( 213250 ), itemID = 137592, icon = GetItemIcon( 137592 ) }, -- Transmute: Skins to Ore
			{ spellID = 188802, name = GetSpellInfo( 188802 ), itemID = 141323, icon = GetItemIcon( 141323 ) }, -- Wild Transmutation
			{ spellID = 188800, name = GetSpellInfo( 188800 ), itemID = 141323, icon = GetItemIcon( 141323 ) }, -- Wild Transmutation
			{ spellID = 188801, name = GetSpellInfo( 188801 ), itemID = 141323, icon = GetItemIcon( 141323 ) }, -- Wild Transmutation
		},
	},
	-- Blacksmithing
	[164] = { name = GetSpellInfo( 2018 ),
		cooldowns = {
			{ spellID = 143255, name = GetSpellInfo( 143255 ), itemID = 98717,  icon = GetItemIcon( 98717 )  }, -- Balanced Trillium Ingot
			{ spellID = 138646, name = GetSpellInfo( 138646 ), itemID = 94111,  icon = GetItemIcon( 94111 )  }, -- Lightning Steel Ingot
			{ spellID = 176090, name = GetSpellInfo( 176090 ), itemID = 118720, icon = GetItemIcon( 118720 ) }, -- Secrets of Draenor Blacksmithing
			{ spellID = 171690, name = GetSpellInfo( 171690 ), itemID = 108257, icon = GetItemIcon( 108257 ) }, -- Truesteel Ingot
		},
	},
	-- Enchanting
	[333] = { name = GetSpellInfo( 7411 ),
		cooldowns = {
			{ spellID = 169092, name = GetSpellInfo( 169092 ), itemID = 113588, icon = GetItemIcon( 113588 ) }, -- Temporal Crystal
			{ spellID = 177043, name = GetSpellInfo( 177043 ), itemID = 119293, icon = GetItemIcon( 119293 ) }, -- Secrets of Draenor Enchanting
			{ spellID = 116499, name = GetSpellInfo( 116499 ), itemID = 74248,  icon = GetItemIcon( 74248 )  }, -- Sha Crystal
		},
	},
	-- Engineering
	[202] = { name = GetSpellInfo( 4036 ),
		cooldowns = {
			{ spellID = 169080, name = GetSpellInfo( 169080 ), itemID = 111366, icon = GetItemIcon( 111366 ) }, -- Gearspring Parts
			{ spellID = 139176, name = GetSpellInfo( 139176 ), itemID = 94113,  icon = GetItemIcon( 94113 )  }, -- Jard's Peculiar Energy Source
			{ spellID = 177054, name = GetSpellInfo( 177054 ), itemID = 119299, icon = GetItemIcon( 119299 ) }, -- Secrets of Draenor Engineering
		},
	},
	-- Inscription
	[773] = { name = GetSpellInfo( 45357 ),
		cooldowns = {
			{ spellID = 112996, name = GetSpellInfo( 112996 ), itemID = 79731,  icon = GetItemIcon( 79731 )  }, -- Scroll of Wisdom
			{ spellID = 177045, name = GetSpellInfo( 177045 ), itemID = 119297, icon = GetItemIcon( 119297 ) }, -- Secrets of Draenor Inscription
			{ spellID = 169081, name = GetSpellInfo( 169081 ), itemID = 112377, icon = GetItemIcon( 112377 ) }, -- War Paints
		},
	},
	-- Jewelcrafting
	[755] = { name = GetSpellInfo( 25229 ),
		cooldowns = {
			{ spellID = 73478,  name = GetSpellInfo( 73478 ),  itemID = 52304,  icon = GetItemIcon( 52304 )  }, -- Fire Prism
			{ spellID = 131691, name = GetSpellInfo( 131691 ), itemID = 90399,  icon = GetItemIcon( 90399 )  }, -- Imperial Amethyst
			{ spellID = 131686, name = GetSpellInfo( 131686 ), itemID = 90401,  icon = GetItemIcon( 90401 )  }, -- Primordial Ruby
			{ spellID = 131593, name = GetSpellInfo( 131593 ), itemID = 90395,  icon = GetItemIcon( 90395 )  }, -- River's Heart
			{ spellID = 176087, name = GetSpellInfo( 176087 ), itemID = 118723, icon = GetItemIcon( 118723 ) }, -- Secrets of Draenor Jewelcrafting
			{ spellID = 140050, name = GetSpellInfo( 140050 ), itemID = 95469,  icon = GetItemIcon( 95469 )  }, -- Serpent's Heart
			{ spellID = 131695, name = GetSpellInfo( 131695 ), itemID = 90398,  icon = GetItemIcon( 90398 )  }, -- Sun's Radiance
			{ spellID = 170700, name = GetSpellInfo( 170700 ), itemID = 115524, icon = GetItemIcon( 115524 ) }, -- Taladite Crystal
			{ spellID = 131690, name = GetSpellInfo( 131690 ), itemID = 90400,  icon = GetItemIcon( 90400 )  }, -- Vermilion Onyx
			{ spellID = 131688, name = GetSpellInfo( 131688 ), itemID = 90397,  icon = GetItemIcon( 90397 )  }, -- Wild Jade
		},
	},
	-- Leatherworking
	[165] = { name = GetSpellInfo( 2108 ),
		cooldowns = {
			{ spellID = 171391, name = GetSpellInfo( 171391 ), itemID = 110611, icon = GetItemIcon( 110611 ) }, -- Burnished Leather
			{ spellID = 142976, name = GetSpellInfo( 142976 ), itemID = 98617,  icon = GetItemIcon( 98617 )  }, -- Hardened Magnificent Hide
			{ spellID = 140040, name = GetSpellInfo( 140040 ), itemID = 72163,  icon = GetItemIcon( 72163 )  }, -- Magnificence of Leather
			{ spellID = 140041, name = GetSpellInfo( 140041 ), itemID = 72163,  icon = GetItemIcon( 72163 )  }, -- Magnificence of Scales
			{ spellID = 176089, name = GetSpellInfo( 176089 ), itemID = 118721, icon = GetItemIcon( 118721 ) }, -- Secrets of Draenor Leatherworking
		},
	},
	-- Tailoring
	[197] = { name = GetSpellInfo( 3908 ),
		cooldowns = {
			{ spellID = 143011, name = GetSpellInfo( 143011 ), itemID = 98619,  icon = GetItemIcon( 98619 )  }, -- Celestial Cloth
			{ spellID = 75146,  name = GetSpellInfo( 75146 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Azshara
			{ spellID = 75142,  name = GetSpellInfo( 75142 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Deepholm
			{ spellID = 94743,  name = GetSpellInfo( 94743 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Destruction
			{ spellID = 75144,  name = GetSpellInfo( 75144 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Hyjal
			{ spellID = 75145,  name = GetSpellInfo( 75145 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Ragnaros
			{ spellID = 75141,  name = GetSpellInfo( 75141 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Skywall
			{ spellID = 168835, name = GetSpellInfo( 168835 ), itemID = 111556, icon = GetItemIcon( 111556 ) }, -- Hexweave Cloth
			{ spellID = 125557, name = GetSpellInfo( 125557 ), itemID = 92960,  icon = GetItemIcon( 92960 )  }, -- Imperial Silk
			{ spellID = 176058, name = GetSpellInfo( 176058 ), itemID = 118722, icon = GetItemIcon( 118722 ) }, -- Secrets of Draenor Tailoring
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
		["cooldowns"] = ( function()
			local t = {};
			for skillLine,profession in pairs( NS.professionInfo ) do
				t[skillLine] = CopyTable( profession.cooldowns );
			end
			return t;
		end )(),
		["showCharacterRealms"] = true,
		["showDeleteCooldownConfirmDialog"] = true,
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
	-- 2.0
	if version < 2.0 then
		wipe( NS.db["characters"] );
		NS.db["cooldowns"] = vars["cooldowns"];
		NS.db["showDeleteCooldownConfirmDialog"] = vars["showDeleteCooldownConfirmDialog"];
	end
	--
	NS.db["version"] = NS.version;
end
--
NS.UpgradePerCharacter = function()
	local varspercharacter = NS.DefaultSavedVariablesPerCharacter();
	local version = NS.dbpc["version"];
	-- 2.x
	--if version < 2.x then
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
	local k = NS.FindKeyByField( NS.db["characters"], "name", NS.currentCharacter.name ) or #NS.db["characters"] + 1;
	if not NS.db["characters"][k] then
		newCharacter = true; -- Flag for sort
		NS.db["characters"][k] = {
			["name"] = NS.currentCharacter.name,					-- Permanent
			["realm"] = GetRealmName(),								-- Permanent
			["classColorCode"] = NS.currentCharacter.classColorCode,-- Permanent
			["professions"] = {},									-- Reset below every update
			["monitor"] = {},										-- Set below for each known cooldown when first added
		};
	end
	-- Professions
	wipe( NS.db["characters"][k]["professions"] ); -- Start fresh every update
	local p1, p2 = GetProfessions();
	local professions = { p1, p2 };
	local monitorable = {}; -- Used to cleanup monitor table
	for i = 1, 2 do
		if professions[i] then -- Can be nil if character doesn't have profession 1 or 2
			local skillLine = select( 7, GetProfessionInfo( professions[i] ) );
			if NS.db["cooldowns"][skillLine] then -- Make sure profession exist in cooldowns, e.g. Herbalism not added
				-- Add Profession
				NS.db["characters"][k]["professions"][i] = {
					["skillLine"] = skillLine,	-- Number reference for profession, e.g. 171 for Alchemy
					["cooldowns"] = {},			-- Set below each update
				};
				-- Add Cooldowns
				for _,cd in ipairs( NS.db["cooldowns"][skillLine] ) do -- Pull from global cooldowns
					if IsPlayerSpell( cd.spellID ) then -- Only known cooldowns
						local start, duration, enabled = GetSpellCooldown( cd.spellID );
						local cooldownRemaining = ( start > 0 and duration > 0 ) and math.ceil( ( start + duration - GetTime() ) ) or 0;
						NS.db["characters"][k]["professions"][i]["cooldowns"][cd.spellID] = cooldownRemaining;
						if NS.db["characters"][k]["monitor"][cd.spellID] == nil then
							NS.db["characters"][k]["monitor"][cd.spellID] = false; -- NOT monitored (false) by default, true when checked
						end
						monitorable[cd.spellID] = true;
					end
				end
			end
		end
	end
	-- Update Time
	NS.db["characters"][k]["updateTime"] = time();
	--
	if not newCharacter then
		-- Monitor Clean Up, only when NOT new character
		for spellID in pairs( NS.db["characters"][k]["monitor"] ) do
			if not monitorable[spellID] then
				NS.db["characters"][k]["monitor"][spellID] = nil;
			end
		end
	else
		-- Sort Characters by realm and name, only when a new character was added
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
-- Misc
--------------------------------------------------------------------------------------------------------------------------------------------
NS.MinimapButton( "PCMinimapButton", "Interface\\ICONS\\inv_misc_enggizmos_swissarmy", {
	dbpc = "minimapButtonPosition",
	tooltip = function()
		GameTooltip:SetText( HIGHLIGHT_FONT_COLOR_CODE .. NS.title .. FONT_COLOR_CODE_CLOSE );
		GameTooltip:AddLine( L["Left-Click to open and close"] );
		GameTooltip:AddLine( L["Drag to move this button"] );
		GameTooltip:Show();
	end,
	OnLeftClick = function( self )
		NS.SlashCmdHandler();
	end,
} );
--
NS.OpenWithTradeSkill = function( parent )
	if not C_TradeSkillUI.IsTradeSkillLinked() and not C_TradeSkillUI.IsTradeSkillGuild() and NS.dbpc["openWithTradeSKill"] then
		local parent = ( TradeSkillFrame and TradeSkillFrame:IsShown() and TradeSkillFrame ) or ( TSMCraftingTradeSkillFrame and TSMCraftingTradeSkillFrame:IsShown() and TSMCraftingTradeSkillFrame ) or ( SkilletFrame and SkilletFrame:IsShown() and SkilletFrame );
		NS.UI.MainFrame:SetParent( parent ); -- Put into parent for positioning
		NS.UI.MainFrame:Reposition();
		NS.UI.MainFrame:ShowTab( 1 );
	end
end
--
NS.AddCooldown = function( spellID, itemID, skillLine )
	skillLine = skillLine or NS.selectedSkillLine;
	--
	if not spellID or not itemID then
		return nil;
	else
		spellID = tonumber( spellID );
		itemID = tonumber( itemID );
		local name = spellID ~= 0 and GetSpellInfo( spellID ) or nil;
		local icon = itemID ~= 0 and select( 5, GetItemInfoInstant( itemID ) ) or nil;
		if not name or not icon then
			return nil;
		else
			local cooldownKey = NS.FindKeyByField( NS.db["cooldowns"][skillLine], "spellID", spellID );
			local which = cooldownKey and "updated" or "added";
			--
			if not cooldownKey then
				cooldownKey = #NS.db["cooldowns"][skillLine] + 1;
			end
			NS.db["cooldowns"][skillLine][cooldownKey] = { ["spellID"] = spellID, ["name"] = name, ["itemID"] = itemID, ["icon"] = icon };
			NS.Sort( NS.db["cooldowns"][skillLine], "name", "ASC" );
			--
			return which;
		end
	end
end
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
	if not NS.db and IsAddOnLoaded( NS.addon ) then
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
	elseif TradeSkillFrame then
		PCEventsFrame:UnregisterEvent( event );
		TradeSkillFrame:HookScript( "OnShow", NS.OpenWithTradeSkill );
	end
end
--
NS.OnPlayerLogin = function( event ) -- PLAYER_LOGIN
	PCEventsFrame:UnregisterEvent( event );
	C_Timer.After( 2, function()
		-- Call initial character update directly to avoid delay which would run intialize prematurely
		NS.UpdateCharacter();
		-- Initialize some variables and register events
		NS.currentCharacter.key = NS.FindKeyByField( NS.db["characters"], "name", NS.currentCharacter.name ); -- Must be reset when character is deleted
		NS.selectedCharacterKey = NS.currentCharacter.key; -- Sets selected character to current character
		--
		PCEventsFrame:RegisterEvent( "CHAT_MSG_TRADESKILLS" );
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
NS.OnTradeSkillListUpdate = function( event )
	if TSMCraftingTradeSkillFrame then
		PCEventsFrame:UnregisterEvent( event );
		TSMCraftingTradeSkillFrame:HookScript( "OnShow", NS.OpenWithTradeSkill );
		NS.OpenWithTradeSkill( TSMCraftingTradeSkillFrame );
	elseif SkilletFrame then
		PCEventsFrame:UnregisterEvent( event );
		SkilletFrame:HookScript( "OnShow", NS.OpenWithTradeSkill );
		NS.OpenWithTradeSkill( SkilletFrame );
	end
end
--
NS.OnChatMsgTradeskills = function( event, ... ) -- CHAT_MSG_TRADESKILLS
	local arg1 = select( 1, ... );
	if not arg1 then return end
	-- If not English update on every message, otherwise only when player craft detected
	if ( GetLocale() ~= "enUS" and GetLocale() ~= "enGB" ) or string.match( arg1, string.gsub( TRADESKILL_LOG_FIRSTPERSON, "%%s%.", "" ) ) then -- You create %s.
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
		elseif	event == "TRADE_SKILL_LIST_UPDATE"	then	NS.OnTradeSkillListUpdate( event );
		elseif	event == "CHAT_MSG_TRADESKILLS"		then	NS.OnChatMsgTradeskills( event, ... );
		elseif	event == "SKILL_LINES_CHANGED"		then	NS.Update( event );
		end
	end,
	OnLoad = function( self )
		self:RegisterEvent( "ADDON_LOADED" );
		self:RegisterEvent( "PLAYER_LOGIN" );
		self:RegisterEvent( "TRADE_SKILL_LIST_UPDATE" );
	end,
} );
