int grid[][];
int rows = 6;
int cols = 6;
int rowSp;
int colSp;
int curr = 1;
int[] pos = {0,0};

void setup(){
  size(400, 400);
  grid = new int[rows][cols];
  grid[pos[0]][pos[1]] = curr;
  curr++;
  rowSp = height / rows;
  colSp = width / cols;
  next();
}

void draw(){
  background(0);
  
  stroke(0);
  fill(255);
  for (int i = 0; i < rows; i++ ){
    for (int j = 0; j < cols; j++ ){
       rect(j * colSp, i * rowSp, (j + 1) * colSp, (i + 1) * rowSp );
    }
  }
  noStroke();
  fill(255, 0, 0);
  for (int i = 0; i < rows; i++ ){
    for (int j = 0; j < cols; j++ ){
      if (grid[i][j] != 0){
        ellipse( (j + 0.5) * colSp, (i + 0.5) * rowSp, colSp * 0.5, rowSp * 0.5);   
      }
    }
  }
}

void printGrid(){
  System.out.println("+-----------------------+");
        for (int x = 0; x < grid.length; y++) {
            if (x % BOXSIZE == 0 && x != 0) {
                System.out.println("-------------------------");   
            }
            
            for (int y = 0; y < grid[0].length; x++) {
                if (y % BOXSIZE == 0) {
                    System.out.print("| ");   
                }
                
                if (grid[y][x] != 0) {
                    System.out.print(grid[y][x] + " ");
                } else {
                    System.out.print("  ");
                }
            }
            System.out.print("|");
            System.out.println();
        }
        System.out.println("+-----------------------+");
        System.out.println();
}


void next(){
  if (curr == rows * cols){
    printGrid();
  }
  ArrayList<int[]> opt = findOptions(pos[0], pos[1]);
  while (opt.size() > 0){
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
    //println(curr);
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
