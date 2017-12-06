local scoreCalculator = {
  version = "1.0"
}

function scoreCalculator:stageBonus()
  local game = Game()
  local level = game:GetLevel():GetStage()

  return STAGE_BONUS[level] or 0
end

function scoreCalculator:rushBonus()
  local bonus = 0
  if scoreState.bossRush then
    bonus = bonus + 4444
  end
  if scoreState.hush  then
    bonus = bonus + 5555
  end
  return bonus
end

function scoreCalculator:lambBonus()
  if scoreState.lamb then
    return 4000
  else
    return 0
  end
end

function scoreCalculator:xxxBonus()
  if scoreState.lamb then
    return 4000
  else
    return 0
  end
end

function scoreCalculator:megaSatanBonus()
  if scoreState.megaSatan then
    return 6666
  else
    return 0
  end
end

function scoreCalculator:secondsPenalty()
  local game = Game()
  local seconds = game.TimeCounter / 30
  local baseStagePenalty = 0

  for i,v in ipairs(scoreState.stages) do
    local penalty = STAGE_BASE_PENALTIES[v]
    if penalty then
      baseStagePenalty = baseStagePenalty + penalty
    end
  end

  return math.exp((seconds * -0.22) / baseStagePenalty)
end

function scoreCalculator:timePenalty()
  local bonuses = self.rushBonus() +
                  self.megaSatanBonus() +
                  self.lambBonus() +
                  self.xxxBonus() +
                  self.stageBonus()

  return math.floor(math.ceil((bonuses * 0.80) * (1.0 - self.secondsPenalty())))
end

function scoreCalculator:itemPenalty()
  local schwag = self.schwagBonus()

  return math.floor(math.ceil((schwag * 0.8) * self.collectablePenalty()))
end

function scoreCalculator:collectablePenalty()
  local player = Isaac.GetPlayer(0)
  local ending = 1 -- TODO: can we actually get this?

  local collectibleCount = player:GetCollectibleCount();
  return 1.0 - math.exp((collectibleCount * -0.22) / (ending * 2.5))
end

function scoreCalculator:schwagBonus()
  local player = Isaac.GetPlayer(0)

  local goldenHearts = player:GetGoldenHearts()
  local redHeartContainers = player:GetMaxHearts()
  local redHearts = player:GetHearts()
  local soulHearts = player:GetSoulHearts()
  local blackHearts = 0 --TODO: do we need to calc this?
  local eternalHearts = player:GetEternalHearts()
  local coins = player:GetNumCoins()
  local bombs = player:GetNumBombs()
  local keys = player:GetNumKeys()
  local pickupBonus = 0 --TODO: calc based on what's picked up total

  return goldenHearts
            + 10 * (redHeartContainers
                 +  redHearts
                 +  soulHearts
                 +  blackHearts
                 +  eternalHearts
                 +  coins)
            + 20 * (keys + bombs)
            + pickupBonus
end

return scoreCalculator
