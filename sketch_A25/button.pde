// line
class button {
  float left=100, top=100;
  float wid=80, hei=utils.fontSize;
  String dictKey="";
  int dictInt=0;
  void setLT(float _l, float _t, String text) {
    left = _l;
    top = _t;
    wid = textWidth(text)+5;
    hei=utils.fontSize;
  }
  void setItem(String k, int i) {
    dictKey = k;
    dictInt = i;
  }
  boolean mouseOn() {
    if (left<mouseX && mouseX<left+wid) {
      if (top-hei/2<mouseY && mouseY <top+hei/2) {
        return true;
      }
    }
    return false;
  }
  void setLTWH(float _l, float _t, float _w, float _h) {
    this.left = _l;
    this.top = _t+_h*0.5f;
    this.wid = _w;
    this.hei = _h;
  }
};

// buttons
ArrayList<button> buttons;
button buttonStart, buttonExperiment=null;
button buttonNew, buttonOpenFile, buttonOpenPsrFile, buttonSaveFile, buttonDeleteFromList, buttonKifuFolder;
button buttonPrevBoard, buttonDownBoard, buttonNextBoard;// board 列表示の前進・現在・後進（ゲームモード、シムモード）（たぶんゲーム木モードも）
button buttonReturnToMenu, buttonMenuGame, buttonMenuSimulation, buttonPass, buttonUndo;
button buttonSaveScreenShot;// スクショのボタン
button buttonSaveBoard, buttonSaveReplace, buttonSaveAppend;// 盤面保存のボタン
button buttonSaveTree, buttonDispTree;// 盤面保存のボタン
button buttonNNNext;// 3手先データのボタン化
button buttonMainBoard;// メインボードのボタン化


void initButtons() {
  buttons = new ArrayList<button>();
  buttonReturnToMenu = new button();
  buttonSaveScreenShot = new button();
  buttonSaveBoard = new button();
  buttonSaveReplace = new button();
  buttonSaveAppend = new button();
  buttonSaveTree = new button();
  buttonDispTree = new button();
  buttonPass = new button();
  buttonUndo = new button();
  buttonNNNext = new button();
  buttonMainBoard = new button();
  displayManager = dP.onContents;
  managerPhase = mP.GameStart;
  simulationManager = sP.setStartBoard;
}
