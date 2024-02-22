modifier_infernal_legion = class({})
modifier_infernal_legion.ability_data = {}

function modifier_infernal_legion:IsHidden() return true end
function modifier_infernal_legion:IsPermanent() return true end

-- function modifier_infernal_legion:DeclareFunctions()
--     return {
        -- MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
--     }
-- end

-- function modifier_infernal_legion:OnAbilityFullyCast( params )

--     local ability = params.ability
--     local caster = params.unit
--     local parent = self:GetParent()

-- end

modifier_infernal_legion_burn = class({})

function modifier_infernal_legion_burn:IsHidden() return false end
function modifier_infernal_legion_burn:IsPermanent() return true end
function modifier_infernal_legion_burn:RemoveOnDeath() return true end

function modifier_infernal_legion_burn:OnCreated()
    self:StartIntervalThink(1)
    

    local pfx = ParticleManager:CreateParticle( "particles/infernal_legion_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    -- ParticleManager:SetParticleControl( pfx, 0, pos )
    ParticleManager:SetParticleControl( pfx, 1, Vector( 400,0,0 ) )
    -- ParticleManager:SetParticleControl( pfx, 2, Vector( radius,0,0 ) )
    -- ParticleManager:SetParticleControl( pfx, 3, Vector( 999999,0,0 ) )
end

function modifier_infernal_legion_burn:OnDeath()
    UTIL_Remove( self )
end

function modifier_infernal_legion_burn:OnDestroy()
    UTIL_Remove( self )
end

function modifier_infernal_legion_burn:OnIntervalThink()

    if not self:GetParent():IsAlive() then UTIL_Remove( self ) return end

    local unit = self:GetParent()
    local health = unit:GetMaxHealth()
    local dmg = health/100

	local neighbours = FindUnitsInRadius(
		unit:GetTeam(), -- int teamNumber, 
		unit:GetAbsOrigin(), -- Vector position, 
		nil, -- handle cacheUnit, 
		400, -- float radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, -- int teamFilter,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, -- int typeFilter, 
		DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, -- int flagFilter, 
		FIND_ANY_ORDER, -- int order, 
		false -- bool canGrowCache
	)

	for n,neighUnit in pairs(neighbours) do

        local dmg_to_enemies = dmg
        if dmg_to_enemies < 10 then
            dmg_to_enemies = 3
        end

		ApplyDamage({
			victim = neighUnit,
			attacker = unit,
			damage = dmg_to_enemies,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
			ability = nil
		})
        
    end

    if dmg < 5 then
        dmg = 5
    end

    ApplyDamage({
        victim = unit,
        attacker = unit,
        damage = dmg,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
        ability = nil
    })
end