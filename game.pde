// Game states
final int TITLE = 0;
final int GAME = 1;
int gameState = TITLE;

// Font
PFont customFont;

// Global fade states
final int FADE_TO_WHITE = 0;
final int SHOW_DAY_TEXT = 1;
final int SHOW_FRAMES = 2;
int fadeState = FADE_TO_WHITE;

// Grey rectangle (duvet) properties
float greyRectY = 0;
float greyRectHeight = 0;
float maxRectHeight;

// Add these variables at the top with other globals
boolean showDoorCloseup = false;
float noKeyMessageAlpha = 0;

// Add with other globals near the top
float doorCloseupAlpha = 255;

// Add these near the top with other global variables
float fadeOutAlpha = 0;
float fadeInAlpha = 255;
boolean isTransitioningToL2 = false;
final float FADE_SPEED = 0.08;  // Adjust this to control fade speed

void setup() {
  size(1200, 600);
  background(0);
  textAlign(LEFT, CENTER);
  rectMode(CENTER);
  
  // Remove bed Y initialization that was overriding our value
  maxRectHeight = height - 20;
  greyRectY = height/2;
  greyRectHeight = height/2 - 10;
  
  initializeSound();
  initializeFont();
  loadImages();
  initializeMovement();
  resetDoor();  // Add this line
}

// Add this new function
void resetDoor() {
  doorAngle = 0;
  doorScale = 1.0;
  isDoorAnimating = false;
  doorCloseupAlpha = 255;  // Add this line to reset the fade
}

void draw() {
  updateMusic();
  
  if (gameState == TITLE) {
    drawTitleScreen();
  } else if (gameState == GAME) {
    if (startFade && fadeState != SHOW_FRAMES) {
      drawTitleScreen();
    } else {
      drawGameScreen();
    }
    
    // Modified level 2 transition
    if (transitionToLevel2) {
      isTransitioningToL2 = true;
      fill(255, fadeOutAlpha);
      rect(width/2, height/2, width, height);
      fadeOutAlpha = lerp(fadeOutAlpha, 255, FADE_SPEED);
      
      if (fadeOutAlpha > 250) {
        gameState = GAME_L2;
        resetLevel2();
      }
    }
  } else if (gameState == GAME_L2) {
    drawLevel2();
    
    // Add fade-in effect for level 2
    if (isTransitioningToL2) {
      fill(255, fadeInAlpha);
      rect(width/2, height/2, width, height);
      fadeInAlpha = lerp(fadeInAlpha, 0, FADE_SPEED);
      
      if (fadeInAlpha < 5) {
        isTransitioningToL2 = false;
        fadeInAlpha = 255;
        fadeOutAlpha = 0;
      }
    }
  }

  if (pillowClicked && pillowAlpha > 0) {
    pillowAlpha -= 5;
  }
}

void mousePressed() {
  if (gameState == TITLE) {
    handleTitleScreenClick();
  } else if (gameState == GAME) {
    handleGameScreenClick();
  } else if (gameState == GAME_L2) {
    handleLevel2Click();
  }
}

void stop() {
  stopMusic();
  super.stop();
}

void drawGameScreen() {
  // Reset door on first entry to game screen
  if (fadeState == SHOW_FRAMES && !duvetFullyDown) {
    resetDoor();
  }
  
  background(255);
  
  // Draw panels
  noFill();
  stroke(0);
  strokeWeight(2);
  rect(300, height/2, 590, height - 20);
  rect(900, height/2, 590, height - 20);
  
  if (duvetFullyDown && rightPanelAlpha <= 0) {
    drawGameObjects();
    updateMovement();
    drawPlayer();
    drawClickEffect();
    
    // Check if player is near door
    float wallY = height/2 - 70;
    float doorCenterX = 150;
    float doorCenterY = wallY - 85;
    float distToDoor = dist(playerX, playerY, doorCenterX, doorCenterY + doorHeight/2 + 20);
    showDoorCloseup = distToDoor <= 50;
  }

  // Draw right panel content
  if (!duvetFullyDown || rightPanelAlpha > 0) {
    drawGirlAndDuvet();
  } else if (showDoorCloseup) {
    drawDoorCloseup();
  } else if (showBedEmpty && !isMoving) {
    drawPillowCloseup();
  }

  // Draw fading "no key" message
  if (noKeyMessageAlpha > 0) {
    fill(0, noKeyMessageAlpha);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("You don't have the key", 900, height/2);
    noKeyMessageAlpha = lerp(noKeyMessageAlpha, 0, 0.1);
  }
}

