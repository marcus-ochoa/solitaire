
require "vector"

CardClass = {}

CARD_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
  GRABBED = 2
}

function CardClass:new(xPos, yPos, stack)
  local card = {}
  local metadata = {__index = CardClass}
  setmetatable(card, metadata)
  
  card.position = Vector(xPos, yPos)
  card.size = Vector(50, 70)
  card.state = CARD_STATE.IDLE
  card.stack = stack
  
  return card
end

function CardClass:update()
  -- pass
end

function CardClass:draw()
  -- NEW: drop shadow for non-idle cards
  if self.state ~= CARD_STATE.IDLE then
    love.graphics.setColor(0, 0, 0, 0.8) -- color values [0, 1]
    local offset = 4 * (self.state == CARD_STATE.GRABBED and 2 or 1)
    love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, 6, 6)
  end
  
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", self.position.x - 3, self.position.y - 3, self.size.x + 3, self.size.y + 3, 6, 6)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
  
  love.graphics.print(tostring(self.state), self.position.x + 20, self.position.y - 20)
end

function CardClass:checkForMouseOver(grabber)
  if self.state == CARD_STATE.GRABBED then
    return
  end
    
  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y
  
  self.state = isMouseOver and CARD_STATE.MOUSE_OVER or CARD_STATE.IDLE
  local isGrabbed = isMouseOver and grabber.isGrabbing
  
  if isGrabbed then
    grabber.isGrabbing = false
    grabber.heldObject = self

    self.stack:removeCards(self)
  end
end

function CardClass:grabbed()
  self.state = CARD_STATE.GRABBED
  table.insert(grabbedTable, self)
end

function CardClass:released()
  self.state = CARD_STATE.IDLE
end