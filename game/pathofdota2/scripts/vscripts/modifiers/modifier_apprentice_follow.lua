modifier_apprentice_follow = class({})

function modifier_apprentice_follow:IsHidden() return true end
function modifier_apprentice_follow:IsPermanent() return true end

function modifier_apprentice_follow:OnCreated()
    self:StartIntervalThink(1)
end

function modifier_apprentice_follow:OnIntervalThink()
    local unit = self:GetParent()
    local owner = unit:GetOwner()
    if owner and unit:GetAggroTarget()==nil and owner:GetAggroTarget()==nil then
        -- unit:MoveToPosition( owner:GetAbsOrigin())
        unit:MoveToNPC( owner )
        unit:SetFollowRange( 100 )
    elseif owner and owner:GetAggroTarget()~=nil then
        unit:SetAggroTarget( owner:GetAggroTarget() )
    end
end

function modifier_apprentice_follow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_apprentice_follow:GetModifierTotalDamageOutgoing_Percentage()
    return -50
end

