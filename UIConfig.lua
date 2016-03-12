--------------------------------------------------------------------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------------------------------------------------------------------
local NS = select( 2, ... );
local L = NS.localization;
--------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------------------------------------------------------------------
NS.UI.cfg = {
	--
	mainFrame = {
		width		= 469,
		height		= 450,
		frameStrata	= "MEDIUM",
		frameLevel	= "TOP",
		Init		= function( MainFrame ) end,
		OnShow		= function( MainFrame )
			MainFrame:Reposition();
		end,
		OnHide		= function( MainFrame )
			if MainFrame:GetParent():GetName() == "TradeSkillFrame" then
				-- Runs only to remove from TradeSkillFrame
				MainFrame:SetParent( UIParent );
				MainFrame:Hide(); -- The ELSE code below will run when this fires
			else
				StaticPopup_Hide( "PC_CHARACTER_DELETE" );
			end
		end,
		Reposition = function( MainFrame )
			MainFrame:ClearAllPoints();
			if MainFrame:GetParent():GetName() == "TradeSkillFrame" then
				MainFrame:SetPoint( "LEFT", "$parent", "RIGHT", 0, 0 ); -- TradeSkillFrame
			else
				MainFrame:SetPoint( "CENTER", 0, 0 ); -- UIParent
			end
		end,
	},
	--
	subFrameTabs = {
		{
			-- Monitor
			mainFrameTitle	= NS.title,
			tabText			= "Monitor",
			Init			= function( SubFrame )
				NS.Button( "NameColumnHeaderButton", SubFrame, NAME, {
					template = "PCColumnHeaderButtonTemplate",
					size = { ( 152 + 8 ), 19 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", -2, 0 },
				} );
				NS.Button( "DCQColumnHeaderButton", SubFrame, "" .. L["Daily Cooldowns and Quests"], {
					template = "PCColumnHeaderButtonTemplate",
					size = { 266, 19 },
					setPoint = { "TOPLEFT", "#sibling", "TOPRIGHT", -2, 0 },
				} );
				NS.Button( "RefreshButton", SubFrame, L["Refresh"], {
					size = { 96, 20 },
					setPoint = { "BOTTOMRIGHT", "#sibling", "TOPRIGHT", 2, 7 },
					fontObject = "GameFontNormalSmall",
					OnClick = function()
						SubFrame:Refresh();
						NS.Print( "Monitor tab refreshed" );
					end,
				} );
				local function DCQ_OnClick( skillName, spellName )
					-- Open TradeSkill if not open
					if not TradeSkillFrame or not TradeSkillFrame:IsShown() or IsTradeSkillLinked() or IsTradeSkillGuild() or skillName ~= GetTradeSkillLine() then
						CastSpellByName( skillName ); -- Attempt to open TradeSkillFrame for a known skill of sufficient level
					end
					-- Is TradeSkill open and ready?
					if not TradeSkillFrame or not TradeSkillFrame:IsShown() or not IsTradeSkillReady() or skillName ~= GetTradeSkillLine() then
						return; -- Stop execution
					end
					--
					-- Reset TradeSkillFrame
					--
					-- Clear "Search"
					SetTradeSkillItemNameFilter( "" );
					TradeSkillFrameSearchBox:SetText( "" );
					TradeSkillFrameSearchBox:ClearFocus();
					-- Clear "Filter"
					local haveMaterials = _G["DropDownList1Button1"];
					local hasSkillUp = _G["DropDownList1Button2"];
					if haveMaterials and haveMaterials.checked and haveMaterials.value == CRAFT_IS_MAKEABLE then
						UIDropDownMenuButton_OnClick( haveMaterials ); -- Required to update UI, clears check and filter summary
					end
					if hasSkillUp and hasSkillUp.checked and hasSkillUp.value == TRADESKILL_FILTER_HAS_SKILL_UP then
						UIDropDownMenuButton_OnClick( hasSkillUp ); -- Required to update UI, clears check and filter summary
					end
					TradeSkillOnlyShowMakeable( false ); -- Not really required, but just in case UI DropDownMenu buttons are incorrect
					TradeSkillOnlyShowSkillUps( false ); -- ^
					TradeSkillSetFilter( -1, -1 ); -- Clears all filters below "Have Materials" and "Has Skill Up"
					ExpandTradeSkillSubClass( 0 ); -- Expand Headers
					TradeSkillFrame_Update(); -- Makes several changes made visible in the UI
					CloseDropDownMenus();
					--
					-- Find index for spellName, select and create if found or print error
					--
					local spellIndex;
					for index = 1, GetNumTradeSkills() do
						if spellName == GetTradeSkillInfo( index ) then
							spellIndex = index;
							break;
						end
					end
					if spellIndex then
						TradeSkillFrame_SetSelection( spellIndex ); -- Required to update UI, highlights item in list and changes item displayed at the bottom
						TradeSkillFrame_Update(); -- Update UI after selecting
						DoTradeSkill( spellIndex ); -- Create
					else
						NS.Print( RED_FONT_COLOR_CODE .. string.format( L["Spell \"%s\" not found"], spellName ) .. FONT_COLOR_CODE_CLOSE );
					end
				end
				NS.ScrollFrame( "ScrollFrame", SubFrame, {
					size = { 422, ( 30 * 11 - 5 ) },
					setPoint = { "TOPLEFT", "$parentNameColumnHeaderButton", "BOTTOMLEFT", 1, -3 },
					buttonTemplate = "PCScrollFrameButtonTemplate",
					udpate = {
						numToDisplay = 11,
						buttonHeight = 30,
						alwaysShowScrollBar = true,
						UpdateFunction = function( sf )
							NS.notReady = 0;
							NS.ready = 0;
							-- Count Ready/NotReady and filter out characters monitoring something into items table
							local items = {}; -- Items are characters, in this case
							for _,char in ipairs( NS.db["characters"] ) do
								local monitoring = 0; -- Init monitoring count
								-- Skills
								for i = 1, 2 do
									if char["skills"][i] then
										for cdk,cd in ipairs( NS.skillInfo[char["skills"][i]["name"]].cooldowns ) do
											if char["skills"][i]["cooldowns"][cdk] and char["monitor"][cd.name] then
												monitoring = monitoring + 1;
												local status = ( char["skills"][i]["cooldowns"][cdk] == "complete" and time() < char["resetTime"] ) and "NotReady" or "Ready";
												if status == "NotReady" then
													NS.notReady = NS.notReady + 1;
												else
													NS.ready = NS.ready + 1;
												end
											end
										end
									end
								end
								-- Buildings
								for _,bldg in ipairs( char["buildings"] ) do
									if char["monitor"][bldg["name"]] then
										monitoring = monitoring + 1;
										local status = ( ( ( bldg["cooldown"] and bldg["cooldown"] == "complete" ) or ( bldg["quest"] and  bldg["quest"] == "complete" ) ) and time() < char["resetTime"] ) and "NotReady" or "Ready";
										if status == "NotReady" then
											NS.notReady = NS.notReady + 1;
										else
											NS.ready = NS.ready + 1;
										end
									end
								end
								-- Monitoring?
								if monitoring > 0 then
									table.insert( items, char );
								end
							end
							local numItems = #items;
							local sfn = SubFrame:GetName();
							FauxScrollFrame_Update( sf, numItems, sf.numToDisplay, sf.buttonHeight, nil, nil, nil, nil, nil, nil, sf.alwaysShowScrollBar );
							for num = 1, sf.numToDisplay do
								local bn = sf.buttonName .. num; -- button name
								local b = _G[bn]; -- button
								local k = FauxScrollFrame_GetOffset( sf ) + num; -- key
								b:UnlockHighlight();
								if k <= numItems then
									local DCQButtonOnEnter = function( self, text, line )
										GameTooltip:SetOwner( self, "ANCHOR_RIGHT" );
										GameTooltip:SetText( text );
										if line then
											GameTooltip:AddLine( HIGHLIGHT_FONT_COLOR_CODE .. line .. FONT_COLOR_CODE_CLOSE );
										end
										GameTooltip:Show();
										b:LockHighlight();
									end
									local OnLeave = function( self )
										GameTooltip_Hide();
										b:UnlockHighlight();
									end
									-- Character - Clickable Button
									_G[bn .. "_CharacterText"]:SetText( ( items[k]["name"] == NS.currentCharacter.name and "|TInterface\\FriendsFrame\\StatusIcon-Online:16:16:-2:-1|t" or "" ) .. items[k]["classColorCode"] .. ( NS.db["showCharacterRealms"] and items[k]["name"] or strsplit( "-", items[k]["name"], 2 ) ) .. FONT_COLOR_CODE_CLOSE );
									_G[bn .. "_Character"]:SetScript( "OnClick", function()
										NS.selectedCharacterKey = NS.FindKeyByName( NS.db["characters"], items[k]["name"] ); -- Set clicked character to selected
										NS.UI.MainFrame:ShowTab( 2 ); -- Characters Tab
									end );
									_G[bn .. "_Character"]:SetScript( "OnEnter", function() b:LockHighlight(); end );
									_G[bn .. "_Character"]:SetScript( "OnLeave", OnLeave );
									-- Daily Cooldowns and Quests
									local numDCQ = 0; -- Initialize DCQ button num
									local numDCQNotReady = 0;
									local numDCQReady = 0;
									-- DCQ: Skills
									for i = 1, 2 do
										if items[k]["skills"][i] then
											for cdk,cd in ipairs( NS.skillInfo[items[k]["skills"][i]["name"]].cooldowns ) do
												if items[k]["skills"][i]["cooldowns"][cdk] and items[k]["monitor"][cd.name] then
													numDCQ = numDCQ + 1;
													-- Clickable Button w/Icon
													_G[bn .. "_DCQ_" .. numDCQ]:SetNormalTexture( cd.icon );
													if items[k]["name"] == NS.currentCharacter.name then
														_G[bn .. "_DCQ_" .. numDCQ]:SetScript( "OnClick", function() DCQ_OnClick( items[k]["skills"][i]["name"], cd.name ); end );
													else
														_G[bn .. "_DCQ_" .. numDCQ]:SetScript( "OnClick", nil );
													end
													_G[bn .. "_DCQ_" .. numDCQ]:SetScript( "OnEnter", function( self ) DCQButtonOnEnter( self, cd.name, self:GetScript( "OnClick" ) and L["Click to Create"] or nil ); end );
													_G[bn .. "_DCQ_" .. numDCQ]:SetScript( "OnLeave", OnLeave );
													-- Status Icon
													local status = ( items[k]["skills"][i]["cooldowns"][cdk] == "complete" and time() < items[k]["resetTime"] ) and "NotReady" or "Ready";
													if status == "NotReady" then
														numDCQNotReady = numDCQNotReady + 1;
													else
														numDCQReady = numDCQReady + 1;
													end
													_G[bn .. "_DCQ_" .. numDCQ .. "_Status"]:SetTexture( "Interface\\RAIDFRAME\\ReadyCheck-" .. status );
													--
													_G[bn .. "_DCQ_" .. numDCQ]:Show();
												end
											end
										end
									end
									-- DCQ: Buildings
									for _,bldg in ipairs( items[k]["buildings"] ) do
										if items[k]["monitor"][bldg["name"]] then
											numDCQ = numDCQ + 1;
											-- Cooldown/Quest - Determines values used for Clickable Button
											local questIndex, icon, spellName, add2Tooltip;
											if bldg["cooldown"] then
												-- Cooldown
												icon = NS.buildingInfo[bldg["name"]].cooldown.icon;
												spellName = NS.buildingInfo[bldg["name"]].cooldown.name;
												add2Tooltip = " - " .. spellName;
											elseif bldg["quest"] then
												-- Quest
												questIndex = type( bldg["quest"] ) == "number" and bldg["quest"] or nil;
												icon = ( questIndex and NS.buildingInfo[bldg["name"]].quests[questIndex].icon ) and NS.buildingInfo[bldg["name"]].quests[questIndex].icon or NS.buildingInfo[bldg["name"]].icon;
												spellName = ( questIndex and NS.buildingInfo[bldg["name"]].quests[questIndex].name ) and NS.buildingInfo[bldg["name"]].quests[questIndex].name or nil;
												add2Tooltip = questIndex and " - " .. NS.buildingInfo[bldg["name"]].quests[questIndex].title or "";
											end
											-- Clickable Button w/Icon
											_G[bn .. "_DCQ_" .. numDCQ]:SetNormalTexture( icon );
											if spellName and items[k]["name"] == NS.currentCharacter.name then
												_G[bn .. "_DCQ_" .. numDCQ]:SetScript( "OnClick", function() DCQ_OnClick( NS.buildingInfo[bldg["name"]].skillName, spellName ); end );
											else
												_G[bn .. "_DCQ_" .. numDCQ]:SetScript( "OnClick", nil );
											end
											_G[bn .. "_DCQ_" .. numDCQ]:SetScript( "OnEnter", function( self ) DCQButtonOnEnter( self, ( bldg["name"] .. add2Tooltip ), self:GetScript( "OnClick" ) and L["Click to Create"] or nil ); end );
											_G[bn .. "_DCQ_" .. numDCQ]:SetScript( "OnLeave", OnLeave );
											-- Status Icon
											local status = ( ( ( bldg["cooldown"] and bldg["cooldown"] == "complete" ) or ( bldg["quest"] and  bldg["quest"] == "complete" ) ) and time() < items[k]["resetTime"] ) and "NotReady" or "Ready";
											if status == "NotReady" then
												numDCQNotReady = numDCQNotReady + 1;
											else
												numDCQReady = numDCQReady + 1;
											end
											_G[bn .. "_DCQ_" .. numDCQ .. "_Status"]:SetTexture( "Interface\\RAIDFRAME\\ReadyCheck-" .. status );
											--
											_G[bn .. "_DCQ_" .. numDCQ]:Show();
										end
									end
									-- HighlightBar (BG) Color
									if numDCQ == numDCQNotReady then
										_G[bn .. "_BG"]:SetTexture( "Interface\\Addons\\" .. NS.addon .. "\\HighlightBar-Red" );
									elseif numDCQ == numDCQReady then
										_G[bn .. "_BG"]:SetTexture( "Interface\\Addons\\" .. NS.addon .. "\\HighlightBar-Green" );
									else
										_G[bn .. "_BG"]:SetTexture( "Interface\\Addons\\" .. NS.addon .. "\\HighlightBar-Orange" );
									end
									-- DCQ: Hide unused buttons up to max of 8
									for numDCQ = ( numDCQ + 1 ), 8 do
										_G[bn .. "_DCQ_" .. numDCQ]:Hide();
									end
									--
									b:Show();
								else
									b:Hide();
								end
							end
						end
					},
				} );
				NS.TextFrame( "Footer", SubFrame, "", {
					size = { 450, 16 },
					setPoint = { "BOTTOM", "$parent", "BOTTOM", 0, 12 },
					justifyH = "CENTER",
				} );
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				--
				_G[sfn .. "ScrollFrame"]:Reset();
				_G[sfn .. "FooterText"]:SetText(
					string.format( L["Reset: %s%s|r"], HIGHLIGHT_FONT_COLOR_CODE, NS.SecondsToStrTime( GetQuestResetTime() ) ) .. "     " ..
					string.format( L["|TInterface\\RAIDFRAME\\ReadyCheck-Ready:16|t Ready: %s%d|r     |TInterface\\RAIDFRAME\\ReadyCheck-NotReady:16|t NotReady: %s%d|r"], HIGHLIGHT_FONT_COLOR_CODE, NS.ready, HIGHLIGHT_FONT_COLOR_CODE, NS.notReady )
				);
			end,
		},
		{
			-- Characters
			mainFrameTitle	= NS.title,
			tabText			= "Characters",
			Init			= function( SubFrame )
				NS.TextFrame( "Character", SubFrame, L["Character:"], {
					size = { 64, 16 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
				} );
				NS.DropDownMenu( "CharacterDropDownMenu", SubFrame, {
					setPoint = { "LEFT", "#sibling", "RIGHT", -12, -1 },
					buttons = function()
						local t = {};
						for ck,c in ipairs( NS.db["characters"] ) do
							local cn = NS.db["showCharacterRealms"] and c["name"] or strsplit( "-", c["name"], 2 );
							tinsert( t, { cn, ck } );
						end
						return t;
					end,
					OnClick = function( info )
						NS.selectedCharacterKey = info.value;
						SubFrame:Refresh();
					end,
					width = 195,
				} );
				-- There are 8 total monitor slots per character
				-- So make enough check buttons for all of them
				for i = 1, 8 do
					NS.CheckButton( "MonitorCheckButton" .. i, SubFrame, L[""], {
						setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", ( i == 1 and 16 or 0 ), -1 },
						OnClick = function( checked, cb )
							NS.db["characters"][NS.selectedCharacterKey]["monitor"][cb.monitorName] = checked;
						end,
					} );
				end
				NS.Button( "DeleteCharacterButton", SubFrame, L["Delete Character"], {
					size = { 126, 22 },
					setPoint = { "BOTTOMRIGHT", "$parent", "BOTTOMRIGHT", -8, 8 },
					OnClick = function()
						StaticPopup_Show( "PC_CHARACTER_DELETE", NS.db["characters"][NS.selectedCharacterKey]["name"], nil, { ["ck"] = NS.selectedCharacterKey, ["name"] = NS.db["characters"][NS.selectedCharacterKey]["name"] } );
					end,
				} );
				StaticPopupDialogs["PC_CHARACTER_DELETE"] = {
					text = L["Delete character? %s"];
					button1 = YES,
					button2 = NO,
					OnAccept = function ( self, data )
						if data["ck"] == NS.currentCharacter.key then return end
						-- Delete
						table.remove( NS.db["characters"], data["ck"] );
						NS.Print( RED_FONT_COLOR_CODE .. string.format( L["%s deleted"], data["name"] ) .. FONT_COLOR_CODE_CLOSE );
						-- Reset keys (Exactly like initialize)
						NS.currentCharacter.key = NS.FindKeyByName( NS.db["characters"], NS.currentCharacter.name ); -- Must be reset when a character is deleted because the keys shift up one
						NS.selectedCharacterKey = NS.currentCharacter.key; -- Sets selected character to current character
						-- Refresh
						SubFrame:Refresh();
					end,
					OnCancel = function ( self ) end,
					OnShow = function ( self, data )
						if data["name"] == NS.currentCharacter.name then
							NS.Print( RED_FONT_COLOR_CODE .. L["You cannot delete the current character"] .. FONT_COLOR_CODE_CLOSE );
							self:Hide();
						end
					end,
					showAlert = 1,
					hideOnEscape = 1,
					timeout = 0,
					exclusive = 1,
					whileDead = 1,
				};
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				_G[sfn .. "CharacterDropDownMenu"]:Reset( NS.selectedCharacterKey );
				-- Monitor: Merge Skills and Buildings
				local monitor = {};
				-- Skills
				for i = 1, 2 do
					if NS.db["characters"][NS.selectedCharacterKey]["skills"][i] then
						for cdk,cd in ipairs( NS.skillInfo[NS.db["characters"][NS.selectedCharacterKey]["skills"][i]["name"]].cooldowns ) do
							if NS.db["characters"][NS.selectedCharacterKey]["skills"][i]["cooldowns"][cdk] then
								table.insert( monitor, { name = cd.name, icon = cd.icon } );
							end
						end
					end
				end
				-- Buildings
				for i = 1, #NS.db["characters"][NS.selectedCharacterKey]["buildings"] do
					local buildingName = NS.db["characters"][NS.selectedCharacterKey]["buildings"][i]["name"];
					table.insert( monitor, { name = buildingName, icon = NS.buildingInfo[buildingName].icon } );
				end
				-- Monitor: Initalize and show monitor check buttons for the selected character
				-- Hide any of the 10 check buttons that are unused
				for i = 1, 8 do
					local cbn = sfn .. "MonitorCheckButton" .. i; -- Check Button Name
					if i <= #monitor then
						_G[cbn]:SetChecked( NS.db["characters"][NS.selectedCharacterKey]["monitor"][monitor[i].name] );
						_G[cbn .. "Text"]:SetText( "|T" .. monitor[i].icon .. ":16|t " .. monitor[i].name );
						_G[cbn].monitorName = monitor[i].name; -- Used in OnClick to set monitor boolean
						_G[cbn]:Show();
					else
						_G[cbn]:Hide();
					end
				end
			end,
		},
		{
			-- Options
			mainFrameTitle	= NS.title,
			tabText			= "Options",
			Init			= function( SubFrame )
				NS.TextFrame( "MiscLabel", SubFrame, L["Miscellaneous"], {
					size = { 100, 16 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
				} );
				NS.CheckButton( "ShowMinimapButtonCheckButton", SubFrame, L["Show Minimap Button"], {
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 3, -1 },
					tooltip = L["Show or hide the\nbutton on the Minimap\n\n(Character Specific)"],
					OnClick = function( checked )
						if not checked then
							PCMinimapButton:Hide();
						else
							PCMinimapButton:Show();
						end
					end,
					dbpc = "showMinimapButton",
				} );
				NS.CheckButton( "OpenWithTradeSKillCheckButton", SubFrame, L["Open With TradeSkill"], {
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -1 },
					tooltip = L["Open and close frame\nwith Blizzard TradeSkill UI\n\nIgnored if Linked or Guild\n\n(Character Specific)"],
					dbpc = "openWithTradeSKill",
				} );
				NS.CheckButton( "ShowCharacterRealmsCheckButton", SubFrame, L["Show Character Realms"], {
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -1 },
					tooltip = L["Show or hide\ncharacter realms"],
					db = "showCharacterRealms",
				} );
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				_G[sfn .. "ShowMinimapButtonCheckButton"]:SetChecked( NS.dbpc["showMinimapButton"] );
				_G[sfn .. "OpenWithTradeSKillCheckButton"]:SetChecked( NS.dbpc["openWithTradeSKill"] );
				_G[sfn .. "ShowCharacterRealmsCheckButton"]:SetChecked( NS.db["showCharacterRealms"] );
			end,
		},
		{
			-- Help
			mainFrameTitle	= NS.title,
			tabText			= "Help",
			Init			= function( SubFrame )
				NS.TextFrame( "Description", SubFrame, string.format( L["%s version %s"], NS.title, NS.versionString ), {
					setPoint = {
						{ "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontRedSmall",
				} );
				NS.TextFrame( "SlashCommandsHeader", SubFrame, string.format( L["%sSlash Commands|r"], BATTLENET_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -18 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontNormalLarge",
				} );
				NS.TextFrame( "SlashCommands", SubFrame, string.format( L["%s/pc|r - Open and close this frame"], NORMAL_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontHighlight",
				} );
				NS.TextFrame( "GettingStartedHeader", SubFrame, string.format( L["%sGetting Started|r"], BATTLENET_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -18 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontNormalLarge",
				} );
				NS.TextFrame( "GettingStarted", SubFrame, string.format(
						L["%s1.|r Login to a character you want to monitor.\n" ..
						"%s2.|r Select Characters tab and uncheck what you don't want to monitor.\n" ..
						"%s3.|r Repeat 1-2 for all characters you want included in this addon."],
						NORMAL_FONT_COLOR_CODE, NORMAL_FONT_COLOR_CODE, NORMAL_FONT_COLOR_CODE
					), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontHighlight",
				} );
				NS.TextFrame( "NeedMoreHelpHeader", SubFrame, string.format( L["%sNeed More Help?|r"], BATTLENET_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -18 },
						{ "RIGHT", 0 },
					},
					fontObject = "GameFontNormalLarge",
				} );
				NS.TextFrame( "NeedMoreHelp", SubFrame, string.format(
						L["%sQuestions, comments, and suggestions can be made on Curse.\nPlease submit bug reports on CurseForge.|r\n\n" ..
						"http://www.curse.com/addons/wow/professions-complete\n" ..
						"http://wow.curseforge.com/addons/professions-complete/tickets/"],
						NORMAL_FONT_COLOR_CODE
					), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontHighlight",
				} );
			end,
			Refresh			= function( SubFrame ) return end,
		},
	},
};
