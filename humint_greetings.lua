--[[
this script will make NPCs greet the actor upon approaching one of the bases
conditions:
1. the actor is near the base location
2. the location is not empty
3. the location is occupied by a non-hostile NPC squad
4. the actor hasn't been greeted yet
in some cases:
1. check the actor faction
2. check if the location the actor is approaching wasn't set as start location for new playthrough

files with 'st_' in their names are strings from .xml localization files and are not included here
--]]

function on_game_start()

	RegisterScriptCallback("actor_on_update", actor_on_update) 
	
	supported_levels = {
	
	jupiter,
	k00_marsh,
	l01_escape,
	l04_darkvalley,
	l05_bar,
	l07_military,
	pripyat,
	zaton
	
	}
	
  --make sure the callback isn't registered if the level is not supported
  
	current_level = level.name()
	
	for i=1, #supported_levels do
		if current_level ~= supported_levels[i] then
			UnregisterScriptCallback("actor_on_update", actor_on_update)
			printf("HUMINT not a supported level, unreg callback")
		else
			RegisterScriptCallback("actor_on_update", actor_on_update)
			printf("HUMINT is a supported level, reg callback")		
		end		
	end
	
end

--[[ 
greetings for each faction (and for each camp in case of loners and some others) are separated
because different checks may be required

we start with "duty" faction, "bar" location
--]]

function first_greeting_bar()

	-- called from actor_on_update when the actor is near the defined smart and if no infoportion was given before

	-- pda tip message, only one here for now
	local message_bar_duty = game.translate_string("st_duty_bar_first_greet")	
	
	-- smarts related to the duty base
  -- 'smart terrain' is a location within a level
  
	local smart_bar_1 = SIMBOARD.smarts_by_names["bar_zastava"] or SIMBOARD.smarts_by_names["bar_zastava_2"]
				
	if not game_relations.get_gulag_relation_actor("bar_zastava", "enemy") and not game_relations.get_gulag_relation_actor("bar_zastava_2", "enemy") then
				
		if smart_bar_1.faction == "dolg" then -- if the smart is taken by this faction
			
			if actor:character_community() == "actor_army" then -- special greeting for army actor
				actor:give_info_portion("hi_bar_duty_first_greet_done") -- give info (a 'flag') not to repeat the greeting, read from an external file
				news_manager.send_tip(actor, gt("st_duty_bar_first_greet_for_army_"..randnum_1), nil, "ui\\ui_icon_news_trx_dolg", 6000) -- pda message
						
			elseif actor:character_community() == "actor_ecolog" then -- special greeting for ecolog actor
				printf("bar eco cond +")
				printf("info given")
				actor:give_info_portion("hi_bar_duty_first_greet_done") 
				printf("cond2 3rd br +")
				news_manager.send_tip(actor, gt("st_duty_bar_first_greet_for_ecolog_"..randnum_1), nil, "ui\\ui_icon_news_trx_dolg", 6000)
			elseif actor:character_community() == "dolg" then
				--do nothing
			else
				actor:give_info_portion("hi_bar_duty_first_greet_done")
				news_manager.send_tip(actor, message_bar_duty, nil, "ui\\ui_icon_news_trx_dolg", 6000) 
				utils_obj.play_sound("characters_voice\\scenario\\bar_duty_base_enter_1") -- voiceline                                    
			end
						
		end

	end
			
end

-- freedom
-- mil base 
		
function first_greeting_freedom_base()

	local smart_freedom_1 = SIMBOARD.smarts_by_names["mil_smart_terrain_7_8"] or SIMBOARD.smarts_by_names["mil_smart_terrain_7_7"] or SIMBOARD.smarts_by_names["mil_smart_terrain_7_10"] or SIMBOARD.smarts_by_names["mil_smart_terrain_7_12"]

	if not game_relations.get_gulag_relation_actor("mil_smart_terrain_7_7", "enemy") 
	and not game_relations.get_gulag_relation_actor("mil_smart_terrain_7_8", "enemy") 
	and not game_relations.get_gulag_relation_actor("mil_smart_terrain_7_10", "enemy") 
	and not game_relations.get_gulag_relation_actor("mil_smart_terrain_7_12", "enemy") then
			
		if actor:character_community() ~= "freedom" then
			
			if smart_freedom_1.faction == "freedom" then
				actor:give_info_portion("hi_freedombase_freedom_first_greet_done")
				news_manager.send_tip(actor, gt("st_freedom_base_first_greet_"..randnum_1), nil, "ui_icon_news_trx_freedom", 6000) -- randomly choose the message from st_humint.xml
				utils_obj.play_sound("characters_voice\\scenario\\aw_freedom_base_enter_"..randnum_1) -- play the according voiceline -- if message ..._1 is chosen then ..._1 sound file is played
			end	
			
		end
		
	end
		
