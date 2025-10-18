/// ucbFast

int ucbFastBrain(player pl, ucbClass ucb) {
  int panelCount=0;
  for (int k=0; k<25; k++) {
    if (pl.myBoard.s[k].col!=0) {
      panelCount++;
    }
  }
  if (panelCount==0) {////////////////////////////////// 1 /////////
    return 12;
  }
  if (panelCount==1) {////////////////////////////////// 2 /////////
    return 7;
  }
  player[] ucbMcParticipants = new player[5];
  //if (ucb == ucb1){
  //  for (int p=1; p<5; p++) {
  //    ucbMcParticipants[p] = new player(p, "random", brain.UCB2);
  //  }
  //}else {
  for (int p=1; p<5; p++) {
    ucbMcParticipants[p] = new player(p, "random", brain.Random);
  }
    
  //}
  //println("pl の変数の初期化");
  pl.myBoard.ClearSv();
  pl.yellow=-1;

  //println("シミュレーション用のサブボード");
  //ucb.subBoard = new board();// assignは済んでいる。
  //for (int k=0; k<25; k++) {
  //  ucbSubboard.s[i].col = pl.myBoard.s[i].col;
  //}

  //println("ルートノード");
  ucb.rootNode=new uctNode();
  ucb.rootNode.legalMoves = new ArrayList<uctNode>();
  pl.myBoard.copyBoardToBd(ucb.rootNode.bd);

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
          ucb.rootNode.legalMoves.add(newNode);//ぶら下げる
          pl.myBoard.copyBoardToSub(ucb.subBoard);
          ucb.subBoard.move(pl.position, j);// 1手着手する
          ucb.subBoard.s[i].col = 5;// 黄色を置く
          ucb.subBoard.copyBoardToBd(newNode.bd);
          newNode.attackChanceNode=true;
          //1回実行する
          winPoints wp = playSimulatorToEnd(ucb.subBoard, ucbMcParticipants);
          newNode.na=1;//
          for (int p=1; p<=4; p++) {
            newNode.wa[p] = wp.points[p];//初回は代入
            newNode.pa[p] = 1.0*wp.panels[p];//初回は代入
            newNode.uct[p] = newNode.UCTwp(p, 1);// シミュレーション回数は１
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
        ucb.rootNode.legalMoves.add(newNode);//ぶら下げる
        pl.myBoard.copyBoardToSub(ucb.subBoard);
        ucb.subBoard.move(pl.position, k);// 1手着手する
        ucb.subBoard.copyBoardToBd(newNode.bd);     
        //newNode.attackChanceNode=false;//デフォルト
        //1回実行する
        winPoints wp = playSimulatorToEnd(ucb.subBoard, ucbMcParticipants);
        newNode.na=1;//
        for (int p=1; p<=4; p++) {
          newNode.wa[p] = wp.points[p];//初回は代入
          newNode.pa[p] = 1.0*wp.panels[p];//初回は代入
          newNode.uct[p] = newNode.UCTwp(p, 1);// シミュレーション回数は１
        }
        // subBoardはここで捨てる。
      }
    }
    //println("手抜きという選択肢を考える");
    if (pl.noPass==0){
      newNode = new uctNode();
      newNode.setItem(pl.position, 25);
      ucb.rootNode.legalMoves.add(newNode);//ぶら下げる
      pl.myBoard.copyBoardToSub(ucb.subBoard);//
      pl.myBoard.copyBoardToBd(newNode.bd);
      //newNode.attackChanceNode=false;//デフォルト
      //1回実行する
      winPoints wp = playSimulatorToEnd(ucb.subBoard, ucbMcParticipants);
      newNode.na=1;//
      for (int p=1; p<=4; p++) {
        newNode.wa[p] = wp.points[p];//初回は代入
        newNode.pa[p] = 1.0*wp.panels[p];//初回は代入
        newNode.uct[p] = newNode.UCTwp(p, 1);// シミュレーション回数は１
      }
    }
    // subBoardはここで捨てる。
  }
  // １万回UCBを試して成績の悪いものをカットする。 
  int count=2;
  do{
    uctNode maxNode = getMaxUcbFromNodeList(pl.position, ucb.rootNode.legalMoves, count);
    //if (uct == ucb1){
    //  print(":"+maxNode.na+"("+maxNode.move+")");
    //}
    if (maxNode.na >= 300) {
      break;
    }
    ucb.subsubBoard.copyBdToBoard(maxNode.bd);
    //1回実行する
    winPoints wp = playSimulatorToEnd(ucb.subsubBoard, ucbMcParticipants);
    maxNode.na ++;//
    for (int p=1; p<=4; p++) {
      maxNode.wa[p] += wp.points[p];//初回は代入
      maxNode.pa[p] += 1.0*wp.panels[p];//初回は代入
    }
    for(uctNode nd : ucb.rootNode.legalMoves){
      for (int p=1; p<=4; p++) {
        nd.uct[p] = nd.UCTwp(p, count);
      }
    }
    count++;
  } while(count<10000);
  //if (uct == ucb1) println("half");
  prize prz=new prize();
  if (ucb.rootNode.legalMoves.size()>=10){  
    prz.getPrize5FromNodeList(pl.position, ucb.rootNode.legalMoves);
  } else if (ucb.rootNode.legalMoves.size()>=4){ 
    prz.getPrize3FromNodeList(pl.position, ucb.rootNode.legalMoves);
  } else {    
    prz.getPrize1FromNodeList(pl.position, ucb.rootNode.legalMoves);
    if (pl.myBoard.attackChanceP()) {
      int k=prz.getMove(1).move;
      pl.yellow=int(k/25);//黄色にするパネルをこの変数に入れておけば、あとでそのように処理をする。
      return (k%25);
    } else {
      return prz.getMove(1).move;
    }
  }
  for (int id=ucb.rootNode.legalMoves.size()-1; id>=0; id--){
    uctNode nd =ucb.rootNode.legalMoves.get(id);
    if(nd!=prz.getMove(1) && nd!=prz.getMove(2) && nd!=prz.getMove(3) && nd!=prz.getMove(4) && nd!=prz.getMove(5)){
      ucb.rootNode.legalMoves.remove(id);
    }
  }
  do{
    uctNode maxNode = getMaxUcbFromNodeList(pl.position, ucb.rootNode.legalMoves, count);
    if (maxNode.na >= 1000) {
      break;
    }
    ucb.subsubBoard.copyBdToBoard(maxNode.bd);
    //1回実行する
    winPoints wp = playSimulatorToEnd(ucb.subsubBoard, ucbMcParticipants);
    maxNode.na ++;//
    for (int p=1; p<=4; p++) {
      maxNode.wa[p] += wp.points[p];//
      maxNode.pa[p] += 1.0*wp.panels[p];//
    }
    for(uctNode nd : ucb.rootNode.legalMoves){
      for (int p=1; p<=4; p++) {
        nd.uct[p] = nd.UCTwp(p, count);
      }
    }
    count++;
  } while(count<20000);
  prz.getPrize1FromNodeList(pl.position, ucb.rootNode.legalMoves);
  //println("goal="+prz.getMove(1).move);
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
