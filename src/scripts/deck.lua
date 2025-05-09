
DeckClass = {}

function DeckClass:new(xPosDeck, yPosDeck, xPosStack, yPosStack, deckSprite)

  local deck = {}
  local metadata = {__index = DeckClass}
  setmetatable(deck, metadata)

  deck.deckPile = MinimalPileClass:new()
  deck.discardPile = MinimalPileClass:new()

  deck.button = ButtonClass:new(xPosDeck, yPosDeck, 70, 95, deck, deck.deckClicked, deckSprite, 0.5, 1)
  deck.drawPile = DrawPileClass:new(xPosStack, yPosStack, deck, deck.onCardsMoved)

  return deck
end

-- Inserts cards into deck, called by main on load
function DeckClass:initInsertCards(insertTable)
  for _, card in ipairs(insertTable) do
    table.insert(self.deckPile.stack, card)
    card.position = self.deckPile.position
  end

  self.button.spriteOpacity = 1
end

-- Replaces card succesfully moved from the draw stack with one from discard, called by draw pile
function DeckClass:onCardsMoved()
  if #self.discardPile.stack > 0 then
    local card = table.remove(self.discardPile.stack, 1)
    self.drawPile:replaceCard(card)
  end
end

-- Draws three more cards if possible, or resets deck
function DeckClass:deckClicked()

  while #self.drawPile.stack > 0 do
    local card = table.remove(self.drawPile.stack, 1)
    table.insert(self.discardPile.stack, 1, card)
    card.position = self.discardPile.position
  end

  if #self.deckPile.stack > 0 then

    local newCards = {}
    for _ = 1, 3 do
      if #self.deckPile.stack > 0 then
        local card = table.remove(self.deckPile.stack)
        table.insert(newCards, card)
      end
    end
    self.drawPile:insertCards(newCards)

  else
    self.deckPile.stack = self.discardPile.stack
    self.discardPile.stack = {}
  end

  -- Update opacity of the deck sprite according to emptiness
  if #self.deckPile.stack <= 0 then
    self.button.spriteOpacity = 0.7
    if #self.discardPile.stack <= 0 then
      self.button.spriteOpacity = 0
    end
  else
    self.button.spriteOpacity = 1
  end
end