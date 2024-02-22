
LinkLuaModifier("modifier_attack_orbital", "modifiers/modifier_vortex", LUA_MODIFIER_MOTION_NONE)

modifier_vortex = class({})
modifier_vortex.orbitals = {}
modifier_vortex.ability_data = {}

function modifier_vortex:IsPermanent() return true end

function modifier_vortex:OnCreated()
end

function modifier_vortex:DeclareFunctions()
    return {
        -- MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_vortex:OnTakeDamage( params )
	if IsClient() then return end
	if params.attacker==self:GetParent() and params.inflictor and self.ability_data[ params.inflictor:GetName() ]~=nil then
		self:CreateAttackOrbital( params.unit:GetOrigin(), 6, params.unit )
	end
end

function modifier_vortex:CreateAttackOrbital( origin, duration, victim )
	local hero = self:GetParent()
	local newOrbital = CreateUnitByName("npc_dota_orbital_sprite", origin, false, hero, hero, hero:GetTeam())
	local pfx = ParticleManager:CreateParticle( "particles/orbitals/orbital_ice_trail.vpcf", PATTACH_CENTER_FOLLOW, newOrbital)
	-- print("These are orbitals:")
	table.insert( self.orbitals, newOrbital )
	-- DeepPrint( self.orbitals )
	local modifier = newOrbital:AddNewModifier( hero, self, "modifier_attack_orbital", { duration = duration } )
	modifier.recentVictims = {}
	modifier.recentVictims[victim] = GameRules:GetGameTime()
	modifier.pfx = pfx
	modifier.trigger_ability = ability
	-- print( "modifier was added...?" )
end

---------------------------

modifier_attack_orbital = class ({})
modifier_attack_orbital.trigger_ability = nil
modifier_attack_orbital.creation_time = nil

function modifier_attack_orbital:RemoveOnDeath() return true end

function modifier_attack_orbital:OnCreated()
	self.creation_time = GameRules:GetGameTime()
    if IsClient() then return end
    -- print( "Server says Caster is... " .. self:GetCaster():GetName() )
    self.interval = 0
    self.radius = RandomInt(50,60) * 10
    self.start_time = GameRules:GetGameTime()
    self.casterPos = self:GetCaster():GetAbsOrigin()
	self.targetPos = self:GetParent():GetAbsOrigin()
    self.startVector = ( self.targetPos - self.casterPos ):Normalized()
	self.recentWindow = 0.5
    self:StartIntervalThink( FrameTime() )
end

function modifier_attack_orbital:OnDestroy()
	if self.pfx~=nil then
		ParticleManager:DestroyParticle( self.pfx, true )
	end
	UTIL_Remove( self:GetParent() )
end

function modifier_attack_orbital:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end

function modifier_attack_orbital:OnIntervalThink()
	if IsServer() then
		local currentTime = GameRules:GetGameTime()

		self.interval = self.interval + 1
		local interval = self.interval

		local caster 					= self:GetCaster()
		local caster_position 			= caster:GetAbsOrigin()
		local elapsedTime 				= currentTime - self.start_time
		local radius = GetDistToEntity( self.casterPos, self.targetPos )
		local circumf = radius * math.pi
		local dist_per_deg = circumf/360
		local speed = 300 + radius/2
		local turn_rate = speed/dist_per_deg

		local orbital = self:GetParent()

		local currentRotationAngle	= elapsedTime * turn_rate -- minus parent_yaw?

		if not orbital:IsNull() then

			-- Rotate
			local rotationAngle = currentRotationAngle
			local relPos 		= self.startVector * radius
			relPos 				= RotatePosition(Vector(0,0,0), QAngle( 0, -rotationAngle, 0 ), relPos)
			local absPos 		= GetGroundPosition( relPos + caster_position, orbital)

			orbital:SetAbsOrigin(absPos)

		end
    end

	local targets = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		self:GetCaster(),
		25,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		FIND_ANY_ORDER,
		false
	)

	for i=1,#targets do
		local shouldHit = false

		-- if self.creation_time and (GameRules:GetGameTime() - self.creation_time < 0.3) then
		-- 	print( "orbital is too young to attack" )
		-- else
		-- 	shouldHit = true
		-- end

		if self.recentVictims[targets[i]]~=nil and self.recentVictims[targets[i]]~="" then
			-- print("monster has been hit before. This long ago:")
			-- print( GameRules:GetGameTime() - self.recentVictims[targets[i]] )
			if ( GameRules:GetGameTime() - self.recentVictims[targets[i]] ) >= self.recentWindow then
				-- print("monster has been hit before, but it's been a while.")
				shouldHit = true
			else
				-- print("monster was hit recently...")
				shouldHit = false
			end
		elseif self.recentVictims[targets[i]]==nil or self.recentVictims[targets[i]]=="" then
			-- print("monster hasn't been hit yet")
			shouldHit = true
		else
			-- print("monster was hit recently...")
			--otherwise shouldHit stay false
		end

		if shouldHit then
			
			self.recentVictims[targets[i]] = {}
			self.recentVictims[targets[i]] = GameRules:GetGameTime()
			local ability_proc_chance = 25
			local proc = RandomInt( 1,100 ) <= ability_proc_chance

			print( "Performing attack via orbital. Proc bool is ", proc )
			self:GetCaster():PerformAttack(
				targets[i],
				true, -- useCastAttackOrb
				proc, -- processProcs
				true, -- skip attack cooldown
				false, -- ignoreInvis
				false, -- use projectile
				true, -- fake attack
				true -- never miss
			)

			local damage_table = {
				victim = targets[i],
				attacker = self:GetCaster(),
				damage = 30,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = nil
			}
			ApplyDamage( damage_table )

		end
	end
end

function GetDistToEntity(pos1, pos2)
	local dx = pos1.x - pos2.x
	local dy = pos1.y - pos2.y
	local distanceToEnt = math.sqrt ( dx * dx + dy * dy )
	return distanceToEnt
end