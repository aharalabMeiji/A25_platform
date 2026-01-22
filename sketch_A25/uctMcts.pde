uctClass uct = new uctClass();
class uctClass {
  player[] participants;
  winPoints winPoint;
  winPoints randomPlayWinPoint;
  prize prize;
  board mainBoard;
  board subBoard;
  board randomPlayBoard=null;
  uctNode newNode;
  uctNode rootNode;
  ArrayList<uctNode> activeNodes;
  int simulationTag=0;
  int cancelCount=0;
  int loopCount=0;
  int expandThreshold = 10;// 
  int terminateThreshold = 10000000;
  int depthMax = 4;
  int cancelCountMax=10;
  float maxNodeWinrate=0.0;
  int chanceNodeOn=0;
  int pruningThreshold=999;
  player nextPlayer=null;
  int nnNextPlayer=1;
  int underCalculation=0;
  float Rrate=1, Grate=1, Wrate=1, Brate=1;
  int qtyPlayouts=0;
  int[] qtyNodes=null;
  uctClass() {
    qtyNodes = new int[7];// 7 = maxdepth+1
  }

  // Brain
  int mctsBrain(player pl) { //
    //ここから
    startTime=millis();
    int answer = uctMctsStartingJoseki(pl);
    if (answer!=-1) return answer;
    answer = mctsBrainPreparation(pl);
    if (answer==-1) return -1;
    answer = mctsBrainFirstSimulation(pl);
    printUctParameters();
    if (answer!=-1) return answer;
    //uct.simulationTag=uct.expandThreshold*10;
    while (true) {
      //if (uct.uctMainLoopOption==1) {
      answer = uctMctsMainLoop(pl);
      //} else {
      //  answer = uctMctsMainLoopVer2(pl);
      //}
      for (int k=0; k<25; k++) {// 今のところ、この書き換えは反映されない。
        utils.gameMainBoard.s[k].shaded=pl.myBoard.s[k].shaded;
      }
      if (answer!=-1) return answer;
    }// end of while(true)
  }

  void printUctParameters(){
    print ("uct ");
    print ("E"+expandThreshold+"/");
    print ("D"+depthMax+"/");
    if (cancelCountMax<10000) print ("C"+cancelCountMax+"/");//uct.terminateThreshold,
    else print ("woC/");
    if (chanceNodeOn==1) print("CN/");
    if (pruningThreshold<999) print("P"+uct.pruningThreshold+" ");
    println();
  }
  
  int mctsBrainPreparation(player pl) {
    //println("uctMctsBrain:プレーヤーをランダムエージェントに設定");
    participants = new player[5];
    for (int p=1; p<5; p++) {
      participants[p] = new player(p, "random", brainType.Random);
    }
    //println("uctMctsBrain:着手可能点を計算しておく");
    pl.myBoard.buildVP(pl.position);
    //pl.myBoard.deleteSymmetricVp();
    if (pl.myBoard.countVp()==0) {// ゲーム終了盤面ならば－１を返す。
      return -1;
    }

    //println("uctMctsBrain:pl の変数の初期化");
    pl.myBoard.clearSv();//たぶん不要
    pl.yellow=-1;
    winPoint=null;
    prize=new prize();
    //println("uctMctsBrain:シミュレーション用のサブボード");
    mainBoard = new board();
    subBoard = new board();
    //println("uctMctsBrain:ループ回数のカウント");
    pl.myBoard.simulatorNumber=0;
    //println("uctMctsBrain:UCT準備");
    newNode = null;
    rootNode = new uctNode();
    rootNode.parent = null;
    rootNode.legalMoves = new ArrayList<uctNode>();
    cancelCount=0;
    pl.myBoard.copyBoardToBd(uct.rootNode.bd);
    qtyPlayouts=0;
    for (int d=0; d<=uct.depthMax; d++) {
      qtyNodes[d]=0;
    }
    //uct.rootNodeに子供をぶら下げる
    if (pl.myBoard.attackChanceP()==false) {
      //println("uctMctsBrain:通常時、uct.rootNodeに子供をぶら下げる");
      for (int k=0; k<25; k++) {
        if (pl.myBoard.vp[k]>0) {
          newNode = new uctNode();
          // 自分自身が先祖// 逆伝播をここで切りたい// アタックチャンスではない
          newNode.setParameters(pl.position, k, 
            rootNode.id + (":"+kifu.playerColCode[pl.position]+nf(k+1, 2)), 
            1, newNode, null, false);
          qtyNodes[0] ++;
          qtyNodes[1] ++;
          rootNode.legalMoves.add(uct.newNode);//ルートノードにぶら下げる
          newNode.onRGWB = new boolean[5];
          for (int p=1; p<5; p++) {//4つのチャンスノードは有効
            newNode.onRGWB[p]=true;
          }
          pl.myBoard.copyBoardToSub(uct.mainBoard);
          mainBoard.move(pl.position, k);//一手進める
          mainBoard.copyBoardToBd(uct.newNode.bd);
        }
      }
      //println("uctMctsBrain:手抜きという選択肢を考える");
      // １手目パス
      if (pl.noPass==0) {
        newNode = new uctNode();
        newNode.setParameters(pl.position, 25,
          uct.rootNode.id+(":"+kifu.playerColCode[pl.position]+nf(26, 2)),
          1, newNode, null, false);          
        qtyNodes[0] ++;
        qtyNodes[1] ++;
        rootNode.legalMoves.add(newNode);//ルートノードにぶら下げる
        newNode.onRGWB = new boolean[5];
        for (int p=1; p<5; p++) {//ノードをつるさない場合はフラグを倒しておく
          if (isPassAtDepth1Node(newNode, p)) newNode.onRGWB[p]=false;
          else newNode.onRGWB[p]=true;
        }
        pl.myBoard.copyBoardToSub(mainBoard);
        mainBoard.copyBoardToBd(newNode.bd);
      }
    } else {
      //println("uctMctsBrain:AC時、uct.rootNodeに子供をぶら下げる");
      pl.myBoard.attackChanceP=true;
      for (int j=0; j<25; j++) { //加えるパネル
        for (int i=0; i<25; i++) { //黄色にするパネル
          int k = i*25+j;
          if ((pl.myBoard.vp[j]>0 && (pl.myBoard.s[i].col>=1 && pl.myBoard.s[i].col<=4)) || (pl.myBoard.vp[j]>0 && i==j)) {
            newNode = new uctNode();
            qtyNodes[0] ++;
            qtyNodes[1] ++;
            newNode.setParameters(pl.position, k, 
              rootNode.id + (":"+kifu.playerColCode[pl.position]+nf(j+1, 2)) + (":Y"+nf(i+1, 2)),
              1, newNode, null, true );
            rootNode.legalMoves.add(newNode);//ぶら下げる
            newNode.onRGWB = new boolean[5];
            for (int p=1; p<5; p++) {
              newNode.onRGWB[p]=true;
            }//4つのチャンスノードは有効
            pl.myBoard.copyBoardToSub(uct.mainBoard);
            mainBoard.move(pl.position, j);// 1手着手する
            mainBoard.s[i].col = 5;// 黄色を置く
            mainBoard.copyBoardToBd(newNode.bd);
          }
        }
      }
    }
    for (int k=0; k<25; k++) {// 何も表示しない。念のため。
      pl.myBoard.s[k].marked = 0;
    }//たぶん不要
    underCalculation=0;//計算厨であることを示すフラグ
    loopCount = int(3000/rootNode.legalMoves.size());
    return 0;// トラブルなく終わる
  }

