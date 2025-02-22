final int GAME_L2 = 2;
float[] doorPositions = {100, 225, 350, 475};
boolean[] doorStates = {false, false, false, false};
int[] doorSequence;
int currentSequenceIndex = 0;
float puzzleCompletionAlpha = 0;
boolean puzzleSolved = false;
float[] doorGlowAlpha = {0, 0, 0, 0};
boolean showSuccessMessage = false;
float messageAlpha = 0;
float levelTimer = 60;
float doorCloseTimer = -1;
boolean timerActive = false;
color[] doorGlowColors = {#FFFF00, #FFFF00, #FFFF00, #FFFF00}; // Default yellow for all doors

void drawLevel2() {
  if (doorSequence == null) {
    initializeLevel2();
  }
  
  background(255);
  
  if (timerActive) {
    levelTimer -= 1.0/frameRate;
    if (levelTimer <= 0) {
      resetLevel();
      messageAlpha = 255;
      showSuccessMessage = false;
    }
  }
  
  if (doorCloseTimer > 0) {
    doorCloseTimer -= 1.0/frameRate;
    if (doorCloseTimer <= 0) {
      closeAllDoors();
    }
  }
  
  noFill();
  stroke(0);
  strokeWeight(2);
  rect(300, height/2, 590, height - 20);
  rect(900, height/2, 590, height - 20);
  
  pushMatrix();
  translate(5, 0);
  drawMainPuzzleScene();
  popMatrix();
  
  pushMatrix();
  translate(605, 0);
  drawHintScene();
  popMatrix();
  
  if (puzzleSolved) {
    fill(255, puzzleCompletionAlpha);
    rect(width/2, height/2, width, height);
    puzzleCompletionAlpha = lerp(puzzleCompletionAlpha, 255, 0.05);
    
    if (puzzleCompletionAlpha > 250) {
      gameState = ENDING;
    }
  }
}

void handleLevel2Click() {
  if (!timerActive) {
    timerActive = true;
  }
  
  for (int i = 0; i < doorPositions.length; i++) {
    if (checkDoorClick(doorPositions[i], i)) {
      if (i == doorSequence[currentSequenceIndex]) {
        doorStates[i] = true;
        doorGlowAlpha[i] = 255;
        doorGlowColors[i] = #FFFF00; // Yellow for correct
        currentSequenceIndex++;
        keySound.play();
        
        doorCloseTimer = 5.0;
        
        if (currentSequenceIndex >= doorSequence.length) {
          puzzleSolved = true;
          showSuccessMessage = true;
          timerActive = false;
        }
      } else {
        doorGlowAlpha[i] = 255;
        doorGlowColors[i] = #FF0000; // Red for incorrect
        messageAlpha = 255;
        showSuccessMessage = false;
        closeAllDoors();
        regeneratePuzzle(); // Add this line to regenerate on failure
      }
    }
  }
}

void drawMessage(String message, float size, color messageColor) {
  textSize(size);
  textAlign(CENTER, CENTER);
  
  fill(0, messageAlpha * 0.3);
  text(message, width/2 + 2, height/2 + 2);
  
  fill(messageColor, messageAlpha);
  text(message, width/2, height/2);
}

void drawMainPuzzleScene() {
  noStroke();
  fill(255);
  rect(300, height/2, 590, height - 20);
  
  stroke(0);
  strokeWeight(4);
  float wallY = height/2 - 70;
  line(5, wallY, 595, wallY);
  
  for (int i = 0; i < doorPositions.length; i++) {
    drawDoor(doorPositions[i], doorStates[i], wallY);
  }
  
  textAlign(LEFT, TOP);
  textSize(24);
  fill(0);  // Always full opacity black
  text(currentSequenceIndex + "/10", 50, 30);
  
  for (int i = 0; i < doorPositions.length; i++) {
    if (doorGlowAlpha[i] > 0) {
      noStroke();
      for (int r = 100; r > 0; r -= 20) {
        float alpha = (doorGlowAlpha[i] * r/100) * 0.5;
        fill(doorGlowColors[i], alpha); // Use the door's glow color
        ellipse(doorPositions[i], wallY - 85, r, r);
      }
      doorGlowAlpha[i] = lerp(doorGlowAlpha[i], 0, 0.1);
    }
  }
}

void drawHintScene() {
  noStroke();
  fill(240);
  rect(300, height/2, 590, height - 20);
  
  if (currentSequenceIndex < doorSequence.length) {
    float startX = 75;  // Changed from 100 to 75
    float spacing = 50;
    float centerY = height/2;
    float symbolSize = 30;
    
    // Draw connecting line
    stroke(0, 30);
    strokeWeight(1);
    line(startX, centerY, startX + spacing * 9, centerY);
    
    for (int i = 0; i < 10; i++) {
      float x = startX + (i * spacing);
      float y = centerY;
      
      // Calculate opacity
      float symbolAlpha;
      if (i < currentSequenceIndex) {
        symbolAlpha = 40;  // Past symbols are very faint
      } else if (i == currentSequenceIndex) {
        symbolAlpha = 255; // Current symbol is fully visible
      } else {
        symbolAlpha = 120; // Future symbols are partially visible
      }
      
      noFill();
      strokeWeight(1.5);
      stroke(0, symbolAlpha);
      
      switch(doorSequence[i]) {
        case 0: // Empty circle
          ellipse(x, y, symbolSize, symbolSize);
          break;
        case 1: // Half circle
          arc(x, y, symbolSize, symbolSize, -HALF_PI, HALF_PI);
          break;
        case 2: // Circle with line
          ellipse(x, y, symbolSize, symbolSize);
          line(x - symbolSize/2, y, x + symbolSize/2, y);
          break;
        case 3: // Filled circle
          fill(0, symbolAlpha);
          ellipse(x, y, symbolSize, symbolSize);
          break;
      }
      
      // Draw small dot to mark current position
      if (i == currentSequenceIndex) {
        fill(0, 255);
        noStroke();
        ellipse(x, y + symbolSize/2 + 10, 4, 4);
      }
    }
  }
}

void drawDoor(float x, boolean isOpen, float wallY) {
  pushMatrix();
  translate(x, wallY - 85);
  
  stroke(0);
  strokeWeight(3);
  noFill();
  rect(0, 0, doorWidth + 10, doorHeight + 10);
  
  if (!isOpen) {
    stroke(0);
    strokeWeight(2);
    fill(255);
    rect(0, 0, doorWidth, doorHeight);
    
    stroke(0);
    line(-doorWidth/4, -doorHeight/4, doorWidth/4, -doorHeight/4);
    line(-doorWidth/4, 0, doorWidth/4, 0);
    line(-doorWidth/4, doorHeight/4, doorWidth/4, doorHeight/4);
    
    fill(0);
    ellipse(20, 0, 8, 8);
  }
  
  popMatrix();
}

boolean checkDoorClick(float doorX, float doorIndex) {
  float wallY = height/2 - 70;
  float doorCenterY = wallY - 85;
  
  return (mouseX > doorX - doorWidth/2 && mouseX < doorX + doorWidth/2 &&
          mouseY > doorCenterY - doorHeight/2 && mouseY < doorCenterY + doorHeight/2);
}

void closeAllDoors() {
  for (int i = 0; i < doorStates.length; i++) {
    doorStates[i] = false;
  }
  currentSequenceIndex = 0;
  messageAlpha = 0;
  showSuccessMessage = false;
}

void regeneratePuzzle() {
  doorSequence = generateRandomSequence();
  currentSequenceIndex = 0;
}

void resetLevel() {
  closeAllDoors();
  regeneratePuzzle(); // Also regenerate when resetting level
  // Reset glow colors to yellow
  for (int i = 0; i < doorGlowColors.length; i++) {
    doorGlowColors[i] = #FFFF00;
  }
  levelTimer = 60;
  timerActive = false;
  messageAlpha = 255;
}

void initializeEnding() {
    endingAlpha = 0;
    textFadeAlpha = 0;
    endingInitialized = true;
    
    stopMusic();
    
    puzzleSolved = false;
    showSuccessMessage = false;
    messageAlpha = 0;
}

void checkPuzzleCompletion() {
  if (puzzleSolved && puzzleCompletionAlpha >= 250) {
    stopMusic();
    initializeEnding();  
  }
}

void initializeLevel2() {
  doorSequence = generateRandomSequence();
  resetLevel();
}

int[] generateRandomSequence() {
  int[] sequence = new int[10];
  
  for (int i = 0; i < sequence.length; i++) {
    int newValue;
    do {
      newValue = int(random(4));
      // Keep generating new values if it's the same as the previous one
      // (except for the last element which should match the first)
    } while (i > 0 && i != 9 && newValue == sequence[i-1]);
    
    sequence[i] = newValue;
  }
  
  // Ensure first and last match
  sequence[9] = sequence[0];
  // Keep position 4 matching position 3
  sequence[4] = sequence[3];
  
  return sequence;
}
