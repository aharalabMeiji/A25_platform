//////並列処理により、計算効率を上げたバージョン、チャンスノードは未実装
//////ここを利用する場合には、uctMcts.pdeと比較をして適切にバージョンアップすることが必要。

//int uctMctsMainLoopVer2(player pl) {
//  // console に計算経過を出力（マストではない。）
//  if (pl.myBoard.simulatorNumber%1000==10) {
//    uct.prize.getPrize3FromNodeList(pl.position, uct.rootNode.legalMoves);
//    if (uct.prize.getMove(1)!=null) {
//      //float winRate=uct.prize.w1;
//      //float error = sqrt(winRate*(1.0-winRate)/uct.prize.getMove(1).na)*1.96;
//      //float secondRate=0;
//      //if (uct.prize.getMove(3)!=null) {
//      //  secondRate=uct.prize.w3;
//      //} else if (uct.prize.getMove(2)!=null) {
//      //  secondRate=uct.prize.w2;
//      //}
//      //if (winRate-secondRate>error) {
//      //  print(++uct.cancelCount);
//      //  if ((uct.cancelCount)>=uct.cancelCountMax) {
//      //    println("　勝率の推定により着手が確定した");
//      //    println("試行回数("+pl.myBoard.simulatorNumber+")");
//      //    println("time=", millis()-startTime, "(ms)");
//      //    // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
//      //    int ret = returnBestChildFromRoot(pl, uct.rootNode);
//      //    if (pl.myBoard.attackChanceP()) {
//      //      pl.yellow = int(ret/25);
//      //      println("["+(ret%25+1)+"-"+(pl.yellow+1)+"]");
//      //      return ret%25;
//      //    } else {
//      //      println("["+(ret+1)+"]");
//      //      return ret;
//      //    }
//      //  }
//      //} else {
//      //  uct.cancelCount=0;
//      //}
//    }
//    print(".");
//  }
//  //println("uctMctsBrain:シミュレーション回数"+pl.myBoard.simulatorNumber);
//  uct.maxNodeWinrate=0.0;
//  int localStartTime=millis();
//  for (uctNode ancestor : uct.rootNode.legalMoves) {
//    pl.myBoard.simulatorNumber ++;
//    ancestor.myThread = new Thread(new uctMctsSubTask(pl, ancestor));
//  }
//  for (uctNode ancestor : uct.rootNode.legalMoves) {
//    ancestor.myThread.start();
//  }
//  for (uctNode ancestor : uct.rootNode.legalMoves) {
//    try {
//      ancestor.myThread.join();
//    } catch (InterruptedException e) {
//      e.printStackTrace(); // //<>// //<>// //<>//
//    }
//  }
//  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
//  println("time=", (millis()-localStartTime));
//  int ret = returnBestChildFromRoot(pl, uct.rootNode);
//  if (pl.myBoard.attackChanceP()) {
//    pl.yellow = int(ret/25);
//    println("["+(ret%25+1)+"-"+(pl.yellow+1)+"]");
//    return ret%25;
//  } else {
//    println("["+(ret+1)+"]");
//    return ret;
//  }
//}

//////並列処理により、計算効率を上げる。
//class uctMctsSubTask implements Runnable {
//  player pl;
//  uctNode ancestor;
//  int returnValue=-1;
//  uctMctsSubTask(player _pl, uctNode _ancestor) {
//    this.pl=_pl;
//    this.ancestor=_ancestor;
//  }
  

//  public void run() {
//    int localCount=0;
//    int localEndNodes=0;
//    board uctMainBoard=new board();
//    board uctSubBoard=new board();
//    uctNode uctNewNode = new uctNode();
//    winPoints uctWinPoint = new winPoints();
//    do {
//      localCount++;
//      if (localCount%2000==0){
//        //println("id="+ancestor.id+":"+localCount+":Winrate="+(ancestor.wa[pl.position]/ancestor.na));
//        if (ancestor.wa[pl.position]/ancestor.na < uct.maxNodeWinrate-0.01){
//          //println("成績が悪いので中断");
//          returnValue=1;
//          return ;
//        }
//      }
//      //for (int repeat=0; repeat<5; repeat++) {

