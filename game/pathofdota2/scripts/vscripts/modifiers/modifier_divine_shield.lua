modifier_divine_shield = class({})
modifier_divine_shield.ability_data = {}
modifier_divine_shield.shield = 0

function modifier_divine_shield:IsHidden() return true end
function modifier_divine_shield:IsPermanent() return true end

function modifier_divine_shield:OnCreated()
    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.1)
end

function modifier_divine_shield:OnIntervalThink()
    self:OnRefresh()
end

function modifier_divine_shield:OnRefresh()
    if IsServer() then
        self:OnCreated()
        self:SendBuffRefreshToClients()
    end
end

function modifier_divine_shield:AddCustomTransmitterData()
    return {
        ability_data = self.ability_data,
        shield = self.shield
    }
end

function modifier_divine_shield:HandleCustomTransmitterData( data )
    self.ability_data = data.ability_data
    self.shield = data.shield
end

function modifier_divine_shield:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT,
    }
end

function modifier_divine_shield:OnTakeDamage( params )
	if params.attacker==self:GetParent() and params.inflictor and self.ability_data[ params.inflictor:GetName() ]~=nil then
        self.shield = self.shield + params.damage
	end
	if params.unit==self:GetParent() then
        self.shield = self.shield - params.damage
    end
end

function modifier_divine_shield:GetModifierIncomingPhysicalDamageConstant( params )
    if IsServer() then
        return -self.shield
    end
    if IsClient() then
        return self.shield
    end
end