  int mctsBrainFirstSimulation(player pl) {
    for (uctNode nd : uct.rootNode.legalMoves) {
      // パラメータの初期化(onRGWBは設定済み）
      nd.na=0;
      nd.naR=0;
      nd.naG=0;
      nd.naW=0;
      nd.naB=0;
      for (int p=1; p<=4; p++) {
        nd.wa[p]=0;
        nd.waR[p]=0;
        nd.waG[p]=0;
        nd.waW[p]=0;
        nd.waB[p]=0;//
        nd.pa[p]=0;
        nd.paR[p]=0;
        nd.paG[p]=0;
        nd.paW[p]=0;
        nd.paB[p]=0;//
      }
      //println("uctMctsBrain:最後までシミュレーションを数回行う");
      // ここをUCBにするアイディアもあるが、結局淘汰されるようなので、０でなければなんでもいいみたい。
      for (int count=0; count<4; count++) {
        //フラグonRGWBが倒れている選択肢については、シミュレーションしない。
        int nextplayer = count+1;
        if (nd.onRGWB[nextplayer]==false) {
          continue;
        }
        mainBoard.copyBdToBoard(nd.bd);
        winPoint = playSimulatorToEnd(mainBoard, participants, nextplayer);//ここは次手番をnextplayerとする。
        qtyPlayouts ++;
        pl.myBoard.simulatorNumber ++;
        if (chanceNodeOn==1) {// //chanceNodeOn=1; waRには「積み上げ」、waには「平均化」
          nd.addNa(nextplayer,1);
          for (int p=1; p<=4; p++) {
            nd.addWa(nextplayer, p, winPoint.points[p]);
            nd.addPa(nextplayer, p, winPoint.panels[p]);
          }
          //if (nextplayer==1) {
          //  nd.naR ++;
          //  for (int p=1; p<=4; p++) {
          //    nd.waR[p] += //
          //    nd.paR[p] += winPoint.panels[p];//
          //  }
          //} else if (nextplayer==2) {
          //  nd.naG ++;
          //  for (int p=1; p<=4; p++) {
          //    nd.waG[p] += winPoint.points[p];//
          //    nd.paG[p] += winPoint.panels[p];//
          //  }
          //} else if (nextplayer==3) {
          //  nd.naW ++;
          //  for (int p=1; p<=4; p++) {
          //    nd.waW[p] += winPoint.points[p];//
          //    nd.paW[p] += winPoint.panels[p];//
          //  }
          //} else { //if(nextplayer==4){
          //  nd.naB ++;
          //  for (int p=1; p<=4; p++) {
          //    nd.waB[p] += winPoint.points[p];//
          //    nd.paB[p] += winPoint.panels[p];//
          //  }
          //}
          nd.na ++;//
          // nd.na = nd.naR + nd.naG + nd.naW + nd.naB;
          for (int p=1; p<=4; p++) {
            nd.wa[p] = averageBackPropagate(nd, p, true);
            nd.pa[p] = averageBackPropagate(nd, p, false);
          }
        } else {// 旧式// waへ「積み上げ」
          nd.na ++;//
          for (int p=1; p<=4; p++) {
            nd.wa[p] += winPoint.points[p];//
            nd.pa[p] += winPoint.panels[p];//
          }
        }
      }
    }
    // 最善勝率より、かなり低い枝はカットする。-> 不採用
    // 優勝が決まっているときには、優勝を逃す可能性のある枝を切る。-> 不採用
    //アクティブなノードをリスト化する。//ここがバージョン２
    //深さ１のノードのそれぞれをアクティブなノードとしてリストへ追加
    for (uctNode nd : rootNode.legalMoves) {
      nd.activeNodes = new ArrayList<uctNode>();
      nd.activeNodes.add(nd);// 26番であっても、アクティブなノードである。
      nd.ancestor = nd;
    }
    //
    if (rootNode.legalMoves.size()==1) {
      /// 選択肢が一つの時には、それを答える。
      int ret=rootNode.legalMoves.get(0).move;
      //println("["+rootNode.legalMoves.get(0).id+"]");
      if (pl.myBoard.attackChanceP()) {
        pl.yellow = int(ret/25);
        return ret%25;
      } else {
        return ret;
      }
    }
    return -1;
  }


