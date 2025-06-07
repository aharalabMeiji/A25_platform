/// ucbFast

int ucbFastBrain(player pl){
  
  player[] ucbMcParticipants = new player[5];
  for (int p=1; p<5; p++) {
    ucbMcParticipants[p] = new player(p, "random", brain.Random);
  }
  //配列vpの値の初期化
  pl.myBoard.buildVP(pl.position);
  
  //println("pl の変数の初期化");
  for (int j=0; j<=25; j++) {
    pl.myBoard.sv[j]=0;
    pl.myBoard.sv2[j]=0;
  }
  pl.yellow=-1;
  
  //println("シミュレーション用のサブボード");
  board ucbSubboard = new board();
  //for (int k=0; k<25; k++) {
  //  ucbSubboard.s[i].col = pl.myBoard.s[i].col;
  //}
  
  //println("ルートノード");
  uctNode rootNode=new uctNode();
  rootNode.children = new ArrayList<uctNode>();
  for (int j=0; j<25; j++) {
    uctRoot.bd[j] = simulator.mainBoard.s[j].col;
  }
  if (pl.myBoard.attackChanceP()){
    pl.yellow=-1;//黄色にするパネルをこの変数に入れておけば、あとでそのように処理をする。
    return pl.chooseOne(pl.myBoard.vp);
  } else {
    return pl.chooseOne(pl.myBoard.vp);
  }
}

int ucbFastAttackChance(player pl) {
  if (pl.yellow!=-1) return pl.yellow;// すでに決定済みであれば、それを回答する。
  int[] ac = new int[25];
  for (int i=0; i<25; i++) {
    if (1<=pl.myBoard.s[i].col && pl.myBoard.s[i].col<=4) {
      ac[i]=1;
    } else {
      ac[i]=0;
    }
  }
  // ここまでで、選ばれる権利のあるパネルの重みがすべて１になっている。
  return pl.chooseOne(ac);//配列acの重みでランダムに一つ選ぶ
}
