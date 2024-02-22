-- Partial credit to Superbia for his crit-detection code contribution
modifier_focus = class({})

function modifier_focus:IsHidden() return true end
function modifier_focus:IsPermanent() return true end

function modifier_focus:OnCreated()
end

function modifier_focus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end


function modifier_focus:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    return 1
end


function modifier_focus:GetModifierOverrideAbilitySpecialValue( params )
    
    local gem_ability = 0
    if self.ability_index then
        gem_ability = EntIndexToHScript(self.ability_index)
    end

    local ability = params.ability
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if not ability==gem_ability then return value end

    local abilityKeys = GetAbilityKeyValuesByName( ability:GetName() )
    local abilityBehavior = abilityKeys["AbilityBehavior"]

    if not string.match( abilityBehavior, "CHANNEL") then return value end

    if string.match( vName, "hannel" ) then -- NOT 'Channel' or 'channel' because noth need to be recognized
        return value * 2
    end

    if string.match( vName, "damage" ) then
        return value * 2
    end

    return value
end