int uctMctsBrain(player pl) { //
  //ここから
  startTime=millis();
  int answer = uctMctsStartingJoseki(pl);
  if (answer!=-1) return answer;
  answer = uctMctsBrainPreparation(pl);
  if (answer==-1) return -1;
  answer = uctMctsBrainFirstSimulation(pl);

  if (answer!=-1) return answer;
  println("uct ", uct.expandThreshold, uct.depthMax, uct.cancelCountMax);//uct.terminateThreshold, 
  //uct.simulationTag=uct.expandThreshold*10;
  while (true) {
    if (uct.uctMainLoopOption==1) {
      answer = uctMctsMainLoop(pl);
    } else {
      answer = uctMctsMainLoopVer2(pl);
    }
    for (int k=0; k<25; k++) {// 今のところ、この書き換えは反映されない。
      utils.gameMainBoard.s[k].shaded=pl.myBoard.s[k].shaded;
    }
    if (answer!=-1) return answer;
  }// end of while(true)
}



int uctMctsBrainPreparation(player pl) {
  //println("uctMctsBrain:プレーヤーをランダムエージェントに設定");
  uct.participants = new player[5];
  for (int p=1; p<5; p++) {
    uct.participants[p] = new player(p, "random", brain.Random);
  }
  //println("uctMctsBrain:着手可能点を計算しておく");
  pl.myBoard.buildVP(pl.position);
  //pl.myBoard.deleteSymmetricVp();
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
  //uct.activeNodes = new ArrayList<uctNode>();
  //println("uctMctsBrain:ループ回数のカウント");
  pl.myBoard.simulatorNumber=0;
  //println("uctMctsBrain:UCT準備");
  uct.newNode = null;
  uct.rootNode = new uctNode();
  uct.rootNode.parent = null;
  uct.rootNode.legalMoves = new ArrayList<uctNode>();
  uct.cancelCount=0;
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
        uct.rootNode.legalMoves.add(uct.newNode);//ルートノードにぶら下げる
        uct.newNode.ancestor = uct.newNode;// 自分自身が先祖
        uct.newNode.parent = null;//逆伝播をここで切りたいので
        uct.newNode.onRGWB = new boolean[5];
        for(int p=1; p<5; p++){
          uct.newNode.onRGWB[p]=true;
        }//4つのチャンスノードは有効
        pl.myBoard.copyBoardToSub(uct.mainBoard);
        uct.mainBoard.move(pl.position, k);//一手進める
        uct.mainBoard.copyBoardToBd(uct.newNode.bd);
        uct.newNode.attackChanceNode=false;
      }
    }
    //println("uctMctsBrain:手抜きという選択肢を考える");
    if (pl.noPass==0) {
      uct.newNode = new uctNode();
      uct.newNode.setItem(pl.position, 25);
      uct.newNode.id = uct.rootNode.id+(":"+kifu.playerColCode[pl.position]+nf(26, 2));
      uct.newNode.depth = 1;
      uct.rootNode.legalMoves.add(uct.newNode);//ルートノードにぶら下げる
      uct.newNode.ancestor = uct.newNode;
      uct.newNode.parent = null;//
      uct.newNode.onRGWB = new boolean[5];
      for(int p=1; p<5; p++){
        if (pl.position==p) uct.newNode.onRGWB[p]=false;
        else uct.newNode.onRGWB[p]=true;
      } //ノードをつるさない場合はフラグを倒しておく
      pl.myBoard.copyBoardToSub(uct.mainBoard);
      uct.mainBoard.copyBoardToBd(uct.newNode.bd);
      uct.newNode.attackChanceNode=false;//念のため倒しておく。
    }
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
          uct.rootNode.legalMoves.add(uct.newNode);//ぶら下げる
          uct.newNode.ancestor = uct.newNode;
          uct.newNode.parent = null;//
          uct.newNode.onRGWB = new boolean[5];
          for(int p=1; p<5; p++){
            uct.newNode.onRGWB[p]=true;
          }//4つのチャンスノードは有効
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
  uct.underCalculation=0;//計算厨であることを示すフラグ
  return 0;// トラブルなく終わる
}

