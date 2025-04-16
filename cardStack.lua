
-- require "vector"
-- require "card"

CardStackClass = {}

function CardStackClass:new(xPos, yPos, cardOffset)
  
  local stack = {}
  local metadata = {__index = CardStackClass}
  setmetatable(stack, metadata)

  stack.stack = {}
  stack.position = Vector(xPos, yPos)
  stack.size = Vector(70, 400)
  stack.cardOffset = cardOffset

  return stack
end

function CardStackClass:draw()
  
  love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y)
  
  for _, card in ipairs(self.stack) do
    card:draw()
  end
end

function CardStackClass:update()
  for _, card in ipairs(self.stack) do
    card:update()
  end
end

function CardStackClass:initInsertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.stack, card)
    card.stack = self
    card.position = self.position + Vector(0, (#self.stack - 1) * self.cardOffset)
    card.isFaceUp = false
  end

  self.stack[#self.stack].isFaceUp = true
end

function CardStackClass:insertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.stack, card)
    card.stack = self
    card.position = self.position + Vector(0, (#self.stack - 1) * self.cardOffset)
  end
end

function CardStackClass:removeCards(grabbedCard)
  local passedObject = false
  for i, card in ipairs(self.stack) do
    if passedObject then
      card:grabbed()
      self.stack[i] = nil
    elseif card == grabbedCard then
      passedObject = true
      card:grabbed()
      self.stack[i] = nil
    end
  end
end

function CardStackClass:checkForMouseOverStack(grabber)
      
  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y
  
  return isMouseOver
end

function CardStackClass:checkForMouseOverCard(grabber)
      
  for i = #self.stack, 1, -1 do
    self.stack[i]:checkForMouseOver(grabber)
  end
end

function CardStackClass:cardsMoved()
  
  print("cards moved from stack")
  if (#self.stack > 0) then
    self.stack[#self.stack].isFaceUp = true
  end
end