  ArrayList<uctNode> GetChildOfUctNode(int player, uctNode nd0) {
    switch(player) {
    case 1:
      return nd0.childR;
    case 2:
      return nd0.childG;
    case 3:
      return nd0.childW;
    default:
      return nd0.childB;
    }
  }
  void randomPlayAndBackPropagate(uctNode uctMaxNode, int _nextPlayer) {
    float[] wDeltas = new float[5];
    float[] pDeltas = new float[5];
    //print("randomPlayAndBackPropagate:",uctMaxNode.id, "のノードを調べる",int(uctMaxNode.na)+":"+int(uctMaxNode.naR)+":"+int(uctMaxNode.naG)+":"+int(uctMaxNode.naW)+":"+int(uctMaxNode.naB));
    if (this.randomPlayBoard==null) {
      this.randomPlayBoard = new board();
    }
    if (this.randomPlayWinPoint==null) {
      this.randomPlayWinPoint = new winPoints();
    }
    //println("uctMctsBrain:mainBoardへ盤面をコピー");
    this.randomPlayBoard.copyBdToBoard(uctMaxNode.bd);
    int nextplayer = 1;
    if (1<=_nextPlayer && _nextPlayer<=4) {
      nextplayer = _nextPlayer;
    } else {
      do {
        nextplayer = int(random(4))+1;
      } while (uctMaxNode.onRGWB[nextplayer]==false);
    }
    //println("uctMctsBrain:uct.mainBoardを最後まで打ち切る");
    this.randomPlayWinPoint = playSimulatorToEnd(this.randomPlayBoard, this.participants, nextplayer);
    uctMaxNode.na ++;//
    qtyPlayouts ++;
    //println("uctMctsBrain:nd.wa[p]、nd.pa[p]、nd.uct[p]");
    if (chanceNodeOn==1) {////chanceNodeOn=1; waRには「積み上げ」、waには「平均化」
      // このタイミングで、「差」を計算しておく。
      for (int p=1; p<=4; p++) {
        wDeltas[p] = this.randomPlayWinPoint.points[p];
        pDeltas[p] = this.randomPlayWinPoint.panels[p];
      }
      if (nextplayer==1) {
        for (int p=1; p<=4; p++) {
          uctMaxNode.waR[p] += wDeltas[p];
          uctMaxNode.paR[p] += pDeltas[p];
        }
        uctMaxNode.naR ++;
      } else if (nextplayer==2) {
        for (int p=1; p<=4; p++) {
          uctMaxNode.waG[p] += wDeltas[p];
          uctMaxNode.paG[p] += pDeltas[p];
        }
        uctMaxNode.naG ++;
      } else if (nextplayer==3) {
        for (int p=1; p<=4; p++) {
          uctMaxNode.waW[p] += wDeltas[p];
          uctMaxNode.paW[p] += pDeltas[p];
        }
        uctMaxNode.naW ++;
      } else if (nextplayer==4) {
        for (int p=1; p<=4; p++) {
          uctMaxNode.waB[p] += wDeltas[p];
          uctMaxNode.paB[p] += pDeltas[p];
        }
        uctMaxNode.naB ++;
      }
      for (int p=1; p<=4; p++) {
        wDeltas[p] = averageBackPropagate(uctMaxNode, p, true)-uctMaxNode.wa[p];
        uctMaxNode.wa[p] += wDeltas[p];
        pDeltas[p] = averageBackPropagate(uctMaxNode, p, false)-uctMaxNode.pa[p];
        uctMaxNode.pa[p] += pDeltas[p];
      }
      //println("->",int(uctMaxNode.na)+":"+int(uctMaxNode.naR)+":"+int(uctMaxNode.naG)+":"+int(uctMaxNode.naW)+":"+int(uctMaxNode.naB));
    } else {// 旧式　// waへ「積み上げ」
      for (int p=1; p<=4; p++) {
        uctMaxNode.wa[p] += this.randomPlayWinPoint.points[p];//2回め以降は和
        uctMaxNode.pa[p] += this.randomPlayWinPoint.panels[p];//2回め以降は和
      }
    }
    //println("親にさかのぼってデータを更新する");
    uctNode nd0 = uctMaxNode;
    uctNode ndC = null;
    do {
      if (nd0.parent!=null) {
        ndC = nd0;
        nd0 = nd0.parent;
        // chance node であるなしに関わらず、上に合流するのが「旧式」//uct.chanceNodeOn=0;
        // chance node から上にあげるときには式を変更するのが「新式」//uct.chanceNodeOn=1;
        //print("->["+ndC.id+"]");
        nd0.na ++;
        if (chanceNodeOn==1) {// 「新式」//uct.chanceNodeOn=1;
          if ( ndC.player == 1) { // 次がRの手番
            // 論理的には、 nd0.childRにぶら下がっているノードのwa[p]の総和をwaR[p]に入れる感じ。
            // ただ、それをやっていると、計算量が増えるので、wa[p]の差分だけを記録して、それを加える。
            nd0.naR ++ ;// nd0.childRにぶら下がっているノードのnaの総和と一致するハズ。
            for (int p=1; p<=4; p++) {
              nd0.waR[p] += wDeltas[p];// 前段で「差」を計算しておいて、それを加える。
              nd0.paR[p] += pDeltas[p];
            }
          } else if ( ndC.player == 2) { // 次がGの手番
            nd0.naG ++ ;// nd0.childRにぶら下がっているノードのnaの総和と一致するハズ。
            for (int p=1; p<=4; p++) {
              nd0.waG[p] += wDeltas[p];// 前段で「差」を計算しておいて、それを加える。
              nd0.paG[p] += pDeltas[p];
            }
          } else if ( ndC.player == 3) { // 次がWの手番
            nd0.naW ++ ;// nd0.childRにぶら下がっているノードのnaの総和と一致するハズ。
            for (int p=1; p<=4; p++) {
              nd0.waW[p] += wDeltas[p];// 前段で「差」を計算しておいて、それを加える。
              nd0.paW[p] += pDeltas[p];
            }
          } else if ( ndC.player == 4) { // 次がBの手番
            nd0.naB ++ ;// nd0.childRにぶら下がっているノードのnaの総和と一致するハズ。
            for (int p=1; p<=4; p++) {
              nd0.waB[p] += wDeltas[p];// 前段で「差」を計算しておいて、それを加える。
              nd0.paB[p] += pDeltas[p];
            }
          }
          for (int p=1; p<=4; p++) {
            // このタイミングで、「差」を計算しておく。
            wDeltas[p] = averageBackPropagate(nd0, p, true) - nd0.wa[p];
            nd0.wa[p] += wDeltas[p];//
            pDeltas[p] = averageBackPropagate(nd0, p, false) - nd0.pa[p];
            nd0.pa[p] += pDeltas[p];//
          }
        } else {//「旧式」//uct.chanceNodeOn=0;
          for (int p=1; p<=4; p++) {
            nd0.wa[p] += this.randomPlayWinPoint.points[p];//2回め以降は和
            nd0.pa[p] += this.randomPlayWinPoint.panels[p];//2回め以降は和
          }
        }
        //println("uctMctsBrain:→　ノード ",nd0.id, "のデータ("+nd0.wa[1]+","+nd0.wa[2]+","+nd0.wa[3]+","+nd0.wa[4]+")/"+nd0.na);
      } else {// ルートまでたどり着いた、の意味
        // ルートまでたどり着いて、なにか作業する必要があればここに書く。
        break;
      }
    } while (true);//println("親にさかのぼってデータを更新する");//おわり
  }
  