int uctMctsBrainFirstSimulation(player pl) {
  for (uctNode nd : uct.rootNode.legalMoves) {
    // パラメータの初期化
    nd.na=0; nd.naR=0; nd.naG=0; nd.naW=0; nd.naB=0;
    for (int p=1; p<=4; p++) {
      nd.wa[p]=0; nd.waR[p]=0; nd.waG[p]=0; nd.waW[p]=0; nd.waB[p]=0;//
      nd.pa[p]=0; nd.paR[p]=0; nd.paG[p]=0; nd.paW[p]=0; nd.paB[p]=0;//
    }
    //println("uctMctsBrain:最後までシミュレーションを_count回行う");
    // ここをUCBにするアイディアもあるが、結局淘汰されるようなので、０でなければなんでもいいみたい。
    for (int count=0; count<4; count++) {
      //ndが26番（パス）の場合、そのプレーヤの文の初期シミュレーションは行わない。
      int nextplayer = count+1;
      if (nd.onRGWB[nextplayer]==false){
        continue;
      }
      uct.mainBoard.copyBdToBoard(nd.bd);
      uct.winPoint = playSimulatorToEnd(uct.mainBoard, uct.participants, nextplayer);//ここは次手番をnextplayerとする。
      pl.myBoard.simulatorNumber ++;
      if(uct.chanceNodeOn){// 「新式」//uct.chanceNodeOn=true;
        if(nextplayer==1){
          nd.naR ++;
          for (int p=1; p<=4; p++) {
            nd.waR[p] += uct.winPoint.points[p];//
            nd.paR[p] += uct.winPoint.panels[p];//
          }
        } else if(nextplayer==2){
          nd.naG ++;
          for (int p=1; p<=4; p++) {
            nd.waG[p] += uct.winPoint.points[p];//
            nd.paG[p] += uct.winPoint.panels[p];//
          }
        } else if(nextplayer==3){
          nd.naW ++;
          for (int p=1; p<=4; p++) {
            nd.waW[p] += uct.winPoint.points[p];//
            nd.paW[p] += uct.winPoint.panels[p];//
          }
        } else { //if(nextplayer==4){
          nd.naB ++;
          for (int p=1; p<=4; p++) {
            nd.waB[p] += uct.winPoint.points[p];//
            nd.paB[p] += uct.winPoint.panels[p];//
          }
        }
        nd.na ++;//
        // nd.na = nd.naR + nd.naG + nd.naW + nd.naB;
        for (int p=1; p<=4; p++) {
          nd.wa[p] = uct.averageBackPropagate(nd.waR[p],nd.naR,nd.waG[p],nd.naG,nd.waW[p],nd.naW,nd.waB[p],nd.naB,nd.na);
          nd.pa[p] = uct.averageBackPropagate(nd.paR[p],nd.naR,nd.paG[p],nd.naG,nd.paW[p],nd.naW,nd.paB[p],nd.naB,nd.na);
        }
      } else {// 旧式
        nd.na ++;//
        for (int p=1; p<=4; p++) {
          nd.wa[p] += uct.winPoint.points[p];//
          nd.pa[p] += uct.winPoint.panels[p];//
        }
      }
    }
  }
  //uct.prize.getPrize1FromNodeList(pl.position, uct.rootNode.legalMoves);// 勝率の最善をピックアップ
  //float bestWr=uct.prize.w1;
  //if (bestWr>0.0 && bestWr<1.0) {
  //  float lowerBound = bestWr - sqrt(bestWr*(1.0-bestWr)/uct.prize.m1.na)*4.0;// 最善勝率より、かなり低い枝はカットする。
  //  if (lowerBound>0) {
  //    int listSize=uct.rootNode.legalMoves.size();
  //    for (int id=listSize-1; id>=0; id--) {
  //      uctNode nd=uct.rootNode.legalMoves.get(id);
  //      //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, lowerBound);
  //      if (nd.wa[pl.position]/nd.na < lowerBound) {
  //        uct.rootNode.legalMoves.remove(nd);
  //        //print(":deleted");
  //      }
  //      //println();
  //    }
  //  }
  //} else if (bestWr>=1.0) {// 優勝が決まっているときには、優勝を逃す可能性のある枝を切る。
  //  int listSize=uct.rootNode.legalMoves.size();
  //  for (int id=listSize-1; id>=0; id--) {
  //    uctNode nd=uct.rootNode.legalMoves.get(id);
  //    //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, "1");
  //    if (nd.wa[pl.position]/nd.na < 1.0) {
  //      uct.rootNode.legalMoves.remove(nd);
  //      //print(":deleted");
  //    }
  //    //println();
  //  }
  //}
  //アクティブなノードをリスト化する。
  //ここがバージョン２//深さ１のノードのそれぞれにアクティブなノードをぶら下げる。
  for (uctNode nd : uct.rootNode.legalMoves) {
    nd.activeNodes = new ArrayList<uctNode>();
    nd.activeNodes.add(nd);// 26番であっても、アクティブなノードである。
    nd.ancestor = nd;
  }
  //
  if (uct.rootNode.legalMoves.size()==1) {
    /// 選択肢が一つの時には、それを答える。
    int ret=uct.rootNode.legalMoves.get(0).move;
    //println("["+uct.rootNode.legalMoves.get(0).id+"]");
    if (pl.myBoard.attackChanceP()) {
      pl.yellow = int(ret/25);
      return ret%25;
    } else {
      return ret;
    }
  }
  return -1;
}

