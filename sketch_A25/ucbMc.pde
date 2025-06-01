// Ucb モンテカルロ　1手読みでプレーするエージェント //
// 質を保つために、候補手の数に応じて計算量を案分する(UCT)
// 一番よい勝率の手を1000回読んだら終わり、という考え方でいく。

int ucbMcBrain(player pl) {
  //pl.myBoard.vp に、候補を整数値（大きい値ほど選ばれる確率が大きい）で入れておく。
  //候補を一つに絞ってもよいが、そこそこ同じ動作になってしまうので、複数個の候補を重みをつけておくとよい。（未実装）

  //println("プレーヤーをランダムエージェントに設定");
  player[] ucbMcParticipants = new player[5];
  for (int p=1; p<5; p++) {
    ucbMcParticipants[p] = new player(p, "random", brain.Random);
  }

  //println("着手可能点を計算しておく");
  pl.myBoard.buildVP(pl.position);
  
  //println("pl の変数の初期化");
  for (int j=0; j<=25; j++) {
    pl.myBoard.sv[j]=0;
    pl.myBoard.sv2[j]=0;
  }
  pl.yellow=-1;

  //println("シミュレーション用のサブボード");
  board ucbMcSubboard = new board();
  //println("ノードのArrayList");
  ArrayList<uctNode> ucbMcNodes = new ArrayList<uctNode>();
  //println("ループ回数のカウント");
  pl.myBoard.simulatorNumber=0;
  
  //println("シミュレーション開始");
  if (pl.myBoard.attackChanceP()) {// アタックチャンスのときの処理を先に書く。
    uctNode newNode=new uctNode();
    // println("アタックチャンスのときの処理");
    float[] ucbMcAttackChanceSV = new float[625];
    float[] ucbMcAttackChanceSV2 = new float[625];
    int[] ucbMcAttackChanceVP = new int[625];
    float[] ucbMcAttackChanceUct = new float[625];
    for (int k=0; k<625; k++) {
      ucbMcAttackChanceSV[k]=0;
      ucbMcAttackChanceSV2[k]=0;
      ucbMcAttackChanceVP[k]=0;
      ucbMcAttackChanceUct[k]=0;
    }
    //println("vpの初期化");
    pl.myBoard.buildVP(pl.position);
    for (int j=0; j<25; j++) { //加えるほう
      for (int i=0; i<25; i++) { //黄色にするほう
        int k = i*25+j;
        if (pl.myBoard.vp[j]>0 && (pl.myBoard.s[i].col>=1 && pl.myBoard.s[i].col<=4)) {
          ucbMcAttackChanceVP[k]=1;
        } else if (pl.myBoard.vp[j]>0 && i==j) {//　ルール上これも許される。
          ucbMcAttackChanceVP[k]=1;
        }
      }
    }
    //println("まずは一とおり、可能性のあるノードについてUCTを発動");
    for (int k=0; k<625; k++) {
      if (ucbMcAttackChanceVP[k]==1) {
        for (int b=0; b<25; b++) {// 問題画面をsimulatorSubにコピー
          ucbMcSubboard.s[b].col = pl.myBoard.s[b].col;
        }
        int j=k%25;
        int i=int(k/25);
        ucbMcSubboard.move(pl.position, j);// 1手着手する
        ucbMcSubboard.s[i].col = 5;// 黄色を置く
        //println("ノード"+i+"-"+j+"を作成する");
        newNode = new uctNode();
        newNode.setItem(pl.position, k);
        ucbMcNodes.add(newNode);
        //println("問題画面をnewNode.bdにコピー");
        for (int b=0; b<25; b++) {
          newNode.bd[b] = ucbMcSubboard.s[b].col;
        }
        //println("そこから最後までシミュレーションを行う");
        winPoints wp = playSimulatorToEnd(ucbMcSubboard, ucbMcParticipants);//
        //println("初回は代入");
        newNode.na=1;//
        for (int p=1; p<=4; p++) {
          newNode.wa[p] = wp.points[p];//初回は代入
          newNode.pa[p] = 1.0*wp.panels[p];//初回は代入
          newNode.uct[p] = newNode.UCTa(p, 1);// シミュレーション回数は１
          //println(newNode.wa[p], newNode.pa[p], newNode.uct[p]);
        }
      }
    }
    //println("UCTループここから");
    while (true) {
      pl.myBoard.simulatorNumber ++;//シミュレーション回数
      //println("uct値が最大となるノードを見つける");
      float uctMax=-1;
      float uctPaMax=0;
      uctNode uctMaxNode=null;
      for (uctNode nd : ucbMcNodes) {
        if (nd.uct[nd.player]>uctMax || (nd.uct[nd.player]==uctMax && nd.pa[nd.player]>uctPaMax)) {
          uctMax=nd.uct[nd.player];
          uctPaMax=nd.pa[nd.player];
          uctMaxNode = nd;
        }
      }
      if (uctMaxNode==null) {// uct最大のノードを見つけられないとき
        println("uct failure");
        // 置く場所と、をセットで回答。
        //消す場所をここに入れておけば、あとでそのように処理をする。
        pl.yellow=-1;
        break;
      }
      //println("("+uctMaxNode.player+":"+uctMaxNode.move+ "の枝を調べる");
      for (int i=0; i<25; i++) {
        ucbMcSubboard.s[i].col = uctMaxNode.bd[i];
      }
      winPoints wp = playSimulatorToEnd(ucbMcSubboard, ucbMcParticipants);
      uctMaxNode.na ++;//2回め以降は和
      for (int p=1; p<=4; p++) {
        uctMaxNode.wa[p] += wp.points[p];//2回め以降は和
        uctMaxNode.pa[p] += 1.0*wp.panels[p];//2回め以降は和
      }
      for (uctNode nd : ucbMcNodes) {
        for (int p=1; p<=4; p++) {
          nd.uct[p] = nd.UCTa(p, pl.myBoard.simulatorNumber);// シミュレーション総回数はpl.myBoard.simulatorNumber
        }
      }
      //println(uctMaxNode.na, uctMaxNode.wa[uctMaxNode.player], uctMaxNode.pa[uctMaxNode.player], uctMaxNode.uct[uctMaxNode.player]);
      if (uctMaxNode.na >= 1000) {// 1000は調整可能なパラメータの一つ
        // 正常終了 uct最大は、最も勝率の良い手
        int j = (uctMaxNode.move)%25;
        int i = int(uctMaxNode.move/25);
        pl.yellow = i;
        return j;
      }
    }
    println("ループ終了（ここは通らない）");
    //println("UCTループここまで");
    // アタックチャンスのときの処理、ここまで
  } else {// 通常のときの処理
    //println("ucbMcBrain:通常時の１列目");
    uctNode newNode=new uctNode();//右辺はnullでも動くのでは？
    for (int j=0; j<25; j++) {
      if (pl.myBoard.vp[j]>0) {
        newNode = new uctNode();
        newNode.setItem(pl.position, j);
        ucbMcNodes.add(newNode);
      }
    }
    //println("手抜きという選択肢を考える");
    newNode = new uctNode();
    newNode.setItem(pl.position, 25);
    ucbMcNodes.add(newNode);
    for (int i=0; i<25; i++) {// 表示は何もしない
      //pl.myBoard.s[i].col ;
      pl.myBoard.s[i].marked = 0;
    }
    //println("まずは一とおり、可能性のあるノードについてUCTを発動");
    for (uctNode nd : ucbMcNodes) {
      //println(pl.position, nd.move);
      // 問題画面をsimulatorSubにコピー
      for (int i=0; i<25; i++) {
        ucbMcSubboard.s[i].col = pl.myBoard.s[i].col;
      }
      if (nd.move<25) {
        ucbMcSubboard.move(pl.position, nd.move);// 1手着手する
        for (int i=0; i<25; i++) {
          nd.bd[i] = ucbMcSubboard.s[i].col;
        }
      } else {// move==25のときには、1手パスする
        for (int i=0; i<25; i++) {
          nd.bd[i] = ucbMcSubboard.s[i].col;
        }
      }
      //println("そこから最後までシミュレーションを行う");
      winPoints wp = playSimulatorToEnd(ucbMcSubboard, ucbMcParticipants);//
      //println("初回は代入");
      nd.na=1;//
      for (int p=1; p<=4; p++) {
        nd.wa[p] = wp.points[p];//初回は代入
        nd.pa[p] = 1.0*wp.panels[p];//初回は代入
        nd.uct[p] = nd.UCTa(p, 1);// シミュレーション回数は１
        //println(nd.wa[p], nd.pa[p], nd.uct[p]);
      }
    }
    //println("ここからループ");
    while (true) {
      pl.myBoard.simulatorNumber ++;//シミュレーション回数
      //println("uct値が最大となるノードを見つける");
      float uctMax=-1;
      float uctPaMax=0;
      uctNode uctMaxNode=null;
      for (uctNode nd : ucbMcNodes) {
        if (nd.uct[nd.player]>uctMax || (nd.uct[nd.player]==uctMax && nd.pa[nd.player]>uctPaMax)) {
          uctMax=nd.uct[nd.player];
          uctPaMax=nd.pa[nd.player];
          uctMaxNode = nd;
        }
      }
      if (uctMaxNode==null) {// uct最大のノードを見つけられないとき
        println("uct failure");
        break;
      } else {
        //println(uctMaxNode.player, uctMaxNode.move, "の枝を調べる");
        for (int i=0; i<25; i++) {
          ucbMcSubboard.s[i].col = uctMaxNode.bd[i];
        }
        winPoints wp = playSimulatorToEnd(ucbMcSubboard, ucbMcParticipants);
        uctMaxNode.na ++;//2回め以降は和
        for (int p=1; p<=4; p++) {
          uctMaxNode.wa[p] += wp.points[p];//2回め以降は和
          uctMaxNode.pa[p] += 1.0*wp.panels[p];//2回め以降は和
        }
        for (uctNode nd : ucbMcNodes) {
          for (int p=1; p<=4; p++) {
            nd.uct[p] = nd.UCTa(p, pl.myBoard.simulatorNumber);// シミュレーション総回数はpl.myBoard.simulatorNumber
          }
        }
        //println(uctMaxNode.na, uctMaxNode.wa[uctMaxNode.player], uctMaxNode.pa[uctMaxNode.player], uctMaxNode.uct[uctMaxNode.player]);
        if (uctMaxNode.na >= 1000) {// 100は調整可能なパラメータの一つ
          // 正常終了 uct最大は、最も勝率の良い手
          float bestWr=0;
          int bestMove=25;
          for (uctNode nd1 : ucbMcNodes){
            if (bestWr<nd1.wa[pl.position]){
              bestWr=nd1.wa[pl.position];
              bestMove = nd1.move;
            }
          }
          return bestMove;//
          //return uctMaxNode.move;
        }
      }
    }
    println("ループ終了（ここは通らない）");
    // 通常のときの処理、ここまで
  }
  //異常終了
  return pl.chooseOne(pl.myBoard.vp);
}

int ucbMcAttackChance(player pl) {
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
