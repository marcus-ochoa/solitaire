
-- require "vector"
-- require "card"

CardDeckClass = {}

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
  deck.stackSize = Vector(300, 95)
  deck.cardOffset = cardOffset
  deck.deckSprite = deckSprite
  deck.spriteScale = 0.5

  return deck
end

function CardDeckClass:draw()
  
  love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", self.deckPosition.x, self.deckPosition.y, self.deckSize.x, self.deckSize.y)

  love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", self.stackPosition.x, self.stackPosition.y, self.stackSize.x, self.stackSize.y)

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
  
  for _, card in ipairs(self.stack) do
    card:draw()
  end
end

function CardDeckClass:update()
  for _, card in ipairs(self.stack) do
    card:update()
  end
  for _, card in ipairs(self.deck) do
    card:update()
  end
  for _, card in ipairs(self.discard) do
    card:update()
  end
end

function CardDeckClass:initInsertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.deck, card)
    card.stack = self
    card.position = self.deckPosition
    card.isFaceUp = true
    card.visible = false
  end
end

function CardDeckClass:insertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.stack, card)
    card.stack = self
    card.position = self.stackPosition + Vector((#self.stack - 1) * self.cardOffset, 0)
    card.visible = true
  end
end

function CardDeckClass:replaceCard(replacementCard)
  print("replacing card, stack length before is: ", #self.stack)
  table.insert(self.stack, 1, replacementCard)
  replacementCard.stack = self
  replacementCard.visible = true
  for i, card in ipairs(self.stack) do
    card.position = self.stackPosition + Vector((i - 1) * self.cardOffset, 0)
  end
end

function CardDeckClass:removeCards(grabbedCard)
  grabbedCard:grabbed()
  table.remove(self.stack)
end

function CardDeckClass:checkForMouseOverDeck(grabber)
      
  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.deckPosition.x and
    mousePos.x < self.deckPosition.x + self.deckSize.x and
    mousePos.y > self.deckPosition.y and
    mousePos.y < self.deckPosition.y + self.deckSize.y
  
  self.state = isMouseOver and DECK_STATE.MOUSE_OVER or DECK_STATE.IDLE
  local isClicked = isMouseOver and grabber.isGrabbing
  
  if isClicked then
    grabber.isGrabbing = false
    self:deckClicked()
  end

  self:checkForMouseOverCard(grabber)
end

function CardDeckClass:checkForMouseOverCard(grabber)
  if #self.stack > 0 then
    self.stack[#self.stack]:checkForMouseOver(grabber)
  end
end

function CardDeckClass:cardsMoved()

  print("cards moved from deck stack")
  if #self.deck > 0 then
    local card = table.remove(self.deck)
    self:replaceCard(card)
  end
end

function CardDeckClass:deckClicked()
  
  while #self.stack > 0 do
    local card = table.remove(self.stack)
    table.insert(self.discard, 1, card)
    card.visible = false
    card.position = self.deckPosition
  end
  
  if #self.deck > 0 then
    
    local newCards = {}
    for _ = 1, 3 do
      if #self.deck > 0 then
        local card = table.remove(self.deck)
        table.insert(newCards, 1, card)
      end
    end
    self:insertCards(newCards)
  
  else
    self.deck = self.discard
    self.discard = {}
  end
end