void drawDoorCloseup() {
  imageMode(CENTER);
  float rightPanelCenterX = 900;
  float rightPanelCenterY = height/2;
  float rightPanelWidth = 590;
  
  // Calculate height based on original aspect ratio (1022:1420)
  float aspectRatio = 1420.0 / 1022.0;
  float imageWidth = rightPanelWidth - 40;
  float imageHeight = imageWidth * aspectRatio;
  
  // Scale down if height exceeds panel height
  if (imageHeight > height - 40) {
    imageHeight = height - 40;
    imageWidth = imageHeight / aspectRatio;
  }
  
  // Add fade effect
  tint(255, doorCloseupAlpha);
  image(doorCloseImage, rightPanelCenterX, rightPanelCenterY, imageWidth, imageHeight);
  noTint();
  
  // Fade out after clicking with key
  if (isDoorAnimating && keyCollected) {
    doorCloseupAlpha = lerp(doorCloseupAlpha, 0, 0.1);
  }
}

void handleGameScreenClick() {
  if (showDoorCloseup) {
    float rightPanelCenterX = 900;
    float rightPanelCenterY = height/2;
    float clickableWidth = 550;
    float clickableHeight = 550;
    
    if (mouseX > rightPanelCenterX - clickableWidth/2 && 
        mouseX < rightPanelCenterX + clickableWidth/2 &&
        mouseY > rightPanelCenterY - clickableHeight/2 &&
        mouseY < rightPanelCenterY + clickableHeight/2) {
      
      if (keyCollected) {
        isDoorAnimating = true;
        doorOpenSound.play();
        doorOpenSound.amp(0.2);  
      } else {
        noKeyMessageAlpha = 255;
        doorLockSound.play();  
        doorLockSound.amp(0.3);  
      }
      return;
    }
  }

  float panelX = 610;
  float panelW = 590;
  float rightPanelCenterX = 900;
  float rightPanelCenterY = height/2;
  
  // Check for key collection
  if (showKey && !keyCollected && 
      mouseX > rightPanelCenterX - 30 && mouseX < rightPanelCenterX + 30 &&
      mouseY > rightPanelCenterY - 45 && mouseY < rightPanelCenterY - 15) {
    keyCollected = true;
    keySound.play();  
    return;
  }
  
  if (!pillowClicked && duvetFullyDown && rightPanelAlpha <= 0 && showBedEmpty) {
    if (mouseX > 700 && mouseX < 1100 && 
        mouseY > height/2 - 100 && mouseY < height/2 + 50) {
      pillowClicked = true;
      pillowAlpha = 255;
      itemSound.play();  
    }
  }
  
  if (mouseX >= panelX && mouseX <= panelX + panelW && 
      mouseY >= greyRectY - 10 && mouseY <= greyRectY + 10) {
    isDragging = true;
  }
  
  handleMouseClick();
}

void handleGameScreenDrawing() {
  if (!duvetFullyDown || rightPanelAlpha > 0) {
    drawGirlAndDuvet();
  } else {
    drawGameObjects();
  }
}

void drawGirlAndDuvet() {
  float panelX = 610;
  float panelW = 590;
  float aspect = 1550.0 / 1140.0;
  float imgHeight = panelW / aspect;
  
  // Draw girl with fade
  tint(255, rightPanelAlpha);
  imageMode(CORNER);
  image(girlImage, panelX, 10, panelW, imgHeight);
  noTint();
  
  // Draw grey rectangle (duvet)
  noStroke();
  fill(128, rightPanelAlpha);
  rectMode(CORNER);
  rect(panelX, greyRectY, panelW, maxRectHeight - greyRectY);
  
  // Draw handle with fade
  stroke(0, rightPanelAlpha);
  strokeWeight(2);
  fill(180, rightPanelAlpha);
  rectMode(CENTER);
  rect(panelX + panelW/2, greyRectY, 60, 20);
  
  // Fade out right panel when duvet is down
  if (duvetFullyDown && rightPanelAlpha > 0) {
    rightPanelAlpha -= 5;
  }
}

