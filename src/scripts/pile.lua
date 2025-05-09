
-- ==================================
-- == BASE (FOUNDATION) PILE CLASS ==
-- ==================================

PileClass = {}

function PileClass:new(xPos, yPos)
  
  local stack = {}
  local metadata = {__index = PileClass}
  setmetatable(stack, metadata)

  stack.stack = {}
  stack.position = Vector(xPos, yPos)
  stack.size = Vector(70, 500)

  -- Offset from one card in the stack to the next
  stack.cardOffset = Vector(0, 30)

  -- Sprite to display when stack empty
  stack.emptySprite = nil
  stack.emptySpriteScale = nil

  -- Max amount of cards that can be grabbed from pile
  stack.grabLimit = 100

  -- Amount of cards visible in pile
  stack.cardsVisible = 100

  -- Whether a back fill rectangle should be drawn
  stack.background = true

  return stack
end

function PileClass:draw()

  -- Draws back fill if set
  if self.background then
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y)
  end

  -- Draws cards if there are any or empty sprite if set
  if #self.stack > 0 then
    for i = math.max(#self.stack - (self.cardsVisible - 1), 1), #self.stack do
      self.stack[i]:draw()
    end
  elseif self.emptySprite ~= nil then
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.draw(self.emptySprite, self.position.x, self.position.y, 0, self.emptySpriteScale, self.emptySpriteScale)
  end
end

-- Inserts inital cards into stack, called by main on load
function PileClass:initInsertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.stack, card)
    card.position = self.position + ((#self.stack - 1) * self.cardOffset)
    card.isFaceUp = false
  end

  self.stack[#self.stack].isFaceUp = true
end

-- Inserts cards into stack
function PileClass:insertCards(insertTable)
  for _, card in ipairs(insertTable) do
    self:onCardInserted(card)
    table.insert(self.stack, card)
    card.position = self.position + ((#self.stack - 1) * self.cardOffset)
  end

  for _, card in ipairs(self.stack) do
    card:setIdle()
  end
end

function PileClass:onCardInserted(card)
  -- TO BE OVERRIDEN
end

-- Removes and returns cards from stack
function PileClass:removeCards(grabbedCard)

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
      self:onCardRemoved(card)
      table.insert(removedCards, card)
      self.stack[i] = nil
    elseif card == grabbedCard then
      passedObject = true
      self:onCardRemoved(card)
      table.insert(removedCards, card)
      self.stack[i] = nil
    end
  end

  return removedCards
end

function PileClass:onCardRemoved(card)
  -- TO BE OVERRIDEN
end

-- Check if mouse over the stack (for releasing)
function PileClass:checkForMouseOverStack(x, y)
  local isMouseOver = 
    x > self.position.x and
    x < self.position.x + self.size.x and
    y > self.position.y and
    y < self.position.y + self.size.y
  
  return isMouseOver
end

-- Check if mouse is over cards from bottom to top (for grabbing)
function PileClass:checkForMouseOverCard(x, y)
  for i = #self.stack, 1, -1 do
    if (#self.stack - i >= self.grabLimit) then break end
    if self.stack[i]:checkForMouseOver(x, y) then
      return self.stack[i]
    end
  end

  return nil
end

-- Reveals next card when a card is succesfully moved
function PileClass:cardsMoved()
  if (#self.stack > 0) then
    self.stack[#self.stack].isFaceUp = true
  end
end

-- Returns whether the grabbed cards can be released here
function PileClass:checkForValidRelease(pile)
  
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
-- == SUIT PILE CLASS ==
-- =====================

SuitPileClass = PileClass:new()

function SuitPileClass:new(xPos, yPos, suit, emptySprite)
  
  local stack = {}
  local metadata = {__index = SuitPileClass}
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

-- Check if the game has been won when a card is added to a suit pile
function SuitPileClass:onCardInserted(card)
  checkWinCondition(self, card)
end

-- Returns whether the grabbed cards can be released here
function SuitPileClass:checkForValidRelease(pile)
  
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


-- =====================
-- == DRAW PILE CLASS ==
-- =====================

DrawPileClass = PileClass:new()

function DrawPileClass:new(xPos, yPos, owner, event)
  
  local stack = {}
  local metadata = {__index = DrawPileClass}
  setmetatable(stack, metadata)

  stack.stack = {}
  stack.position = Vector(xPos, yPos)
  stack.size = Vector(110, 95)
  stack.cardOffset = Vector(20, 0)

  stack.grabLimit = 1
  stack.cardsVisible = 100

  -- Owner and function to call when cards moved
  stack.owner = owner
  stack.event = event

  stack.background = true

  return stack
end

-- Returns whether the grabbed cards can be released here, called by grabber
function DrawPileClass:checkForValidRelease(pile)
  return false
end

-- Replaces a taken card with a given one (for deck logic)
function DrawPileClass:replaceCard(replacementCard)
  table.insert(self.stack, 1, replacementCard)

  for i, card in ipairs(self.stack) do
    card.position = self.position + ((i - 1) * self.cardOffset)
  end
end

-- Calls passed in function when card moved (for deck logic)
function DrawPileClass:cardsMoved()
  self.event(self.owner)
end


-- ========================
-- == GRABBER PILE CLASS ==
-- ========================

GrabbedPileClass = PileClass:new()

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

-- Sets card to grabbed when inserted
function GrabbedPileClass:onCardInserted(card)
  card:setGrabbed()
end

-- Sets card to released when removed
function GrabbedPileClass:onCardRemoved(card)
  card:setReleased()
end

-- Updates position pile and all cards in it
function GrabbedPileClass:updatePosition(x, y)
  self.position = Vector(x, y) + self.stackOffset
  for i, card in ipairs(self.stack) do
    card.position = self.position + ((i - 1) * self.cardOffset)
  end
end


-- ========================
-- == MINIMAL PILE CLASS ==
-- ========================

MinimalPileClass = PileClass:new()

function MinimalPileClass:new()
  
  local stack = {}
  local metadata = {__index = MinimalPileClass}
  setmetatable(stack, metadata)

  stack.stack = {}
  stack.position = Vector()
  stack.size = Vector()
  stack.cardOffset = Vector()

  stack.grabLimit = 0
  stack.cardsVisible = 0

  stack.background = false

  return stack
end