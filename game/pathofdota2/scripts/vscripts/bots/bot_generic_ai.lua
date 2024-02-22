LinkLuaModifier( "modifier_boss_restrained", "modifiers/modifier_boss_restrained", LUA_MODIFIER_MOTION_NONE )
-- require("maze_settings")

function Spawn( entityKeyValues )
    if thisEntity == nil then return end

    if IsClient() then return end

	thisEntity:SetContextThink( "CreatureThink", CreatureThink, 0.1 )
end

function CreatureThink()
  -- print("encounter spawner dummy is thinking...")

  if GameRules:IsGamePaused() or GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME then
      return 1
  end

  if thisEntity == nil then return end

  if IsClient() then return end

  return 0.2
end