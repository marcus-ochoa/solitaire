
CardDeckClass = {}

DECK_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
}

function CardDeckClass:new(xPosDeck, yPosDeck, xPosStack, yPosStack, deckSprite)
  
  local deck = {}
  local metadata = {__index = CardDeckClass}
  setmetatable(deck, metadata)

  deck.deck = {}
  deck.discard = {}
  deck.state = DECK_STATE.IDLE
  deck.deckPosition = Vector(xPosDeck, yPosDeck)
  deck.deckSize = Vector(70, 95)
  deck.deckSprite = deckSprite
  deck.spriteScale = 0.5

  deck.spread = CardSpreadClass:new(xPosStack, yPosStack, deck)

  return deck
end

-- Draws all tables and top cards
function CardDeckClass:draw()
  -- Draws deck and stack back fills
  love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", self.deckPosition.x, self.deckPosition.y, self.deckSize.x, self.deckSize.y)

  -- Draws deck, faded if all cards in discard or nothing if no more cards at all
  if (#self.deck > 0) or (#self.discard > 0) then
    if self.state == DECK_STATE.MOUSE_OVER then
      love.graphics.setColor(0, 0, 0, 0.8) -- color values [0, 1]
      local offset = 4
      love.graphics.rectangle("fill", self.deckPosition.x + offset, self.deckPosition.y + offset, self.deckSize.x, self.deckSize.y, 6, 6)
    end

    love.graphics.setColor(1, 1, 1, 1)

    if #self.deck <= 0 then
      love.graphics.setColor(0.5, 0.5, 0.5, 1)
    end

    love.graphics.draw(self.deckSprite, self.deckPosition.x, self.deckPosition.y, 0, self.spriteScale, self.spriteScale)
  end
end

-- Inserts cards into deck, called by main on load
function CardDeckClass:initInsertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.deck, card)
    card.stack = self
    card.position = self.deckPosition
    card.isFaceUp = true
  end
end

-- Check if mouse over the deck (for drawing), called by main
function CardDeckClass:checkForMouseOverDeck(x, y)
      
  local isMouseOver = 
    x > self.deckPosition.x and
    x < self.deckPosition.x + self.deckSize.x and
    y > self.deckPosition.y and
    y < self.deckPosition.y + self.deckSize.y
  
  self.state = isMouseOver and DECK_STATE.MOUSE_OVER or DECK_STATE.IDLE
  return isMouseOver
end

-- Replaces card succesfully moved from the draw stack with one from discard, called by spread
function CardDeckClass:onCardsMoved()
  print("cards moved")
  if #self.discard > 0 then
    print("replacing card")
    local card = table.remove(self.discard, 1)
    self.spread:replaceCard(card)
  end
end

-- Draws three more cards if possible, or resets deck
function CardDeckClass:deckClicked()
  
  while #self.spread.stack > 0 do
    local card = table.remove(self.spread.stack, 1)
    table.insert(self.discard, 1, card)
    card.position = self.deckPosition
  end
  
  if #self.deck > 0 then
    
    local newCards = {}
    for _ = 1, 3 do
      if #self.deck > 0 then
        local card = table.remove(self.deck)
        table.insert(newCards, card)
      end
    end
    self.spread:insertCards(newCards)
  
  else
    self.deck = self.discard
    self.discard = {}
  end
end