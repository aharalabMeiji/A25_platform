boolean isCenter(int k){
  return (k==12);
}

boolean isCorner(int k){
  return (k==0) || (k==4) || (k==20) || (k==24);
}

boolean isEdge(int k){
  return (k==1) || (k==2) || (k==3) || 
  (k==9) || (k==14) || (k==19) || 
  (k==21) || (k==22) || (k==23) || 
  (k==5) || (k==10) || (k==15);
}

boolean isCross(int k){
  return (k==2) || (k==7) || (k==12) || (k==17) || (k==22) ||
  (k==10) || (k==11) || (k==13) || (k==14);
}

boolean isInsideCross(int k){
  return  (k==7) ||  (k==15) || (k==11) || (k==13);
}

boolean isOutsideCross(int k){
  return  (k==2) ||  (k==22) || (k==10) || (k==14);
}

boolean isNearCorner(int k){
  return (k==1) || (k==5) || (k==6) || 
  (k==3) || (k==8) || (k==9) || 
  (k==18) || (k==19) || (k==23) || 
  (k==15) || (k==16) || (k==21);
}

boolean isCNearCorner(int k){
  return (k==1) || (k==5) ||  
  (k==3) || (k==9) || 
  (k==19) || (k==23) || 
  (k==15) || (k==21);
}

boolean isXNearCorner(int k){
  return (k==6) || 
  (k==8) || 
  (k==18)  ||
  (k==16);
}

boolean isEarlyStage(board b){
  for (int k=0; k<25; k++){
    if (!isCross(k)){
      if (b.s[k].col>0){
        return false;
      }
    }
  }
  return true;
}

int isCornerBattle(board b){
  //int corner=0;
  if (b.s[0].col == 0 && (b.s[1].col != 0 || b.s[5].col != 0 || b.s[6].col != 0)){
    return 0;
  }
   if (b.s[4].col == 0 && (b.s[3].col != 0 || b.s[8].col != 0 || b.s[9].col != 0)){
    return 4;
  }
  if (b.s[20].col == 0 && (b.s[15].col != 0 || b.s[16].col != 0 || b.s[21].col != 0)){
    return 20;
  }
  if (b.s[24].col == 0 && (b.s[18].col != 0 || b.s[19].col != 0 || b.s[23].col != 0)){
    return 24;
  }
  return -1; 
}
boolean isMidField(int turn){
  return true;
}

int heu0Brain(player pl) {
  pl.myBoard.buildVP(pl.position);
  //pl.myBoard.vp に、候補を整数値（大きい値ほど選ばれる確率が大きい）で入れておく。
  //候補を一つに絞ってもよいが、いつでも同じ動作になってしまうので、複数個の候補を重みをつけておくとよい。
  if (pl.myBoard.attackChanceP()) {
    // 本当は、置く場所と、をセットで回答させたい。
    pl.yellow=-1;//消す場所をここに入れておけば、あとでそのように処理をする。
  }
  return pl.chooseOne(pl.myBoard.vp);
}

int heu0AttackChance(player pl) {
  if (pl.yellow!=-1) return pl.yellow;// すでに決定済みであれば、それを回答する。
  int[] ac = new int[25];
  for (int i=0; i<25; i++) {
    if (1<=pl.myBoard.s[i].col && pl.myBoard.s[i].col<=4) {
      ac[i]=1;
    } else {
      ac[i]=0;
    }
  }
  return pl.chooseOne(ac);
}
