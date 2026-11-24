//一般的な課題：人数を減らすオプションをつけるかどうか。
//一般的な課題：JSへ移植するかどうか。
// 十字盤面で、UCT/E10/D4/wC/maxnが、画面遷移が起こらないのをチェック

import javax.swing.JOptionPane; //
import org.apache.commons.math3.random.MersenneTwister;

MersenneTwister mt;

void setup() {
  size(960, 960);
  //int randomSeed = 1;
  //mt = new MersenneTwister(MTseed);
  frameRate(10000);//draw()の実行をできるだけ早く繰り返す
  
  utils.setups();
  simulator.mainBoard = new board();
  simulator.subBoard = new board();
  game.participants = new player[5];
  game.participants[0] = null;
  managerPhase = mP.GameStart;
  initGameOptions();// utils.pde
  initButtons();// button
  simulatorStartBoard = new ArrayList<startBoard>();
  initStartBoard();
  
}

void draw() {  
  if (displayManager == dP.onSimulator) {// シミュレーション
    showSimulator();
  } else if (displayManager == dP.onGame) {// ゲーム進行
    showGames();
  } else if (displayManager == dP.onContents) {
    showContents();
  } else if (displayManager == dP.onTree){
    tree.show();
  } else if (displayManager == dP.onExperiment){
    showExperiment();
  } else if (displayManager == dP.onExperimentalSimulator){
    showExpSim();
  }
}



