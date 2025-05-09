-- Marcus Ochoa
-- CMPM 121 - Solitaire

io.stdout:setvbuf("no")

require "scripts.vector"
require "scripts.cardStack"
require "scripts.card"
require "scripts.grabber"
require "scripts.cardDeck"
require "scripts.cardPile"

local grabber = {}
local deck = {}
local cardStacks = {}

function love.load()

  -- Window setup
  love.window.setMode(960, 720)
  love.window.setTitle("Soli-tearing My Hair Out")
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)

  setGame()
end

-- Update grabber and check for mouse moving
function love.update()
  grabber:update()
  checkForMouseMoving()
end

-- Draw deck, stacks (which include foundations), and the grabbed cards
function love.draw()
  deck:draw()
  for _, stack in ipairs(cardStacks) do
    stack:draw()
  end
  grabber:draw()
end

-- Checks whether the mouse is over any of the cards or deck
function checkForMouseMoving()
  if grabber.currentMousePos == nil then
    return
  end

  for _, stack in ipairs(cardStacks) do
    stack:checkForMouseOverCard(grabber)
  end

  deck:checkForMouseOverCard(grabber)
  deck:checkForMouseOverDeck(grabber)
end


-- Sets up the game
function setGame()

  -- Create 7 stacks (columns) and grabber
  for i = 1, 7 do
    table.insert(cardStacks, CardStackClass:new(60 + ((i - 1) * 125), 160, 30))
  end
  grabber = GrabberClass:new(20, cardStacks)

  -- Generate card back sprite and make draw deck
  local backSprite = love.graphics.newImage("art/cards/cardBack.png")
  deck = CardDeckClass:new(30, 30, 130, 30, 20, backSprite)

  -- Create cards and place them into a temp deck, also create 4 card piles (foundations)
  local initDeck = {}

  local suits = {
    "Hearts", "Diamonds", "Clubs", "Spades"
  }

  for suitNum, suit in ipairs(suits) do
    for rank = 1, 13 do

      -- make each card with a sprite, suit, and rank
      local spritePath = "art/cards/card" .. suit .. tostring(rank) .. ".png"
      local frontSprite = love.graphics.newImage(spritePath)
      table.insert(initDeck, CardClass:new(suitNum, rank, frontSprite, backSprite))

      -- if its an ace, also use the sprite for foundation piles
      if rank == 1 then
        table.insert(cardStacks, CardPileClass:new(550 + ((suitNum - 1) * 100) , 30, suitNum, frontSprite))
      end
    end
  end

  -- Randomly place cards from temp deck into columns
  for i = 1, 7 do
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

  -- Insert rest of cards randomly into draw deck
  local selectedCards = {}
  
  while #initDeck > 0 do
    local randomIndex = love.math.random(#initDeck)
    local card = table.remove(initDeck, randomIndex)
    table.insert(selectedCards, card)
  end

  deck:initInsertCards(selectedCards)
end
