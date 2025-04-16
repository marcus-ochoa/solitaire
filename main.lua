-- Zac Emerzian
-- CMPM 121 - Pickup
-- 4-11-25
io.stdout:setvbuf("no")

require "cardStack"
require "card"
require "grabber"
require "cardDeck"

function love.load()
  love.window.setMode(960, 640)
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)

  grabber = GrabberClass:new(20)
  grabbedTable = {}

  cardStacks = {}

  for i = 1, 7 do
    table.insert(cardStacks, CardStackClass:new(60 + ((i - 1) * 125), 160, 30))
  end

  setGame()
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

  deck:update()
end

function love.draw()
  
  deck:draw()
  
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

  deck:checkForMouseOverDeck(grabber)
  deck:checkForMouseOverCard(grabber)
end

function setGame()
  
  local backSprite = love.graphics.newImage("Art/Cards/cardBack.png")
  
  local initDeck = {}

  local suits = {
    "Hearts", "Diamonds", "Clubs", "Spades"
  }

  deck = CardDeckClass:new(30, 30, 130, 30, 20, backSprite)

  for suitNum, suit in ipairs(suits) do
    for rank = 1, 13 do
      local spritePath = "Art/Cards/card" .. suit .. tostring(rank) .. ".png"
      table.insert(initDeck, CardClass:new(suitNum, rank, love.graphics.newImage(spritePath), backSprite))
    end
  end

  for i = 1, #cardStacks do
    local count = i
    local selectedCards = {}

    while count > 0 do
      local randomIndex = love.math.random(#initDeck)
      local card = table.remove(initDeck, randomIndex)
      table.insert(selectedCards, card)
      count = count - 1
    end
    
    cardStacks[i]:initInsertCards(selectedCards)
  end

  local selectedCards = {}
  
  while #initDeck > 0 do
    local randomIndex = love.math.random(#initDeck)
    local card = table.remove(initDeck, randomIndex)
    table.insert(selectedCards, card)
  end

  deck:initInsertCards(selectedCards)
end