void mousePressed() {
  if (displayManager == dP.onContents) {
    if (gameOptions.get("gameMode")==0) {// game のメニュー画面
      for (button b : buttons) {
        if (b.mouseOn()) {//メニューをクリックすると選択される。
          if (b.dictKey.equals("Times") && b.dictInt==game.times10 && gameOptions.get("Times")==game.times10){
            game.times10 += 10;
            if (game.times10 == 100) game.times10 = 10;
            gameOptions.set("Times", game.times10);
          } else if (b.dictKey.equals("Times") && b.dictInt==game.times100 && gameOptions.get("Times")==game.times100){
            game.times100 += 100;
            if (game.times100 == 1000) game.times100 = 100;
            gameOptions.set("Times", game.times100);
          } else if (b.dictKey.equals("Times") && b.dictInt==game.times1000 && gameOptions.get("Times")==game.times1000){
            game.times1000 += 1000;
            if (game.times1000 == 11000) game.times1000 = 1000;
            gameOptions.set("Times", game.times1000);
          } else if (b.dictKey.equals("Rrate") && gameOptions.get("Rrate")==game.Rrate){
            game.Rrate ++;
            if(game.Rrate==6) game.Rrate=1;
            gameOptions.set("Rrate", game.Rrate);
          } else if (b.dictKey.equals("Grate") && gameOptions.get("Grate")==game.Grate){
            game.Grate ++;
            if(game.Grate==6) game.Grate=1;
            gameOptions.set("Grate", game.Grate);
          } else if (b.dictKey.equals("Wrate") && gameOptions.get("Wrate")==game.Wrate){
            game.Wrate ++;
            if(game.Wrate==6) game.Wrate=1;
            gameOptions.set("Wrate", game.Wrate);
          } else if (b.dictKey.equals("Brate") && gameOptions.get("Brate")==game.Brate){
            game.Brate ++;
            if(game.Brate==6) game.Brate=1;
            gameOptions.set("Brate", game.Brate);
          } else {
            gameOptions.set(b.dictKey, b.dictInt);
          }
          return;
        }
      }
      if (buttonStart.mouseOn()) {//START
        displayManager = dP.onGame;
        managerPhase = mP.GameStart;
        utils.gameMainBoard.simulatorNumber=0;
      } else if (buttonExperiment!=null && buttonExperiment.mouseOn()){
        displayManager = dP.onExperiment;
        managerPhase = mP.PrepareGame;
      } else if (buttonNew.mouseOn()) {// new list
        simulatorStartBoard.clear();
        simulatorStartBoard.add(startBoard0);
      } else if (buttonOpenFile.mouseOn()) {// open file
        selectInput("読み込むファイルを選択してください", "openFileSelected");
      } else if (buttonSaveFile.mouseOn()) {// save file
        selectOutput("保存先を選択してください", "saveFileSelected");
      } else if (buttonDeleteFromList.mouseOn()) {// delete from list
        if (simulator.StartBoardId!=0) {
          // イエスノーダイアログを表示
          int response = JOptionPane.showConfirmDialog(null, "盤面 "+(simulator.StartBoardId)+" を消去しますか？", "消去の確認", JOptionPane.YES_NO_OPTION);
          // ユーザーの応答を確認
          if (response == JOptionPane.YES_OPTION) {
            simulatorStartBoard.remove(simulator.StartBoardId);
          }
        }
      } else if (buttonKifuFolder.mouseOn()) {// kifu folder
        selectOutput("棋譜を保存する場所を選択してください", "saveKifuFileSelected");
      } else if (buttonPrevBoard.mouseOn()) {//previous board
        int total = simulatorStartBoard.size();
        simulator.StartBoardId = (simulator.StartBoardId + total - 1)% total;
      } else if (buttonNextBoard.mouseOn()) {//next board
        int total = simulatorStartBoard.size();
        simulator.StartBoardId = (simulator.StartBoardId + 1)% total;
      }
    }
    if (gameOptions.get("gameMode")==1) {// simulator のメニュー画面
      for (button b : buttons) {
        if (b.mouseOn()) {
          gameOptions.set(b.dictKey, b.dictInt);
          if (b.dictKey=="SimMethod" && b.dictInt==1) {
            gameOptions.set("SimTimes", 2);
          } else if (b.dictKey=="SimMethod" && b.dictInt==2) {
            gameOptions.set("SimTimes", 12);
          } else if (b.dictKey=="SimMethod" && b.dictInt==3) {
            gameOptions.set("SimTimes", 21);
          } else if (b.dictKey=="SimTimes" && b.dictInt==25) {
            gameOptions.set("expandThreshold", 10);
            gameOptions.set("terminateThreshold", 5);
            gameOptions.set("depthMax", 4);
            gameOptions.set("wCancel", 1);
          } else if (b.dictKey=="SimTimes" && (b.dictInt==26 || b.dictInt==28)){
            gameOptions.set("pruning", 1); 
          } else if (b.dictKey=="SimTimes" && (b.dictInt==27 || b.dictInt==29)){
            gameOptions.set("pruning", 2); 
          } else if (b.dictKey=="SimTimes" && (b.dictInt==21 || b.dictInt==22 || b.dictInt==23 || b.dictInt==24)){
            gameOptions.set("pruning", 999); 
          } else if (b.dictKey.equals("Rrate") && gameOptions.get("Rrate")==simulator.Rrate){
            simulator.Rrate ++;
            if(simulator.Rrate==6) simulator.Rrate=1;
            gameOptions.set("Rrate", simulator.Rrate);
          } else if (b.dictKey.equals("Grate") && gameOptions.get("Grate")==simulator.Grate){
            simulator.Grate ++;
            if(simulator.Grate==6) simulator.Grate=1;
            gameOptions.set("Grate", simulator.Grate);
          } else if (b.dictKey.equals("Wrate") && gameOptions.get("Wrate")==simulator.Wrate){
            simulator.Wrate ++;
            if(simulator.Wrate==6) simulator.Wrate=1;
            gameOptions.set("Wrate", simulator.Wrate);
          } else if (b.dictKey.equals("Brate") && gameOptions.get("Brate")==simulator.Brate){
            simulator.Brate ++;
            if(simulator.Brate==6) simulator.Brate=1;
            gameOptions.set("Brate", simulator.Brate);
          }
          return;
        }
      }
      if (buttonStart.mouseOn()) {// start
        displayManager = dP.onSimulator;
        simulationManager = sP.GameStart;
      } else if (buttonExperiment!=null && buttonExperiment.mouseOn()){//100回シミュレーション
        displayManager = dP.onExperimentalSimulator;
        simulationManager = sP.GameStart;
      } else if (buttonPrevBoard.mouseOn()) {//previous board
        int total = simulatorStartBoard.size();
        simulator.StartBoardId = (simulator.StartBoardId + total - 1)% total;
      } else if (buttonDownBoard.mouseOn()){//simulationの中央ボード下の色変更        
        int total = simulatorStartBoard.size();
        int startBoardId = (simulator.StartBoardId)% total;
        simulatorStartBoard.get(startBoardId).add1NextPlayer();
        //simulatorStartBoard.get(startBoardId).display();
      } else if (buttonNextBoard.mouseOn()) {// next board
        int total = simulatorStartBoard.size();
        simulator.StartBoardId = (simulator.StartBoardId + 1)% total;
      } else if (buttonNew.mouseOn()) {// new list
        simulatorStartBoard.clear();
        simulatorStartBoard.add(startBoard0);
      } else if (buttonSaveFile.mouseOn()) {// save file
        selectOutput("保存先を選択してください", "saveFileSelected");
      } else if (buttonOpenFile.mouseOn()) {// open file
        selectInput("読み込むファイルを選択してください", "openFileSelected");
      //} else if (buttonOpenPsrFile.mouseOn()) {
      //  selectInput("読み込むPSRファイルを選択してください", "openPsrFileSelected");
      } else if (buttonDeleteFromList.mouseOn()) {// delete from lst
        if (simulator.StartBoardId!=0) {
          // イエスノーダイアログを表示
          int response = JOptionPane.showConfirmDialog(null, "盤面 "+(simulator.StartBoardId)+" を消去しますか？", "消去の確認", JOptionPane.YES_NO_OPTION);
          // ユーザーの応答を確認
          if (response == JOptionPane.YES_OPTION) {
            simulatorStartBoard.remove(simulator.StartBoardId);
          }
        }
      } else if (buttonKifuFolder.mouseOn()) {// set kifu folder // simulationにはボタンがない。
        selectOutput("棋譜を保存する場所を選択してください", "saveKifuFileSelected");
      }
    }
    return;
  } else if (displayManager == dP.onGame) {
    mousePressedGame();
  } else if (displayManager == dP.onSimulator) {
    mousePreesedSimulator();
  } else if (displayManager == dP.onTree){
    tree.mousePressedTree();
  }
}

