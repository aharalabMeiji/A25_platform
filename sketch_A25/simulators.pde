//// simulate line 2651 //<>//

class startBoard {
  int[] theArray;
  int nextPlayer;
  startBoard(int[] _a, int _p) {
    // _a must be of length 25, _p must be in {1,2,3,4}
    theArray = new int[25];
    for (int i=0; i<25; i++) {
      theArray[i] = _a[i];
    }
    nextPlayer = _p;
  }
  void display(int mode, int x, int y, int dx, int dy) {
    if (mode==0) {
      for (int i=0; i<25; i++) {
        int xx=x+dx*(i%5);
        int yy=y+dy*int(i/5);
        stroke(0);
        fill(utils.playerColor[theArray[i]]);
        rect(xx, yy, dx, dy);
      }
      fill(utils.playerColor[nextPlayer]);
      rect(x, y+dy*5.5, 5*dx, dy);
    }
  }
}

ArrayList<startBoard> simulatorStartBoard;
startBoard startBoard0;

void initStartBoard() {
  simulatorStartBoard.clear();
  String[] rows = loadStrings(filename);
  for (int i = 0; i < rows.length; ++i) {
    String[] fruits = splitTokens(rows[i], ",");
    int[] nums = new int [26];
    for (int j=0; j<26; j++) {
      nums[j] = int(fruits[j]);
    }
    simulatorStartBoard.add (new startBoard(nums, nums[25]));
    if (i==0) {
      startBoard0=new startBoard(nums, nums[25]);
    }
  }
}

// 面データを保存する。
void saveFile() {
}

// 面データを読みだす。
void openFile() {
  ;
}

class winPoints {
  float[] points;
  float[] panels;
  winPoints() {
    points = new float[5];
    points[0]=0;
    panels = new float[5];
    panels[0]=0;
  }
}

winPoints playSimulatorToEnd(board sub, player[] _participants) {// 引数名かぶり
  // TODO アタックチャンスの判定と処理
  // n(0)=4 -> AC_flag==false -> アタックチャンス, AC_flag=true
  //
  int remaining=0;
  for (int i=0; i<25; i++) {
    if (sub.s[i].col==0 || sub.s[i].col==5) remaining ++;// 黄色パネルは空欄あつかい
  }
  //println("playSimulatorToEnd:残り枚数は"+remaining);
  //int count=0;
  if (remaining>0) {
    //println("playSimulatorToEnd:ループ開始");
    do {
      int simulatorNextPlayer = int(random(4))+1;
      if (1<= simulatorNextPlayer && simulatorNextPlayer<=4 ) {
        //println("playSimulatorToEnd:player変数が持っている盤面をsubにコピーする。");
        sub.copyBoardToSub(_participants[simulatorNextPlayer].myBoard);
        int attack = -1;
        if (sub.attackChanceP()) {
          //println("playSimulatorToEnd:if attack chance");
          attack = _participants[simulatorNextPlayer].callBrain();
          if (0<= attack && attack<25) {
            sub.buildVP(simulatorNextPlayer);
            if (sub.vp[attack]>0) {
              sub.move(simulatorNextPlayer, attack);
            }
            attack = _participants[simulatorNextPlayer].callAttackChance();
            if (1 <= sub.s[attack].col&&  sub.s[attack].col<=4) {
              sub.s[attack].col=5;
            }
          }
        } else {
          //println("playSimulatorToEnd:通常時");
          attack = _participants[simulatorNextPlayer].callBrain();
          //println("playSimulatorToEnd:AIの回答は"+attack);
          if (0<= attack && attack<25) {
            sub.buildVP(simulatorNextPlayer);
            if (sub.vp[attack]>0) {
              //println("playSimulatorToEnd:AIの回答"+attack+"は合法手");
              sub.move(simulatorNextPlayer, attack);
            }
          }
        }
        //println("playSimulatorToEnd:残り枚数を数える");
        remaining = 0;
        for (int i=0; i<25; i++) {
          if (sub.s[i].col==0 || sub.s[i].col==5) remaining ++;// 黄色パネルは空欄あつかい
        }
        //println("playSimulatorToEnd:残り枚数は"+remaining);
        //println(simulatorNextPlayer, attack, remaining);
      }
      //count ++;
    } while (remaining >0);
    //println("playSimulatorToEnd:ループ終了");
  }
  int[] noP = new int[5];
  for (int i=0; i<25; i++) {
    if (sub.s[i].col>0) noP[sub.s[i].col] ++;
  }
  //println("各プレーヤーの枚数は："+noP[1]+","+noP[2]+","+noP[3]+","+noP[4]);
  winPoints wp=new winPoints();
  for (int p=1; p<5; p++) {
    wp.panels[p] = 1.0*noP[p];
    //int p = simulator.nextPlayer-1;
    int Pt1=0, Pt2=0;
    for (int q=1; q<5; q++) {
      if (noP[p]>noP[q]) Pt1 ++;
      if (noP[p]>=noP[q]) Pt2 ++;
    }
    wp.points[p]=0;
    if (Pt2==4) {// 最高枚数者
      if (winPointRule==0) {// 単独勝利のみ１勝
        if (Pt1==3) wp.points[p] = 1.0;
      } else if (winPointRule==1) {// 最高枚数者で勝ちを按分
        int anbun = 4-Pt1;
        wp.points[p] = 1.0 / anbun;
      } else if (winPointRule==2) {// 最高枚数者ならば1勝
        wp.points[p] = 1.0;
      }
    }
  }
  //println("各プレーヤーの勝ち点は："+wp.points[1]+","+wp.points[2]+","+wp.points[3]+","+wp.points[4]);
  return wp;//
}

