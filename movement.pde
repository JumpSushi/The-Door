float targetX;
float targetY;
float playerSpeed = 4;
boolean isMoving = false;
int currentFrame = 0;
int frameDelay = 12;
int movementFrameCount = 0;
boolean isFacingLeft = false;

// Click feedback properties
float clickAlpha = 0;
float clickX = 0;
float clickY = 0;
boolean showClickEffect = false;

void initializeMovement() {
  targetX = playerX;
  targetY = playerY;
}

void checkBedProximity() {
  float distToBed = dist(playerX, playerY, bedX, bedY);
  showBedEmpty = distToBed <= 100;
}

void updateMovement() {
  checkBedProximity();
  
  if (!isMoving) return;
  
  float dx = targetX - playerX;
  float dy = targetY - playerY;
  float distance = sqrt(dx*dx + dy*dy);
  
  // Update facing direction based on movement
  if (abs(dx) > 0.1) {  // Only update direction if there's significant horizontal movement
    isFacingLeft = dx < 0;
  }
  
  if (distance < 5) {
    playerX = targetX;
    playerY = targetY;
    isMoving = false;
    currentFrame = 0;
    return;
  }
  
  float currentSpeed = distance < 20 ? playerSpeed * 0.5 : playerSpeed;
  
  dx /= distance;
  dy /= distance;
  
  float nextX = playerX + dx * currentSpeed;
  float nextY = playerY + dy * currentSpeed;
  
  // Collision bounds
  float collisionMargin = 20;
  boolean collidesWithBed = 
    nextX + collisionMargin > bedX - bedWidth/2 &&
    nextX - collisionMargin < bedX + bedWidth/2 &&
    nextY + collisionMargin > bedY - bedHeight/2 && 
    nextY - collisionMargin < bedY + bedHeight/2;
  
  if (!collidesWithBed) {
    // Panel boundaries
    float leftBound = 300 - (590/2) + 30;
    float rightBound = 300 + (590/2) - 30;
    float topBound = 100;  // Adjusted even higher to allow movement near bed
    float bottomBound = height - 60;
    
    playerX = constrain(nextX, leftBound, rightBound);
    playerY = constrain(nextY, topBound, bottomBound);
    
    movementFrameCount++;
    if (movementFrameCount >= frameDelay) {
      currentFrame = (currentFrame + 1) % 6;
      movementFrameCount = 0;
    }
  }
}

void drawPlayer() {
  pushMatrix();
  imageMode(CENTER);
  
  noStroke();
  fill(0, 50);
  ellipse(playerX, playerY + 40, 60, 30);
  
  if (playerX >= 5 && playerX <= 595) {
    pushMatrix();
    translate(playerX, playerY);
    scale(isFacingLeft ? -1 : 1, 1);  // Flip horizontally if facing left
    image(playerSprites[isMoving ? currentFrame : 2], 
          0, 0, 120, 120);  // Draw at 0,0 since we're using translate
    popMatrix();
  }
  
  popMatrix();
}

void handleMouseClick() {
  float leftBound = 300 - (590/2) + 30;
  float rightBound = 300 + (590/2) - 30;
  float topBound = height/2 - 70;  // This is where the wall line should be
  float bottomBound = height - 60;

  if (mouseX > leftBound && mouseX < rightBound &&
      mouseY > topBound && mouseY < bottomBound) {
    
    PVector target = canReachDirectly(mouseX, mouseY) ? 
      new PVector(mouseX, mouseY) : 
      findNearestValidPoint(mouseX, mouseY);
    
    target.x = constrain(target.x, leftBound, rightBound);
    target.y = constrain(target.y, topBound, bottomBound);
    
    targetX = target.x;
    targetY = target.y;
    isMoving = true;

    clickX = targetX;
    clickY = targetY;
    clickAlpha = 100;
    showClickEffect = true;
  }
}

void drawClickEffect() {
  if (!showClickEffect) return;
  
  noStroke();
  fill(128, 128, 128, clickAlpha);
  ellipse(clickX, clickY, 30, 30);
  clickAlpha = lerp(clickAlpha, 0, 0.1);
  
  if (clickAlpha < 1) {
    showClickEffect = false;
  }
}

boolean canReachDirectly(float x, float y) {
  float margin = 20;
  return !(x + margin > bedX - bedWidth/2 &&
           x - margin < bedX + bedWidth/2 &&
           y + margin > bedY - bedHeight/2 &&
           y - margin < bedY + bedHeight/2);
}

PVector findNearestValidPoint(float x, float y) {
  float maxRadius = 100;
  float step = 5;
  
  for (float r = 0; r <= maxRadius; r += step) {
    for (float theta = 0; theta < TWO_PI; theta += 0.3) {
      float testX = x + cos(theta) * r;
      float testY = y + sin(theta) * r;
      
      if (canReachDirectly(testX, testY)) {
        return new PVector(testX, testY);
      }
    }
  }
  
  return new PVector(playerX, playerY);
}
