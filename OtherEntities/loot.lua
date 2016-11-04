Loot = {}

Loot.new = function(x, y, loot)
  local self = self or {}

  self.x = x
  self.y = y
  self.loot = loot
  self.radius = 20
  self.color = {89,11,11}
  self.type = "loot"

  self.real = {}
    self.real.health = 1
    self.real.autoAttackTimer = 0

  self.move = function()
  end

  self.update = function()
  end

  self.regen = function()
  end

  self.draw = function()
    love.graphics.setColor(self.color);
    love.graphics.circle("fill", self.x, self.y, self.radius, 128)
  end

  self.drawHealthBar = function()
  end

  return self
end
