entityArray = {}
autoAttacks = {}

function reduceAutoAttackTimer()
  for i=1,table.getn(entityArray),1
  do
    if entityArray[i].real.autoAttackTimer > 0 then
      entityArray[i].real.autoAttackTimer = entityArray[i].real.autoAttackTimer - 1
    elseif entityArray[i].real.autoAttackTimer < 0 then
      entityArray[i].real.autoAttackTimer = 0
    end
  end
end

function handleThisFrame()
  reduceAutoAttackTimer()
    for i=1,#entityArray,1
    do
      entityArray[i].regen()
    end
    entityArray[1].reduceCooldowns()
end

function checkLootHover()
  local maybeLoot = entityArray[2]
  local mblx, mbly = maybeLoot.x, maybeLoot.y
  local x, y = love.mouse.getPosition()
  local mx, my = camera:worldCoords(x,y)
  if mx > mblx - maybeLoot.radius and mx < mblx + maybeLoot.radius and my > mbly - maybeLoot.radius and my < mbly + maybeLoot.radius then
    love.graphics.setColor(51,62,98,100)
    local x, y = maybeLoot.x + (maybeLoot.radius * 2), maybeLoot.y - (maybeLoot.radius / 2) --TODO: Add a better checker to see which quad the loot is in, and adjust where we display this accordingly
    love.graphics.rectangle("fill", x, y, Font:getWidth(maybeLoot.loot.itemName) + 10, Font:getHeight(maybeLoot.loot.itemName))
    love.graphics.setColor(255,255,255)
    love.graphics.printf(maybeLoot.loot.itemName, x, y, Font:getWidth(maybeLoot.loot.itemName) + 10, "center")
  end
end

function drawEntities()
  for i=1,table.getn(entityArray),1
  do
    entityArray[i]:draw()
  end
  if entityArray[2].type == "loot" then
    checkLootHover()
  end
end

function drawEntityHealthBar()
  for i=1,table.getn(entityArray),1
  do
    entityArray[i]:drawHealthBar()
  end
end

function adjustAngle()
  local x, y = love.mouse.getPosition()
  local x, y = camera:worldCoords(x, y)
  local Player = entityArray[1]
  local v = {x = x - Player.x, y = y - Player.y}
  Player.aimAngle = math.atan2(v.y, v.x)
end

function moveEntities()
  for i=#entityArray,1,-1
  do
    entityArray[i]:move()
  end
end

function invertTable(table)
  local u = {}
  for k, v in pairs(table)
  do
    u[v] = k
  end
  return u
end

function updateAutoAttacks()
  if #autoAttacks > 0 then
    for i=#autoAttacks,1,-1
    do
      local collision = checkAutoAttackForEntityCollision(autoAttacks[i])
      if (collision) then
        collision.real.health = collision.real.health - autoAttacks[i].damage
        checkNotDead(collision)
        table.remove(autoAttacks, i)
      elseif autoAttacks[i].range < 1 then
        table.remove(autoAttacks, i)
      else
        autoAttacks[i].x = autoAttacks[i].x + autoAttacks[i].speedx
        autoAttacks[i].y = autoAttacks[i].y + autoAttacks[i].speedy
        autoAttacks[i].range = autoAttacks[i].range - 1
        drawAutoAttack(autoAttacks[i])
      end
    end
  end
end

