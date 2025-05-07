
-- Native card sprite size is 70 x 95

-- === USED STARTER CODE FROM CLASS == 

ButtonClass = {}

BUTTON_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
  INACTIVE = 2,
}

function ButtonClass:new(xPos, yPos, xSize, ySize, owner, event, sprite, spriteScale, opacity)
  local button = {}
  local metadata = {__index = ButtonClass}
  setmetatable(button, metadata)
  
  button.position = Vector(xPos, yPos)
  button.size = Vector(xSize, ySize)
  button.state = BUTTON_STATE.IDLE
  button.sprite = sprite
  button.spriteScale = spriteScale
  button.opacity = opacity
  button.owner = owner
  button.event = event
  
  return button
end

function ButtonClass:draw()

  if self.state == CARD_STATE.INACTIVE then
    return
  end

  -- Draw shadow if mouse over button
  if self.state == BUTTON_STATE.MOUSE_OVER then
    love.graphics.setColor(0, 0, 0, 0.8)
    local offset = 4
    love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, 6, 6)
  end

  love.graphics.setColor(0.5, 0.5, 0.5, 1)
  love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y)

  if self.sprite ~= nil then
    love.graphics.setColor(1, 1, 1, self.opacity)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, self.spriteScale, self.spriteScale)
  end
end

-- Checks if the mouse is over the button and whether it should be clicked
function ButtonClass:checkForMouseOver(x, y)

  if self.state == BUTTON_STATE.INACTIVE then
    return
  end

  local isMouseOver = 
    x > self.position.x and
    x < self.position.x + self.size.x and
    y > self.position.y and
    y < self.position.y + self.size.y

  self.state = isMouseOver and BUTTON_STATE.MOUSE_OVER or BUTTON_STATE.IDLE
  return isMouseOver
end

-- Runs event when clicked
function ButtonClass:onClicked()
  self.event(self.owner)
end