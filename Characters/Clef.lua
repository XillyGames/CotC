require("OtherEntities.clones")

Clef = {}

Clef.new = function (x, y, radius)
  local self = self or {}
  local dt = love.timer.getDelta()

  clone = {}

  self.x = x
  self.y = y
  self.radius = radius
  self.level = 1
  self.color = {249, 139, 146}
  self.resource = 'mana'
  self.name = 'Clef'
  self.aimAngle = ""
  self.characterClass = "Sorcery"
  self.inUlt = false
  self.xp = 0
  self.xpToLevel = 100

  --How much each of the character's stats grow when they level up
  self.levelModifier = {}
    self.levelModifier.abilityDamageModifier = 1.02
    self.levelModifier.autoAttackDamage = 1.05
    self.levelModifier.autoAttackRange = 1
    self.levelModifier.autoAttackTimer = 0.98
    self.levelModifier.cooldownReduction = 0.995
    self.levelModifier.healthRegen = 1.02
    self.levelModifier.maxHealth = 1.05
    self.levelModifier.maxResource = 1.02
    self.levelModifier.movementSpeed = 1
    self.levelModifier.resourceRegen = 1.01

  --The base attrs and values
  self.base = {}
    self.base.abilityDamageModifier = 1
    self.base.autoAttackDamage = 8
    self.base.autoAttackRange = 20
    self.base.autoAttackTimer = 50
    self.base.cooldownReduction = 1
    self.base.healthRegen = 1
    self.base.maxHealth = 450
    self.base.maxResource = 200
    self.base.movementSpeed = 5
    self.base.resourceRegen = 2

  --The current attrs and values
  self.current = {}
    self.current.abilityDamageModifier = self.base.abilityDamageModifier
    self.current.autoAttackDamage = self.base.autoAttackDamage
    self.current.autoAttackRange = self.base.autoAttackRange
    self.current.autoAttackTimer = self.base.autoAttackTimer
    self.current.cooldownReduction = self.base.cooldownReduction
    self.current.healthRegen = self.base.healthRegen
    self.current.maxHealth = self.base.maxHealth
    self.current.maxResource = self.base.maxResource
    self.current.movementSpeed = self.base.movementSpeed
    self.current.resourceRegen = self.base.resourceRegen

  --These are the things that can change in the game, but not just when we level up etc.
  self.real = {}
    self.real.autoAttackTimer = 0
    self.real.chord = 0
    self.real.health = self.current.maxHealth
    self.real.movementSpeed = 200 * dt --*40 * dt
    self.real.note = 0
    self.real.resource = self.current.maxResource

  self.chord = {}
    self.chord.C = 0
    self.chord.Db = 1
    self.chord.D = 2
    self.chord.Eb = 3
    self.chord.E = 4
    self.chord.F = 5
    self.chord.Gb = 6
    self.chord.G = 7
    self.chord.Ab = 8
    self.chord.A = 9
    self.chord.Bb = 10
    self.chord.B = 11

  self.notes = {}
    self.notes.C = 0, 4, 7
    self.notes.Db = 1, 5, 8
    self.notes.D = 2, 6, 9
    self.notes.Eb = 3, 7, 10
    self.notes.E = 4, 8, 11
    self.notes.F = 5, 9, 0
    self.notes.Gb = 6, 10, 1
    self.notes.G = 7, 11, 2
    self.notes.Ab = 8, 0, 3
    self.notes.A = 9, 1, 4
    self.notes.Bb = 10, 2, 5
    self.notes.B = 11, 3, 6

  self.abilities = {}
    self.abilities.ability1 = {}
      self.abilities.ability1.currentCooldown = 15 * self.current.cooldownReduction
      self.abilities.ability1.damage = 30
      self.abilities.ability1.range = 50
      self.abilities.ability1.realCooldown = 0
      self.abilities.ability1.resourceCost = 50
      self.abilities.ability1.name = "Trumpwn"
    self.abilities.ability2 = {}
      self.abilities.ability2.currentCooldown = (15 * self.current.cooldownReduction)
      self.abilities.ability2.realCooldown = 0
      self.abilities.ability2.resourceCost = 30
      self.abilities.ability2.name = "Key Change"
    self.abilities.ability3 = {}
      self.abilities.ability3.currentCooldown = 25 * self.current.cooldownReduction
      self.abilities.ability3.realCooldown = 0
      self.abilities.ability3.resourceCost = 40
      self.abilities.ability3.name = "Treble Clef"
    self.abilities.ability4 = {}
      self.abilities.ability4.autoCount = 0 --TODO - change this to the amount of attacks that they can fit into a period of time
      self.abilities.ability4.numberOfAutos = 9
      self.abilities.ability4.currentCooldown = 50 * self.current.cooldownReduction
      self.abilities.ability4.realCooldown = 0
      self.abilities.ability4.resourceCost = 80
      self.abilities.ability4.name = "Going Solo"
      self.abilities.ability4.timer = 0

  self.inventory = {}
    self.inventory.cap = {}
    self.inventory.vest = {}
    self.inventory.leggings = {}
    self.inventory.boots = {}

  self.autoAttack = function()
    autoAttack = {}
    autoAttack.x = self.x
    autoAttack.y = self.y
    autoAttack.speedx = math.cos(self.aimAngle) * 5 --* dt
    autoAttack.speedy = math.sin(self.aimAngle) * 5 --* dt
    autoAttack.range = self.current.autoAttackRange
    autoAttack.owner = self.name
    autoAttack.damage = self.passive()
    autoAttack.radius = 5
    table.insert(autoAttacks, autoAttack)
    if self.inUlt == false then
      self.real.autoAttackTimer = self.current.autoAttackTimer
    elseif self.inUlt == true then
      self.real.autoAttackTimer = 10
      if self.abilities.ability4.autoCount > 0 then
        self.abilities.ability4.autoCount = self.abilities.ability4.autoCount - 1
        self.abilities.ability4.timer = 0
      else
        self.inUlt = false
        self.real.autoAttackTimer = self.current.autoAttackTimer
        self.abilities.ability4.realCooldown = self.abilities.ability4.currentCooldown
        self.abilities.ability4.timer = 0
      end
    end
  end

  self.doAbility1 = function()
    checkClefAbility1Collision(self.abilities.ability1.range)
    if #ClefAbility1CollisionArray >= 1 then
      for i=1,#ClefAbility1CollisionArray,1
      do
        ClefAbility1CollisionArray[i].real.health = ClefAbility1CollisionArray[i].real.health - self.abilities.ability1.damage
      end
    end
    self.real.resource = self.real.resource - self.abilities.ability2.resourceCost
    self.abilities.ability1.realCooldown = self.abilities.ability2.currentCooldown
  end

  self.doAbility2 = function()
    if self.real.chord < 10 then
      self.real.chord = self.real.chord + 1
    else
      self.real.chord = 1
    end
    self.real.resource = self.real.resource - self.abilities.ability2.resourceCost
    self.abilities.ability2.realCooldown = self.abilities.ability2.currentCooldown
  end

  self.doAbility3 = function()
    for i=1,2,1
    do
      local cloneQuadrant = math.random(4)
      if i~= 1 and cloneQuadrant == clone[i-1].quadrant then
        if cloneQuadrant ~= 4 then
          cloneQuadrant = cloneQuadrant + 1
        else
          cloneQuadrant = 1
        end
      end
      local cloneX = ""
      local cloneY = ""
      if cloneQuadrant == 1 then
        cloneX = self.x + (self.radius * 2)
        cloneY = self.y - (self.radius * 2)
      elseif cloneQuadrant == 2 then
        cloneX = self.x - (self.radius * 2)
        cloneY = self.y - (self.radius * 2)
      elseif cloneQuadrant == 3 then
        cloneX = self.x - (self.radius * 2)
        cloneY = self.y + (self.radius * 2)
      else
        cloneX = self.x + (self.radius * 2)
        cloneY = self.y + (self.radius * 2)
      end
      local n = cloneQuadrant
      local x, y = camera:worldCoords(cloneX, cloneY)
      local v = {x = cloneX - self.x, y = cloneY - self.y}
      local angle = math.atan2(v.y, v.x)
      angle = math.deg(angle)
      angle = angle + math.random(-45, 45)
      angle = math.rad(angle)
      local speedx = math.cos(angle) * self.real.movementSpeed
      local speedy = math.sin(angle) * self.real.movementSpeed
      clone[i] = Clone.new(cloneX, cloneY, cloneQuadrant, speedx, speedy)
      table.insert(entityArray, clone[i])
    end

    self.real.resource = self.real.resource - self.abilities.ability3.resourceCost
    self.abilities.ability3.realCooldown = self.abilities.ability3.currentCooldown
  end

  self.doAbility4 = function()
    self.inUlt = true
    self.real.autoAttackTimer = 0
    self.abilities.ability4.autoCount = self.abilities.ability4.numberOfAutos
    self.real.resource = self.real.resource - self.abilities.ability4.resourceCost
  end

  self.draw = function()
    love.graphics.setColor(self.color);
    love.graphics.circle("fill", self.x, self.y, self.radius, 128)
  end

  self.drawHealthBar = function()
    if clone[1] == nil then
      love.graphics.setColor(256,0,0)
      love.graphics.rectangle("fill", (self.x - self.radius), (self.y - self.radius) - 8, self.radius * 2, 3)
      love.graphics.setColor(0,256,0)
      love.graphics.rectangle("fill", (self.x - self.radius), (self.y - self.radius) - 8, ((self.real.health / self.current.maxHealth) * (self.radius * 2)), 3)
      love.graphics.setColor(0,0,0)
      love.graphics.rectangle("fill", (self.x - self.radius), (self.y - self.radius) - 5, self.radius * 2, 3)
      love.graphics.setColor(176,224,230)
      love.graphics.rectangle("fill", (self.x - self.radius), (self.y - self.radius) - 5, ((self.real.resource / self.current.maxResource) * (self.radius * 2)), 3)
   end
  end

  self.levelUp = function()
    self.level = self.level + 1
    self.recalStats()
  end

  self.move = function ()
      if(love.keyboard.isDown("a")) then
        self.x = self.x - self.real.movementSpeed
      end
      if(love.keyboard.isDown("s")) then
        self.y = self.y + self.real.movementSpeed
      end
      if(love.keyboard.isDown("d")) then
        self.x = self.x + self.real.movementSpeed
      end
      if(love.keyboard.isDown("w")) then
        self.y = self.y - self.real.movementSpeed
      end
    collision = checkEntityToEntityCollision(self)
    if (collision) then
      local e1x, e1y = camera:worldCoords(collision.x, collision.y)
      local e2x, e2y = camera:worldCoords(self.x, self.y)
      local v = {x = e1x - e2x, y = e1y - e2y}
      local angleBetweenEntities = math.deg(math.atan2(v.y, v.x))
      local angleBetweenEntities = angleBetweenEntities + 180
      if angleBetweenEntities >= 0 and angleBetweenEntities < 90 then
        self.x = self.x + self.current.movementSpeed
        self.y = self.y + self.current.movementSpeed
      elseif angleBetweenEntities >= 90 and angleBetweenEntities < 180 then
        self.x = self.x - self.current.movementSpeed
        self.y = self.y + self.current.movementSpeed
      elseif angleBetweenEntities >= 180 and angleBetweenEntities < 270 then
        self.x = self.x - self.current.movementSpeed
        self.y = self.y - self.current.movementSpeed
      else
        self.x = self.x + self.current.movementSpeed
        self.y = self.y - self.current.movementSpeed
      end
    end
  end

  self.passive = function()
    local baseDamage = self.current.autoAttackDamage
    if ((self.real.chord == 1 or self.real.chord == 3 or self.real.chord == 6 or self.real.chord == 8 or self.real.chord == 10) and self.real.note == 0) then
      damage = baseDamage * 1.1 --TODO - change this so that it scales per level of the user
    elseif((self.real.chord == 2 or self.real.chord == 4 or self.real.chord == 6 or self.real.chord == 9 or self.real.chord == 11) and self.real.note == 1) then
      damage = baseDamage * 1.1 --TODO - change this so that it scales per level of the user
    elseif((self.real.chord == 1 or self.real.chord == 3 or self.real.chord == 6 or self.real.chord == 8 or self.real.chord == 11) and self.real.note == 2) then
      damage = baseDamage * 1.1 --TODO - change this so that it scales per level of the user
    else
      damage = baseDamage
    end
    if(self.real.note < 2) then
      self.real.note = self.real.note + 1
    else
      self.real.note = 0
    end
    return damage
  end

  self.recalStats = function()
    for stat, value in pairs(self.current)
    do
      local healthPercentage = self.real.health / self.current.maxHealth
      local resourcePercentage = self.real.resource / self.current.maxResource
      self.current[stat] = self.base[stat] * (math.pow(self.levelModifier[stat], self.level - 1))
      for slot, item in pairs(self.inventory)
      do
        if self.inventory[slot].modifier and self.inventory[slot].modifier[stat] == stat and (stat == "cooldownReduction" or stat == "autoAttackTimer") then
          self.current[stat] = self.current[stat] / self.inventory[slot].quality.multiplier
        elseif self.inventory[slot].modifier and self.inventory[slot].modifier.stat == stat then
          self.current[stat] = self.current[stat] * self.inventory[slot].quality.multiplier
        end
      end
      self.real.health = healthPercentage * self.current.maxHealth
      self.real.resource = resourcePercentage * self.current.maxResource
    end
  end

  self.reduceCooldowns = function()
    for i=1,4,1
    do
      if self.abilities['ability'..i].realCooldown > 0 then
        self.abilities['ability'..i].realCooldown = self.abilities['ability'..i].realCooldown - dt
      elseif self.abilities['ability'..i].realCooldown < 0 then
        self.abilities['ability'..i].realCooldown = 0
      end
    end
  end

  self.regen = function()
    if self.real.health < self.current.maxHealth and self.real.health + (self.current.healthRegen * dt) < self.current.maxHealth then
      self.real.health = self.real.health + (self.current.healthRegen * dt)
    elseif self.real.health < self.current.maxHealth then
      self.real.health = self.current.maxHealth
    end
    if self.real.resource < self.current.maxResource and self.real.resource + (self.current.resourceRegen * dt) < self.current.maxResource then
      self.real.resource = self.real.resource + (self.current.resourceRegen * dt)
    elseif self.real.resource < self.current.maxResource then
      self.real.resource = self.current.maxResource
    end
    if self.inUlt == true and self.abilities.ability4.timer < 25 then
      self.abilities.ability4.timer = self.abilities.ability4.timer + 1
    elseif self.inUlt == true and self.abilities.ability4.timer == 25 then
      self.inUlt = false
      self.abilities.ability4.realCooldown = self.abilities.ability4.currentCooldown
      self.abilities.ability4.timer = 0
      self.real.autoAttackTimer = 5
    end
  end

  return self
end