boolean differentExt(String s1, String ext){
  int len = s1.length();
  int repeat=ext.length();
  for (int i=0; i<repeat; i++){
    if (s1.charAt(len-repeat+i)!=ext.charAt(i)) return true;
  }
  return false;
}
// ダイアログで選択されたファイルパスを取得する関数
void saveFileSelected(File selection) {
  if (selection == null) {
    println("ファイルが選択されませんでした。");
  } else {
    utils.filePath = selection.getAbsolutePath();
    
    if (differentExt(utils.filePath,".txt")==true ){
      utils.filePath += ".txt";
    }
    println("選択されたファイルパス: " + utils.filePath);
    utils.filenamePath = utils.filePath;
    utils.filename = filenameFromPath(utils.filePath);
    int lineSize = simulatorStartBoard.size();
    String[] lines = new String[lineSize];

    for (int i=0; i<lineSize; i++) {
      startBoard sb = simulatorStartBoard.get(i);
      lines[i]="";
      for (int k=0; k<25; k++) {
        lines[i] += (""+sb.theArray[k]+",");
      }
      lines[i] += (""+sb.nextPlayer);
    }
    saveStrings(utils.filePath, lines);
  }
}

void saveKifuFileSelected(File selection) {
  if (selection == null) {
    println("ファイルが選択されませんでした。");
  } else {
    kifu.kifuFullPath = selection.getAbsolutePath();
    println("選択されたファイルパス: " + kifu.kifuFullPath);
  }
}

