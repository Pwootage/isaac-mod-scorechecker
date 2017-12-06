-- Debugging if you need it
--require("mobdebug").start()
--package.path = package.path .. ";F:/steam/steamapps/common/The Binding of Isaac Rebirth/?.lua"

scorechecker = RegisterMod("ScoreChecker", 1)

json = require("json")
-- Load constants
package.loaded["constants"] = nil
package.loaded["scoreCalculator"] = nil
require("constants")
local scoreCalculator = require("scoreCalculator")

scoreState = {}

function scorechecker:initScorestate()
  Isaac.DebugString("Initializing score state")
  scoreState = {
    lastPickup = nil,
    stages = {},
    bossRush = false,
    hush = false,
    megaSatan = false,
    lamb = false,
    xxx = false
  }
end
scorechecker:initScorestate()

function scorechecker:render()
  --local game = Game();
  local player = Isaac.GetPlayer(0)

  local collectibleCount = player:GetCollectibleCount();

  local y = 30
  Isaac.RenderText("Collectables: "..player:GetCollectibleCount(), 30, y, 255, 255, 255, 255)
  y = y + 10
  Isaac.RenderText("Stage bonus: "..scoreCalculator:stageBonus(), 30, y, 255, 255, 255, 255)
  y = y + 10
  Isaac.RenderText("Schwag bonus: "..scoreCalculator:schwagBonus(), 30, y, 255, 255, 255, 255)
  y = y + 10
  Isaac.RenderText("Rush bonus: "..scoreCalculator:rushBonus(), 30, y, 255, 255, 255, 255)
  y = y + 10
  Isaac.RenderText("Mega satan bonus: "..scoreCalculator:megaSatanBonus(), 30, y, 255, 255, 255, 255)
  y = y + 10
  Isaac.RenderText("Lamb bonus: "..scoreCalculator:lambBonus(), 30, y, 255, 255, 255, 255)
  y = y + 10
  Isaac.RenderText("??? bonus: "..scoreCalculator:xxxBonus(), 30, y, 255, 255, 255, 255)
  y = y + 10
  Isaac.RenderText("Time penalty: "..scoreCalculator:timePenalty(), 30, y, 255, 255, 255, 255)
  y = y + 10
  Isaac.RenderText("collectible penalty: "..scoreCalculator:collectablePenalty(), 30, y, 255, 255, 255, 255)
  y = y + 10
  Isaac.RenderText("Item penalty: "..scoreCalculator:itemPenalty(), 30, y, 255, 255, 255, 255)

  y = y + 10
  if scoreState.lastPickup then
    Isaac.RenderText("Last Pickup: "..scoreState.lastPickup, 30, y, 255, 255, 255, 255)
  else
    Isaac.RenderText("No pickups yet", 30, y, 255, 255, 255, 255)
  end

  local status, result = pcall(json.encode, scoreState)
  if status then
    Isaac.RenderText("State: "..result, 60, 140, 255, 255, 255, 255)
  else
    Isaac.RenderText("State: "..result, 60, 140, 255, 255, 255, 255)
  end

end

function scorechecker:pickupCollide(pickup, collider, low)
  if collider.Type ~= EntityType.ENTITY_PLAYER then
    return
  end

  local pickupType = pickup.Variant
  Isaac.DebugString("Pickup variant "..pickupType)
  scoreState.lastPickup = PICKUP_VARIANT_STRINGS[pickupType] or nil
end

function scorechecker:newLevel()
  local game = Game()
  local stage = game:GetLevel():GetStage()
  table.insert(scoreState.stages, stage)
  Isaac.DebugString("New level"..stage)
  Isaac.DebugString("Levels so far"..json.encode(scoreState.stages))
end

function scorechecker:gameStart(fromSaveState)
  if fromSaveState then
    local str = Isaac.LoadModData(scorechecker)
    if str then
      Isaac.DebugString("Loaded data: "..str)
      local state = json.decode(str)
      scoreState = state
    end
  end
end

function scorechecker:gameExit(shouldSave)
  if shouldSave then
    local str = json.encode(scoreState)
    Isaac.SaveModData(scorechecker, str)
    Isaac.DebugString("Saved data: "..str)
  end
  scorechecker.initScorestate()
end

function scorechecker:postRoom()
  Isaac.DebugString("Post room?")
  local game = Game()
  local room = game:GetRoom()

end

scorechecker:AddCallback(ModCallbacks.MC_POST_RENDER, scorechecker.render)
scorechecker:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, scorechecker.pickupCollide)
scorechecker:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, scorechecker.newLevel)
scorechecker:AddCallback(ModCallbacks.MC_POST_GAME_STARTED , scorechecker.gameStart)
scorechecker:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, scorechecker.gameExit)
scorechecker:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, scorechecker.postRoom)
