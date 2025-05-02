
-- === USED STARTER CODE FROM CLASS == 

require "vector"

GrabberClass = {}

GRABBER_STATE = {
  IDLE = 0,
  GRABBING = 1,
  GRABBED = 2,
}

function GrabberClass:new(cardOffset, cardStacks)
  local grabber = {}
  local metadata = {__index = GrabberClass}
  setmetatable(grabber, metadata)

  grabber.currentMousePos = nil
  grabber.seenCard = false
  grabber.state = GRABBER_STATE.IDLE
  grabber.grabbedTable = {}
  grabber.cardOffset = cardOffset
  grabber.cardStacks = cardStacks

  return grabber
end

function GrabberClass:update()

  -- Get mouse position
  self.currentMousePos = Vector(
    love.mouse.getX(),
    love.mouse.getY()
  )

  self.seenCard = false

  -- Even if no card was found, mouse is still down
  if self.state == GRABBER_STATE.GRABBING then
    self.state = GRABBER_STATE.GRABBED
  end

  -- Set state to grabbing so other cards know they can be grabbed this frame
  if love.mouse.isDown(1) and self.state == GRABBER_STATE.IDLE then
    self.state = GRABBER_STATE.GRABBING
  end
  
  -- Release
  if (not love.mouse.isDown(1)) and self.state == GRABBER_STATE.GRABBED then
    self:release()
    self.state = GRABBER_STATE.IDLE
  end

  -- Update grabbed card positions
  if #self.grabbedTable > 0 then
    for i, card in ipairs(self.grabbedTable) do
      card:updatePosition(self.currentMousePos + Vector(-35, (self.cardOffset * (i - 1)) - 45))
    end
  end
end

-- Draws all grabbed cards
function GrabberClass:draw()
  for _, card in ipairs(self.grabbedTable) do
    card:draw()
  end
end

-- Called by cards or deck button to set the top grabbed card
function GrabberClass:setGrab()
  self.state = GRABBER_STATE.GRABBED
end

-- Called by cards to set that the grabber has seen a card
function GrabberClass:setSeenCard()
  self.seenCard = true
end

-- Inserts cards into grabbed table, called by stack
function GrabberClass:insertCards(insertTable)
  for _, card in ipairs(insertTable) do
    card:setGrabbed()
    table.insert(self.grabbedTable, card)
  end
end

-- Releases cards
function GrabberClass:release()

  -- Nothing to release if you aren't holding anything
  if #self.grabbedTable <= 0 then
    return
  end

  -- Check all stacks and try to release if possible
  local isValidReleasePosition = false

  for _, stack in ipairs(self.cardStacks) do
    if stack:checkForMouseOverStack(self) then
      isValidReleasePosition = stack:checkForValidRelease(self)

      -- If over a valid stack, notify previous stack and add cards to grabbed table
      if isValidReleasePosition then
        if stack ~= self.grabbedTable[1].stack then
          self.grabbedTable[1].stack:cardsMoved()
        end
        stack:insertCards(self.grabbedTable)
      end
      break
    end
  end

  -- If invalid release, put the cards back in the previous stack
  if not isValidReleasePosition then
    self.grabbedTable[1].stack:insertCards(self.grabbedTable)
  end

  -- Release all cards from grabbed table
  for _, card in ipairs(self.grabbedTable) do
    card:setReleased()
  end

  -- Reset grabbed variables
  self.grabbedTable = {}
end