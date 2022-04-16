final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2;
int gameState = 0;

final int GRASS_HEIGHT = 15;
final int START_BUTTON_W = 144;
final int START_BUTTON_H = 60;
final int START_BUTTON_X = 248;
final int START_BUTTON_Y = 360;

PImage title, gameover, startNormal, startHovered, restartNormal, restartHovered;
PImage bg, soil8x24;
PImage lifeImg;
PImage[] soilImg;
PImage stoneImg1,stoneImg2;

int[][] soilHealth;

PImage groundhogIdleImg,groundhogDownImg,groundhogLeftImg,groundhogRightImg;
PImage cabbageImg;
PImage soldierImg;
PVector soldierPosition,cabbagePosition,groundhogPosition;
final int HOG_IDLE = 0;
final int HOG_LEFT = 1;
final int HOG_RIGHT = 2;
final int HOG_DOWN = 3;
int soldierLayer,robotLayer;
int groundhogState = HOG_IDLE;
boolean movingDetection;
int movingFrame = 15;

// For debug function; DO NOT edit or remove this!
int playerHealth = 2;
float cameraOffsetY = 0;
boolean debugMode = true;

void setup() {
	size(640, 480, P2D);
	// Enter your setup code here (please put loadImage() here or your game will lag like crazy)
	bg = loadImage("img/bg.jpg");
	title = loadImage("img/title.jpg");
	gameover = loadImage("img/gameover.jpg");
	startNormal = loadImage("img/startNormal.png");
	startHovered = loadImage("img/startHovered.png");
	restartNormal = loadImage("img/restartNormal.png");
	restartHovered = loadImage("img/restartHovered.png");
	soil8x24 = loadImage("img/soil8x24.png");
  lifeImg = loadImage("img/life.png");
  soilImg = new PImage[6];
  soilImg[0] = loadImage("img/soil0.png");
  soilImg[1] = loadImage("img/soil1.png");
  soilImg[2] = loadImage("img/soil2.png");
  soilImg[3] = loadImage("img/soil3.png");
  soilImg[4] = loadImage("img/soil4.png");
  soilImg[5] = loadImage("img/soil5.png");
  stoneImg1 = loadImage("img/stone1.png");
  stoneImg2 = loadImage("img/stone2.png");
  groundhogIdleImg = loadImage("img/groundhogIdle.png");
  groundhogDownImg = loadImage("img/groundhogDown.png");
  groundhogLeftImg = loadImage("img/groundhogLeft.png");
  groundhogRightImg = loadImage("img/groundhogRight.png");
  cabbageImg = loadImage("img/cabbage.png");
  soldierImg = loadImage("img/soldier.png");
  // soil health
  soilHealth = new int[8][24];
  for(int i=0;i<8;i++){
    for(int o=0;o<24;o++){
      if(o<8 && i==o){ // rock 1-8
        soilHealth[i][o] = 30;
      }else if(o>7 && o<16){ // rock 9-16
        if(o==8||o==11||o==12||o==15){
          if(i==1||i==2||i==5||i==6){
            soilHealth[i][o] = 30;
          }
        }else{
          if(i==0||i==3||i==4||i==7){
            soilHealth[i][o] = 30;
          }
        }
      }else if(o>15 && o<24){ // rock 17-24
        if((i+o) % 3 == 0){
          soilHealth[i][o] = 45;
        }
        if((i+o) % 3 == 2){
          soilHealth[i][o] = 30;
        }
      }else{
        soilHealth[i][o] = 15;
      }
    }
  }
  // groundhog position
  groundhogPosition = new PVector(320,80);
  
  // cabbage position
  int cabbageIndexX = int(random(0,8));
  int cabbageIndexY = int(random(0,4));
  cabbagePosition = new PVector(cabbageIndexX * 80 , 160 + cabbageIndexY * 80);
  
  // soldier layer and position
  soldierLayer = int(random(0,4));
  soldierPosition = new PVector(random(width),160+soldierLayer*80);
}

