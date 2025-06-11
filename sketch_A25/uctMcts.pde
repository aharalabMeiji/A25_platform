int uctMctsBrain(player pl, int expandThreshold, int terminateThreshold, int _depth) { //
  //候補を一つに絞ってもよいが、いつでも同じ動作になってしまうので、複数個の候補を重みをつけておくとよい。
  //ここから
  startTime=millis();
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
  winPoints uctWinPoint=null;
  prize uctPrize=new prize();
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
    //println("uctMctsBrain:通常時、rootNodeに子供をぶら下げる");
    for (int k=0; k<25; k++) {
      if (pl.myBoard.vp[k]>0) {
        newNode = new uctNode();
        newNode.setItem(pl.position, k);
        newNode.id = rootNode.id + (":"+kifu.playerColCode[pl.position]+nf(k+1, 2));
        newNode.depth = 1;
        rootNode.children.add(newNode);//ルートノードにぶら下げる
        newNode.parent = null;//逆伝播をここで切りたいので
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
    newNode.id = rootNode.id+(":"+kifu.playerColCode[pl.position]+nf(26, 2));
    newNode.depth = 1;
    rootNode.children.add(newNode);//ルートノードにぶら下げる
    newNode.parent = null;//
    pl.myBoard.copyBoardToSub(uctMctsMainBoard);
    uctMctsMainBoard.copyBoardToBd(newNode.bd);
    newNode.attackChanceNode=false;//念のため倒しておく。
  } else {
    //println("uctMctsBrain:AC時、rootNodeに子供をぶら下げる");
    pl.myBoard.attackChanceP=true;
    for (int j=0; j<25; j++) { //加えるパネル
      for (int i=0; i<25; i++) { //黄色にするパネル
        int k = i*25+j;
        if ((pl.myBoard.vp[j]>0 && (pl.myBoard.s[i].col>=1 && pl.myBoard.s[i].col<=4)) || (pl.myBoard.vp[j]>0 && i==j)) {
          newNode = new uctNode();
          newNode.setItem(pl.position, k);
          newNode.id = rootNode.id + (":"+kifu.playerColCode[pl.position]+nf(j+1, 2)) + (":Y"+nf(i+1, 2));
          newNode.depth = 1;
          rootNode.children.add(newNode);//ぶら下げる
          newNode.parent = null;//
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

  //println("uctMctsBrain:まずは500回シミュレーションして、余りに成績が悪いものはここでカットする。");
  for (uctNode nd : rootNode.children) {
    // パラメータの初期化
    nd.na=0;
    for (int p=1; p<=4; p++) {
      nd.wa[p] = 0;//
      nd.pa[p] = 0;//
    }
    //println("uctMctsBrain:最後までシミュレーションを500回行う");
    for (int count=0; count<500; count++) {
      uctMctsMainBoard.copyBdToBoard(nd.bd);
      uctWinPoint = playSimulatorToEnd(uctMctsMainBoard, uctMctsParticipants);//
      //println("uctMctsBrain:初回は代入　nd.na=1");
      pl.myBoard.simulatorNumber ++;
      nd.na ++;//
      for (int p=1; p<=4; p++) {
        nd.wa[p] += uctWinPoint.points[p];//
        nd.pa[p] += uctWinPoint.panels[p];//
        //println("uctMctsBrain:"+p,nd.wa[p], nd.pa[p]);
      }
    }
  }
  uctPrize.getPrize1FromNodeList(pl.position, rootNode.children);
  float bestWr=uctPrize.w1;
  if (bestWr>0.0 && bestWr<1.0) {
    float lowerBound = bestWr - sqrt(bestWr*(1.0-bestWr)/uctPrize.m1.na)*4.0;// not 1.96? lol
    if (lowerBound>0) {
      int listSize=rootNode.children.size();
      for (int id=listSize-1; id>=0; id--) {
        //println("129",id);
        uctNode nd=rootNode.children.get(id);
        //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, lowerBound);
        if (nd.wa[pl.position]/nd.na < lowerBound) {
          rootNode.children.remove(nd);
          //print(":deleted");
        }
        //println();
      }
    }
  } else if (bestWr>=1.0) {
    int listSize=rootNode.children.size();
    for (int id=listSize-1; id>=0; id--) {
      //  println("143",id);
      uctNode nd=rootNode.children.get(id);
      //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, "1");
      if (nd.wa[pl.position]/nd.na < 1.0) {
        rootNode.children.remove(nd);
        //print(":deleted");
      }
      //println();
    }
  }
  uctMctsNodes.clear();
  for (uctNode nd : rootNode.children) {
    uctMctsNodes.add(nd);
  }
  if (rootNode.children.size()==1){
    /// 選択肢が一つの時には、それを答える。
    int ret=rootNode.children.get(0).move;
    println("["+rootNode.children.get(0).id+"]");
    if (pl.myBoard.attackChanceP()){
      pl.yellow = int(ret/25);
      return ret%25;
    }
    else {
      return ret;
    }

  }
  println("uct starts");
  int simulatorTag=10000;
  while (true) {
    //println(pl.myBoard.simulatorNumber);
    pl.myBoard.simulatorNumber ++;
    if (pl.myBoard.simulatorNumber>=simulatorTag) {
      uctPrize.getPrize3FromNodeList(pl.position, rootNode.children);
      String str="";
      str = " "+(simulatorTag/10000)+":(";
      if (uctPrize.getMove(1)!=null){
        str += (" "+uctPrize.getMove(1).id);
      }
      str += ",";
      if (uctPrize.getMove(2)!=null){
        str += (uctPrize.getMove(2).id);
      } 
      str += ")";
      print(str);
      simulatorTag += 10000;
      // １位と２位が大差であれば、ここで打ち切る。
      //uctNode nd1 = uctPrize.getMove(1);
      //uctNode nd2 = uctPrize.getMove(2);
      //float winrate1=nd1.wa[pl.position]/nd1.na;
      //float winrate2=nd2.wa[pl.position]/nd2.na;
      //float lowerBound = winrate1 - sqrt(winrate1*(1.0-winrate1)/nd1.na)*3.0;
      //if (winrate2 < lowerBound){
      //  int ret = nd1.move;
      //  println("大差["+nd1.id+"]");
      //  if (pl.myBoard.attackChanceP()){
      //    pl.yellow = int(ret/25);
      //    return ret%25;
      //  }
      //  else {
      //    return ret;
      //  }
      //}
      
    }
    //println("uctMctsBrain:シミュレーション回数"+pl.myBoard.simulatorNumber);

    //println("uct値を整える");
    for (uctNode nd : uctMctsNodes) {
      for (int p=1; p<=4; p++) {
        // シミュレーション総回数はpl.myBoard.simulatorNumber
        // 平均パネル枚数に0.04かけて、加算している。
        nd.uct[p] = nd.UCTwp(p, pl.myBoard.simulatorNumber);
      }
    }

    //println("uct値が最大となるノードを見つける");
    float uctMax=-1;
    uctNode uctMaxNode=null;
    int uctMctsNodesLength = uctMctsNodes.size();
    for (int zz=uctMctsNodesLength-1; zz>=0; zz--) {
      //println("181",zz);
      uctNode nd = uctMctsNodes.get(zz);
      if (nd.na >= expandThreshold && nd.depth >= _depth) {//
        uctMctsNodes.remove(zz);
      } else if (nd.uct[nd.player]>uctMax) {
        uctMax=nd.uct[nd.player];
        uctMaxNode = nd;
      }
    }
    if (uctMaxNode==null) {
      println("計算すべきノードが尽きた");
      println("time=",millis()-startTime,"(ms)");
      //println("ループ終了（計算すべきノードが尽きた時）");
      // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
      int ret = returnBestChildFromRoot(pl, rootNode);
      if (pl.myBoard.attackChanceP()){
        pl.yellow = int(ret/25);
        return ret%25;
      }
      else {
        return ret;
      }
    }

    //println("uctMctsBrain:",uctMaxNode.id, "のノードを調べる");
    //println("uctMctsBrain:uctMctsMainBoardへ盤面をコピー");
    uctMctsMainBoard.copyBdToBoard(uctMaxNode.bd);
    //println("uctMctsBrain:uctMctsMainBoardを最後まで打ち切る");
    uctWinPoint = playSimulatorToEnd(uctMctsMainBoard, uctMctsParticipants);
    //println("uctMctsBrain:2回め以降は和　nd.wa[p]、nd.pa[p]、nd.uct[p]");
    uctMaxNode.na ++;//2回め以降は和
    for (int p=1; p<=4; p++) {
      uctMaxNode.wa[p] += uctWinPoint.points[p];//2回め以降は和
      uctMaxNode.pa[p] += uctWinPoint.panels[p];//2回め以降は和
    }

    //println("親にさかのぼってデータを更新する");
    uctNode nd0 = uctMaxNode;
    do {
      if (nd0.parent!=null) {
        nd0 = nd0.parent;
        nd0.na ++;
        for (int p=1; p<=4; p++) {
          nd0.wa[p] += uctWinPoint.points[p];//2回め以降は和
          nd0.pa[p] += uctWinPoint.panels[p];//2回め以降は和
        }
        //for (int p=1; p<=4; p++) {// 上がっていったら、たぶんUCTいらない。
        //  nd0.uct[p] = nd0.UCTwp(p, pl.myBoard.simulatorNumber);// 上がっていったら、たぶんUCTいらない。
        //}// 上がっていったら、たぶんUCTいらない。
        //println("uctMctsBrain:→　ノード ",nd0.id, "のデータ("+nd0.wa[1]+","+nd0.wa[2]+","+nd0.wa[3]+","+nd0.wa[4]+")/"+nd0.na);
      } else {// ルートまでたどり着いた、の意味
        break;
      }
    } while (true);

    //println("uctMctsBrain:ノード ",uctMaxNode.id, "のデータ("+uctMaxNode.wa[1]+","+uctMaxNode.wa[2]+","+uctMaxNode.wa[3]+","+uctMaxNode.wa[4]+")/"+uctMaxNode.na);
    //println("uctMctsBrain:",uctMaxNode.na, uctMaxNode.wa[uctMaxNode.player], uctMaxNode.pa[uctMaxNode.player]);
    if (uctMaxNode.na >= expandThreshold) {// 削除するための条件
      //println("uctMctsBrain:uctMaxNodeはuctMctsNodesから削除");
      //展開するにせよしないにせよ、この作業は等価に必要。
      for (int zz=uctMctsNodes.size()-1; zz>=0; zz--) {
        //println("241",zz);
        if (uctMctsNodes.get(zz)==uctMaxNode) {
          uctMctsNodes.remove(zz);//枝を打ち切る
          break;
        }
      }
      if (uctMaxNode.depth<_depth && uctMaxNode.id!="") {   // 展開するための条件    
        //println("uctMctsBrain:展開　"+uctMaxNode.id);
        // uctMaxNodeの下にノードをぶら下げる
        newNode=null;
        
        for (int p=1; p<5; p++) {
          //println("プレイヤー"+p+"の着手を追加");
          uctMctsMainBoard.copyBdToBoard(uctMaxNode.bd);
          uctMctsMainBoard.buildVP(p); 
          ArrayList<uctNode> tmpUctNodes = new ArrayList<uctNode>();//いったんここにぶら下げる。
          //println("uctMctsBrain: uctMaxNodeの盤面でプレイヤー"+p+"の合法手をリストアップ");
          if (uctMaxNode.attackChanceP()==false){
            // アタックチャンスでないときの、子ノードのぶらさげ
            uctMaxNode.attackChanceNode=false;
            for (int k=0; k<25; k++) {
              // 合法手ごとのforループ 
              if (uctMctsMainBoard.vp[k]>0) {
  
                // 子ノードをぶら下げる
                newNode = new uctNode();
                newNode.setItem(p, k);
                newNode.id = uctMaxNode.id+":"+kifu.playerColCode[p]+nf(k, 2);
                newNode.depth = uctMaxNode.depth+1;
                //println("uctMctsBrain: id="+newNode.id);                
                tmpUctNodes.add(newNode);// tmpUctNodesに追加する
                newNode.parent = uctMaxNode;//uctMaxNodeを親に設定
                //println("新しいノード "+newNode.id+"を追加した！");
                uctMctsMainBoard.copyBoardToSub(uctMctsSubBoard);
                uctMctsSubBoard.move(p, k);// 1手着手する
                uctMctsSubBoard.copyBoardToBd(newNode.bd);
                //newNode.printlnBd();
              }
            }
          } else {
            // アタックチャンスのときの、子ノードのぶらさげ    
            uctMaxNode.attackChanceNode=true;  //<>//
            
            for (int j=0; j<25; j++) { //加えるパネル
              for (int i=0; i<25; i++) { //黄色にするパネル
                int k = i*25+j;
                if ((pl.myBoard.vp[j]>0 && (pl.myBoard.s[i].col>=1 && pl.myBoard.s[i].col<=4)) || (pl.myBoard.vp[j]>0 && i==j)) {
                  newNode = new uctNode();
                  newNode.setItem(p, k);
                  newNode.id = uctMaxNode.id + (":"+kifu.playerColCode[pl.position]+nf(j+1, 2)) + (":Y"+nf(i+1, 2));
                  newNode.depth = uctMaxNode.depth + 1;
                  //println("uctMctsBrain: id="+newNode.id);                  
                  tmpUctNodes.add(newNode);//tmpUctNodesにぶら下げる
                  newNode.parent = uctMaxNode;//
                  //println("新しいノード "+newNode.id+"を追加した！");
                  uctMctsMainBoard.copyBoardToSub(uctMctsSubBoard);
                  uctMctsSubBoard.move(p, j);// 1手着手する
                  uctMctsSubBoard.s[i].col = 5;// 黄色を置く
                  uctMctsSubBoard.copyBoardToBd(newNode.bd);
                  newNode.attackChanceNode=true;
                }
              }
            }            
          }// ACノードの子ノード作成終わり。
          // 子ノードをぶら下げるここまで
          // TODO: 500回
          for (uctNode nd : tmpUctNodes){
            nd.na=0;
            for (int pp=1; pp<=4; pp++) {
              nd.wa[pp] = 0;//
              nd.pa[pp] = 0;//
            }
            for (int count=0; count<500;count++){            
              uctMctsSubBoard.copyBdToBoard(nd.bd);
              //println("uctMctsBrain:そこから最後までシミュレーションを行う");
              winPoints wpwp = playSimulatorToEnd(uctMctsSubBoard, uctMctsParticipants);//
              nd.na ++;//
              pl.myBoard.simulatorNumber ++;
              for (int pp=1; pp<=4; pp++) {
                nd.wa[pp] += wpwp.points[pp];//
                nd.pa[pp] += wpwp.panels[pp];//
                //println("uctMctsBrain:"+pp,newNode.wa[p], newNode.pa[p]);
              }
            }
            //println("親にさかのぼってデータを更新する");
            nd0 = nd;
            do {
              if (nd0.parent!=null) {
                nd0 = nd0.parent;
                nd0.na +=nd.na;
                for (int pp=1; pp<=4; pp++) {
                  nd0.wa[pp] += nd.wa[pp];//
                  nd0.pa[pp] += nd.pa[pp];//
                }
                //println("uctMctsBrain:→　ノード ",nd0.id, "のデータ("+nd0.wa[1]+","+nd0.wa[2]+","+nd0.wa[3]+","+nd0.wa[4]+")/"+nd0.na);
              } else {// ルートまでたどり着いた、の意味
                break;
              }
            } while (true);   
            // バックプロパゲートここまで
          }// 全部の新しいノードを５００回ずつ試行した。
          uctPrize.getPrize1FromNodeList(pl.position, rootNode.children);
          bestWr=uctPrize.w1;
          if (bestWr>0.0 && bestWr<1.0) {
            float lowerBound = bestWr - sqrt(bestWr*(1.0-bestWr)/uctPrize.m1.na)*4.0;// not 1.96? lol
            if (lowerBound>0) {
              int listSize=tmpUctNodes.size();
              for (int id=listSize-1; id>=0; id--) {
                //println("348",id);
                uctNode nd=tmpUctNodes.get(id);
                //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, lowerBound);
                if (nd.wa[pl.position]/nd.na < lowerBound) {
                  rootNode.children.remove(nd);
                  //print(":deleted");
                }
                //println();
              }
            }
          }// ここまで、筋の悪いものを消した。
          if (uctMaxNode.children==null) {//
            uctMaxNode.children = new ArrayList<uctNode>();
          }
          for (uctNode nd : tmpUctNodes){
            uctMaxNode.children.add(nd);//親ノードにぶら下げた
            uctMctsNodes.add(newNode);//アクティブなノードのリストに追加                
          }
        }//ここまで、４人分のノード展開
      }
    }
    if (pl.myBoard.simulatorNumber >= terminateThreshold) {//
      //println("試行回数上限到達")
      // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
      int ret = returnBestChildFromRoot(pl, rootNode);
      println("time=",millis()-startTime,"(ms)");
      if (pl.myBoard.attackChanceP()){
        pl.yellow = int(ret/25);
        return ret%25;
      }
      else {
        return ret;
      }
    }
  }// end of while(true)
}

int returnBestChildFromRoot(player pl, uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
  float bestWr=0;//
  int bestMove=-1;
  for (uctNode nd1 : root.children) {
    float tmpWe = (nd1.wa[pl.position]+nd1.pa[pl.position]*0.04 )/ nd1.na;
    if (bestWr<=tmpWe) {
      bestWr = tmpWe;
      bestMove = nd1.move;
    }
  }
  return bestMove;//
}

int returnBest2ChildrenFromRoot(player pl, uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものから２つをリターンする。
  float bestWr=0;//
  int bestMove=-1;
  float secondWr=0;//
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
