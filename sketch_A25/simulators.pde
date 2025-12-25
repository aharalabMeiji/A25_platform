//// simulate line 2651

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

winPoints playSimulatorToEnd(board sub, player[] _participants, int nextplayer) {//
  // TODO アタックチャンスの判定と処理
  // n(0)=4 -> AC_flag==false -> アタックチャンス, AC_flag=true
  //
  int remaining=0;
  for (int i=0; i<25; i++) {
    if (sub.s[i].col==0 || sub.s[i].col==5) remaining ++;// 黄色(5)パネルは空欄あつかい
  }
  //println("playSimulatorToEnd:残り枚数は"+remaining);
  //int count=0;
  if (remaining>0) {
    //println("playSimulatorToEnd:ループ開始");
    do {
      int simulatorNextPlayer;
      if (nextplayer==0) {// 次の手番をランダムに定める
        simulatorNextPlayer = int(random(4))+1;
      } else {// 次の手番をnextplayerによって定め、以降はランダムに定める
        simulatorNextPlayer = nextplayer;
        nextplayer=0;
      }
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

void displayBestStats(prize prize, float yy) {
  textAlign(LEFT, CENTER);
  textSize(utils.fontSize);
  //fill(255, 0, 0);
  //text("BEST 3", utils.subL, utils.subU+utils.fontSize*1.5);
  fill(0);
  for (int pr=1; pr<=3; pr++) {
    int move = prize.getMove(pr).move;
    float winrate = prize.getWinrate(pr);
    float panels = prize.getPanels(pr);
    String msg = "("+(move%25+1)+"-"+(int(move/25)+1)+") "+nf(winrate, 1, 3)+" : "+ nf(panels, 2, 3);
    text(msg, utils.subL, yy+utils.fontSize*1.5*(pr-1) );
  }
}

void displayAllStats(int cursor, int player) {
  textAlign(LEFT, CENTER);
  fill(255, 0, 0);
  text("ALL(click to slide)", utils.unitSize/2, utils.subU);
  fill(0);
  int loopSize=simulator.rootNode.legalMoves.size();
  int prev= (cursor+loopSize-1)%loopSize;
  uctNode tmpNd = simulator.rootNode.legalMoves.get(prev);
  int move=tmpNd.move;
  float winrate=tmpNd.wa[player]/tmpNd.na;
  float panels=tmpNd.pa[player]/tmpNd.na;
  String msg = "("+(move%25+1)+"-"+(int(move/25)+1)+") "+nf(winrate, 1, 3)+" : "+ nf(panels, 2, 3);
  text(msg, utils.unitSize/2, utils.subU+utils.fontSize*1.5);
  buttonPrevSV.setLT(utils.unitSize/2, utils.subU+utils.fontSize*1.5, msg);
  int now = cursor%loopSize;
  tmpNd = simulator.rootNode.legalMoves.get(now);
  move=tmpNd.move;
  winrate=tmpNd.wa[player]/tmpNd.na;
  panels=tmpNd.pa[player]/tmpNd.na;
  msg = "("+(move%25+1)+"-"+(int(move/25)+1)+") "+nf(winrate, 1, 3)+" : "+ nf(panels, 2, 3);
  text(msg, utils.unitSize/2, utils.subU+utils.fontSize*3);
  int next= (cursor+1)%loopSize;
  tmpNd = simulator.rootNode.legalMoves.get(next);
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
    ///////////////////////////////////////////// シミュレーション開始。共通の準備
    startTime=millis();
    simulator.Participants = new player[5];
    simulator.rootNode = new uctNode();
    simulator.rootNode.legalMoves = new ArrayList<uctNode>();
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

    // 着手可能点を計算しておく。
    simulator.mainBoard.buildVP(simulator.nextPlayer);// 0~24の話
    //数字の色
    simulator.mainBoard.svColor = simulator.nextPlayer;
    simulator.mainBoard.simulatorNumber=0;
    simulationManager=sP.setStartBoard;
  } else if (simulationManager == sP.setStartBoard) {
    // 問題がアタックチャンス問題のときには、別処理にする。
    if (simulator.mainBoard.attackChanceP()) {
      // ///////////////////////////////////////////////////////////////////問題がアタックチャンス問題のときの「準備」
      // vpの初期化と、svの初期化
      simulator.mainBoard.attackChanceP=true;
      simulator.mainBoard.buildVP(simulator.nextPlayer);
      simulator.rootNode.legalMoves.clear();
      attackChanceCursor=1;
      for (int j=0; j<25; j++) { //加えるほう
        for (int i=0; i<25; i++) { //黄色にするほう
          int k = i*25+j;//これがアタックチャンスのmove番号
          if (simulator.mainBoard.vp[j]>0 && (simulator.mainBoard.s[i].col>=1 && simulator.mainBoard.s[i].col<=4)) {
            attackChanceVP[k]=1;
            uctNode newNode = new uctNode();
            newNode.setItem(simulator.nextPlayer, k);
            //newNodeに盤面情報を入れるならここ
            simulator.rootNode.legalMoves.add(newNode);
            newNode.parent = simulator.rootNode;
          } else if (simulator.mainBoard.vp[j]>0 && i==j) {//　ルール上これも許される。
            attackChanceVP[k]=1;
            uctNode newNode = new uctNode();
            newNode.setItem(simulator.nextPlayer, k);
            //newNodeに盤面情報を入れるならここ
            simulator.rootNode.legalMoves.add(newNode);
            newNode.parent = simulator.rootNode;
          } else {
            attackChanceVP[k]=0;
          }
        }
      }
      simulationManager = sP.runMC;
    } else {
      // ///////////////////////////////////////////////////////////////////問題がアタックチャンスでないときの「準備」
      simulator.mainBoard.attackChanceP=false;
      simulator.mainBoard.buildVP(simulator.nextPlayer);
      simulator.rootNode.legalMoves.clear();
      for (int k=0; k<25; k++) {
        if (simulator.mainBoard.vp[k]>0 ) {
          uctNode newNode = new uctNode();
          newNode.setItem(simulator.nextPlayer, k);
          //newNodeに盤面情報を入れるならここ
          simulator.rootNode.legalMoves.add(newNode);
          newNode.parent = simulator.rootNode;
        }
      }
      uctNode newNode = new uctNode();
      newNode.setItem(simulator.nextPlayer, 25);
      //newNodeに盤面情報を入れるならここ
      simulator.rootNode.legalMoves.add(newNode);
      newNode.parent = simulator.rootNode;
      simulationManager = sP.runMC;
    }
  } else if (simulationManager == sP.runMC) {
    if (simulator.mainBoard.attackChanceP()) {
      // ///////////////////////////////////////////////////////////////////問題がアタックチャンス問題のときの「ループ」
      //int loopLen = simulator.rootNode.legalMoves.size();
      for (uctNode nd : simulator.rootNode.legalMoves) {
        for (int i=0; i<25; i++) {// 問題画面をsimulatorSubにコピー
          simulator.subBoard.s[i].col = simulator.mainBoard.s[i].col;
        }
        int k = nd.move;
        int j = k%25;
        int i = int(k/25);
        simulator.subBoard.move(simulator.nextPlayer, j);// 1手着手する
        simulator.subBoard.setCol(i, 5);// 黄色を置く
        winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants, 0);//そこから最後までシミュレーションを行う。
        nd.na ++;
        for (int p=1; p<=4; p++) {
          nd.wa[p] += wp.points[p];// 総勝ち数
          nd.pa[p] += wp.panels[p];// 最終パネル枚数の総数
        }
      }

      simulator.mainBoard.simulatorNumber ++;//シミュレーション回数（分母）
      //表示データの更新

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
      if (simulator.mainBoard.simulatorNumber%500==0) {
        simulator.mainBoard.display(10);
        prize prize=new prize();
        prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.legalMoves);
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

        displayBestStats(prize, utils.subU+utils.fontSize*1.5);
        displayAllStats(attackChanceCursor, simulator.nextPlayer);
        showReturnButton();
        showScreenCapture();
      }
    } else {// 通常時
      ///////////////////////////////////////////////////////////////////通常営業の「ループ」
      for (uctNode nd : simulator.rootNode.legalMoves) {
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
          winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants, 0);//そこから最後までシミュレーションを行う。
          nd.na ++;
          for (int p=1; p<=4; p++) {
            nd.wa[p] += wp.points[p];
            nd.pa[p] += wp.panels[p];
          }
          //println(nd.move,nd.wa[1], nd.na);
          //画面表示指示
          simulator.mainBoard.sv[nd.move] = nd.wa[simulator.nextPlayer]/nd.na;//　その着手点はちょっと優秀ということになる。
          simulator.mainBoard.sv2[nd.move] = nd.pa[simulator.nextPlayer]/nd.na;// 最終パネル数の累積
          simulator.mainBoard.s[nd.move].marked=simulator.nextPlayer;// svを表示する意味
        } else {// あえて着手しなかった場合
          for (int k=0; k<25; k++) {
            nd.bd[k] = simulator.subBoard.s[k].col;
          }
          winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants, 0);//そこから最後までシミュレーションを行う。
          nd.na ++;
          for (int p=1; p<=4; p++) {
            nd.wa[p] += wp.points[p];
            nd.pa[p] += wp.panels[p];
          }
          simulator.mainBoard.sv[nd.move] = nd.wa[simulator.nextPlayer]/nd.na;//　その着手点はちょっと優秀ということになる。
          simulator.mainBoard.sv2[nd.move] = nd.pa[simulator.nextPlayer]/nd.na;// 最終パネル数の累積
        }
      }
      simulator.mainBoard.simulatorNumber ++;//シミュレーション回数（分母）
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
      if (simulator.mainBoard.simulatorNumber%500==0) {
        prize prize=new prize();
        prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.legalMoves);
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
        simulator.mainBoard.display(10);
        showReturnButton();
        showScreenCapture();
      }
    }
    //print(",");
  } else if (simulationManager==sP.GameEnd) {
    ;//println(millis()-startTime);
  }
}


