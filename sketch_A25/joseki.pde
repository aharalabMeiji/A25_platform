class joseki{
  String board;
  int answer;
  joseki(String b, int a){
    board = b;
    answer = a;
  }
    
};

int uctMctsStartingJoseki(player pl) {
  int count=0;
  for (int k=0; k<25; k++) {
    if (pl.myBoard.s[k].col!=0) {
      count++;
    }
  }
  //println("panels =",count);
  if (count==0) {////////////////////////////////// 1 /////////
    return 12;
  }
  if (count==1) {////////////////////////////////// 2 /////////
    return 7;
  }
  if (count==2) {////////////////////////////////// 3 /////////
    uct.mainBoard=new board();
    pl.myBoard.buildVP(pl.position);
    if (pl.myBoard.s[7].col>0 && pl.myBoard.vp[2]>0) return 2;
    if (pl.myBoard.s[11].col>0 && pl.myBoard.vp[10]>0) return 10;
    if (pl.myBoard.s[13].col>0 && pl.myBoard.vp[14]>0) return 14;
    if (pl.myBoard.s[17].col>0 && pl.myBoard.vp[22]>0) return 22;
    if (pl.myBoard.s[6].col>0 && pl.myBoard.vp[0]>0) return 0;
    if (pl.myBoard.s[8].col>0 && pl.myBoard.vp[4]>0) return 4;
    if (pl.myBoard.s[16].col>0 && pl.myBoard.vp[20]>0) return 20;
    if (pl.myBoard.s[18].col>0 && pl.myBoard.vp[24]>0) return 24;
  }
  if (count==3) {////////////////////////////////// 4 /////////
    if (sameColor(pl.myBoard,7,12,17) && pl.myBoard.s[12].col!=pl.position) return 2;
    if (sameColor(pl.myBoard,7,12,17) && pl.myBoard.s[12].col==pl.position) return 2;
    if (sameColor(pl.myBoard,11,12,13) && pl.myBoard.s[12].col!=pl.position) return 14;
    if (sameColor(pl.myBoard,11,12,13) && pl.myBoard.s[12].col==pl.position) return 14;
    if (sameColor(pl.myBoard,2, 7,12) && pl.myBoard.s[12].col==pl.position) return 17;
    if (sameColor(pl.myBoard,10, 11, 12) && pl.myBoard.s[12].col==pl.position) return 13;
    if (sameColor(pl.myBoard,12,13,14) && pl.myBoard.s[12].col==pl.position) return 11;
    if (sameColor(pl.myBoard,12,17,22) && pl.myBoard.s[12].col==pl.position) return 7;     
    if (sameColor(pl.myBoard,2, 7,12) && pl.myBoard.s[12].col!=pl.position) return 25;
    if (sameColor(pl.myBoard,10, 11, 12) && pl.myBoard.s[12].col!=pl.position) return 25;
    if (sameColor(pl.myBoard,12,13,14) && pl.myBoard.s[12].col!=pl.position) return 25;
    if (sameColor(pl.myBoard,12,17,22) && pl.myBoard.s[12].col!=pl.position) return 25;     
    
  }
  if (count==4){
    if (sameColor(pl.myBoard,2,7,12,17) && pl.myBoard.s[12].col==pl.position) return 22;    
    if (sameColor(pl.myBoard,7,12,17,22) && pl.myBoard.s[12].col==pl.position) return 2;    
    if (sameColor(pl.myBoard,11,12,13,14) && pl.myBoard.s[12].col==pl.position) return 10;    
    if (sameColor(pl.myBoard,10,11,12,13) && pl.myBoard.s[12].col==pl.position) return 14;        
    if (sameColor(pl.myBoard,2,7,12,17) && pl.myBoard.s[12].col!=pl.position) return 25;    
    if (sameColor(pl.myBoard,7,12,17,22) && pl.myBoard.s[12].col!=pl.position) return 25;    
    if (sameColor(pl.myBoard,11,12,13,14) && pl.myBoard.s[12].col!=pl.position) return 25;    
    if (sameColor(pl.myBoard,10,11,12,13) && pl.myBoard.s[12].col!=pl.position) return 25;        
  }
  if (count==5){
    if (sameColor(pl.myBoard,7,12,17,22) && sameColor(pl.myBoard,2,7)&& pl.myBoard.s[12].col==pl.position) return 11;    
    if (sameColor(pl.myBoard,11,12,13,14) && sameColor(pl.myBoard,10,11)&& pl.myBoard.s[12].col==pl.position) return 7;    
    if (sameColor(pl.myBoard,7,12,17,22) && sameColor(pl.myBoard,2,7)&& pl.myBoard.s[12].col!=pl.position) return 25;    
    if (sameColor(pl.myBoard,11,12,13,14) && sameColor(pl.myBoard,10,11)&& pl.myBoard.s[12].col!=pl.position) return 25;    
  }
  return -1;
}

boolean sameColor(board b, int i, int j){
  if (b.s[i].col>0 && b.s[j].col>0){
    if (b.s[i].col == b.s[j].col){
      return true;
    }
  }
  return false;
}

boolean sameColor(board b, int i, int j, int k){
  if (b.s[i].col>0 && b.s[j].col>0 && b.s[k].col>0){
    if (b.s[i].col == b.s[j].col && b.s[j].col == b.s[k].col){
      return true;
    }
  }
  return false;
}

boolean sameColor(board b, int i, int j, int k, int m){
  if (b.s[i].col>0 && b.s[j].col>0 && b.s[k].col>0 && b.s[m].col>0){
    if (b.s[i].col == b.s[j].col && b.s[j].col == b.s[k].col && b.s[k].col == b.s[m].col){
      return true;
    }
  }
  return false;
}
