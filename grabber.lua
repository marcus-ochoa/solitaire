
-- === USED STARTER CODE FROM CLASS == 

GrabberClass = {}

function GrabberClass:new(cardStacks, buttons)
  local grabber = {}
  local metadata = {__index = GrabberClass}
  setmetatable(grabber, metadata)

  grabber.grabbedPile = GrabbedPileClass:new()

  grabber.cardStacks = cardStacks
  grabber.buttons = buttons
  grabber.prevStack = nil

  return grabber
end

function GrabberClass:onMouseMoved(x, y)

  for _, button in ipairs(self.buttons) do
    button:checkForMouseOver(x, y)
  end

  for _, stack in ipairs(self.cardStacks) do
    stack:checkForMouseOverCard(x, y)
  end

  self.grabbedPile:updatePosition(x, y)
end

function GrabberClass:onMousePressed(x, y)

  for _, button in ipairs(self.buttons) do
    if button:checkForMouseOver(x, y) then
      button:onClicked()
      return
    end
  end

  for _, stack in ipairs(self.cardStacks) do
    local card = stack:checkForMouseOverCard(x, y)
    if card ~= nil then
      self.grabbedPile:insertCards(stack:removeCards(card))
      self.prevStack = stack
      return
    end
  end
end


-- Releases cards
function GrabberClass:onMouseReleased(x, y)
  -- Nothing to release if you aren't holding anything
  if #self.grabbedPile.stack <= 0 then
    return
  end

  -- Check all stacks and try to release if possible
  local isValidReleasePosition = false

  for _, stack in ipairs(self.cardStacks) do
    if stack:checkForMouseOverStack(x, y) then
      isValidReleasePosition = stack:checkForValidRelease(self.grabbedPile)

      -- If over a valid stack, notify previous stack and add cards to grabbed table
      if isValidReleasePosition then
        if stack ~= self.prevStack then
          self.prevStack:cardsMoved()
        end
        stack:insertCards(self.grabbedPile:removeCards())
      end

      break
    end
  end

  -- If invalid release, put the cards back in the previous stack
  if not isValidReleasePosition then
    self.prevStack:insertCards(self.grabbedPile:removeCards())
  end
end