void printAllWaPa(uctNode nd){
  if ( nd.depth<=3){
    println(""+nd.id+","+(nd.wa[1]/nd.na)+","+(nd.wa[2]/nd.na)+","+(nd.wa[3]/nd.na)+","+(nd.wa[4]/nd.na)+","+(nd.pa[1]/nd.na)+","+(nd.pa[2]/nd.na)+","+(nd.pa[3]/nd.na)+","+(nd.pa[4]/nd.na)+","+nd.na+"");
  }
  if (nd.childR!=null && nd.childR.size()>0){
    for(uctNode nd2: nd.childR){
      printAllWaPa(nd2);
    }
  }
  if (nd.childG!=null && nd.childG.size()>0){
    for(uctNode nd2: nd.childG){
      printAllWaPa(nd2);
    }
  }
  if (nd.childW!=null && nd.childW.size()>0){
    for(uctNode nd2: nd.childW){
      printAllWaPa(nd2);
    }
  }
  if (nd.childB!=null && nd.childB.size()>0){
    for(uctNode nd2: nd.childB){
      printAllWaPa(nd2);
    }
  }
}

int uctMctsMainLoop(player pl) {
  //uctMctsMainLoop block 01
  // console に計算経過を出力（マストではない。）
  uct.prize.getPrize3FromNodeList(pl.position, uct.rootNode.legalMoves); //<>//
  if (uct.prize.getMove(1)!=null) {
    float winRate=uct.prize.w1;
    float error = sqrt(winRate*(1.0-winRate)/uct.prize.getMove(1).na)*1.96;
    float secondRate=0;
    if (uct.prize.getMove(3)!=null) {
      secondRate=uct.prize.w3;
    } else if (uct.prize.getMove(2)!=null) {
      secondRate=uct.prize.w2;
    }
    if (winRate-secondRate>error) {
      if ((uct.cancelCount)>=uct.cancelCountMax) {
        println("勝率の推定により着手が確定した");
        println("試行回数(",pl.myBoard.simulatorNumber,")");
        println("time=", millis()-startTime, "(ms)");
        uct.underCalculation=10;
        // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
        int ret = returnBestChildFromRoot(pl, uct.rootNode);
        if (pl.myBoard.attackChanceP()) {
          pl.yellow = int(ret/25);
          println("[",(ret%25+1)+"-"+(pl.yellow+1),"]");
          return ret%25;
        } else {
          println("[",(ret+1),"]");
          println(""+simulator.mainBoard.sv[ret]+" : "+simulator.mainBoard.sv2[ret]);
          return ret;
        }
      }
    } else {
      uct.cancelCount=0;
    }
  }
  uct.underCalculation ++;
  if (uct.underCalculation==3) uct.underCalculation=0;
  //uctMctsMainLoop block 02
  for (int repeat=0; repeat<1000; repeat++) {
    //uctMctsMainLoop block 02-1
    // VERSION2
    for (uctNode ancestor : uct.rootNode.legalMoves) {//root直下に、先祖たちがぶら下がっている。
      for (uctNode nd : ancestor.activeNodes) {// 先祖たちにはアクティブノード（葉）がぶら下がっている。
        for (int p=1; p<=4; p++) {
          // シミュレーション総回数はpl.myBoard.simulatorNumber
          // 平均パネル枚数に0.04かけて、加算している。
          nd.uct[p] = nd.UCTwp(p, pl.myBoard.simulatorNumber);
          //nd.uct[p] = nd.UCTa(p, pl.myBoard.simulatorNumber);
        }
      }
    }

    //uctMctsMainLoop block 02-2
    for (uctNode ancestor : uct.rootNode.legalMoves) {//

      //println("ancestorごとに、uct値が最大となるアクティブノードを見つける");
      //uctMctsMainLoop block 02-2-1
      float uctMax=-1;
      uctNode uctMaxNode=null;
      for (int zz=ancestor.activeNodes.size()-1; zz>=0; zz--) {//消去する可能性があるので、後ろからサーチする。
        uctNode nd = ancestor.activeNodes.get(zz);
        if (nd.na >= uct.expandThreshold && nd.depth >= uct.depthMax) {//試行回数がマックス、かつ深さもマックス
          //println("試行回数がマックス、かつ深さもマックスなので、"+nd.id+"を展開せずにアクティブノードのリストから消去");
          ancestor.activeNodes.remove(zz);// 展開せずにアクティブノードのリストから消去        
        } else if (nd.uct[nd.player]>uctMax) {// uct局所最大なら、記録しておく。
          uctMax=nd.uct[nd.player];
          uctMaxNode = nd;
        }
      }
      //uctMctsMainLoop block 02-2-2
      // このancestorの下のアクティブノードが尽きたとき。
      if (uctMaxNode==null) {
        //よそのancestorで、続行するかを調査
        boolean anotherAncestor=false;
        for (uctNode ancestor2 : uct.rootNode.legalMoves) {
          if (ancestor2.activeNodes.size()>0) {
            anotherAncestor=true;
            break;
          }
        }
        if (!anotherAncestor) {
          println("すべてのancestorでアクティブノードが尽きた");
          println("試行回数(",pl.myBoard.simulatorNumber,")");
          println("time=", millis()-startTime, "(ms)");
          uct.underCalculation=10;
          //内部データのチェック用;
          //for(uctNode anc : uct.rootNode.legalMoves){
          //  printAllWaPa(anc);
          //}
          // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
          int ret = returnBestChildFromRoot(pl, uct.rootNode); //<>//
          if (pl.myBoard.attackChanceP()) {
            pl.yellow = int(ret/25);
            println("[",(ret%25+1)+"-"+(pl.yellow+1),"]");
            return ret%25;
          } else {
            println("[",(ret+1),"]");
            println(""+simulator.mainBoard.sv[ret]+" : "+simulator.mainBoard.sv2[ret]);
            return ret;
          }
        }// すべての先祖が終わったら、そこでおわり
        else {
          continue;
        }
      }//
      //uctMctsMainLoop block 02-2-3
      // uctMaxNodeから最後までランダムに打って
      // そののちに親までさかのぼって褒章データを更新する。
      pl.myBoard.simulatorNumber ++;
      uct.randomPlayAndBackPropagate(uctMaxNode,0);

      //uctMctsMainLoop block 02-2-4
      //println("uctMctsBrain:ノード ",uctMaxNode.id, "のデータ("+uctMaxNode.wa[1]+","+uctMaxNode.wa[2]+","+uctMaxNode.wa[3]+","+uctMaxNode.wa[4]+")/"+uctMaxNode.na);
      //println("uctMctsBrain:",uctMaxNode.na, uctMaxNode.wa[uctMaxNode.player], uctMaxNode.pa[uctMaxNode.player]);
      if (uctMaxNode.na >= uct.expandThreshold) {// 削除するための条件
        //println("uctMctsBrain:uctMaxNodeはuct.activeNodesから削除");
        //展開するにせよしないにせよ、この作業は等価に必要。
        for (int zz=ancestor.activeNodes.size()-1; zz>=0; zz--) {
          if (ancestor.activeNodes.get(zz)==uctMaxNode) {
            //println("ノード"+uctMaxNode.id+"をアクティブノードのリストから消去");
            ancestor.activeNodes.remove(zz);//枝を打ち切る
            break;
          }
        }
        if (uctMaxNode.depth<uct.depthMax && uctMaxNode.id!="" && remaingInBd(uctMaxNode.bd)>0) {   // 展開するための条件
          // remaingInBd(uctMaxNode.bd) : 残り空パネルの個数。
          //println("uctMctsBrain:展開　"+uctMaxNode.id);////展開開始展開開始展開開始展開開始展開開始展開開始
          //println(uctMaxNode.id+"を展開中");//+returnFriquentChildFromRoot(uct.rootNode).id);

          uct.newNode=null;
          uctMaxNode.legalMoves=null;
          // チャンスノードを別途ぶら下げる案を却下。
          //旧来のノード構成で、ぶら下げる場所を4か所作る（メモリとスピードの節約のため）
          if (uctMaxNode.childR==null) uctMaxNode.childR = new ArrayList<uctNode>();
          if (uctMaxNode.childG==null) uctMaxNode.childG = new ArrayList<uctNode>();
          if (uctMaxNode.childW==null) uctMaxNode.childW = new ArrayList<uctNode>();
          if (uctMaxNode.childB==null) uctMaxNode.childB = new ArrayList<uctNode>();
          for (int p=1; p<5; p++) {// 4人分の作業ここから
            //uctMctsMainLoop block 02-2-4-1
            // パス選択のノードには、繰り返し同じプレイヤーを扱わない。
            if (ancestor.move==25 && uctMaxNode.depth==1){
              print("[pass]");
              continue;
            }
            if (ancestor.move==25){
              if (uctMaxNode.depth==1){
                if (gameOptions.get("Absence0R")==1 && p==1){
                  print("[R]");
                  continue;
                }
                if (gameOptions.get("Absence0G")==1 && p==2){
                  print("[G]");
                  continue;
                }
                if (gameOptions.get("Absence0W")==1 && p==3){
                  print("[W]");
                  continue;
                }
                if (gameOptions.get("Absence0B")==1 && p==4){
                  print("[B]");
                  continue;
                }
              }
              else if (uctMaxNode.depth==2){
                if (gameOptions.get("Absence1R")==1 && p==1){
                  print("[R]");
                  continue;
                }
                if (gameOptions.get("Absence1G")==1 && p==2){
                  print("[G]");
                  continue;
                }
                if (gameOptions.get("Absence1W")==1 && p==3){
                  print("[W]");
                  continue;
                }
                if (gameOptions.get("Absence1B")==1 && p==4){
                  print("[B]");
                  continue;
                }
              }
            } else {
              if (uctMaxNode.depth==1){
                if (gameOptions.get("Absence1R")==1 && p==1){
                  print("[R]");
                  continue;
                }
                if (gameOptions.get("Absence1G")==1 && p==2){
                  print("[G]");
                  continue;
                }
                if (gameOptions.get("Absence1W")==1 && p==3){
                  print("[W]");
                  continue;
                }
                if (gameOptions.get("Absence1B")==1 && p==4){
                  print("[B]");
                  continue;
                }
              }
            }
            //uctMctsMainLoop block 02-2-4-2
            //println("プレイヤー"+p+のチャンスノードをuctMaxNodeに追加);//展開中
            //println("uctMaxNodeの盤面をuct.mainBoardにコピーして、新規ノードのデータを作る。");
            uct.mainBoard.copyBdToBoard(uctMaxNode.bd);
            //println("uctMctsBrain: uctMaxNodeの盤面でプレイヤー"+p+"の合法手をリストアップ");
            uct.mainBoard.buildVP(p);
            //println("新規ノードを作り、プレイヤー"+p+"の着手を入れて、これをchildRなどにぶらさげる");
            //uctMctsMainLoop block 02-2-4-3
            if (uct.mainBoard.attackChanceP()==false) {
              //uctMctsMainLoop block 02-2-4-3-1
              // アタックチャンスでないときの、子ノードのぶらさげ//ただいま展開中
              uctMaxNode.attackChanceNode=false;
              for (int k=0; k<25; k++) {   // 合法手ごとのforループ、パスは含まない
                if (uct.mainBoard.vp[k]>0) { // 子ノードをぶら下げる
                  uct.newNode = new uctNode();
                  uct.newNode.setItem(p, k);
                  uct.newNode.id = uctMaxNode.id+":"+kifu.playerColCode[p]+nf(k+1, 2);
                  uct.newNode.depth = uctMaxNode.depth+1;//=newChancenode.depth
                  //println("新しいノード "+uct.newNode.id+"を追加した！");
                  switch(p) {
                  case 1:
                    uctMaxNode.childR.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
                    break;
                  case 2:
                    uctMaxNode.childG.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
                    break;
                  case 3:
                    uctMaxNode.childW.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
                    break;
                  case 4:
                    uctMaxNode.childB.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
                    break;
                  }
                  uct.newNode.parent = uctMaxNode;//uctMaxNodeをuct.newNodeの親に設定
                  uct.newNode.ancestor = ancestor;//uct.newNodeのご先祖さまを記録
                  ancestor.activeNodes.add(uct.newNode);//ご先祖様のアクティブノードに登録
                  //println("新しいノードに盤情報を記入");
                  uct.mainBoard.copyBoardToSub(uct.subBoard);
                  uct.subBoard.move(p, k);// 1手着手する
                  uct.subBoard.copyBoardToBd(uct.newNode.bd);
                  //uct.newNode.printlnBd();
                  // println("新しいノードで4回ランダム試行を行う。");// アタックチャンスでないとき//展開中
                  // uct.newNodeの報酬データを初期化
                  uct.newNode.initRewardOfNode();
                  // 4回、最後まで打ち切ってバックプロパゲートしておく。
                  // uct値を有効にするため。
                  for (int count=0; count<4; count++) {
                    pl.myBoard.simulatorNumber ++;
                    uct.randomPlayAndBackPropagate(uct.newNode, count+1);
                  }
                }
              }// 合法手ごとのforループ ここまで
            } else {
              //uctMctsMainLoop block 02-2-4-3-2
              // アタックチャンスのときの、子ノードのぶらさげ//ただいま展開中
              uctMaxNode.attackChanceNode=true;
              // 合法手ごとのforループ
              for (int j=0; j<25; j++) { //加えるパネル
                for (int i=0; i<25; i++) { //黄色にするパネル
                  int k = i*25+j;
                  if ((uct.mainBoard.vp[j]>0 && (uct.mainBoard.s[i].col>=1 && uct.mainBoard.s[i].col<=4)) || (uct.mainBoard.vp[j]>0 && i==j)) {
                    uct.newNode = new uctNode();
                    uct.newNode.setItem(p, k);
                    uct.newNode.id = uctMaxNode.id + (":"+kifu.playerColCode[p]+nf(j+1, 2)) + (":Y"+nf(i+1, 2));
                    uct.newNode.depth = uctMaxNode.depth + 1;//=newChancenode.depth
                    //println("uctMctsBrain: id="+uct.newNode.id);
                    switch(p) {
                    case 1:
                      uctMaxNode.childR.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
                      break;
                    case 2:
                      uctMaxNode.childG.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
                      break;
                    case 3:
                      uctMaxNode.childW.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
                      break;
                    case 4:
                      uctMaxNode.childB.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
                      break;
                    }
                    uct.newNode.parent = uctMaxNode;//uctMaxNodeをuct.newNodeの親に設定
                    uct.newNode.ancestor = ancestor;//uct.newNodeのご先祖さまを記録
                    ancestor.activeNodes.add(uct.newNode);//ご先祖様のアクティブノードに登録
                    //println("新しいノード "+uct.newNode.id+"を追加した！");
                    uct.mainBoard.copyBoardToSub(uct.subBoard);
                    uct.subBoard.move(p, j);// 1手着手する
                    uct.subBoard.s[i].col = 5;// 黄色を置く
                    uct.subBoard.copyBoardToBd(uct.newNode.bd);
                    uct.newNode.attackChanceNode=true;
                    // println("新しいノードで５回ランダム試行を行う。");// アタックチャンスのとき//展開中
                    // uct.newNodeの報酬データを初期化
                    uct.newNode.initRewardOfNode();
                    // 4回、最後まで打ち切ってバックプロパゲートしておく。
                    // uct値を有効にするため。
                    for (int count=0; count<4; count++) {
                      pl.myBoard.simulatorNumber ++;
                      uct.randomPlayAndBackPropagate(uct.newNode, count+1);
                    }
                    //新規ノードの処理ここまで/// アタックチャンスのとき//展開中
                  }
                }
              }// 合法手ごとのforループ ここまで
            }// ACノードの子ノード作成終わり。
            // 子ノードをぶら下げるここまで//展開中
            //uctMctsMainLoop block 02-2-4-4
            // プレイヤーpにとって、筋の悪いものを消す。//この作業自体の筋が悪そうなので、コメアウト
            //uct.prize.getPrize1FromNodeList(p, tmpUctNodes);
            //float bestWr=uct.prize.w1;
            //if (bestWr>0.0 && bestWr<1.0) {
            //  float lowerBound = bestWr - sqrt(bestWr*(1.0-bestWr)/uct.prize.m1.na)*4.0;// not 1.96? lol
            //  if (lowerBound>0) {
            //    int listSize=tmpUctNodes.size();
            //    for (int id=listSize-1; id>=0; id--) {
            //      uctNode nd=tmpUctNodes.get(id);
            //      //print((nd.move%25)+1, int(nd.move/25)+1, nd.wa[pl.position]/nd.na, lowerBound);
            //      if (nd.wa[p]/nd.na < lowerBound) {
            //        tmpUctNodes.remove(nd);
            //        //print(":deleted");
            //      }
            //      //println();
            //    }
            //  }
            //}// プレイヤーpにとって、筋の悪いものを消す。ここまで
          }//ここまで、４人分のノード展開
          //println("uctMctsBrain:展開　終了　"+uctMaxNode.id);
        } 
        //else if (remaingInBd(uctMaxNode.bd)==0){
        //  println(""+uctMaxNode.id+","+uctMaxNode.wa[1]+","+uctMaxNode.wa[2]+","+uctMaxNode.wa[3]+","+uctMaxNode.wa[4]+","+uctMaxNode.pa[1]+","+uctMaxNode.pa[2]+","+uctMaxNode.pa[3]+","+uctMaxNode.pa[4]+","+uctMaxNode.na+"");
        //}
      }// アクティブノード削除からの展開、ここまで
      //uctMctsMainLoop block 02-2-5
      //if (pl.myBoard.simulatorNumber >= uct.terminateThreshold) {//
      //  println("試行回数上限到達(",pl.myBoard.simulatorNumber,")");
      //  uct.underCalculation=10;
      //  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
      //  int ret = returnBestChildFromRoot(pl, uct.rootNode);
      //  println("time=", millis()-startTime, "(ms)");
      //  //PrintWriter output = createWriter("output.txt");
      //  //showAllMct(uct.rootNode, pl.myBoard.simulatorNumber, output);
      //  //output.flush();
      //  //output.close();
      //  if (pl.myBoard.attackChanceP()) {
      //    pl.yellow = int(ret/25);
      //    println("[",(ret%25+1)+"-"+(pl.yellow+1),"]");
      //    return ret%25;
      //  } else {
      //    println("[",(ret+1),"]");
      //    println(""+simulator.mainBoard.sv[ret]+" : "+simulator.mainBoard.sv2[ret]);
      //    return ret;
      //  }
      //}
    }//for (uctNode ancestor : uct.rootNode.children)ここまで
  }
  return -1;
}


