-- Partial credit to Superbia for his crit-detection code contribution
modifier_chain = class({})
modifier_chain.ability_data = {}

function modifier_chain:IsHidden() return true end
function modifier_chain:IsPermanent() return true end

function modifier_chain:OnCreated()
    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.1)
end

function modifier_chain:OnIntervalThink()
    self:OnRefresh()
end

function modifier_chain:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_chain:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
    }
end

function modifier_chain:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
end

function modifier_chain:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_chain:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    if self.ability_data[ params.ability:GetName() ]==nil then return 0 end
    return 1
end

function modifier_chain:GetModifierOverrideAbilitySpecialValue( params )

    local ability = params.ability
    local gem_ability = 0
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if self.ability_data[ ability:GetName() ]==nil then
        return value
    end

    if string.match(vName, "bounce") or string.match(vName, "jump_count") or string.match(vName, "jumps") and not string.match(vName, "delay") then
        local chain_bonus = 3
        self.total_bounces = math.floor( value + chain_bonus )
        return math.floor( value + 3 )
    elseif string.match(vName, "damage") and self.total_bounces~=nil then
        local amp_per_bounce = 0.03
        local amp = 1 + (self.total_bounces * amp_per_bounce)
        return math.floor( value * amp )
    end

    return value
end