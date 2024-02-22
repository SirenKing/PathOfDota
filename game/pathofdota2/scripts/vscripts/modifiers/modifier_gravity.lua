LinkLuaModifier( "modifier_gravity_thinker", "modifiers/modifier_gravity", LUA_MODIFIER_MOTION_NONE )

modifier_gravity = class({})
modifier_gravity.ability_data = {}
modifier_gravity.active = false

function modifier_gravity:IsHidden() return true end
function modifier_gravity:IsPermanent() return true end

function modifier_gravity:DeclareFunctions()
    return {
        MODIFIER_EVENT_SPELL_APPLIED_SUCCESSFULLY,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end

function modifier_gravity:OnAbilityExecuted( params )

    local ability = params.ability
    local caster = params.unit
    local parent = self:GetParent()

    if caster==parent and self.ability_data[ ability:GetName() ]~=nil then

        if ability:IsToggle() then
            if not ability:GetToggleState() then
                self:AddPermanentGravity( caster, ability )
            else
                self:RemovePermanentGravity( caster, ability )
            end
        end
    end
end

function modifier_gravity:RemovePermanentGravity(caster,ability)
    ability.gravity_thinker:OnDestroy()
end

function modifier_gravity:AddPermanentGravity(caster,ability)

    local radius_name = ability:GetFirstAbilitySpecialNameContaining( "radius" )
    local radius = ability:GetSpecialValueFor( radius_name )
    local pos = caster:GetOrigin()

    if radius then
        -- print( "Casting toggle that should work with gravity!")

        local pfx_name = "particles/gravity_swirl.vpcf"

        local thinker = CreateModifierThinker( caster, ability, "modifier_gravity_thinker", {}, pos, caster:GetTeamNumber(), false)
        local mod = thinker:FindModifierByName( "modifier_gravity_thinker" )
        mod.radius = radius

        mod.hero_to_follow = caster
        ability.gravity_thinker = mod

        local pfx = ParticleManager:CreateParticle( pfx_name, PATTACH_ABSORIGIN_FOLLOW, thinker )
        ParticleManager:SetParticleControl( pfx, 0, pos )
        ParticleManager:SetParticleControl( pfx, 1, Vector( 60,0,0 ) )
        ParticleManager:SetParticleControl( pfx, 2, Vector( radius,0,0 ) )
        ParticleManager:SetParticleControl( pfx, 3, Vector( 999999,0,0 ) )
    end

end

function modifier_gravity:OnSpellAppliedSuccessfully( params )

    local ability = params.ability
    local caster = params.unit

    local hero = self:GetParent()

    if self.ability_data[ ability:GetName() ]~=nil then

        -- print( caster, hero, caster==hero)
        
        local pos = ability:GetCursorPosition()
        local should_follow = false

        if ability:GetCursorTarget() then
            -- print("Should follow target")
            pos = ability:GetCursorTarget():GetOrigin()
            should_follow = true
        elseif ability:GetCursorTargetingNothing() then
            pos = hero:GetAbsOrigin()
            should_follow = true
        end

        local radius_name = ability:GetFirstAbilitySpecialNameContaining( "radius" )
        local radius = ability:GetSpecialValueFor( radius_name )

        if pos and radius then
            -- print( "OnSpellAppliedSuccessfully: Casting an ability that should work with gravity!")
            local duration_name = ability:GetFirstAbilitySpecialNameContaining( "duration" )
            local duration = 0

            if duration_name then
                duration = ability:GetSpecialValueFor( duration_name )
            else
                duration = ability:GetChannelTime()
            end

            if duration == 0 or duration==nil then
                duration = 6
            end

            local pfx_name = "particles/gravity_swirl.vpcf"

            local thinker = CreateModifierThinker( hero, ability, "modifier_gravity_thinker", { duration = duration }, pos, hero:GetTeamNumber(), false)
            local mod = thinker:FindModifierByName( "modifier_gravity_thinker" )
            mod.radius = radius

            if should_follow and ability:GetCursorTarget() then
                mod.hero_to_follow = ability:GetCursorTarget()
            elseif should_follow then
                mod.hero_to_follow = hero
            end

            local pfx = ParticleManager:CreateParticle( pfx_name, PATTACH_ABSORIGIN_FOLLOW, thinker )
            ParticleManager:SetParticleControl( pfx, 0, pos )
            ParticleManager:SetParticleControl( pfx, 1, Vector( 60,0,0 ) )
            ParticleManager:SetParticleControl( pfx, 2, Vector( radius,0,0 ) )
            ParticleManager:SetParticleControl( pfx, 3, Vector( duration,0,0 ) )
        end
    end
end

function modifier_gravity:OnAbilityFullyCast( params )

    local ability = params.ability
    local caster = params.unit

    local hero = self:GetParent()

    if caster==hero and self.ability_data[ ability:GetName() ]~=nil then

        print( caster, hero, caster==hero)
        
        local pos = ability:GetCursorPosition()
        local should_follow = false
        local radius = 100

        if ability:GetCursorTarget() then
            -- print("Should follow target")
            pos = ability:GetCursorTarget():GetAbsOrigin()
            should_follow = true
        elseif ability:GetCursorTargetingNothing() then
            pos = hero:GetAbsOrigin()
            should_follow = true
        end

        local radius_name = ability:GetFirstAbilitySpecialNameContaining( "radius" ) or ability:GetFirstAbilitySpecialNameContaining( "aoe" )

        if radius_name then
            radius = ability:GetSpecialValueFor( radius_name )
        end

        if radius and radius > 0 and radius < 200 then
            radius = 200
        end

        if pos and radius then
            -- print( "OnAbilityFullyCast: Casting an ability that should work with gravity!")
            local duration_name = ability:GetFirstAbilitySpecialNameContaining( "duration" )
            local duration = 0

            if pos==Vector(0,0,0) then
                pos = ability:GetCaster():GetAbsOrigin()
            end

            if duration_name then
                duration = ability:GetSpecialValueFor( duration_name )
            else
                duration = ability:GetChannelTime()
            end

            if duration < 4 or duration==nil then
                duration = 4
            end

            local pfx_name = "particles/gravity_swirl.vpcf"


            local thinker = CreateModifierThinker( caster, ability, "modifier_gravity_thinker", { duration = duration }, pos, caster:GetTeamNumber(), false)
            local mod = thinker:FindModifierByName( "modifier_gravity_thinker" )
            mod.radius = radius

            if should_follow and ability:GetCursorTarget()~=nil then
                mod.hero_to_follow = ability:GetCursorTarget()
            elseif should_follow then
                mod.hero_to_follow = ability:GetCaster()
            elseif ability:GetName()=="primal_beast_trample" or ability:GetName()=="juggernaut_blade_fury" then
                mod.hero_to_follow = ability:GetCaster()
            end

            -- print( "Adding gravity thinker!", duration, radius, caster, ability, pos, mod.hero_to_follow )

            local pfx = ParticleManager:CreateParticle( pfx_name, PATTACH_ABSORIGIN_FOLLOW, thinker )
            ParticleManager:SetParticleControl( pfx, 0, pos )
            -- ParticleManager:SetParticleControl( pfx, 1, Vector( 60,0,0 ) )
            ParticleManager:SetParticleControl( pfx, 2, Vector( radius,0,0 ) )
            ParticleManager:SetParticleControl( pfx, 3, Vector( duration,0,0 ) )
        end
    end
end

---------------------------
-- THINKER ----
---------------------------

modifier_gravity_thinker = class({})
modifier_gravity_thinker.radius = 0
modifier_gravity_thinker.is_channeling = false

function modifier_gravity_thinker:IsHidden() return true end
function modifier_gravity_thinker:IsPermanent() return true end

function modifier_gravity_thinker:OnCreated()

    if not IsServer() then return end
    
    if self:GetAbility() and self:GetAbility():IsChanneling() then
        self.is_channeling = true
        self:SetDuration( self:GetAbility():GetChannelTime(), true )
    end
    -- print("Thinker was built!")
    self:StartIntervalThink( FrameTime() )
end

function modifier_gravity_thinker:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_gravity_thinker:OnDestroy()
    -- print("Thinker was destroyed!")
    UTIL_Remove(self:GetParent())
end

function modifier_gravity_thinker:OnIntervalThink()

    if not IsServer() then return end

    if self:GetAbility() and self:GetAbility():IsToggle() and not self:GetAbility():GetToggleState() then
        self:OnDestroy()
    end
    
    if self.is_channeling == true and self:GetAbility() and not self:GetAbility():IsChanneling() then
        self:OnDestroy()
    end

    local dist = 2.5 + ( self:GetAbility():GetLevel() / 2 )
    
    if self.hero_to_follow~=nil and self.hero_to_follow:IsAlive() then
        local new_pos = self.hero_to_follow:GetAbsOrigin()
        self:GetParent():SetOrigin( new_pos )
    end

    if self.radius >= 1 then
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeam(),
            self:GetParent():GetAbsOrigin(),
            nil,
            self.radius, --radius
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false --canGrowCache: bool
        )

        for i=1,#enemies do
            -- print("Moving enemy!")
            local enemy_pos = enemies[i]:GetAbsOrigin()
            local gravity_pos = self:GetParent():GetOrigin()
            local dist_between = CalcDistanceBetweenEntityOBB( enemies[i], self:GetParent())
            local dist_perc = dist / dist_between
            local lerp_pos = LerpVectors( enemy_pos, gravity_pos, dist_perc )
            -- local lerp_pos = Vector(enemy_pos.x + 100, enemy_pos.y, enemy_pos.z)
            if dist_between > (self.radius * 0.2) then
                local new_pos = Vector(lerp_pos.x, lerp_pos.y, GetGroundHeight(lerp_pos, nil) )
                -- enemies[i]:SetOrigin( Vector(lerp_pos.x, lerp_pos.y, GetGroundHeight(lerp_pos, nil) ) )
                FindClearSpaceForUnit( enemies[i], new_pos, false )
            end
        end
    end

end

function modifier_gravity_thinker:OnRefresh()
end