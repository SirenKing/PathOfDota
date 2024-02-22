modifier_increased_aoe = class({})
modifier_increased_aoe.ability_data = {}
modifier_increased_aoe.kv_values = {}

function modifier_increased_aoe:IsHidden() return false end
function modifier_increased_aoe:IsPermanent() return true end

function modifier_increased_aoe:OnCreated()
    if not IsServer() then return end
    
    self:CalcKvData()
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(1)
end

function modifier_increased_aoe:OnIntervalThink()
    self:OnRefresh()
end

function modifier_increased_aoe:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_increased_aoe:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
        kv_values = self.kv_values,
    }
end

function modifier_increased_aoe:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
    self.kv_values = data.kv_values
end

function modifier_increased_aoe:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_increased_aoe:GetModifierOverrideAbilitySpecial( params )
    if params.ability:IsItem() then return 0 end
    if self.ability_data[ params.ability:GetName() ]==nil then return 0 end
    return 1
end

function modifier_increased_aoe:GetModifierOverrideAbilitySpecialValue( params )

    local ability = params.ability
    local vName = params.ability_special_value
    local vLevel = params.ability_special_level
    local value = params.ability:GetLevelSpecialValueNoOverride( vName, vLevel )

    if self.ability_data[ ability:GetName() ]==nil then
        return value
    end

    if string.match( vName, "AbilityDamage" ) then
        vName = "AbilityDamage"
    end
    
    if string.match( vName, "Charges" ) then
        return value
    end

    if self.kv_values[ vName ] then
        if self.kv_values[ vName ][vLevel] then
            return self.kv_values[ vName ][vLevel]
        elseif self.kv_values[ vName ][tostring(vLevel)] then
            return self.kv_values[ vName ][tostring(vLevel)]
        end
    end

    return value
end

function modifier_increased_aoe:CalcKvData()
    if IsServer() then
    -- print("This ran...")
        local ability_names = self.ability_data
        -- DeepPrint(ability_names)
        for k,v in pairs(ability_names) do
            local ability = self:GetParent():FindAbilityByName( k )
            local special_names = ability:GetAllAbilitySpecials()
            table.insert( special_names, "AbilityDamage" )
            -- DeepPrint(special_names)
            if ability then
                for e,i in pairs(special_names) do
                    -- print(e,i)
                    
                    local vName = i
                    if vName then
                        -- print(vName)
                        for l=0,ability:GetMaxLevel()-1 do
                            local value = ability:GetLevelSpecialValueNoOverride(vName, l)
                            -- print(value)

                            if value then

                                -- print(value)
                                if not self.kv_values[ vName ] then self.kv_values[ vName ] = {} end
                                if not self.kv_values[ vName ][l] then self.kv_values[ vName ][l] = value end

                                if string.match(vName, "radius") or string.match(vName, "aoe") or string.match(vName, "area") then
                                    local bonus_area_multi = 1.75
                                    local area = ( value ^ 2 ) * 3.14
                                    local newArea = area * bonus_area_multi
                                    local newRadius = math.sqrt( newArea / 3.14 )
                                    self.kv_values[ vName ][l] = math.floor( newRadius )
                                end

                                local is_aoe = ability:GetHasAbilitySpecialWith( "radius" )==true or ability:GetHasAbilitySpecialWith( "aoe" )==true
                                local is_dmg = string.match(vName, "damage") or string.match(vName, "dmg")
                                local is_ability_damage_KV =  string.match(vName, "AbilityDamage" )

                                if is_aoe and is_ability_damage_KV then
                                    local damageStr = ability:GetAbilityKeyValues()["AbilityDamage"]
                                    local newDamage = tonumber( findnth(damageStr,l+1) ) * 0.6
                                    self.kv_values[ vName ][l] = math.floor( newDamage )
                                end

                                if is_aoe and is_dmg then
                                    local newDamage = value * 1.75
                                    self.kv_values[ vName ][l] = math.floor( newDamage )
                                end

                                -- DeepPrint(self.kv_values)
                            end
                        end
                    end
                end
            end
        end
    end
end

function findnth(str, nth)
    local array = {}
    for i in string.gmatch(str, "%d+") do
      table.insert(array, i)
    end
    return array[nth]
end