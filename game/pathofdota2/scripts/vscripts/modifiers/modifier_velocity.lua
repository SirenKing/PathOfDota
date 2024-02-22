-- Partial credit to Superbia for his crit-detection code contribution
modifier_velocity = class({})
modifier_velocity.ability_data = {}
modifier_velocity.dist_last_2_sec = 0
modifier_velocity.last_pos = 0
modifier_velocity.dist_table = {}
modifier_velocity.dist_table["1"] = 0
modifier_velocity.dist_table["2"] = 0
modifier_velocity.dist_table["3"] = 0
modifier_velocity.dist_table["4"] = 0
modifier_velocity.dist_table["5"] = 0
modifier_velocity.dist_table["6"] = 0
modifier_velocity.dist_table["7"] = 0
modifier_velocity.dist_table["8"] = 0
modifier_velocity.dist_table["9"] = 0
modifier_velocity.dist_table["10"] = 0

function modifier_velocity:IsHidden() return true end
function modifier_velocity:IsPermanent() return true end

function modifier_velocity:OnCreated()
    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.2)
end

function modifier_velocity:OnIntervalThink()
    
    local dist_traveled = 0

    if self.last_pos~=0 and self.last_pos~=nil then
        dist_traveled = self:GetParent():GetDistToPos( self.last_pos )
    end
    
    self.last_pos = self:GetParent():GetAbsOrigin()
    
    if dist_traveled < 350 then -- if the distance traveled in the past 0.1s is less than 500 (so it ignores blinks, etc)
        self.dist_table[ tostring( math.floor( (GameRules:GetGameTime()*20) % 10 ) + 1) ] = dist_traveled -- 10x each second, check to see how far the unit moved since last check, then log that distance in a table
    end
    
    self.dist_last_2_sec = 0

    for i=1,10 do
        self.dist_last_2_sec = self.dist_last_2_sec + self.dist_table[tostring(i)]
    end

    -- DeepPrint(self.dist_table)

    self:OnRefresh()
end

function modifier_velocity:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_velocity:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
        dist_last_2_sec = self.dist_last_2_sec,
    }
end

function modifier_velocity:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
    self.dist_last_2_sec = data.dist_last_2_sec
end

function modifier_velocity:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_velocity:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    if self.ability_data[ params.ability:GetName() ]==nil then return 0 end
    return 1
end

function modifier_velocity:GetModifierOverrideAbilitySpecialValue( params )

    local ability = params.ability
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if IsServer() then return value end -- this modifier does NOT change the damage here- just the tooltip. The damage itself is handled in a damage filter

    if self.ability_data[ ability:GetName() ]==nil then
        return value
    end

    local is_dmg = string.match(vName, "damage") or string.match(vName, "dmg") or string.match(vName, "crit") or string.match(vName, "AbilityDamage" )

    if is_dmg then
        -- local current_ms = self:GetParent():GetMoveSpeedModifier( self:GetParent():GetBaseMoveSpeed(), false )
        local increase = 1 + ( self.dist_last_2_sec * 0.0005 )
        if increase > 2 then
            increase = 2
        end
        local newDamage = value * increase
        return math.floor( newDamage )
    end

    return value
end

