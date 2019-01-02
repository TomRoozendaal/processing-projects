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
ArrayList<PVector> path;

// starting position
int[] pos = {0, 0};
// nrof rows
int rows = 5;
// nrof columns
int cols = 5;
// print all the solutions, time consuming if enabled!
// nrof solutions 5x5: 552
// nrof solutions 6x6: 302282
// ..
boolean printAllSolutions = false;
// computation delay (to draw)
//int delay = 0;
int delay = int(1000/30);

// ------------ setup ------------
void setup() {
  size(400, 400);
  solCount = 0;
  curr = 1;
  grid = new int[rows][cols];
  path = new ArrayList<PVector>();
  grid[pos[0]][pos[1]] = curr;
  path.add(new PVector(pos[0], pos[1]));
  curr++;

  rowSp = height / rows;
  colSp = width / cols;
  colorMode(HSB);
  thread("next");
  println("finished, solutions: " + solCount);
}
void draw() {
  visualize();
}

// ------------ misc ------------
void visualize() {
  background(0);
  strokeWeight(2);
  stroke(180);
  fill(230);
  for (int i = 0; i < rows; i++ ) {
    for (int j = 0; j < cols; j++ ) {
      rect(j * colSp, i * rowSp, (j + 1) * colSp, (i + 1) * rowSp );
    }
  }
  noStroke();
  for (int k = 0; k < path.size(); k++) {
    PVector pos = path.get(k);
    int i = int(pos.x);
    int j = int(pos.y);
    int a = grid[i][j];
    float radius = min(colSp * 0.6, rowSp * 0.6);
    float hue = map(a, 1, rows*cols, 60, 150);
    float[] p = {(j + 0.5) * colSp, (i + 0.5) * rowSp};
    if ( k < path.size()-1) {
      PVector next = path.get(k + 1).copy();
      next.sub(pos).normalize().mult((radius/2) + 12);
      int x = int(next.y);
      int y = int(next.x);
      stroke(hue, 200, 200);
      arrow(int(p[0]), int(p[1]), int(p[0] + x), int(p[1] + y));
    }
    fill(hue, 0, 250);
    stroke(hue, 200, 200);
    strokeWeight(2);
    ellipse( p[0], p[1], radius, radius);   
    textAlign(CENTER, CENTER);
    fill(0, 0, 0);
    noStroke();
    textSize(12);
    text(a, p[0], p[1] - 2);
  }
  for (int i = 0; i < rows; i++ ) {
    for (int j = 0; j < cols; j++ ) {
      //println(grid[i][j]);
      if (grid[i][j] == 0) {
        float radius = min(colSp * 0.6, rowSp * 0.6);
        float[] p = {(j + 0.5) * colSp, (i + 0.5) * rowSp};
        fill(0, 0, 120);
        stroke(0, 0, 50);
        strokeWeight(2);
        ellipse( p[0], p[1], radius, radius);
      }
    }
  }
}

void arrow(int x1, int y1, int x2, int y2) {
  strokeWeight(2);
  line(x1, y1, x2, y2);
  pushMatrix();
  strokeWeight(2);
  translate(x2, y2);
  float a = atan2(x1-x2, y2-y1);
  rotate(a);
  line(0, 0, -5, -5);
  line(0, 0, 5, -5);
  popMatrix();
} 



void printGrid() {
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
void next() {
  if (curr > rows * cols) {
    solCount++;
    printGrid();
    if (!printAllSolutions || solCount == 1) {
      visualize();
      delay(1000);
      noLoop();
    }
  }
  ArrayList<int[]> opt = findOptions(pos[0], pos[1]);
  while (opt.size() > 0 && (solCount == 0 || printAllSolutions)) {
    delay(delay);
    for (int k = 0; k < opt.size(); k++ ) {
      int[] pre = pos;
      pos = opt.get(k);
      grid[pos[0]][pos[1]] = curr;
      path.add(new PVector(pos[0], pos[1]));
      curr++;
      // recurse
      next();
      // reset
      grid[pos[0]][pos[1]] = 0;
      path.remove(path.size() -1);
      pos = pre;
      curr--;
    }
    break;
  }
}

ArrayList<int[]> findOptions(int y, int x) {
  ArrayList<int[]> options = new ArrayList<int[]>();
  int[][] nextList = {{y-2, x-2}, {y-3, x}, {y-2, x+2}, {y, x+3}, {y+2, x+2}, {y+3, x}, {y+2, x-2}, {y, x-3}};
  for (int i = 0; i < nextList.length; i++) {
    if (nextList[i][0] >= 0 && nextList[i][0] < rows && nextList[i][1] >= 0 && nextList[i][1] < cols
      && grid[nextList[i][0]][nextList[i][1]] == 0) {
      options.add(nextList[i]);
    }
  }
  return options;
}
