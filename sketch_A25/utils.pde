// globals //
globals utils=new globals();

class globals{
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
class games{
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
class kifu{
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
class ucbClass{
  board subBoard;
  board subsubBoard;
  uctNode rootNode=null;
  ArrayList<uctNode> fullNodes=null;
  ucbClass(){
    subBoard=new board();
    subsubBoard=new board();
  }
}

uctClass uct = new uctClass();
class uctClass{
  player[] participants;
  winPoints winPoint;
  prize prize;
  board mainBoard;
  board subBoard;
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
  uctClass(){
  }
  void randomPlayAndBackPropagate(uctNode uctMaxNode){
      //println("uctMctsBrain:",uctMaxNode.id, "のノードを調べる");
      //println("uctMctsBrain:uct.mainBoardへ盤面をコピー");
      this.mainBoard.copyBdToBoard(uctMaxNode.bd);
      //println("uctMctsBrain:uct.mainBoardを最後まで打ち切る");
      this.winPoint = playSimulatorToEnd(this.mainBoard, this.participants);
      //println("uctMctsBrain:nd.wa[p]、nd.pa[p]、nd.uct[p]");
      uctMaxNode.na ++;//
      for (int p=1; p<=4; p++) {
        uctMaxNode.wa[p] += this.winPoint.points[p];//2回め以降は和
        uctMaxNode.pa[p] += this.winPoint.panels[p];//2回め以降は和
      }
      //println("親にさかのぼってデータを更新する");
      uctNode nd0 = uctMaxNode;
      do {
        if (nd0.parent!=null) {
          nd0 = nd0.parent;
          // chance node であるなしに関わらず、上に合流するのが「旧式」//uct.chanceNodeOn=false;
          // chance node から上にあげるときには式を変更するのが「新式」//uct.chanceNodeOn=true;
          nd0.na ++;
          for (int p=1; p<=4; p++) {
            nd0.wa[p] += this.winPoint.points[p];//2回め以降は和
            nd0.pa[p] += this.winPoint.panels[p];//2回め以降は和
          }
          //println("uctMctsBrain:→　ノード ",nd0.id, "のデータ("+nd0.wa[1]+","+nd0.wa[2]+","+nd0.wa[3]+","+nd0.wa[4]+")/"+nd0.na);
        } else {// ルートまでたどり着いた、の意味
          // ルートまでたどり着いて、なにか作業する必要があればここに書く。
          break;
        }
      } while (true);//println("親にさかのぼってデータを更新する");//おわり
  }    
};
