-- Partial credit to Superbia for his crit-detection code contribution
modifier_crit_damage = class({})
modifier_crit_damage.ability_data = {}

function modifier_crit_damage:IsHidden() return true end
function modifier_crit_damage:IsPermanent() return true end

function modifier_crit_damage:OnCreated()
    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.1)
end

function modifier_crit_damage:OnIntervalThink()
    self:OnRefresh()
end

function modifier_crit_damage:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_crit_damage:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
    }
end

function modifier_crit_damage:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
end

function modifier_crit_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_crit_damage:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    if self.ability_data[ params.ability:GetName() ]==nil then return 0 end
    return 1
end

function modifier_crit_damage:GetModifierOverrideAbilitySpecialValue( params )

    local ability = params.ability
    local gem_ability = 0
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if self.ability_data[ ability:GetName() ]==nil then
        return value
    end

    if string.match(vName, "crit_bonus") or string.match(vName, "crit_mult") then
        local crit_bonus = 150
        return math.floor( value + crit_bonus )
    end

    return value
end