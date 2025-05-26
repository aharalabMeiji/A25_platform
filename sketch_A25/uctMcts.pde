int uctMctsBrain(player pl) {
  //候補を一つに絞ってもよいが、いつでも同じ動作になってしまうので、複数個の候補を重みをつけておくとよい。
  //ここから
  
  //println("uctMctsBrain:プレーヤーをランダムエージェントに設定");
  player[] uctMcParticipants = new player[5];
  for (int p=1; p<5; p++) {
    uctMcParticipants[p] = new player(p, "random", brain.Random);
  }

  //println("uctMctsBrain:着手可能点を計算しておく");
  pl.myBoard.buildVP(pl.position);
  //pl.myBoard.vp に、候補を整数値（大きい値ほど選ばれる確率が大きい）で入れておく。
  
  //println("uctMctsBrain:pl の変数の初期化");
  for (int j=0; j<=25; j++) {
    pl.myBoard.sv[j]=0;
    pl.myBoard.sv2[j]=0;
  }
  pl.yellow=-1;
  
  //println("uctMctsBrain:シミュレーション用のサブボード");
  board uctMcSubboard = new board();
  //println("uctMctsBrain:アクティブなノードのArrayList");
  ArrayList<uctNode> uctMcNodes = new ArrayList<uctNode>();
  //println("uctMctsBrain:ループ回数のカウント");
  pl.myBoard.simulatorNumber=0;
  //println("uctMctsBrain:シミュレーション開始");
  if (pl.myBoard.attackChanceP()) {
    //println("uctMctsBrain:アタックチャンスのとき");
    // 本当は、置く場所と、をセットで回答させたい。
    pl.yellow=-1;//消す場所をここに入れておけば、あとでそのように処理をする。
  } else {
    //println("uctMctsBrain:通常営業のとき"); 
    //println("uctMcBrain:通常時の１列目");
    uctNode newNode = null;
    uctNode rootNode = new uctNode();
    rootNode.children = new ArrayList<uctNode>();
    for (int j=0; j<25; j++) {
      if (pl.myBoard.vp[j]>0) {
        newNode = new uctNode();
        newNode.setItem(pl.position, j);
        uctMcNodes.add(newNode);//アクティブなノードのリストに追加
        rootNode.children.add(newNode);//ルートノードにぶら下げる
        newNode.parent = rootNode;//ルートノードを親に設定
      }
    }
    
    //println("uctMctsBrain:手抜きという選択肢を考える");
    newNode = new uctNode();
    newNode.setItem(pl.position, 25);
    uctMcNodes.add(newNode);//アクティブなノードのリストに追加
    rootNode.children.add(newNode);//ルートノードにぶら下げる
    newNode.parent = rootNode;//ルートノードを親に設定
    for (int i=0; i<25; i++) {// 何も表示しない
      //pl.myBoard.s[i].col ;
      pl.myBoard.s[i].marked = 0;
    }
    
    //println("uctMctsBrain:まずは一とおり、可能性のあるノードについてUCTを発動");
    for (uctNode nd : uctMcNodes) {
      //println(pl.position, nd.move);
      //println("uctMctsBrain:問題画面をsimulatorSubにコピー");
      for (int i=0; i<25; i++) {
        uctMcSubboard.s[i].col = pl.myBoard.s[i].col;
      }
      if (nd.move<25) {
        uctMcSubboard.move(pl.position, nd.move);// 1手着手する
        for (int i=0; i<25; i++) {// nd.bdへとコピー
          nd.bd[i] = uctMcSubboard.s[i].col;
        }
      } else {// move==25のときには、1手パスする
        for (int i=0; i<25; i++) {// nd.bdへとコピー
          nd.bd[i] = uctMcSubboard.s[i].col;
        }
      }
      //println("uctMctsBrain:そこから最後までシミュレーションを行う");
      winPoints wp = playSimulatorToEnd(uctMcSubboard, uctMcParticipants);//
      //println("uctMctsBrain:初回は代入　nd.na=1");
      nd.na=1;//
      //println("uctMctsBrain:初回は代入　nd.wa[p]、nd.pa[p]、nd.uct[p]");
      for (int p=1; p<=4; p++) {
        nd.wa[p] = wp.points[p];//初回は代入
        nd.pa[p] = 1.0*wp.panels[p];//初回は代入
        nd.uct[p] = nd.UCTa(p, 1);// シミュレーション回数は１
        //println("uctMctsBrain:"+p,nd.wa[p], nd.pa[p], nd.uct[p]);
      }
      //println("ここからループ");
      while (true) {
        pl.myBoard.simulatorNumber ++;
        //println("uctMctsBrain:シミュレーション回数"+pl.myBoard.simulatorNumber);
        
        //println("uct値が最大となるノードを見つける");
        float uctMax=-1;
        float uctPaMax=0;
        uctNode uctMaxNode=null;
        for (uctNode nd : uctMcNodes) {
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
        //println("uctMctsBrain:",uctMaxNode.player, uctMaxNode.move, "の枝を調べる");
        //println("uctMctsBrain:uctMcSubboardへ盤面をコピー");
        for (int i=0; i<25; i++) {
          uctMcSubboard.s[i].col = uctMaxNode.bd[i];
        }
        //println("uctMctsBrain:uctMcSubboardを最後まで打ち切る");
        winPoints wp = playSimulatorToEnd(uctMcSubboard, uctMcParticipants);
        //println("uctMctsBrain:2回め以降は和　nd.wa[p]、nd.pa[p]、nd.uct[p]");
        uctMaxNode.na ++;//2回め以降は和
        for (int p=1; p<=4; p++) {
          uctMaxNode.wa[p] += wp.points[p];//2回め以降は和
          uctMaxNode.pa[p] += 1.0*wp.panels[p];//2回め以降は和
        }
        for (uctNode nd : uctMcNodes) {
          for (int p=1; p<=4; p++) {
            nd.uct[p] = nd.UCTa(p, pl.myBoard.simulatorNumber);// シミュレーション総回数はpl.myBoard.simulatorNumber
          }
        }
        //println("uctMctsBrain:",uctMaxNode.na, uctMaxNode.wa[uctMaxNode.player], uctMaxNode.pa[uctMaxNode.player], uctMaxNode.uct[uctMaxNode.player]);
        if (uctMaxNode.na >= 100) {// 100は調整可能なパラメータの一つ
          //println("uctMctsBrain:展開");
          // uctMaxNodeの下にノードをぶら下げる
          // uctMaxNodeの盤面を＊＊＊へコピー
          for (int p=1; p<5; p++){
            // uctMaxNodeの盤面でプレイヤーpの合法手をリストアップ
            // 合法手ごとのforループ
            // 子ノードをぶら下げる
            // １回最後までプレイする
            // バックプロパゲート
            // uctMcNodesに追加する
            ;
            // uctMaxNodeはuctMcNodesから削除
            
          }
        }
        if (uctMaxNode.na >= 1000) {// 1000は調整可能なパラメータの一つ
          // 正常終了 uct最大は、最も勝率の良い手
          return uctMaxNode.move;
        }
      }
    }
    println("ループ終了（ここは通らない）");
  }
  return pl.chooseOne(pl.myBoard.vp);
}

int uctMctsAttackChance(player pl) {
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
