LinkLuaModifier( "modifier_focus_attack", "modifiers/modifier_focus", LUA_MODIFIER_MOTION_NONE )

modifier_focus = class({})
modifier_focus.ability_data = {}

function modifier_focus:IsHidden() return true end
function modifier_focus:IsPermanent() return true end

function modifier_focus:OnCreated()
    if self.has_cast then
        self:GetParent():AddNewModifier( self:GetParent(), nil, "modifier_focus_attack", { duration = nil } )
    end

    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.1)
end

function modifier_focus:OnIntervalThink()
    self:OnRefresh()
end

function modifier_focus:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_focus:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
        has_cast = self.has_cast,
    }
end

function modifier_focus:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
    self.has_cast = data.has_cast
end

function modifier_focus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_ABILITY_END_CHANNEL,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end

function modifier_focus:OnAbilityExecuted( params )
    local abilityKeys = GetAbilityKeyValuesByName( params.ability:GetName() )
    local abilityBehavior = abilityKeys["AbilityBehavior"]
    local is_channeled = string.match( abilityBehavior, "CHANNEL")

    if params.unit==self:GetParent() and self.ability_data[ params.ability:GetName()]~=nil and is_channeled then
        self.has_cast = true
    end
    self:OnCreated()
    self:SendBuffRefreshToClients()
end

function modifier_focus:OnAbilityEndChannel( params )
    if params.unit==self:GetParent() then
        self.has_cast = false
    end
end

function modifier_focus:GetModifierPhysicalArmorBonus()
    if self.has_cast==true or self.has_cast==1 then
        return 15
    else
        return 0
    end
end

function modifier_focus:GetModifierMagicalResistanceBonus()
    if self.has_cast==true or self.has_cast==1 then
        return 25
    else
        return 0
    end
end

-------------------------------------

modifier_focus_attack = class({})
modifier_focus_attack.ability_data = {}

function modifier_focus_attack:IsHidden() return true end
function modifier_focus_attack:IsPermanent() return true end

function modifier_focus_attack:OnCreated()
    self:AttackNearbyEnemies()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_focus_attack:OnIntervalThink()
    self:AttackNearbyEnemies()
end

function modifier_focus_attack:AttackNearbyEnemies()
    print("looking for nearby enemies!")
    if IsClient() then return end
    if self:GetParent():IsChanneling() then

        local hero = self:GetParent()
        local enemies = FindUnitsInRadius(
            hero:GetTeam(),
            hero:GetAbsOrigin(),
            nil,
            600,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
        
        for i=1,#enemies do
            print("Attacking a nearby enemy!")
            hero:PerformAttack(
                enemies[i], --victim
                false, --useCastAttackOrb
                true, --processProcs
                true, --skipCooldown
                true, --ignoreInvis
                true, --useProjectile
                false, --fakeAttack
                true --neverMiss
            )
        end
    else
        self:GetParent():RemoveAllModifiersOfName( "modifier_focus_attack" )
    end
end