  float averageBackPropagate(uctNode nd, int p, boolean wp) {
    float wR = (wp)? nd.waR[p]: nd.paR[p];
    float nR = nd.naR;
    float wG = (wp)? nd.waG[p]: nd.paG[p];
    float nG = nd.naG;
    float wW = (wp)? nd.waW[p]: nd.paW[p];
    float nW = nd.naW;
    float wB = (wp)? nd.waB[p]: nd.paB[p];
    float nB = nd.naB;
    float na = nd.na;
    //float averageBackPropagate(float wR, float nR, float wG, float nG, float wW, float nW, float wB, float nB, float na) {
    if (nR+nG+nW+nB!=na) {
      println("averageBackPropagate", "("+wR+"/"+nR+")("+wG+"/"+nG+")("+wW+"/"+nW+")("+wB+"/"+nB+")na="+na);
    }
    if (nd.onRGWB[2]==false && nG>0) {
      println("something is wrong on childG at averageBackPropagat");
    }
    float sum=0f;
    float numer=0;
    int denom=0;
    if (nd.onRGWB[1] && nR!=0) {// if (nd.onRGWB[1])
      numer = Rrate;
      sum += (wR/nR*numer) ;
      denom += numer;
    }
    if (nd.onRGWB[2] && nG!=0) {
      numer = Grate;
      sum += (wG/nG*numer);
      denom += numer;
    }
    if (nd.onRGWB[3] && nW!=0) {
      numer = Wrate;
      sum += (wW/nW*numer);
      denom += numer;
    }
    if (nd.onRGWB[4] && nB!=0) {
      numer = Brate;
      sum += (wB/nB*numer);
      denom += numer;
    }
    return sum*na/denom;
  }
  boolean isPassAtDepth1Node(uctNode nd, int _p) {// uct.rootNode.legalMove 内の話。
    if (nd.depth==1) {
      if (nd.move==25) {
        if (nd.player==_p) {
          return true;
        }
        if (gameOptions.get("Absence0R")==1 && nd.player==1) {
          return true;
        }
        if (gameOptions.get("Absence0G")==1 && nd.player==2) {
          return true;
        }
        if (gameOptions.get("Absence0W")==1 && nd.player==3) {
          return true;
        }
        if (gameOptions.get("Absence0B")==1 && nd.player==4) {
          return true;
        }
      }
    }
    return false;
  }

