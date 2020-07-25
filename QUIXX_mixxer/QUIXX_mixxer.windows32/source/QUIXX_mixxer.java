import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Collections; 
import java.util.Arrays; 
import java.util.List; 
import java.util.LinkedList; 
import java.util.Random; 
import java.util.Map; 
import java.util.Date; 
import java.text.SimpleDateFormat; 
import java.util.Calendar; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class QUIXX_mixxer extends PApplet {

/* Tom van Roozendaal
 *  Qwixx scoreblok generator
 *  date: 23/12/2019
 */











// Default Qwixx grid
Cell[][] grid = new Cell[4][11];

final int rows = grid.length;
final int cols = grid[0].length;
final int padding = 10;
int[] colors = {
  0xffD91812, 
  0xffFCC900, 
  0xff309800, 
  0xff326698
};
int[] darkColors = {
  0xff8A0001, 
  0xff92680E, 
  0xff015C02, 
  0xff053264
};
int[] lightColors = {
  0xffFED0D0, 
  0xffFFFECE, 
  0xffF0FDF2, 
  0xffE0E1FE
};

int barH = 40;
int barMargin = 8; 
HashMap<String, Boolean> bools = new HashMap<String, Boolean>();
String pre = "Default";

// ------------ setup and draw ------------

public void setup() {
  bools.put("reset", false);
  bools.put("mixx", false);
  bools.put("shuffle", false);
  bools.put("save", false);
  bools.put("play", false);

  resetGrid();
  
  PFont font = createFont("Roobert Bold", 20);
  textFont(font);
  textAlign(CENTER, CENTER);
  //shuffleValues();
  generateMixx(false, false);
}

public void draw() {
  background(230);
  int cellSize = 36;
  int rowHeight = 50;
  int lockSpacing = 12;
  int cellRadius = 6;
  int lockSize = 28;
  int borderWeigth = 2;
  int textVOffset = -3;
  int vSpacing = 3;

  int left = (width - (11 * cellSize) - lockSize - lockSpacing)/2;
  int right = (width - (11 * cellSize) - lockSize - lockSpacing)/2 + lockSize + lockSpacing;

  // background
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      Cell cell = grid[i][j];
      // Outer colors
      fill(colors[cell.col]);
      noStroke();
      if (j == 0) {
        rect((j * cellSize), (i * (rowHeight + vSpacing))+ vSpacing, left + cellSize, rowHeight);
      } else if (j == cols - 1) {
        rect(left + (j * cellSize), (i * (rowHeight + vSpacing))+ vSpacing, cellSize + right, rowHeight);
      } else { 
        rect(left + (j * cellSize), (i * (rowHeight + vSpacing))+ vSpacing, cellSize, rowHeight);
      }
      // Dark border left half
      fill(darkColors[cell.col]);
      if (j != 0 && grid[i][j].col == grid[i][j-1].col) {
        rect(left - borderWeigth + (j * cellSize), ((rowHeight-cellSize)/2) - borderWeigth + (i * (rowHeight + vSpacing))+ vSpacing, 
          cellSize/2 + borderWeigth, cellSize + 2*borderWeigth);
      } else {
        rect(left - borderWeigth + (j * cellSize), ((rowHeight-cellSize)/2) - borderWeigth + (i * (rowHeight + vSpacing))+ vSpacing, 
          cellSize/2 + borderWeigth, cellSize + 2*borderWeigth, cellRadius + 2, 0, 0, cellRadius + 2);
      }
      // Dark border right half
      fill(darkColors[cell.col]);
      if (j != cols - 1 && grid[i][j].col == grid[i][j+1].col) {
        rect(left + (j * cellSize) + cellSize/2, ((rowHeight-cellSize)/2) - borderWeigth + (i * (rowHeight + vSpacing))+ vSpacing, 
          cellSize/2 + borderWeigth, cellSize + 2*borderWeigth);
      } else {
        rect(left + (j * cellSize) + cellSize/2, ((rowHeight-cellSize)/2) - borderWeigth + (i * (rowHeight + vSpacing))+ vSpacing, 
          cellSize/2 + borderWeigth, cellSize + 2*borderWeigth, 0, cellRadius + 2, cellRadius + 2, 0);
      }
    }

    // Locks backgrounds
    Cell cell = grid[i][10];
    fill(darkColors[cell.col]);
    rect(left + (11 * cellSize), (i * (rowHeight + vSpacing))+ vSpacing + rowHeight/2 - 3, 
      lockSpacing, 6);
    rect(left + (11 * cellSize) + lockSpacing - borderWeigth, ((rowHeight-lockSize)/2) - borderWeigth + (i * (rowHeight + vSpacing))+ vSpacing, 
      lockSize + 2*borderWeigth, lockSize + 2*borderWeigth, 2*lockSize);
  }

  // White areas with text
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      Cell cell = grid[i][j];
      fill(lightColors[cell.col]);
      rect(left + (j * cellSize), ((rowHeight-cellSize)/2) + (i * (rowHeight + vSpacing))+ vSpacing, 
        cellSize, cellSize, cellRadius);
      fill(colors[cell.col]);
      textSize(20);
      text(cell.value, 
        left + (cellSize/2) + (j * cellSize), (rowHeight/2) + (i * (rowHeight + vSpacing))+ vSpacing + textVOffset);
    }
    // Lock
    Cell cell = grid[i][10];
    fill(lightColors[cell.col]);
    rect(left + (11 * cellSize) + lockSpacing, ((rowHeight-lockSize)/2) + (i * (rowHeight + vSpacing))+ vSpacing, 
      lockSize, lockSize, 2*lockSize);
  }

  drawButtons();
}

