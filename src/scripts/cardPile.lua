
CardPileClass = {}

function CardPileClass:new(xPos, yPos, suit, sprite)
  
  local pile = {}
  local metadata = {__index = CardPileClass}
  setmetatable(pile, metadata)

  pile.stack = {}
  pile.suit = suit
  pile.position = Vector(xPos, yPos)
  pile.size = Vector(70, 95)
  pile.sprite = sprite
  pile.spriteScale = 0.5

  return pile
end

-- Draws pile or top card
function CardPileClass:draw()
  
  -- Draws back fill
  love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y)
  
  -- Draws top card or placeholder ace if none exists
  if #self.stack > 0 then
    self.stack[#self.stack]:draw()
  else
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, self.spriteScale, self.spriteScale)
  end
end

-- Inserts cards into pile, called by grabber
function CardPileClass:insertCards(insertTable)
  if #self.stack > 0 then
    self.stack[#self.stack].visible = false
  end
  
  card = insertTable[1]
  table.insert(self.stack, card)
  card.stack = self
  card.position = self.position
end

-- Removes grabbed card, called by grabber
function CardPileClass:removeCards(grabbedCard, grabber)
  grabber:setGrab(grabbedCard)
  grabbedCard:grabbed(grabber)
  table.remove(self.stack)
  if #self.stack > 0 then
    self.stack[#self.stack].visible = true
  end
end

-- Check if mouse over the stack (for releasing), called by grabber
function CardPileClass:checkForMouseOverStack(grabber)
      
  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y
  
  return isMouseOver
end

-- Check if mouse is over the top draw card, called by main
function CardPileClass:checkForMouseOverCard(grabber)
      
  if (#self.stack > 0) then
    self.stack[#self.stack]:checkForMouseOver(grabber)
  end
end

-- Shows next card when a card is succesfully moved, called by grabber
function CardPileClass:cardsMoved()
  if (#self.stack > 0) then
    self.stack[#self.stack].visible = true
  end
end

-- Returns whether the grabbed cards can be released here, called by grabber
function CardPileClass:checkForValidRelease(grabber)
  
  local requiredRank = 1
  
  if #self.stack > 0 then
    requiredRank = self.stack[#self.stack].rank + 1
  end

  -- Should be one card of one greater rank than top card and correct suit
  local isValidRelease = 
    #grabber.grabbedTable == 1 and
    grabber.grabbedTable[1].suit == self.suit and
    grabber.grabbedTable[1].rank == requiredRank

  return isValidRelease
end