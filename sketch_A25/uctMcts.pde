int uctMctsBrain(player pl, int expandThreshold, int terminateThreshold, int _depth) { // //<>// //<>// //<>//
  //候補を一つに絞ってもよいが、いつでも同じ動作になってしまうので、複数個の候補を重みをつけておくとよい。
  //ここから
  startTime=millis();
  int answer = uctMctsStartingJoseki(pl);
  if (answer!=-1) return answer;
  answer = uctMctsBrainPreparation(pl);
  if (answer==-1) return -1;
  answer = uctMctsBrainFirstSimulation(2, pl);
  if (answer!=-1) return answer;
  println("uct starts");
  uct.simulationTag=expandThreshold*10;
  while (true) {
    answer = uctMctsMainLoop(pl, expandThreshold, terminateThreshold, _depth);
    if (answer!=-1) return answer;
  }// end of while(true)
}

int uctMctsStartingJoseki(player pl) {
  int count=0;
  for (int k=0; k<25; k++) {
    if (pl.myBoard.s[k].col!=0) {
      count++;
    }
  }
  //println("panels =",count);
  if (count==0) {
    return 12;
  }
  if (count==1) {
    return 7;
  }
  if (count==2) {
    uct.mainBoard=new board();
    pl.myBoard.buildVP(pl.position);
    if (pl.myBoard.vp[2]>0) return 2;
    if (pl.myBoard.vp[10]>0) return 10;
    if (pl.myBoard.vp[14]>0) return 14;
    if (pl.myBoard.vp[22]>0) return 22;
    if (pl.myBoard.vp[0]>0) return 0;
    if (pl.myBoard.vp[4]>0) return 4;
    if (pl.myBoard.vp[20]>0) return 20;
    if (pl.myBoard.vp[24]>0) return 24;
  }
  return -1;
}