public void drawButtons() {
  pushMatrix();
  translate(0, height-barH);
  fill(250);
  rect(0, 0, width, barH);

  // ----
  translate(barMargin, barMargin);
  fill(colors[0]);
  noStroke();
  rect(0, 0, 80, barH-2*barMargin, 8);
  fill(lightColors[0]);
  textSize(14);
  text("RESET", 40, barH/2 - barMargin - 2);
  // ----
  translate(80 + barMargin, 0);
  fill(colors[2]);
  noStroke();
  rect(0, 0, 80, barH-2*barMargin, 8);
  fill(lightColors[2]);
  textSize(14);
  text("SHUFFLE", 40, barH/2 - barMargin - 2);
  // ----
  translate(80 + barMargin, 0);
  fill(colors[3]);
  noStroke();
  rect(0, 0, 80, barH-2*barMargin, 8);
  fill(lightColors[3]);
  textSize(14);
  text("MIXX", 40, barH/2 - barMargin - 2);
  // ----
  translate(80 + barMargin, 0);
  fill(colors[3]);
  noStroke();
  rect(0, 0, 68, barH-2*barMargin, 8, 0, 0, 8);
  fill(colors[2]);
  rect(68, 0, 92, barH-2*barMargin, 0, 8, 8, 0);
  fill(255);
  textSize(14);
  text("MIXX and SHUFFLE", 80, barH/2 - barMargin - 2);
  
  popMatrix();
  // ----
  pushMatrix();
  translate(0, height-barH + barMargin);
  if (bools.get("save")){
    fill(200);
    noStroke();
    rect(width - 80 - barMargin*2, 0, 80, barH-2*barMargin, 8);
    fill(240);
    textSize(14);
    text("SAVE", width - 40 - barMargin*2, barH/2 - barMargin - 2);
  } else {
    fill(colors[1]);
    noStroke();
    rect(width - 80 - barMargin*2, 0, 80, barH-2*barMargin, 8);
    fill(lightColors[1]);
    textSize(14);
    text("SAVE", width - 40 - barMargin*2, barH/2 - barMargin - 2);
  }
  popMatrix();
}

public void mousePressed() {
  if (mouseY > height - barH + barMargin && mouseY < height-barMargin ) {
    if (mouseX > barMargin && mouseX < barMargin + 80) {
      resetGrid();
      bools.put("save", false);
      pre = "Default";
    } else if (mouseX > 2*barMargin + 80 && mouseX < 2*barMargin + 160) {
      resetGrid();
      shuffleValues();
      bools.put("save", false);
      pre = "Shuffle";
    } else if (mouseX > 3*barMargin + 160 && mouseX < 3*barMargin + 240) {
      resetGrid();
      generateMixx(true, false);
      bools.put("save", false);
      pre = "Mixx";
    } else if (mouseX > 4*barMargin + 240 && mouseX < 4*barMargin + 400) {
      resetGrid();
      shuffleValues();
      generateMixx(true, true);
      bools.put("save", false);
      pre = "Mixx_Shuffle";
    } else if (mouseX > width - 80 - barMargin*2 && mouseX < width - barMargin*2 && !bools.get("save")) {
      saveFrame();
      bools.put("save", true);
    }
  }
}

public void saveFrame() {
  SimpleDateFormat sdfDate = new SimpleDateFormat("dd_MM_YYYY-HH_mm_ss"); //"yyyy-MM-dd HH:mm:ss.SSS"
  Date now = new Date();
  String strDate = sdfDate.format(now);
  
  PImage partialSave = get(0,0,width,height-barH);
  String file = (pre + "_" + strDate + ".png");
  
  partialSave.save("/img/"+ file);
  println(file + " saved");
}

// ------------ modification methods ------------

public void resetGrid() {
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (i < 2) {
        grid[i][j] = new Cell(i, j + 2);
      } else {
        grid[i][j] = new Cell(i, 12 - j);
      }
    }
  }
}

