
CardStackClass = {}

function CardStackClass:new(xPos, yPos)
  
  local stack = {}
  local metadata = {__index = CardStackClass}
  setmetatable(stack, metadata)

  stack.stack = {}
  stack.position = Vector(xPos, yPos)
  stack.size = Vector(70, 500)
  stack.cardOffset = Vector(0, 30)
  stack.emptySprite = nil
  stack.emptySpriteScale = nil

  stack.grabLimit = 100
  stack.cardsVisible = 100

  stack.background = true

  return stack
end

-- Draws back fill and cards
function CardStackClass:draw()

  if self.background then
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y)
  end

  -- Draws cards or empty sprite
  if #self.stack > 0 then
    for i = math.max(#self.stack - (self.cardsVisible - 1), 1), #self.stack do
      self.stack[i]:draw()
    end

    for _, card in ipairs(self.stack) do
      card:draw()
    end

  elseif self.emptySprite ~= nil then
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.draw(self.emptySprite, self.position.x, self.position.y, 0, self.emptySpriteScale, self.emptySpriteScale)
  end
end

-- Inserts inital cards into stack, called by main on load
function CardStackClass:initInsertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.stack, card)
    card.position = self.position + ((#self.stack - 1) * self.cardOffset)
    card.isFaceUp = false
  end

  self.stack[#self.stack].isFaceUp = true
end

-- Inserts cards into stack, called by grabber 
function CardStackClass:insertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.stack, card)
    card.position = self.position + ((#self.stack - 1) * self.cardOffset)
  end

  for _, card in ipairs(self.stack) do
    card:setReleased()
  end
end

-- Removes grabbed cards, called by grabber
function CardStackClass:removeCards(grabbedCard)

  local removedCards = {}

  if #self.stack <= 0 then
    return removedCards
  end

  if grabbedCard == nil then
    grabbedCard = self.stack[1]
  end

  local passedObject = false

  -- Grab all cards on top of the grabbed card
  for i, card in ipairs(self.stack) do
    if passedObject then
      table.insert(removedCards, card)
      self.stack[i] = nil
    elseif card == grabbedCard then
      passedObject = true
      table.insert(removedCards, card)
      self.stack[i] = nil
    end
  end

  return removedCards
end

-- Check if mouse over the stack (for releasing), called by grabber
function CardStackClass:checkForMouseOverStack(x, y)
  local isMouseOver = 
    x > self.position.x and
    x < self.position.x + self.size.x and
    y > self.position.y and
    y < self.position.y + self.size.y
  
  return isMouseOver
end

-- Check if mouse is over cards, check from bottom to top
function CardStackClass:checkForMouseOverCard(x, y)
  for i = #self.stack, 1, -1 do
    if (#self.stack - i >= self.grabLimit) then break end
    if self.stack[i]:checkForMouseOver(x, y) then
      return self.stack[i]
    end
  end

  return nil
end

-- Reveals next card when a card is succesfully moved, called by grabber
function CardStackClass:cardsMoved()
  if (#self.stack > 0) then
    self.stack[#self.stack].isFaceUp = true
  end
end

-- Returns whether the grabbed cards can be released here, called by grabber
-- OVERWRITE
function CardStackClass:checkForValidRelease(pile)
  
  local requiredRank = 13
  local requiredSuit = true
  
  if #self.stack > 0 then
    requiredRank = self.stack[#self.stack].rank - 1

    if self.stack[#self.stack].suit <= 2 then
      requiredSuit = (pile.stack[1].suit > 2)
    else
      requiredSuit = (pile.stack[1].suit <= 2)
    end
  end

  -- Should be one card of one lesser rank than top card and alternated suit color
  local isValidRelease = requiredSuit and (pile.stack[1].rank == requiredRank)

  return isValidRelease
end


-- =====================
-- == CARD PILE CLASS ==
-- =====================

CardPileClass = CardStackClass:new()

function CardPileClass:new(xPos, yPos, suit, emptySprite)
  
  local stack = {}
  local metadata = {__index = CardPileClass}
  setmetatable(stack, metadata)

  stack.stack = {}
  stack.position = Vector(xPos, yPos)
  stack.size = Vector(70, 95)
  stack.cardOffset = Vector()
  stack.emptySprite = emptySprite
  stack.emptySpriteScale = 0.5

  stack.grabLimit = 1
  stack.cardsVisible = 1

  stack.suit = suit

  stack.background = true

  return stack
end

-- Returns whether the grabbed cards can be released here, called by grabber
function CardPileClass:checkForValidRelease(pile)
  
  local requiredRank = 1
  
  if #self.stack > 0 then
    requiredRank = self.stack[#self.stack].rank + 1
  end

  -- Should be one card of one greater rank than top card and correct suit
  local isValidRelease = 
    #pile.stack == 1 and
    pile.stack[1].suit == self.suit and
    pile.stack[1].rank == requiredRank

  return isValidRelease
end


-- =======================
-- == CARD SPREAD CLASS ==
-- =======================

CardSpreadClass = CardStackClass:new()

function CardSpreadClass:new(xPos, yPos, owner)
  
  local stack = {}
  local metadata = {__index = CardSpreadClass}
  setmetatable(stack, metadata)

  stack.stack = {}
  stack.position = Vector(xPos, yPos)
  stack.size = Vector(110, 95)
  stack.cardOffset = Vector(20, 0)

  stack.grabLimit = 1
  stack.cardsVisible = 100
  stack.owner = owner

  stack.background = true

  return stack
end

-- Returns whether the grabbed cards can be released here, called by grabber
function CardSpreadClass:checkForValidRelease(pile)
  return false
end

function CardSpreadClass:replaceCard(replacementCard)
  table.insert(self.stack, 1, replacementCard)

  for i, card in ipairs(self.stack) do
    card.position = self.position + ((i - 1) * self.cardOffset)
  end
end

-- Reveals next card when a card is succesfully moved, called by grabber
function CardSpreadClass:cardsMoved()
  self.owner:onCardsMoved()
end


-- ==============================
-- == CARD GRABBER STACK CLASS ==
-- ==============================

GrabbedPileClass = CardStackClass:new()

function GrabbedPileClass:new()
  
  local stack = {}
  local metadata = {__index = GrabbedPileClass}
  setmetatable(stack, metadata)

  stack.stack = {}
  stack.position = Vector(0, 0)
  stack.size = Vector(0, 0)
  stack.cardOffset = Vector(0, 20)

  stack.stackOffset = Vector(-35, -45)

  stack.grabLimit = 0
  stack.cardsVisible = 100

  stack.background = false

  return stack
end

-- Inserts cards into stack, called by grabber 
function GrabbedPileClass:insertCards(insertTable)
  for _, card in ipairs(insertTable) do
    card:setGrabbed()
    table.insert(self.stack, card)
    card.position = self.position + ((#self.stack - 1) * self.cardOffset)
  end

  for _, card in ipairs(self.stack) do
    card:setReleased()
  end
end

function GrabbedPileClass:updatePosition(x, y)
  self.position = Vector(x, y) + self.stackOffset
  for i, card in ipairs(self.stack) do
    card.position = self.position + ((i - 1) * self.cardOffset)
  end
end

-- Removes grabbed cards, called by grabber
function GrabbedPileClass:removeCards(grabbedCard)

  local removedCards = {}

  if #self.stack <= 0 then
    return removedCards
  end

  if grabbedCard == nil then
    grabbedCard = self.stack[1]
  end

  local passedObject = false

  -- Grab all cards on top of the grabbed card
  for i, card in ipairs(self.stack) do
    if passedObject then
      card:setReleased()
      table.insert(removedCards, card)
      self.stack[i] = nil
    elseif card == grabbedCard then
      passedObject = true
      card:setReleased()
      table.insert(removedCards, card)
      self.stack[i] = nil
    end
  end

  return removedCards
end