modifier_storm_cast = class({})
modifier_storm_cast.ability_data = {}
modifier_storm_cast.shield = 0

function modifier_storm_cast:IsHidden() return true end
function modifier_storm_cast:IsPermanent() return true end

function modifier_storm_cast:OnCreated()
end

function modifier_storm_cast:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end

function modifier_storm_cast:OnAbilityExecuted( params )

    local ability = params.ability

    if params.unit==self:GetParent() and self.ability_data[ ability:GetName() ]~=nil then
        local pos = ability:GetCursorPosition()
        if pos==nil or pos==Vector(0,0,0) then
            pos = self:GetParent():GetAbsOrigin()
        end
        ability:BeginCastStormRadial( ability:GetName(), pos, 10, 0.25, 300, 900, 0.7, 0.8, 175, 350, 0.4, true )
    end
end