//      for (uctNode nd : ancestor.activeNodes) {
//        for (int p=1; p<=4; p++) {
//          // シミュレーション総回数はpl.myBoard.simulatorNumber
//          // 平均パネル枚数に0.04かけて、加算している。
//          nd.uct[p] = nd.UCTwp(p, int(ancestor.na+1));
//        }
//      }
//      //println("uct値が最大となるノードを見つける");
//      float uctMax=-1;
//      uctNode uctMaxNode=null;
//      for (int zz=ancestor.activeNodes.size()-1; zz>=0; zz--) {
//        uctNode nd = ancestor.activeNodes.get(zz);
//        if (nd.na >= uct.expandThreshold && nd.depth >= uct.depthMax) {//
//          ancestor.activeNodes.remove(zz);
//          //println("末端のノード("+nd.id+")がいっぱいになったのでアクティブノードのリストから消去");
//        } else if (nd.uct[nd.player]>uctMax) {
//          uctMax=nd.uct[nd.player];
//          uctMaxNode = nd;
//        }
//      }
//      if (uctMaxNode==null) {
//        //  println("計算すべきノードが尽きた先祖がいる");
//        //  println("試行回数("+pl.myBoard.simulatorNumber+")");
//        //  println("time=", millis()-startTime, "(ms)");
//        //  //PrintWriter output = createWriter("output.txt");
//        //  //showAllMct(uct.rootNode, pl.myBoard.simulatorNumber, output);
//        //  //output.flush();
//        //  //output.close();
//        //println("ループ終了（計算すべきノードが尽きた時）");
//        returnValue=0;
//        println("id="+ancestor.id+":"+localCount+"nodes="+localEndNodes+":Winrate="+(ancestor.wa[pl.position]/ancestor.na));
//        if (uct.maxNodeWinrate<ancestor.wa[pl.position]/ancestor.na){
//          uct.maxNodeWinrate = ancestor.wa[pl.position]/ancestor.na;
//        }
//        return ;
//        //  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
//        //  int ret = returnBestChildFromRoot(pl, uct.rootNode);
//        //  if (pl.myBoard.attackChanceP()) {
//        //    pl.yellow = int(ret/25);
//        //    println("["+(ret%25+1)+"-"+(pl.yellow+1)+"]");
//        //    return ret%25;
//        //  } else {
//        //    println("["+(ret+1)+"]");
//        //    return ret;
//        //  }
//        //{
//        //boolean atsuzokkou=false;
//        //for (uctNode ancestor2 : uct.rootNode.legalMoves) {
//        //  if (ancestor2.activeNodes.size()>0) {
//        //    atsuzokkou=true;
//        //    break;
//        //  }
//        //}
//        //if (!atsuzokkou) {
//        //  println("計算すべきノードが尽きた");
//        //  println("試行回数("+pl.myBoard.simulatorNumber+")");
//        //  println("time=", millis()-startTime, "(ms)");
//        //  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
//        //  int ret = returnBestChildFromRoot(pl, uct.rootNode);
//        //  if (pl.myBoard.attackChanceP()) {
//        //    pl.yellow = int(ret/25);
//        //    println("["+(ret%25+1)+"-"+(pl.yellow+1)+"]");
//        //    return ret%25;
//        //  } else {
//        //    println("["+(ret+1)+"]");
//        //    return ret;
//        //  }
//        //}// すべての先祖が終わったら、そこでおわり
//        //}
//      }// あとで、これやめるかも（すべての先祖が終わったら、そこでおわり、とか）
//      else {
//        //println("uctMctsBrain:",uctMaxNode.id, "のノードを調べる");
//        //println("uctMctsBrain:uctMainBoardへ盤面をコピー");
//        uctMainBoard.copyBdToBoard(uctMaxNode.bd);
//        //println("uctMctsBrain:uctMainBoardを最後まで打ち切る");
//        uctWinPoint = playSimulatorToEnd(uctMainBoard, uct.participants, 0);
//        //println("uctMctsBrain:nd.wa[p]、nd.pa[p]、nd.uct[p]");
//        uctMaxNode.na ++;//旧対応
//        for (int p=1; p<=4; p++) {
//          uctMaxNode.wa[p] += uctWinPoint.points[p];//2回め以降は和
//          uctMaxNode.pa[p] += uctWinPoint.panels[p];//2回め以降は和
//        }

//        //println("親にさかのぼってデータを更新する");
//        uctNode nd0 = uctMaxNode;
//        do {
//          if (nd0.parent!=null) {
//            nd0 = nd0.parent;
//            nd0.na ++;
//            for (int p=1; p<=4; p++) {
//              nd0.wa[p] += uctWinPoint.points[p];//2回め以降は和
//              nd0.pa[p] += uctWinPoint.panels[p];//2回め以降は和
//            }
//            //println("uctMctsBrain:→　ノード ",nd0.id, "のデータ("+nd0.wa[1]+","+nd0.wa[2]+","+nd0.wa[3]+","+nd0.wa[4]+")/"+nd0.na);
//          } else {// ルートまでたどり着いた、の意味
//            break;
//          }
//        } while (true);//println("親にさかのぼってデータを更新する");//おわり

