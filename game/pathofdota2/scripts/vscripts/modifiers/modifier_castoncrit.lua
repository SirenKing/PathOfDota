-- Partial credit to Superbia for his crit-detection code contribution
modifier_castoncrit = class({})
modifier_castoncrit.ability_data = {}
modifier_castoncrit.aggro_target = nil

function modifier_castoncrit:IsHidden() return true end
function modifier_castoncrit:IsPermanent() return true end

function modifier_castoncrit:OnCreated()
    if IsServer() then
        self.crits = {}
    end
end

-- function modifier_castoncrit:OnRemoved()
--     print( "castoncrit was removed...")
-- end

function modifier_castoncrit:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_RECORD,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        -- MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
    }
end

function modifier_castoncrit:GetModifierPercentageManacost( keys )
    if self.mid_cast == true then
        return 60
    else
        return 0
    end
end

-- function modifier_castoncrit:OnAbilityFullyCast( params )
-- end

function modifier_castoncrit:GetCritDamage( keys )
    return 0
end

function modifier_castoncrit:OnAttackRecord(keys)
    if not IsServer() then return end
    if keys.attacker ~= self:GetParent() then return end
    -- if keys.damage==0 or keys.damage==nil then return end
    self.crits[keys.record] = true
end

function modifier_castoncrit:OnAttackRecordDestroy(keys)
    if not IsServer() then return end
    if keys.attacker ~= self:GetParent() then return end
    self.crits[keys.record] = nil
end

function modifier_castoncrit:GetModifierPreAttack_CriticalStrike(keys)
    if not IsServer() then return end
    if keys.attacker ~= self:GetParent() then return end
    self.crits[keys.record] = nil
end

function modifier_castoncrit:OnAttackLanded(keys)
    -- if not IsServer() then return end
    if keys.attacker ~= self:GetParent() then return end

    local target = keys.target

    if self.crits[keys.record] and not target:IsBuilding() then
        -- print("crit landed")
		self:GetParent():GiveMana( 7 )
        local ability_data = self.ability_data

        local roll = RandomInt(1,1000) / 10

        local abil_tbl = {}

        for k,v in pairs(ability_data) do

            local ability_name = k
            local ability = self:GetParent():FindAbilityByName( ability_name )

            if ability then
                local mana_req = ability:GetEffectiveManaCost( ability:GetLevel() * 0.4 )
                local cooldown = ability:GetEffectiveCooldown( ability:GetLevel() )
                ability.cast_chance = 400 * (1/cooldown)

                if ability:GetLevel()>0 and ability:IsCooldownReady() and ability:GetCaster():GetMana() >= mana_req and not ability:IsHidden() then
                    table.insert( abil_tbl, ability )
                end
            end
        end

        for i=1,#abil_tbl do

            local ability = abil_tbl[i]
            -- print("chance to cast is", ability.cast_chance)

            if roll <= ability.cast_chance then
                ability:EndCooldown()
                ability:StartCooldown( FrameTime() )
                local mana_req = ability:GetEffectiveManaCost( ability:GetLevel() * 0.4 )
                
                Timers:CreateTimer( ability:GetCastPoint(), function()
                    if ability:GetLevel()>0 and ability:IsCooldownReady() and not ability:IsHidden() and ability:GetCaster():GetMana() >= mana_req then
                        self.aggro_target = target

                        self.mid_cast = true
                        ability:FakeCastAbility( target )
                        self.mid_cast = false

                        ability:EndCooldown()
                        ability:StartCooldown( ability:GetEffectiveCooldown(ability:GetLevel()) * 0.15 )
                    end
                    return nil
                end)
            end
        end
    end
end