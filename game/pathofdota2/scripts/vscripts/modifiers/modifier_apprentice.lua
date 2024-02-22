modifier_apprentice = class({})
modifier_apprentice.ability_data = {}

function modifier_apprentice:IsHidden() return true end
function modifier_apprentice:IsPermanent() return true end

function modifier_apprentice:OnCreated()
    -- if not IsServer() then return end
end