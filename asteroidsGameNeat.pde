Player humanPlayer; // the player which the user (you) controls
Population pop;
int speed = 100;
float globalMutationRate = 0.1;
PFont font;
int nextConnectionNo = 1000;

boolean showBest = true; // true if only show the best of the previous generation
boolean runBest = false; // true if replaying the best ever game
boolean humanPlaying = false; // true if the user is playing

boolean runThroughSpecies = false;
int upToSpecies = 0;
Player speciesChamp;

boolean showBrain = false;

boolean showBestEachGen = false;
int upToGen = 0;
Player genPlayerTemp;

//----------------------------------------------------------------------------------------------------------------------------------------
void setup() { // on startup
  size(1200, 675);

  humanPlayer = new Player();
  pop = new Population(300); // create new population
  frameRate(speed);
  font = loadFont("AgencyFB-Reg-48.vlw");
}

//------------------------------------------------------------------------------------------------------------------------------------------
void draw() {
  background(0); // deep space background

  if (showBrain) {
    background(255);
    if (runThroughSpecies) {
      if (speciesChamp != null) speciesChamp.brain.drawGenome();
    } else if (runBest) {
      if (pop.bestPlayer != null) pop.bestPlayer.brain.drawGenome();
    } else if (humanPlaying) {
      showBrain = false;
    } else {
      if (!pop.pop.isEmpty() && pop.pop.get(0) != null)
        pop.pop.get(0).brain.drawGenome();
    }
  } else if (showBestEachGen) {
    if (genPlayerTemp != null && !genPlayerTemp.dead) {
      genPlayerTemp.look();
      genPlayerTemp.think();
      genPlayerTemp.update();
      genPlayerTemp.show();
    } else {
      upToGen++;
      if (pop.genPlayers != null && upToGen < pop.genPlayers.size()) {
        genPlayerTemp = pop.genPlayers.get(upToGen).clone();
        println(genPlayerTemp.bestScore);
      } else {
        upToGen = 0;
        showBestEachGen = false;
      }
    }
  } else if (runThroughSpecies) {
    if (speciesChamp != null && !speciesChamp.dead) {
      speciesChamp.look();
      speciesChamp.think();
      speciesChamp.update();
      speciesChamp.show();
    } else {
      upToSpecies++;
      if (pop.species != null && upToSpecies < pop.species.size()) {
        speciesChamp = pop.species.get(upToSpecies).champ.cloneForReplay();
      } else {
        runThroughSpecies = false;
      }
    }
  } else if (humanPlaying) {
    if (!humanPlayer.dead) {
      humanPlayer.look();
      humanPlayer.update();
      humanPlayer.show();
      println(humanPlayer.vision[1]);
    } else {
      humanPlaying = false;
    }
  } else if (runBest) {
    if (pop.bestPlayer != null && !pop.bestPlayer.dead) {
      pop.bestPlayer.look();
      pop.bestPlayer.think();
      pop.bestPlayer.update();
      pop.bestPlayer.show();
    } else {
      runBest = false;
      if (pop.bestPlayer != null)
        pop.bestPlayer = pop.bestPlayer.cloneForReplay();
    }
  } else {
    if (!pop.done()) {
      pop.updateAlive();
    } else {
      pop.naturalSelection();
    }
  }

  showScore(); // display the score
}

//------------------------------------------------------------------------------------------------------------------------------------------
void keyPressed() {
  switch(key) {
    case ' ':
      if (humanPlaying) {
        humanPlayer.shoot();
      } else {
        showBest = !showBest;
      }
      break;
    case 'p':
      humanPlaying = !humanPlaying;
      humanPlayer = new Player();
      break;
    case '+':
      speed += 10;
      frameRate(speed);
      println(speed);
      break;
    case '-':
      if (speed > 10) {
        speed -= 10;
        frameRate(speed);
        println(speed);
      }
      break;
    case 'h':
      globalMutationRate /= 2;
      println(globalMutationRate);
      break;
    case 'd':
      globalMutationRate *= 2;
      println(globalMutationRate);
      break;
    case 'b':
      runBest = true;
      break;
    case 's':
      if (pop.species != null && !pop.species.isEmpty()) {
        runThroughSpecies = !runThroughSpecies;
        upToSpecies = 0;
        speciesChamp = pop.species.get(upToSpecies).champ.cloneForReplay();
      }
      break;
    case 'g':
      if (pop.genPlayers != null && !pop.genPlayers.isEmpty()) {
        showBestEachGen = !showBestEachGen;
        upToGen = 0;
        genPlayerTemp = pop.genPlayers.get(upToGen).clone();
      }
      break;
    case 'n':
      showBrain = !showBrain;
      break;
  }

  if (key == CODED) {
    if (keyCode == UP) {
      humanPlayer.boosting = true;
    }
    if (keyCode == LEFT) {
      humanPlayer.spin = -0.08;
    } else if (keyCode == RIGHT) {
      if (runThroughSpecies) {
        upToSpecies++;
        if (pop.species != null && upToSpecies < pop.species.size()) {
          speciesChamp = pop.species.get(upToSpecies).champ.cloneForReplay();
        } else {
          runThroughSpecies = false;
        }
      } else if (showBestEachGen) {
        upToGen++;
        if (pop.genPlayers != null && upToGen < pop.genPlayers.size()) {
          genPlayerTemp = pop.genPlayers.get(upToGen).cloneForReplay();
        } else {
          showBestEachGen = false;
        }
      } else {
        humanPlayer.spin = 0.08;
      }
    }
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------
void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) {
      humanPlayer.boosting = false;
    }
    if (keyCode == LEFT || keyCode == RIGHT) {
      humanPlayer.spin = 0;
    }
  }
}

//------------------------------------------------------------------------------------------------------------------------------------------
boolean isOut(PVector pos) {
  return (pos.x < -50 || pos.y < -50 || pos.x > width + 50 || pos.y > height + 50);
}

//------------------------------------------------------------------------------------------------------------------------------------------
void showScore() {
  textFont(font);
  fill(255);
  textAlign(LEFT);

  if (showBestEachGen && genPlayerTemp != null) {
    text("Score: " + genPlayerTemp.score, 80, 60);
    text("Gen: " + (upToGen + 1), width - 250, 60);
  } else if (runThroughSpecies && speciesChamp != null) {
    text("Score: " + speciesChamp.score, 80, 60);
    text("Species: " + (upToSpecies + 1), width - 250, 60);
  } else if (humanPlaying) {
    text("Score: " + humanPlayer.score, 80, 60);
  } else if (runBest && pop.bestPlayer != null) {
    text("Score: " + pop.bestPlayer.score, 80, 60);
    text("Gen: " + pop.gen, width - 200, 60);
  } else if (showBest && !pop.pop.isEmpty() && pop.pop.get(0) != null) {
    text("Score: " + pop.pop.get(0).score, 80, 60);
    text("Gen: " + pop.gen, width - 200, 60);
  }
}
