//
//  random MonteCarlo simulation
//

void randomMcStart() {
  simulator.Participants = new player[5];
  simulator.rootNode = new uctNode();
  simulator.rootNode.children = new ArrayList<uctNode>();
  //attackChanceSV = new float[625];//いらなくなる
  //attackChanceSV2 = new float[625];//いらなくなる
  attackChanceVP = new int[625];//
  prevWinrate1=prevWinrate2=prevPanels1=prevPanels2=0;//収束の計算
  // プレーヤーをランダムプレーヤーに設定
  for (int p=1; p<5; p++) {
    simulator.Participants[p] = new player(p, "random", brain.Random);
    //simulator.Participants[p] = new player(p, "random", brain.UCB1);//ここを引数にしてもよい。
  }
  for (int j=0; j<=25; j++) {
    simulator.mainBoard.sv[j]=0;
    simulator.mainBoard.sv2[j]=0;
  }
  //メインボードの初期可
  for (int i=0; i<25; i++) {
    simulator.mainBoard.s[i].col = simulatorStartBoard.get(simulator.StartBoardId).theArray[i];
    simulator.mainBoard.s[i].marked = 0;
  }
  //次の手番の指定
  simulator.nextPlayer = simulatorStartBoard.get(simulator.StartBoardId).nextPlayer;
  simulator.subjectPlayer = simulator.nextPlayer;
  // 着手可能点を計算しておく。
  simulator.mainBoard.buildVP(simulator.nextPlayer);// 0~24の話
  //for (int k=0; k<625; k++) {//いらなくなる
  //  attackChanceSV[k]=0;//いらなくなる
  //  attackChanceSV2[k]=0;//いらなくなる
  //}//いらなくなる
  simulator.mainBoard.simulatorNumber=0;
}

void randomMcRegularPrepare() {
  simulator.mainBoard.attackChanceP=false;
  simulator.mainBoard.buildVP(simulator.nextPlayer);
  simulator.rootNode.children.clear();
  for (int k=0; k<25; k++) {
    if (simulator.mainBoard.vp[k]>0 ) {
      uctNode newNode = new uctNode();
      newNode.setItem(simulator.nextPlayer, k);
      //newNodeに盤面情報を入れるならここ
      simulator.rootNode.children.add(newNode);
      newNode.parent = simulator.rootNode;
    }
  }
  uctNode newNode = new uctNode();
  newNode.setItem(simulator.nextPlayer, 25);
  //newNodeに盤面情報を入れるならここ
  simulator.rootNode.children.add(newNode);
  newNode.parent = simulator.rootNode;
}

void randomMcAttackchancePrepare() {
  // vpの初期化と、svの初期化
  simulator.mainBoard.attackChanceP=true;
  simulator.mainBoard.buildVP(simulator.nextPlayer);
  simulator.rootNode.children.clear();
  attackChanceCursor=1;
  for (int j=0; j<25; j++) { //加えるほう
    for (int i=0; i<25; i++) { //黄色にするほう
      int k = i*25+j;//これがアタックチャンスのmove番号
      if (simulator.mainBoard.vp[j]>0 && (simulator.mainBoard.s[i].col>=1 && simulator.mainBoard.s[i].col<=4)) {
        attackChanceVP[k]=1;
        uctNode newNode = new uctNode();
        newNode.setItem(simulator.nextPlayer, k);
        //newNodeに盤面情報を入れるならここ
        simulator.rootNode.children.add(newNode);
        newNode.parent = simulator.rootNode;
      } else if (simulator.mainBoard.vp[j]>0 && i==j) {//　ルール上これも許される。
        attackChanceVP[k]=1;
        uctNode newNode = new uctNode();
        newNode.setItem(simulator.nextPlayer, k);
        //newNodeに盤面情報を入れるならここ
        simulator.rootNode.children.add(newNode);
        newNode.parent = simulator.rootNode;
      } else {
        attackChanceVP[k]=0;
      }
    }
  }
}

