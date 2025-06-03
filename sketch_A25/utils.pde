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
  //unitSize
  float unitSize;
  int mainL, mainU, mainW, mainH, subL, subU;
  float fontSize, hOffset, hSpace, vStep;
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


int nextPlayer;//1~4 // これは整理したい
player[] participants; // これは整理したい。

// simulators
simulator simulator=new simulator();
class simulator {
  int StartBoardId=0;
  player[] Participants;//これは残す
  board mainBoard;
  board subBoard;
  uctNode rootNode=null;
}

int nextSimulatorPlayer=1;//1~4
int[] attackChanceVP;// そもそも、アタックチャンスのためのVPはここにあるべきではない。というか、これから廃止の方向にする。
int attackChanceCursor=0;//これは表示のために必要。
int startTime;//時間計測のため
button buttonPrevSV=new button(), buttonNextSV=new button();// これはボタン
  boolean WrConv, PrConv;
  float best1WrP=0, best2WrP=0, best1PrP=0, best2PrP=0;
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
uctNode uctRoot=null;
ArrayList<uctNode> fullUctNode=null;