void displayBestStats(prize prize) {
  textAlign(LEFT, CENTER);
  textSize(utils.fontSize);
  fill(255, 0, 0);
  text("BEST 3", utils.subL, utils.subU+utils.fontSize*1.5);
  fill(0);
  for (int pr=1; pr<=3; pr++) {
    int move = prize.getMove(pr).move;
    float winrate = prize.getWinrate(pr);
    float panels = prize.getPanels(pr);
    String msg = "("+(move%25+1)+"-"+(int(move/25)+1)+") "+nf(winrate, 1, 3)+" : "+ nf(panels, 2, 3);
    text(msg, utils.subL, utils.subU+utils.fontSize*1.5*(1+pr) );
  }
}

void displayAllStats(int cursor, int player) {
  textAlign(LEFT, CENTER);
  fill(255, 0, 0);
  text("ALL(click to slide)", utils.unitSize/2, utils.subU);
  fill(0);
  int loopSize=simulator.rootNode.children.size();
  int prev= (cursor+loopSize-1)%loopSize;
  uctNode tmpNd = simulator.rootNode.children.get(prev);
  int move=tmpNd.move;
  float winrate=tmpNd.wa[player]/tmpNd.na;
  float panels=tmpNd.pa[player]/tmpNd.na;
  String msg = "("+(move%25+1)+"-"+(int(move/25)+1)+") "+nf(winrate, 1, 3)+" : "+ nf(panels, 2, 3);
  text(msg, utils.unitSize/2, utils.subU+utils.fontSize*1.5);
  buttonPrevSV.setLT(utils.unitSize/2, utils.subU+utils.fontSize*1.5, msg);
  int now = cursor%loopSize;
  tmpNd = simulator.rootNode.children.get(now);
  move=tmpNd.move;
  winrate=tmpNd.wa[player]/tmpNd.na;
  panels=tmpNd.pa[player]/tmpNd.na;
  msg = "("+(move%25+1)+"-"+(int(move/25)+1)+") "+nf(winrate, 1, 3)+" : "+ nf(panels, 2, 3);
  text(msg, utils.unitSize/2, utils.subU+utils.fontSize*3);
  int next= (cursor+1)%loopSize;
  tmpNd = simulator.rootNode.children.get(next);
  move=tmpNd.move;
  winrate=tmpNd.wa[player]/tmpNd.na;
  panels=tmpNd.pa[player]/tmpNd.na;
  msg = "("+(move%25+1)+"-"+(int(move/25)+1)+") "+nf(winrate, 1, 3)+" : "+ nf(panels, 2, 3);
  text(msg, utils.unitSize/2, utils.subU+utils.fontSize*4.5);
  buttonNextSV.setLT(utils.unitSize/2, utils.subU+utils.fontSize*4.5, msg);
}



void showSimulator() {
  if (gameOptions.get("SimMethod")==1) {
    fullRandomMC();
  } else if (gameOptions.get("SimMethod")==2) {
    UCB1(ucb1);
  } else if (gameOptions.get("SimMethod")==3) {
    UCT1();
  } else {
    fullRandomMC();
  }
}

