-- Partial credit to Superbia for his crit-detection code contribution
modifier_flagellation = class({})
modifier_flagellation.ability_data = {}
modifier_flagellation.active = false

function modifier_flagellation:IsHidden() return true end

function modifier_flagellation:OnCreated()
end

function modifier_flagellation:OnRefresh()
end

function modifier_flagellation:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

function modifier_flagellation:OnAbilityFullyCast( params )

    local ability = params.ability
    local caster = params.unit
    local hero = self:GetParent()

    if caster==hero and self.ability_data[ ability:GetName() ]~=nil then
        local clone = CreateUnitByName( hero:GetName(), hero:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)

        for i=1,(hero:GetLevel()-1) do
            clone:HeroLevelUp( false )
        end
        
        for i=1,6 do
            local for_ability = hero:GetAbilityByIndex(i)
            local for_item = hero:GetItemInSlot(i)

            if for_ability~=nil and for_ability:IsHidden() then
                local ability_level = for_ability:GetLevel()
                -- local cln_ability = clone:AddAbility( for_ability:GetName() )
                local cln_ability = clone:FindAbilityByName( for_ability:GetName() )
                cln_ability:SetLevel( ability_level )
            end

            if for_item then
                clone:AddItemByName( for_item:GetName() )
            end
        end

        for i=1,3 do
            -- print("Hitting self three times!")
            hero:PerformAttack(
                clone, --victim
                false, --useCastAttackOrb
                true, --processProcs
                true, --skipCooldown
                true, --ignoreInvis
                false, --useProjectile
                false, --fakeAttack
                true --neverMiss
            )
            clone:PerformAttack(
                hero, --victim
                false, --useCastAttackOrb
                true, --processProcs
                true, --skipCooldown
                true, --ignoreInvis
                false, --useProjectile
                false, --fakeAttack
                true --neverMiss
            )
        end

        UTIL_Remove( clone )
    end
end