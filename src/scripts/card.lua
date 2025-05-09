
-- Native card sprite size is 70 x 95

-- === USED STARTER CODE FROM CLASS == 

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
  card.suit = suit
  card.rank = rank
  card.isFaceUp = true
  card.spriteScale = 0.5
  card.faceUpSprite = faceUpSprite
  card.faceDownSprite = faceDownSprite
  
  return card
end

function CardClass:draw()
  
  -- Draw shadow if cards are not idle (light if mouse hovering, heavy if grabbed)
  if self.state ~= CARD_STATE.IDLE then
    love.graphics.setColor(0, 0, 0, 0.8)
    local offset = 4 * (self.state == CARD_STATE.GRABBED and 2 or 1)
    love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, 6, 6)
  end

  love.graphics.setColor(1, 1, 1, 1)

  -- Draws face up or face down sprite
  if self.isFaceUp then
    love.graphics.draw(self.faceUpSprite, self.position.x, self.position.y, 0, self.spriteScale, self.spriteScale)
  else
    love.graphics.draw(self.faceDownSprite, self.position.x, self.position.y, 0, self.spriteScale, self.spriteScale)
  end
end

-- Checks if the mouse is over the card and updates state accordingly
function CardClass:checkForMouseOver(x, y)

  if not self.isFaceUp then
    self.state = CARD_STATE.IDLE
    return
  end

  local isMouseOver = 
    x > self.position.x and
    x < self.position.x + self.size.x and
    y > self.position.y and
    y < self.position.y + self.size.y

  self.state = isMouseOver and CARD_STATE.MOUSE_OVER or CARD_STATE.IDLE
  return isMouseOver
end

function CardClass:setGrabbed()
  self.state = CARD_STATE.GRABBED
end

function CardClass:setReleased()
  self.state = CARD_STATE.IDLE
end

-- Sets card state back to idle from mouse over
function CardClass:setIdle()
  if self.state ~= CARD_STATE.GRABBED then
    self.state = CARD_STATE.IDLE
  end
end