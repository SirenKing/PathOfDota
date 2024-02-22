-- Partial credit to Superbia for his crit-detection code contribution
modifier_enlighten = class({})
modifier_enlighten.ability_data = {}

function modifier_enlighten:IsHidden() return true end
function modifier_enlighten:IsPermanent() return true end

function modifier_enlighten:OnCreated()
    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.1)
end

function modifier_enlighten:OnIntervalThink()
    self:OnRefresh()
end

function modifier_enlighten:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_enlighten:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
    }
end

function modifier_enlighten:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
end

function modifier_enlighten:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end

function modifier_enlighten:GetModifierPercentageCooldown( params )
    if params.ability:IsItem() then return 0 end
    if self.ability_data[ params.ability:GetName() ]==nil then return 0 end
    return 30
end

function modifier_enlighten:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    if self.ability_data[ params.ability:GetName() ]==nil then return 0 end
    return 1
end

function modifier_enlighten:GetModifierOverrideAbilitySpecialValue( params )

    local ability = params.ability
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if self.ability_data[ ability:GetName() ]==nil then
        return value
    end

    if string.match( vName, "anaCost" ) or string.match( vName, "cost" ) or string.match( vName, "mana_per_sec" ) then -- NOT 'Channel' or 'channel' because noth need to be recognized
        return value * 0.7
    end

    return value
end