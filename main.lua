-- Zac Emerzian
-- CMPM 121 - Pickup
-- 4-11-25
io.stdout:setvbuf("no")

require "cardStack"
require "card"
require "grabber"

function love.load()
  love.window.setMode(960, 640)
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)

  grabber = GrabberClass:new(20)
  grabbedTable = {}

  cardStacks = {}

  table.insert(cardStacks, CardStackClass:new(100, 100, 20))
  table.insert(cardStacks, CardStackClass:new(400, 100, 20))

  cardStacks[1]:insertCards({
    CardClass:new(100, 100, cardStacks[1]),
    CardClass:new(100, 120, cardStacks[1])
  })

  cardStacks[2]:insertCards({
    CardClass:new(400, 100, cardStacks[2]),
    CardClass:new(400, 120, cardStacks[2])
  })
end

function love.update()
  grabber:update()
  checkForMouseMoving()

  for _, card in ipairs(grabbedTable) do
    card:update()
  end

  for _, stack in ipairs(cardStacks) do
    stack:update()
  end
end

function love.draw()
  for _, stack in ipairs(cardStacks) do
    stack:draw()
  end

  for _, card in ipairs(grabbedTable) do
    card:draw()
  end

  love.graphics.setColor(0.1, 0.1, 0.1, 1)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Mouse: " .. tostring(grabber.currentMousePos.x) .. ", " .. tostring(grabber.currentMousePos.y))
end

function checkForMouseMoving()
  if grabber.currentMousePos == nil then
    return
  end

  for _, stack in ipairs(cardStacks) do
    stack:checkForMouseOverCard(grabber)
  end
end