int uctMctsBrainPreparation(player pl) {
  //println("uctMctsBrain:プレーヤーをランダムエージェントに設定");
  uct.participants = new player[5];
  for (int p=1; p<5; p++) {
    uct.participants[p] = new player(p, "random", brain.Random);
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
  for (int k=0; k<=25; k++) {//たぶん不要
    pl.myBoard.sv[k]=0;
    pl.myBoard.sv2[k]=0;
  }//たぶん不要
  pl.yellow=-1;
  uct.winPoint=null;
  uct.prize=new prize();
  //println("uctMctsBrain:シミュレーション用のサブボード");
  uct.mainBoard = new board();
  uct.subBoard = new board();
  //println("uctMctsBrain:アクティブなノードのArrayList");
  uct.activeNodes = new ArrayList<uctNode>();
  //println("uctMctsBrain:ループ回数のカウント");
  pl.myBoard.simulatorNumber=0;
  //println("uctMctsBrain:UCT準備");
  uct.newNode = null;
  uct.rootNode = new uctNode();
  uct.rootNode.parent = null;
  uct.rootNode.children = new ArrayList<uctNode>();
  pl.myBoard.copyBoardToBd(uct.rootNode.bd);
  //uct.rootNodeに子供をぶら下げる
  if (pl.myBoard.attackChanceP()==false) {
    //println("uctMctsBrain:通常時、uct.rootNodeに子供をぶら下げる");
    for (int k=0; k<25; k++) {
      if (pl.myBoard.vp[k]>0) {
        uct.newNode = new uctNode();
        uct.newNode.setItem(pl.position, k);
        uct.newNode.id = uct.rootNode.id + (":"+kifu.playerColCode[pl.position]+nf(k+1, 2));
        uct.newNode.depth = 1;
        uct.rootNode.children.add(uct.newNode);//ルートノードにぶら下げる
        uct.newNode.parent = null;//逆伝播をここで切りたいので
        pl.myBoard.copyBoardToSub(uct.mainBoard);
        uct.mainBoard.move(pl.position, k);//一手進める
        uct.mainBoard.copyBoardToBd(uct.newNode.bd);
        uct.newNode.attackChanceNode=false;
      }
    }
    //println("uctMctsBrain:手抜きという選択肢を考える");
    // 手抜きは展開しない。
    uct.newNode = new uctNode();
    uct.newNode.setItem(pl.position, 25);
    uct.newNode.id = uct.rootNode.id+(":"+kifu.playerColCode[pl.position]+nf(26, 2));
    uct.newNode.depth = 1;
    uct.rootNode.children.add(uct.newNode);//ルートノードにぶら下げる
    uct.newNode.parent = null;//
    pl.myBoard.copyBoardToSub(uct.mainBoard);
    uct.mainBoard.copyBoardToBd(uct.newNode.bd);
    uct.newNode.attackChanceNode=false;//念のため倒しておく。
  } else {
    //println("uctMctsBrain:AC時、uct.rootNodeに子供をぶら下げる");
    pl.myBoard.attackChanceP=true;
    for (int j=0; j<25; j++) { //加えるパネル
      for (int i=0; i<25; i++) { //黄色にするパネル
        int k = i*25+j;
        if ((pl.myBoard.vp[j]>0 && (pl.myBoard.s[i].col>=1 && pl.myBoard.s[i].col<=4)) || (pl.myBoard.vp[j]>0 && i==j)) {
          uct.newNode = new uctNode();
          uct.newNode.setItem(pl.position, k);
          uct.newNode.id = uct.rootNode.id + (":"+kifu.playerColCode[pl.position]+nf(j+1, 2)) + (":Y"+nf(i+1, 2));
          uct.newNode.depth = 1;
          uct.rootNode.children.add(uct.newNode);//ぶら下げる
          uct.newNode.parent = null;//
          pl.myBoard.copyBoardToSub(uct.mainBoard);
          uct.mainBoard.move(pl.position, j);// 1手着手する
          uct.mainBoard.s[i].col = 5;// 黄色を置く
          uct.mainBoard.copyBoardToBd(uct.newNode.bd);
          uct.newNode.attackChanceNode=true;
        }
      }
    }
  }

  for (int k=0; k<25; k++) {// 何も表示しない。念のため。
    pl.myBoard.s[k].marked = 0;
  }//たぶん不要
  return 0;// トラブルなく終わる
}

int uctMctsBrainFirstSimulation(int _count, player pl) {
  //println("uctMctsBrain:まずは500回シミュレーションして、余りに成績が悪いものはここでカットする。");
  for (uctNode nd : uct.rootNode.children) {
    // パラメータの初期化
    nd.na=0;
    for (int p=1; p<=4; p++) {
      nd.wa[p] = 0;//
      nd.pa[p] = 0;//
    }
    //println("uctMctsBrain:最後までシミュレーションを500回行う");
    for (int count=0; count<_count; count++) {
      uct.mainBoard.copyBdToBoard(nd.bd);
      uct.winPoint = playSimulatorToEnd(uct.mainBoard, uct.participants);//
      pl.myBoard.simulatorNumber ++;
      nd.na ++;//
      for (int p=1; p<=4; p++) {
        nd.wa[p] += uct.winPoint.points[p];//
        nd.pa[p] += uct.winPoint.panels[p];//
        //println("uctMctsBrain:"+p,nd.wa[p], nd.pa[p]);
      }
    }
  }
  //uct.prize.getPrize1FromNodeList(pl.position, uct.rootNode.children);// 勝率の最善をピックアップ
  //float bestWr=uct.prize.w1;
  //if (bestWr>0.0 && bestWr<1.0) {
  //  float lowerBound = bestWr - sqrt(bestWr*(1.0-bestWr)/uct.prize.m1.na)*4.0;// 最善勝率より、かなり低い枝はカットする。
  //  if (lowerBound>0) {
  //    int listSize=uct.rootNode.children.size();
  //    for (int id=listSize-1; id>=0; id--) {
  //      uctNode nd=uct.rootNode.children.get(id);
  //      //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, lowerBound);
  //      if (nd.wa[pl.position]/nd.na < lowerBound) {
  //        uct.rootNode.children.remove(nd);
  //        //print(":deleted");
  //      }
  //      //println();
  //    }
  //  }
  //} else if (bestWr>=1.0) {// 優勝が決まっているときには、優勝を逃す可能性のある枝を切る。
  //  int listSize=uct.rootNode.children.size();
  //  for (int id=listSize-1; id>=0; id--) {
  //    uctNode nd=uct.rootNode.children.get(id);
  //    //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, "1");
  //    if (nd.wa[pl.position]/nd.na < 1.0) {
  //      uct.rootNode.children.remove(nd);
  //      //print(":deleted");
  //    }
  //    //println();
  //  }
  //}
  //アクティブなノードをリスト化する。
  uct.activeNodes.clear();
  for (uctNode nd : uct.rootNode.children) {
    uct.activeNodes.add(nd);
  }
  if (uct.rootNode.children.size()==1) {
    /// 選択肢が一つの時には、それを答える。
    int ret=uct.rootNode.children.get(0).move;
    //println("["+uct.rootNode.children.get(0).id+"]");
    if (pl.myBoard.attackChanceP()) {
      pl.yellow = int(ret/25);
      return ret%25;
    } else {
      return ret;
    }
  }
  return -1;
}

int uctMctsMainLoop(player pl, int expandThreshold, int terminateThreshold, int _depth) {
  // console に計算経過を出力（マストではない。）
  uct.prize.getPrize3FromNodeList(pl.position, uct.rootNode.children);
  String str=""+(pl.myBoard.simulatorNumber/1000)+":(";
  if (uct.prize.getMove(1)!=null) {
    str += (""+uct.prize.getMove(1).id);
  }
  str += ",";
  if (uct.prize.getMove(2)!=null) {
    str += (uct.prize.getMove(2).id);
  }
  str += ")";
  //print(str);
  //println(pl.myBoard.simulatorNumber);
  for (int repeat=0; repeat<1000; repeat++) {
    pl.myBoard.simulatorNumber ++;
    //println("uctMctsBrain:シミュレーション回数"+pl.myBoard.simulatorNumber);

    //println("アクティブなノードのuct値を更新する");
    for (uctNode nd : uct.activeNodes) {
      for (int p=1; p<=4; p++) {
        // シミュレーション総回数はpl.myBoard.simulatorNumber
        // 平均パネル枚数に0.04かけて、加算している。
        //nd.uct[p] = nd.UCTwp(p, pl.myBoard.simulatorNumber);
        nd.uct[p] = nd.UCTa(p, pl.myBoard.simulatorNumber);
      }
    }

    //println("uct値が最大となるノードを見つける");
    float uctMax=-1;
    uctNode uctMaxNode=null;
    for (int zz=uct.activeNodes.size()-1; zz>=0; zz--) {
      uctNode nd = uct.activeNodes.get(zz);
      if (nd.na >= expandThreshold && nd.depth >= _depth) {//
        uct.activeNodes.remove(zz);
        //println("末端のノード("+nd.id+")がいっぱいになったのでアクティブノードのリストから消去");
      } else if (nd.uct[nd.player]>uctMax) {
        uctMax=nd.uct[nd.player];
        uctMaxNode = nd;
      }
    }
    if (uctMaxNode==null) {
      println("計算すべきノードが尽きた");
      println("time=", millis()-startTime, "(ms)");
      //PrintWriter output = createWriter("output.txt");
      //showAllMct(uct.rootNode, pl.myBoard.simulatorNumber, output);
      //output.flush();
      //output.close();
      //println("ループ終了（計算すべきノードが尽きた時）");
      // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
      int ret = returnBestChildFromRoot(pl, uct.rootNode);
      if (pl.myBoard.attackChanceP()) {
        pl.yellow = int(ret/25);
        return ret%25;
      } else {
        return ret;
      }
    }

    //println("uctMctsBrain:",uctMaxNode.id, "のノードを調べる");
    //println("uctMctsBrain:uct.mainBoardへ盤面をコピー");
    uct.mainBoard.copyBdToBoard(uctMaxNode.bd);
    //println("uctMctsBrain:uct.mainBoardを最後まで打ち切る");
    uct.winPoint = playSimulatorToEnd(uct.mainBoard, uct.participants);
    //println("uctMctsBrain:nd.wa[p]、nd.pa[p]、nd.uct[p]");
    uctMaxNode.na ++;//
    for (int p=1; p<=4; p++) {
      uctMaxNode.wa[p] += uct.winPoint.points[p];//2回め以降は和
      uctMaxNode.pa[p] += uct.winPoint.panels[p];//2回め以降は和
    }

    //println("親にさかのぼってデータを更新する");
    uctNode nd0 = uctMaxNode;
    do {
      if (nd0.parent!=null) {
        nd0 = nd0.parent;
        nd0.na ++;
        for (int p=1; p<=4; p++) {
          nd0.wa[p] += uct.winPoint.points[p];//2回め以降は和
          nd0.pa[p] += uct.winPoint.panels[p];//2回め以降は和
        }
        //println("uctMctsBrain:→　ノード ",nd0.id, "のデータ("+nd0.wa[1]+","+nd0.wa[2]+","+nd0.wa[3]+","+nd0.wa[4]+")/"+nd0.na);
      } else {// ルートまでたどり着いた、の意味
        break;
      }
    } while (true);//println("親にさかのぼってデータを更新する");//おわり

    //println("uctMctsBrain:ノード ",uctMaxNode.id, "のデータ("+uctMaxNode.wa[1]+","+uctMaxNode.wa[2]+","+uctMaxNode.wa[3]+","+uctMaxNode.wa[4]+")/"+uctMaxNode.na);
    //println("uctMctsBrain:",uctMaxNode.na, uctMaxNode.wa[uctMaxNode.player], uctMaxNode.pa[uctMaxNode.player]);
    if (uctMaxNode.na >= expandThreshold) {// 削除するための条件
      //println("uctMctsBrain:uctMaxNodeはuct.activeNodesから削除");
      //展開するにせよしないにせよ、この作業は等価に必要。
      for (int zz=uct.activeNodes.size()-1; zz>=0; zz--) {
        if (uct.activeNodes.get(zz)==uctMaxNode) {
          //println("ノード"+uctMaxNode.id+"をアクティブノードのリストから消去");
          uct.activeNodes.remove(zz);//枝を打ち切る
          
          break;
        }
      }
      if (uctMaxNode.depth<_depth && uctMaxNode.id!="") {   // 展開するための条件
        //println("uctMctsBrain:展開　"+uctMaxNode.id);/////////////////////////////ここから展開
        println(uctMaxNode.id+"を展開中");//+returnFriquentChildFromRoot(uct.rootNode).id);
        // uctMaxNodeの下にノードをぶら下げる
        uct.newNode=null;

        for (int p=1; p<5; p++) {
          //println("プレイヤー"+p+"の着手を追加");
          uct.mainBoard.copyBdToBoard(uctMaxNode.bd);
          uct.mainBoard.buildVP(p);
          ArrayList<uctNode> tmpUctNodes = new ArrayList<uctNode>();//いったんここにぶら下げる。
          //println("uctMctsBrain: uctMaxNodeの盤面でプレイヤー"+p+"の合法手をリストアップ");
          if (uctMaxNode.attackChanceP()==false) {
            // アタックチャンスでないときの、子ノードのぶらさげ
            uctMaxNode.attackChanceNode=false;
            for (int k=0; k<25; k++) {
              // 合法手ごとのforループ
              if (uct.mainBoard.vp[k]>0) {

                // 子ノードをぶら下げる
                uct.newNode = new uctNode();
                uct.newNode.setItem(p, k);
                uct.newNode.id = uctMaxNode.id+":"+kifu.playerColCode[p]+nf(k+1, 2);
                uct.newNode.depth = uctMaxNode.depth+1;
                //println("uctMctsBrain: id="+uct.newNode.id);
                tmpUctNodes.add(uct.newNode);// tmpUctNodesに追加する
                uct.newNode.parent = uctMaxNode;//uctMaxNodeを親に設定
                //println("新しいノード "+uct.newNode.id+"を追加した！");
                uct.mainBoard.copyBoardToSub(uct.subBoard);
                uct.subBoard.move(p, k);// 1手着手する
                uct.subBoard.copyBoardToBd(uct.newNode.bd);
                //uct.newNode.printlnBd();
              }
            }
          } else {
            // アタックチャンスのときの、子ノードのぶらさげ
            uctMaxNode.attackChanceNode=true;

            for (int j=0; j<25; j++) { //加えるパネル
              for (int i=0; i<25; i++) { //黄色にするパネル
                int k = i*25+j;
                if ((pl.myBoard.vp[j]>0 && (pl.myBoard.s[i].col>=1 && pl.myBoard.s[i].col<=4)) || (pl.myBoard.vp[j]>0 && i==j)) {
                  uct.newNode = new uctNode();
                  uct.newNode.setItem(p, k);
                  uct.newNode.id = uctMaxNode.id + (":"+kifu.playerColCode[pl.position]+nf(j+1, 2)) + (":Y"+nf(i+1, 2));
                  uct.newNode.depth = uctMaxNode.depth + 1;
                  //println("uctMctsBrain: id="+uct.newNode.id);
                  tmpUctNodes.add(uct.newNode);//tmpUctNodesにぶら下げる
                  uct.newNode.parent = uctMaxNode;//
                  //println("新しいノード "+uct.newNode.id+"を追加した！");
                  uct.mainBoard.copyBoardToSub(uct.subBoard);
                  uct.subBoard.move(p, j);// 1手着手する
                  uct.subBoard.s[i].col = 5;// 黄色を置く
                  uct.subBoard.copyBoardToBd(uct.newNode.bd);
                  uct.newNode.attackChanceNode=true;
                }
              }
            }
          }// ACノードの子ノード作成終わり。
          // 子ノードをぶら下げるここまで
          // TODO: 500回
          for (uctNode nd : tmpUctNodes) {
            nd.na=0;
            for (int pp=1; pp<=4; pp++) {
              nd.wa[pp] = 0;//
              nd.pa[pp] = 0;//
            }
            for (int count=0; count<5; count++) {
              uct.subBoard.copyBdToBoard(nd.bd);
              //println("uctMctsBrain:そこから最後までシミュレーションを行う");
              winPoints wpwp = playSimulatorToEnd(uct.subBoard, uct.participants);//
              nd.na ++;//
              pl.myBoard.simulatorNumber ++;
              for (int pp=1; pp<=4; pp++) {
                nd.wa[pp] += wpwp.points[pp];//
                nd.pa[pp] += wpwp.panels[pp];//
                //println("uctMctsBrain:"+pp,uct.newNode.wa[p], uct.newNode.pa[p]);
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
          uct.prize.getPrize1FromNodeList(p, tmpUctNodes);
          float bestWr=uct.prize.w1;
          if (bestWr>0.0 && bestWr<1.0) {
            float lowerBound = bestWr - sqrt(bestWr*(1.0-bestWr)/uct.prize.m1.na)*4.0;// not 1.96? lol
            if (lowerBound>0) {
              int listSize=tmpUctNodes.size();
              for (int id=listSize-1; id>=0; id--) {
                uctNode nd=tmpUctNodes.get(id);
                //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, lowerBound);
                if (nd.wa[p]/nd.na < lowerBound) {
                  tmpUctNodes.remove(nd);
                  //print(":deleted");
                }
                //println();
              }
            }
          }// ここまで、プレイヤーpにとって、筋の悪いものを消した。
          if (uctMaxNode.children==null) {//
            uctMaxNode.children = new ArrayList<uctNode>();
          } 
          for (uctNode nd : tmpUctNodes) {
            uctMaxNode.children.add(nd);//親ノードにぶら下げた
            uct.activeNodes.add(nd);//アクティブなノードのリストに追加
            //println("新しいノード("+nd.id+")を追加");
          }
        }//ここまで、４人分のノード展開
      }
    }
    if (pl.myBoard.simulatorNumber >= terminateThreshold) {//
      //println("試行回数上限到達")
      // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
      int ret = returnBestChildFromRoot(pl, uct.rootNode);
      println("time=", millis()-startTime, "(ms)");
      //PrintWriter output = createWriter("output.txt");
      //showAllMct(uct.rootNode, pl.myBoard.simulatorNumber, output);
      //output.flush();
      //output.close();
      if (pl.myBoard.attackChanceP()) {
        pl.yellow = int(ret/25);
        return ret%25;
      } else {
        return ret;
      }
    }
  }
  return -1;
}

void showAllMct(uctNode nd, int totalNumber, PrintWriter output) {
  if (nd==null) return;
  if (nd != uct.rootNode) {
    float winrate = nd.wa[nd.player] / nd.na;
    //float ucbValue = nd.UCTwp(nd.player, totalNumber);
    float ucbValue = nd.UCTa(nd.player, totalNumber);
    //println(nd.id+": "+ nf(winrate, 0, 3)+" [" +nd.na+"] <"+nf(ucbValue, 0, 3)+">");
  }
  if (nd.children!=null) {
    if (nd.children.size()>0) {
      for (uctNode child : nd.children) {
        showAllMct(child, totalNumber, output);
      }
    }
  }
}

int returnBestChildFromRoot(player pl, uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
  float bestWr=0, bestPr=0;//
  int bestMove=-1;
  for (uctNode nd1 : root.children) {
    float tmpWr = (nd1.wa[pl.position])/ nd1.na;
    float tmpPr = (nd1.pa[pl.position])/nd1.na;
    if (bestWr<tmpWr || ( bestWr==tmpWr && bestPr<=tmpPr)) {
      bestWr = tmpWr;
      bestPr = tmpPr;
      bestMove = nd1.move;
    }
  }
  return bestMove;//
}

uctNode returnFriquentChildFromRoot(uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も訪問関数が良いものをリターンする。
  float bestNa=0;//
  uctNode bestMove=null;
  for (uctNode nd1 : root.children) {
    if (bestNa<nd1.na) {
      bestNa = nd1.na;
      bestMove = nd1;
    }
  }
  return bestMove;//
}
int returnBest2ChildrenFromRoot(player pl, uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものから２つをリターンする。
  float bestWr=0,bestPr=0;//
  int bestMove=-1;
  float secondWr=0, secondPr=0;//
  int secondMove=-1;
  for (uctNode nd1 : root.children) {
    float tmpWr = nd1.wa[pl.position] / nd1.na;
    float tmpPr = nd1.pa[pl.position] / nd1.na;
    if (bestWr<tmpWr || (bestWr==tmpWr && bestPr<=tmpPr)) {
      secondWr = bestWr;
      secondPr = bestPr;
      secondMove = bestMove;
      bestWr = tmpWr;
      bestPr = tmpPr;
      bestMove = nd1.move;
    } else
      if (secondWr<tmpWr || (secondWr==tmpWr && secondPr<=tmpPr)) {
        secondWr = tmpWr;
        secondPr = tmpPr;
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
