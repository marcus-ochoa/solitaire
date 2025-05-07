
CardDeckClass = {}

DECK_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
}

function CardDeckClass:new(xPosDeck, yPosDeck, xPosStack, yPosStack, deckSprite)

  local deck = {}
  local metadata = {__index = CardDeckClass}
  setmetatable(deck, metadata)

  deck.deck = {}
  deck.discard = {}
  deck.state = DECK_STATE.IDLE
  deck.deckPosition = Vector(xPosDeck, yPosDeck)
  deck.deckSize = Vector(70, 95)
  deck.deckSprite = deckSprite
  deck.spriteScale = 0.5

  deck.button = ButtonClass:new(xPosDeck, yPosDeck, 70, 95, deck, deck.deckClicked, deckSprite, 0.5, 1)
  deck.spread = CardSpreadClass:new(xPosStack, yPosStack, deck)

  return deck
end

-- Inserts cards into deck, called by main on load
function CardDeckClass:initInsertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.deck, card)
    card.position = self.deckPosition
    card.isFaceUp = true
  end
end

-- Replaces card succesfully moved from the draw stack with one from discard, called by spread
function CardDeckClass:onCardsMoved()
  if #self.discard > 0 then
    local card = table.remove(self.discard, 1)
    self.spread:replaceCard(card)
  end
end

-- Draws three more cards if possible, or resets deck
function CardDeckClass:deckClicked()
  
  while #self.spread.stack > 0 do
    local card = table.remove(self.spread.stack, 1)
    table.insert(self.discard, 1, card)
    card.position = self.deckPosition
  end
  
  if #self.deck > 0 then
    
    local newCards = {}
    for _ = 1, 3 do
      if #self.deck > 0 then
        local card = table.remove(self.deck)
        table.insert(newCards, card)
      end
    end
    self.spread:insertCards(newCards)
  
  else
    self.deck = self.discard
    self.discard = {}
  end

  if #self.deck <= 0 then
    self.button.opacity = 0.7
    if #self.discard <= 0 then
      self.button.opacity = 0
    end
  else
    self.button.opacity = 1
  end
end