modifier_apprentice_creep = class({})

function modifier_apprentice_creep:IsHidden() return true end
function modifier_apprentice_creep:IsPermanent() return true end

function modifier_apprentice_creep:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end

function modifier_apprentice_creep:GetModifierSpellAmplify_Percentage()
    return -50
end

function modifier_apprentice_creep:GetModifierPercentageCooldown()
    return -100
end
