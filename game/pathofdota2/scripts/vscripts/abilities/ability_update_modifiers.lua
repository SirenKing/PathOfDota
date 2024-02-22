ability_update_modifiers = class ({})

function ability_update_modifiers:OnHeroCalculateStatBonus()
    Timers:CreateTimer( FrameTime(), function()
        local refresh_table = {
            "modifier_second_wind",
            "modifier_conc_aoe",
            "modifier_increased_aoe",
        }
        local hero = self:GetCaster()
        for i=1,#refresh_table do
            local i_mod = hero:FindModifierByName( refresh_table[i] )
            if i_mod then
                print( "Refreshing mod: ", i_mod:GetName() )
                i_mod:OnRefresh()
            end
        end
        return nil
    end)
end