void fullRandomMC() {
  // 完全ランダム＝モンテカルロ1手読み
  if (simulationManager==sP.GameStart) {
    // シミュレーション開始。共通の準備
    randomMcStart();
    startTime=millis();
    simulationManager=sP.setStartBoard;
  } else if (simulationManager == sP.setStartBoard) {
    // 問題がアタックチャンス問題のときには、別処理にする。
    if (simulator.mainBoard.attackChanceP()) {
      // 問題がアタックチャンス問題のときの「準備」
      randomMcAttackchancePrepare();
      simulationManager = sP.runMC;
    } else {
      randomMcRegularPrepare();
      // 問題がアタックチャンスでないときの「準備」
      simulationManager = sP.runMC;
    }
  } else if (simulationManager == sP.runMC) {
    if (simulator.mainBoard.attackChanceP()) {
      // 問題がアタックチャンス問題のときの「ループ」
      randomMcAttackchanceLoop();
      if (simulator.mainBoard.simulatorNumber%500==0) {
        //表示データの更新
        randomMcAttackchanceDisplay();
      }
    } else {// 通常時
      //通常営業の「ループ」
      randomMcRegularLoop();
      if (simulator.mainBoard.simulatorNumber%500==0) {// 500回に1回、画面を更新する
        randomMcRegularDisplay();
      }
    }
    //print(",");
  } else if (simulationManager==sP.GameEnd) {
    // アタックチャンスの時
    if (simulator.mainBoard.attackChanceP()) {//アタックチャンス
      randomMcAttackchanceDisplay();
    } else {// フツウの時
      randomMcRegularDisplay();
    }
    //println(millis()-startTime);
  }
}


void UCB1(ucbClass ucb) {
  // UCB1手読み
  if (simulationManager==sP.GameStart) {
    // シミュレーション開始
    ucbMcStartSimulation(ucb);
    startTime=millis();
    simulationManager=sP.setStartBoard;
  } else if (simulationManager==sP.setStartBoard) {// UCB1ループ部分
    if (simulator.mainBoard.attackChanceP()) {//アタックチャンスの場合// UCB1ループ部分
      ucbMcAttackchanceLoop(ucb);
      if (simulator.mainBoard.simulatorNumber%500==0) {
        // 間歇的に表示を更新する。
        ucbMcAttackchanceDisplay(ucb);
      }
    } else {//通常の場合// UCT1ループ部分
      ucbMcRegularLoop(ucb);
      if (simulator.mainBoard.simulatorNumber%500==0) {
        ucbMcRegularDisplay();
      }
    }
  } else if (simulationManager==sP.GameEnd) {
    ;
  }
  //println(millis()-startTime);
  //startTime=millis();
}


