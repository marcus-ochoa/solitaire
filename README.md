# Soli-tearing My Hair Out (Solitaire)
**CMPM121 Project**\
Marcus Ochoa

## Assets
Kenney Assets (Playing Cards): https://kenney.nl/assets/boardgame-pack\

## Information
### Programming Patterns
**Update Method**\
The update method pattern is being used by the LOVE2D engine to update game logic every frame. In particular I opted to use the engine's mouse pressed, mouse released, and mouse moved events which are called using an update to dictate player input. 

**Game Loop**\
The game loop pattern is used by the LOVE2D engine to both update and draw the game each frame. This allows the game to be functional and display or render game state to the player. Within this loop a double buffer pattern is also used to accurately render the game state.

**Prototype**\
All of the "classes" used are implementations of the prototype pattern using lua tables rather than proper classes. For example, all the "subclasses" of the pile "class" are new pile objects with some overridden or additional fields and methods. This pattern allows fields and methods to be encapsulated between pile classes and also allows for a kind of inheritance where fields and methods derived from one pile prototype can be shared between other pile prototypes.

**Component**\
The draw pile and button classes are used as components by other classes. Both allow the owning object to pass in a function to be called by the component when an event occurs. In particular, the deck class is made up of two minimal pile instances, one draw pile instance, and one button instance. This allows the functions of the deck which involve pressing a button to draw new cards, displaying the new cards, and storing cards hidden in the deck to all be decoupled and separately managed in their own component objects.

**States**\
The state pattern is used to specify card state (idle/mouse over/grabbed) and button state (idle/mouse over/inactive). This enables the cards and buttons to easily be drawn differently or function differently according to state. For example, a grabbed card is drawn with a shadow while an idle card is drawn without one. And an inactive button is not drawn or able to be interacted with.

**Flyweight Pattern**\
The flyweight pattern is used where a singular instance of the back-of-card sprite is referenced by all cards, rather than creating a new instance of the sprite for each card. This reduces sprite data loaded by a factor of the number of cards.

### Feedback
**Dilbert Iraheta**\
Feedback: Thought the code was overall well written. Noted that the grabber class was heavily coupled with the card class and there was room for modularization of the grabber class. Suggested merging the card pile and card stack classes since they shared most of their behavior. Suggested using the engine's mouse pressed, mouse released, and mouse moved events to simplify grabber logic and state. Felt that the grabber should not need to be drawing cards. Suggested defining random integers (mostly used for sizing or scale) as constants for better clarity. 

Adjustments: I decoupled the grabber class from the card class by moving logic changing card states to the pile class. I merged the card pile and card stack classes and made all containers of cards subclasses of a singular card pile class. I used the engine mouse events instead of trying to track pressed, held, and released states in the grabber. I defined some scaling and sizing numbers as constants. I also had all cards be drawn by their piles instead of by classes like the grabber or deck classes.

**Isaac Kim**\
Feedback: Noticed there was repeated constructor logic in the pile class, where the same fields were being redefined in the same way in each subclass. Suggested using a separate initialize method which could be overridden by the subclasses. Felt that the pile class should not hold placement validation logic and suggested this logic should be delegated to a separate class.

Adjustments: I realized I could call methods to be overridden later in other class methods not meant to be overridden and therefore insert overridable logic in the middle of inherited logic. I used this to add extra logic to cards being inserted and removed for certain piles. 

**Brian Hudick**\
Feedback: Found my naming conventions and general style to be consistent and clean. Felt that my pile classes heavily depended on each other. Suggested an observer class to be used.

Adjustments: I made small changes to minimize the amount of logic necessary to be overridden by the pile subclasses while keeping the base class clear and uncluttered. I allowed functions to be passed into class instances so the instance can call the function when necessary as a kind of crude event.

### Postmortem
The largest pain points of the project were the grabber class and pile or stack classes. In the first iteration of the project, the pile and stack and deck classes all clearly had the same kind of logic which held cards, moved them, and displayed them which I had basically rewritten across each class separately with only minor changes. Having all of these card containers inherit from a singular card pile class was meant to reduce the repeated logic and allow for more consistent interfacing. I think I did a decent job in reducing the amount of logic repeated and because I decided to have all card containers be instances of the pile class (including invisible containers like the discard pile) this allows me to have access to consistent methods to access all possible places cards can be at any time. This kind of flexibility made behavior like the reset much easier to implement. The grabber class now operates as much more of a standard player class, taking the input events from the engine and translating them to simple actions performed on the card containers. Now the grabber class has a pile component instead of doing logic on the cards themselves, making operations much simpler. However I am still having the grabber iterate over all stacks and buttons on input, which can perhaps be decoupled so the grabber class only has to deal with moving cards between piles. The deck class is also greatly improved by splitting its logic into button and pile components. Now I can call simple commands between the piles based on simple button click events instead of changing card and sprite states constantly. Overall I feel like my code is much more readable and easier to work with now. A few concerns I still have are with the functions present in the main file which I feel can be moved to some kind of game manager class, the precise role of the grabber in the code (what logic it should be in charge of), and efficiency of the pile classes (how can I make interfacing with them even simpler).   
