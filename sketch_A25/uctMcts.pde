int uctMctsBrain(player pl, int expandThreshold, int terminateThreshold, int depth) { //
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
  int noVp=0;//着手可能点のカウント
  for (int k=0; k<25; k++) {
    if (pl.myBoard.vp[k]>0) {
      noVp ++;
    }
  }
  if (noVp==0) {// ゲーム終了盤面ならば－１を返す。
    return -1;
  }

  //println("uctMctsBrain:pl の変数の初期化");
  for (int k=0; k<=25; k++) {
    pl.myBoard.sv[k]=0;
    pl.myBoard.sv2[k]=0;
  }
  pl.yellow=-1;

  //println("uctMctsBrain:シミュレーション用のサブボード");
  board uctMctsMainBoard = new board();
  board uctMctsSubBoard = new board();
  //println("uctMctsBrain:アクティブなノードのArrayList");
  ArrayList<uctNode> uctMctsNodes = new ArrayList<uctNode>();
  //println("uctMctsBrain:ループ回数のカウント");
  pl.myBoard.simulatorNumber=0;
  //println("uctMctsBrain:UCT準備");
  uctNode newNode = null;
  uctNode rootNode = new uctNode();
  rootNode.parent = null;
  rootNode.children = new ArrayList<uctNode>();
  pl.myBoard.copyBoardToBd(rootNode.bd);
  //rootNodeに子供をぶら下げる
  if (pl.myBoard.attackChanceP()==false) {
    println("uctMctsBrain:通常時、rootNodeに子供をぶら下げる");
    for (int k=0; k<25; k++) {
      if (pl.myBoard.vp[k]>0) {
        newNode = new uctNode();
        newNode.setItem(pl.position, k);
        newNode.id += (":"+pl.position+nf(k, 2));
        uctMctsNodes.add(newNode);//アクティブなノードのリストに追加
        rootNode.children.add(newNode);//ルートノードにぶら下げる
        newNode.parent = rootNode;//ルートノードを親に設定
        pl.myBoard.copyBoardToSub(uctMctsMainBoard);
        uctMctsMainBoard.move(pl.position, k);//一手進める
        uctMctsMainBoard.copyBoardToBd(newNode.bd);
        newNode.attackChanceNode=false;
      }
    }
    //println("uctMctsBrain:手抜きという選択肢を考える");
    // 手抜きは展開しない。
    newNode = new uctNode();
    newNode.setItem(pl.position, 25);
    uctMctsNodes.add(newNode);//アクティブなノードのリストに追加
    rootNode.children.add(newNode);//ルートノードにぶら下げる
    newNode.parent = rootNode;//ルートノードを親に設定
    pl.myBoard.copyBoardToSub(uctMctsMainBoard);
    uctMctsMainBoard.copyBoardToBd(newNode.bd);
    newNode.attackChanceNode=false;//念のため倒しておく。    
  } else {
    println("uctMctsBrain:AC時、rootNodeに子供をぶら下げる");
    pl.myBoard.attackChanceP=true;
    for (int j=0; j<25; j++) { //加えるパネル
      for (int i=0; i<25; i++) { //黄色にするパネル
        int k = i*25+j;
        if ((pl.myBoard.vp[j]>0 && (pl.myBoard.s[i].col>=1 && pl.myBoard.s[i].col<=4)) || (pl.myBoard.vp[j]>0 && i==j)) {
          newNode = new uctNode();
          newNode.setItem(pl.position, k);
          rootNode.children.add(newNode);//ぶら下げる
          pl.myBoard.copyBoardToSub(uctMctsMainBoard);
          uctMctsMainBoard.move(pl.position, j);// 1手着手する
          uctMctsMainBoard.s[i].col = 5;// 黄色を置く
          uctMctsMainBoard.copyBoardToBd(newNode.bd);
          newNode.attackChanceNode=true;
        }
      }
    }
  }
  
  for (int k=0; k<25; k++) {// 何も表示しない。念のため。
    //pl.myBoard.s[k].col ;
    pl.myBoard.s[k].marked = 0;
  }

  //println("uctMctsBrain:まずは100回シミュレーションして、余りに成績が悪いものはここでカットする。");  
  for (uctNode nd : rootNode.children) {
    // パラメータの初期化
    nd.na=0;
    for (int p=1; p<=4; p++) {
      nd.wa[p] = 0;//
      nd.pa[p] = 0;//
    }
    //println("uctMctsBrain:最後までシミュレーションを100回行う");
    for (int count=0; count<100; count++){
      uctMctsMainBoard.copyBdToBoard(nd.bd);
      winPoints wp = playSimulatorToEnd(uctMctsMainBoard, uctMctsParticipants);//
      //println("uctMctsBrain:初回は代入　nd.na=1");
      nd.na ++;//
      for (int p=1; p<=4; p++) {
        nd.wa[p] += wp.points[p];//初回は代入
        nd.pa[p] += 1.0*wp.panels[p];//初回は代入
        nd.uct[p] = nd.UCTwp(p, 1);// ここではいらないかも
        //println("uctMctsBrain:"+p,nd.wa[p], nd.pa[p], nd.uct[p]);
      }
    }
  }
  prize prize = new prize();
  prize.getPrize1FromNodeList(pl.position, rootNode.children);
  float bestWr=prize.w1;
  if (rootNode.children.size()>10 && bestWr>0.0 && bestWr<1.0){
    float lowerBound = bestWr - sqrt(bestWr*(1.0-bestWr)/prize.m1.na)*4.0;// not 1.96? lol
    if (lowerBound>0){
      int listSize=rootNode.children.size();
      for (int id=listSize-1; id>=0; id--){
        uctNode nd=rootNode.children.get(id);
        //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, lowerBound);
        if (nd.wa[pl.position]/nd.na < lowerBound){
          rootNode.children.remove(nd);
          //print(":deleted");
        }
        //println();
      }
    }
  }
  //println("ここからループ");
  while (true) {
    pl.myBoard.simulatorNumber ++; //<>//
    if (pl.myBoard.simulatorNumber%10000==0) {
      //  for (uctNode nd : uctMctsNodes) {
      //    println(nd.id, nd.wa[nd.player]/nd.na, nd.uct[nd.player]);
      //  }
      //  println("This is here.");
      int bestChildren = returnBest2ChildrenFromRoot(pl, rootNode);
      int best1 = int(bestChildren/100);
      int best2 = bestChildren % 100;
      String best1Str = kifu.playerColCode[pl.position]+nf(best1+1, 2);
      String best2Str = kifu.playerColCode[pl.position]+nf(best2+1, 2);
      print(" "+(pl.myBoard.simulatorNumber/10000)+":("+best1Str+","+best2Str+")");
    }
    //println("uctMctsBrain:シミュレーション回数"+pl.myBoard.simulatorNumber);

    //println("uct値が最大となるノードを見つける");
    float uctMax=-1;
    float uctPaMax=0;
    uctNode uctMaxNode=null;
    int uctMctsNodesLength = uctMctsNodes.size();
    for (int zz=uctMctsNodesLength-1; zz>=0; zz--) {
      uctNode nd = uctMctsNodes.get(zz);
      if (nd.na >= expandThreshold && nd.id.length()>= 1+depth*4) {
        uctMctsNodes.remove(zz);
      } else if (nd.uct[nd.player]>uctMax || (nd.uct[nd.player]==uctMax && nd.pa[nd.player]>uctPaMax)) {
        uctMax=nd.uct[nd.player];
        uctPaMax=nd.pa[nd.player];
        uctMaxNode = nd;
      }
    }
    if (uctMaxNode==null) {// uct最大のノードを見つけられないとき
      println("loop end");
      break;
    } else {// uct最大のノードを見つけらたとき（フツウはこっち）
      //println("uctMctsBrain:",uctMaxNode.id, "のノードを調べる");
      //println("uctMctsBrain:uctMctsMainBoardへ盤面をコピー");
      for (int k=0; k<25; k++) {
        uctMctsMainBoard.s[k].col = uctMaxNode.bd[k];
      }
      //println("uctMctsBrain:uctMctsMainBoardを最後まで打ち切る");
      winPoints wp = playSimulatorToEnd(uctMctsMainBoard, uctMctsParticipants);
      //println("uctMctsBrain:2回め以降は和　nd.wa[p]、nd.pa[p]、nd.uct[p]");
      uctMaxNode.na ++;//2回め以降は和
      for (int p=1; p<=4; p++) {
        uctMaxNode.wa[p] += wp.points[p];//2回め以降は和
        uctMaxNode.pa[p] += 1.0*wp.panels[p];//2回め以降は和
      }
      for (uctNode nd : uctMctsNodes) {
        for (int p=1; p<=4; p++) {
          nd.uct[p] = nd.UCTwp(p, pl.myBoard.simulatorNumber);// シミュレーション総回数はpl.myBoard.simulatorNumber
        }
      }
      //println("uctMctsBrain:ノード ",uctMaxNode.id, "のデータ("+uctMaxNode.wa[1]+","+uctMaxNode.wa[2]+","+uctMaxNode.wa[3]+","+uctMaxNode.wa[4]+")/"+uctMaxNode.na);
      //println("親にさかのぼってデータを更新する");
      uctNode nd0 = uctMaxNode;
      do {
        if (nd0.parent!=null) {
          nd0 = nd0.parent;
          if (nd0.parent==null) {// ルートまでたどり着いた、の意味
            break;
          } else {
            nd0.na ++;
            for (int p=1; p<=4; p++) {
              nd0.wa[p] += wp.points[p];//2回め以降は和
              nd0.pa[p] += 1.0*wp.panels[p];//2回め以降は和
            }
            for (int p=1; p<=4; p++) {// 上がっていったら、たぶんUCTいらない。
              nd0.uct[p] = nd0.UCTwp(p, pl.myBoard.simulatorNumber);// 上がっていったら、たぶんUCTいらない。
            }// 上がっていったら、たぶんUCTいらない。
            //println("uctMctsBrain:→　ノード ",nd0.id, "のデータ("+nd0.wa[1]+","+nd0.wa[2]+","+nd0.wa[3]+","+nd0.wa[4]+")/"+nd0.na);
          }
        }
      } while (true);
      //println("uctMctsBrain:",uctMaxNode.na, uctMaxNode.wa[uctMaxNode.player], uctMaxNode.pa[uctMaxNode.player]);
      if (uctMaxNode.na >= expandThreshold && uctMaxNode.id.length()<3+depth*4) {//
        //println("uctMctsBrain:展開　"+uctMaxNode.id);
        // uctMaxNodeの下にノードをぶら下げる
        newNode=null;
        //println("uctMctsBrain:uctMaxNodeはuctMctsNodesから削除");
        int uctMaxNodeId=0;
        for (int id=0; id<uctMctsNodes.size(); id++) {
          if (uctMctsNodes.get(id)==uctMaxNode) {
            uctMaxNodeId=id;
            break;
          }
        }
        uctMctsNodes.remove(uctMaxNodeId);
        if (uctMaxNode.id!="R") {// 「パス」は掘り下げない。
          for (int p=1; p<5; p++) {
            for (int k=0; k<25; k++) {
              uctMctsMainBoard.s[k].col = uctMaxNode.bd[k];
            }
            uctMctsMainBoard.buildVP(p);
            //println("uctMctsBrain: uctMaxNodeの盤面でプレイヤーpの合法手をリストアップ");

            // 合法手ごとのforループ

            for (int k=0; k<25; k++) {
              // 子ノードをぶら下げる
              if (uctMctsMainBoard.vp[k]>0) {
                //for (int kk=0; kk<25; kk++) {
                //  uctMctsMainBoard.s[kk].col = uctMaxNode.bd[kk];
                //}
                newNode = new uctNode();
                newNode.setItem(p, k);
                newNode.id = uctMaxNode.id+":"+p+nf(k, 2);
                //println("uctMctsBrain: id="+newNode.id);
                // uctMctsNodesに追加する
                uctMctsNodes.add(newNode);//アクティブなノードのリストに追加
                if (uctMaxNode.children==null) {
                  uctMaxNode.children = new ArrayList<uctNode>();
                }
                uctMaxNode.children.add(newNode);//uctMaxNodeにぶら下げる
                newNode.parent = uctMaxNode;//uctMaxNodeを親に設定
                //println("新しいノード "+newNode.id+"を追加した！");
                // １回最後までプレイする
                for (int kk=0; kk<25; kk++) {
                  uctMctsSubBoard.s[kk].col = uctMctsMainBoard.s[kk].col;
                }
                uctMctsSubBoard.move(p, k);// 1手着手する
                for (int kk=0; kk<25; kk++) {// newNode.bdへとコピー
                  newNode.bd[kk] = uctMctsSubBoard.s[kk].col;
                }
                //print("ボード：");
                //for (int kki=0; kki<5; kki++) {
                //  for (int kkj=0; kkj<5; kkj++) {
                //    print(" "+newNode.bd[kkj+kki*5]);
                //  }
                //  print(":");
                //}
                //println();
                //println("uctMctsBrain:そこから最後までシミュレーションを行う");
                winPoints wpwp = playSimulatorToEnd(uctMctsSubBoard, uctMctsParticipants);//
                //println("uctMctsBrain:初回は代入　nd.na=1");
                newNode.na=1;//

                for (int pp=1; pp<=4; pp++) {
                  newNode.wa[pp] = wpwp.points[pp];//初回は代入
                  newNode.pa[pp] = 1.0*wpwp.panels[pp];//初回は代入
                  newNode.uct[pp] = newNode.UCTwp(pp, 1);// シミュレーション回数は１
                  //println("uctMctsBrain:"+pp,newNode.wa[p], newNode.pa[p], newNode.uct[p]);
                }
                //println("uctMctsBrain:ノード"+"のデータ("+newNode.wa[1]+","+newNode.wa[2]+","+newNode.wa[3]+","+newNode.wa[4]+")/"+newNode.na);
                // バックプロパゲート
                //println("親にさかのぼってデータを更新する");
                nd0 = newNode;
                do {
                  if (nd0.parent!=null) {
                    nd0 = nd0.parent;
                    if (nd0.parent==null) {// ルートまでたどり着いた、の意味
                      break;
                    } else {
                      nd0.na ++;
                      for (int pp=1; pp<=4; pp++) {
                        nd0.wa[pp] += wpwp.points[pp];//2回め以降は和
                        nd0.pa[pp] += 1.0*wpwp.panels[pp];//2回め以降は和
                      }
                      // nd0.uctはいらん。
                      //println("uctMctsBrain:→　ノード ",nd0.id, "のデータ("+nd0.wa[1]+","+nd0.wa[2]+","+nd0.wa[3]+","+nd0.wa[4]+")/"+nd0.na);
                    }
                  }
                } while (true);   // バックプロパゲートここまで
              }
            }// 子ノードをぶら下げるここまで
          }
        }
      }
      if (pl.myBoard.simulatorNumber >= terminateThreshold) {//
        // 正常終了
        // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
        bestWr=0;//<>//
        int bestMove=-1;
        for (uctNode nd1 : rootNode.children) {
          float tmpWe = nd1.wa[pl.position] / nd1.na;
          if (bestWr<tmpWe) {
            bestWr = tmpWe;
            bestMove = nd1.move;
          }
        }
        return bestMove;//
      }
    }
  }
  //println("ループ終了（計算すべきノードが尽きた時）");
  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
  return returnBestChildFromRoot(pl, rootNode);//
  //}
  //return pl.chooseOne(pl.myBoard.vp);
}

int returnBestChildFromRoot(player pl, uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
  float bestWr=0;//<>//
  int bestMove=-1;
  for (uctNode nd1 : root.children) {
    float tmpWe = nd1.wa[pl.position] / nd1.na;
    if (bestWr<tmpWe) {
      bestWr = tmpWe;
      bestMove = nd1.move;
    }
  }
  return bestMove;//
}

int returnBest2ChildrenFromRoot(player pl, uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものから２つをリターンする。
  float bestWr=0;//<>//
  int bestMove=-1;
  float secondWr=0;//<>//
  int secondMove=-1;
  for (uctNode nd1 : root.children) {
    float tmpWe = nd1.wa[pl.position] / nd1.na;
    if (bestWr<tmpWe) {
      secondWr = bestWr;
      secondMove = bestMove;
      bestWr = tmpWe;
      bestMove = nd1.move;
    } else
      if (secondWr<tmpWe) {
        secondWr = tmpWe;
        secondMove = nd1.move;
      }
  }
  return bestMove*100+secondMove;//
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
