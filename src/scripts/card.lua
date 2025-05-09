
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
  card.stack = nil
  card.suit = suit
  card.rank = rank
  card.isFaceUp = true
  card.spriteScale = 0.5
  card.faceUpSprite = faceUpSprite
  card.faceDownSprite = faceDownSprite

  card.visible = true
  
  return card
end

function CardClass:draw()

  if self.visible then

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
end

-- Checks if the mouse is over the card and whether it should be grabbed
function CardClass:checkForMouseOver(grabber)
  if self.state == CARD_STATE.GRABBED or (not self.isFaceUp) or grabber.seenCard then
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

    -- Set that the grabber has seen a card, so it doesn't see anymore this frame
    grabber:setSeenCard()
    self.state = CARD_STATE.MOUSE_OVER
    
    -- If the card is being grabbed, notify the stack to give over the proper cards
    if grabber.state == GRABBER_STATE.GRABBING then
      self.stack:removeCards(self, grabber)
    end
  else
    self.state = CARD_STATE.IDLE
  end
end

-- Sets card state to grabbed and inserts card into the grabbed table, called by stack
function CardClass:grabbed(grabber)
  self.state = CARD_STATE.GRABBED
  grabber:insertCards({self})
end

-- Sets card state back to idle, called by grabber
function CardClass:released()
  self.state = CARD_STATE.IDLE
end

-- Sets card positin, called by grabber
function CardClass:updatePosition(positionVector)
  self.position = positionVector
end