  boolean isPassAtDepth2Node(uctNode nd, int _p) {
    if (nd.ancestor.move==25) {
      if (nd.depth==3) {
        if (gameOptions.get("Absence1R")==1 && _p==1) {
          return true;
        }
        if (gameOptions.get("Absence1G")==1 && _p==2) {
          return true;
        }
        if (gameOptions.get("Absence1W")==1 && _p==3) {
          return true;
        }
        if (gameOptions.get("Absence1B")==1 && _p==4) {
          return true;
        }
      }
    } else {
      if (nd.depth==2) {
        if (gameOptions.get("Absence1R")==1 && _p==1) {
          return true;
        }
        if (gameOptions.get("Absence1G")==1 && _p==2) {
          return true;
        }
        if (gameOptions.get("Absence1W")==1 && _p==3) {
          return true;
        }
        if (gameOptions.get("Absence1B")==1 && _p==4) {
          return true;
        }
      }
    }
    return false;
  }
  
  void printQtyNodes(){
    print("(");
    for (int d=1; d<=depthMax; d++){
      print(qtyNodes[d]+" ");
    }
    println(")");
  }
}; // class uctClass のおわり

/////////////////////////////////

// utilsへ移籍予定
void printAllWaPa(uctNode nd) {// デバッグのためのコンソール出力
  if ( nd.depth<=3 && nd.id.substring(0, 4).equals(":G26")) {
    println(""+nd.id+","+(nd.wa[1]/nd.na)+","+(nd.wa[2]/nd.na)+","+(nd.wa[3]/nd.na)+","+(nd.wa[4]/nd.na)+","+(nd.pa[1]/nd.na)+","+(nd.pa[2]/nd.na)+","+(nd.pa[3]/nd.na)+","+(nd.pa[4]/nd.na)+","+nd.na+"");
  }
  if (nd.childR!=null && nd.childR.size()>0) {
    for (uctNode nd2 : nd.childR) {
      printAllWaPa(nd2);
    }
  }
  if (nd.childG!=null && nd.childG.size()>0) {
    for (uctNode nd2 : nd.childG) {
      printAllWaPa(nd2);
    }
  }
  if (nd.childW!=null && nd.childW.size()>0) {
    for (uctNode nd2 : nd.childW) {
      printAllWaPa(nd2);
    }
  }
  if (nd.childB!=null && nd.childB.size()>0) {
    for (uctNode nd2 : nd.childB) {
      printAllWaPa(nd2);
    }
  }
}


