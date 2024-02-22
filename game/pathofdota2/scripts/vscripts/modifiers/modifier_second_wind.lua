-- Partial credit to Superbia for his crit-detection code contribution
modifier_second_wind = class({})
modifier_second_wind.ability_data = {}

function modifier_second_wind:IsHidden() return true end
function modifier_second_wind:IsPermanent() return true end

function modifier_second_wind:OnCreated()
    if not IsServer() then return end
        
    self:CheckCharges()
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(1)
end

function modifier_second_wind:OnIntervalThink()
    self:OnRefresh()
end

function modifier_second_wind:CheckCharges()
    if not IsServer() then return end

    print("Checking ability charges...")
    local hero = self:GetParent()
    local ability_data = self.ability_data

    DeepPrint(ability_data)

    for k,v in pairs(ability_data) do
        local ability = hero:FindAbilityByName( k )
        local max_charges = ability:GetMaxAbilityCharges(ability:GetLevel())
        local current_charges = ability:GetCurrentAbilityCharges()
        print( max_charges, current_charges )
        if current_charges > max_charges then
            print( "Setting max charges for ability: ", ability:GetName() )
            ability:SetCurrentAbilityCharges( max_charges )
        elseif current_charges == 0 and ability:GetCooldownTimeRemaining()==0 then
            ability:SetCurrentAbilityCharges( 1 )
            ability:SetCurrentAbilityCharges( 0 )
            -- ability:StartCooldown(FrameTime())
        end
    end

end

function modifier_second_wind:OnRefresh()
    if IsServer() then

        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_second_wind:OnDestroy()
    self:CheckCharges()
end

function modifier_second_wind:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
    }
end

function modifier_second_wind:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
end

function modifier_second_wind:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_second_wind:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    if self.ability_data[ params.ability:GetName() ]==nil then return 0 end
    return 1
end

function modifier_second_wind:GetModifierOverrideAbilitySpecialValue( params )

    local ability = params.ability
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if self.ability_data[ ability:GetName() ]==nil then
        return value
    end

    if string.match(vName, "AbilityCooldown") then
        self.ability_data[ params.ability:GetName() ] = value * 1.3
        return 1
    elseif string.match(vName, "AbilityCharges") then
        local bonus = 2
        return value + bonus
    elseif string.match(vName, "AbilityChargeRestoreTime") then
        -- print(value)
        if self.ability_data[ params.ability:GetName() ] >= 1.1 then
            return self.ability_data[ params.ability:GetName() ]
        else
            return value * 1.3
        end
    end

    return value
end