void drawGameObjects() {
  imageMode(CENTER);
  
  // Draw wall line
  stroke(0);
  strokeWeight(4);
  float wallY = height/2 - 70;  // Matched to movement constraints
  line(5, wallY, 595, wallY);
  
  // Draw door
  pushMatrix();
  translate(150, wallY - 85);  // Door position relative to wall line
  
  // Door frame
  stroke(0);
  strokeWeight(3);
  noFill();
  rect(0, 0, doorWidth + 10, doorHeight + 10);
  
  // Only animate if we have the key and clicked the door
  if (isDoorAnimating && keyCollected) {
    doorScale = lerp(doorScale, 0, 0.1);
    doorAngle = lerp(doorAngle, 360, 0.2);
    
    if (doorScale < 0.1) {
      transitionToLevel2 = true;  // Start transition when door is fully gone
    }
  }
  
  pushMatrix();
  rotate(radians(doorAngle));
  scale(doorScale);
  
  // Door
  stroke(0);
  strokeWeight(2);
  fill(255);
  rect(0, 0, doorWidth, doorHeight);
  
  // Door details
  line(-doorWidth/4, -doorHeight/4, doorWidth/4, -doorHeight/4);
  line(-doorWidth/4, 0, doorWidth/4, 0);
  line(-doorWidth/4, doorHeight/4, doorWidth/4, doorHeight/4);
  
  // Door handle
  fill(0);
  ellipse(20, 0, 8, 8);
  
  popMatrix();
  popMatrix();
  
  // Draw bed
  if (pillowClicked) {
    image(noPillowImage, bedX, bedY, bedWidth, bedHeight);
  } else {
    image(bedImage, bedX, bedY, bedWidth, bedHeight);
  }
}

void drawPillowCloseup() {
  imageMode(CENTER);
  float rightPanelCenterX = 900;
  float rightPanelCenterY = height/2;
  float rightPanelWidth = 590;
  
  // Draw duvet
  float duvetAspect = (float)duvetCloseImage.width / duvetCloseImage.height;
  float duvetWidth = rightPanelWidth - 40;
  float duvetHeight = duvetWidth / duvetAspect;
  image(duvetCloseImage, rightPanelCenterX, rightPanelCenterY + 100, duvetWidth, duvetHeight);
  
  // Draw pillow if not clicked or still fading
  if (!pillowClicked || pillowAlpha > 0) {
    float pillowAspect = (float)pillowCloseImage.width / pillowCloseImage.height;
    float pillowWidth = rightPanelWidth - 80;
    float pillowHeight = pillowWidth / pillowAspect;
    
    if (pillowClicked) {
      tint(255, pillowAlpha);
    }
    image(pillowCloseImage, rightPanelCenterX, rightPanelCenterY - 50, pillowWidth, pillowHeight);
    if (pillowClicked) {
      noTint();
    }
  }
  
  // Draw key if pillow is gone
  if (pillowClicked && pillowAlpha <= 0) {
    showKey = true;
    if (!keyCollected) {
      keyAlpha = lerp(keyAlpha, 255, 0.1);
      tint(255, keyAlpha);
      image(keyImage, rightPanelCenterX, rightPanelCenterY - 30, 60, 30);
      noTint();
    }
  }
  
  // Show collection text
  if (keyCollected) {
    fill(0);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Key Acquired.", rightPanelCenterX, rightPanelCenterY + 100);
  }
}

void mouseDragged() {
  if (gameState == GAME && isDragging) {
    greyRectY = constrain(mouseY, height/2 - 50, height - 70);
    if (greyRectY >= height - 70) {
      duvetFullyDown = true;
      isDragging = false;
      playerX = bedX - bedWidth/2 - 50;
      playerY = bedY;
      targetX = playerX;
      targetY = playerY;
      rightPanelAlpha = 255; // Reset alpha before fade
    }
  }
}

void mouseReleased() {
  isDragging = false;
}

void resetLevel2() {
  level2TransitionAlpha = 0;
  transitionToLevel2 = false;
  for (int i = 0; i < doorStates.length; i++) {
    doorStates[i] = false;
  }
  
  // Add music transition
  level2Music.play();
  level2Music.loop();
  level2Music.amp(0);
  musicVolume = 0.0;
  isFadingMusic = true;
  
  // Reset fade variables
  fadeOutAlpha = 0;
  fadeInAlpha = 255;
}
