-- called from internal/filters

-- Filters allow you to do some code on specific events.
-- Whats special about it: you can manipulate some values here.

Filters = class({})
Filters.duplicated_projectiles = {}

function Filters:AbilityTuningValueFilter(event)
	-- called on most abilities for each value
	-- PrintTable(event)
	local ability = event.entindex_ability_const and EntIndexToHScript(event.entindex_ability_const)
	local casterUnit = event.entindex_caster_const and EntIndexToHScript(event.entindex_caster_const)
	local valueName = event.value_name_const -- e.g. duration or area_of_affect
	local value = event.value -- can not get modified with local

	-- --  example
		-- event.value = 10

	return true
end

function Filters:BountyRunePickupFilter(event)
	-- PrintTable(event)
	local playerID = event.player_id_const
	local xp = event.xp_bounty -- can not get modified with local
	local gold = event.gold_bounty -- can not get modified with local

	local heroUnit = playerID and PlayerResource:GetSelectedHeroEntity(playerID)

	-- --  example
		-- event.gold_bounty = 10
		-- event.xp_bounty = 10

	return true
end

function Filters:DamageFilter(event)
    local attackerUnit = event.entindex_attacker_const and EntIndexToHScript(event.entindex_attacker_const)
    local victimUnit = event.entindex_victim_const and EntIndexToHScript(event.entindex_victim_const)
    local ability = event.entindex_inflictor_const and EntIndexToHScript(event.entindex_inflictor_const)

	-- local velocity_mod = attackerUnit:FindModifierByName("modifier_velocity")
	
	-- if velocity_mod then
	-- 	local dist_traveled = velocity_mod.dist_last_2_sec

	-- 	event.damage = event.damage * (1 + ( dist_traveled * 0.0005 ))

	-- 	return true
	-- end

    if attackerUnit and attackerUnit.hero_parent~=nil and attackerUnit.hero_parent:IsRealHero() then

		local hero = attackerUnit.hero_parent

		if ability and hero:HasAbility( ability:GetAbilityName() ) then
			-- print( "changing ability to parent unit's matching ability" )
			ability = hero:FindAbilityByName( ability:GetAbilityName() )
		end

		-- local victim_deaths = victimUnit:GetDeaths()

        local damage_table = {
            victim = victimUnit,
            attacker = hero,
            damage = event.damage,
            damage_type = event.damagetype_const,
            ability = ability
        }

		if ability and string.match( ability:GetAbilityName(), "finger_of_death") then
			-- print( "ability was finger of death...")
			victimUnit:AddNewModifierButt( hero, ability, "modifier_lion_finger_of_death_delay", { duration = 3 } )
		end

        ApplyDamage(damage_table)
		
		return false
    end

    return true
end

function Filters:ExecuteOrderFilter(event)
	-- PrintTable(event)
	local ability = event.entindex_ability and EntIndexToHScript(event.entindex_ability)
	local targetUnit = event.entindex_target and EntIndexToHScript(event.entindex_target)
	local playerID = event.issuer_player_id_const
	local orderType = event.order_type
	local pos = Vector(event.position_x,event.position_y,event.position_z)
	local queue = event.queue
	local seqNum = event.sequence_number_const
	local units = event.units
	local unit = units and units["0"] and EntIndexToHScript(units["0"])

	-- --  example
		-- if pos._len()<2000 then return false end
	if ability then
		local gem_table = CustomNetTables:GetTableValue( "gem_slots", tostring( unit:GetEntityIndex() ) )
		
		if not gem_table then
			return true
		end

		local gem_name = gem_table[ tostring(event.entindex_ability) ]

		-- if gem_name then
		-- 	if gem_name=="castoncrit" and orderType~=11 then
		-- 		-- GameRules:SendCustomMessage("This ability is disabled by the Cast-on-Crit support gem...", 0, 0)
		-- 		UTIL_MessageText( playerID, "This ability is disabled by the Cast-on-Crit support gem...", 255, 0, 0, 2.0)
		-- 		print( "ordertype was ", orderType )
		-- 		return false
		-- 	end
		-- end

		if gem_name then
			if gem_name=="apprentice" and orderType~=DOTA_UNIT_ORDER_TRAIN_ABILITY and orderType~=DOTA_UNIT_ORDER_PING_ABILITY then
				-- GameRules:SendCustomMessage("This ability is disabled by the Cast-on-Crit support gem...", 0, 0)
				-- UTIL_MessageText( playerID, "This ability is disabled by the Apprentice support gem...", 255, 0, 0, 2.0)
				print("Heyo. Don't cast this nonsense. Throw an error...")
				Notifications:Bottom(PlayerResource:GetPlayer( playerID ), {text="This ability is disabled by the Apprentice support gem...", duration=3, style={color="red", ["font-size"]="25px", border="none"}})
				-- print( "ordertype was ", orderType )
				return false
			end
		end
	end

	return true