String filenameFromPath(String fn){
  int len=fn.length();
  String ret="";
  int phase=0;
  for (int i=len-1; i>=0; i--){
    if (phase==0){
      ret = str(fn.charAt(i))+ret;
      if (fn.charAt(i)=='.'){
        phase=1;
      }
    } else if (phase==1){
      if (fn.charAt(i)=='\\') return ret;
      ret = str(fn.charAt(i))+ret;
    }
  }
  return ret;
}
void openFileSelected(File selection) {
  if (selection == null) {
    println("ファイルが選択されませんでした。");
  } else {
    utils.filePath = selection.getAbsolutePath(); 
    println("選択されたファイルパス: " + utils.filePath);
    utils.filenamePath = utils.filePath;
    utils.filename = filenameFromPath(utils.filePath);
    String[] lines = loadStrings(utils.filePath);
    int lineSize=lines.length;
    if (lines[0].charAt(0)=='0' && lines[0].charAt(1)==',') {
      //println(lines[0].substring(0, 4));
      simulatorStartBoard.clear();
      for (int i=0; i<lineSize; i++) {
        String[] panels = splitTokens(lines[i], ",");
        if (panels.length>=26) {
          int[] nums = new int[25];
          for (int k=0; k<25; k++) {
            nums[k] = int(panels[k]);
          }
          simulatorStartBoard.add (new startBoard(nums, int(panels[25])));
        } else {
          println("第"+i+"行目が不正なデータです。");
        }
      }
    } else if ((lines[0].charAt(1)=='1' && lines[0].charAt(2)=='3') ||
      (lines[0].charAt(1)=='2' && lines[0].charAt(2)=='6' && lines[0].charAt(4)=='1' && lines[0].charAt(5)=='3')) {
      //println(lines[0].substring(0, 4));
      simulatorStartBoard.clear();
      int len = lines[0].length();
      int player=0;
      int[] nums = new int[25];
      for (int k=0; k<25; k++) {
        nums[k] = 0;
      }
      for (int c=0; c<len; c +=3) {
        int ch0, ch1, move;
        player = color2Player(lines[0].charAt(c));
        if (player==5) {
          ch0=int(lines[0].charAt(c+1))-int('0');
          ch1=int(lines[0].charAt(c+2))-int('0');
          move=ch0*10+ch1-1;
          nums[move]=5;
          c+=3;
          player = color2Player(lines[0].charAt(c));
        }
        simulatorStartBoard.add (new startBoard(nums, player));
        ch0=int(lines[0].charAt(c+1))-int('0');
        ch1=int(lines[0].charAt(c+2))-int('0');
        move=ch0*10+ch1-1;
        if (move<25) {
          for (int k=0; k<25; k++) {
            utils.gameMainBoard.s[k].col = nums[k];
          }
          utils.gameMainBoard.move(player, move);
          for (int k=0; k<25; k++) {
            nums[k] = utils.gameMainBoard.s[k].col;
          }
        }
      }
    } else if (lines[0].charAt(0)=='p' && lines[0].charAt(1)=='s' && lines[0].charAt(2)=='i' && lines[0].charAt(3)=='m') {
      simulatorStartBoard.clear();
      int p=9;
      int[] bb0=new int[25];
      int[] bb1=new int[25];
      int nextP=0;
      for (int i=0; i<lineSize; i++) {
        String brds0=lines[p];
        String brds1=lines[p+2];
        if (brds0.length()!=27|| brds1.length()!=27) {
          break;
        }
        //assert brds0.length()==26;
        if (brds1.charAt(0)==':') break; //
        nextP=0;
        for (int j=0; j<25; j++) {
          bb0[j] = Character.getNumericValue(brds0.charAt(j+1));
          bb1[j] = Character.getNumericValue(brds1.charAt(j+1));
          if (bb0[j]==9)
            bb0[j]=5;
          if (bb1[j]==9)
            bb1[j]=5;
          if (bb0[j]!=bb1[j] && bb1[j]!=5)
            nextP = bb1[j];
        }
        if (nextP!=0)
          simulatorStartBoard.add(new startBoard(bb0, nextP)); //
        p += 2;
      }
    } else {
      println("適切なファイルが選択されませんでした。");
    }
  }
}

int color2Player(char ch) {
  if (ch=='R') return 1;
  else if (ch == 'G') return 2;
  else if (ch == 'W') return 3;
  else if (ch == 'B') return 4;
  else if (ch == 'Y') return 5;
  return 0;
}

void openPsrFileSelected(File selection) {
  if (selection == null) {
    println("ファイルが選択されませんでした。");
  } else {
    utils.filePath = selection.getAbsolutePath(); //
    utils.filenamePath = utils.filePath;
    utils.filename = filenameFromPath(utils.filePath);
    String[] lines = loadStrings(utils.filePath);
    int lineSize=lines.length;
    simulatorStartBoard.clear();
    int p=9;
    int[] bb0=new int[25];
    int[] bb1=new int[25];
    int nextP=0;
    for (int i=0; i<lineSize; i++) {
      String brds0=lines[p];
      String brds1=lines[p+2];
      if (brds0.length()!=27|| brds1.length()!=27) {
        break;
      }
      //assert brds0.length()==26;
      if (brds1.charAt(0)==':') break; //
      nextP=0;
      for (int j=0; j<25; j++) {
        bb0[j] = Character.getNumericValue(brds0.charAt(j+1));
        bb1[j] = Character.getNumericValue(brds1.charAt(j+1));
        if (bb0[j]==9)
          bb0[j]=5;
        if (bb1[j]==9)
          bb1[j]=5;
        if (bb0[j]!=bb1[j] && bb1[j]!=5)
          nextP = bb1[j];
      }
      if (nextP!=0)
        simulatorStartBoard.add(new startBoard(bb0, nextP)); //
      p += 2;
    }
  }
}
