
-- require "vector"

-- native sprite size is 140 x 190

CardClass = {}

CARD_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
  GRABBED = 2
}

function CardClass:new(suit, rank, faceUpSprite, faceDownSprite)
  local card = {}
  local metadata = {__index = CardClass}
  setmetatable(card, metadata)
  
  card.position = nil
  card.size = Vector(70, 95)
  card.state = CARD_STATE.IDLE
  card.stack = nil

  card.suit = suit
  card.rank = rank
  card.isFaceUp = nil

  card.spriteScale = 0.5
  
  card.faceUpSprite = faceUpSprite
  card.faceDownSprite = faceDownSprite

  card.visible = true
  
  return card
end

function CardClass:update()
  -- pass
end

function CardClass:draw()

  if self.visible then

    -- NEW: drop shadow for non-idle cards
    if self.state ~= CARD_STATE.IDLE then
      love.graphics.setColor(0, 0, 0, 0.8) -- color values [0, 1]
      local offset = 4 * (self.state == CARD_STATE.GRABBED and 2 or 1)
      love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, 6, 6)
    end

    love.graphics.setColor(1, 1, 1, 1) -- color values [0, 1]

    if self.isFaceUp then
      love.graphics.draw(self.faceUpSprite, self.position.x, self.position.y, 0, self.spriteScale, self.spriteScale)
    else
      love.graphics.draw(self.faceDownSprite, self.position.x, self.position.y, 0, self.spriteScale, self.spriteScale)
    end

    -- love.graphics.setColor(0, 0, 0, 1)
    -- love.graphics.print(tostring(self.state), self.position.x + 20, self.position.y - 20)
  end

end

function CardClass:checkForMouseOver(grabber)
  if self.state == CARD_STATE.GRABBED or not self.isFaceUp or grabber.seenCard then
    self.state = CARD_STATE.IDLE
    return
  end
    
  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y
  
  if isMouseOver then
    grabber.seenCard = true
    self.state = CARD_STATE.MOUSE_OVER
    
    if grabber.isGrabbing then
      grabber.isGrabbing = false
      grabber.heldObject = self
      self.stack:removeCards(self)
    end
  else
    self.state = CARD_STATE.IDLE
  end
end

function CardClass:grabbed()
  self.state = CARD_STATE.GRABBED
  table.insert(grabbedTable, self)
end

function CardClass:released()
  self.state = CARD_STATE.IDLE
end