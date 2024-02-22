-- Partial credit to Superbia for his crit-detection code contribution
unit_gives_to_parent = class({})

function unit_gives_to_parent:IsHidden() return true end
function unit_gives_to_parent:IsPermanent() return true end

function unit_gives_to_parent:OnCreated()
    -- print( "created unit_gives_to_parent!" )
    Timers:CreateTimer( 0.1, function()
        self.hero = self:GetParent().hero_parent
        self:StartIntervalThink( 0.1 )
    end)
end

function unit_gives_to_parent:OnRemoved()
    self:StartIntervalThink( -1 )
end

function unit_gives_to_parent:UpdateCasterStats()
    -- print( "updating caster stats!" )
    local unit = self:GetParent()
    local hero = unit.hero_parent

    unit:SetMaxMana( hero:GetMaxMana() )
    unit:SetBaseDamageMax( hero:GetDamageMax() )
    unit:SetBaseDamageMin( hero:GetDamageMin() )
end

function unit_gives_to_parent:OnIntervalThink()
    -- if IsClient() then return end

    if self:GetParent().hero_parent ~= nil then
        local modifiers = self:GetParent():FindAllModifiers()
        local unit = self:GetParent()

        if unit.hero_parent~=nil and not unit:IsRealHero() then
            unit:SetAbsOrigin( unit.hero_parent:GetAbsOrigin() )
        end

        for i=1,#modifiers do
            -- print( i, "this ran {1}" )
            if modifiers[i]==self then
            elseif GEM_EXCEPTIONS["no_give_modifier"][modifiers[i]:GetName()]~=nil then
                -- print("ignoring this modifier...")
            else
                -- print( i, " this ran {2}" )
                -- print( "Found a modifier to give: ", modifiers[i]:GetName() )
                local modifier_ability = modifiers[i]:GetAbility()

                if modifier_ability then
                    local hero_ability = self.hero:FindAbilityByName( modifier_ability:GetAbilityName() )
                    if hero_ability and self.hero:HasAbility( hero_ability:GetAbilityName() ) then

                        if not self.hero:HasModifier( modifiers[i]:GetName() ) then
                            -- print( "Duration is... " .. modifiers[i]:GetDuration())
                            self.hero:AddNewModifier( self.hero, hero_ability, modifiers[i]:GetName(), { duration = 1 } )
                            local duration = modifiers[i]:GetDuration()

                            if duration and duration>0 then
                                self.hero:FindModifierByName( modifiers[i]:GetName() ):SetDuration( modifiers[i]:GetDuration(), true )
                            end
                        end

                        if modifiers[i]:GetStackCount() > 1 then
                            local new_modifier = self.hero:FindModifierByName( modifiers[i]:GetName() )
                            new_modifier:SetStackCount( modifiers[i]:GetStackCount() )

                            if string.match( modifiers[i]:GetName(), "static_link" ) then
                                modifiers[i]:SetStackCount( 0 )
                            else
                                self:GetParent():RemoveModifierByName( modifiers[i]:GetName() )
                            end
                        end

                    end
                end
            end
        end
    end
end