modifier_spread = class({})
modifier_spread.ability_data = {}
modifier_spread.shield = 0

function modifier_spread:IsHidden() return true end
function modifier_spread:IsPermanent() return true end

function modifier_spread:OnCreated()
end

function modifier_spread:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

function modifier_spread:OnAbilityFullyCast( params )

    local ability = params.ability

    if params.unit==self:GetParent() and self.ability_data[ ability:GetName() ]~=nil then
        local pos = ability:GetCaster():GetAbsOrigin()
        local cast_pos = ability:GetCursorPosition()
        local cast_dist = ability:GetCaster():GetDistToPos(cast_pos)
        local spread = 35
        local qty = 1
    
        ability:SplitSubcast( ability:GetName(), pos, self:GetCaster():GetLocalAngles(), 2, ability:GetCastPoint(), -spread, -spread, 1, cast_dist, 1, 1, 1, 0 )
        ability:SplitSubcast( ability:GetName(), pos, self:GetCaster():GetLocalAngles(), 2, ability:GetCastPoint(), spread, spread, 1, cast_dist, 1, 1, 1, 0 )
    end
end