// globals //
globals utils=new globals();

class globals{
  board gameMainBoard;// use in games
  board gameSubBoard;// use in board.buildVP
  board simulatorBoard;
  board simulatorSubBoard;
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
int nextSimulatorPlayer=1;//1~4
int simulatorStartBoardId=0;
player[] simulatorParticipants;
float[] attackChanceSV;
float[] attackChanceSV2;
int[] attackChanceVP;// そもそも、アタックチャンスのためのVPはここにあるべきではない。
IntList attackChanceValidNodes = new IntList();
int attackChanceCursor=0;
int startTime;//時間計測のため
button buttonPrevSV=new button(), buttonNextSV=new button();// これはボタン

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