int uctMctsMainLoop(player pl) {
  //uctMctsMainLoop  01
  // 勝率３位までをリストアップし、大差かどうかを調べる
  uct.prize.getPrize3FromNodeList(pl.position, uct.rootNode.legalMoves);
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
      uct.cancelCount += uct.loopCount;
      //print("["+(uct.cancelCount/1000.0)+"]");
      if ((uct.cancelCount)>=uct.cancelCountMax*1000) {
        println("勝率の推定により着手が確定した");
        println("試行回数(", pl.myBoard.simulatorNumber, ")");
        println("time=", millis()-startTime, "(ms)");
        uct.underCalculation=10;//十分大きな値
        println("プレイアウト回数："+uct.qtyPlayouts);
        println("ノード総数："+uct.qtyNodes[0]);
        uct.printQtyNodes();
        // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
        int ret = returnBestChildFromRoot(pl, uct.rootNode);
        if (pl.myBoard.attackChanceP()) {
          pl.yellow = int(ret/25);
          println("[", (ret%25+1)+"-"+(pl.yellow+1), "]");
          return ret%25;
        } else {
          println("[", (ret+1), "]");
          println(""+simulator.mainBoard.sv[ret]+" : "+simulator.mainBoard.sv2[ret]);
          return ret;
        }
      }
    } else {
      uct.cancelCount=0;
    }
  }
  uct.underCalculation ++;//計算中表示のためのアルゴリズム
  if (uct.underCalculation==3) uct.underCalculation=0;//繰り返し
  //uctMctsMainLoop  02
  for (int repeat=0; repeat<uct.loopCount; repeat++) {
    //uctMctsMainLoop  02-1
    // VERSION2 バージョン１は消去済み
    for (uctNode ancestor : uct.rootNode.legalMoves) {//root直下に、先祖たちがぶら下がっている。
      for (uctNode nd : ancestor.activeNodes) {// 先祖たちにはアクティブノード（葉）がぶら下がっている。
        for (int p=1; p<=4; p++) {
          // シミュレーション総回数はpl.myBoard.simulatorNumber
          // 平均パネル枚数に0.04かけて、加算している。２点満点
          nd.uct[p] = nd.UCTwp(p, pl.myBoard.simulatorNumber);
          //nd.uct[p] = nd.UCTa(p, pl.myBoard.simulatorNumber);
        }
      }
    }

    //uctMctsMainLoop  02-2
    for (uctNode ancestor : uct.rootNode.legalMoves) {//
      //println("ancestorごとに、uct値が最大となるアクティブノードを見つける");
      //uctMctsMainLoop block 02-2-1
      float uctMax=-1;
      uctNode uctMaxNode=null;
      for (int zz=ancestor.activeNodes.size()-1; zz>=0; zz--) {//消去する可能性があるので、後ろからサーチする。
        uctNode nd = ancestor.activeNodes.get(zz);
        if (nd.na >= uct.expandThreshold && nd.depth >= uct.depthMax) {
          //println("試行回数がマックス、かつ深さもマックスなので、"+nd.id+"をアクティブノードのリストから消去");
          ancestor.activeNodes.remove(zz);// アクティブノードのリストから消去
        } else if (nd.uct[nd.player]>uctMax) {// uct局所最大なら、記録しておく。
          uctMax=nd.uct[nd.player];
          uctMaxNode = nd;
        }
      }
      //uctMctsMainLoop block 02-2-2
      // このancestorの下のアクティブノードが尽きたとき。
      if (uctMaxNode==null) {// すでに尽きていてもこうなる。
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
          println("試行回数(", pl.myBoard.simulatorNumber, ")");
          println("time=", millis()-startTime, "(ms)");
          uct.underCalculation=10;//十分大きな値を代入
          //内部データのチェック用;
          //for(uctNode anc : uct.rootNode.legalMoves){
          //  printAllWaPa(anc);
          //}
          // プレイアウトの回数、ノードの個数を個別にカウントしたものを表示
          println("プレイアウト回数："+uct.qtyPlayouts);
          println("ノード総数："+uct.qtyNodes[0]);
          uct.printQtyNodes();
          // rootに直接ぶら下がっているノードの中から、最も勝率が良いものをリターンする
          int ret = returnBestChildFromRoot(pl, uct.rootNode);
          if (pl.myBoard.attackChanceP()) {
            pl.yellow = int(ret/25);
            println("[", (ret%25+1)+"-"+(pl.yellow+1), "]");
            return ret%25;
          } else {
            println("[", (ret+1), "]");
            println(""+simulator.mainBoard.sv[ret]+" : "+simulator.mainBoard.sv2[ret]);
            return ret;
          }
        }// すべての先祖が終わったら、そこでおわり
        else {
          continue;
        }
      }//
      //uctMctsMainLoop block 02-2-3
      // uctMaxNodeから最後までランダムに打って（初手番を指定可能）
      // そののちに親までさかのぼって褒章データを更新する。
      pl.myBoard.simulatorNumber ++;
      uct.randomPlayAndBackPropagate(uctMaxNode, 0);

      //uctMctsMainLoop  02-2-4
      if (uctMaxNode.na >= uct.expandThreshold) {// 削除するための条件
        //println("uctMctsBrain:uctMaxNodeはuct.activeNodesから削除");
        //展開するにせよしないにせよ、この作業は等価に必要。
        for (int zz=ancestor.activeNodes.size()-1; zz>=0; zz--) {
          if (ancestor.activeNodes.get(zz)==uctMaxNode) {
            //println("ノード"+uctMaxNode.id+"をアクティブノードのリストから消去");
            ancestor.activeNodes.remove(zz);//アクティブノードのリストから消去
            break;
          }
        }
        // 親の状況を確認（直接の兄弟が何人いるか）
        boolean expandOK=false;
        if (uctMaxNode.depth==1) expandOK=true;
        else {
          if(uctMaxNode.parent==null) expandOK=false;// これは起こらない
          else {
            if (uctMaxNode.player==1){
              uctMaxNode.parent.ncR++;
              if (uctMaxNode.parent.ncR >uct.pruningThreshold) expandOK=false; else expandOK=true;
              if (uctMaxNode.parent.bcR==null) uctMaxNode.parent.bcR=uctMaxNode;// bc = best child
            } else if (uctMaxNode.player==2){
              uctMaxNode.parent.ncG++;
              if (uctMaxNode.parent.ncG >uct.pruningThreshold) expandOK=false; else expandOK=true;
              if (uctMaxNode.parent.bcG==null) uctMaxNode.parent.bcG=uctMaxNode; 
            } else if (uctMaxNode.player==3){
              uctMaxNode.parent.ncW++;
              if (uctMaxNode.parent.ncW >uct.pruningThreshold) expandOK=false; else expandOK=true;
              if (uctMaxNode.parent.bcW==null) uctMaxNode.parent.bcW=uctMaxNode; 
            } else if (uctMaxNode.player==4){
              uctMaxNode.parent.ncB++;
              if (uctMaxNode.parent.ncB >uct.pruningThreshold) expandOK=false; else expandOK=true;
              if (uctMaxNode.parent.bcB==null) uctMaxNode.parent.bcB=uctMaxNode; 
            }
          }
        }
        //if(expandOK==false){
        //  println(uctMaxNode.parent.id+"->"+uctMaxNode.id);         
        //}
        if (uctMaxNode.depth<uct.depthMax && uctMaxNode.id!="" && remaingInBd(uctMaxNode.bd)>0 && expandOK ) {   // 展開するための条件
          // remaingInBd(uctMaxNode.bd) : 残り空パネルの個数（黄色も含む）
          uct.newNode=null;
          uctMaxNode.legalMoves=null;
          // uctMaxNode.parent.ncB == uct.pruningThresholdのとき、残されたアクティブノードをリストからはずす、というアイディアはある。
          // チャンスノードを別途ぶら下げる <- この案を却下。
          // ぶら下げる場所を4か所作る（メモリとスピードの節約のため）
          if (uctMaxNode.childR==null) uctMaxNode.childR = new ArrayList<uctNode>();
          if (uctMaxNode.childG==null) uctMaxNode.childG = new ArrayList<uctNode>();
          if (uctMaxNode.childW==null) uctMaxNode.childW = new ArrayList<uctNode>();
          if (uctMaxNode.childB==null) uctMaxNode.childB = new ArrayList<uctNode>();
          //uctMctsMainLoop 02-2-4-1
          if (uctMaxNode.onRGWB==null) {// これは起こりえないが、念のため入れておく。
            uctMaxNode.onRGWB = new boolean[5];
            for (int p=1; p<5; p++) {// 4人分の作業ここから
              //uctMctsMainLoop block 02-2-4-1
              // 深さ２以上のパスによる枝切
              if (uct.isPassAtDepth2Node(uctMaxNode, p)) {
                //print("[pass at"+uctMaxNode.id+";"+p+"]");
                uctMaxNode.onRGWB[p]=false;
                continue;
              } else {
                uctMaxNode.onRGWB[p]=true;
              }
            }
          }
          for (int p=1; p<5; p++) {// 4人分の作業ここから
            //uctMctsMainLoop 02-2-4-2
            if (! uctMaxNode.onRGWB[p]) continue; // 「お立ち」では作業省略
            //println("プレイヤー"+p+の子供ノードをuctMaxNodeに追加);//展開中
            //println("uctMaxNodeの盤面をuct.mainBoardにコピー。");
            uct.mainBoard.copyBdToBoard(uctMaxNode.bd);
            //println("プレイヤー"+p+"の合法手をリストアップ");
            uct.mainBoard.buildVP(p);
            //println("新規ノードを作り、これをchildRなどにぶらさげる");
            //uctMctsMainLoop block 02-2-4-3
            if (uct.mainBoard.attackChanceP()==false) {
              //uctMctsMainLoop block 02-2-4-3-1
              // アタックチャンスでないときの、子ノードのぶらさげ//ただいま展開中
              uctMaxNode.attackChanceNode=false;
              for (int k=0; k<25; k++) {   // 合法手ごとのforループ、パスは含まない
                if (uct.mainBoard.vp[k]>0) { // 子ノードをぶら下げる条件
                  uct.newNode = new uctNode();
                  uct.qtyNodes[0] ++;
                  uct.newNode.setItem(p, k);
                  uct.newNode.id = uctMaxNode.id+":"+kifu.playerColCode[p]+nf(k+1, 2);
                  uct.newNode.depth = uctMaxNode.depth+1;//=newChancenode.depth
                  uct.qtyNodes[uct.newNode.depth] ++;
                  //println("新しいノード "+uct.newNode.id+"を追加した！");
                  uctMaxNode.getChildList(p).add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
                  uct.newNode.parent = uctMaxNode;//uctMaxNodeをuct.newNodeの親に設定
                  uct.newNode.ancestor = ancestor;//uct.newNodeのご先祖さまを記録
                  uct.newNode.onRGWB = new boolean[5];
                  for (int p0=1; p0<5; p0++) {// 4人分の作業ここから
                    // 深さ２以上のパスによる枝切
                    if (uct.isPassAtDepth2Node(uct.newNode, p0)) {
                      //print("[pass at"+uctMaxNode.id+";"+p0+"]");
                      uct.newNode.onRGWB[p0]=false;
                      continue;
                    } else {
                      uct.newNode.onRGWB[p0]=true;
                    }
                  }
                  ancestor.activeNodes.add(uct.newNode);//ご先祖様のアクティブノードに登録
                  //println("新しいノードに盤情報を記入");
                  uct.mainBoard.copyBoardToSub(uct.subBoard);
                  uct.subBoard.move(p, k);// 1手着手する
                  uct.subBoard.copyBoardToBd(uct.newNode.bd);
                  // uct.newNodeの報酬データを初期化
                  uct.newNode.initRewardOfNode();
                  // 4回、最後まで打ち切ってバックプロパゲートしておく。
                  // uct値を有効にするため。
                  for (int count=0; count<4; count++) {
                    if (uctMaxNode.onRGWB[count+1]) {
                      pl.myBoard.simulatorNumber ++;
                      uct.randomPlayAndBackPropagate(uct.newNode, count+1);
                    }
                  }
                }
              }// 合法手ごとのforループ ここまで
              //if (uctMaxNode.depth==1){
              //  // パス(move=26)をここに含めるかどうか。
              //  // 現状では、初手以外ではパスを入れていない。
              //  // その結果「ほかの人がパスをしない前提で自分のパスを考える」ことになっている。
              //  // これがよいか.深さ２だけ２６番を入れるという考え方もある。
              //  // 体感だが、これを入れると、かすかに弱くなっている気がする。
              //  uct.newNode = new uctNode();
              //  uct.qtyNodes[0] ++;
              //  uct.newNode.setItem(p, 25);
              //  uct.newNode.id = uctMaxNode.id+":"+kifu.playerColCode[p]+nf(26, 2);
              //  uct.newNode.depth = uctMaxNode.depth+1;//=newChancenode.depth
              //  uct.qtyNodes[uct.newNode.depth] ++;
              //  //println("新しいノード "+uct.newNode.id+"を追加した！");
              //  switch(p) {
              //  case 1:
              //    uctMaxNode.childR.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
              //    break;
              //  case 2:
              //    uctMaxNode.childG.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
              //    break;
              //  case 3:
              //    uctMaxNode.childW.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
              //    break;
              //  case 4:
              //    uctMaxNode.childB.add(uct.newNode);// uct.newNodeをuctMaxNodeの子に設定
              //    break;
              //  }
              //  uct.newNode.parent = uctMaxNode;//uctMaxNodeをuct.newNodeの親に設定
              //  uct.newNode.ancestor = ancestor;//uct.newNodeのご先祖さまを記録
              //  uct.newNode.onRGWB = new boolean[5];
              //  for (int p0=1; p0<5; p0++) {// 4人分の作業ここから
              //    // 深さ２以上のパスによる枝切
              //    if (uct.isPassAtDepth2Node(uct.newNode, p0)) {
              //      //print("[pass at"+uctMaxNode.id+";"+p0+"]");
              //      uct.newNode.onRGWB[p0]=false;
              //      continue;
              //    } else {
              //      uct.newNode.onRGWB[p0]=true;
              //    }
              //  }
              //  ancestor.activeNodes.add(uct.newNode);//ご先祖様のアクティブノードに登録
              //  //println("新しいノードに盤情報を記入");
              //  uct.mainBoard.copyBoardToSub(uct.subBoard);
              //  // 1手パスする
              //  uct.subBoard.copyBoardToBd(uct.newNode.bd);
              //  // uct.newNodeの報酬データを初期化
              //  uct.newNode.initRewardOfNode();
              //  // 4回、最後まで打ち切ってバックプロパゲートしておく。
              //  // uct値を有効にするため。
              //  for (int count=0; count<4; count++) {
              //    if (uctMaxNode.onRGWB[count+1]) {
              //      pl.myBoard.simulatorNumber ++;
              //      uct.randomPlayAndBackPropagate(uct.newNode, count+1);
              //    }
              //  }                
              //}
              // アタックチャンスでないときの、子ノードのぶらさげ終了
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
                    uct.qtyNodes[0] ++;
                    uct.newNode.setItem(p, k);
                    uct.newNode.id = uctMaxNode.id + (":"+kifu.playerColCode[p]+nf(j+1, 2)) + (":Y"+nf(i+1, 2));
                    uct.newNode.depth = uctMaxNode.depth + 1;//=newChancenode.depth
                    uct.qtyNodes[uct.newNode.depth] ++;
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
                    uct.newNode.onRGWB = new boolean[5];
                    for (int p0=1; p0<5; p0++) {// 4人分の作業ここから
                      // 深さ２以上のパスによる枝切
                      if (uct.isPassAtDepth2Node(uct.newNode, p0)) {
                        //print("[pass at"+uctMaxNode.id+";"+p0+"]");
                        uct.newNode.onRGWB[p0]=false;
                        continue;
                      } else {
                        uct.newNode.onRGWB[p0]=true;
                      }
                    }
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
                      if (uctMaxNode.onRGWB[count+1]) {
                        pl.myBoard.simulatorNumber ++;
                        uct.randomPlayAndBackPropagate(uct.newNode, count+1);
                      }
                    }
                    //新規ノードの処理ここまで/// アタックチャンスのとき//展開中
                  }
                }
              }// 合法手ごとのforループ ここまで
            }// ACノードの子ノード作成終わり。
            // 子ノードをぶら下げるここまで//展開中
            //uctMctsMainLoop block 02-2-4-4
            // プレイヤーpにとって、筋の悪いものを消す。<- 却下
          }//ここまで、４人分のノード展開
          //println("uctMctsBrain:展開　終了　"+uctMaxNode.id);
        }
      }// アクティブノード削除からの展開、ここまで
      //uctMctsMainLoop block 02-2-5
      //if (pl.myBoard.simulatorNumber >= uct.terminateThreshold) {// 却下
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
    println("No root's legal moves");
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