void randomMcRegularLoop() {
  for (uctNode nd : simulator.rootNode.children) {
    // 問題画面をsimulatorSubにコピー
    for (int k=0; k<25; k++) {
      simulator.subBoard.s[k].col = simulatorStartBoard.get(simulator.StartBoardId).theArray[k];
    }
    if (nd.move<25) {
      simulator.subBoard.move(simulator.nextPlayer, nd.move);// 1手着手する
      for (int k=0; k<25; k++) {
        nd.bd[k] = simulator.subBoard.s[k].col;
      }
      //println(simulator.nextPlayer, j, "*");
      winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants);//そこから最後までシミュレーションを行う。
      nd.na ++;
      for (int p=1; p<=4; p++) {
        nd.wa[p] += wp.points[p];
        nd.pa[p] += wp.panels[p];
      }
      //println(nd.move,nd.wa[1], nd.na);
      //画面表示指示
      simulator.mainBoard.sv[nd.move] = nd.wa[simulator.subjectPlayer]/nd.na;//　その着手点はちょっと優秀ということになる。
      simulator.mainBoard.sv2[nd.move] = nd.pa[simulator.subjectPlayer]/nd.na;// 最終パネル数の累積
      simulator.mainBoard.s[nd.move].marked=simulator.nextPlayer;// svを表示する意味
    } else {// あえて着手しなかった場合
      for (int k=0; k<25; k++) {
        nd.bd[k] = simulator.subBoard.s[k].col;
      }
      winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants);//そこから最後までシミュレーションを行う。
      nd.na ++;
      for (int p=1; p<=4; p++) {
        nd.wa[p] += wp.points[p];
        nd.pa[p] += wp.panels[p];
      }
      simulator.mainBoard.sv[nd.move] = nd.wa[simulator.subjectPlayer]/nd.na;//　その着手点はちょっと優秀ということになる。
      simulator.mainBoard.sv2[nd.move] = nd.pa[simulator.subjectPlayer]/nd.na;// 最終パネル数の累積
    }
  }
  simulator.mainBoard.simulatorNumber ++;//シミュレーション回数（分母）
  // 終了条件
  if (gameOptions.get("SimTimes")==1) {// 1000 times
    if (simulator.mainBoard.simulatorNumber>=1000) {
      simulationManager=sP.GameEnd;
    }
  } else if (gameOptions.get("SimTimes")==2) {// 10000 times
    if (simulator.mainBoard.simulatorNumber>=10000) {
      simulationManager=sP.GameEnd;
    }
  } else {// gameOptions.get("SimTimes")==3 //
    // 収束するまで
    if (winrateConvergents && panelsConvergent) {
      simulationManager=sP.GameEnd;
    }
  }
}

void randomMcAttackchanceLoop() {
  //int loopLen = simulator.rootNode.children.size();
  for (uctNode nd : simulator.rootNode.children) {
    for (int i=0; i<25; i++) {// 問題画面をsimulatorSubにコピー
      simulator.subBoard.s[i].col = simulator.mainBoard.s[i].col;
    }
    int k = nd.move;
    int j = k%25;
    int i = int(k/25);
    simulator.subBoard.move(simulator.nextPlayer, j);// 1手着手する
    simulator.subBoard.setCol(i, 5);// 黄色を置く
    winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants);//そこから最後までシミュレーションを行う。
    nd.na ++;
    for (int p=1; p<=4; p++) {
      nd.wa[p] += wp.points[p];// 総勝ち数
      nd.pa[p] += wp.panels[p];// 最終パネル枚数の総数
    }
  }
  simulator.mainBoard.simulatorNumber ++;//シミュレーション回数（分母）
  // 終了条件
  if (gameOptions.get("SimTimes")==1) {// 1000 times
    if (simulator.mainBoard.simulatorNumber>=1000) {
      simulationManager=sP.GameEnd;
    }
  } else if (gameOptions.get("SimTimes")==2) {// 10000 times
    if (simulator.mainBoard.simulatorNumber>=10000) {
      simulationManager=sP.GameEnd;
    }
  } else {// gameOptions.get("SimTimes")==3 // 収束するまで
    if (winrateConvergents && panelsConvergent) {
      simulationManager=sP.GameEnd;
    }
  }
}

void randomMcRegularDisplay() {
  prize prize=new prize();
  prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.children);
  if (abs(prevWinrate1-prize.getWinrate(1))<0.0005 && abs(prevWinrate2-prize.getWinrate(2))<0.0005 )
    winrateConvergents=true;
  else
    winrateConvergents=false;
  prevWinrate1=prize.getWinrate(1);
  prevWinrate2=prize.getWinrate(2);
  if (abs(prevPanels1-prize.getPanels(1))<0.005 && abs(prevPanels2-prize.getPanels(2))<0.005 )
    panelsConvergent=true;
  else
    panelsConvergent=false;
  prevPanels1 = prize.getPanels(1);
  prevPanels2=prize.getPanels(2);
  simulator.mainBoard.setSubjectPlayerColor(simulator.subjectPlayer);
  simulator.mainBoard.randomMcSimulatorRegularDisplay();
  showReturnButton();
  showScreenCapture();
  setMainboardButton();
}

void randomMcAttackchanceDisplay() {
  simulator.mainBoard.randomMcSimulatorAttackchanceDisplay();
  prize prize=new prize();
  prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.children);
  if (abs(prevWinrate1-prize.getWinrate(1))<0.0005 && abs(prevWinrate2-prize.getWinrate(2))<0.0005 )
    winrateConvergents=true;
  else
    winrateConvergents=false;
  prevWinrate1=prize.getWinrate(1);
  prevWinrate2=prize.getWinrate(2);
  if (abs(prevPanels1-prize.getPanels(1))<0.005 && abs(prevPanels2-prize.getPanels(2))<0.005 )
    panelsConvergent=true;
  else
    panelsConvergent=false;
  prevPanels1 = prize.getPanels(1);
  prevPanels2=prize.getPanels(2);

  displayBestStats(prize);
  displayAllStats(attackChanceCursor, simulator.nextPlayer);
  showReturnButton();
  showScreenCapture();
  setMainboardButton();
}