function generateItem()
  local newItem = {}

  local iocnum = math.random(#itemOfClothing)
  local imnum = math.random(#itemModifier)
  local iqnum = math.random(#itemQuality)

  newItem.type = itemOfClothing[iocnum]
  newItem.modifier = itemModifier[imnum]
  newItem.quality = itemQuality[iqnum]
  newItem.itemName = newItem.type.." of "..newItem.quality.displayText.." "..newItem.modifier.displayText

  return newItem
end

function equipItem(item)
  local player = entityArray[1]
  local type = item.type:lower()
  player.inventory[type] = item
  player.recalStats()
end

function drawAutoAttack(autoAttack)
  love.graphics.setColor(0,0,0)
  love.graphics.circle("fill", autoAttack.x, autoAttack.y, autoAttack.radius)
end

function drawHUD()
  drawMain()
  drawInventory()
  drawMiniMap()
end

function drawMain()
  drawWrapper()
  drawHPBar()
  drawManaBar()
  drawXPBar()
  drawLevels()
  drawAbilities()
  drawExtras()
end

function drawExtras()
--[[  player = entityArray[1]
  if player.name == "Clef" then
    love.graphics.setColor(51,62,98)
    local x, y = camera:worldCoords(170, love.graphics.getHeight() - 40)
    love.graphics.rectangle("fill", x, y, 20, 20)
    love.graphics.setColor(255,255,255)
    local chords = invertTable(player.chords)
    local currentChord = chords[self.real.chord]
    love.graphics.setFont(font)
    love.graphics.printf(player.chords, x, y, 20, "center")
    love.graphics.setFont(Font)
  end]]--
end

function drawWrapper()
  love.graphics.setColor(51,62,98)
  local x, y = camera:worldCoords(200, (love.graphics.getHeight() - 50))
  love.graphics.rectangle("fill", x, y, 300, 50)
end

function drawHPBar()
  local player = entityArray[1]
  love.graphics.setColor(255,0,0)
  local x, y = camera:worldCoords(200, love.graphics.getHeight() - 70)
  love.graphics.rectangle("fill", x, y, 300, 10)
  love.graphics.setColor(0,255,0)
  love.graphics.rectangle("fill", x, y, ((player.real.health / player.current.maxHealth)* 300), 10)
  love.graphics.setColor(0,0,0)
  local x, y = camera:worldCoords(200, love.graphics.getHeight() - 67 - (font:getHeight() / 2))
  local tWidth = font:getWidth(player.real.health..'/'..player.current.maxHealth)
  love.graphics.setFont(font)
  love.graphics.printf(math.floor(player.real.health + 0.5)..'/'..math.floor(player.current.maxHealth + 0.5), x, y, 300, "center")
end

function drawManaBar()
  local player = entityArray[1]
  love.graphics.setColor(255,255,255)
  local x, y = camera:worldCoords(200, love.graphics.getHeight() - 60)
  love.graphics.rectangle("fill", x, y, 300, 10)
  love.graphics.setColor(176,224,230)
  love.graphics.rectangle("fill", x, y, ((player.real.resource / player.current.maxResource)* 300), 10)
  love.graphics.setColor(0,0,0)
  local x, y = camera:worldCoords(200, love.graphics.getHeight() - 56 - (font:getHeight() / 2))
  local tWidth = font:getWidth(player.real.resource..'/'..player.current.maxResource)
  love.graphics.printf(math.floor(player.real.resource + 0.5)..'/'..math.floor(player.current.maxResource + 0.5), x, y, 300, "center")
  love.graphics.setFont(Font)
end

function drawXPBar()
  local player = entityArray[1]
  love.graphics.setColor(230,148,52)
  local x, y = camera:worldCoords(190, love.graphics.getHeight() - ((player.xp / player.xpToLevel) * 70))
  love.graphics.rectangle("fill", x, y, 10, (player.xp / player.xpToLevel) * 70)
  love.graphics.setColor(0,0,0,50)
  local x, y = camera:worldCoords(190, love.graphics.getHeight() - 70)
  love.graphics.rectangle("fill", x, y, 10, 70)
end

function drawLevels()
  local player = entityArray[1]
  love.graphics.setColor(51,62,98)
  local x, y = camera:worldCoords(170, love.graphics.getHeight() - 20)
  love.graphics.rectangle("fill", x, y, 20, 20)
  love.graphics.setColor(255,255,255)
  love.graphics.printf(player.level, x, y, 20, "center")
end

function drawAbilities()
  local player = entityArray[1]
  local abs = {
    ability1 = 1,
    ability2 = 2,
    ability3 = 3,
    ability4 = 4
  }
  love.graphics.setFont(font)
  for i=1,4,1 do
    local ab = invertTable(abs)
    local newx = 240 + ((i-1)*60)
    local x, y = camera:worldCoords(newx, (love.graphics.getHeight() - 45))
    love.graphics.setColor(207,224,242)
    love.graphics.rectangle("fill", x, y, 40, 40)
    love.graphics.setColor(0,0,0,80)
    local x, y = camera:worldCoords(newx, (love.graphics.getHeight() - (45 + (player.abilities[ab[i]].realCooldown / player.abilities[ab[i]].currentCooldown))))
    love.graphics.rectangle("fill", x, y, 40, (player.abilities[ab[i]].realCooldown / player.abilities[ab[i]].currentCooldown) * 40)
    love.graphics.setColor(0,0,0)
    local x, y = camera:worldCoords(newx, (love.graphics.getHeight() - 35))
    love.graphics.printf(math.floor(player.abilities[ab[i]].realCooldown + 0.5), x, y, 40, "center")
  end
  love.graphics.setFont(Font)
end

function drawMiniMap()
  local x, y = camera:worldCoords((love.graphics.getWidth() - 150), (love.graphics.getHeight() - 150))
  local x2, y2 = camera:worldCoords((love.graphics.getWidth() - 145), (love.graphics.getHeight() - 145))

  love.graphics.setColor(51,62,98)
  love.graphics.rectangle("fill", x, y, 150, 150)
  love.graphics.setColor(207,224,242)
  love.graphics.rectangle("fill", x2, y2, 140, 140)
end

function drawInventory()
  love.graphics.setColor(51,62,98)
  local height = love.graphics.getHeight()
  local x, y = camera:worldCoords(0, height - 185)
  love.graphics.rectangle("fill", x, y, 50, 185)
  drawInventorySlots()
end

function drawInventorySlots()
  love.graphics.setColor(207,224,242)
  local player = entityArray[1]
  local height = love.graphics.getHeight()
  for i=1,4,1 do
    local x, y = camera:worldCoords(5, height - (180 - ((i-1) * 45)))
    love.graphics.rectangle("fill", x, y, 40, 40)
  end
  for k=1,4,1 do
    local inv = {
      cap = 1,
      vest = 2,
      leggings = 3,
      boots = 4
    }
    local invInv = invertTable(inv)
    if player.inventory[invInv[k]].itemName ~= nil then
      local x, y = camera:worldCoords(10, height - (180 - ((k-1) * 45)) + 5)
      love.graphics.setColor(51,62,98)
      love.graphics.rectangle("fill", x, y, 30, 30)
      local msx, msy = love.mouse.getPosition()
      local mx, my = camera:worldCoords(msx, msy)
      local xmin, ymin = camera:worldCoords(5, height - (180 - ((k-1) * 45)))
      local xmax, ymax = camera:worldCoords(45, height - (180 - ((k-1) * 45)) + 40)
      if mx > xmin and mx < xmax and my > ymin and my < ymax then
        love.graphics.setColor(51,62,98,100)
        local htx, hty = camera:worldCoords(55, height - (180 - ((k-1) * 45)) + 5)
        love.graphics.rectangle("fill", htx, hty, Font:getWidth(player.inventory[invInv[k]].itemName) + 10, 30)
        love.graphics.setColor(255,255,255)
        local tx, ty = camera:worldCoords(60, height - (180 - ((k-1) * 45)) + 10)
        love.graphics.print(player.inventory[invInv[k]].itemName, tx, ty)
      end
    end
  end
end

function checkNotDead(entity)
  if entity.real.health <= 0 then
    entity:die()
  end
end

function makeLoot(x, y)
  local item = generateItem()
  local lootCrate = Loot.new(x, y, item)
  table.insert(entityArray, lootCrate)
end

function addBoss()
  if (table.getn(entityArray) == 1) then
    local bosses = {Enemy1, Enemy2, Enemy3}
    local level = entityArray[1].level
    local bx, by = camera:worldCoords(500, 500)
    print(level)
    local Boss = bosses[level].new(bx, by, 20)
    table.insert(entityArray, Boss)
  end
end

function playerAutoAttack()
  if love.mouse.isDown(2) and entityArray[1].real.autoAttackTimer <= 0 then
    entityArray[1]:autoAttack()
  end
end

function drawMainMenu()
  love.graphics.setBackgroundColor(207,224,242)
  love.graphics.setColor(51,62,98)
  love.graphics.rectangle("fill", (love.graphics.getWidth() / 2) - 100, (love.graphics.getHeight() / 2) - 40, 200, 80)
  love.graphics.setColor(256,256,256)
  love.graphics.printf("Timed Mode", (love.graphics.getWidth() / 2) - 45, (love.graphics.getHeight() / 2) - 15, 200, center)
end

function drawCharSelectMenu(types)
  for i=1,table.getn(types),1
  do
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", (i*10) + ((i-1) * 200), 10, 200, 200)
    local characters = types[i].characterNames
    for j=1,#characters, 1
    do
      love.graphics.setColor(44,108,135)
      love.graphics.rectangle("fill", (i*10) + ((i-1) * 200) + 5, (j*30) - 5, 190, 30)
      love.graphics.setColor(types[i].color)
      love.graphics.rectangle("fill", (i*10) + ((i-1) * 200) + 10, j*30, 20, 20)
      love.graphics.setColor(255, 255, 255)
      love.graphics.print(characters[j], (i*10) + ((i-1) * 200) + 40, j*30)
    end
  end
end

function checkEntityToEntityCollision(e1)
  local entity1 = {x = e1.x, y = e1.y}
  for i=1,table.getn(entityArray),1
  do
    if entityArray[i].name ~= e1.name then
      entity2 = {x = entityArray[i].x, y = entityArray[i].y}
      local dx = entity1.x - entity2.x
      local dy = entity1.y - entity2.y
      local distance = math.sqrt((dy^2) + (dx^2))
      if distance < (e1.radius + entityArray[i].radius) then
        return entityArray[i]
      end
    end
  end
end

function checkClefAbility1Collision(radius)
  local entity1 = {x = entityArray[1].x, y = entityArray[1].y}
  ClefAbility1CollisionArray = {}
  for i=1,table.getn(entityArray),1
  do
    if entityArray[i].name ~= entityArray[1].name then
      entity2 = {x = entityArray[i].x, y = entityArray[i].y}
      local dx = entity1.x - entity2.x
      local dy = entity1.y - entity2.y
      local distance = math.sqrt((dy^2) + (dx^2))
      if distance < (radius + entityArray[i].radius) then
        table.insert(ClefAbility1CollisionArray, entityArray[i])
      end
    end
  end
  return ClefAbility1CollisionArray
end

function checkAutoAttackForEntityCollision(auto)
  entity1 = {x = auto.x, y = auto.y}
  for i=1,#entityArray,1
  do
    if entityArray[i].name ~= auto.owner and entityArray[i].type ~= "loot" or (entityArray[i].type == "clone" and auto.owner ~= "Clef")  then
      entity2 = {x = entityArray[i].x, y = entityArray[i].y}
      local dx = entity1.x - entity2.x
      local dy = entity1.y - entity2.y
      local distance = math.sqrt((dy^2) + (dx^2))
      if distance < (auto.radius + entityArray[i].radius) then
        return entityArray[i]
      end
    end
  end
end

function handleMenuClickEvent(x, y)
  if x > (love.graphics.getWidth() / 2 - 100) and x < (love.graphics.getWidth() / 2 + 100) then
    if y > (love.graphics.getHeight() / 2 - 40) and y < (love.graphics.getHeight() / 2 + 40) then
      return true
    end
  end
end

function handleCharSelectEvent(x, y)
  for i=1,table.getn(Types),1
  do
    local characters = Types[i].characters
    for j=1,#characters, 1
    do
      if x > (i*10) + ((i-1) * 200) + 5 and x < (i*10) + ((i-1) * 200) + 195 and y > (j*30) - 5 and y < (j*30) + 25 then
        return characters[j]
      end
    end
  end
end
