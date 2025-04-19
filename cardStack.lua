
CardStackClass = {}

function CardStackClass:new(xPos, yPos, cardOffset)
  
  local stack = {}
  local metadata = {__index = CardStackClass}
  setmetatable(stack, metadata)

  stack.stack = {}
  stack.position = Vector(xPos, yPos)
  stack.size = Vector(70, 500)
  stack.cardOffset = cardOffset

  return stack
end

-- Draws back fill and cards
function CardStackClass:draw()

  love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y)
  
  for _, card in ipairs(self.stack) do
    card:draw()
  end
end

-- Inserts inital cards into stack, called by main on load
function CardStackClass:initInsertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.stack, card)
    card.stack = self
    card.position = self.position + Vector(0, (#self.stack - 1) * self.cardOffset)
    card.isFaceUp = false
  end

  self.stack[#self.stack].isFaceUp = true
end

-- Inserts cards into stack, called by grabber 
function CardStackClass:insertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.stack, card)
    card.stack = self
    card.position = self.position + Vector(0, (#self.stack - 1) * self.cardOffset)
  end
end

-- Removes grabbed cards, called by grabber
function CardStackClass:removeCards(grabbedCard, grabber)
  grabber:setGrab(grabbedCard)
  local passedObject = false

  -- Grab all cards on top of the grabbed card
  for i, card in ipairs(self.stack) do
    if passedObject then
      card:grabbed(grabber)
      self.stack[i] = nil
    elseif card == grabbedCard then
      passedObject = true
      card:grabbed(grabber)
      self.stack[i] = nil
    end
  end
end

-- Check if mouse over the stack (for releasing), called by grabber
function CardStackClass:checkForMouseOverStack(grabber)
      
  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y
  
  return isMouseOver
end

-- Check if mouse is over cards, check from bottom to top
function CardStackClass:checkForMouseOverCard(grabber)
      
  for i = #self.stack, 1, -1 do
    self.stack[i]:checkForMouseOver(grabber)
  end
end

-- Reveals next card when a card is succesfully moved, called by grabber
function CardStackClass:cardsMoved()

  if (#self.stack > 0) then
    self.stack[#self.stack].isFaceUp = true
  end
end

-- Returns whether the grabbed cards can be released here, called by grabber
function CardStackClass:checkForValidRelease(grabber)
  
  local requiredRank = 13
  local requiredSuit = true
  
  if #self.stack > 0 then
    requiredRank = self.stack[#self.stack].rank - 1

    if self.stack[#self.stack].suit <= 2 then
      requiredSuit = (grabber.grabbedTable[1].suit > 2)
    else
      requiredSuit = (grabber.grabbedTable[1].suit <= 2)
    end
  end

  -- Should be one card of one lesser rank than top card and alternated suit color
  local isValidRelease = requiredSuit and (grabber.grabbedTable[1].rank == requiredRank)

  return isValidRelease
end