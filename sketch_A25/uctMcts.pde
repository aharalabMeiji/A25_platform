int uctMctsBrain(player pl) {
  //候補を一つに絞ってもよいが、いつでも同じ動作になってしまうので、複数個の候補を重みをつけておくとよい。
  //ここから
  
  //println("プレーヤーをランダムエージェントに設定");
  player[] uctMcParticipants = new player[5];
  for (int p=1; p<5; p++) {
    uctMcParticipants[p] = new player(p, "random", brain.Random);
  }

  //println("着手可能点を計算しておく");
  pl.myBoard.buildVP(pl.position);
  //pl.myBoard.vp に、候補を整数値（大きい値ほど選ばれる確率が大きい）で入れておく。
  
  //println("pl の変数の初期化");
  for (int j=0; j<=25; j++) {
    pl.myBoard.sv[j]=0;
    pl.myBoard.sv2[j]=0;
  }
  pl.yellow=-1;
  
  //println("シミュレーション用のサブボード");
  board uctMcSubboard = new board();
  //println("アクティブなノードのArrayList");
  ArrayList<uctNode> uctMcNodes = new ArrayList<uctNode>();
  //println("ループ回数のカウント");
  pl.myBoard.simulatorNumber=0;

  if (pl.myBoard.attackChanceP()) {
    // 本当は、置く場所と、をセットで回答させたい。
    pl.yellow=-1;//消す場所をここに入れておけば、あとでそのように処理をする。
  }
  return pl.chooseOne(pl.myBoard.vp);
}

int uctMctsAttackChance(player pl) {
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
