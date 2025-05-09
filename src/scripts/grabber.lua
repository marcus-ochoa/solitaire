
-- === USED STARTER CODE FROM CLASS == 

GrabberClass = {}

function GrabberClass:new(piles, buttons)
  local grabber = {}
  local metadata = {__index = GrabberClass}
  setmetatable(grabber, metadata)
  grabber.grabbedPile = GrabbedPileClass:new()

  grabber.piles = piles
  grabber.buttons = buttons
  grabber.prevPile = nil

  return grabber
end

-- Check over all buttons and cards to update states and update grabbed pile position
function GrabberClass:onMouseMoved(x, y)

  for _, button in ipairs(self.buttons) do
    button:checkForMouseOver(x, y)
  end

  for _, stack in ipairs(self.piles) do
    stack:checkForMouseOverCard(x, y)
  end

  self.grabbedPile:updatePosition(x, y)
end

-- Check over all buttons and piles to interact
function GrabberClass:onMousePressed(x, y)

  for i = #self.buttons, 1, -1 do
    if self.buttons[i]:checkForMouseOver(x, y) then
      self.buttons[i]:onClicked()
      return
    end
  end

  -- If over a grabbable card, add it to the grabbed pile
  for _, stack in ipairs(self.piles) do
    local card = stack:checkForMouseOverCard(x, y)
    if card ~= nil then
      self.grabbedPile:insertCards(stack:removeCards(card))
      self.prevPile = stack
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

  for _, stack in ipairs(self.piles) do
    if stack:checkForMouseOverStack(x, y) then
      isValidReleasePosition = stack:checkForValidRelease(self.grabbedPile)

      -- If over a valid stack, notify previous stack and add cards to grabbed pile
      if isValidReleasePosition then
        if stack ~= self.prevPile then
          self.prevPile:cardsMoved()
        end
        stack:insertCards(self.grabbedPile:removeCards())
      end

      break
    end
  end

  -- If invalid release, put the cards back in the previous pile
  if not isValidReleasePosition then
    self.prevPile:insertCards(self.grabbedPile:removeCards())
  end
end