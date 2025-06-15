////

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
  text("BEST 3", utils.subL, utils.subU);
  fill(0);
  for (int pr=1; pr<=3; pr++) {
    int move = prize.getMove(pr).move;
    float winrate = prize.getWinrate(pr);
    float panels = prize.getPanels(pr);
    String msg = "("+(move%25+1)+"-"+(int(move/25)+1)+") "+nf(winrate, 1, 3)+" : "+ nf(panels, 2, 3);
    text(msg, utils.subL, utils.subU+utils.fontSize*1.5*pr );
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
    ///////////////////////////////////////////// シミュレーション開始。共通の準備
    startTime=millis();
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

    // 着手可能点を計算しておく。
    simulator.mainBoard.buildVP(simulator.nextPlayer);// 0~24の話
    //for (int k=0; k<625; k++) {//いらなくなる
    //  attackChanceSV[k]=0;//いらなくなる
    //  attackChanceSV2[k]=0;//いらなくなる
    //}//いらなくなる
    simulator.mainBoard.simulatorNumber=0;
    simulationManager=sP.setStartBoard;
  } else if (simulationManager == sP.setStartBoard) {
    // 問題がアタックチャンス問題のときには、別処理にする。
    if (simulator.mainBoard.attackChanceP()) {
      // ///////////////////////////////////////////////////////////////////問題がアタックチャンス問題のときの「準備」
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
      simulationManager = sP.runMC;
    } else {
      // ///////////////////////////////////////////////////////////////////問題がアタックチャンスでないときの「準備」
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
      simulationManager = sP.runMC;
    }
  } else if (simulationManager == sP.runMC) {
    if (simulator.mainBoard.attackChanceP()) {
      // ///////////////////////////////////////////////////////////////////問題がアタックチャンス問題のときの「ループ」
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
      }
    } else {// 通常時
      ///////////////////////////////////////////////////////////////////通常営業の「ループ」
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
          simulator.mainBoard.sv[nd.move] = nd.wa[simulator.nextPlayer]/nd.na;//　その着手点はちょっと優秀ということになる。
          simulator.mainBoard.sv2[nd.move] = nd.pa[simulator.nextPlayer]/nd.na;// 最終パネル数の累積
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
    simulationManager=sP.setStartBoard;
  } else if (simulationManager==sP.setStartBoard) {// UCT1ループ部分
    if (simulator.mainBoard.attackChanceP()) {//アタックチャンスの場合// UCT1ループ部分
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
        simulator.mainBoard.display(11);// Uct1 ディスプレイ
        prize prize=new prize();
        prize.getPrize3FromNodeList(simulator.nextPlayer, uct.rootNode.children);
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
    } else {//通常の場合// UCT1ループ部分
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
  player nextPlayer=null;
  int SimTimes = gameOptions.get("SimTimes");
  if (simulationManager==sP.GameStart) {
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
    nextPlayer=simulator.Participants[simulator.nextPlayer];
    simulator.mainBoard.copyBoardToSub(nextPlayer.myBoard);
    int answer = uctMctsStartingJoseki(nextPlayer);
    if (answer!=-1) {
      simulator.mainBoard.sv[answer]=1;
      simulator.mainBoard.s[answer].marked=1;
      simulationManager=sP.GameEnd;
      simulator.mainBoard.display(12);
      showReturnButton();
      showScreenCapture();
    } else {
      answer = uctMctsBrainPreparation(nextPlayer);
      if (answer==-1) {
        simulationManager=sP.GameEnd;
      } else {
        answer = uctMctsBrainFirstSimulation(500, nextPlayer);
        if (answer!=-1) {
          uctNode nd = uct.rootNode.children.get(0);
          simulator.mainBoard.sv[answer]=nd.wa[nextPlayer.position] / nd.na;
          simulator.mainBoard.sv2[answer]=nd.pa[nextPlayer.position] / nd.na;
          simulator.mainBoard.s[answer].marked=1;
          simulationManager=sP.GameEnd;
          simulator.mainBoard.display(12);
          showReturnButton();
          showScreenCapture();
        } else {
          println("uct starts");
          uct.simulationTag=10000;
          simulationManager=sP.setStartBoard;
        }
      }
    }
  } else if (simulationManager==sP.setStartBoard) {
    nextPlayer=simulator.Participants[simulator.nextPlayer];
    int answer=-1;
    if (SimTimes == 21)
      answer = uctMctsMainLoop(nextPlayer, 500, 100000, 4);//
    else if (SimTimes == 22)
      answer = uctMctsMainLoop(nextPlayer, 1000, 1000000, 4);//
    else if (SimTimes == 23)
      answer = uctMctsMainLoop(nextPlayer, 1000, 10000000, 4);//
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
  uctNode nd1, ndP;
  uctNode[] nd2 = new uctNode[5];
  uctNode[] nd3 = new uctNode[5];
  uctNode[] nd4 = new uctNode[5];
  float maxWinrate=0;
  if (uct.prize.getMove(1)!=null) {
    nd1 = uct.prize.getMove(1);
    for (int p2=1; p2<=4; p2++) {
      if (nd1.children!=null) {
        ndP = null;
        maxWinrate = 0;
        for (uctNode nd : nd1.children) {
          if (nd.player==p2) {
            if (maxWinrate < nd.wa[p2]/nd.na) {
              maxWinrate = nd.wa[p2]/nd.na;
              ndP = nd;
            }
          }
        }
        nd2[p2] = ndP;
      }
    }
    for (int p3=1; p3<=4; p3++) {
      if (nd2[p3]!=null && nd2[p3].children!=null) {
        ndP = null;
        maxWinrate = 0;
        for (uctNode nd : nd2[p3].children) {
          if (maxWinrate < nd.wa[p3]/nd.na) {
            maxWinrate = nd.wa[p3]/nd.na;
            ndP = nd;
          }
        }
        nd3[p3] = ndP;
      }
    }
    for (int p4=1; p4<=4; p4++) {
      if (nd3[p4]!=null && nd3[p4].children!=null) {
        ndP = null;
        maxWinrate = 0;
        for (uctNode nd : nd3[p4].children) {
          if (maxWinrate < nd.wa[p4]/nd.na) {
            maxWinrate = nd.wa[p4]/nd.na;
            ndP = nd;
          }
        }
        nd4[p4] = ndP;
      }
    }
    for (int p=1; p<=4; p++) {
      if (nd4[p]!=null)
        message[p] = ("["+nd4[p].id+"]");
      else if (nd3[p]!=null)
        message[p] = ("["+nd3[p].id+"]");
      else if (nd2[p]!=null)
        message[p] = ("["+nd2[p].id+"]");
      else if (nd1!=null)
        message[p] = ("["+nd1.id+"]");
      else
        message[p] = "[]";
    }
  }

  simulator.mainBoard.display(12);// UCTディスプレイ
  textAlign(LEFT, CENTER);
  fill(0);
  for (int p=1; p<=4; p++) {
    text(message[p], utils.unitSize/2, utils.subU+utils.vStep*(p-1));
  }
  showReturnButton();
  showScreenCapture();
}
void mousePreesedSimulator() {
  if (buttonReturnToMenu.mouseOn()) {//　メニューに戻る、をクリックされたとき
    displayManager = dP.onContents;
    managerPhase=mP.GameStart;
    return;
  }
  if (buttonSaveScreenShot.mouseOn()) {//　メニューに戻る、をクリックされたとき
    selectOutput("スクリーンショットを保存", "saveScreenShotSelected");
    //save("screenshot.png");
  }
  if (gameOptions.get("SimMethod")==1) {
    if (buttonPrevSV.mouseOn()) {
      int loopSize=simulator.rootNode.children.size();
      attackChanceCursor = (attackChanceCursor+loopSize-1)%loopSize;
      simulator.mainBoard.display(10);
      prize prize=new prize();
      prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.children);
      displayBestStats(prize);
      displayAllStats(attackChanceCursor, simulator.nextPlayer);
      showReturnButton();
      showScreenCapture();
    } else if (buttonNextSV.mouseOn()) {
      int loopSize=simulator.rootNode.children.size();
      attackChanceCursor = (attackChanceCursor+1)%loopSize;
      simulator.mainBoard.display(10);
      prize prize=new prize();
      prize.getPrize3FromNodeList(simulator.nextPlayer, simulator.rootNode.children);
      displayBestStats(prize);
      displayAllStats(attackChanceCursor, simulator.nextPlayer);
      showReturnButton();
      showScreenCapture();
    }
  }
}

void saveScreenShotSelected(File selection) {
  if (selection == null) {
    println("ファイルが選択されませんでした。");
  } else {
    filePath = selection.getAbsolutePath();
    if (filePath.substring(filePath.length()-4)!=".png") {
      filePath += ".png";
    }
    println("選択されたファイルパス: " + filePath);
    save(filePath);
  }
}
