-- Partial credit to Superbia for his crit-detection code contribution
modifier_vengeance = class({})
modifier_vengeance.ability_data = {}
modifier_vengeance.active = false

function modifier_vengeance:IsHidden() return true end
function modifier_vengeance:IsPermanent() return true end

function modifier_vengeance:OnCreated()
end

function modifier_vengeance:OnRefresh()
end

function modifier_vengeance:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_vengeance:OnAttackLanded( params )

    local target = params.target
    local hero = self:GetParent()

    local ability_table = self.ability_data

    if target==hero then
        -- print("Parent hero was attacked!")
        -- DeepPrint(self.ability_data)
        for k,v in pairs(ability_table) do
            local ability = hero:FindAbilityByName( k )
            -- print( "Ability to lower cooldown on is called ", ability:GetName() )
            if ability~=nil and not ability:IsCooldownReady() then
                local time_remaining = ability:GetCooldownTimeRemaining()
                if time_remaining > 0.5 then
                    -- print( "Lowering ability cooldown from:", time_remaining, " to ", time_remaining - 0.5)
                    ability:EndCooldown()
                    ability:StartCooldown( time_remaining - 0.5 )
                else
                    ability:EndCooldown()
                end
            end
        end
    end
end