end

function Filters:HealingFilter(event)
	-- PrintTable(event)
	local targetUnit = event.entindex_target_const and EntIndexToHScript(event.entindex_target_const)
	local heal = event.heal -- can not get modified with local

	-- --  example
		-- event.heal = event.heal*RandomInt(0,2)
	
	return true
end

function Filters:ItemAddedToInventoryFilter(event)
	-- PrintTable(event)
	local inventory = event.inventory_parent_entindex_const and EntIndexToHScript(event.inventory_parent_entindex_const)
	local item = event.item_entindex_const and EntIndexToHScript(event.item_entindex_const)
	local itemParent = event.item_parent_entindex_const and EntIndexToHScript(event.item_parent_entindex_const)
	local sugg = event.suggested_slot

	-- --  example
	-- --  dunno
	
	return true
end

function Filters:ModifierGainedFilter(event)
	-- PrintTable(event)
	local name = event.name_const
	local duration = event.duration -- can not get modified with local
	local casterUnit = event.entindex_caster_const and EntIndexToHScript(event.entindex_caster_const)
	local parentUnit = event.entindex_parent_const and EntIndexToHScript(event.entindex_parent_const)

	-- --  example
		-- event.duration = duration*RandomFloat(0,2)
	
	return true
end

function Filters:ModifyExperienceFilter(event)
	-- PrintTable(event)
	local playerID = event.player_id_const
	local reason = event.reason_const
	local xp = event.experience -- can not get modified with local
	local heroUnit = playerID and PlayerResource:GetSelectedHeroEntity(playerID)
	
	-- --  example
		-- event.experience = xp*RandomFloat(0,2)

	return true
end

function Filters:ModifyGoldFilter(event)
	-- PrintTable(event) 
	local playerID = event.player_id_const
	local reason = event.reason_const
	local gold = event.gold -- can not get modified with local
	local reliable = event.reliable -- can not get modified with local
	local heroUnit = playerID and PlayerResource:GetSelectedHeroEntity(playerID)

	-- --  example
		-- event.gold = gold*RandomFloat(0,2)

	return true
end


function Filters:RuneSpawnFilter(event)
	-- PrintTable(event)
	-- maybe deprecated? 
	return true
end

function Filters:TrackingProjectileFilter(event)
	-- PrintTable(event)
	if not IsServer() then return true end

	local dodgeable = event.dodgeable
	local ability = event.entindex_ability_const and EntIndexToHScript(event.entindex_ability_const)
	local attackerUnit = event.entindex_source_const and EntIndexToHScript(event.entindex_source_const)
	local targetUnit = event.entindex_target_const and EntIndexToHScript(event.entindex_target_const)
	local expireTime = event.expire_time
	local isAttack = (1==event.is_attack)
	local maxImpactTime = event.max_impact_time
	local moveSpeed = event.move_speed -- can not get modified with local

	-- if not isAttack and ability then
	-- 	local tracker_ability = ability:GetCaster():FindAbilityByName("ability_projectile_tracker")
	-- 	local is_bouncy = string.match( ability:GetName(),"chain_frost" ) or string.match( ability:GetName(),"cask" ) or string.match( ability:GetName(),"arc_lightning" )
	-- 	if tracker_ability and tracker_ability~=ability and not is_bouncy then
	-- 		print("Woot! Test Projectile fired!")
	-- 		local tracking_proj_options = {
	-- 			vSourceLoc = ability:GetCaster():GetOrigin(),
	-- 			Target = targetUnit,
	-- 			iMoveSpeed = moveSpeed,
	-- 			flExpireTime = expireTime,
	-- 			bDodgeable = dodgeable,
	-- 			bIsAttack = false,
	-- 			bReplaceExisting = false,
	-- 			bIgnoreObstructions = true,
	-- 			bDrawsOnMinimap = false,
	-- 			bVisibleToEnemies = false,
	-- 			EffectName = "models/heroes/muerta/debut/particles/trickshot/muerta_debut_ricochet_trickshot_tracking_proj.vpcf",
	-- 			Ability = tracker_ability,
	-- 			Source = attackerUnit, -- needs to be the hero caster
	-- 			bProvidesVision = false,
	-- 		}
	-- 		local proj_id = ProjectileManager:CreateTrackingProjectile( tracking_proj_options )
	-- 		-- table.insert( self.duplicated_projectiles, proj_id )
	-- 	end
	-- end

	return true
end

function Filters:SetModifierGainedFilter(event)
	local parent = EntIndexToHScript( event.entindex_parent_const )
	if parent:IsFakeClient() and event.name_const == "modifier_fountain_invulnerability" then
		return false
	end
	
	return true
end
