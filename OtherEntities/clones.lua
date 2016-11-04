Clone = {}

Clone.new = function(x, y, quadrant, speedx, speedy)
  local self = self or {}

  self.x = x
  self.y = y
  self.quadrant = quadrant
  self.speedX = speedx
  self.speedY = speedy
  self.range = 40
  self.radius = 20
  self.color = {249, 139, 146}
  self.type = "clone"

  self.real = {}
    self.real.autoAttackTimer = 0
    self.real.health = 1

  self.die = function()
    local invertedEntityArray = invertTable(entityArray)
    table.remove(entityArray, invertedEntityArray[self])
    table.remove(clone, 1)
  end

  self.draw = function()
    love.graphics.setColor(self.color);
    love.graphics.circle("fill", self.x, self.y, self.radius, 128)
  end

  self.drawHealthBar = function()
    return
  end

  self.move = function()
    if self.range > 0 then
      self.x = self.x + self.speedX
      self.y = self.y + self.speedY
      self.range = self.range - 1
    else
      self.die()
    end
  end

  self.regen = function()
    return
  end

  return self
end
