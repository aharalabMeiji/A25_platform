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
          //1回実行する
          winPoints wp = playSimulatorToEnd(uct.subBoard, ucbMcParticipants);
          newNode.na=1;//
          for (int p=1; p<=4; p++) {
            newNode.wa[p] = wp.points[p];//初回は代入
            newNode.pa[p] = 1.0*wp.panels[p];//初回は代入
            newNode.uct[p] = newNode.UCTa(p, 1);// シミュレーション回数は１
          }
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
        //newNode.attackChanceNode=false;//デフォルト
        //1回実行する
        winPoints wp = playSimulatorToEnd(uct.subBoard, ucbMcParticipants);
        newNode.na=1;//
        for (int p=1; p<=4; p++) {
          newNode.wa[p] = wp.points[p];//初回は代入
          newNode.pa[p] = 1.0*wp.panels[p];//初回は代入
          newNode.uct[p] = newNode.UCTa(p, 1);// シミュレーション回数は１
        }
        // subBoardはここで捨てる。
      }
    }
    //println("手抜きという選択肢を考える");
    newNode = new uctNode();
    newNode.setItem(pl.position, 25);
    uct.rootNode.children.add(newNode);//ぶら下げる
    pl.myBoard.copyBoardToSub(uct.subBoard);//
    pl.myBoard.copyBoardToBd(newNode.bd);
    //newNode.attackChanceNode=false;//デフォルト
    //1回実行する
    winPoints wp = playSimulatorToEnd(uct.subBoard, ucbMcParticipants);
    newNode.na=1;//
    for (int p=1; p<=4; p++) {
      newNode.wa[p] = wp.points[p];//初回は代入
      newNode.pa[p] = 1.0*wp.panels[p];//初回は代入
      newNode.uct[p] = newNode.UCTa(p, 1);// シミュレーション回数は１
    }
    // subBoardはここで捨てる。
  }
  // １万回UCBを試して成績の悪いものをカットする。
  int count=2;
  do{
    uctNode maxNode = getMaxUcbFromNodeList(pl.position, uct.rootNode.children, count);
    if (maxNode.na >= 500) {
      break;
    }
    uct.subsubBoard.copyBdToBoard(maxNode.bd);
    //1回実行する
    winPoints wp = playSimulatorToEnd(uct.subsubBoard, ucbMcParticipants);
    maxNode.na ++;//
    for (int p=1; p<=4; p++) {
      maxNode.wa[p] += wp.points[p];//初回は代入
      maxNode.pa[p] += 1.0*wp.panels[p];//初回は代入
    }
    for(uctNode nd : uct.rootNode.children){
      for (int p=1; p<=4; p++) {
        nd.uct[p] = nd.UCTa(p, count);
      }
    }
    count++;
  } while(count<10000);
  prize prz=new prize();
  prz.getPrize5FromNodeList(pl.position, uct.rootNode.children);
  for (int id=uct.rootNode.children.size()-1; id>=0; id--){
    uctNode nd =uct.rootNode.children.get(id);
    if(nd!=prz.getMove(1) && nd!=prz.getMove(2) && nd!=prz.getMove(3) && nd!=prz.getMove(4) && nd!=prz.getMove(5)){
      uct.rootNode.children.remove(id);
    }
  }
  do{
    uctNode maxNode = getMaxUcbFromNodeList(pl.position, uct.rootNode.children, count);
    if (maxNode.na >= 1000) {
      break;
    }
    uct.subsubBoard.copyBdToBoard(maxNode.bd);
    //1回実行する
    winPoints wp = playSimulatorToEnd(uct.subsubBoard, ucbMcParticipants);
    maxNode.na ++;//
    for (int p=1; p<=4; p++) {
      maxNode.wa[p] += wp.points[p];//
      maxNode.pa[p] += 1.0*wp.panels[p];//
    }
    for(uctNode nd : uct.rootNode.children){
      for (int p=1; p<=4; p++) {
        nd.uct[p] = nd.UCTa(p, count);
      }
    }
    count++;
  } while(count<20000);
  prz.getPrize1FromNodeList(pl.position, uct.rootNode.children);
  
  if (pl.myBoard.attackChanceP()) {
    int k=prz.getMove(1).move;
    pl.yellow=int(k/25);//黄色にするパネルをこの変数に入れておけば、あとでそのように処理をする。
    return (k%25);
  } else {
    return prz.getMove(1).move;
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
