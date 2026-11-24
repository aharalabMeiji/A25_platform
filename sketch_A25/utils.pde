// globals //
globals utils=new globals();

class globals {
  board gameMainBoard;// use in games
  board gameSubBoard;// use in board.buildVP
  board experimentMainBoard;// use in experiment
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
  String filePath; // 選択されたファイルのフルパスを保存する変数
  String filename = "default.txt";//選択されたファイルのファイル名部分
  String filenamePath=sketchPath()+"\\"+"data"+"\\"+"default.txt";// 選択されたファイルのフルパス

  void setups() {
    utils.filename = "default.txt";
    utils.filenamePath = sketchPath()+"\\"+"data"+"\\"+"default.txt";

    utils.unitSize = width;
    utils.mainL = int(utils.unitSize/12);
    utils.mainU = int(utils.unitSize/16);
    utils.mainW = utils.mainL*2;
    utils.mainH = utils.mainU*2;
    utils.subL = utils.mainL;
    utils.subU = int(utils.mainU*1.5)+utils.mainH*5;
    utils.fontSize=utils.unitSize/35;
    utils.hOffset=utils.fontSize;
    utils.hSpace=10;
    utils.vStep=utils.fontSize*1.5;

    utils.gameMainBoard = new board();
    utils.gameSubBoard = new board();
  }
};


//

IntDict gameOptions = new IntDict(); // 0:PlayGame 1:Simulate
void initGameOptions() {
  gameOptions.set("gameMode", 0);
  gameOptions.set("Player1", 0);
  gameOptions.set("Player2", 0);
  gameOptions.set("Player3", 0);
  gameOptions.set("Player4", 0);
  gameOptions.set("Order", 0);// 0 Random, 1:Manual, 2:Conditional random, 3:in turn
  gameOptions.set("Playout", 0);// 0:Random, 1:corner, 2:cross-corner
  gameOptions.set("Times", 1);// 1:once, 100:100 times, 10000:10000 times
  gameOptions.set("SimTimes", 2);
  gameOptions.set("SimMethod", 1);
  gameOptions.set("expandThreshold", 10);
  gameOptions.set("depthMax", 4);
  gameOptions.set("wCancel", 1);
  gameOptions.set("Absence0R", 0);
  gameOptions.set("Absence0G", 0);
  gameOptions.set("Absence0W", 0);
  gameOptions.set("Absence0B", 0);
  gameOptions.set("Absence1R", 0);
  gameOptions.set("Absence1G", 0);
  gameOptions.set("Absence1W", 0);
  gameOptions.set("Absence1B", 0);
  gameOptions.set("chanceNodeOn", 1);
  gameOptions.set("uctOption", 1);//1: maxn, 2:paranoid , 3:maxn + paranoid
  gameOptions.set("pruning", 999);
  gameOptions.set("Rrate", 1);
  gameOptions.set("Grate", 1);
  gameOptions.set("Wrate", 1);
  gameOptions.set("Brate", 1);
}



int winPointRule = 1;// 0: 単独勝利のみ勝ち、 1:トップ者で按分、2:トップであれば勝ち



// games
games game = new games();
class games {
  int nextPlayer;//1~4 // これは整理したい
  player[] participants; // これは整理したい。
  int previousPlayer=0;
  boolean editMode=false;
  ArrayList<board> editBoard=null;
  int times10=10;
  int times100=100;
  int times1000=1000;
  int Rrate=1, Grate=1, Wrate=1, Brate=1;
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
  int Rrate=1, Grate=1, Wrate=1, Brate=1;
  void clearMainBoardSvs(){
    for (int j=0; j<=25; j++) {
      mainBoard.sv[j]=0;
      mainBoard.sv2[j]=0;
    }
  }
  void initMainBoardSs(int[] bd){
    for (int i=0; i<25; i++) {
      mainBoard.s[i].col = bd[i];
      mainBoard.s[i].marked = 0;
    }
  }
  void initParticipantsRandom(){
    simulator.Participants = new player[5];
    for (int p=1; p<5; p++) {
      if (gameOptions.get("Playout")==1) 
        Participants[p] = new player(p, "random", brainType.Heuristic1);//
      else if (gameOptions.get("Playout")==2) 
        Participants[p] = new player(p, "random", brainType.Heuristic2);//
      else 
        Participants[p] = new player(p, "random", brainType.Random);
    }
  }
}

//int simulator.nextPlayer=1;//1~4
int[] attackChanceVP;// そもそも、アタックチャンスのためのVPはここにあるべきではない。というか、これから廃止の方向にする。
int attackChanceCursor=0;//これは表示のために必要。
int startTime;//時間計測のため
button buttonPrevSV=new button(), buttonNextSV=new button();// これはボタン変数たちに合流すべき。
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

// UCB
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
