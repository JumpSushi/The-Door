PImage[] playerSprites = new PImage[6];
PImage girlImage;
PImage bedImage;
PImage bedEmptyImage;
PImage pillowCloseImage;
PImage duvetCloseImage;
PImage noPillowImage;
PImage keyImage;
PImage doorCloseImage; 

void loadImages() {
  // animation frames for the player walking (add credit later )
  for (int i = 0; i < 6; i++) {
    playerSprites[i] = loadImage(i + ".png");
  }

  girlImage = loadImage("girl.png");
  bedImage = loadImage("bed.png");
  pillowCloseImage = loadImage("pillowclose.png");
  duvetCloseImage = loadImage("duvetclose.png");
  noPillowImage = loadImage("nopillow.png");
  keyImage = loadImage("key.jpg");
  doorCloseImage = loadImage("doorcloseup.png");  
}

void initializeFont() {
  try {
    customFont = createFont("DJB COFFEE SHOPPE ESPRESSO.ttf", 32);
    textFont(customFont);
  } catch (Exception e) {
    println("Error loading font: " + e.getMessage());
    customFont = createFont("Arial", 32);
    textFont(customFont);
  }
}
