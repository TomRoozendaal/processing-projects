/* Tom van Roozendaal
*  A 1D Cellular Automata generator
*  date: 08/09/2018
*
*  Use A/D to change the automata rule
*  You can turn on/off randomization options with W(top)/S(sides)
*  E/space to refresh the grid using the current randomization setting
*  Q add another step
*
*  ------------------------------------------------------------
*  ~ How it works:
*  Every row in the grid represents a generation of cells. The next generation is determined by the current generation and a set of rules.
*  These rules are often referred to by a number for which its binary representation determines the state of the next generation from its neighbours.
*  more information: http://mathworld.wolfram.com/ElementaryCellularAutomaton.html
*/

// amount of steps horizontally
int stepsX = 301;
// amount of steps vertically
int stepsY = 200;         
boolean randomizeTop = true;
boolean randomizeSides = true;
boolean animate = true;
boolean GUI = true;

color c1 = color(25); // ON cell color
color c2 = color(220); // OFF cell color

int rule = 120; // = int(random(255));
// rule should be in range of [0, 255] (rule < 2^8)
// some fun ones: 18, 30, 45, 57, 90, 105, 120, 135, 150, 167, 195 ..

boolean[][] grid;
boolean[] previous;

void setup() {
  grid = new boolean[stepsX][stepsY];
  previous = new boolean[3];
  //fullScreen();
  size(602, 400);
  frameRate(60);

  for (int x = 0; x < grid.length; x++) {
    if (randomizeTop) {
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
    for (int x = 0; x < grid.length; x++) {
      if (grid[x][y]) {
        fill(c1);
      } else {
        fill(c2);
      }
      rect(x * width/grid.length, y * height/grid[0].length, ceil((float)width/grid.length), ceil((float)height/grid[0].length));
    }
  }
  
  if(GUI){
    drawGUI();
  }
  if (animate){
    nextStep();
  }
}

void drawGUI(){
  fill(255);
  stroke(150);
  rect(-1, -1, 65, 20, 0, 0, 8, 0);

  fill(255, 0, 0);
  textAlign(LEFT, TOP);
  text(rule, 4, 2);
  if (!randomizeTop){
    fill(150);
  } else {
    fill (255, 0, 0);
  }
  text("T", 36, 2);
  if (!randomizeSides){
    fill(150);
  } else {
    fill (255, 0, 0);
  }
  text("S", 48, 2);
}

// -------------------- OTHER METHODS --------------------

boolean randomBool() {
  return random(1) > .5;
}
void mousePressed(){
  animate = !animate;
}

void keyPressed(){
  if (key == 's'){        // toggle randomization of the outer columns (walls)
    randomizeSides = !randomizeSides;
    setup();
  } else if (key == 'w'){ // toggle randomization of the top row (roof)
    randomizeTop = !randomizeTop;
    setup();
  } else if (key == 'a'){ //  decrease rule count
    rule--;
    setup();
  } else if (key == 'd'){ // increase rule count
    rule++;
    setup();
  } else if (key == ' '){ // toggle animation
    animate = !animate;
  } else if (key == 'q'){ // next step
    animate = false;
    nextStep();
  } else if (key == 'e'){ // reset
    setup();     
  } else if (key == 'g'){ // reset
    GUI = !GUI;     
  }
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
    if (x != 0) {
      previous[0] = grid[x-1][y-1];
    } else if (!randomizeSides){
      previous[0] = false;
    } else {
      previous[0] = randomBool();
    }                                // LEFT
    previous[1] = grid[x][y-1];      // CENTER
    if (x != grid.length - 1) {
      previous[2] = grid[x+1][y-1];
    } else if (!randomizeSides){
      previous[2] = false;
    } else {
      previous[2] = randomBool();
    }                                // RIGHT

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
