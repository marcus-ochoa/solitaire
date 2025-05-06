
--[[ CardDeckClass = {}

DECK_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
}

function CardDeckClass:new(xPosDeck, yPosDeck, xPosStack, yPosStack, cardOffset, deckSprite)
  
  local deck = {}
  local metadata = {__index = CardDeckClass}
  setmetatable(deck, metadata)

  deck.deck = {}
  deck.discard = {}
  deck.stack = {}
  deck.state = DECK_STATE.IDLE
  deck.deckPosition = Vector(xPosDeck, yPosDeck)
  deck.stackPosition = Vector(xPosStack, yPosStack)
  deck.deckSize = Vector(70, 95)
  deck.stackSize = Vector(110, 95)
  deck.cardOffset = cardOffset
  deck.deckSprite = deckSprite
  deck.spriteScale = 0.5

  return deck
end

-- Draws all tables and top cards
function CardDeckClass:draw()
  
  -- Draws deck and stack back fills
  love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", self.deckPosition.x, self.deckPosition.y, self.deckSize.x, self.deckSize.y)
  love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", self.stackPosition.x, self.stackPosition.y, self.stackSize.x, self.stackSize.y)

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
  
  -- Draws all cards in stack
  for _, card in ipairs(self.stack) do
    card:draw()
  end
end

-- Inserts cards into deck, called by main on load
function CardDeckClass:initInsertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.deck, card)
    card.stack = self
    card.position = self.deckPosition
    card.isFaceUp = true
    card.visible = false
  end
end

-- Inserts cards into stack, called by grabber 
function CardDeckClass:insertCards(insertTable)
  if #self.stack > 0 then
    self.stack[#self.stack].state = CARD_STATE.IDLE
  end
  for _, card in ipairs(insertTable) do
    table.insert(self.stack, card)
    card.stack = self
    card.position = self.stackPosition + Vector((#self.stack - 1) * self.cardOffset, 0)
    card.visible = true
  end
end


-- Replaces card in the draw stack
function CardDeckClass:replaceCard(replacementCard)
  table.insert(self.stack, 1, replacementCard)
  replacementCard.stack = self
  replacementCard.visible = true
  for i, card in ipairs(self.stack) do
    card.position = self.stackPosition + Vector((i - 1) * self.cardOffset, 0)
  end
end

-- Removes grabbed card, called by grabber
function CardDeckClass:removeCards(grabbedCard, grabber)
  grabber:setGrab()
  grabber:insertCards({grabbedCard})
  table.remove(self.stack)
end


-- Check if mouse over the deck (for drawing), called by main
function CardDeckClass:checkForMouseOverDeck(grabber)
      
  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.deckPosition.x and
    mousePos.x < self.deckPosition.x + self.deckSize.x and
    mousePos.y > self.deckPosition.y and
    mousePos.y < self.deckPosition.y + self.deckSize.y
  
  self.state = isMouseOver and DECK_STATE.MOUSE_OVER or DECK_STATE.IDLE
  local isClicked = isMouseOver and (grabber.state == GRABBER_STATE.GRABBING)
  
  if isClicked then
    grabber:setGrab()
    self:deckClicked()
  end
end

-- Check if mouse is over the top draw card, called by main
function CardDeckClass:checkForMouseOverCard(grabber)
  if #self.stack > 0 then
    self.stack[#self.stack]:checkForMouseOver(grabber)
  end
end

-- Replaces card succesfully moved from the draw stack with one from discard, called by grabber
function CardDeckClass:cardsMoved()
  if #self.discard > 0 then
    local card = table.remove(self.discard, 1)
    self:replaceCard(card)
  end
end

-- Draws three more cards if possible, or resets deck
function CardDeckClass:deckClicked()
  
  while #self.stack > 0 do
    local card = table.remove(self.stack, 1)
    table.insert(self.discard, 1, card)
    card.visible = false
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
    self:insertCards(newCards)
  
  else
    self.deck = self.discard
    self.discard = {}
  end
end ]]