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
  String filePath; // 選択されたファイルのフルパスを保存する変数
  String filename = "default.txt";//選択されたファイルのファイル名部分
  String filenamePath=sketchPath()+"\\"+"data"+"\\"+"default.txt";// 選択されたファイルのフルパス

};


//

IntDict gameOptions = new IntDict(); // 0:PlayGame 1:Simulate
int winPointRule = 1;// 0: 単独勝利のみ勝ち、 1:トップ者で按分、2:トップであれば勝ち


// buttons
ArrayList<button> buttons;

button buttonStart;
button buttonNew, buttonOpenFile, buttonOpenPsrFile, buttonSaveFile, buttonDeleteFromList, buttonKifuFolder;
button buttonPrevBoard, buttonNextBoard;
button buttonReturnToMenu, buttonMenuGame, buttonMenuSimulation, buttonPass, buttonUndo;
button buttonSaveScreenShot;// スクショのボタン
button buttonSaveBoard, buttonSaveReplace, buttonSaveAppend;// 盤面保存のボタン
button buttonSaveTree;// 盤面保存のボタン
button buttonNNNext;// 3手先データのボタン化
button buttonMainBoard;// メインボードのボタン化

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
