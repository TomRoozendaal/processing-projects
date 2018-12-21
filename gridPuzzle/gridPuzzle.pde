/* Tom van Roozendaal
*  Grid Puzzle solver
*  date: 05/10/2018
*
*  This sketch solves a puzzle game using a brute-force, recursive Depth-First-search algorithm.
*
*  ~ The puzzle game to be solved goes as follows:
*  On an empty grid (of arbitrary size, usually 10x10), put a 1 on an arbitrary square. Starting from that square, 
*  you can move horizontally or vertically by jumping over two squares or move diagonally by jumping over one square.
*  There you will place the number 2. Your goal is to fill the entire grid by jumping from cell to cell.
*/

int grid[][];
int rowSp;
int colSp;
int curr;
int solCount;

// starting position
int[] pos = {0,0};
// nrof rows
int rows = 6;
// nrof columns
int cols = 6;
// print all the solutions, time consuming if enabled!
// nrof solutions 5x5: 552
// nrof solutions 6x6: 302282
// ..
boolean printAllSolutions = false;

// ------------ setup ------------
void setup(){
  size(400, 400);
  solCount = 0;
  curr = 1;
  grid = new int[rows][cols];
  grid[pos[0]][pos[1]] = curr;
  curr++;
  
  rowSp = height / rows;
  colSp = width / cols;
  colorMode(HSB);
  noLoop();
  next();
  println("finished, solutions: " + solCount);
}

// ------------ misc ------------
void visualize(){
  background(0);
  strokeWeight(1);
  stroke(180);
  fill(255);
  for (int i = 0; i < rows; i++ ){
    for (int j = 0; j < cols; j++ ){
       rect(j * colSp, i * rowSp, (j + 1) * colSp, (i + 1) * rowSp );
    }
  }
  noStroke();
  for (int i = 0; i < rows; i++ ){
    for (int j = 0; j < cols; j++ ){
      //println(grid[i][j]);
      int a = grid[i][j];
      if (a != 0){
        float radius;
        if(colSp < rowSp){
          radius = colSp * 0.6;
        } else { 
          radius = rowSp * 0.6;
        }
        float hue = map(a, 1, rows*cols, 60, 150);
        float[] p = {(j + 0.5) * colSp, (i + 0.5) * rowSp};
        fill(hue, 0, 220);
        stroke(hue, 200, 200);
        strokeWeight(2);
        ellipse( p[0], p[1], radius, radius);   
        textAlign(CENTER, CENTER);
        fill(0, 0, 0);
        noStroke();
        textSize(12);
        text(a, p[0], p[1] - 2);
        
      }
    }
  }
}

void printGrid(){
  for (int x = 0; x < grid[0].length; x++) {
    print("+---------\t");
  }
  println("+");
  for (int y = 0; y < grid.length; y++) {
    if (y % rows == 0 && y != 0) {
      println("-------------------------");   
    }
    for (int x = 0; x < grid[0].length; x++) {
      if (x % cols == 0) {
        print("| ");   
      }
      if (grid[y][x] != 0) {
        print(grid[y][x] + "\t");
      } else {
        print("\t");
      }
    }
    println("|");
  }
  for (int x = 0; x < grid[0].length; x++) {
    print("+---------\t");
  }
  println("+");
  println();
}

// ------------ calculations ------------
void next(){
  if (curr > rows * cols){
    solCount++;
    printGrid();
    if (!printAllSolutions || solCount == 1){
      visualize();
    }
  }
  ArrayList<int[]> opt = findOptions(pos[0], pos[1]);
  while (opt.size() > 0 && (solCount == 0 || printAllSolutions)){
    for (int k = 0; k < opt.size(); k++ ){
      int[] pre = pos;
      pos = opt.get(k);
      grid[pos[0]][pos[1]] = curr;
      curr++;
      // recurse
      next();
      // reset
      grid[pos[0]][pos[1]] = 0;
      pos = pre;
      curr--;
    }
    break;
  }
}

ArrayList<int[]> findOptions(int y, int x){
   ArrayList<int[]> options = new ArrayList<int[]>();
   int[][] nextList = {{y-2, x-2},{y-3, x},{y-2, x+2},{y, x+3},{y+2, x+2},{y+3, x},{y+2, x-2},{y, x-3}};
   for (int i = 0; i < nextList.length; i++){
      if (nextList[i][0] >= 0 && nextList[i][0] < rows && nextList[i][1] >= 0 && nextList[i][1] < cols
      && grid[nextList[i][0]][nextList[i][1]] == 0){
        options.add(nextList[i]);
      }
   }
   return options;
}
