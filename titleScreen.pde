float doorX = 400;
float doorY = 400;
float doorWidth = 80;
float doorHeight = 160;
float doorAngle = 0;
float doorScale = 1.0;
boolean isDoorOpening = false;
float textOpacity = 255;
float whiteScreenAlpha = 0;
float dayTextAlpha = 0;
float frameAlpha = 0;
boolean startFade = false;
boolean showDayText = false;
float stickFigureX = 100;
float stickFigureY = 480;

void drawTitleScreen() {
  drawPanels();
  drawWallAndDoor();
  drawCharacter();
  drawTitleText();
  
  if (startFade) {
    handleFadeTransition();
  }
}

void handleTitleScreenClick() {
  if (mouseX > 360 && mouseX < 440 && 
      mouseY > doorY - doorHeight/2 && mouseY < doorY + doorHeight/2) {
    if (!isDoorOpening) {
      isDoorOpening = true;
      doorScale = 1.0;
      doorOpenSound.play();
      doorOpenSound.amp(0.2); 
    } else if (doorScale < 0.1) {
      startFade = true;
      gameState = GAME;
      
      initializeMovement();
      playerX = 100;
      playerY = height/2;
      targetX = playerX;
      targetY = playerY;
      
      gameMusic.play();
      gameMusic.loop();
      gameMusic.amp(0);
      musicVolume = 0.0;
      isFadingMusic = true;
    }
  }
}

void drawPanels() {
  // Left panel
  noStroke();
  fill(255);
  rect(300, height/2, 590, height - 20);
  
  // Right panel
  fill(0);
  stroke(255);
  strokeWeight(2);
  rect(900, height/2, 590, height - 20);
}

void drawWallAndDoor() {
  // Wall line
  stroke(0);
  strokeWeight(4);
  line(0, doorY + doorHeight/2 + 10, 600, doorY + doorHeight/2 + 10);
  
  // Door
  pushMatrix();
  translate(400, doorY);
  
  // Door frame
  stroke(0);
  strokeWeight(3);
  noFill();
  rect(0, 0, doorWidth + 10, doorHeight + 10);
  
  if (isDoorOpening) {
    doorScale = lerp(doorScale, 0, 0.1);
    doorAngle = lerp(doorAngle, 360, 0.2);
    textOpacity = lerp(textOpacity, 0, 0.1);
  }
  
  pushMatrix();
  rotate(radians(doorAngle));
  scale(doorScale);
  
  // Door and details
  stroke(0);
  strokeWeight(2);
  fill(255);
  rect(0, 0, doorWidth, doorHeight);
  line(-doorWidth/4, -doorHeight/4, doorWidth/4, -doorHeight/4);
  line(-doorWidth/4, 0, doorWidth/4, 0);
  line(-doorWidth/4, doorHeight/4, doorWidth/4, doorHeight/4);
  
  // Handle
  fill(0);
  ellipse(20, 0, 8, 8);
  
  popMatrix();
  popMatrix();
}

void drawCharacter() {
  pushMatrix();
  imageMode(CENTER);
  // Shadow
  noStroke();
  fill(0, 50);
  ellipse(stickFigureX, stickFigureY + 60, 60, 30);  // Adjusted Y offset from +40 to +20
  
  // Character
  image(playerSprites[2], stickFigureX, stickFigureY, 200, 200);
  popMatrix();
}

void drawTitleText() {
  textSize(72);
  fill(255, textOpacity);
  text("THE", 650, height/2 - 50);
  text("DOOR", 650, height/2 + 50);
  
  textSize(18);
  fill(255, textOpacity * 0.6);
  text("Click the door to begin", 650, height - 40);
}

void handleFadeTransition() {
  switch(fadeState) {
    case FADE_TO_WHITE:
      whiteScreenAlpha = lerp(whiteScreenAlpha, 255, 0.05);
      fill(255, whiteScreenAlpha);
      rect(width/2, height/2, width, height);
      if (whiteScreenAlpha > 250) {
        fadeState = SHOW_DAY_TEXT;
        showDayText = true;
      }
      break;
      
    case SHOW_DAY_TEXT:
      fill(255);
      rect(width/2, height/2, width, height);
      
      if (showDayText) {
        dayTextAlpha = lerp(dayTextAlpha, 255, 0.05);
        fill(0, dayTextAlpha);
        textSize(92);
        textAlign(CENTER, CENTER);
        text("The Day", width/2, height/2);
        
        if (dayTextAlpha > 250 && frameCount % 120 == 0) {
          showDayText = false;
        }
      } else {
        dayTextAlpha = lerp(dayTextAlpha, 0, 0.05);
        fill(0, dayTextAlpha);
        textSize(92);
        textAlign(CENTER, CENTER);
        text("The Day", width/2, height/2);
        
        if (dayTextAlpha < 5) {
          fadeState = SHOW_FRAMES;
        }
      }
      break;
      
    case SHOW_FRAMES:
      fill(255);
      rect(width/2, height/2, width, height);
      frameAlpha = lerp(frameAlpha, 255, 0.05);
      stroke(0, frameAlpha);
      strokeWeight(4);
      noFill();
      rect(300, height/2, 590, height - 20);
      rect(900, height/2, 590, height - 20);
      break;
  }
}