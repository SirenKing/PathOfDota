local Thinker = class({})

ListenToGameEvent("game_rules_state_game_in_progress", function()
	
	-- local watch_towers = Entities:FindAllByName( "npc_dota_watch_tower" )

	-- Timers:CreateTimer( 10, function() --10 minutes into the game, make watch_tower ents vulnerable
	-- 	for i=1,#watch_towers do
	-- 		print("Found a watch tower!")
	-- 		watch_towers[i]:RemoveModifierByName("modifier_invulnerable")
	-- 		watch_towers[i]:SetInvulnCount(0)
	-- 	end
	-- 	return nil
	-- end)

	Timers:CreateTimer( 2, function()		
		return 30
	end)

end, GameMode)

function Thinker:Minute00()
	print("The Game begins!")
	return nil -- does not repeat
end

function Thinker:DontForgetToSubscribe()
	-- print("20 minutes")
	return nil -- does not repeat
end

function Thinker:LateGame()
	-- print("30 minutes")
	return nil -- does not repeat
end

function Thinker:VeryVeryOften()
	-- print("every 10 seconds")
	return 10
end

function Thinker:VeryOften()
end

function Thinker:Often()
	-- print("every 5 minutes")
	return 5*60
end

function Thinker:Regular()
	-- print("every 15 minutes")
	return 15*60
end

function Thinker:Seldom()
	-- print("every 30 minutes")
	return 30*60
end

function Thinker:DoLegionLogic( heroes )
	for i=1,#heroes do
		-- DeepPrint(heroes)
		if heroes[i]:HasModifier("modifier_legion") then
			local modifier = heroes[i]:FindModifierByName("modifier_legion")
			local abilities = modifier.ability_data
			DeepPrint(abilities)
			for k,v in pairs( abilities ) do
				local ability_name = k
				print( ability_name )
				if spawn_data[ability_name]~=nil then
					local paths = {
						"mid",
						"top",
						"bot",
					}
					local team_name = nil
					if heroes[i]:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
						team_name = "good"
					else
						team_name = "bad"
					end
					for x=1,3 do
						print(spawn_data[ability_name])
						local path_point_name = "lane_" .. paths[x] .. "_pathcorner_" .. team_name .. "guys_1"
						local first_path_point = Entities:FindByName( nil, path_point_name )
						local spawn_point = Entities:FindByName( nil, "npc_dota_spawner_" .. team_name .. "_" .. paths[x] .. "_staging" )
						if first_path_point~=nil then
							local unit = CreateUnitByName( spawn_data[ability_name], spawn_point:GetOrigin(), true, nil, nil, heroes[i]:GetTeamNumber() )
							unit:SetInitialGoalEntity( first_path_point )
							if string.match( unit:GetName(), "eidolon" ) then
								unit:AddNewModifierButt( nil, nil, "modifier_demonic_conversion", {} )
							end
						end
					end
				end
			end
		end
	end
end
