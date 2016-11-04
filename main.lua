require("Characters.Clef")
require("Enemies.Enemy1")
require("Enemies.Enemy2")
require("Enemies.Enemy3")
require("gameLogic")
Camera = require("hump.camera")
Gamestate = require("hump.gamestate")
math.randomseed(os.clock())
require ("items")
require("OtherEntities.loot")

love.graphics.setFont(love.graphics.newFont("font.ttf", 20))
Font = love.graphics.newFont("font.ttf", 20)
font = love.graphics.newFont("numFont.ttf", 10)
local Menu = {}
local Game = {}
local CharSelect = {}
local Player = nil
Types = {
  {name = "Wisdom", characters = {Clef}, characterNames = {"Clef"}, color = {249, 139, 146}},
  {name = "Sorcery", characters = {Cirro}, characterNames = {"Cirro"}, color = {255, 0, 0}},
  {name = "Strength", characters = {Egnito}, characterNames = {"Egnito"},  color = {0, 255, 0}}
}
characterSelected = {}

function Menu:draw()
  drawMainMenu()
end

function Menu:mousepressed(x, y, button)
  if button == 1 then
    if handleMenuClickEvent(x, y) == true then
      Gamestate.switch(CharSelect)
    end
  end
end

function CharSelect:draw()
  drawCharSelectMenu(Types)
end

function CharSelect:mousepressed(x, y, button)
  if button == 1 then
    local charSelected = handleCharSelectEvent(x, y)
    if charSelected then
      characterSelected = charSelected
      Gamestate.switch(Game)
    end
  end
end

function Game:update(dt)
  moveEntities()
  camera:lookAt(Player.x, Player.y)
  if Player.level < 10 then
    addBoss()
  end
  handleThisFrame()
  adjustAngle()
  playerAutoAttack()
end

function Game:mousepressed(x, y, button)
  if button == 1 then
    local maybeLoot = entityArray[2]
    local mx, my = camera:worldCoords(x,y)
    if maybeLoot.type == "loot" and mx > maybeLoot.x - maybeLoot.radius and mx < maybeLoot.x + maybeLoot.radius and my > maybeLoot.y - maybeLoot.radius and my < maybeLoot.y + maybeLoot.radius then
      equipItem(maybeLoot.loot)
      table.remove(entityArray, 2)
    end
  end
  if button == 2 then
    local maybeLoot = entityArray[2]
    local mx, my = camera:worldCoords(x,y)
    if maybeLoot.type == "loot" and mx > maybeLoot.x - maybeLoot.radius and mx < maybeLoot.x + maybeLoot.radius and my > maybeLoot.y - maybeLoot.radius and my < maybeLoot.y + maybeLoot.radius then
      table.remove(entityArray, 2)
    end
  end
end

function Game:draw()
  camera:attach()
  drawEntities()
  drawEntityHealthBar()
  updateAutoAttacks()
  drawHUD()
  camera:detach()
end

function Game:enter()
  love.graphics.setBackgroundColor(201,192,151)
  camera = Camera(0,0)
  px, py = camera:worldCoords(0,0)
  Player = characterSelected.new(px, py, 20)
  table.insert(entityArray, Player)
end

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(Menu)
end

function love.keyreleased(key)
  if key == "1" then
    if (entityArray[1].real.resource > entityArray[1].abilities.ability1.resourceCost and entityArray[1].abilities.ability1.realCooldown <= 0) then
      entityArray[1].doAbility1()
    end
  elseif key == "2" then
    if (entityArray[1].real.resource > entityArray[1].abilities.ability2.resourceCost and entityArray[1].abilities.ability2.realCooldown <= 0) then
      entityArray[1].doAbility2()
    end
  elseif key == "3" then
    if (entityArray[1].real.resource > entityArray[1].abilities.ability3.resourceCost and entityArray[1].abilities.ability3.realCooldown <= 0) then
      entityArray[1].doAbility3()
    end
  elseif key == "4" then
    if (entityArray[1].real.resource > entityArray[1].abilities.ability4.resourceCost and entityArray[1].abilities.ability4.realCooldown <= 0) then
      entityArray[1].doAbility4()
    end
  end
end
