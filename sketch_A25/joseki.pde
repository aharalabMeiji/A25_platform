int rotation(int pos, int theta) {
  if (theta==0) return pos;
  if (theta==2) return 24-pos;
  int[] rot={20, 15, 10, 5, 0, 21, 16, 11, 6, 1, 22, 17, 12, 7, 2, 23, 18, 13, 8, 3, 24, 19, 14, 9, 4};
  if (theta==1) return rot[pos];
  else return 24-rot[pos];
}

int playByJoseki(player pl, int[] myPanel, int[] hisPanel1, int[] hisPanel2, int[] hisPanel3, int answer1, int answer2, int answer3, int pattern) {
  int lenA=myPanel.length;
  int lenB=hisPanel1.length;
  int lenC=hisPanel2.length;
  int lenD=hisPanel3.length;

  for (int t=0; t<4; t++) {
    boolean ret=true;
    if (lenA>0) {
      if (pl.myBoard.s[rotation(myPanel[0], t)].col != pl.position) {
        ret = false;
      }
    }
    if (ret && lenB>0) {
      if (pl.myBoard.s[rotation(hisPanel1[0], t)].col == pl.position) {
        ret = false;
      }
    }
    if (ret && lenC>0) {
      if (pl.myBoard.s[rotation(hisPanel2[0], t)].col == pl.position) {
        ret = false;
      }
    }
    if (ret && lenD>0) {
      if (pl.myBoard.s[rotation(hisPanel3[0], t)].col == pl.position) {
        ret = false;
      }
    }
    if (ret && lenB>0 && lenC>0) {
      if (pl.myBoard.s[rotation(hisPanel1[0], t)].col==pl.myBoard.s[rotation(hisPanel2[0], t)].col) {
        ret = false;
      }
    }
    if (ret && lenB>0 && lenD>0) {
      if (pl.myBoard.s[rotation(hisPanel1[0], t)].col==pl.myBoard.s[rotation(hisPanel3[0], t)].col) {
        ret = false;
      }
    }
    if (ret && lenC>0 && lenD>0) {
      if (pl.myBoard.s[rotation(hisPanel2[0], t)].col==pl.myBoard.s[rotation(hisPanel3[0], t)].col) {
        ret = false;
      }
    }
    if (ret && lenA>1) {
      for (int i=1; i<lenA; i++) {
        if (pl.myBoard.s[rotation(myPanel[i], t)].col!=pl.myBoard.s[rotation(myPanel[0], t)].col) {
          ret = false;
        }
      }
    }
    if (ret && lenB>1) {
      for (int i=1; i<lenB; i++) {
        if (pl.myBoard.s[rotation(hisPanel1[i], t)].col!=pl.myBoard.s[rotation(hisPanel1[0], t)].col) {
          ret = false;
        }
      }
    }
    if (ret && lenC>1) {
      for (int i=1; i<lenC; i++) {
        if (pl.myBoard.s[rotation(hisPanel2[i], t)].col!=pl.myBoard.s[rotation(hisPanel2[0], t)].col) {
          return -1;
        }
      }
    }
    if (ret && lenD>1) {
      for (int i=1; i<lenD; i++) {
        if (pl.myBoard.s[rotation(hisPanel3[i], t)].col!=pl.myBoard.s[rotation(hisPanel3[0], t)].col) {
          return -1;
        }
      }
    }
    if (ret){
      int[] t2tt={0,3,2,1};
      int tt=t2tt[t];
      if(pattern==0 || pattern==1){
        return rotation(answer1,tt);
      }
      if(pattern==2){
        int k=int(random(2));
        if (k==0) return rotation(answer1,tt); else return rotation(answer2,tt);
      }
      if(pattern==3){
         int k=int(random(3));
        if (k==0) return rotation(answer1,tt); else if(k==1) return rotation(answer2,tt); else return rotation(answer3,tt);
      }   
      else {
        if (pl.noPass==0) return 25;
        else return rotation(answer1,tt);
      }        
    }
  }
  return -1;
}

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
    int answer=-1;
    // . . . . .
    // . . A . .
    // . . A . .
    // . . A . .
    // . . . . .
    pl.myBoard.buildVP(pl.position);
    int[] a31a={7, 12, 17};
    int[] none={};
    answer = playByJoseki(pl, a31a, none, none, none, 2, 0, 0, 0);
    if (answer>=0 && pl.myBoard.vp[answer]>0) return answer;
    // . . . . .
    // . . B . .
    // . . B . .
    // . . B . .
    // . . . . .
    answer = playByJoseki(pl, none, a31a, none, none, 2, 0, 0, 0);
    if (answer>=0 && pl.myBoard.vp[answer]>0) return answer;
    // . . A . .
    // . . A . .
    // . . A . .
    // . . . . .
    // . . . . .
    int[] a32a={2, 7, 12};    
    answer = playByJoseki(pl, a32a, none, none, none, 17, 0, 0, 1);
    if (answer>=0 && pl.myBoard.vp[answer]>0) return answer;
    // . . B . .
    // . . B . .
    // . . B . .
    // . . . . .
    // . . . . .
    answer = playByJoseki(pl, none, a32a, none, none, 13, 0, 0, 10);
    if (answer>=0 &&  (answer==25 || pl.myBoard.vp[answer]>0)) return answer;
    // . . B . .
    // . . C . .
    // . . C . .
    // . . . . .
    // . . . . .
    int[] a33a={2};    
    int[] a33b={7, 12};
    answer = playByJoseki(pl, none, a33a, a33b, none, 11, 0, 0, 10);
    if (answer>=0 &&  (answer==25 || pl.myBoard.vp[answer]>0)) return answer;
    // . . C . .
    // . . B . .
    // . . A . .
    // . . . . .
    // . . . . .
    int[] a34a={12};    
    int[] a34b={7};
    int[] a34c={2};
    answer = playByJoseki(pl, a34a, a34b, a34c, none, 11, 0, 0, 1);///////////////////////////////////// old move
    if (answer>=0 &&  (answer==25 || pl.myBoard.vp[answer]>0)) return answer;
    // . . B . .
    // . . C . .
    // . . D . .
    // . . . . .
    // . . . . .
    answer = playByJoseki(pl, none, a34a, a34b, a34c, 11, 0, 0, 1);///////////////////////////////////// old move
    if (answer>=0 &&  (answer==25 || pl.myBoard.vp[answer]>0)) return answer;
  }
  if (count==4) {
    // . . A . .
    // . . A . .
    // . . A . .
    // . . A . .
    // . . . . .
    pl.myBoard.buildVP(pl.position);
    int[] a41a={2, 7, 12, 17};
    int[] none={};
    int answer = playByJoseki(pl, a41a, none, none, none, 22,0,0,0);
    if (answer>=0 && pl.myBoard.vp[answer]>0) return answer;
    // . . B . .
    // . . B . .
    // . . B . .
    // . . B . .
    // . . . . .
    answer = playByJoseki(pl, none, a41a, none, none, 13,0,0,10);
    if (answer>=0 && (answer==25 || pl.myBoard.vp[answer]>0)) return answer;   
    // . . B . .
    // . . C . .
    // . . C . .
    // . . C . .
    // . . . . .
    int[] a42b={2};
    int[] a42c={7, 12, 17};
    answer = playByJoseki(pl, none, a42b, a42c, none, 11,0,0,1);
    if (answer>=0 && (answer==25 || pl.myBoard.vp[answer]>0)) return answer;   
    // . . B . .
    // . . B . .
    // . . B C .
    // . . . . .
    // . . . . .
    int[] a43b={2, 7, 12};
    int[] a43c={13};
    answer = playByJoseki(pl, none, a43b, a43c, none, 14,0,0,1);
    if (answer>=0 && (answer==25 || pl.myBoard.vp[answer]>0)) return answer;   
  }
  if (count==5) {
    // . . A . .
    // . . A . .
    // . . A . .
    // . . A . .
    // . . A . .
    pl.myBoard.buildVP(pl.position);
    int[] a51a={2, 7, 12, 17, 22};
    int[] none={};
    int answer = playByJoseki(pl, a51a, none, none, none, 11,0,0,0);
    if (answer>=0 && pl.myBoard.vp[answer]>0) return answer;
    answer = playByJoseki(pl, none, a51a, none, none, 11,0,0,10);
    if (answer>=0 && (answer==25 || pl.myBoard.vp[answer]>0)) return answer;
    // . . A . .
    // . . A . .
    // . . A A A
    // . . . . .
    // . . . . .
    int[] a52a={2, 7, 12, 13, 14};
    answer = playByJoseki(pl, a52a, none, none, none, 11,0,0,0);
    if (answer>=0 && pl.myBoard.vp[answer]>0) return answer;
    answer = playByJoseki(pl, none, a52a, none, none, 11,0,0,10);
    if (answer>=0 &&  (answer==25 || pl.myBoard.vp[answer]>0)) return answer;

  }
  if (count==6) {
    // . . A . .
    // . . A . .
    // . . A A .
    // . . A . .
    // . . A . .
    pl.myBoard.buildVP(pl.position);
    int[] a61a={2, 7, 12, 17, 22, 13};
    int[] none={};
    int answer = playByJoseki(pl, a61a, none, none, none, 14,0,0,0);
    if (answer>=0 && pl.myBoard.vp[answer]>0) return answer;
    answer = playByJoseki(pl, none, a61a, none, none, 14,0,0,0);
    if (answer>=0 && pl.myBoard.vp[answer]>0) return answer;
    // . . A . .
    // . . A . .
    // . . A A A
    // . . A . .
    // . . . . .
    int[] a62a={2, 7, 12, 13, 14, 17};
    answer = playByJoseki(pl, a62a, none, none, none, 22,0,0,0);
    if (answer>=0 && pl.myBoard.vp[answer]>0) return answer;
    answer = playByJoseki(pl, none, a62a, none, none, 11,0,0,10);
    if (answer>=0 &&  (answer==25 || pl.myBoard.vp[answer]>0)) return answer;
  }
  return -1;
}

boolean sameColor(board b, int i, int j) {
  if (b.s[i].col>0 && b.s[j].col>0) {
    if (b.s[i].col == b.s[j].col) {
      return true;
    }
  }
  return false;
}

boolean sameColor(board b, int i, int j, int k) {
  if (b.s[i].col>0 && b.s[j].col>0 && b.s[k].col>0) {
    if (b.s[i].col == b.s[j].col && b.s[j].col == b.s[k].col) {
      return true;
    }
  }
  return false;
}

boolean sameColor(board b, int i, int j, int k, int m) {
  if (b.s[i].col>0 && b.s[j].col>0 && b.s[k].col>0 && b.s[m].col>0) {
    if (b.s[i].col == b.s[j].col && b.s[j].col == b.s[k].col && b.s[k].col == b.s[m].col) {
      return true;
    }
  }
  return false;
}