public void generateMixx(boolean shuffleRows, boolean swapValues) {
  LinkedList<Integer> candidates = new LinkedList(Arrays.asList(new Integer[] {1, 2, 3}));
  Random rnd = new Random();
  int random = rnd.nextInt(2) + 1;
  int firstRedSwap = candidates.remove(random);
  Boolean firstColumn = rnd.nextBoolean();

  int[] redSwaps = new int[3];
  if (firstRedSwap == 2) {
    redSwaps = new int[] {2, 3, 1};
  } else if (firstRedSwap == 3) {
    redSwaps = new int[] {3, 2, 1};
  }

  // FIRST SWAP (column 2/3)
  if (firstColumn) {
    swapRemainingCells(new int[] {0, 2}, new int[] { redSwaps[0], 2}, swapValues);
    swapRemainingCells(new int[] { candidates.pop(), 3}, new int[] { candidates.pop(), 3}, swapValues);
  } else {
    swapRemainingCells(new int[] {0, 3}, new int[] { redSwaps[0], 3}, swapValues);
    swapRemainingCells(new int[] { candidates.pop(), 2}, new int[] { candidates.pop(), 2}, swapValues);
  }

  // SECOND SWAP (column 6)
  candidates = new LinkedList(Arrays.asList(new Integer[] {0, 1, 2, 3}));
  // remove red swap colors
  candidates.remove(new Integer (redSwaps[0]) );
  candidates.remove(new Integer (redSwaps[1]) );
  swapRemainingCells(new int[] { redSwaps[0], 6}, new int[] { redSwaps[1], 6}, swapValues);
  swapRemainingCells(new int[] { candidates.pop(), 6}, new int[] { candidates.pop(), 6}, swapValues);

  // LAST SWAP (column 8/9)
  candidates = new LinkedList(Arrays.asList(new Integer[] {0, 1, 2, 3}));
  // remove red swap colors
  candidates.remove(new Integer (redSwaps[1]) );
  candidates.remove(new Integer (redSwaps[2]) );
  if (firstColumn) {
    swapRemainingCells(new int[] { redSwaps[1], 9}, new int[] { redSwaps[2], 9}, swapValues);
    swapRemainingCells(new int[] { candidates.pop(), 8}, new int[] { candidates.pop(), 8}, swapValues);
  } else {
    swapRemainingCells(new int[] { redSwaps[1], 8}, new int[] {redSwaps[2], 8}, swapValues);
    swapRemainingCells(new int[] { candidates.pop(), 9}, new int[] { candidates.pop(), 9}, swapValues);
  }

  if (shuffleRows) {
    shuffleRows();
  };
}

public void shuffleRows() {
  LinkedList rows = new LinkedList(Arrays.asList(new Integer[] {0, 1, 2, 3}));
  Collections.shuffle(rows);
  Cell[][] shuffleGrid = new Cell[4][11];
  shuffleGrid[0] = grid[(int) rows.pop()];
  shuffleGrid[1] = grid[(int) rows.pop()];
  shuffleGrid[2] = grid[(int) rows.pop()];
  shuffleGrid[3] = grid[(int) rows.pop()];
  grid = shuffleGrid;
}

public void swapCells(int[] a, int[] b, boolean swapValues) {
  if (a == b) {
    println("warning: trying to swap the same cell");
    return;
  }
  Cell a_ = grid[a[0]][a[1]];
  Cell b_ = grid[b[0]][b[1]];
  if (grid[a[0]][a[1]] == grid[b[0]][b[1]]) {
    println("FAK");
  }
  if (swapValues) {
    grid[a[0]][a[1]] = b_;
    grid[b[0]][b[1]] = a_;
  } else {
    int[] cols = {a_.col, b_.col};
    grid[a[0]][a[1]].col = cols[1];
    grid[b[0]][b[1]].col = cols[0];
  }
}

public void shuffleValues() {
  LinkedList values;
  for (int i = 0; i < rows; i++) {
    values = new LinkedList(Arrays.asList(new Integer[] {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}));
    for (int j = 0; j < cols; j++) {
      Collections.shuffle(values);
      grid[i][j].value = (int) values.pop();
    }
  }
}

public void swapRemainingCells(int[] a, int[] b, boolean swapValues) {
  if (a[1] == b[1]) {
    for (int j = a[1]; j < cols; j++) {
      swapCells(new int[] {a[0], j}, new int[] {b[0], j}, swapValues);
    }
  } else {
    println("warning: swapping segments of different lengths");
    if (swapValues) {
      return;
    }
    int a_ = grid[a[0]][a[1]].col;
    int b_ = grid[b[0]][b[1]].col;

    for (int j = a[1]; j < cols; j++) {
      grid[a[0]][j].col = b_;
    }

    for (int j = b[1]; j < cols; j++) {
      grid[b[0]][j].col = a_;
    }
  }
}

class Cell {
  int col;
  int value;

  public Cell(int c, int v) {
    col = c;
    value = v;
  }

  public void setCol(int c) {
    col = c;
  }

  public void setVal(int v) {
    value = v;
  }
}
  public void settings() {  size(600, 254); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "QUIXX_mixxer" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