void showAllMct(uctNode nd, int totalNumber, PrintWriter output) {
  if (nd==null) return;
  if (nd != uct.rootNode) {
    float winrate = nd.wa[nd.player] / nd.na;
    float ucbValue = nd.UCTwp(nd.player, totalNumber);
    //float ucbValue = nd.UCTa(nd.player, totalNumber);
    println(nd.id+": "+ nf(winrate, 0, 3)+" [" +nd.na+"] <"+nf(ucbValue, 0, 3)+">");
  }
  if (nd.legalMoves!=null && nd.legalMoves.size()>0) {
    for (uctNode child : nd.legalMoves) {
      showAllMct(child, totalNumber, output);
    }
  }
  if (nd.childR!=null && nd.childR.size()>0) {
    for (uctNode child : nd.childR) {
      showAllMct(child, totalNumber, output);
    }
  }
  if (nd.childR!=null && nd.childG.size()>0) {
    for (uctNode child : nd.childG) {
      showAllMct(child, totalNumber, output);
    }
  }
  if (nd.childR!=null && nd.childW.size()>0) {
    for (uctNode child : nd.childW) {
      showAllMct(child, totalNumber, output);
    }
  }
  if (nd.childR!=null && nd.childB.size()>0) {
    for (uctNode child : nd.childB) {
      showAllMct(child, totalNumber, output);
    }
  }
}

