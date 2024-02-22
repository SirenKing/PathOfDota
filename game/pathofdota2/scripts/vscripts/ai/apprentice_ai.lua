function Spawn( entityKeyValues )
    if thisEntity == nil then return end

    if IsClient() then return end

	thisEntity:SetContextThink( "CreatureThink", CreatureThink, 1 )
end

function CreatureThink()

    if GameRules:IsGamePaused() or GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME then
        return 1
    end

    if thisEntity == nil then return end

    if IsClient() then return end
    
    local heroes = HeroList:GetAllHeroes()
    DoApprenticeLogic( heroes, thisEntity )

    local aggro_target = thisEntity:GetAggroTarget()

    if aggro_target and not aggro_target:IsBuilding() then
        local ability_table = thisEntity:GetMainHeroAbilities()
        for i=1,#ability_table do
            local ability = ability_table[i]
            if ability:IsFullyCastable() and not ability:IsPassive() and not thisEntity:GetCurrentActiveAbility() then
                local result = ability:FakeCastAbility(aggro_target)
                if result then
                    ability:EndCooldown()
                    ability:StartCooldown( ability:GetEffectiveCooldown(ability:GetLevel()) )
                    local original_ability = ability.original_ability
                end
            end
        end
    end

    return 1
end

function DoApprenticeLogic(heroes, spawnedUnit)
	for i=1,#heroes do
		if heroes[i]:HasModifier("modifier_apprentice") then
			local modifier = heroes[i]:FindModifierByName("modifier_apprentice")
			local abilities = modifier.ability_data
			-- DeepPrint(abilities)
			for k,v in pairs( abilities ) do
				local ability_name = k
				-- print( ability_name )
				if heroes[i]:GetTeamNumber()==spawnedUnit:GetTeamNumber() then
					if heroes[i]:HasAbility( ability_name ) and not spawnedUnit:HasAbility(ability_name) then
						local ability = heroes[i]:FindAbilityByName( ability_name )
						local new_ability = spawnedUnit:AddAbility( ability_name )
						local behavior = new_ability:GetBehaviorInt()
						local is_auto_cast = DOTA_ABILITY_BEHAVIOR_AUTOCAST == bit.band(DOTA_ABILITY_BEHAVIOR_AUTOCAST, behavior)
						if is_auto_cast and new_ability:GetAutoCastState()==false then
							new_ability:ToggleAutoCast()
						end
						new_ability:SetLevel( ability:GetLevel() )
						new_ability.original_ability = ability
						new_ability:EndCooldown()
						new_ability:StartCooldown( ability:GetCooldownTimeRemaining() )
					end
				end
			end
		end
	end
end