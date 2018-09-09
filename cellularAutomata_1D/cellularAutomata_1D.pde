/* Tom van Roozendaal
*  A 1D Cellular Automata generator
*  date: 08/09/2018
*
*  ~ How it works:
*  Every row in the grid represents a generation of cells. The next generation is determined by the current generation and a set of rules.
*  These rules are often referred to by a number for which its binary representation determines the state of the next generation from its neighbours.
*  more information: http://mathworld.wolfram.com/ElementaryCellularAutomaton.html
*
*  ------------------------------------------------------------
*
*  ~ Hotkeys:
*  A/D to change the automata rule count
*  W to toggle randomization
*  R to reset the grid using the current randomization setting
*  Q add another step
*  S to save the current frame
*  SPACE to toggle the animation
*/

// amount of steps horizontally
int stepsX = 80;
// amount of steps vertically
int stepsY = 40;
boolean randomize = true;
boolean animate = false;
boolean GUI = true;

color c1 = color(0); // ON cell color
color c2 = color(255); // OFF cell color
boolean gridStroke = true;
color c3 = lerpColor(c1, c2, 0.5); 
color c4 = (c3 & 0xffffff) | (150 << 24); // Stroke color
int imgCount = 1;

int rule = int(random(255)); // = int(random(255));
String ruleStr;
// rule should be in range of [0, 255] (rule < 2^8)
// some fun ones: 18, 30, 45, 57, 90, 105, 120, 135, 154, 167, 195 ..

boolean[][] grid;
boolean[] previous;

void setup() {
  grid = new boolean[stepsX * 2][stepsY];
  previous = new boolean[3];
  //fullScreen();
  size(800, 420); // height is with extra spacing for the GUI
  frameRate(30);

  for (int x = 0; x < grid.length; x++) {
    if (randomize) {
      grid[x][0] = randomBool();
    } else if (x != floor(grid.length/2)) {
      grid[x][0] = false;
    } else {
      grid[x][0] = true;
    }
  }

  for (int y = 1; y < grid[0].length; y++) {
    calcGeneration(y);
  }
}

void draw() {
  background(0);
  noStroke();
  for (int y = 0; y < grid[0].length; y++) {
    for (int x = 0; x < 0.5*grid.length; x++) {
      if (grid[x + grid.length/4][y]) {
        fill(c1);
      } else {
        fill(c2);
      }
      if (gridStroke){
        stroke(c4);
      }
      
      int rows = grid[0].length;
      int cols = grid.length/2;
      int W = width;
      int H = height - 20;
      rect(x * W/cols, y * H/rows, ceil((float)W/cols), ceil((float)H/rows)); 
    }
  }

  drawGUI();
  if (animate){
    nextStep();
  }
}

void drawGUI(){
  fill(255);
  stroke(150);
  rect(0, height - 20, width, 20, 0, 0, 0, 0);

  fill(255, 0, 0);
  textAlign(LEFT, CENTER);
  text(ruleStr, 8, height - 11);
  
  textAlign(LEFT, CENTER);
  if (!randomize){
    fill (150);
    text("Random OFF", 40, height - 11);
  } else {
    fill (0, 180, 0);
    text("Random ON", 40, height - 11);
  }
  
}

// -------------------- OTHER METHODS --------------------

boolean randomBool() {
  return random(1) > .5;
}
void mouseClicked(){
  if (mouseY > height-20){
     randomize = !randomize;
     setup();
  } else {
     animate = !animate;
  }
}

void keyPressed(){
  if (key == 'w' || key == 'W'){        // toggle randomization of the outer columns (walls)
    randomize = !randomize;
    animate = false;
    setup();
  } else if (key == 'a' || key == 'A'){ //  decrease rule count
    rule--;
    animate = false;
    setup();
  } else if (key == 'd' || key == 'D'){ // increase rule count
    rule++;
    animate = false;
    setup();
  } else if (key == ' '){ // toggle animation
    animate = !animate;
  } else if (key == 'q' || key == 'Q'){ // next step
    animate = false;
    nextStep();
  } else if (key == 'r' || key == 'R'){ // reset
    animate = false;
    setup();
  } else if (key == 's' || key == 'S'){
    saveFrame(); 
  } else if (key == 'g' || key == 'G'){
    gridStroke = !gridStroke; 
  }
}

void saveFrame() {
  String imgStr = String.format("%03d", imgCount);
  PImage partialSave = get(0,0,width,height-20);
  partialSave.save("/frames/"+(imgStr + "_rule" + ruleStr+".png"));
  println(imgStr + "_rule" + ruleStr+".png saved");
  imgCount++;
}

void nextStep(){
  for (int y = 0; y < grid[0].length - 1; y++){
    for (int x = 0; x < grid.length; x++) {
      grid[x][y] = grid[x][y + 1];
    }
  }
  calcGeneration(grid[0].length - 1);
}


void calcGeneration(int y){
  for (int x = 0; x < grid.length; x++) {

    // accomodate for the boundaries with if statements
    if (x != 0) {                    // LEFT
      previous[0] = grid[x-1][y-1];
    } else if (!randomize){
      previous[0] = false;
    } else {
      previous[0] = randomBool();
    }                                //
    previous[1] = grid[x][y-1];      // CENTER
    if (x != grid.length - 1) {      // RIGHT
      previous[2] = grid[x+1][y-1];
    } else if (!randomize){
      previous[2] = false;
    } else {
      previous[2] = randomBool();
    }                                //

    grid[x][y] = calcRule(previous[0], previous[1], previous[2]);
  }
}

// Method to setup the cellular automata rule using the 8 possible cases
boolean calcRule(boolean l, boolean c, boolean r){
  if (rule < 0 ){
    println(rule + " is not a valid rule input. Rule must be within [0, 255]");
    print(rule + " is being converted to ");
    while (rule < 0){
      rule = rule + 256;
    }
    println( rule );
  } else if (rule > 255 ){
    println(rule + " is not a valid rule input. Rule must be within [0, 255]");
    println(rule + " is being converted to " + rule % 256);
    rule = rule % 256;
  }
  ruleStr = String.format("%03d", rule);
  String binaryNum = binary(rule % 256, 8);
  return (binaryNum.charAt(0) == '1' && l && c && r ||
          binaryNum.charAt(1) == '1' && l && c && !r ||
          binaryNum.charAt(2) == '1' && l && !c && r ||
          binaryNum.charAt(3) == '1' && l && !c && !r ||
          binaryNum.charAt(4) == '1' && !l && c && r ||
          binaryNum.charAt(5) == '1' && !l && c &&! r ||
          binaryNum.charAt(6) == '1' && !l && !c && r ||
          binaryNum.charAt(7) == '1' && !l && !c && !r );
}
