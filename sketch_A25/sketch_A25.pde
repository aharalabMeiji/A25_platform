import javax.swing.JOptionPane; //
import org.apache.commons.math3.random.MersenneTwister;


MersenneTwister mt;

void setup() {
  size(960, 960);
  mt = new MersenneTwister();
  
  frameRate(10000);//draw()の実行をできるだけ早く繰り返す //<>// //<>//

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
  utils.vStep=utils.fontSize*1.6;

  utils.gameMainBoard = new board();
  utils.gameSubBoard = new board();
  simulator.mainBoard = new board();
  simulator.subBoard = new board();
  game.participants = new player[5];
  game.participants[0] = null;
  managerPhase = mP.GameStart;

  gameOptions.set("gameMode", 0);
  gameOptions.set("Player1", 0);
  gameOptions.set("Player2", 0);
  gameOptions.set("Player3", 0);
  gameOptions.set("Player4", 0);
  gameOptions.set("Order", 0);// 0 Random, 1:Manual, 2:Conditional random, 3:in order
  gameOptions.set("Times", 1);// 1:once, 100:100 times, 10000:10000 times
  gameOptions.set("SimTimes", 2);
  gameOptions.set("SimMethod", 1);
  
  buttons = new ArrayList<button>();
  buttonReturnToMenu = new button();
  buttonSaveScreenShot = new button();
  buttonSaveBoard = new button();
  buttonPass = new button();
  displayManager = dP.onContents;
  managerPhase = mP.GameStart;
  simulationManager = sP.setStartBoard;

  simulatorStartBoard = new ArrayList<startBoard>();
  initStartBoard();
  
}

void draw() {
  if (displayManager == dP.onSimulator) {
    showSimulator();
  } else if (displayManager == dP.onGame) {// 通常のゲーム進行
    showGames();
  } else if (displayManager == dP.onContents) {
    showContents();
  }
}



void mousePressed() {
  if (displayManager == dP.onContents) {
    if (gameOptions.get("gameMode")==0) {// game のメニュー画面
      if (buttonMenuSimulation.mouseOn()) {
        gameOptions.set("gameMode", 1);
        return;
      }
      for (button b : buttons) {
        if (b.mouseOn()) {
          gameOptions.set(b.dictKey, b.dictInt);
          //println(b.dictKey, b.dictInt);
          return;
        }
      }
      if (buttonStart.mouseOn()) {
        displayManager = dP.onGame;
        managerPhase = mP.GameStart;
        utils.gameMainBoard.simulatorNumber=0;
      } else if (buttonPrevBoard.mouseOn()) {
        int total = simulatorStartBoard.size();
        simulator.StartBoardId = (simulator.StartBoardId + total - 1)% total;
      } else if (buttonNextBoard.mouseOn()) {
        int total = simulatorStartBoard.size();
        simulator.StartBoardId = (simulator.StartBoardId + 1)% total;
      } else if (buttonSaveFile.mouseOn()) {
        selectOutput("保存先を選択してください", "saveFileSelected");
      } else if (buttonOpenFile.mouseOn()) {
        selectInput("読み込むファイルを選択してください", "openFileSelected");
      } else if (buttonNew.mouseOn()) {
        simulatorStartBoard.clear();
        simulatorStartBoard.add(startBoard0);
      } else if (buttonDeleteFromList.mouseOn()) {
        if (simulator.StartBoardId!=0) {
          // イエス・ノーダイアログを表示
          int response = JOptionPane.showConfirmDialog(null, "盤面 "+(simulator.StartBoardId)+" を消去しますか？", "消去の確認", JOptionPane.YES_NO_OPTION);
          // ユーザーの応答を確認
          if (response == JOptionPane.YES_OPTION) {
            simulatorStartBoard.remove(simulator.StartBoardId);
          }
        }
      } else if (buttonKifuFolder.mouseOn()) {
        selectOutput("棋譜を保存する場所を選択してください", "saveKifuFileSelected");
      }
    }
    if (gameOptions.get("gameMode")==1) {// simulator のメニュー画面
      if (buttonMenuGame.mouseOn()) {
        gameOptions.set("gameMode", 0);
        return;
      }
      for (button b : buttons) {
        if (b.mouseOn()) {
          gameOptions.set(b.dictKey, b.dictInt);
          if (b.dictKey=="SimMethod" && b.dictInt==1) {
            gameOptions.set("SimTimes", 2);
          } else if (b.dictKey=="SimMethod" && b.dictInt==2) {
            gameOptions.set("SimTimes", 12);
          }
          //println(b.dictKey, b.dictInt);
          return;
        }
      }
      if (buttonStart.mouseOn()) {
        displayManager = dP.onSimulator;
        simulationManager = sP.GameStart;
      } else if (buttonPrevBoard.mouseOn()) {
        int total = simulatorStartBoard.size();
        simulator.StartBoardId = (simulator.StartBoardId + total - 1)% total;
      } else if (buttonNextBoard.mouseOn()) {
        int total = simulatorStartBoard.size();
        simulator.StartBoardId = (simulator.StartBoardId + 1)% total;
      } else if (buttonSaveFile.mouseOn()) {
        selectOutput("保存先を選択してください", "saveFileSelected");
      } else if (buttonOpenFile.mouseOn()) {
        selectInput("読み込むTXTファイルを選択してください", "openFileSelected");
      } else if (buttonOpenPsrFile.mouseOn()) {
        selectInput("読み込むPSRファイルを選択してください", "openPsrFileSelected");
      } else if (buttonNew.mouseOn()) {
        simulatorStartBoard.clear();
        simulatorStartBoard.add(startBoard0);
      } else if (buttonDeleteFromList.mouseOn()) {
        if (simulator.StartBoardId!=0) {
          // イエス・ノーダイアログを表示
          int response = JOptionPane.showConfirmDialog(null, "盤面 "+(simulator.StartBoardId)+" を消去しますか？", "消去の確認", JOptionPane.YES_NO_OPTION);
          // ユーザーの応答を確認
          if (response == JOptionPane.YES_OPTION) {
            simulatorStartBoard.remove(simulator.StartBoardId);
          }
        }
      } else if (buttonKifuFolder.mouseOn()) {
        selectOutput("棋譜を保存する場所を選択してください", "saveKifuFileSelected");
      }
    }
    return;
  } else if (displayManager == dP.onGame) {
    mousePreesedGame();
  } else if (displayManager == dP.onSimulator) {
    mousePreesedSimulator();
  }
}

String filePath; // 選択されたファイルのフルパスを保存する変数
// ダイアログで選択されたファイルパスを取得する関数
void saveFileSelected(File selection) {
  if (selection == null) {
    println("ファイルが選択されませんでした。");
  } else {
    filePath = selection.getAbsolutePath();
    println("選択されたファイルパス: " + filePath);
    if (filePath.substring(filePath.length()-4)!=".txt") {
      filePath += ".txt";
    }
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
    saveStrings(filePath, lines);
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

void openFileSelected(File selection) {
  if (selection == null) {
    println("ファイルが選択されませんでした。");
  } else {
    filePath = selection.getAbsolutePath(); 
    String[] lines = loadStrings(filePath);
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
    } else if (lines[0].charAt(1)=='1' && lines[0].charAt(2)=='3') {
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
    filePath = selection.getAbsolutePath(); //
    String[] lines = loadStrings(filePath);
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