void UCT1() {
  player nextPlayer=null;
  int SimTimes = gameOptions.get("SimTimes");
  if (simulationManager==sP.GameStart) {
    startTime=millis();
    if (SimTimes == 21) {
      uct.expandThreshold=10;
      uct.terminateThreshold = uct.expandThreshold*1000000;
      uct.depthMax=4;
      uct.cancelCountMax=10;
    } else if (SimTimes == 22) {
      uct.expandThreshold=10;
      uct.terminateThreshold = uct.expandThreshold*1000000;
      uct.depthMax=4;
      uct.cancelCountMax=1000000;
    } else if (SimTimes == 23) {
      uct.expandThreshold=10;
      uct.terminateThreshold = uct.expandThreshold*1000000;
      uct.depthMax=5;
      uct.cancelCountMax=20;
    } else if (SimTimes == 24) {
      uct.expandThreshold=10;
      uct.terminateThreshold = uct.expandThreshold*1000000;
      uct.depthMax=5;
      uct.cancelCountMax=100000;
    } else if (SimTimes == 25) {
      uct.expandThreshold=gameOptions.get("expandThreshold");
      if (gameOptions.get("terminateThreshold")==4) {
        uct.terminateThreshold = uct.expandThreshold*10000;
      } else if (gameOptions.get("terminateThreshold")==5) {
        uct.terminateThreshold = uct.expandThreshold*100000;
      } else {
        uct.terminateThreshold = uct.expandThreshold*1000000;
      }
      uct.depthMax=gameOptions.get("depthMax");
      if (gameOptions.get("wCancel")==1) {
        if (uct.depthMax==2) {
          uct.cancelCountMax=2;
        } else if (uct.depthMax==3) {
          uct.cancelCountMax=6;
        } else if (uct.depthMax==4) {
          uct.cancelCountMax=10;
        } else if (uct.depthMax==5) {
          uct.cancelCountMax=20;
        } else {
          uct.cancelCountMax=40;
        }
      } else {
        uct.cancelCountMax=100000;
      }
    }
    simulator.Participants = new player[5];
    for (int p=1; p<5; p++) {
      simulator.Participants[p] = new player(p, "random", brain.Random);
    }
    for (int j=0; j<=25; j++) {
      simulator.mainBoard.sv[j]=0;
      simulator.mainBoard.sv2[j]=0;
    }
    for (int i=0; i<25; i++) {
      simulator.mainBoard.s[i].col = simulatorStartBoard.get(simulator.StartBoardId).theArray[i];
      simulator.mainBoard.s[i].marked = 0;
    }
    simulator.nextPlayer = simulatorStartBoard.get(simulator.StartBoardId).nextPlayer;
    simulator.subjectPlayer = simulator.nextPlayer;
    nextPlayer=simulator.Participants[simulator.nextPlayer];
    simulator.mainBoard.copyBoardToSub(nextPlayer.myBoard);
    //int answer = uctMctsStartingJoseki(nextPlayer);
    //if (answer!=-1) {
    //  simulator.mainBoard.sv[answer]=1;
    //  if(answer<25){
    //    simulator.mainBoard.s[answer].marked=1;
    //  }
    //  simulationManager=sP.GameEnd;
    //  simulator.mainBoard.uctMctsSimulatorDisplay();
    //  showReturnButton();
    //  showScreenCapture();
    //} else
    {
      int answer = uctMctsBrainPreparation(nextPlayer);
      if (answer==-1) {
        simulationManager=sP.GameEnd;
      } else {
        answer = uctMctsBrainFirstSimulation(nextPlayer);
        if (answer!=-1) {
          uctNode nd = uct.rootNode.children.get(0);
          simulator.mainBoard.sv[answer]=nd.wa[nextPlayer.position] / nd.na;
          simulator.mainBoard.sv2[answer]=nd.pa[nextPlayer.position] / nd.na;
          simulator.mainBoard.s[answer].marked=1;
          simulationManager=sP.GameEnd;
          simulator.mainBoard.uctMctsSimulatorDisplay();
          showReturnButton();
          showScreenCapture();
        } else {
          println("uct ", uct.expandThreshold, uct.terminateThreshold, uct.depthMax, uct.cancelCountMax);
          uct.simulationTag=10000;
          simulationManager=sP.setStartBoard;
        }
      }
    }
  } else if (simulationManager==sP.setStartBoard) {
    nextPlayer=simulator.Participants[simulator.nextPlayer];
    int answer=-1;
    answer = uctMctsMainLoop(nextPlayer);
    // 1000回に1回、svにデータを埋める。

    if (uct.rootNode.attackChanceNode==false) {
      for (uctNode nd : uct.rootNode.children) {
        int k = nd.move;//たぶん、kは0～２５
        if (0<=k && k<=25) {
          simulator.mainBoard.sv[k] = nd.wa[nextPlayer.position] / nd.na;
          simulator.mainBoard.sv2[k] = nd.pa[nextPlayer.position] / nd.na;
          if (k<25) {
            simulator.mainBoard.s[k].marked = 1;
          }
        }
      }
    } else {
    }
    simulator.mainBoard.simulatorNumber=nextPlayer.myBoard.simulatorNumber;
    showMcts(nextPlayer);
    if (answer!=-1) {
      simulationManager=sP.GameEnd;
    }
  } else if (simulationManager==sP.GameEnd) {
    ;
  }
}

