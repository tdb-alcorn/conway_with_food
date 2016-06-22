Cell[][] CELLS;
int T_MAX = 50;
int NUM_CELLS = 100;
int CELL_DRAW_SIZE = 10;
int T = 0;

void setup() {
  size(1000, 1000);
  frameRate(5);
  CELLS = initCells(NUM_CELLS);
  seed(CELLS);
  for (int t=1; t<T_MAX; t++) {
    step(CELLS, t);
  }
}

void draw() {
  for (int x=0, xlen=CELLS.length; x<xlen; x++) {
    for (int y=0, ylen=CELLS[x].length; y<ylen; y++) {
      CELLS[x][y].draw(T, CELL_DRAW_SIZE);
    }
  }
  T++;
  if (T == T_MAX) {
    T = 0;
  }
}

enum State {
  EMPTY, FOOD, ORGANISM;
}

void seed(Cell[][] cells) {
  for (int x=0, xlen=cells.length; x<xlen; x++) {
    for (int y=0, ylen=cells[x].length; y<ylen; y++) {
      switch (floor(random(3))) {
        case 0: cells[x][y].history[0] = State.EMPTY;
                break;
        case 1: cells[x][y].history[0] = State.FOOD;
                break;
        case 2: cells[x][y].history[0] = State.ORGANISM;
                break;
        default: cells[x][y].history[0] = State.EMPTY;
                 break;
      } 
    }
  }
}

void step(Cell[][] cells, int t) {
  for (int x=0, xlen=cells.length; x<xlen; x++) {
    for (int y=0, ylen=cells[x].length; y<ylen; y++) {
      cells[x][y].step(t);
    }
  }
}

Cell[][] initCells(int size) {
  Cell[][] cells = new Cell[size][size];
  for (int x=0; x<size; x++) {
    for (int y=0; y<size; y++) {
      cells[x][y] = new Cell();
      cells[x][y].x = x;
      cells[x][y].y = y;
    }
  }
  for (int x=0; x<size; x++) {
    for (int y=0; y<size; y++) {
      ArrayList<Cell> adjacentCells = new ArrayList<Cell>();
      if (x > 0) {
        adjacentCells.add(cells[x-1][y]);
      }
      if (y > 0) {
        adjacentCells.add(cells[x][y-1]);
      }
      if (x < size -1) {
        adjacentCells.add(cells[x+1][y]);
      }
      if (y < size - 1) {
        adjacentCells.add(cells[x][y+1]);
      }
      int acSize = adjacentCells.size();
      Cell[] ac = new Cell[acSize];
      for (int i=0; i<acSize; i++) {
        ac[i] = adjacentCells.get(i);
      }
      cells[x][y].adjacentCells = ac;
    }
  }
  return cells;
}

class Cell {
   public State[] history = new State[32];
   public int x, y;
   public Cell[] adjacentCells;
   
   void step(int t) {
     if (t >= history.length) {
       _doubleHistorySize();
     }
     if (history[t-1] == State.EMPTY) {
       // reproduction of organism
       for (int i=0, len=adjacentCells.length; i<len; i++) {
         if (adjacentCells[i].history[t-1] == State.ORGANISM && adjacentCells[i].isAdjacentTo(State.FOOD, t-1)) {
           history[t] = State.ORGANISM;
           return;
         }
       }
       // growth of food
       if (!isAdjacentTo(State.ORGANISM, t-1)) {
         //  && !isSurroundedBy(State.FOOD, t-1)
         history[t] = State.FOOD;
         return;
       }
     } else if (history[t-1] == State.ORGANISM) {
       // death of organism
       if (!(isAdjacentTo(State.FOOD, t-1) || isSurroundedBy(State.ORGANISM, t-1))) {
         // isSurroundedBy(State.ORGANISM, t-1)
         // numAdjacentTo(State.ORGANISM, t-1) > 0
         history[t] = State.EMPTY;
         return;
       }
     } else if (history[t-1] == State.FOOD) {
       // organism consumes food
       if (isAdjacentTo(State.ORGANISM, t-1)) {
         history[t] = State.EMPTY;
         return;
       }
     }
     history[t] = history[t-1];
   }
   
   private void _doubleHistorySize() {
     int size = history.length;
     State[] newHist = new State[size*2];
     for (int i=0; i<size; i++) {
       newHist[i] = history[i];
     }
     history = newHist;
   }
   
   boolean isAdjacentTo(State s, int t) {
     for (int i=0, len=adjacentCells.length; i<len; i++) {
       if (adjacentCells[i].history[t] == s) {
         return true;
       }
     }
     return false;
   }
   
   int numAdjacentTo(State s, int t) {
     int count = 0;
     for (int i=0, len=adjacentCells.length; i<len; i++) {
       if (adjacentCells[i].history[t] == s) {
         count++;
       }
     }
     return count;
   }
   
   boolean isSurroundedBy(State s, int t) {
     for (int i=0, len=adjacentCells.length; i<len; i++) {
       if (adjacentCells[i].history[t] != s) {
         return false;
       }
     }
     return true;
   }
   
   void draw(int t, int size) {
     switch (history[t]) {
       case EMPTY: fill(#FFFFFF);
                   break;
       case FOOD: fill(#AAAA00);
                  break;
       case ORGANISM: fill(#0000FF);
                      break;
     }
     rect(x*size, y*size, size, size);
   }
}