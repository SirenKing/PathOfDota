
LinkLuaModifier("modifier_attack_orbital", "modifiers/modifier_phantom_blade", LUA_MODIFIER_MOTION_NONE)

modifier_phantom_blade = class({})
modifier_phantom_blade.orbitals = {}
modifier_phantom_blade.ability_data = {}

function modifier_phantom_blade:IsPermanent() return true end

function modifier_phantom_blade:OnCreated()
	self.last_time = 0
end

function modifier_phantom_blade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end


function modifier_phantom_blade:GetModifierPreAttack_BonusDamage()
	if self.phantom_attack == true then
		return -99999
	else
		return 0
	end
end

if IsServer() then
	function modifier_phantom_blade:OnTakeDamage( params )

		if params.attacker==self:GetParent() and params.inflictor and self.ability_data[ params.inflictor:GetName() ]~=nil then

			local time = GameRules:GetGameTime()
			local min_eslasped = 0.2
			local last_time = self.last_time

			if time-last_time>=min_eslasped then
				self.last_time = time
				Timers:CreateTimer( FrameTime(), function()
					-- print( "Enough time passed!", time - last_time )
					self.last_time = time
					self.phantom_attack = true
					self:GetCaster():PerformAttack(
						params.unit,
						false, -- useCastAttackOrb
						true, -- processProcs
						true, -- skip attack cooldown
						false, -- ignoreInvis
						false, -- use projectile
						false, -- fake attack
						true -- never miss
					)
					self.phantom_attack = false
					return nil
				end)
			end

		end
	end
end