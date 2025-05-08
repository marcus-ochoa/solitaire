-- Marcus Ochoa
-- CMPM 121 - Solitaire

io.stdout:setvbuf("no")

require "vector"
require "pile"
require "card"
require "grabber"
require "button"
require "deck"

local grabber = {}
local deck = {}
local piles = {}
local buttons = {}

function love.load()

  -- Window setup
  love.window.setMode(960, 740)
  love.window.setTitle("Soli-tearing My Hair Out")
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)

  loadGame()
end

-- Draw deck and stacks (which include foundations)
function love.draw()
  for _, button in ipairs(buttons) do
    button:draw()
  end

  for _, stack in ipairs(piles) do
    stack:draw()
  end
end

function love.mousereleased(x, y, button)
  if button == 1 then
    grabber:onMouseReleased(x, y)
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    grabber:onMousePressed(x, y)
  end
end

function love.mousemoved(x, y)
  grabber:onMouseMoved(x, y)
end

-- Sets up the game
function loadGame()

  -- Create 7 stacks (columns) and grabber
  for i = 1, 7 do
    table.insert(piles, PileClass:new(60 + ((i - 1) * 125), 160))
  end
  -- Generate card back sprite and make draw deck
  local backSprite = love.graphics.newImage("Art/Cards/cardBack.png")
  deck = DeckClass:new(60, 30, 160, 30, backSprite)
  table.insert(piles, deck.discardPile)
  table.insert(piles, deck.deckPile)
  table.insert(piles, deck.drawPile)
  table.insert(buttons, deck.button)

  -- Create cards and place them into a temp deck, also create 4 card piles (foundations)
  local initDeck = {}

  local suits = {
    "Hearts", "Diamonds", "Clubs", "Spades"
  }

  for suitNum, suit in ipairs(suits) do
    for rank = 1, 13 do

      -- make each card with a sprite, suit, and rank
      local spritePath = "Art/Cards/card" .. suit .. tostring(rank) .. ".png"
      local frontSprite = love.graphics.newImage(spritePath)
      table.insert(initDeck, CardClass:new(suitNum, rank, frontSprite, backSprite))

      -- if its an ace, also use the sprite for foundation piles
      if rank == 1 then
        table.insert(piles, SuitPileClass:new(510 + ((suitNum - 1) * 100), 30, suitNum, frontSprite))
      end
    end
  end

  grabber = GrabberClass:new(piles, buttons)
  table.insert(piles, grabber.grabbedPile)

  table.insert(buttons, ButtonClass:new(800, 680, 100, 50, nil, resetGame, nil, nil, nil, "RESET"))

  setGame(initDeck)
end

function resetGame()
  local resetDeck = {}

  for _, stack in ipairs(piles) do
    for _, card in ipairs(stack:removeCards()) do
      card.isFaceUp = true
      table.insert(resetDeck, card)
    end
  end

  setGame(resetDeck)
end


function setGame(tempDeck)
  -- Randomly place cards from temp deck into columns
  for i = 1, 7 do
    local count = i
    local selectedCards = {}

    while count > 0 do
      local randomIndex = love.math.random(#tempDeck)
      local card = table.remove(tempDeck, randomIndex)
      table.insert(selectedCards, card)
      count = count - 1
    end
    
    piles[i]:initInsertCards(selectedCards)
  end

  -- Insert rest of cards randomly into draw deck
  local selectedCards = {}
  
  while #tempDeck > 0 do
    local randomIndex = love.math.random(#tempDeck)
    local card = table.remove(tempDeck, randomIndex)
    table.insert(selectedCards, card)
  end

  deck:initInsertCards(selectedCards)

  buttons[2].text = "RESET"
end

local winCheck = {0, 0, 0, 0}

function checkWinCondition(pile, card)
  winCheck[pile.suit] = card.rank
  for _, rank in ipairs(winCheck) do
    if rank ~= 13 then
      return
    end
  end

  buttons[2].text = "YOU WIN (RESET)"
end

