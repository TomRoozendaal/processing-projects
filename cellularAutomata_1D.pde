/* Tom van Roozendaal
*  A 1D Cellular Automata generator
*  date: 08/09/2018
*
*  Use A/D to change the automata rule
*  You can turn on/off randomization options with W(top)/S(sides)
*  Q/space to refresh with the current settings
*
*  ------------------------------------------------------------
*  ~ How it works:
*  Every row in the grid represents a generation of cells. The next generation is determined by the current generation and a set of rules. 
*  These rules are often referred to by a number for which its binary representation determines the state of the next generation from its neighbours.
*  more information: http://mathworld.wolfram.com/ElementaryCellularAutomaton.html
*/

int stepsX = 200;
int stepsY = 100;
boolean randomizeTop = true;
boolean randomizeSides = true;

int rule = 120;
// some fun rule options: 18, 30, 45, 57, 90, 105, 120, 135, 150, 167 ..

boolean[][] grid;
boolean[] previous;

void setup() {
  grid = new boolean[stepsX][stepsY];
  previous = new boolean[3];
  size(400, 200);
  frameRate(30);

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
    for (int x = 0; x < grid.length; x++) {

      // accomodate for the boundaries with if statements
      if (x != 0) { 
        previous[0] = grid[x-1][y-1];
      } else if (!randomizeSides){
        previous[0] = false;
      } else {
        previous[0] = randomBool();
      }  // LEFT
      previous[1] = grid[x][y-1]; // CENTER
      if (x != grid.length - 1) { 
        previous[2] = grid[x+1][y-1];
      } else if (!randomizeSides){
        previous[2] = false;
      } else {
        previous[2] = randomBool();
      }  // RIGHT

      grid[x][y] = calcRule(previous[0], previous[1], previous[2]);
    }
  }
}

void draw() {
  background(0);
  noStroke();
  for (int y = 0; y < grid[0].length; y++) {
    for (int x = 0; x < grid.length; x++) {
      if (grid[x][y]) {
        fill(0);
      } else {
        fill(255);
      }
      rect(x * width/grid.length, y * height/grid[0].length, width/grid.length, height/grid[0].length);
    }
  }
  
  fill(255);
  rect(0, 0, 64, 19);
  
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

boolean randomBool() {
  return random(1) > .5;
}

void keyPressed(){
  if (key == 's'){
    randomizeSides = !randomizeSides;
    setup();
  } else if (key == 'w'){
    randomizeTop = !randomizeTop;
    setup();
  } else if (key == 'a'){
    rule--;
    setup();
  } else if (key == 'd'){
    rule++;
    setup();
  } else if (key == ' ' || key == 'q'){
    setup();
  }
}

// Here's a function to setup own cellular automata rule
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