int returnBestChildFromRoot(player pl, uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする。
  float bestWr=0, bestPr=0;//
  int bestMove=-1;
  if (root.legalMoves!=null) {
    for (uctNode nd1 : root.legalMoves) {
      float tmpWr = (nd1.wa[pl.position])/ nd1.na;
      float tmpPr = (nd1.pa[pl.position])/nd1.na;
      if (bestWr<tmpWr || ( bestWr==tmpWr && bestPr<=tmpPr)) {
        bestWr = tmpWr;
        bestPr = tmpPr;
        bestMove = nd1.move;
      }
    }
  }
  if (bestMove==-1) {
    println("No root's legal moves"); //<>//
  }
  return bestMove;//
}

uctNode returnFriquentChildFromRoot(uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も訪問関数が良いものをリターンする。
  float bestNa=0;//
  uctNode bestMove=null;
  for (uctNode nd1 : root.legalMoves) {
    if (bestNa<nd1.na) {
      bestNa = nd1.na;
      bestMove = nd1;
    }
  }
  return bestMove;//
}

int returnBest2ChildrenFromRoot(player pl, uctNode root) {
  // rootに直接ぶら下がっているノードの中から、最も勝率が良いものから２つをリターンする。
  float bestWr=0, bestPr=0;//
  int bestMove=-1;
  float secondWr=0, secondPr=0;//
  int secondMove=-1;
  if (root.legalMoves!=null) {
    for (uctNode nd1 : root.legalMoves) {
      float tmpWr = nd1.wa[pl.position] / nd1.na;
      float tmpPr = nd1.pa[pl.position] / nd1.na;
      if (bestWr<tmpWr || (bestWr==tmpWr && bestPr<=tmpPr)) {
        secondWr = bestWr;
        secondPr = bestPr;
        secondMove = bestMove;
        bestWr = tmpWr;
        bestPr = tmpPr;
        bestMove = nd1.move;
      } else if (secondWr<tmpWr || (secondWr==tmpWr && secondPr<=tmpPr)) {
        secondWr = tmpWr;
        secondPr = tmpPr;
        secondMove = nd1.move;
      }
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
