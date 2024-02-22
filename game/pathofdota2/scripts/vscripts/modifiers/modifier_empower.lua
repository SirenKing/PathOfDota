modifier_empower = class({})
modifier_empower.ability_data = {}

function modifier_empower:IsHidden() return true end
function modifier_empower:IsPermanent() return true end

function modifier_empower:OnCreated()
end

function modifier_empower:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_empower:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    return 1
end

function modifier_empower:GetModifierOverrideAbilitySpecialValue( params )

    local ability = params.ability
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if self.ability_data[ ability:GetName() ]==nil then
        return value
    end

    if string.match( vName, "max" ) or string.match( vName, "stacks" ) then -- NOT 'Channel' or 'channel' because noth need to be recognized
        return math.floor( value * 1.5 )
    end

    -- if string.match( vName, "number_of_golems" ) or string.match( vName, "spirit_count" ) or string.match( vName, "total_familiars" ) or string.match( vName, "tooltip_clones" ) or string.match( vName, "spawn_count" ) then
    --     return value + 1
    -- end

    -- if string.match( vName, "wolf_count" ) then
    --     return value + 3
    -- end

    -- if string.match( ability:GetName(), "spiderlings" ) and string.match( vName, "count" ) then
    --     return value + 2
    -- end

    -- if string.match( ability:GetName(), "special_bonus_unique_visage_6" ) then --doesn't work... :'(
    --     return value + 1
    -- end

    if string.match( vName, "max_treants" )then
        return value + 3
    end

    -- if string.match( ability:GetName(), "special_bonus_unique_meepo_5" ) then --doesn't work... :'(
    --     return value + 1
    -- end

    

    return value
end