end

-- clear sky
-- main base
	
function first_greeting_csky_base()

	local smart_csky_base = SIMBOARD.smarts_by_names["mar_smart_terrain_base"] or SIMBOARD.smarts_by_names["mar_smart_terrain_5_12"]
	
	if not game_relations.get_gulag_relation_actor("mar_smart_terrain_base", "enemy")
	or not game_relations.get_gulag_relation_actor("mar_smart_terrain_5_12", "enemy") then
		
		if actor:character_community() ~= "csky" then
			actor:give_info_portion("hi_csky_base_first_greet_done")
			news_manager.send_tip(actor, gt("st_csky_base_first_greet_"..randnum_1), nil, "ui_icon_news_trx_csky", 6000)
			utils_obj.play_sound("characters_voice\\scenario\\stalker_base_enter_"..randnum_1)
		end
										
	end
	
end
		
-- loners
-- rookie village
		
function first_greeting_village()

	local village_smart = SIMBOARD.smarts_by_names["esc_smart_terrain_2_12"]

	if start_location ~= village_smart then -- don't greet on the start location when starting a new game 
	
		if not game_relations.get_gulag_relation_actor("esc_smart_terrain_2_12", "enemy") then 
			actor:give_info_portion("hi_stalker_camp_rookie_village_first_greet_done")
			news_manager.send_tip(actor, gt("st_csky_base_first_greet_"..randnum_1), nil, "ui_icon_news_trx_stalker", 6000)
			utils_obj.play_sound("characters_voice\\scenario\\stalker_base_enter_"..randnum_1)
		end
				
	end
	
end
		
-- pripyat outskirts
	
function first_greeting_launry()

	local laundry_smart = SIMBOARD.smarts_by_names["pri_a16"] or SIMBOARD.smarts_by_names["pri_a16_mlr_copy"]
	
	if not game_relations.get_gulag_relation_actor("pri_a16", "enemy")
	and not game_relations.get_gulag_relation_actor("pri_a16_mlr_copy", "enemy") then
		printf ("outskirts enemy cond +")

		if start_location ~= laundry_smart then
			actor:give_info_portion("hi_stalker_camp_outskirts_first_greet_done")
			news_manager.send_tip(actor, gt("st_csky_base_first_greet_"..randnum_1), nil, "ui_icon_news_trx_stalker", 6000)
			utils_obj.play_sound("characters_voice\\scenario\\stalker_base_enter_"..randnum_1)
		end
				
	end
			
end
				
-- skadovsk	
	
function first_greeting_skadovsk()

	local smart_skadovsk = SIMBOARD.smarts_by_names["zat_stalker_base_smart"]
	
	if not game_relations.get_gulag_relation_actor("zat_stalker_base_smart", "enemy") then 
						
		if start_location ~= smart_skadovsk then
			actor:give_info_portion("hi_stalker_camp_skadovsk_first_greet_done")
			news_manager.send_tip(actor, gt("st_csky_base_first_greet_"..randnum_1), nil, "ui_icon_news_trx_stalker", 6000)
			utils_obj.play_sound("characters_voice\\scenario\\stalker_base_enter_"..randnum_1)
		end
					
	end
			
end

-- jupiter ecolog base

function first_greeting_jup_sci_base()

	local smart_jup_sci_base = SIMBOARD.smarts_by_names["jup_b41"]

	if not game_relations.get_gulag_relation_actor("jup_b41", "enemy") then
	
		if start_location ~= smart_jup_sci_base then
			actor:give_info_portion("hi_stalker_camp_skadovsk_first_greet_done")
			news_manager.send_tip(actor, gt("st_jup_sci_base_first_greet"), nil, "ui_icon_news_trx_stalker", 6000)
			utils_obj.play_sound("characters_voice\\scenario\\yanov_sci_base_enter")
		end
		
	end

end

-- bandits
-- dark valley

function first_greeting_bandit_dv()

	local smart_bandit_dv = SIMBOARD.smarts_by_names["val_smart_terrain_7_3"]
	or SIMBOARD.smarts_by_names["val_smart_terrain_7_4"]
	or SIMBOARD.smarts_by_names["val_smart_terrain_7_5"]
	
	if not game_relations.get_gulag_relation_actor("val_smart_terrain_7_3", "enemy") 
	and not game_relations.get_gulag_relation_actor("val_smart_terrain_7_4", "enemy") 
	and not game_relations.get_gulag_relation_actor("val_smart_terrain_7_5", "enemy") then
	
		if actor:character_community() ~= "bandit" then
			actor:give_info_portion("hi_bandits_dv_first_greet_done")
			news_manager.send_tip(actor, gt("st_bandit_base_first_greet_"..randnum_1), nil, "ui_icon_news_trx_bandit", 6000) 
			utils_obj.play_sound("characters_voice\\scenario\\bandit_base_enter_"..randnum_1)
		end
		
	end