void UCB1(ucbClass ucb) {
  // UCB1手読み
  if (simulationManager==sP.GameStart) {
    // シミュレーション開始
    startTime=millis();
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
    //数字の色
    simulator.mainBoard.svColor = simulator.nextPlayer;

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
      ucb.rootNode.legalMoves=new ArrayList<uctNode>();
      for (int k=0; k<625; k++) {//アタックチャンス時の合法手のノードを追加する
        if (attackChanceVP[k]>0) {
          uctNode newNode = new uctNode();
          ucb.rootNode.legalMoves.add(newNode);
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
          //newNode.childR = newNode.childG = newNode.childW = newNode.childB = null;
          //とりあえず、最初の１シミュレーションはここで行うのがよさそう。
          winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants, 0);//そこから最後までシミュレーションを行う。
          simulator.mainBoard.simulatorNumber ++;
          newNode.na=1;//　初回につき代入、以後+=
          for (int p=1; p<5; p++) {
            newNode.wa[p] = wp.points[p];//　初回につき代入、以後+=
          }
          //simulator.mainBoard.s[j].marked=1;// この行、様子をみる。実際には、盤面下部に優良データを表示する方針
        }
      }
    } else {// 通常時の１世代めの追加 // UCB1
      simulator.mainBoard.attackChanceP=false;
      simulator.mainBoard.buildVP(simulator.nextPlayer);
      simulator.mainBoard.simulatorNumber=0;
      ucb.rootNode.legalMoves=new ArrayList<uctNode>();
      for (int j=0; j<25; j++) {
        if (simulator.mainBoard.vp[j]>0) {
          uctNode newNode = new uctNode();
          ucb.rootNode.legalMoves.add(newNode);
          ucb.fullNodes.add(newNode);
          newNode.setItem(simulator.nextPlayer, j);
          simulator.mainBoard.copyBoardToSub(simulator.subBoard);
          simulator.subBoard.move(simulator.nextPlayer, j);
          for (int k=0; k<25; k++) {
            newNode.bd[k] = simulator.subBoard.s[k].col;
          }
          newNode.parent = ucb.rootNode;
          //とりあえず、最初の１シミュレーションはここで行うのがよさそう。
          winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants, 0);//そこから最後までシミュレーションを行う。
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
      uctNode newNode = new uctNode();
      ucb.rootNode.legalMoves.add(newNode);
      ucb.fullNodes.add(newNode);
      newNode.setItem(simulator.nextPlayer, 25);
      //
      simulator.mainBoard.copyBoardToSub(simulator.subBoard);
      for (int k=0; k<25; k++) {
        newNode.bd[k] = simulator.subBoard.s[k].col;
      }
      newNode.parent = ucb.rootNode;
      //最初の１シミュレーション
      winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants, 0);//そこから最後までシミュレーションを行う。
      simulator.mainBoard.simulatorNumber ++;
      newNode.na=1;//　初回につき代入、以後+=
      for (int p=1; p<5; p++) {
        newNode.wa[p] = wp.points[p];//　初回につき代入、以後+=
      }
    }
    simulationManager=sP.setStartBoard;
  } else if (simulationManager==sP.setStartBoard) {// UCB1ループ部分
    if (simulator.mainBoard.attackChanceP()) {//アタックチャンスの場合// UCB1ループ部分
      float maxUct=-100;
      uctNode maxNd=null;
      for (uctNode nd : ucb.fullNodes) {
        float newUct = nd.UCTwp(nd.player, simulator.mainBoard.simulatorNumber) ;
        if (newUct>maxUct) {
          maxUct=newUct;
          maxNd=nd;
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
        winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants, 0);//そこから最後までシミュレーションを行う。
        simulator.mainBoard.simulatorNumber ++;
        maxNd.na ++ ;//
        for (int p=1; p<5; p++) {
          maxNd.wa[p] += wp.points[p];//
          maxNd.pa[p] += wp.panels[p];//
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
      if (simulator.mainBoard.simulatorNumber%500==0) {
        // 間歇的に表示を更新する。
        simulator.mainBoard.display(11);// Ucb1 ディスプレイ
        prize prize=new prize();
        prize.getPrize3FromNodeList(simulator.nextPlayer, ucb.rootNode.legalMoves);
        displayBestStats(prize, utils.subU+utils.fontSize*1.5);
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
    } else {//通常の場合// UCB1ループ部分
      float maxUct=-100;
      uctNode maxNd=null;
      for (uctNode nd : ucb.fullNodes) {
        float newUct = nd.UCTwp(nd.player, simulator.mainBoard.simulatorNumber) ;
        if (newUct>maxUct) {
          maxUct=newUct;
          maxNd=nd;
        }
      }
      if (maxNd==null) {
        simulationManager=sP.GameEnd;
      } else {
        //この枝のデータを更新する。
        for (int k=0; k<25; k++) {//ノードの盤面をsimulator.subBoardへコピ－
          simulator.subBoard.s[k].col = maxNd.bd[k] ;
        }
        winPoints wp = playSimulatorToEnd(simulator.subBoard, simulator.Participants, 0);//そこから最後までシミュレーションを行う。
        simulator.mainBoard.simulatorNumber ++;
        maxNd.na ++ ;//　
        for (int p=1; p<5; p++) {
          maxNd.wa[p] += wp.points[p];//
          maxNd.pa[p] += wp.panels[p];//
        }
        // 表示データの更新
        simulator.mainBoard.sv[maxNd.move] = maxNd.wa[maxNd.player]/maxNd.na;
        simulator.mainBoard.sv2[maxNd.move] = maxNd.pa[maxNd.player]/maxNd.na;
        //maxNd.UCTwp(maxNd.player, simulator.mainBoard.simulatorNumber) ;
        if (gameOptions.get("SimTimes")==11) {// 10sec
          if (millis()-startTime>=10000) {
            simulationManager=sP.GameEnd;
          }
        } else if (gameOptions.get("SimTimes")==12) {// 60sec
          if (millis()-startTime>=60000) {
            simulationManager=sP.GameEnd;
          }
        } else {/// gameOptions.get("SimTimes")==13
          if (simulator.mainBoard.simulatorNumber%1000==0) {//収束しているかを判定する
            winrateConvergents=false;
            panelsConvergent=false;
            prevWinrate1=best1Wr;
            prevWinrate2=best2Wr;
            prevPanels1 = best1Pr;
            prevPanels2=best2Pr;
            best1Wr=0;
            best2Wr=0;
            best1Pr=0;
            best2Pr=0;
            for (int kk=0; kk<=25; kk++) {
              if (simulator.mainBoard.sv[kk]>0 || simulator.mainBoard.sv2[kk]>0) {
                if (simulator.mainBoard.sv[kk]>best1Wr ||(simulator.mainBoard.sv[kk]==best1Wr && simulator.mainBoard.sv2[kk]>best1Pr)) {
                  best2Wr = best1Wr;
                  best2Pr=best2Wr;
                  best1Wr = simulator.mainBoard.sv[kk];
                  best1Pr = simulator.mainBoard.sv2[kk];
                } else
                  if (simulator.mainBoard.sv[kk]>best2Wr ||(simulator.mainBoard.sv[kk]==best2Wr && simulator.mainBoard.sv2[kk]>best2Pr)) {
                    best2Wr = simulator.mainBoard.sv[kk];
                    best2Pr = simulator.mainBoard.sv2[kk];
                  }
              }
            }
            //println(prevWinrate1,best1Wr,prevWinrate2,best2Wr);
            if (abs(prevWinrate1-best1Wr)<0.0005 && abs(prevWinrate2-best2Wr)<0.0005 )
              winrateConvergents=true;
            else winrateConvergents=false;
            if (abs(prevPanels1-best1Pr)<0.005 && abs(prevPanels2-best2Pr)<0.005 )
              panelsConvergent=true;
            else panelsConvergent=false;
            if (winrateConvergents && panelsConvergent) {
              simulationManager=sP.GameEnd;
            }
          }
        }
      }
      if (simulator.mainBoard.simulatorNumber%500==0) {
        simulator.mainBoard.display(11);// Uct1 ディスプレイ
        showReturnButton();
        showScreenCapture();
      }
    }
  } else if (simulationManager==sP.GameEnd) {
    ;
  }
  //println(millis()-startTime);
  //startTime=millis();
}


void UCT1() {
  int SimTimes = gameOptions.get("SimTimes");
  if (simulationManager==sP.GameStart) {
    startTime=millis();
    uct.chanceNodeOn=false;
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
      uct.terminateThreshold = uct.expandThreshold*10000000;
      uct.depthMax=5;
      uct.cancelCountMax=20;
    } else if (SimTimes == 24) {
      uct.expandThreshold=10;
      uct.terminateThreshold = uct.expandThreshold*10000000;
      uct.depthMax=5;
      uct.cancelCountMax=100000;
    } else if (SimTimes == 25) {
      uct.expandThreshold=gameOptions.get("expandThreshold");
      //if (gameOptions.get("terminateThreshold")==4) {
      //  uct.terminateThreshold = uct.expandThreshold*10000;
      //} else if (gameOptions.get("terminateThreshold")==5) {
      //  uct.terminateThreshold = uct.expandThreshold*100000;
      //} else if (gameOptions.get("terminateThreshold")==6) {
      //  uct.terminateThreshold = uct.expandThreshold*1000000;
      //} else {
      //  uct.terminateThreshold = uct.expandThreshold*10000000;
      //}
      uct.terminateThreshold = uct.expandThreshold*1000000;
      uct.depthMax=gameOptions.get("depthMax");
      if (gameOptions.get("wCancel")==1) {
        uct.cancelCountMax=5;
      } else if (gameOptions.get("wCancel")==3) {
        uct.cancelCountMax=10;
      } else if (gameOptions.get("wCancel")==4) {
        uct.cancelCountMax=20;
      } else if (gameOptions.get("wCancel")==5) {
        uct.cancelCountMax=50;
      } else if (gameOptions.get("wCancel")==6) {
        uct.cancelCountMax=100;
      } else if (gameOptions.get("wCancel")==2) {
        uct.cancelCountMax=100000;
      }
    }
    uct.chanceNodeOn=(gameOptions.get("chanceNodeOn")==1);
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
    uct.nextPlayer=simulator.Participants[simulator.nextPlayer];
    simulator.mainBoard.copyBoardToSub(uct.nextPlayer.myBoard);
    //int answer = uctMctsStartingJoseki(nextPlayer);
    //if (answer!=-1) {
    //  simulator.mainBoard.sv[answer]=1;
    //  if(answer<25){
    //    simulator.mainBoard.s[answer].marked=1;
    //  }
    //  simulationManager=sP.GameEnd;
    //  simulator.mainBoard.display(12);
    //  showReturnButton();
    //  showScreenCapture();
    //} else

    int answer = uctMctsBrainPreparation(uct.nextPlayer);
    if (answer==-1) {
      simulationManager=sP.GameEnd;
    } else {
      answer = uctMctsBrainFirstSimulation(uct.nextPlayer);
      if (answer!=-1) {
        uctNode nd = uct.rootNode.legalMoves.get(0);
        simulator.mainBoard.sv[answer]=nd.wa[uct.nextPlayer.position] / nd.na;
        simulator.mainBoard.sv2[answer]=nd.pa[uct.nextPlayer.position] / nd.na;
        simulator.mainBoard.s[answer].marked=1;
        simulationManager=sP.GameEnd;
        simulator.mainBoard.display(12);
        showReturnButton();
        showScreenCapture();
      } else {
        if (uct.cancelCountMax>1000) {
          println("uct:E"+uct.expandThreshold+"D"+uct.depthMax+"woC");//+"T"+uct.terminateThreshold
        } else {
          println("uct:E"+uct.expandThreshold+"D"+uct.depthMax+"C"+uct.cancelCountMax);
        }
        uct.simulationTag=10000;
        simulationManager=sP.setStartBoard;
      }
    }
    uct.nnNextPlayer = uct.nextPlayer.position;
  } else if (simulationManager==sP.setStartBoard) {
    uct.nextPlayer=simulator.Participants[simulator.nextPlayer];
    int answer=-1;
    answer = uctMctsMainLoop(uct.nextPlayer);
    // 1000回に1回、svにデータを埋める。
    //if (uct.rootNode.attackChanceNode==false) {
    if (uct.nextPlayer.myBoard.attackChanceP==false) {
      for (uctNode nd : uct.rootNode.legalMoves) {
        int k = nd.move;//たぶん、kは0～２５
        if (0<=k && k<=25) {
          simulator.mainBoard.sv[k] = nd.wa[uct.nextPlayer.position] / nd.na;
          simulator.mainBoard.sv2[k] = nd.pa[uct.nextPlayer.position] / nd.na;
          if (k<25) {
            simulator.mainBoard.s[k].marked = 1;
          }
        }
      }
    } else {
      // アタックチャンスのときには、sv,sv2を使わずに表示する。
    }
    simulator.mainBoard.simulatorNumber=uct.nextPlayer.myBoard.simulatorNumber;
    showMcts(uct.nextPlayer);//
    //printlnAllNodes(uct.rootNode, 2);//
    if (answer!=-1) {
      simulationManager=sP.GameEnd;
    }
  } else if (simulationManager==sP.GameEnd) {
    ;
  }
}

void printlnAllNodes(uctNode nd, int p) {
  //if (nd.thisIsChanceNode==false){
  println(""+nd.id+":("+nf(nd.wa[p], 1, 3)+")["+nf(nd.wa[p]/nd.na, 1, 3)+"]:("+nd.na+")");
  //}
  if (! nd.totalChildNullP()) {
    for (uctNode nd0 : nd.childR) {
      printlnAllNodes(nd0, p);
    }
    for (uctNode nd0 : nd.childG) {
      printlnAllNodes(nd0, p);
    }
    for (uctNode nd0 : nd.childW) {
      printlnAllNodes(nd0, p);
    }
    for (uctNode nd0 : nd.childB) {
      printlnAllNodes(nd0, p);
    }
  }
}

void showMcts(player nextPlayer) {
  uct.prize.getPrize1FromNodeList(nextPlayer.position, uct.rootNode.legalMoves); //<>//
  String[] message=new String[5];
  prize localPrize=new prize();
  uctNode nd1=null, nd2=null, nd3=null;
  //uct.nnNextPlayer=1;
  nd1 = uct.prize.getMove(1);// トップ合法手
  if (nd1==null)  return;// ルートに子ノードがなければヤメ
  for (int p2=1; p2<=4; p2++) {// nNext = p2;
    if (nd1.totalChildNullP()==false && nd1.totalChildSize()>0) {
      switch(p2){
        case 1: localPrize.getPrize1FromNodeList(1, nd1.childR); break;
        case 2: localPrize.getPrize1FromNodeList(2, nd1.childG); break;
        case 3: localPrize.getPrize1FromNodeList(3, nd1.childW); break;
        case 4: localPrize.getPrize1FromNodeList(4, nd1.childB); break;
      }
      nd2 = localPrize.getMove(1);
      if (nd2==null) {
        message[p2]=nd1.id;
      } else if (nd2.totalChildNullP()==false && nd2.totalChildSize()>0) {
        switch(uct.nnNextPlayer){
          case 1: localPrize.getPrize1FromNodeList(1, nd2.childR); break;
          case 2: localPrize.getPrize1FromNodeList(2, nd2.childG); break;
          case 3: localPrize.getPrize1FromNodeList(3, nd2.childW); break;
          case 4: localPrize.getPrize1FromNodeList(4, nd2.childB); break;
        }
        nd3 = localPrize.getMove(1);
        if (nd3==null) {
          message[p2] = nd2.id+" ("+nf(nd2.wa[p2]/nd2.na,1,3)+":"+nf(nd2.pa[p2]/nd2.na,2,3)+")";
        } else {
          message[p2] = nd3.id+" ("+nf(nd3.wa[uct.nnNextPlayer]/nd3.na,1,3)+":"+nf(nd3.pa[uct.nnNextPlayer]/nd3.na,2,3)+")";
        }
      } else {
        message[p2]=nd2.id+": ("+nf(nd2.wa[p2]/nd2.na,1,3)+":"+nf(nd2.pa[p2]/nd2.na,2,3)+")";
      }
    } else {
      message[p2]=nd1.id;
    }
  }
  simulator.mainBoard.display(12);// UCTディスプレイ
  textAlign(LEFT, CENTER);
  fill(0);
  //if (!simulator.mainBoard.attackChanceP){
  if (nextPlayer.myBoard.attackChanceP==false) {
    text(1.0*simulator.mainBoard.sv[25], utils.mainL, utils.mainU-utils.fontSize);
    text(1.0*simulator.mainBoard.sv2[25], utils.mainL+utils.fontSize*3, utils.mainU-utils.fontSize);
  } else {
    prize prize=new prize();
    prize.getPrize3FromNodeList(nextPlayer.position, uct.rootNode.legalMoves);
    displayBestStats(prize, utils.subU+utils.fontSize*3);
  }
  for (int p=1; p<=4; p++) {
    fill(0);
    textSize(utils.fontSize);
    textAlign(LEFT, CENTER);
    String buttonNNNextText=message[p];
    text(buttonNNNextText, utils.unitSize/2, utils.subU+utils.vStep*(p-1));
    buttonNNNext.left = utils.unitSize/2;
    buttonNNNext.top = utils.subU+utils.vStep*1.5;
    buttonNNNext.wid = textWidth(buttonNNNextText)+5;
    buttonNNNext.hei=utils.vStep*4;
  }
  showReturnButton();
  showScreenCapture();
  showSaveTree();
}

void mousePreesedSimulator() {
  if (buttonReturnToMenu.mouseOn()) {//　メニューに戻る、をクリックされたとき
    displayManager = dP.onContents;
    managerPhase=mP.GameStart;
    return;
  }
  if (buttonSaveScreenShot.mouseOn()) {//　スクショ、をクリックされたとき
    selectOutput("スクリーンショットを保存", "saveScreenShotSelected");
    //save("screenshot.png");
  }
  if (buttonSaveTree.mouseOn()) {//　ゲーム木保存、をクリックされたとき
    selectOutput("ゲーム木を保存", "saveTreeSelected");
    // uct.SaveGameTree(simulator.nextPlayer);
  }
  if (buttonNNNext.mouseOn()){// ３手先のデータ、をクリックされたとき    
    //println("buttonNNNext.mouseOn()");
    uct.nnNextPlayer ++;
    if (uct.nnNextPlayer==5){
      uct.nnNextPlayer = 1;
    }
    showMcts(uct.nextPlayer);
  }
  if (gameOptions.get("SimMethod")==1) {
    if (buttonPrevSV.mouseOn()) {
      int loopSize=simulator.rootNode.legalMoves.size();
      attackChanceCursor = (attackChanceCursor+loopSize-1)%loopSize;
      simulator.mainBoard.display(10);
      prize prize=new prize();
      prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.legalMoves);
      displayBestStats(prize, utils.subU+utils.fontSize*1.5);
      displayAllStats(attackChanceCursor, simulator.nextPlayer);
      showReturnButton();
      showScreenCapture();
      showSaveTree();
    } else if (buttonNextSV.mouseOn()) {
      int loopSize=simulator.rootNode.legalMoves.size();
      attackChanceCursor = (attackChanceCursor+1)%loopSize;
      simulator.mainBoard.display(10);
      prize prize=new prize();
      prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.legalMoves);
      displayBestStats(prize, utils.subU+utils.fontSize*1.5);
      displayAllStats(attackChanceCursor, simulator.nextPlayer);
      showReturnButton();
      showScreenCapture();
      showSaveTree();
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

void saveTreeSelected(File selection) {
  if (selection == null) {
    println("ファイルが選択されませんでした。");
  } else {
    filePath = selection.getAbsolutePath();
    if (differentExt(filePath, ".txt")==true) {
      filePath += ".txt";
    }
    println("選択されたファイルパス: " + filePath);
    saveGameTree(filePath);
  }
}

PrintWriter outputGameTree;
void saveGameTree(String filepath) {
  // 出力用ファイルを作成
  outputGameTree = createWriter(filepath);
  for (uctNode nd : uct.rootNode.legalMoves) {
    fileOutputAllWaPa(nd);
  }
  // 書き込み終了時は必ず close()
  outputGameTree.close();
}

void fileOutputAllWaPa(uctNode nd) {
  if ( nd.depth<=3) {
    outputGameTree.println(""+nd.id+",("+nf(nd.wa[1]/nd.na, 1, 6)+","+nf(nd.pa[1]/nd.na, 2, 6)+")"+
      "("+nf(nd.wa[2]/nd.na, 1, 6)+","+nf(nd.pa[2]/nd.na, 2, 6)+")"+
      "("+nf(nd.wa[3]/nd.na, 1, 6)+","+nf(nd.pa[3]/nd.na, 2, 6)+")"+
      "("+nf(nd.wa[4]/nd.na, 1, 6)+","+nf(nd.pa[4]/nd.na, 2, 6)+")");
  }
  if (nd.childR!=null && nd.childR.size()>0) {
    for (uctNode nd2 : nd.childR) {
      fileOutputAllWaPa(nd2);
    }
  }
  if (nd.childG!=null && nd.childG.size()>0) {
    for (uctNode nd2 : nd.childG) {
      fileOutputAllWaPa(nd2);
    }
  }
  if (nd.childW!=null && nd.childW.size()>0) {
    for (uctNode nd2 : nd.childW) {
      fileOutputAllWaPa(nd2);
    }
  }
  if (nd.childB!=null && nd.childB.size()>0) {
    for (uctNode nd2 : nd.childB) {
      fileOutputAllWaPa(nd2);
    }
  }
}
