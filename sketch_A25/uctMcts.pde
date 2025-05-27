int uctMctsBrain(player pl) {
  //候補を一つに絞ってもよいが、いつでも同じ動作になってしまうので、複数個の候補を重みをつけておくとよい。
  //ここから

  //println("uctMctsBrain:プレーヤーをランダムエージェントに設定");
  player[] uctMctsParticipants = new player[5];
  for (int p=1; p<5; p++) {
    uctMctsParticipants[p] = new player(p, "random", brain.Random);
  }

  //println("uctMctsBrain:着手可能点を計算しておく");
  pl.myBoard.buildVP(pl.position);
  //pl.myBoard.vp に、候補を整数値（大きい値ほど選ばれる確率が大きい）で入れておく。

  //println("uctMctsBrain:pl の変数の初期化");
  for (int k=0; k<=25; k++) {
    pl.myBoard.sv[k]=0;
    pl.myBoard.sv2[k]=0;
  }
  pl.yellow=-1;

  //println("uctMctsBrain:シミュレーション用のサブボード");
  board uctMctsSubboard = new board();
  board uctMctsSubsubboard = new board();
  //println("uctMctsBrain:アクティブなノードのArrayList");
  ArrayList<uctNode> uctMctsNodes = new ArrayList<uctNode>();
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
    rootNode.parent = null;
    rootNode.children = new ArrayList<uctNode>();
    for (int k=0; k<25; k++) {
      if (pl.myBoard.vp[k]>0) {
        newNode = new uctNode();
        newNode.setItem(pl.position, k);
        uctMctsNodes.add(newNode);//アクティブなノードのリストに追加
        rootNode.children.add(newNode);//ルートノードにぶら下げる
        newNode.parent = rootNode;//ルートノードを親に設定
      }
    }

    //println("uctMctsBrain:手抜きという選択肢を考える");
    newNode = new uctNode();
    newNode.setItem(pl.position, 25);
    uctMctsNodes.add(newNode);//アクティブなノードのリストに追加
    rootNode.children.add(newNode);//ルートノードにぶら下げる
    newNode.parent = rootNode;//ルートノードを親に設定
    for (int k=0; k<25; k++) {// 何も表示しない
      //pl.myBoard.s[k].col ;
      pl.myBoard.s[k].marked = 0;
    }

    //println("uctMctsBrain:まずは一とおり、可能性のあるノードについてUCTを発動");
    for (uctNode nd : uctMctsNodes) {
      //println(pl.position, nd.move);
      //println("uctMctsBrain:問題画面をsimulatorSubにコピー");
      for (int i=0; i<25; i++) {
        uctMctsSubboard.s[i].col = pl.myBoard.s[i].col;
      }
      if (nd.move<25) {
        uctMctsSubboard.move(pl.position, nd.move);// 1手着手する
        for (int k=0; k<25; k++) {// nd.bdへとコピー
          nd.bd[k] = uctMctsSubboard.s[k].col;
        }
      } else {// move==25のときには、1手パスする
        for (int k=0; k<25; k++) {// nd.bdへとコピー
          nd.bd[k] = uctMctsSubboard.s[k].col;
        }
      }
      //println("uctMctsBrain:そこから最後までシミュレーションを行う");
      winPoints wp = playSimulatorToEnd(uctMctsSubboard, uctMctsParticipants);//
      //println("uctMctsBrain:初回は代入　nd.na=1");
      nd.na=1;//
      //println("uctMctsBrain:初回は代入　nd.wa[p]、nd.pa[p]、nd.uct[p]");
      for (int p=1; p<=4; p++) {
        nd.wa[p] = wp.points[p];//初回は代入
        nd.pa[p] = 1.0*wp.panels[p];//初回は代入
        nd.uct[p] = nd.UCTa(p, 1);// シミュレーション回数は１
        //println("uctMctsBrain:"+p,nd.wa[p], nd.pa[p], nd.uct[p]);
      }
    }
    
    //println("ここからループ");
    while (true) {
      pl.myBoard.simulatorNumber ++;
      //println("uctMctsBrain:シミュレーション回数"+pl.myBoard.simulatorNumber);

      //println("uct値が最大となるノードを見つける");
      float uctMax=-1;
      float uctPaMax=0;
      uctNode uctMaxNode=null;
      for (uctNode nd : uctMctsNodes) {
        if (nd.uct[nd.player]>uctMax || (nd.uct[nd.player]==uctMax && nd.pa[nd.player]>uctPaMax)) {
          uctMax=nd.uct[nd.player];
          uctPaMax=nd.pa[nd.player];
          uctMaxNode = nd;
        }
      }
      if (uctMaxNode==null) {// uct最大のノードを見つけられないとき
        println("uct failure");
        break;
      } else {// uct最大のノードを見つけらたとき（フツウはこっち）
        //println("uctMctsBrain:",uctMaxNode.player, uctMaxNode.move, "のノードを調べる");
        //println("uctMctsBrain:uctMctsSubboardへ盤面をコピー");
        for (int k=0; k<25; k++) {
          uctMctsSubboard.s[k].col = uctMaxNode.bd[k];
        }
        //println("uctMctsBrain:uctMctsSubboardを最後まで打ち切る");
        winPoints wp = playSimulatorToEnd(uctMctsSubboard, uctMctsParticipants);
        //println("uctMctsBrain:2回め以降は和　nd.wa[p]、nd.pa[p]、nd.uct[p]");
        uctMaxNode.na ++;//2回め以降は和
        for (int p=1; p<=4; p++) {
          uctMaxNode.wa[p] += wp.points[p];//2回め以降は和
          uctMaxNode.pa[p] += 1.0*wp.panels[p];//2回め以降は和
        }
        for (uctNode nd : uctMctsNodes) {
          for (int p=1; p<=4; p++) {
            nd.uct[p] = nd.UCTa(p, pl.myBoard.simulatorNumber);// シミュレーション総回数はpl.myBoard.simulatorNumber
          }
        }
        //println("親にさかのぼってデータを更新する");
        uctNode nd0 = uctMaxNode;
        do {          
          if (nd0.parent!=null){
            nd0 = nd0.parent;
            if (nd0.parent==null){// ルートまでたどり着いた、の意味
              break;
            } else {
              nd0.na ++;
              for (int p=1; p<=4; p++) {
                nd0.wa[p] += wp.points[p];//2回め以降は和
                nd0.pa[p] += 1.0*wp.panels[p];//2回め以降は和
              }
              for (int p=1; p<=4; p++) {// 上がっていったら、たぶんUCTいらない。
                nd0.uct[p] = nd0.UCTa(p, pl.myBoard.simulatorNumber);// 上がっていったら、たぶんUCTいらない。
              }// 上がっていったら、たぶんUCTいらない。
            }
          }
        } while(true);
        //println("uctMctsBrain:",uctMaxNode.na, uctMaxNode.wa[uctMaxNode.player], uctMaxNode.pa[uctMaxNode.player]);
        if (uctMaxNode.na >= 100) {// 100は調整可能なパラメータの一つ
          //println("uctMctsBrain:展開");
          // uctMaxNodeの下にノードをぶら下げる
          newNode=null;          
          //println("uctMctsBrain:uctMaxNodeはuctMctsNodesから削除");
          int uctMaxNodeId=0;
          for (int id=0; id<uctMctsNodes.size(); id++){
            if (uctMctsNodes.get(id)==uctMaxNode){
              uctMaxNodeId=id;
              break;
            }
          }
          uctMctsNodes.remove(uctMaxNodeId);
          
          for (int p=1; p<5; p++) {
            // uctMaxNodeの盤面をuctMctsSubboardへコピー
            for (int k=0; k<25; k++) {
              uctMctsSubboard.s[k].col = uctMaxNode.bd[k];
            }
            // uctMaxNodeの盤面でプレイヤーpの合法手をリストアップ
            uctMctsSubboard.buildVP(p);
            // 合法手ごとのforループ
            for (int k=0; k<25; k++){
              // 子ノードをぶら下げる
              if (uctMctsSubboard.vp[k]>0){
                newNode = new uctNode();
                newNode.setItem(p, k);
                // uctMctsNodesに追加する
                uctMctsNodes.add(newNode);//アクティブなノードのリストに追加
                uctMaxNode.children.add(newNode);//uctMaxNodeにぶら下げる
                newNode.parent = uctMaxNode;//uctMaxNodeを親に設定
                // １回最後までプレイする
                for (int kk=0; kk<25; kk++) {
                  uctMctsSubsubboard.s[kk].col = uctMctsSubboard.s[kk].col;
                }
                uctMctsSubsubboard.move(p, k);// 1手着手する
                for (int kk=0; kk<25; kk++) {// newNode.bdへとコピー
                  newNode.bd[k] = uctMctsSubsubboard.s[kk].col;
                }
                //println("uctMctsBrain:そこから最後までシミュレーションを行う");
                winPoints wpwp = playSimulatorToEnd(uctMctsSubsubboard, uctMctsParticipants);//
                //println("uctMctsBrain:初回は代入　nd.na=1");
                newNode.na=1;//
                //println("uctMctsBrain:初回は代入　nd.wa[p]、nd.pa[p]、nd.uct[p]");
                for (int pp=1; pp<=4; pp++) {
                  newNode.wa[pp] = wpwp.points[pp];//初回は代入
                  newNode.pa[pp] = 1.0*wpwp.panels[pp];//初回は代入
                  newNode.uct[pp] = newNode.UCTa(pp, 1);// シミュレーション回数は１
                  //println("uctMctsBrain:"+pp,newNode.wa[p], newNode.pa[p], newNode.uct[p]);
                }
              }
              // バックプロパゲート
              //println("親にさかのぼってデータを更新する");
              nd0 = newNode;
              do {          
                if (nd0.parent!=null){
                  nd0 = nd0.parent;
                  if (nd0.parent==null){// ルートまでたどり着いた、の意味
                    break;
                  } else {
                    nd0.na ++;
                    for (int pp=1; pp<=4; pp++) {
                      nd0.wa[pp] += wp.points[pp];//2回め以降は和
                      nd0.pa[pp] += 1.0*wp.panels[pp];//2回め以降は和
                    }
                    // nd0.uctはいらん。
                  }
                }
              } while(true);   // バックプロパゲートここまで      
              
              
            }// 子ノードをぶら下げるここまで
            
            
            
            ;
            
          }
        }
        if (uctMaxNode.na >= 1000) {// 1000は調整可能なパラメータの一つ
          // 正常終了 uct最大は、最も勝率の良い手
          // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
          return uctMaxNode.move;//これは正しくない。
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
