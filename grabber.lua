
require "vector"

GrabberClass = {}

function GrabberClass:new(cardOffset)
  local grabber = {}
  local metadata = {__index = GrabberClass}
  setmetatable(grabber, metadata)

  grabber.previousMousePos = nil
  grabber.currentMousePos = nil

  grabber.grabPos = nil

  grabber.seenCard = false
  grabber.isGrabbing = false
  grabber.isReleasing = false

  grabber.cardOffset = cardOffset

  -- NEW: we'll want to keep track of the object (ie. card) we're holding
  grabber.heldObject = nil

  return grabber
end

function GrabberClass:update()
  self.currentMousePos = Vector(
    love.mouse.getX(),
    love.mouse.getY()
  )

  self.seenCard = false

  -- Click (just the first frame)
  if love.mouse.isDown(1) and self.grabPos == nil then
    self:grab()
    self.isGrabbing = true
  else
    self.isGrabbing = false
  end
  -- Release
  if not love.mouse.isDown(1) and self.grabPos ~= nil then
    self:release()
    self.isReleasing = true
  else
    self.isReleasing = false
  end

  if self.heldObject ~= nil then
    -- self.heldObject.position = self.currentMousePos

    for i, card in ipairs(grabbedTable) do
      card.position = self.currentMousePos + Vector(-35, self.cardOffset * (i - 1))
    end
  end
end

function GrabberClass:grab()
  self.grabPos = self.currentMousePos
end

function GrabberClass:release()
  -- NEW: some more logic stubs here
  if self.heldObject == nil then -- we have nothing to release
    self.grabPos = nil
    return
  end

  -- TODO: eventually check if release position is invalid and if it is
  -- return the heldObject to the grabPosition

  local isValidReleasePosition = false -- *insert actual check instead of "true"*

  for _, stack in ipairs(cardStacks) do
    if stack:checkForMouseOverStack(grabber) then
      isValidReleasePosition = true
      if stack ~= self.heldObject.stack then
        self.heldObject.stack:cardsMoved()
      end
      stack:insertCards(grabbedTable)
      break
    end
  end

  if not isValidReleasePosition then
    self.heldObject.stack:insertCards(grabbedTable)
  end

  -- self.heldObject.state = 0 -- it's no longer grabbed

  for _, card in ipairs(grabbedTable) do
    card:released()
  end

  grabbedTable = {}

  self.heldObject = nil
  self.grabPos = nil
end