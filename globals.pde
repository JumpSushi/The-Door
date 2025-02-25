
// player
float playerX = 100;
float playerY = 500;
//bed
float bedX = 300 + 240;  
float bedY = 300;  
float bedWidth = 100;
float bedHeight = 180;
boolean showBedEmpty = false;

// door prop
boolean isDoorAnimating = false; 

// lvel trans
boolean transitionToLevel2 = false;
float level2TransitionAlpha = 0;
boolean showLevel2Text = false;

// states
boolean pillowClicked = false;
float pillowAlpha = 255;
boolean keyCollected = false; 
boolean showKey = false;  // show key after pillow
float keyAlpha = 0; 
boolean duvetFullyDown = false;
float rightPanelAlpha = 255;

// Interaction state
boolean isDragging = false;

final int ENDING = 3; 

// ending 
float endingAlpha = 0;
String endingText = "Thank you for playing";
boolean endingInitialized = false;
float textFadeAlpha = 0;