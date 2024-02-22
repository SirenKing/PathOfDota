modifier_lifetap = class({})
modifier_lifetap.ability_data = {}
modifier_lifetap.shield = 0

function modifier_lifetap:IsHidden() return true end
function modifier_lifetap:IsPermanent() return true end

function modifier_lifetap:OnCreated()
    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.5)
end

function modifier_lifetap:OnIntervalThink()
    self:OnRefresh()
end

function modifier_lifetap:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_lifetap:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
        shield = self.shield
    }
end

function modifier_lifetap:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
    self.shield = data.shield
end

function modifier_lifetap:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

function modifier_lifetap:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    if self.ability_data[ params.ability:GetName() ]==nil then return 0 end
    return 1
end

function modifier_lifetap:GetModifierOverrideAbilitySpecialValue( params )

    local ability = params.ability
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if self.ability_data[ ability:GetName() ]==nil then
        return value
    end

    if self.ability_data[ ability:GetName() ] >= 0 then
        local is_manacost = string.match( vName, "ManaCost" ) or string.match( vName, "mana_" )
        local is_healthcost = string.match( vName, "HealthCost" ) or string.match( vName, "hp_cost" ) or string.match( vName, "health_cost" )
        local is_dmg = string.match(vName, "damage") or string.match(vName, "dmg") or string.match(vName, "AbilityDamage" )

        if is_dmg then
            local newDamage = value
            return math.floor( newDamage )
        end

        if is_manacost then
            self.ability_data[ ability:GetName() ] = value
            return 0
        end

        if is_healthcost then
            if value==0 or value==nil then
                local new_value = self.ability_data[ ability:GetName() ] * 2
                return new_value
            else
                return value
            end
        end
    end

    return value
end

function modifier_lifetap:OnTakeDamage( params )
    -- local damage_is_attack = params.damage_type==DAMAGE_TYPE_PHYSICAL or params.damage_type==DAMAGE_TYPE_NONE and params.inflictor==nil
	if params.unit==self:GetParent() and params.damage_type==DAMAGE_TYPE_PHYSICAL then
        -- DeepPrint( params )
        self.shield = self.shield - params.original_damage
        if self.shield < 0 then
            self.shield = 0
        end
        self:OnRefresh()
    end
end

function modifier_lifetap:GetModifierIncomingPhysicalDamageConstant( params )
    if IsServer() then
        return -self.shield
    end
    if IsClient() then
        return self.shield
    end
end

function modifier_lifetap:OnAbilityFullyCast( params )

    local ability = params.ability

    if params.unit==self:GetParent() and self.ability_data[ ability:GetName() ]~=nil then
        self.shield = self.shield + ( ability:GetEffectiveHealthCost( ability:GetLevel() ) )
        if self.shield > 1000 then
            self.shield = 1000
        end
    end
    self:OnRefresh()
end