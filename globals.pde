// Player properties
float playerX = 100;
float playerY = 500;

// Bed properties
float bedX = 300 + 240;  // Right side of left panel
float bedY = 300;  // Positioned vertically centered in the panel
float bedWidth = 100;
float bedHeight = 180;
boolean showBedEmpty = false;

// Door properties
boolean isDoorAnimating = false;  // Only keep the new property

// Level transition properties
boolean transitionToLevel2 = false;
float level2TransitionAlpha = 0;
boolean showLevel2Text = false;

// Game state properties
boolean pillowClicked = false;
float pillowAlpha = 255;
boolean keyCollected = false;  // New variable to track key state
boolean showKey = false;  // Show key after pillow fades
float keyAlpha = 0;  // For fade in effect
boolean duvetFullyDown = false;
float rightPanelAlpha = 255;

// Interaction state
boolean isDragging = false;

final int ENDING = 3;  // Add this line

// Ending properties
float endingAlpha = 0;
String endingText = "Thank you for playing";
boolean endingInitialized = false;
float textFadeAlpha = 0;

