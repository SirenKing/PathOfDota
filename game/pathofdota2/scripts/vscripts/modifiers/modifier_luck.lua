-- Partial credit to Superbia for his crit-detection code contributiony_index
modifier_luck = class({})
modifier_luck.ability_data = {}

function modifier_luck:IsHidden() return true end
function modifier_luck:IsPermanent() return true end

function modifier_luck:OnCreated()
    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.1)
end

function modifier_luck:OnIntervalThink()
    self:OnRefresh()
end

function modifier_luck:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_luck:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
    }
end

function modifier_luck:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
end

function modifier_luck:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_luck:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    if self.ability_data[ params.ability:GetName() ]==nil then return 0 end
    return 1
end

function modifier_luck:GetModifierOverrideAbilitySpecialValue( params )

    local ability = params.ability
    local gem_ability = 0
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if self.ability_data[ ability:GetName() ]==nil then
        return value
    end

    if string.match(vName, "chance") or string.match(vName, "odds") then
        return self:MultiplyOdds( value, 100 )
    end

    return value
end

function modifier_luck:MultiplyOdds( a, b )
    local new_crit_chance = math.ceil( ( 1 - (1-(a/100))^(1+(b/100)))*100 ) - 1
    return new_crit_chance
end