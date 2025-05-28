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
  //for (int k=0; k<5; k++) {
  //  for (int j=0; j<5; j++) {
  //    print(" "+sub.s[5*k+j].col);
  //  }
  //  print(" |");
  //}
  //println();
  if (remaining>0) {
    //println("playSimulatorToEnd:ループ開始");
    do {
      int simulatorNextPlayer = int(random(4))+1;
      if (1<= simulatorNextPlayer && simulatorNextPlayer<=4 ) {
        //println("playSimulatorToEnd:player変数が持っている盤面をsubにコピーする。");
        sub.copyBoard(_participants[simulatorNextPlayer].myBoard);
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
    //int p = nextSimulatorPlayer-1;
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

void updateDisplayData(int r) {
  if (r==3) {
    int b1=0, b2=0, b3=0;
    float p1=0, p2=0, p3=0;
    float q1=0, q2=0, q3=0;
    for (int k=0; k<625; k++) {
      if ( attackChanceVP[k]==1 ) {
        if ( attackChanceSV[k] > p3 || (attackChanceSV[k] == p3 && attackChanceSV2[k] >= q3) ) {
          b3=k;
          p3=attackChanceSV[k];
          q3=attackChanceSV2[k];
          if ( attackChanceSV[k] > p2 || (attackChanceSV[k] == p2 && attackChanceSV2[k] >= q2)) {
            b3=b2;
            p3=p2;
            q3=q2;
            b2=k;
            p2=attackChanceSV[k];
            q2=attackChanceSV2[k];
            if ( attackChanceSV[k] > p1 || (attackChanceSV[k] == p1 && attackChanceSV2[k] >= q1) ) {
              b2=b1;
              p2=p1;
              q2=q1;
              b1=k;
              p1=attackChanceSV[k];
              q1=attackChanceSV2[k];
            }
          }
        }
      }
    }

    textAlign(LEFT, CENTER);
    textSize(utils.fontSize);
    fill(255, 0, 0);
    text("BEST 3", utils.subL, utils.subU);
    text("ALL(click to slide)", utils.unitSize/2, utils.subU);
    fill(0);
    String msg1 = "("+(b1%25+1)+"-"+(int(b1/25)+1)+") "+int(p1)+"/"+(utils.simulatorBoard.simulatorNumber)+" : "+ nf(q1/utils.simulatorBoard.simulatorNumber, 2, 3);
    text(msg1, utils.subL, utils.subU+utils.fontSize*1.5 );
    String msg2 = "("+(b2%25+1)+"-"+(int(b2/25)+1)+") "+int(p2)+"/"+(utils.simulatorBoard.simulatorNumber)+" : "+ nf(q2/utils.simulatorBoard.simulatorNumber, 2, 3);
    text(msg2, utils.subL, utils.subU+utils.fontSize*3 );
    String msg3 = "("+(b3%25+1)+"-"+(int(b3/25)+1)+") "+int(p3)+"/"+(utils.simulatorBoard.simulatorNumber)+" : "+ nf(q3/utils.simulatorBoard.simulatorNumber, 2, 3);
    text(msg3, utils.subL, utils.subU+utils.fontSize*4.5 );
    int loopSize=attackChanceValidNodes.size();
    int prev= (attackChanceCursor+loopSize-1)%loopSize;
    int kk = attackChanceValidNodes.get(prev);
    msg1 = "("+(kk%25+1)+"-"+(int(kk/25)+1)+") "+int(attackChanceSV[kk])+"/"+(utils.simulatorBoard.simulatorNumber)+" : "+ nf(attackChanceSV2[kk]/utils.simulatorBoard.simulatorNumber, 2, 3);
    text(msg1, utils.unitSize/2, utils.subU+utils.fontSize*1.5);
    buttonPrevSV.setLT(utils.unitSize/2, utils.subU+utils.fontSize*1.5, msg1);
    int now = attackChanceCursor;
    kk = attackChanceValidNodes.get(now);
    //print(now,kk,"-");
    msg2 = "("+(kk%25+1)+"-"+(int(kk/25)+1)+") "+int(attackChanceSV[kk])+"/"+(utils.simulatorBoard.simulatorNumber)+" : "+ nf(attackChanceSV2[kk]/utils.simulatorBoard.simulatorNumber, 2, 3);
    text(msg2, utils.unitSize/2, utils.subU+utils.fontSize*3);
    int next= (attackChanceCursor+1)%loopSize;
    kk = attackChanceValidNodes.get(next);
    msg3 = "("+(kk%25+1)+"-"+(int(kk/25)+1)+") "+int(attackChanceSV[kk])+"/"+(utils.simulatorBoard.simulatorNumber)+" : "+ nf(attackChanceSV2[kk]/utils.simulatorBoard.simulatorNumber, 2, 3);
    text(msg3, utils.unitSize/2, utils.subU+utils.fontSize*4.5);
    buttonNextSV.setLT(utils.unitSize/2, utils.subU+utils.fontSize*4.5, msg1);
  }
}


void showSimulator() {
  if (gameOptions.get("SimMethod")==1) {
    fullRandomMC();
  } else if (gameOptions.get("SimMethod")==2) {
    UCT1();
  //} else if (gameOptions.get("SimMethod")==3) {
  //  UCT2();
  } else {
    fullRandomMC();
  }
}

void fullRandomMC() {
  // 完全ランダム＝モンテカルロ1手読み
  if (simulationManager==sP.GameStart) {
    // シミュレーション開始
    startTime=millis();
    simulatorParticipants = new player[5];
    attackChanceSV = new float[625];
    attackChanceSV2 = new float[625];
    attackChanceVP = new int[625];
    // プレーヤーをランダムに設定
    for (int p=1; p<5; p++) {
      simulatorParticipants[p] = new player(p, "random", brain.Random);
      //simulatorParticipants[p] = new player(p, "random", brain.UCT1);//
    }
    for (int j=0; j<=25; j++) {
      utils.simulatorBoard.sv[j]=0;
      utils.simulatorBoard.sv2[j]=0;
    }
    for (int i=0; i<25; i++) {
      utils.simulatorBoard.s[i].col = simulatorStartBoard.get(simulatorStartBoardId).theArray[i];
      utils.simulatorBoard.s[i].marked = 0;
    }
    //次の手番の指定
    nextSimulatorPlayer = simulatorStartBoard.get(simulatorStartBoardId).nextPlayer;
    // 着手可能点を計算しておく。
    utils.simulatorBoard.buildVP(nextSimulatorPlayer);
    for (int k=0; k<625; k++) {
      attackChanceSV[k]=0;
      attackChanceSV2[k]=0;
    }
    utils.simulatorBoard.simulatorNumber=0;
    simulationManager=sP.setStartBoard;
  } else if (simulationManager == sP.setStartBoard) {
    // 問題がアタックチャンス問題のときには、別処理にする。
    if (utils.simulatorBoard.attackChanceP()) {
      // vpの初期化と、svの初期化
      utils.simulatorBoard.buildVP(nextSimulatorPlayer);
      attackChanceValidNodes.clear();
      attackChanceCursor=1;
      for (int j=0; j<25; j++) { //加えるほう
        for (int i=0; i<25; i++) { //黄色にするほう
          int k = i*25+j;
          if (utils.simulatorBoard.vp[j]>0 && (utils.simulatorBoard.s[i].col>=1 && utils.simulatorBoard.s[i].col<=4)) {
            attackChanceVP[k]=1;
            attackChanceValidNodes.append(k);
          } else if (utils.simulatorBoard.vp[j]>0 && i==j) {//　ルール上これも許される。
            attackChanceVP[k]=1;
            attackChanceValidNodes.append(k);
          } else {
            attackChanceVP[k]=0;
          }
        }
      }
      simulationManager = sP.runMC;
    } else {
      simulationManager = sP.runMC;
    }
  } else if (simulationManager == sP.runMC) {
    if (utils.simulatorBoard.attackChanceP()) {
      for (int k=0; k<625; k++) {
        if (attackChanceVP[k]==1) {
          for (int i=0; i<25; i++) {// 問題画面をsimulatorSubにコピー
            utils.simulatorSubBoard.s[i].col = utils.simulatorBoard.s[i].col;
          }
          int j=k%25;
          int i=int(k/25);
          utils.simulatorSubBoard.move(nextSimulatorPlayer, j);// 1手着手する
          utils.simulatorSubBoard.s[i].col = 5;// 黄色を置く
          winPoints wp = playSimulatorToEnd(utils.simulatorSubBoard, simulatorParticipants);//そこから最後までシミュレーションを行う。
          attackChanceSV[k] += wp.points[nextSimulatorPlayer];//　その着手点はちょっと優秀ということになる。
          attackChanceSV2[k] += wp.panels[nextSimulatorPlayer];// 最終パネル枚数の総数
        }
      }
      utils.simulatorBoard.simulatorNumber ++;//シミュレーション回数（分母）
      //表示データの更新

      if (gameOptions.get("SimTimes")==1) {// 1000 times
        if (utils.simulatorBoard.simulatorNumber>=1000) {
          simulationManager=sP.GameEnd;
        }
      } else if (gameOptions.get("SimTimes")==2) {// 10000 times
        if (utils.simulatorBoard.simulatorNumber>=10000) {
          simulationManager=sP.GameEnd;
        }
      } else {// gameOptions.get("SimTimes")==3 // 50000 times
        if (utils.simulatorBoard.simulatorNumber>=50000) {
          simulationManager=sP.GameEnd;
        }
      }
      //print(",");
      if (utils.simulatorBoard.simulatorNumber%500==0) {
        utils.simulatorBoard.display(10);
        updateDisplayData(3);
        showReturnButton();
        showScreenCapture();
      }
    } else {// 通常時
      for (int j=0; j<=25; j++) {
        // 問題画面をsimulatorSubにコピー
        for (int i=0; i<25; i++) {
          utils.simulatorSubBoard.s[i].col = simulatorStartBoard.get(simulatorStartBoardId).theArray[i];
        }
        if (j<25) {
          if (utils.simulatorBoard.vp[j]>0) {// 着手できる箇所ごとに
            utils.simulatorSubBoard.move(nextSimulatorPlayer, j);// 1手着手する
            //println(nextSimulatorPlayer, j, "*");
            winPoints wp = playSimulatorToEnd(utils.simulatorSubBoard, simulatorParticipants);//そこから最後までシミュレーションを行う。
            float winPoint = wp.points[nextSimulatorPlayer];
            utils.simulatorBoard.sv[j] += winPoint;//　その着手点はちょっと優秀ということになる。
            utils.simulatorBoard.sv2[j] += 1.0*wp.panels[nextSimulatorPlayer];// 最終パネル数の累積
            utils.simulatorBoard.s[j].marked=nextSimulatorPlayer;// svを表示する意味
          }
        } else {// あえて着手しなかった場合
          winPoints wp = playSimulatorToEnd(utils.simulatorSubBoard, simulatorParticipants);//そこから最後までシミュレーションを行う。
          float winPoint = wp.points[nextSimulatorPlayer];
          utils.simulatorBoard.sv[j] += winPoint;
          utils.simulatorBoard.sv2[j] += 1.0*wp.panels[nextSimulatorPlayer];
        }
      }
      utils.simulatorBoard.simulatorNumber ++;//シミュレーション回数（分母）
      for (int j=0; j<25; j++) {
        utils.simulatorBoard.s[j].sv = utils.simulatorBoard.sv[j]/utils.simulatorBoard.simulatorNumber;
        utils.simulatorBoard.s[j].sv2 = utils.simulatorBoard.sv2[j]/utils.simulatorBoard.simulatorNumber;
        if (utils.simulatorBoard.vp[j]>0) {
          utils.simulatorBoard.s[j].marked = 1;
        }
      }
      if (gameOptions.get("SimTimes")==1) {// 1000 times
        if (utils.simulatorBoard.simulatorNumber>=1000) {
          simulationManager=sP.GameEnd;
        }
      } else if (gameOptions.get("SimTimes")==2) {// 10000 times
        if (utils.simulatorBoard.simulatorNumber>=10000) {
          simulationManager=sP.GameEnd;
        }
      } else {// gameOptions.get("SimTimes")==3 // 50000 times
        if (utils.simulatorBoard.simulatorNumber>=50000) {
          simulationManager=sP.GameEnd;
        }
      }
      if (utils.simulatorBoard.simulatorNumber%50==0) {
        utils.simulatorBoard.display(10);
        showReturnButton();
        showScreenCapture();
      }
    }
    //print(",");
  } else if (simulationManager==sP.GameEnd) {
    ;//println(millis()-startTime);
  }
}


void UCT1() {
  // UCT1手読み
  if (simulationManager==sP.GameStart) {
    // シミュレーション開始
    startTime=millis();
    simulatorParticipants = new player[5];
    attackChanceSV = new float[625];//アタックチャンス時の評価値の表
    attackChanceSV2 = new float[625];//アタックチャンス時の評価値の表
    attackChanceVP = new int[625];//アタックチャンス時の合法手のフラグ
    // プレーヤーをランダムに設定
    for (int p=1; p<5; p++) {
      simulatorParticipants[p] = new player(p, "random", brain.Random);
    }
    fullUctNode = new ArrayList<uctNode>();
    // 評価値のクリア
    for (int j=0; j<=25; j++) {
      utils.simulatorBoard.sv[j]=0;// ここにUCT値を代入する。
    }
    for (int i=0; i<25; i++) {
      utils.simulatorBoard.s[i].col = simulatorStartBoard.get(simulatorStartBoardId).theArray[i];
      utils.simulatorBoard.s[i].marked = 0;
    }
    nextSimulatorPlayer = simulatorStartBoard.get(simulatorStartBoardId).nextPlayer;
    // root nodeの設置と、
    uctRoot = new uctNode();
    for (int j=0; j<25; j++) {
      uctRoot.bd[j] = utils.simulatorBoard.s[j].col;
    }
    if (utils.simulatorBoard.attackChanceP()) {//アタックチャンスのための１世代めの追加
      //アタックチャンスのための初期化
      for (int k=0; k<625; k++) {
        attackChanceSV[k]=0;
      }
      utils.simulatorBoard.buildVP(nextSimulatorPlayer);// そもそもの着手可能パネル
      //アタックチャンス時の合法手の決定
      for (int j=0; j<25; j++) { //加えるほう
        for (int i=0; i<25; i++) { //黄色にするほう
          int k = i*25+j;
          if (utils.simulatorBoard.vp[j]>0 && (utils.simulatorBoard.s[i].col>=1 && utils.simulatorBoard.s[i].col<=4)) {
            attackChanceVP[k]=1;
          } else if (utils.simulatorBoard.vp[j]>0 && i==j) {//　ルール上これも許される。
            attackChanceVP[k]=1;
          } else {
            attackChanceVP[k]=0;
          }
        }
      }
      utils.simulatorBoard.simulatorNumber=0;
      uctRoot.children=new ArrayList<uctNode>();
      for (int k=0; k<625; k++) {//アタックチャンス時の合法手のノードを追加する
        if (attackChanceVP[k]>0) {
          uctNode newNode = new uctNode();
          uctRoot.children.add(newNode);
          fullUctNode.add(newNode);
          newNode.setItem(nextSimulatorPlayer, k);
          utils.simulatorBoard.copyBoard(utils.simulatorSubBoard);
          int j=k%25;
          int i=int(k/25);
          utils.simulatorSubBoard.move(nextSimulatorPlayer, j);// 1手着手する
          utils.simulatorSubBoard.s[i].col = 5;// 黄色を置く
          for (int l=0; l<25; l++) {
            newNode.bd[l] = utils.simulatorSubBoard.s[l].col;
          }
          newNode.parent = uctRoot;
          newNode.children = null;
          //とりあえず、最初の１シミュレーションはここで行うのがよさそう。
          winPoints wp = playSimulatorToEnd(utils.simulatorSubBoard, simulatorParticipants);//そこから最後までシミュレーションを行う。
          utils.simulatorBoard.simulatorNumber ++;
          newNode.na=1;//　初回につき代入、以後+=
          for (int p=1; p<5; p++) {
            newNode.wa[p] = wp.points[p];//　初回につき代入、以後+=
          }
          //utils.simulatorBoard.s[j].marked=1;// この行、様子をみる。実際には、盤面下部に優良データを表示する方針
        }
      }
    } else {// 通常時の１世代めの追加 // UCT1
      utils.simulatorBoard.buildVP(nextSimulatorPlayer);
      utils.simulatorBoard.simulatorNumber=0;
      uctRoot.children=new ArrayList<uctNode>();
      for (int j=0; j<25; j++) {
        if (utils.simulatorBoard.vp[j]>0) {
          uctNode newNode = new uctNode();
          uctRoot.children.add(newNode);
          fullUctNode.add(newNode);
          newNode.setItem(nextSimulatorPlayer, j);
          utils.simulatorBoard.copyBoard(utils.simulatorSubBoard);
          utils.simulatorSubBoard.move(nextSimulatorPlayer, j);
          for (int k=0; k<25; k++) {
            newNode.bd[k] = utils.simulatorSubBoard.s[k].col;
          }
          newNode.parent = uctRoot;
          //とりあえず、最初の１シミュレーションはここで行うのがよさそう。
          winPoints wp = playSimulatorToEnd(utils.simulatorSubBoard, simulatorParticipants);//そこから最後までシミュレーションを行う。
          utils.simulatorBoard.simulatorNumber ++;
          newNode.na=1;//　初回につき代入、以後+=
          for (int p=1; p<5; p++) {
            newNode.wa[p] = wp.points[p];//　初回につき代入、以後+=
          }
          utils.simulatorBoard.s[j].marked=1;
        } else {
          utils.simulatorBoard.s[j].marked=0;
        }
      }
    }
    simulationManager=sP.setStartBoard;
  } else if (simulationManager==sP.setStartBoard) {// UCT1ループ部分
    if (utils.simulatorBoard.attackChanceP()) {//アタックチャンスの場合// UCT1ループ部分
      float maxUct=-100;
      uctNode maxNd=null;
      for (uctNode nd : fullUctNode) {
        if (nd.children==null) {
          float newUct = nd.UCTa(nd.player, utils.simulatorBoard.simulatorNumber) ;
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
        for (int k=0; k<25; k++) {//ノードの盤面をutils.simulatorSubBoardへコピ－
          utils.simulatorSubBoard.s[k].col = maxNd.bd[k] ;
        }
        winPoints wp = playSimulatorToEnd(utils.simulatorSubBoard, simulatorParticipants);//そこから最後までシミュレーションを行う。
        utils.simulatorBoard.simulatorNumber ++;
        maxNd.na ++ ;//
        for (int p=1; p<5; p++) {
          maxNd.wa[p] += wp.points[p];//
          maxNd.pa[p] += wp.panels[p];//
        }

        if (gameOptions.get("SimTimes")==11) {// 1sec
          if (millis()-startTime>=1000) {
            simulationManager=sP.GameEnd;
          }
        } else if (gameOptions.get("SimTimes")==12) {// 10sec
          if (millis()-startTime>=10000) {
            simulationManager=sP.GameEnd;
          }
        } else if (gameOptions.get("SimTimes")==13) {// 60sec
          if (millis()-startTime>=60000) {
            simulationManager=sP.GameEnd;
          }
        } else {/// gameOptions.get("SimTimes")==14
          if (maxNd.na>=50000) {// 50000 の根拠はなし。十分に多い、という意味。
            simulationManager=sP.GameEnd;
          }
        }
      }
      if (utils.simulatorBoard.simulatorNumber%500==0) {
        utils.simulatorBoard.display(11);// Uct1 ディスプレイ

        int b1=0, b2=0, b3=0;
        float p1=0, p2=0, p3=0;
        float q1=0, q2=0, q3=0;
        for (uctNode nd : uctRoot.children) {
          float P=nd.wa[nextSimulatorPlayer]/nd.na;
          float Q=nd.pa[nextSimulatorPlayer]/nd.na;
          int K=nd.move;
          if ( P > p3 || (P == p3 && Q >= q3) ) {
            b3=K;
            p3=P;
            q3=Q;
            if ( P > p2 || (P == p2 && Q >= q2)) {
              b3=b2;
              p3=p2;
              q3=q2;
              b2=K;
              p2=P;
              q2=Q;
              if ( P > p1 || (P == p1 && Q >= q1) ) {
                b2=b1;
                p2=p1;
                q2=q1;
                b1=K;
                p1=P;
                q1=Q;
              }
            }
          }
        }
        //background(255);
        //utils.simulatorBoard.display(0);
        textAlign(LEFT, CENTER);
        textSize(utils.fontSize);
        fill(255, 0, 0);
        text("BEST 3", utils.subL, utils.subU );
        fill(0);
        String msg1 = "("+(b1%25+1)+"-"+(int(b1/25)+1)+") "+nf(p1, 1, 5)+" : "+ nf(q1, 2, 3);
        text(msg1, utils.subL, utils.subU+utils.fontSize*1.5);
        String msg2 = "("+(b2%25+1)+"-"+(int(b2/25)+1)+") "+nf(p2, 1, 5)+" : "+ nf(q2, 2, 3);
        text(msg2, utils.subL, utils.subU+utils.fontSize*3);
        String msg3 = "("+(b3%25+1)+"-"+(int(b3/25)+1)+") "+nf(p3, 1, 5)+" : "+ nf(q2, 2, 3);
        text(msg3, utils.subL, utils.subU+utils.fontSize*4.5 );
        showReturnButton();
        showScreenCapture();
      }
    } else {//通常の場合// UCT1ループ部分
      float maxUct=-100;
      uctNode maxNd=null;
      for (uctNode nd : fullUctNode) {
        if (nd.children==null) {
          float newUct = nd.UCTa(nd.player, utils.simulatorBoard.simulatorNumber) ;
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
        for (int k=0; k<25; k++) {//ノードの盤面をutils.simulatorSubBoardへコピ－
          utils.simulatorSubBoard.s[k].col = maxNd.bd[k] ;
        }
        winPoints wp = playSimulatorToEnd(utils.simulatorSubBoard, simulatorParticipants);//そこから最後までシミュレーションを行う。
        utils.simulatorBoard.simulatorNumber ++;
        maxNd.na ++ ;//　
        for (int p=1; p<5; p++) {
          maxNd.wa[p] += wp.points[p];//
          maxNd.pa[p] += wp.panels[p];//
        }
        // 表示データの更新
        utils.simulatorBoard.sv[maxNd.move] = maxNd.wa[maxNd.player]/maxNd.na;
        utils.simulatorBoard.sv2[maxNd.move] = maxNd.pa[maxNd.player]/maxNd.na;
        //maxNd.UCTa(maxNd.player, utils.simulatorBoard.simulatorNumber) ;
        if (gameOptions.get("SimTimes")==11) {// 1sec
          if (millis()-startTime>=1000) {
            simulationManager=sP.GameEnd;
          }
        } else if (gameOptions.get("SimTimes")==12) {// 10sec
          if (millis()-startTime>=10000) {
            simulationManager=sP.GameEnd;
          }
        } else if (gameOptions.get("SimTimes")==13) {// 60sec
          if (millis()-startTime>=60000) {
            simulationManager=sP.GameEnd;
          }
        } else {/// gameOptions.get("SimTimes")==14
          if (maxNd.na>=50000) {// 50000 の根拠はなし。十分に多い、という意味。
            simulationManager=sP.GameEnd;
          }
        }
      }
      if (utils.simulatorBoard.simulatorNumber%500==0) {
        utils.simulatorBoard.display(11);// Uct1 ディスプレイ
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
      int loopSize=attackChanceValidNodes.size();
      attackChanceCursor = (attackChanceCursor+loopSize-1)%loopSize;
      utils.simulatorBoard.display(10);
      updateDisplayData(3);
      showReturnButton();
      showScreenCapture();
    } else if (buttonNextSV.mouseOn()) {
      int loopSize=attackChanceValidNodes.size();
      attackChanceCursor = (attackChanceCursor+1)%loopSize;
      utils.simulatorBoard.display(10);
      updateDisplayData(3);
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
