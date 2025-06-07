/// ucbFast

int ucbFastBrain(player pl) {
  player[] ucbMcParticipants = new player[5];
  for (int p=1; p<5; p++) {
    ucbMcParticipants[p] = new player(p, "random", brain.Random);
  }

  //println("pl の変数の初期化");
  pl.myBoard.ClearSv();
  pl.yellow=-1;

  //println("シミュレーション用のサブボード");
  //uct.subBoard = new board();// assignは済んでいる。
  //for (int k=0; k<25; k++) {
  //  ucbSubboard.s[i].col = pl.myBoard.s[i].col;
  //}

  //println("ルートノード");
  uct.rootNode=new uctNode();
  uct.rootNode.children = new ArrayList<uctNode>();
  pl.myBoard.copyBoardToBd(uct.rootNode.bd);

  //配列vpの値の初期化
  pl.myBoard.buildVP(pl.position);
  //println("ルートノードに子供を吊り下げる");
  uctNode newNode=null;//
  if (pl.myBoard.attackChanceP()) {//ここだけ分岐
    pl.myBoard.attackChanceP=true;
    for (int j=0; j<25; j++) { //加えるほう
      for (int i=0; i<25; i++) { //黄色にするほう
        int k = i*25+j;
        if ((pl.myBoard.vp[j]>0 && (pl.myBoard.s[i].col>=1 && pl.myBoard.s[i].col<=4)) || (pl.myBoard.vp[j]>0 && i==j)) {
          newNode = new uctNode();
          newNode.setItem(pl.position, k);
          uct.rootNode.children.add(newNode);//ぶら下げる
          pl.myBoard.copyBoardToSub(uct.subBoard);
          uct.subBoard.move(pl.position, j);// 1手着手する
          uct.subBoard.s[i].col = 5;// 黄色を置く
          uct.subBoard.copyBoardToBd(newNode.bd);
          newNode.attackChanceNode=true;
        }
      }
    }
  } else
  {
    for (int k=0; k<25; k++) {
      if (pl.myBoard.vp[k]>0) {
        newNode = new uctNode();
        newNode.setItem(pl.position, k);
        uct.rootNode.children.add(newNode);//ぶら下げる
        pl.myBoard.copyBoardToSub(uct.subBoard);
        uct.subBoard.move(pl.position, k);// 1手着手する
        uct.subBoard.copyBoardToBd(newNode.bd);
        // subBoardはここで捨てる。
        //newNode.attackChanceNode=false;//デフォルト
      }
    }
    //println("手抜きという選択肢を考える");
    newNode = new uctNode();
    newNode.setItem(pl.position, 25);
    uct.rootNode.children.add(newNode);//ぶら下げる
    pl.myBoard.copyBoardToSub(uct.subBoard);// この行は不要
    pl.myBoard.copyBoardToBd(newNode.bd);
    //newNode.attackChanceNode=false;//デフォルト
  }

  // １万回UCBを試して成績の悪いものをカットする。

  if (pl.myBoard.attackChanceP()) {
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