end

-- jupiter camp

function first_greeting_bandit_jup_camp()

	local smart_bandit_jup_camp = SIMBOARD.smarts_by_names["jup_a12"]
	
	if not game_relations.get_gulag_relation_actor("jup_a12", "enemy") then
	
		if start_location ~= smart_bandit_jup_camp then
			actor:give_info_portion("hi_bandits_jup_first_greet_done")
			news_manager.send_tip(actor, gt("st_bandit_base_first_greet_"..randnum_1), nil, "ui_icon_news_trx_bandit", 6000) 
			utils_obj.play_sound("characters_voice\\scenario\\bandit_base_enter_"..randnum_1)
		end
		
	end

end

function actor_on_update()

	actor = db.actor -- technical name of the player
	gt = game.translate_string -- in this case we can pass arguments with more options instead of a plain string
	randnum_1 = math.random(3) -- will be used for random choice of pda tip + voiceline

	config = axr_main.config
	start_location = config:r_value("character_creation","new_game_map")
			
-- check if the actor is close to one of the supported locations
-- each of these only fires once
  
	if (not actor:has_info("hi_bar_duty_first_greet_done")) and (xr_conditions.actor_near_smart(nil,nil,{"bar_zastava"}) or xr_conditions.actor_near_smart(nil,nil,{"bar_zastava_2"})) then
		first_greeting_bar()
		UnregisterScriptCallback("actor_on_update", actor_on_update) -- to make sure greeting is not repeated/looped
	end
	
	if (not actor:has_info("hi_freedombase_freedom_first_greet_done")) and (xr_conditions.actor_near_smart(nil,nil,{"mil_smart_terrain_7_7"}) or xr_conditions.actor_near_smart(nil,nil,{"mil_smart_terrain_7_8"}) or xr_conditions.actor_near_smart(nil,nil,{"mil_smart_terrain_7_10"}) or xr_conditions.actor_near_smart(nil,nil,{"mil_smart_terrain_7_12"})) then
		first_greeting_freedom_base()
		UnregisterScriptCallback("actor_on_update", actor_on_update)
	end
	
	if (not actor:has_info("hi_csky_base_first_greet_done")) and (xr_conditions.actor_near_smart(nil,nil,{"mar_smart_terrain_base"}))
	or xr_conditions.actor_near_smart(nil,nil,{"mar_smart_terrain_5_12"}) then
		first_greeting_csky_base()
		UnregisterScriptCallback("actor_on_update", actor_on_update)
	end
	
	if not actor:has_info("hi_stalker_camp_rookie_village_first_greet_done") and xr_conditions.actor_near_smart(nil,nil,{"esc_smart_terrain_2_12"}) then
		first_greeting_village()
		UnregisterScriptCallback("actor_on_update", actor_on_update)
	end
	
	if (not actor:has_info("hi_stalker_camp_outskirts_first_greet_done")) and ((xr_conditions.actor_near_smart(nil,nil,{"pri_a16"}) or xr_conditions.actor_near_smart(nil,nil,{"pri_a16_mlr_copy"}))) then
		first_greeting_launry()
		UnregisterScriptCallback("actor_on_update", actor_on_update)
	end
	
	if not actor:has_info("hi_stalker_camp_skadovsk_first_greet_done") and xr_conditions.actor_near_smart(nil,nil,{"zat_stalker_base_smart"}) then
		first_greeting_skadovsk()
		UnregisterScriptCallback("actor_on_update", actor_on_update)
	end
	
	if not actor:has_info("hi_jup_sci_base_first_greet_done") and xr_conditions.actor_near_smart(nil,nil,{"jup_b41"}) then
		first_greeting_jup_sci_base()
		UnregisterScriptCallback("actor_on_update", actor_on_update)
	end
	
	if (not actor:has_info("hi_bandits_dv_first_greet_done")) and (xr_conditions.actor_near_smart(nil,nil,{"val_smart_terrain_7_3"})
	or xr_conditions.actor_near_smart(nil,nil,{"val_smart_terrain_7_4"})
	or xr_conditions.actor_near_smart(nil,nil,{"val_smart_terrain_7_5"})) then
		first_greeting_bandit_dv()
		UnregisterScriptCallback("actor_on_update", actor_on_update)
	end
	
	if not actor:has_info("hi_bandits_jup_first_greet_done") and xr_conditions.actor_near_smart(nil,nil,{"jup_a12"}) then
		first_greeting_bandit_jup_camp()
		UnregisterScriptCallback("actor_on_update", actor_on_update)
	end
	
end