//        //println("uctMctsBrain:ノード ",uctMaxNode.id, "のデータ("+uctMaxNode.wa[1]+","+uctMaxNode.wa[2]+","+uctMaxNode.wa[3]+","+uctMaxNode.wa[4]+")/"+uctMaxNode.na);
//        //println("uctMctsBrain:",uctMaxNode.na, uctMaxNode.wa[uctMaxNode.player], uctMaxNode.pa[uctMaxNode.player]);
//        if (uctMaxNode.na >= uct.expandThreshold) {// 削除するための条件
//          //println("uctMctsBrain:uctMaxNodeはuct.activeNodesから削除");
//          //展開するにせよしないにせよ、この作業は等価に必要。
//          for (int zz=ancestor.activeNodes.size()-1; zz>=0; zz--) {
//            if (ancestor.activeNodes.get(zz)==uctMaxNode) {
//              //println("ノード"+uctMaxNode.id+"をアクティブノードのリストから消去");
//              ancestor.activeNodes.remove(zz);//枝を打ち切る

//              break;
//            }
//          }
//          if (uctMaxNode.depth<uct.depthMax && uctMaxNode.id!="") {   // 展開するための条件
//            //println("uctMctsBrain:展開　"+uctMaxNode.id);/////////////////////////////ここから展開
//            //println(uctMaxNode.id+"を展開中");//+returnFriquentChildFromRoot(uct.rootNode).id);
//            // uctMaxNodeの下にノードをぶら下げる
//            uctNewNode=null;
//            for (int p=1; p<5; p++) {
//              if (uctMaxNode.move==25){                
//                if (uctMaxNode.player==p){
//                  print("pass.");
//                  continue;
//                }
//              }
//              //println("プレイヤー"+p+"の着手を追加");
//              uctMainBoard.copyBdToBoard(uctMaxNode.bd);
//              uctMainBoard.buildVP(p);
//              ArrayList<uctNode> tmpUctNodes = new ArrayList<uctNode>();//いったんここにぶら下げる。
//              //println("uctMctsBrain: uctMaxNodeの盤面でプレイヤー"+p+"の合法手をリストアップ");
//              if (uctMainBoard.attackChanceP()==false) {
//                // アタックチャンスでないときの、子ノードのぶらさげ
//                uctMaxNode.attackChanceNode=false;
//                for (int k=0; k<25; k++) {
//                  // 合法手ごとのforループ
//                  if (uctMainBoard.vp[k]>0) {
//                    // 子ノードをぶら下げる
//                    uctNewNode = new uctNode();
//                    uctNewNode.setItem(p, k);
//                    uctNewNode.id = uctMaxNode.id+":"+kifu.playerColCode[p]+nf(k+1, 2);
//                    uctNewNode.depth = uctMaxNode.depth+1;
//                    //println("uctMctsBrain: id="+uctNewNode.id);
//                    tmpUctNodes.add(uctNewNode);// tmpUctNodesに追加する
//                    uctNewNode.parent = uctMaxNode;//uctMaxNodeを親に設定
//                    //println("新しいノード "+uctNewNode.id+"を追加した！");
//                    uctMainBoard.copyBoardToSub(uctSubBoard);
//                    uctSubBoard.move(p, k);// 1手着手する
//                    uctSubBoard.copyBoardToBd(uctNewNode.bd);
//                    //uctNewNode.printlnBd();
//                  }
//                }
//              } else {
//                // アタックチャンスのときの、子ノードのぶらさげ
//                uctMaxNode.attackChanceNode=true;

