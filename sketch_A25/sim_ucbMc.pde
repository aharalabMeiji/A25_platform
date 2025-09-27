void ucbMcStartSimulation(ucbClass ucb) {
  simulator.Participants = new player[5];
  //attackChanceSV = new float[625];//アタックチャンス時の評価値の表
  //attackChanceSV2 = new float[625];//アタックチャンス時の評価値の表
  attackChanceVP = new int[625];//アタックチャンス時の合法手のフラグ
  winrateConvergents=false;
  panelsConvergent=false;
  // プレーヤーをランダムに設定
  for (int p=1; p<5; p++) {
    simulator.Participants[p] = new player(p, "random", brain.Random);
  }
  ucb.fullNodes = new ArrayList<uctNode>();
  // 評価値のクリア
  for (int j=0; j<=25; j++) {
    simulator.mainBoard.sv[j]=0;// ここにUCT値を代入する。
  }
  for (int i=0; i<25; i++) {
    simulator.mainBoard.s[i].col = simulatorStartBoard.get(simulator.StartBoardId).theArray[i];
    simulator.mainBoard.s[i].marked = 0;
  }
  simulator.nextPlayer = simulatorStartBoard.get(simulator.StartBoardId).nextPlayer;
  simulator.subjectPlayer = simulator.nextPlayer;
  // root nodeの設置と、
  ucb.rootNode = new uctNode();
  for (int j=0; j<25; j++) {
    ucb.rootNode.bd[j] = simulator.mainBoard.s[j].col;
  }
  if (simulator.mainBoard.attackChanceP()) {//アタックチャンスのための１世代めの追加
    simulator.mainBoard.attackChanceP=true;
    simulator.mainBoard.buildVP(simulator.nextPlayer);// そもそもの着手可能パネル
    //アタックチャンス時の合法手の決定
    for (int j=0; j<25; j++) { //加えるほう
      for (int i=0; i<25; i++) { //黄色にするほう
        int k = i*25+j;
        if (simulator.mainBoard.vp[j]>0 && (simulator.mainBoard.s[i].col>=1 && simulator.mainBoard.s[i].col<=4)) {
          attackChanceVP[k]=1;
        } else if (simulator.mainBoard.vp[j]>0 && i==j) {//　ルール上これも許される。
          attackChanceVP[k]=1;
        } else {
          attackChanceVP[k]=0;
        }
      }
    }
    simulator.mainBoard.simulatorNumber=0;
    ucb.rootNode.children=new ArrayList<uctNode>();
    for (int k=0; k<625; k++) {//アタックチャンス時の合法手のノードを追加する
      if (attackChanceVP[k]>0) {
        uctNode newNode = new uctNode();
        ucb.rootNode.children.add(newNode);
        ucb.fullNodes.add(newNode);
        newNode.setItem(simulator.nextPlayer, k);
        simulator.mainBoard.copyBoardToSub(simulator.subBoard);
        int j=k%25;
        int i=int(k/25);
        simulator.subBoard.move(simulator.nextPlayer, j);// 1手着手する
        simulator.subBoard.s[i].col = 5;// 黄色を置く
        for (int l=0; l<25; l++) {
          newNode.bd[l] = simulator.subBoard.s[l].col;
        }
        newNode.parent = ucb.rootNode;
        newNode.children = null;
        //とりあえず、最初の１シミュレーションはここで行うのがよさそう。
        winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants);//そこから最後までシミュレーションを行う。
        simulator.mainBoard.simulatorNumber ++;
        newNode.na=1;//　初回につき代入、以後+=
        for (int p=1; p<5; p++) {
          newNode.wa[p] = wp.points[p];//　初回につき代入、以後+=
        }
        //simulator.mainBoard.s[j].marked=1;// この行、様子をみる。実際には、盤面下部に優良データを表示する方針
      }
    }
  } else {// 通常時の１世代めの追加 // UCT1
    simulator.mainBoard.attackChanceP=false;
    simulator.mainBoard.buildVP(simulator.nextPlayer);
    simulator.mainBoard.simulatorNumber=0;
    ucb.rootNode.children=new ArrayList<uctNode>();
    for (int j=0; j<25; j++) {
      if (simulator.mainBoard.vp[j]>0) {
        uctNode newNode = new uctNode();
        ucb.rootNode.children.add(newNode);
        ucb.fullNodes.add(newNode);
        newNode.setItem(simulator.nextPlayer, j);
        simulator.mainBoard.copyBoardToSub(simulator.subBoard);
        simulator.subBoard.move(simulator.nextPlayer, j);
        for (int k=0; k<25; k++) {
          newNode.bd[k] = simulator.subBoard.s[k].col;
        }
        newNode.parent = ucb.rootNode;
        //とりあえず、最初の１シミュレーションはここで行うのがよさそう。
        winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants);//そこから最後までシミュレーションを行う。
        simulator.mainBoard.simulatorNumber ++;
        newNode.na=1;//　初回につき代入、以後+=
        for (int p=1; p<5; p++) {
          newNode.wa[p] = wp.points[p];//　初回につき代入、以後+=
        }
        simulator.mainBoard.s[j].marked=1;
      } else {
        simulator.mainBoard.s[j].marked=0;
      }
    }
  }
}

void ucbMcAttackchanceLoop(ucbClass ucb) {
  float maxUct=-100;
  uctNode maxNd=null;
  for (uctNode nd : ucb.fullNodes) {
    if (nd.children==null) {
      float newUct = nd.UCTwp(nd.player, simulator.mainBoard.simulatorNumber) ;
      if (newUct>maxUct) {
        maxUct=newUct;
        maxNd=nd;
      }
    }
  }
  if (maxNd==null) {
    simulationManager=sP.GameEnd;
  } else {
    //この枝のデータを更新する。
    //最良ノードについてランダム打ち切りで勝敗を求める
    for (int k=0; k<25; k++) {//ノードの盤面をsimulator.subBoardへコピ－
      simulator.subBoard.s[k].col = maxNd.bd[k] ;
    }
    winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants);//そこから最後までシミュレーションを行う。
    simulator.mainBoard.simulatorNumber ++;
    maxNd.na ++ ;//
    for (int p=1; p<5; p++) {
      maxNd.wa[p] += wp.points[p];//
      maxNd.pa[p] += wp.panels[p];//
    }
  }
  if (gameOptions.get("SimTimes")==11) {// 10sec
    if (millis()-startTime>=10000) {
      simulationManager=sP.GameEnd;
    }
  } else if (gameOptions.get("SimTimes")==12) {// 60sec
    if (millis()-startTime>=60000) {
      simulationManager=sP.GameEnd;
    }
  } else if (gameOptions.get("SimTimes")==13) {// limit
    if (winrateConvergents && panelsConvergent) {
      simulationManager=sP.GameEnd;
    }
  }
}

void ucbMcAttackchanceDisplay(ucbClass ucb) {
  simulator.mainBoard.display(11);// Ucb1 ディスプレイ
  prize prize=new prize();
  prize.getPrize3FromNodeList(simulator.nextPlayer, ucb.rootNode.children);
  displayBestStats(prize);
  showReturnButton();
  showScreenCapture();
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
}
