
-- require "vector"
-- require "card"

CardPileClass = {}

function CardPileClass:new(xPos, yPos, suit, sprite)
  
  local pile = {}
  local metadata = {__index = CardPileClass}
  setmetatable(pile, metadata)

  pile.stack = {}
  pile.position = Vector(xPos, yPos)
  pile.size = Vector(70, 95)
  pile.sprite = sprite
  pile.spriteScale = 0.5

  return pile
end

function CardPileClass:draw()
  
  love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y)
  
  if #self.stack > 0 then
    self.stack[#self.stack]:draw()
  else
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, self.spriteScale, self.spriteScale)
  end
end

function CardPileClass:update()
  for _, card in ipairs(self.stack) do
    card:update()
  end
end

function CardPileClass:insertCards(insertTable)
  if #self.stack > 0 then
    self.stack[#self.stack].visible = false
  end
  
  card = insertTable[1]
  table.insert(self.stack, card)
  card.stack = self
  card.position = self.position
end

function CardPileClass:removeCards(grabbedCard)
  grabbedCard:grabbed()
  table.remove(self.stack)
  if #self.stack > 0 then
    self.stack[#self.stack].visible = true
  end
end

function CardPileClass:checkForMouseOverStack(grabber)
      
  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y
  
  return isMouseOver
end

function CardPileClass:checkForMouseOverCard(grabber)
      
  if (#self.stack > 0) then
    self.stack[#self.stack]:checkForMouseOver(grabber)
  end
end

function CardPileClass:cardsMoved()
  
  print("cards moved from stack")
  if (#self.stack > 0) then
    self.stack[#self.stack].visible = true
  end
end