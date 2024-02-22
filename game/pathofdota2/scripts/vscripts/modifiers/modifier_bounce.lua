modifier_bounce = class({})
modifier_bounce.ability_data = {}

function modifier_bounce:IsHidden() return true end
function modifier_bounce:IsPermanent() return true end

function modifier_bounce:DeclareFunctions()
    return {
        MODIFIER_EVENT_SPELL_APPLIED_SUCCESSFULLY
    }
end

function modifier_bounce:OnSpellAppliedSuccessfully( event )
    local ability = event.ability
    local target = event.target
    local new_pos = event.new_pos
    local order_type = event.order_type
    local unit = event.unit
    local caster = ability:GetCaster()
    local parent = self:GetParent()

    if caster==parent then
        -- print("Raar! This fired...")
    end
end