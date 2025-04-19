
-- === USED STARTER CODE FROM CLASS == 

require "vector"

GrabberClass = {}

GRABBER_STATE = {
  IDLE = 0,
  GRABBING = 1,
  RELEASING = 2
}

function GrabberClass:new(cardOffset, cardStacks)
  local grabber = {}
  local metadata = {__index = GrabberClass}
  setmetatable(grabber, metadata)

  grabber.previousMousePos = nil
  grabber.currentMousePos = nil
  grabber.grabPos = nil
  grabber.seenCard = false
  grabber.state = GRABBER_STATE.IDLE
  grabber.grabbedTable = {}
  grabber.cardOffset = cardOffset
  grabber.cardStacks = cardStacks
  grabber.heldObject = nil

  return grabber
end

function GrabberClass:update()

  -- Get mouse position
  self.currentMousePos = Vector(
    love.mouse.getX(),
    love.mouse.getY()
  )

  self.seenCard = false
  self.state = GRABBER_STATE.IDLE

  -- Click (just the first frame)
  if love.mouse.isDown(1) and self.grabPos == nil then
    self:grab()
    self.state = GRABBER_STATE.GRABBING
  end
  
  -- Release
  if not love.mouse.isDown(1) and self.grabPos ~= nil then
    self:release()
    self.state = GRABBER_STATE.RELEASING
  end

  -- Update grabbed card positions
  if self.heldObject ~= nil then
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

-- Sets grab position
function GrabberClass:grab()
  self.grabPos = self.currentMousePos
end

-- Called by cards or deck button to set the top grabbed card
function GrabberClass:setGrab(topCard)
  self.state = GRABBER_STATE.IDLE
  -- If the deck is clicked, it will not pass a card
  if topCard then
    self.heldObject = topCard
  end
end

-- Called by cards to set that the grabber has seen a card
function GrabberClass:setSeenCard()
  self.seenCard = true
end

-- Inserts cards into grabbed table, called by cards
function GrabberClass:insertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.grabbedTable, card)
  end
end

-- Releases cards
function GrabberClass:release()

  -- Nothing to release if you aren't holding anything
  if self.heldObject == nil then
    self.grabPos = nil
    return
  end

  -- Check all stacks and try to release if possible
  local isValidReleasePosition = false

  for _, stack in ipairs(self.cardStacks) do
    if stack:checkForMouseOverStack(self) then
      isValidReleasePosition = stack:checkForValidRelease(self)

      -- If over a valid stack, notify previous stack and add cards to grabbed table
      if isValidReleasePosition then
        if stack ~= self.heldObject.stack then
          self.heldObject.stack:cardsMoved()
        end
        stack:insertCards(self.grabbedTable)
      end
      break
    end
  end

  -- If invalid release, put the cards back in the previous stack
  if not isValidReleasePosition then
    self.heldObject.stack:insertCards(self.grabbedTable)
  end

  -- Release all cards from grabbed table
  for _, card in ipairs(self.grabbedTable) do
    card:released()
  end

  -- Reset grabbed variables
  self.grabbedTable = {}
  self.heldObject = nil
  self.grabPos = nil
end