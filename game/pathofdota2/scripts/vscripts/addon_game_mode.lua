_G.ADDON_FOLDER = debug.getinfo(1,"S").source:sub(2,-37)
_G.PUBLISH_DATA = LoadKeyValues(ADDON_FOLDER:sub(5,-16).."publish_data.txt") or {}
_G.WORKSHOP_TITLE = PUBLISH_DATA.title or "Dota 2 but..."-- LoadKeyValues(debug.getinfo(1,"S").source:sub(7,-53).."publish_data.txt").title 
_G.MAX_LEVEL = 30

_G.GameMode = _G.GameMode or class({})

ALL_ABILITY_EXCEPTIONS = LoadKeyValues('scripts/vscripts/ability_exceptions.txt')
local GEM_EXCEPTIONS = LoadKeyValues('scripts/vscripts/gem_exceptions.txt')

require("internal/utils/util")
require("internal/init")

require("internal/courier") -- EditFilterToCourier called from internal/filters

require("internal/utils/butt_api")
require("internal/utils/custom_gameevents")
require("internal/utils/particles")
require("internal/utils/timers")
require("internal/utils/notifications") -- will test it tomorrow 

require("internal/events")
require("internal/filters")
require("internal/panorama")
require("internal/shortcuts")
require("internal/talents")
require("internal/thinker")
require("internal/xp_modifier")

softRequire("events")
softRequire("filters")
softRequire("settings_butt")
softRequire("settings_misc")
softRequire("startitems")
softRequire("thinker")

function Precache( context )
	FireGameEvent("addon_game_mode_precache",nil)
	PrecacheResource("soundfile", "soundevents/custom_sounds.vsndevts", context)
	PrecacheResource( "particle", "particles/gravity_swirl.vpcf", context )
	PrecacheResource( "particle", "particles/damage_zone_indicator.vpcf", context )
	PrecacheResource( "particle", "particles/orbitals/orbital_ice_trail.vpcf", context )
	PrecacheResource( "particle", "particles/infernal_legion_fire.vpcf", context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

function Spawn()
	FireGameEvent("addon_game_mode_spawn",nil)
	local gmE = GameRules:GetGameModeEntity()

	gmE:SetUseDefaultDOTARuneSpawnLogic(true)
	gmE:SetTowerBackdoorProtectionEnabled(true)
	GameRules:SetShowcaseTime(0)

	FireGameEvent("created_game_mode_entity",{gameModeEntity = gmE})
end

function Activate()
	FireGameEvent("addon_game_mode_activate",nil)
	-- GameRules.GameMode = GameMode()
	-- FireGameEvent("init_game_mode",{})
end

ListenToGameEvent("addon_game_mode_activate", function()
	print( "Dota Butt Template is loaded." )
end, nil)

CustomGameEventManager:RegisterListener( "gem_slot_assigned",  function(_, args)
	
    if IsClient() then
        print( "Client says, gem_slot_assigned" )
    else
        print( "Server says, gem_slot_assigned" )
    end

	local item = EntIndexToHScript( args.item_index )
	local hero = EntIndexToHScript( args.hero_index )
	local playerID = hero:GetPlayerOwnerID()
	-- local is_bot = PlayerResource:GetSteamID( playerID )==0
	local ability_index = args.ability_index
	local ability_name = EntIndexToHScript(ability_index):GetAbilityName()
	local gem_name_old = nil
	local nettable = CustomNetTables:GetTableValue( "gem_slots", tostring(args.hero_index) )
	local allowed = true
	local blacklisted = false
	
	if not nettable then -- create a table with empty slots to inject into the customnettable
		local empty = {}
		CustomNetTables:SetTableValue( "gem_slots", tostring(args.hero_index), empty)
		nettable = empty
	else
		gem_name_old = nettable[ tostring(ability_index) ]
	end

	-- Set new Gem Name for ability slot
	local gem_name = item:GetName():gsub( "item_ability_gem_", "" )
	nettable[ tostring(ability_index) ] = gem_name

	if GEM_EXCEPTIONS["allow_"..gem_name] and GEM_EXCEPTIONS["allow_"..gem_name][ability_name]==nil then
		allowed = false
		Notifications:Bottom(PlayerResource:GetPlayer( playerID ), { text= ability_name .. " is blacklisted for this gem.", duration=3, style={color="red", ["font-size"]="25px", border="none"} } )
		print( ability_name, " is not allowed with this gem.")
	end

	if GEM_EXCEPTIONS["no_"..gem_name] and GEM_EXCEPTIONS["no_"..gem_name][ability_name]~=nil then
		blacklisted = true
		Notifications:Bottom(PlayerResource:GetPlayer( playerID ), { text= ability_name .. " is blacklisted for this gem.", duration=3, style={color="red", ["font-size"]="25px", border="none"} } )
		print( ability_name, " is blacklisted for this gem.")
	end

	-- Check whether gem is allowed for this ability (must either be whitelisted or (else) not blacklisted )
	if allowed and not blacklisted then

		-- Set NetTable value to the new gem name
		CustomNetTables:SetTableValue( "gem_slots", tostring(args.hero_index), nettable )
		print( "After setting table value: " .. CustomNetTables:GetTableValue( "gem_slots", tostring(args.hero_index) )[ tostring( ability_index )] )

		-- Remove gem item from hero
		print( "Remove item from hero: " .. item:GetName() .. ", " .. hero:GetName() )
		hero:RemoveItem(item)
		
		if IsClient() then return end
		
		-- Remove old ability's index from the previous modifier's table
		if gem_name_old then
			local old_mod = hero:FindModifierByName( "modifier_" .. gem_name_old )

			-- clear the ability from the old modifier
			if old_mod~=nil then
				old_mod.ability_data[ ability_name ] = nil
			end
			
			-- If the old ability's index table is empty, the mod should be removed
			if old_mod then
				if next(old_mod.ability_data) == nil then
					print( "Remove modifier from hero: modifier_" .. gem_name_old .. ", " .. hero:GetName() )
					hero:RemoveModifierByName( "modifier_" .. gem_name_old )
				end
			end
		end

		if gem_name ~= "" then
			hero:AddNewModifierButt(hero, nil, "modifier_" .. gem_name, {})

			local mod = hero:FindModifierByName( "modifier_" .. gem_name )
			print("Mod named " .. mod:GetName() .. " was added to " .. hero:GetName())
			mod.ability_data[ ability_name ] = 0
		end
	end

	if gem_name=="second_wind" then
	-- 	Timers:CreateTimer( FrameTime(), function()
		-- local mod = hero:FindModifierByName( "modifier_" .. gem_name )
		-- mod:CheckCharges()
			local ability = hero:FindAbilityByName( ability_name )
	-- 		ability:SetCurrentAbilityCharges( ability:GetCurrentAbilityCharges() )
			
			local max_charges = ability:GetMaxAbilityCharges(ability:GetLevel())
	-- 		local current_charges = ability:GetCurrentAbilityCharges()
	-- 		if current_charges > max_charges then
			ability:SetCurrentAbilityCharges( max_charges-1 )
	-- 		end
	-- 		return nil
	-- 	end)
	end
end)

function OnGemSlotAssignedEvent( event )
end