# Soli-tearing My Hair Out (Solitaire)
**CMPM121 Project**\
Marcus Ochoa

## Assets
Kenney Assets (Playing Cards): https://kenney.nl/assets/boardgame-pack\

## Information
### Programming Patterns
**Update Method**\
The update method pattern is being used by the LOVE2D engine to update game logic every frame. I used this to change the state of the game and game objects over discrete periods of time to allow the player to click and drag and do things.

**Game Loop**\
The game loop pattern is used by the LOVE2D engine to both update and draw the game each frame. I used this so the game would convey changes to the game state like card position to the player.

**Object Pool**\
The cards are kept in stacks and moved between them. All the stacks are initialized at loadtime in one table that is updated/drawn each frame. This allowed cards and stacks to be updated efficiently and meant they only had to be created once.

**States**\
The state pattern is used to specify card state (grabbed/idle/mouse over). This was used so that the mouse over check was only performed in an idle state and the card was drawn according to its state. The card could only exclusively be in one of these states at a time so it made sense to implement.

**Flyweight Pattern**\
The flyweight pattern is used by having the back of the card sprites and ace sprites (for the foundations) be referenced by all cards. This was used to reduce sprite data loaded since all the backs of the cards are the same


### Postmortem
I believe that creating stacks and passing cards between stacks was a good way to implement stacking. Having the grabber class interface with stacks which have their own internal functionality allows the grabber to easily interact with cards. I think I could have created a more encapsulated stack class which could have been used by the column, foundation, and deck classes instead of doing a sort of interface implementation which I ended up going with. Even a type object pattern could have been used to create different types of stacks (like one that hides cards except the top one or has a different offset).








