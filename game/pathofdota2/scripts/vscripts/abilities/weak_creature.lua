LinkLuaModifier("modifier_weak_creature", "abilities/weak_creature", LUA_MODIFIER_MOTION_NONE )

weak_creature = class ({})
weak_creature.max_radius = 10000
weak_creature.max_length = 10000

function weak_creature:Spawn()
	self.damage = 1
	self.radius = 1
	self.heal = 1
	self.mana = 1
	self:GetCaster().cast_recently = false
end

function weak_creature:GetIntrinsicModifierName()
  return "modifier_weak_creature"
end

modifier_weak_creature = modifier_weak_creature or class({})

function modifier_weak_creature:GetTexture() return "item_blades_of_attack" end

function modifier_weak_creature:IsPermanent() return true end
function modifier_weak_creature:RemoveOnDeath() return true end
function modifier_weak_creature:IsDebuff() return true end
function modifier_weak_creature:IsPurgable() return false end
function modifier_weak_creature:IsHidden() return true end

function modifier_weak_creature:CheckState()
	local state = {
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true, --breaks swashbuckle
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
		[MODIFIER_STATE_IGNORING_STOP_ORDERS] = true
	}
	return state
end

function modifier_weak_creature:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MP_RESTORE_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

function modifier_weak_creature:OnCreated()
    if not IsServer() then return end
	self.max_radius = self:GetAbility().max_radius
	self.max_length = self:GetAbility().max_length
	self.damage_percent = 100
	self.heal_percent = 100
	self.mana_percent = 100
	self.radius_percent = 100
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.5)
end

function modifier_weak_creature:OnIntervalThink()
    self:OnRefresh()
	if self:GetParent():IsChanneling() then
		local parent = self:GetParent().hero_parent
		if parent then
			if not parent:IsChanneling() then
				self:GetParent():Stop()
			end
		end
	end
end

function modifier_weak_creature:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_weak_creature:CloneCasterHero( mod )
	local original_ability = self:GetAbility().original_ability
	local hero = original_ability:GetCaster()
	local sub_caster = self:GetParent()

	if sub_caster then
		print(hero:GetUnitName())
		print(sub_caster:GetUnitName())
		for i=0,5 do
			local new_item = hero:GetItemInSlot(i)
			if new_item then
				local old_item = sub_caster:GetItemInSlot(i)
				if old_item then
					sub_caster:RemoveItem( old_item )
				end
				print(new_item:GetAbilityName())
				sub_caster:AddItemByName( new_item:GetAbilityName() )
			end
		end

		-- subcaster:SetModel( hero:GetModelName() )
		-- subcaster:SetModelScale( 0.0000001 )
		sub_caster:SetBaseDamageMin( hero:GetBaseDamageMin() )
		sub_caster:SetBaseDamageMax( hero:GetBaseDamageMax() )
	end
end

function modifier_weak_creature:OnAbilityExecuted( params )

	if params.unit==self:GetParent() then
		self:CloneCasterHero( self )
	end
end

function modifier_weak_creature:OnAbilityFullyCast( params )
	if params.unit==self:GetParent() then
		local duration_name = params.ability:GetFirstAbilitySpecialNameContaining("duration")
		local duration = 8
		if duration_name then
			duration = params.ability:GetSpecialValueFor( duration_name )
		end
		Timers:CreateTimer( duration, function()
			local parent = self:GetParent()
			if not parent:GetCurrentActiveAbility() then
				parent:SetAbsOrigin( Vector(99999,99999,0) )
			end
			return nil
		end)
	end
end

function modifier_weak_creature:AddCustomTransmitterData()
    return {
		damage_percent = self.damage_percent,
		heal_percent = self.heal_percent,
		mana_percent = self.mana_percent,
		radius_percent = self.radius_percent,
		max_radius = self.max_radius,
		max_length = self.max_length,
	}
end

function modifier_weak_creature:HandleCustomTransmitterData( data )
	self.damage_percent = data.damage_percent
	self.heal_percent = data.heal_percent
	self.mana_percent = data.mana_percent
	self.radius_percent = data.radius_percent
	self.max_radius = data.max_radius
	self.max_length = data.max_length
end

function modifier_weak_creature:GetModifierDamageOutgoing_Percentage()
	return -100 + (self.damage_percent * self:GetAbility().damage)
end

function modifier_weak_creature:GetModifierHealAmplify_PercentageSource()
	return -100 + (self.heal_percent * self:GetAbility().heal)
end

function modifier_weak_creature:GetModifierMPRestoreAmplify_Percentage()
	return -100 + (self.mana_percent * self:GetAbility().mana)
end

function modifier_weak_creature:GetModifierOverrideAbilitySpecial( params )
	if params.ability:IsItem() then return 0 end
    return 1
end

function modifier_weak_creature:GetModifierOverrideAbilitySpecialValue( params )

	if params.ability:IsItem() then return end

	local szAbilityName = params.ability:GetAbilityName()
	local szSpecialValueName = params.ability_special_value
	local nSpecialLevel = params.ability_special_level
	local base_value = params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, nSpecialLevel )
	local ability = self:GetAbility()

	if string.match(szSpecialValueName, "radius") then
		base_value = base_value * (ability.radius) * ( self.radius_percent/100 )
		if base_value > self.max_radius then
			base_value = self.max_radius
		end
	end

	if string.match(szSpecialValueName, "distance") or string.match(szSpecialValueName, "dist") then
		-- print(ability.max_length)
		if string.match(szSpecialValueName, "length_buffer") then
			return 1
		end
		if base_value > ability.max_length then
			base_value = ability.max_length
		end
	end

	if szAbilityName == "earthshaker_fissure" and string.match(szSpecialValueName, "CastRange") then
		if base_value > ability.max_length then
			base_value = ability.max_length
		end
	end

	return base_value
end

function modifier_weak_creature:GetModifierPercentageCooldown()
	return 100
end