//                for (int j=0; j<25; j++) { //加えるパネル
//                  for (int i=0; i<25; i++) { //黄色にするパネル
//                    int k = i*25+j;
//                    if ((uctMainBoard.vp[j]>0 && (uctMainBoard.s[i].col>=1 && uctMainBoard.s[i].col<=4)) || (uctMainBoard.vp[j]>0 && i==j)) {
//                      uctNewNode = new uctNode();
//                      uctNewNode.setItem(p, k);
//                      uctNewNode.id = uctMaxNode.id + (":"+kifu.playerColCode[pl.position]+nf(j+1, 2)) + (":Y"+nf(i+1, 2));
//                      uctNewNode.depth = uctMaxNode.depth + 1;
//                      //println("uctMctsBrain: id="+uctNewNode.id);
//                      tmpUctNodes.add(uctNewNode);//tmpUctNodesにぶら下げる
//                      uctNewNode.parent = uctMaxNode;//
//                      //println("新しいノード "+uctNewNode.id+"を追加した！");
//                      uctMainBoard.copyBoardToSub(uctSubBoard);
//                      uctSubBoard.move(p, j);// 1手着手する
//                      uctSubBoard.s[i].col = 5;// 黄色を置く
//                      uctSubBoard.copyBoardToBd(uctNewNode.bd);
//                      uctNewNode.attackChanceNode=true;
//                    }
//                  }
//                }
//              }// ACノードの子ノード作成終わり。
//              // 子ノードをぶら下げるここまで
//              // TODO: 5回
//              for (uctNode nd : tmpUctNodes) {
//                nd.na=0;
//                for (int pp=1; pp<=4; pp++) {
//                  nd.wa[pp] = 0;//
//                  nd.pa[pp] = 0;//
//                }
//                for (int count=0; count<5; count++) {
//                  uctSubBoard.copyBdToBoard(nd.bd);
//                  //println("uctMctsBrain:そこから最後までシミュレーションを行う");
//                  winPoints wpwp = playSimulatorToEnd(uctSubBoard, uct.participants, 0);//
//                  nd.na ++;//
//                  pl.myBoard.simulatorNumber ++;
//                  for (int pp=1; pp<=4; pp++) {
//                    nd.wa[pp] += wpwp.points[pp];//
//                    nd.pa[pp] += wpwp.panels[pp];//
//                    //println("uctMctsBrain:"+pp,uctNewNode.wa[p], uctNewNode.pa[p]);
//                  }
//                }
//                //println("親にさかのぼってデータを更新する");
//                nd0 = nd;
//                do {
//                  if (nd0.parent!=null) {
//                    nd0 = nd0.parent;
//                    nd0.na +=nd.na;
//                    for (int pp=1; pp<=4; pp++) {
//                      nd0.wa[pp] += nd.wa[pp];//
//                      nd0.pa[pp] += nd.pa[pp];//
//                    }
//                    //println("uctMctsBrain:→　ノード ",nd0.id, "のデータ("+nd0.wa[1]+","+nd0.wa[2]+","+nd0.wa[3]+","+nd0.wa[4]+")/"+nd0.na);
//                  } else {// ルートまでたどり着いた、の意味
//                    break;
//                  }
//                } while (true);
//                // バックプロパゲートここまで
//              }// 全部の新しいノードを５回ずつ試行した。
//              if (uctMaxNode.childR==null) {//
//                uctMaxNode.childR = new ArrayList<uctNode>();
//              }
//              if (uctMaxNode.childG==null) {//
//                uctMaxNode.childG = new ArrayList<uctNode>();
//              }
//              if (uctMaxNode.childW==null) {//
//                uctMaxNode.childW = new ArrayList<uctNode>();
//              }
//              if (uctMaxNode.childB==null) {//
//                uctMaxNode.childB = new ArrayList<uctNode>();
//              }
//              for (uctNode nd : tmpUctNodes) {
//                switch(p){
//                  case 1: 
//                  uctMaxNode.childR.add(nd);//親ノードにぶら下げた
//                  if (nd.depth==uct.depthMax){
//                    localEndNodes ++;
//                  }
//                  break;
//                  case 2: 
//                  uctMaxNode.childG.add(nd);//親ノードにぶら下げた
//                  if (nd.depth==uct.depthMax){
//                    localEndNodes ++;
//                  }
//                  break;
//                  case 3: 
//                  uctMaxNode.childW.add(nd);//親ノードにぶら下げた
//                  if (nd.depth==uct.depthMax){
//                    localEndNodes ++;
//                  }
//                  break;
//                  case 4: 
//                  uctMaxNode.childB.add(nd);//親ノードにぶら下げた
//                  if (nd.depth==uct.depthMax){
//                    localEndNodes ++;
//                  }
//                  break;
//                }  
//                ancestor.activeNodes.add(nd);//アクティブなノードのリストに追加
//                nd.ancestor = ancestor;
//                //println("新しいノード("+nd.id+")を追加");
//              }
//            }//ここまで、４人分のノード展開
//          }
//        }// アクティブノード削除からの展開、ここまで
//        //if (pl.myBoard.simulatorNumber >= uct.terminateThreshold) {//
//        //  println("試行回数上限到達("+pl.myBoard.simulatorNumber+")");
//        //  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
//        //  int ret = returnBestChildFromRoot(pl, uct.rootNode);
//        //  println("time=", millis()-startTime, "(ms)");
//        //  if (pl.myBoard.attackChanceP()) {
//        //    pl.yellow = int(ret/25);
//        //    println("["+(ret%25+1)+"-"+(pl.yellow+1)+"]");
//        //    return ret%25;
//        //  } else {
//        //    println("["+(ret+1)+"]");
//        //    return ret;
//        //  }
//        //}
//      }
//    } while (returnValue==-1);
//  }
//}