void showMcts(player nextPlayer) {
  uct.prize.getPrize3FromNodeList(nextPlayer.position, uct.rootNode.children);
  String[] message=new String[5];
  prize localPrize=new prize();
  uctNode nd1=null, nd2=null, nd3=null, nd4=null;
  //float maxWinrate=0;
  nd1 = uct.prize.getMove(1);
  if (nd1!=null) {
    for (int p2=1; p2<=4; p2++) {
      if (nd1.children!=null && nd1.children.size()>0) {
        localPrize.getBPrize1FromNodeList(p2, nd1.children);
        nd2 = localPrize.getMove(1);
        if (nd2==null) {
          message[p2]=nd1.id;
        } else if (nd2.children!=null && nd2.children.size()>0) {
          localPrize.getBXPrize1FromNodeList(nd2.children);
          nd3 = localPrize.getMove(1);
          if (nd3==null) {
            message[p2] = nd2.id;
          } else if (nd3.children!=null && nd3.children.size()>0) {
            localPrize.getBXPrize1FromNodeList(nd3.children);
            nd4 = localPrize.getMove(1);
            message[p2] = nd4.id;
          } else {
            message[p2] = nd3.id;
          }
        } else {
          message[p2]=nd2.id;
        }
      } else {
        message[p2]=nd1.id;
      }
    }

    simulator.mainBoard.uctMctsSimulatorDisplay();// UCTディスプレイ
    textAlign(LEFT, CENTER);
    fill(0);
    if (!simulator.mainBoard.attackChanceP) {
      text(1.0*simulator.mainBoard.sv[25], utils.mainL, utils.mainU-utils.fontSize);
      text(1.0*simulator.mainBoard.sv2[25], utils.mainL+utils.fontSize*3, utils.mainU-utils.fontSize);
    }
    for (int p=1; p<=4; p++) {
      text(message[p], utils.unitSize/2, utils.subU+utils.vStep*(p-1));
    }
    showReturnButton();
    showScreenCapture();
  }
}

void mousePreesedSimulator() {
  if (buttonReturnToMenu.mouseOn()) {//　メニューに戻る、がクリックされたとき
    displayManager = dP.onContents;
    managerPhase=mP.GameStart;
    return;
  }
  if (buttonSaveScreenShot.mouseOn()) {//　スクショを取る、がクリックされたとき
    selectOutput("スクリーンショットを保存", "saveScreenShotSelected");
    //save("screenshot.png");
  }
  if (buttonMainBoard.mouseOn()) {// ボード画面がクリックされたとき（勝率の主語を変更するとき）
    //画面上の勝率・パネル数の期待値について、「誰にとっての勝率・期待値」なのかを変更できるようにする。
    if (gameOptions.get("SimMethod") == 1) {//[fullRandom]
      if (simulator.mainBoard.attackChanceP()==false) {
        if (simulator.subjectPlayer<4) simulator.subjectPlayer++;
        else simulator.subjectPlayer = 1;
        //println(simulator.subjectPlayer);
        for (uctNode nd : simulator.rootNode.children) {
          simulator.mainBoard.setSubjectPlayerColor(simulator.subjectPlayer);
          simulator.mainBoard.sv[nd.move] = nd.wa[simulator.subjectPlayer]/nd.na;//　
          simulator.mainBoard.sv2[nd.move] = nd.pa[simulator.subjectPlayer]/nd.na;//
        }
      }
    } else if (gameOptions.get("SimMethod") == 2 ) {//[UCB]
      println("under construction");
    } else {//gameOptions.get("SimMethod") == 3// [UCT]
      ;  
    }
  }
  if (gameOptions.get("SimMethod")==1) {// random MC
    if (simulator.mainBoard.attackChanceP()) {//アタックチャンス次の右下部分のスクロール対応
      if (buttonPrevSV.mouseOn()) {
        int loopSize=simulator.rootNode.children.size();
        attackChanceCursor = (attackChanceCursor+loopSize-1)%loopSize;
        simulator.mainBoard.randomMcSimulatorRegularDisplay();
        prize prize=new prize();
        prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.children);
        displayBestStats(prize);
        displayAllStats(attackChanceCursor, simulator.nextPlayer);
      } else if (buttonNextSV.mouseOn()) {
        int loopSize=simulator.rootNode.children.size();
        attackChanceCursor = (attackChanceCursor+1)%loopSize;
        simulator.mainBoard.randomMcSimulatorRegularDisplay();
        prize prize=new prize();
        prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.children);
        displayBestStats(prize);
        displayAllStats(attackChanceCursor, simulator.nextPlayer);
      }
    }
  }
}

void saveScreenShotSelected(File selection) {
  if (selection == null) {
    println("ファイルが選択されませんでした。");
  } else {
    filePath = selection.getAbsolutePath();
    if (differentExt(filePath, ".png")==true) {
      filePath += ".png";
    }
    println("選択されたファイルパス: " + filePath);
    save(filePath);
  }
}
