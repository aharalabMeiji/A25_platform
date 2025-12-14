// globals //
globals utils=new globals();

class globals {
  board gameMainBoard;// use in games
  board gameSubBoard;// use in board.buildVP
  //playerColor
  color[] playerColor =  {
    color(128, 128, 128),
    color(255, 0, 0),
    color(0, 255, 0),
    color(255, 255, 255),
    color(0, 80, 255),
    color(255, 255, 0) };

  color[] playerShade = {
    color(128, 128, 128, 128),
    color(255, 0, 0, 128),
    color(0, 255, 0, 128),
    color(255, 255, 255, 128),
    color(0, 80, 255, 128),
    color(255, 255, 0, 144) };
  //unitSize
  float unitSize;
  int mainL, mainU, mainW, mainH, subL, subU;
  float fontSize, hOffset, hSpace, vStep;
  String headerText="";
};


//

IntDict gameOptions = new IntDict(); // 0:PlayGame 1:Simulate
int winPointRule = 1;// 0: 単独勝利のみ勝ち、 1:トップ者で按分、2:トップであれば勝ち

//String filename = "default.txt";
String filename = sketchPath()+"\\"+"data"+"\\"+"default.txt";

// buttons
ArrayList<button> buttons;

button buttonStart;
button buttonNew, buttonOpenFile, buttonOpenPsrFile, buttonSaveFile, buttonDeleteFromList, buttonKifuFolder;
button buttonPrevBoard, buttonNextBoard;
button buttonReturnToMenu, buttonMenuGame, buttonMenuSimulation, buttonPass;
button buttonSaveScreenShot;// スクショのボタン
button buttonSaveBoard;// 盤面保存のボタン

// games
games game = new games();
class games {
  int nextPlayer;//1~4 // これは整理したい
  player[] participants; // これは整理したい。
  int previousPlayer=0;
}

// simulators
simulators simulator=new simulators();
class simulators {
  int StartBoardId=0;
  player[] Participants;//これは残す
  board mainBoard;
  board subBoard;
  uctNode rootNode=null;
  int nextPlayer=1;//1~4
}

//int simulator.nextPlayer=1;//1~4
int[] attackChanceVP;// そもそも、アタックチャンスのためのVPはここにあるべきではない。というか、これから廃止の方向にする。
int attackChanceCursor=0;//これは表示のために必要。
int startTime;//時間計測のため
button buttonPrevSV=new button(), buttonNextSV=new button();// これはボタン
boolean winrateConvergents, panelsConvergent;
float prevWinrate1=0, prevWinrate2=0, prevPanels1=0, prevPanels2=0;
float best1Wr=0, best2Wr=0, best1Pr=0, best2Pr=0;

// 棋譜
kifu kifu=new kifu();
class kifu {
  boolean kifuValid=true;
  String string="";
  String[] playerColCode={" ", "R", "G", "W", "B", "Y"};
  String kifuFullPath="";
  String csvPath="";
  String mmddhhmm="";
};

// ランダムに関する提案（回数は保証される、という版）
int[] randomOrder=new int[28];
int randomOrderCount=0;

// UCT
ucbClass ucb1 = new ucbClass();
ucbClass ucb2 = new ucbClass();
class ucbClass {
  board subBoard;
  board subsubBoard;
  uctNode rootNode=null;
  ArrayList<uctNode> fullNodes=null;
  ucbClass() {
    subBoard=new board();
    subsubBoard=new board();
  }
}

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
  int expandThreshold = 10;// ここらあたりの変数があるんだったら、brainの引数要りませんね。
  int terminateThreshold = 10000000;
  int depthMax = 4;
  int cancelCountMax=10;
  int uctMainLoopOption=1;// ここを２にすると、並列処理になる。が、今は使わない。
  float maxNodeWinrate=0.0;
  boolean chanceNodeOn=false;
  uctClass() {
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
  void randomPlayAndBackPropagate(uctNode uctMaxNode) {
    float[] wDeltas = new float[5];
    float[] pDeltas = new float[5];
    //println("uctMctsBrain:",uctMaxNode.id, "のノードを調べる");
    //println("uctMctsBrain:uct.mainBoardへ盤面をコピー");
    if (this.randomPlayBoard==null) {
      this.randomPlayBoard = new board();
    }
    if (this.randomPlayWinPoint==null) {
      this.randomPlayWinPoint = new winPoints();
    }
    this.randomPlayBoard.copyBdToBoard(uctMaxNode.bd);
    //println("uctMctsBrain:uct.mainBoardを最後まで打ち切る");
    int nextplayer = int(random(4))+1;
    this.randomPlayWinPoint = playSimulatorToEnd(this.randomPlayBoard, this.participants, nextplayer);
    //println("uctMctsBrain:nd.wa[p]、nd.pa[p]、nd.uct[p]");
    uctMaxNode.na ++;//

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
      uctMaxNode.wa[p] = averageBackPropagate(
        uctMaxNode.waR[p], uctMaxNode.naR,
        uctMaxNode.waG[p], uctMaxNode.naG,
        uctMaxNode.waW[p], uctMaxNode.naW,
        uctMaxNode.waB[p], uctMaxNode.naB, uctMaxNode.na);
      uctMaxNode.pa[p] = averageBackPropagate(
        uctMaxNode.paR[p], uctMaxNode.naR,
        uctMaxNode.paG[p], uctMaxNode.naG,
        uctMaxNode.paW[p], uctMaxNode.naW,
        uctMaxNode.paB[p], uctMaxNode.naB, uctMaxNode.na);
    }

    //println("親にさかのぼってデータを更新する");
    uctNode nd0 = uctMaxNode;
    uctNode ndC = null;
    do {
      if (nd0.parent!=null) {
        ndC = nd0;
        nd0 = nd0.parent;
        // chance node であるなしに関わらず、上に合流するのが「旧式」//uct.chanceNodeOn=false;
        // chance node から上にあげるときには式を変更するのが「新式」//uct.chanceNodeOn=true;
        nd0.na ++;
        if (uct.chanceNodeOn) {// 「新式」//uct.chanceNodeOn=true;
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
            wDeltas[p] = averageBackPropagate(nd0.waR[p], nd0.naR, nd0.waG[p], nd0.naG, nd0.waW[p], nd0.naW, nd0.waB[p], nd0.naB, nd0.na) - nd0.wa[p];
            nd0.wa[p] += wDeltas[p];//
            pDeltas[p] = averageBackPropagate(nd0.paR[p], nd0.naR, nd0.paG[p], nd0.naG, nd0.paW[p], nd0.naW, nd0.paB[p], nd0.naB, nd0.na) - nd0.pa[p];
            nd0.pa[p] += pDeltas[p];//
          }
        } else {//「旧式」//uct.chanceNodeOn=false;
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
  float averageBackPropagate(float wR, float nR, float wG, float nG, float wW, float nW, float wB, float nB, float na) {
    if (nR+nG+nW+nB!=na) {
      println("illegal move in averageBackPropagate", wR, nR, wG, nG, wW, nW, wB, nB, na);
    }
    float sum=0f;
    if (nR!=0) sum += (wR/nR*0.25);
    if (nR!=0) sum += (wG/nG*0.25);
    if (nR!=0) sum += (wW/nW*0.25);
    if (nR!=0) sum += (wB/nB*0.25);
    return sum*na;
  }
};
