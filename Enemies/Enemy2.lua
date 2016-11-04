Enemy2 = {}

Enemy2.new = function (x, y, radius, level)
  local self = self or {}
  local dt = love.timer.getDelta()

  self.x = x
  self.y = y
  self.radius = radius
  self.level = level
  self.color = {38, 149, 34}

  self.base = {}
    self.base.autoAttackTimer = 20
    self.base.healthRegen = 1
    self.base.maxHealth = 200

  self.current = {}
    self.current.autoAttackTimer = 20
    self.current.healthRegen = self.base.healthRegen
    self.current.maxHealth = self.base.maxHealth

  self.real = {}
    self.real.autoAttackTimer = 0
    self.real.health = self.current.maxHealth

  self.die = function()
    entityArray[1].levelUp()
    entityArray[1].xp = entityArray[1].xp + 10
    local invertedEntityArray = invertTable(entityArray)
    table.remove(entityArray, invertedEntityArray[self]) --TODO: Find a better way to do this, without using a for statement as if we have a "double boss" then this way sucks
    makeLoot(self.x, self.y)
  end

  self.draw = function()
    love.graphics.setColor(self.color);
    love.graphics.circle("fill", self.x, self.y, self.radius, 128)
  end

  self.drawHealthBar = function()
    love.graphics.setColor(256,0,0)
    love.graphics.rectangle("fill", (self.x - self.radius), (self.y - self.radius) - 8, (self.radius * 2), 3)
    love.graphics.setColor(0,256,0)
    love.graphics.rectangle("fill", (self.x - self.radius), (self.y - self.radius) - 8, ((self.real.health / self.current.maxHealth) * (self.radius * 2)), 3)
  end

  self.move = function()
    return
  end

  self.regen = function()
    if self.real.health < self.current.maxHealth and self.real.health + (self.current.healthRegen * dt) < self.current.maxHealth then
      self.real.health = self.real.health + (self.current.healthRegen * dt)
    elseif self.real.health < self.current.maxHealth then
      self.real.health = self.current.maxHealth
    end
  end

  return self
end
