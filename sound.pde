import processing.sound.*;

SoundFile titleMusic;
SoundFile gameMusic;
SoundFile level2Music;
SoundFile keySound;
SoundFile doorLockSound;
SoundFile doorOpenSound;  
SoundFile itemSound;  // Add this line
float musicVolume = 1.0;
boolean isFadingMusic = false;

void initializeSound() {
  titleMusic = new SoundFile(this, "The Bird.mp3");
  gameMusic = new SoundFile(this, "Day One.mp3");
  level2Music = new SoundFile(this, "Day Five.mp3");
  keySound = new SoundFile(this, "triangle.mp3");
  doorLockSound = new SoundFile(this, "doorlock.mp3");
  doorOpenSound = new SoundFile(this, "dooropen.wav");  
  itemSound = new SoundFile(this, "item.mp3");  
  
  titleMusic.loop();
  titleMusic.amp(1.0);
}

void updateMusic() {
  if (!isFadingMusic) return;
  
  if (gameState == TITLE) {
    titleMusic.amp(musicVolume);
    gameMusic.amp(1.0 - musicVolume);
  } else if (gameState == GAME) {
    gameMusic.amp(musicVolume);
    titleMusic.amp(1.0 - musicVolume);
  } else if (gameState == GAME_L2) {
    level2Music.amp(musicVolume);
    gameMusic.amp(1.0 - musicVolume);
  }
  
  if (musicVolume < 1.0) {
    musicVolume += 0.02;
  } else {
    musicVolume = 1.0;
    isFadingMusic = false;
    if (gameState == TITLE) {
      gameMusic.stop();
    } else if (gameState == GAME) {
      titleMusic.stop();
    } else if (gameState == GAME_L2) {
      gameMusic.stop();
    }
  }
}

void stopMusic() {
  titleMusic.stop();
  gameMusic.stop();
  level2Music.stop();  
}