void draw() {
    /* ------ Debug Function ------ 
      Please DO NOT edit the code here.
      It's for reviewing other requirements when you fail to complete the camera moving requirement.
    */
    if (debugMode) {
      pushMatrix();
      translate(0, cameraOffsetY);
    }
    /* ------ End of Debug Function ------ */

    
	switch (gameState) {

		case GAME_START: // Start Screen
  		image(title, 0, 0);
  
  		if(START_BUTTON_X + START_BUTTON_W > mouseX
  	    && START_BUTTON_X < mouseX
  	    && START_BUTTON_Y + START_BUTTON_H > mouseY
  	    && START_BUTTON_Y < mouseY) {
  
  			image(startHovered, START_BUTTON_X, START_BUTTON_Y);
  			if(mousePressed){
  				gameState = GAME_RUN;
  				mousePressed = false;
  			}
  		}else{
  			image(startNormal, START_BUTTON_X, START_BUTTON_Y);
  		}
  		break;

		case GAME_RUN: // In-Game

  		// Background
  		image(bg, 0, 0);
  
  		// Sun
  	  stroke(255,255,0);
  	  strokeWeight(5);
      fill(253,184,19);
  	  ellipse(590,50,120,120);
      //screen move
      pushMatrix();
        if(groundhogPosition.y<=1680){
          translate(0,groundhogPosition.y*-1+80);
        }else{
          translate(0,-1600);
        }
        // Grass
        fill(124, 204, 25);
        noStroke();
        rect(0, 160 - GRASS_HEIGHT, width, GRASS_HEIGHT);
        // Soil
        for(int i=0;i<8;i++){
          for(int o=0;o<24;o++){
            // soil image
            int soildepth = floor(o/4);
            image(soilImg[soildepth],i * 80,160 + o*80);
            if(soilHealth[i][o] >= 30){
              image(stoneImg1,i * 80,160 + o*80);
            }
            if(soilHealth[i][o] >= 45){
              image(stoneImg2,i * 80,160 + o*80);
            }
          }
        }
    		// Player
        // groundhog moving detection
        if(movingFrame==15){
          movingDetection = false;
          groundhogState = HOG_IDLE;
        }else{
          movingDetection = true;
        }
        // groundhog move
        if(movingFrame < 15){
          switch(groundhogState){
            case HOG_LEFT:
              movingFrame += 1;
              groundhogPosition.x-=80.0/15.0;
              break;
            case HOG_DOWN:
              movingFrame += 1;
              groundhogPosition.y+=80.0/15.0;
              break;
            case HOG_RIGHT:
              movingFrame += 1;
              groundhogPosition.x+=80.0/15.0;
              break;
          }
          // position fix
          if(movingFrame == 15){
            groundhogPosition.x = round(groundhogPosition.x);
            groundhogPosition.y = round(groundhogPosition.y);
          }
        }
        // groundhog show
        switch(groundhogState){
          case HOG_IDLE:
            image(groundhogIdleImg,groundhogPosition.x,groundhogPosition.y);
            break;
          case HOG_LEFT:
            image(groundhogLeftImg,groundhogPosition.x,groundhogPosition.y);
            break;
          case HOG_RIGHT:
            image(groundhogRightImg,groundhogPosition.x,groundhogPosition.y);
            break;
          case HOG_DOWN:
            image(groundhogDownImg,groundhogPosition.x,groundhogPosition.y);
            break;
        }
        // soldier&groundhog collide detection
        if(groundhogPosition.x < soldierPosition.x+80 &&
           groundhogPosition.x + 80 > soldierPosition.x &&
           groundhogPosition.y < soldierPosition.y + 80 &&
           groundhogPosition.y + 80 > soldierPosition.y){
          groundhogPosition = new PVector(80*5,80);
          movingFrame = 15;
          playerHealth --;
        }
        // soldier
        soldierPosition.x += 4;
        if(soldierPosition.x >= width){
          soldierPosition.x = -80;
        }
        image(soldierImg,soldierPosition.x,soldierPosition.y);
        // cabbage&groundhog collide detection
        if(groundhogPosition.x < cabbagePosition.x+80 &&
           groundhogPosition.x + 80 > cabbagePosition.x &&
           groundhogPosition.y < cabbagePosition.y + 80 &&
           groundhogPosition.y + 80 > cabbagePosition.y){
          cabbagePosition = new PVector(-80,-80);
          playerHealth ++;
        }
        // cabbage
        image(cabbageImg,cabbagePosition.x,cabbagePosition.y);
      popMatrix();
  
  		// Health UI
      if(playerHealth>5){
        playerHealth = 5;
      }
      for(int i=0;i<playerHealth;i++){
        image(lifeImg,10 + i*70,10); 
      }
      if(playerHealth == 0){
        gameState = GAME_OVER;
        break;
      }
      
  		break;

		case GAME_OVER: // Gameover Screen
		image(gameover, 0, 0);
		
		if(START_BUTTON_X + START_BUTTON_W > mouseX
	    && START_BUTTON_X < mouseX
	    && START_BUTTON_Y + START_BUTTON_H > mouseY
	    && START_BUTTON_Y < mouseY) {

			image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;
				// Remember to initialize the game here!
        playerHealth = 2;
        // soldier layer and position
        soldierLayer = int(random(0,4));
        soldierPosition = new PVector(random(width),160+soldierLayer*80);
        // groundhog position
        groundhogPosition = new PVector(80*5,80);
        // cabbage position
        int cabbageIndexX = int(random(0,8));
        int cabbageIndexY = int(random(0,4));
        cabbagePosition = new PVector(cabbageIndexX * 80 , 160 + cabbageIndexY * 80);
			}
		}else{
			image(restartNormal, START_BUTTON_X, START_BUTTON_Y);
		}
		break;
	}

    // DO NOT REMOVE OR EDIT THE FOLLOWING 3 LINES
    if (debugMode) {
        popMatrix();
    }
}

void keyPressed(){
	// Add your moving input code here
  if(gameState == GAME_RUN){
    switch(keyCode){
      case LEFT:
        if(!movingDetection && groundhogPosition.x>0){
          movingFrame = 0;
          groundhogState = HOG_LEFT;
        }
        break;
      case RIGHT:
        if(!movingDetection && groundhogPosition.x<width-80){
          movingFrame = 0;
          groundhogState = HOG_RIGHT;
        }
        break;
      case DOWN:
        if(!movingDetection && groundhogPosition.y<2000){
          movingFrame = 0;
          groundhogState = HOG_DOWN;
        }
        break;
    }
  }
	// DO NOT REMOVE OR EDIT THE FOLLOWING SWITCH/CASES
    switch(key){
      case 'w':
      debugMode = true;
      cameraOffsetY += 25;
      break;

      case 's':
      debugMode = true;
      cameraOffsetY -= 25;
      break;

      case 'a':
      if(playerHealth > 0) playerHealth --;
      break;

      case 'd':
      if(playerHealth < 5) playerHealth ++;
      break;
    }
}

void keyReleased(){
}
