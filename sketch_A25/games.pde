//line 1480

import java.io.FileWriter;
//import java.io.IOException;
//import java.io.File;

void showReturnButton() { //
  float dx=utils.subL, dy=utils.subU+utils.mainH*1.5+utils.hOffset;
  // return ボタン
  fill(0);
  textSize(utils.fontSize);
  textAlign(LEFT, CENTER);
  String buttonMenuText="[Return to menu]";
  text(buttonMenuText, dx, dy);
  buttonReturnToMenu.setLT(dx, dy, buttonMenuText);
}

void showScreenCapture() {
  float dx=utils.subL+textWidth("[Return to menu]")+utils.hSpace, dy=utils.subU+utils.mainH*1.5+utils.hOffset;
  // スクショ ボタン
  fill(0);
  textSize(utils.fontSize);
  textAlign(LEFT, CENTER);
  String buttonScreenshotText="[Save screenshot]";
  text(buttonScreenshotText, dx, dy);
  buttonSaveScreenShot.setLT(dx, dy, buttonScreenshotText);
}

void showSaveBoard() {
  float dx=utils.subL+textWidth("[Return to menu]")+utils.hSpace+textWidth("[Save screenshot]")+utils.hSpace, dy=utils.subU+utils.mainH*1.5+utils.hOffset;
  // 保存 ボタン
  fill(0);
  textSize(utils.fontSize);
  textAlign(LEFT, CENTER);
  String buttonSaveBoardText="[Save board]";
  text(buttonSaveBoardText, dx, dy);
  buttonSaveBoard.setLT(dx, dy, buttonSaveBoardText);
}

void showPassButton() { //
  float dx=utils.subL+int(utils.mainW+utils.hSpace)*4, dy=utils.subU+utils.mainH*1.5+utils.hOffset;
  // pass ボタン
  fill(0);
  textSize(utils.fontSize);
  textAlign(LEFT, CENTER);
  String buttonPassText="[Pass]";
  text(buttonPassText, dx, dy);
  buttonPass.setLT(dx, dy, buttonPassText);
}

void initRandomOrder() {
  randomOrderCount=0;
  for (int i=0; i<28; i++) {
    randomOrder[i] = (i%4)+1;
  }
  for (int i=0; i<500; i++) {
    int j=int(random(28));
    int k=int(random(28));
    if (j!=k) {
      int tmp=randomOrder[j];
      randomOrder[j] = randomOrder[k];
      randomOrder[k] = tmp;
    }
  }
  //print("random order=");
  //for(int i=0; i<28; i++) {
  //  print(randomOrder[i]);
  //}
  //println();
}

int getRandomOrder() {
  if (randomOrderCount<28) {
    int ret = randomOrder[randomOrderCount];
    randomOrderCount ++;
    return ret;
  } else {
    randomOrderCount ++;
    return int(random(4)+1);
  }

}

void backgroundHeader(){
  stroke(255);fill(255);
  rect(0,0,utils.mainU-1, utils.mainW*10);
}

void showHeader(){
  backgroundHeader();
  stroke(0);fill(0);
  textSize(utils.fontSize);
  textAlign(LEFT, CENTER);
  text(utils.headerText,utils.mainL, utils.mainU*0.5);
}

void showGames() {
  if (managerPhase==mP.GameStart) {
    //println("ゲームモードのプレイヤー初期化");
    if (gameOptions.get("Player1")==0) {
      game.participants[1] = new player(1, "human1", brain.Human);
    } else if (gameOptions.get("Player1")==3) {
      game.participants[1] = new player(1, "ucb-1", brain.UCB1);
    } else if (gameOptions.get("Player1")==4) {
      game.participants[1] = new player(1, "uct-1", brain.UCTE10D4);
    } else {
      game.participants[1] = new player(1, "random1", brain.Random);
    }
    if (gameOptions.get("Player2")==0) {
      game.participants[2] = new player(2, "human2", brain.Human);
    } else if (gameOptions.get("Player2")==3) {
      game.participants[2] = new player(2, "ucb-2", brain.UCB1);
    } else if (gameOptions.get("Player2")==4) {
      game.participants[2] = new player(2, "uct-2", brain.UCTE10D4);
    } else {
      game.participants[2] = new player(2, "random2", brain.Random);
    }
    if (gameOptions.get("Player3")==0) {
      game.participants[3] = new player(3, "human3", brain.Human);
    } else if (gameOptions.get("Player3")==3) {
      game.participants[3] = new player(3, "ucb-3", brain.UCB1);
    } else if (gameOptions.get("Player3")==4) {
      game.participants[3] = new player(3, "uct-3", brain.UCTE10D4);
    } else {
      game.participants[3] = new player(3, "random3", brain.Random);
    }
    if (gameOptions.get("Player4")==0) {
      game.participants[4] = new player(4, "human4", brain.Human);
    } else if (gameOptions.get("Player4")==3) {
      game.participants[4] = new player(4, "ucb-4", brain.UCB1);
    } else if (gameOptions.get("Player4")==4) {
      game.participants[4] = new player(4, "uct-4", brain.UCTE10D4);
    } else {
      game.participants[4] = new player(4, "random4", brain.Random);
    }
    utils.gameMainBoard.attackChanceP=false;//アタックチャンス終了フラグはいったん寝せておく
    game.previousPlayer=0;
    //println("gameモードの盤面初期化");
    if (simulator.StartBoardId==0) {// カラ盤面から始める
      utils.gameMainBoard.clearCol();
      utils.gameMainBoard.clearMarked();
      game.nextPlayer=0;//最初のプレーヤーは決めない。
      kifu.kifuValid=true;// １つ１つの棋譜ファイルを出力します。
      if (kifu.kifuFullPath=="") {
        kifu.mmddhhmm = nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2);
        File folder = new File(sketchPath("kifu/kifu"+ kifu.mmddhhmm));
        if (!folder.exists()) {
          folder.mkdirs();
          println("フォルダを作成しました。"+folder.getAbsolutePath());
        }
        // 特に保存ファイル名が指定されていなければ、自分でフォルダを作って、そこに保存する。
        kifu.kifuFullPath = folder.getAbsolutePath() + "\\" + kifu.mmddhhmm+"_";
      }
    } else {// 途中盤面から始める
      int now = simulator.StartBoardId%simulatorStartBoard.size();
      // println("mP.GameStart:盤面をDBからコピーする");
      int remaining=0;
      for (int k=0; k<25; k++) {
        int c=simulatorStartBoard.get(now).theArray[k];
        utils.gameMainBoard.setCol(k, c);
        if (c==0) {
          remaining ++;
        }
        //if (c==5) {//// println("mP.GameStart:黄色いパネルが存在した");
        //  utils.gameMainBoard.attackChanceP=true;//アタックチャンス終了フラグをたてる
        //}
      }
      if (remaining<=4) {// 空きパネルが４枚以下なら、黄色の有無に関わらずアタックチャンス後。
        //println("mP.GameStart:空きパネルが４枚以下");
        utils.gameMainBoard.attackChanceP=true;//アタックチャンス終了フラグをたてる
      }
      utils.gameMainBoard.clearMarked();
      game.nextPlayer = simulatorStartBoard.get(now).nextPlayer;//最初のプレーヤーは事前に決まっている。
      kifu.kifuValid=false;
      kifu.kifuFullPath="";
      // この場合には、初期盤面以前の着手は存在しない。（想定もしない。）
      // 初期盤面以降の着手（の束）を一つのcsvファイルに保存する
      kifu.mmddhhmm = nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2);
      File folder = new File(sketchPath("kifu/kifu"+ kifu.mmddhhmm));
      if (!folder.exists()) {
        folder.mkdirs();
        println("フォルダを作成しました。"+folder.getAbsolutePath());
      }
      kifu.csvPath = folder.getAbsolutePath() + "\\" + "csv"+ kifu.mmddhhmm+".csv";
    }
    kifu.string="";// 初期盤面以降の着手をここに記録する。
    // 試しに、「ターン回数を均等にするランダム」を作ってみる
    initRandomOrder();
    //randomOrderCount=0;
    //盤面を一度表示
    background(255);
    utils.gameMainBoard.display(0);
    for (int p = 1; p<=4; p++) {
      game.participants[p].display(0);//
    }
    showReturnButton();
    showScreenCapture();
    showPassButton();
    managerPhase=mP.WaitChoosePlayer;// show setting and wait start
  } else if (managerPhase==mP.WaitChoosePlayer) {   
    if (gameOptions.get("Order") == 3) {
      game.nextPlayer = getRandomOrder();// 次の手番をランダムに決める //
      for (int p = 1; p<=4; p++) {
        game.participants[p].turn = false;
      }
      game.participants[game.nextPlayer].turn = true;
      managerPhase = mP.AfterChoosePlayer;
    } else if (gameOptions.get("Order") == 4){
      if (game.previousPlayer==0){
        game.previousPlayer = game.nextPlayer = int(random(4))+1;
      } else {
        game.nextPlayer = (game.previousPlayer%4)+1;
        game.previousPlayer = game.nextPlayer;
      }      
      for (int p = 1; p<=4; p++) {
        game.participants[p].turn = false;
      }
      game.participants[game.nextPlayer].turn = true;
      managerPhase = mP.AfterChoosePlayer;
    } else if (gameOptions.get("Order") == 0){
      game.nextPlayer = mt.nextInt(4)+1; 
      //game.nextPlayer = int(random(4))+1; 
      for (int p = 1; p<=4; p++) {
        game.participants[p].turn = false;
      }
      game.participants[game.nextPlayer].turn = true;
      managerPhase = mP.AfterChoosePlayer;
    }

    
    background(255);
    utils.gameMainBoard.display(0);
    for (int p = 1; p<=4; p++) {
      game.participants[p].display(0);//
    }
    showReturnButton();
    showScreenCapture();
    showSaveBoard();
    fill(0);
    textAlign(LEFT, CENTER);
    textSize(utils.fontSize*0.6);
    text(kifu.string, utils.subL, utils.subU + utils.mainH + utils.hOffset);     //残り枚数のカウントと分岐処理
    
    //managerPhase = mP.AfterChoosePlayer;

  } else if (managerPhase==mP.AfterChoosePlayer) {
    // from game.nextPlayer, set the player's turn
    // 特にすることはなし。
    if (1<= game.nextPlayer && game.nextPlayer<=4 ) {
      managerPhase = mP.BeforeMoving;
    } else {
      print("ERROR:WaitChoosePlayer@draw");
      managerPhase = mP.ErrorStop;
    }
  } else if (managerPhase==mP.BeforeMoving) {
    if (game.participants[game.nextPlayer].myBrain!=brain.Human) {// non-human player uses algorithm
      managerPhase = mP.OnMoving;
    } else if (game.participants[game.nextPlayer].myBrain==brain.Human) {// Human player uses mouse click
      // 着手可能地点にマークを表示する
      utils.gameMainBoard.buildVP(game.nextPlayer);
      for (int i=0; i<25; i++) {
        if (utils.gameMainBoard.vp[i]>0) {
          utils.gameMainBoard.s[i].marked=game.nextPlayer;
        }
      }
      managerPhase = mP.OnMoving;
    }
  } else if (managerPhase == mP.OnMoving) {
    // とりま画面表示
    background(255);
    utils.gameMainBoard.display(0);
    for (int p = 1; p<=4; p++) {
      game.participants[p].display(0);//
    }
    showReturnButton();
    showScreenCapture();
    showSaveBoard();
    showPassButton();
    // CPUのときのムーブ処理
    if (game.participants[game.nextPlayer].myBrain!=brain.Human) {// call strategy algorithm
      utils.gameMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
      int attack = game.participants[game.nextPlayer].callBrain();
      if (attack==-2){// refrainのコード
        //print("["+attack+"]");
      } else {
        kifu.string += (kifu.playerColCode[game.nextPlayer]+nf(attack+1,2));
        utils.gameMainBoard.buildVP(game.nextPlayer);
        if (attack==25) {
          // パスを選択
          managerPhase = mP.AfterMoving;
          game.participants[game.nextPlayer].noPass+=2;// 向こう２ターンはパス禁止
        } else if (utils.gameMainBoard.vp[attack]>0) {
          utils.gameMainBoard.move(game.nextPlayer, attack);// 着手可能ならば着手する
          game.participants[game.nextPlayer].noPass = max(0, game.participants[game.nextPlayer].noPass-1);
          managerPhase = mP.AfterMoving;
        } else {
          println("ERROR:OnMoving@draw");
          print("ボード：");
          for (int kki=0;kki<5;kki++){
            for (int kkj=0;kkj<5;kkj++){
              print(" "+utils.gameMainBoard.s[kkj+kki*5].col);
            }
            print(":");
          }
          println();
          println("kifu: "+kifu.string);
          println("attack: "+attack);
          managerPhase = mP.ErrorStop;
        }
      }
    }
  } else if (managerPhase==mP.AfterMoving) {
    //とりま表示
    background(255);
    utils.gameMainBoard.display(0);
    for (int p = 1; p<=4; p++) {
      game.participants[p].display(0);//
    }
    showReturnButton();
    showScreenCapture();
    showSaveBoard();
    int remain05 = 0;
    int remain0 =0;
    for (int i=0; i<25; i++) {
      if (utils.gameMainBoard.getCol(i)==0) {
        remain0 ++;
        remain05 ++;
      } else if (utils.gameMainBoard.getCol(i)==5) {
        remain05 ++;
      }
    }
    if (remain05 == 0) {
      managerPhase = mP.GameEnd;
    } else if (utils.gameMainBoard.attackChanceP==false && remain0 == 4) {// アタックチャンス（着手後に色を消すことができる。）
      utils.gameMainBoard.attackChanceP=true;
      managerPhase = mP.BeforeAttackChance;
    } else {
      managerPhase = mP.WaitChoosePlayer;
    }
  } else if (managerPhase==mP.GameEnd) {///////mP.GameEnd
    background(255);
    for (int p = 1; p<=4; p++) {
      game.participants[p].display(0);
    }
    showReturnButton();
    showScreenCapture();
    utils.gameMainBoard.simulatorNumber ++;
    // スコア計算
    int[] count=new int[5];
    int[] Pt1 = new int[5];
    int[] Pt2 = new int[5];
    for (int p = 1; p<=4; p++) {
      for (int k=0; k<25; k++) {
        if (utils.gameMainBoard.getCol(k)==p) {
          count[p] ++;
        }
      }
    }
    for (int p = 1; p <= 4; p ++) {
      for (int q = 1; q <= 4; q ++) {
        if (count[p] > count[q]) Pt1[p] ++;
        if (count[p] >= count[q]) Pt2[p] ++;
      }
    }
    for (int p = 1; p <= 4; p ++) {
      if (Pt2[p]==4) {// win
        game.participants[p].score += (1.0/ (Pt2[p]-Pt1[p]));
      }
    }
    // 棋譜を保存
    if (kifu.kifuValid) {// 空白状態からのゲーム
      String kifuFilePath;
      kifuFilePath=kifu.kifuFullPath + nf(utils.gameMainBoard.simulatorNumber, 4)+".kifu";
      //
      String[] lines = new String[1];
      lines[0] = kifu.string;
      saveStrings(kifuFilePath, lines);
    } else {// 初期状態指定からのゲーム
      if (kifu.string!="") {
        //PrintWriter writer = new PrintWriter(new FileWriter(kifu.csvPath, true)); // 追記モード
        try {
          FileWriter writer = new FileWriter(kifu.csvPath, true);
          writer.write(kifu.string+","+count[game.nextPlayer]+","+(Pt2[game.nextPlayer]==4)+"\n");
          writer.close();
        }
        catch (IOException e) {
          println("error"+e.getMessage());
        }
      }
    }
    game.nextPlayer = simulatorStartBoard.get(simulator.StartBoardId).nextPlayer;
    // 繰り返し判定
    if (utils.gameMainBoard.simulatorNumber == gameOptions.get("Times") ) {
      // 結果の表示
      background(255);
      utils.gameMainBoard.display(0);
      for (int p = 1; p<=4; p++) {
        game.participants[p].display(0);
      }
      showReturnButton();
      showScreenCapture();
      fill(0);
      textAlign(LEFT, CENTER);
      textSize(utils.fontSize*0.6);
      text(kifu.string, utils.subL, utils.subU + utils.mainH + utils.hOffset);     //残り枚数のカウントと分岐処理

      // 棋譜文字列の初期化
      kifu.string="";
      managerPhase = mP.Halt;
    } else {
      if (simulator.StartBoardId==0) {
        utils.gameMainBoard.clearCol();
        utils.gameMainBoard.clearMarked();
        game.nextPlayer=0;
        kifu.kifuValid=true;
        utils.gameMainBoard.attackChanceP=false;
      } else {
        // utils.gameMainBoard.clearCol();
        int remaining=0;
        int now = simulator.StartBoardId%simulatorStartBoard.size();
        utils.gameMainBoard.attackChanceP=false;
        utils.gameMainBoard.clearMarked();
        for (int k=0; k<25; k++) {
          int c = simulatorStartBoard.get(now).theArray[k];
          utils.gameMainBoard.setCol(k, c);
          if (c==0) {
            remaining ++;
          }
          //if (c==5) {
          //  utils.gameMainBoard.attackChanceP=true;
          //}
        }
        if (remaining<=4) {
          utils.gameMainBoard.attackChanceP=true;
        }
        game.nextPlayer = simulatorStartBoard.get(now).nextPlayer;
        kifu.kifuValid=false;
      }
      // 棋譜文字列の初期化
      kifu.string="";
      initRandomOrder();
      managerPhase = mP.WaitChoosePlayer;
    }
    ///////mP.GameEndここまで
  } else if (managerPhase==mP.BeforeAttackChance) {///////mP.BeforeAttackChance
    //人間のプレーのときには、アタックチャンスで消せる枠にマークを付ける
    if (game.participants[game.nextPlayer].myBrain==brain.Human) {
      for (int i=0; i<25; i++) {
        if (1 <= utils.gameMainBoard.s[i].col && utils.gameMainBoard.s[i].col <= 4) {
          utils.gameMainBoard.s[i].marked=game.nextPlayer;
        } else {
          utils.gameMainBoard.s[i].marked=0;
        }
      }
      utils.gameMainBoard.display(0);
    }
    managerPhase=mP.OnAttackChance;
  } else if (managerPhase==mP.OnAttackChance) {//
    // CPU ならば、callAttackChanceを実行
    // 選ばれた箇所を黄色（コード５）へ変更
    // 人ならば、マウスクリック入力待ち
    if (game.participants[game.nextPlayer].myBrain!=brain.Human) {
      utils.gameMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);
      int attack = game.participants[game.nextPlayer].callAttackChance();
      if (1 <= utils.gameMainBoard.s[attack].col && utils.gameMainBoard.s[attack].col <= 4) {
        utils.gameMainBoard.s[attack].col=5;
      }
      String strAttack=str(attack+1);
      if (strAttack.length()<2) {
        kifu.string += (kifu.playerColCode[5]+"0"+strAttack);
      } else {
        kifu.string += (kifu.playerColCode[5]+strAttack);
      }
      // 結果の表示
      background(255);
      utils.gameMainBoard.display(0);
      for (int p = 1; p<=4; p++) {
        game.participants[p].display(0);
      }
      showReturnButton();
      showScreenCapture();
      managerPhase=mP.AfterAttackChance;
    }
  } else if (managerPhase==mP.AfterAttackChance) {//
    for (int i=0; i<25; i++) {
      utils.gameMainBoard.s[i].marked=0;
    }
    //
    managerPhase=mP.WaitChoosePlayer;
  } else if (managerPhase==mP.Halt) {// 停止状態
  ;
  }
}

void mousePreesedGame() {// ゲーム中のキーボード待ちの処理
  if (buttonReturnToMenu.mouseOn()) {//　メニューに戻る、をクリックされたとき
    displayManager = dP.onContents;
    managerPhase=mP.GameStart;
    return;
  } else if (buttonSaveScreenShot.mouseOn()) {//　メニューに戻る、をクリックされたとき
    //save("screenshot.png");
    selectOutput("スクリーンショットを保存", "saveScreenShotSelected");
  } else if (buttonSaveBoard.mouseOn()) {
    int[] tmpBoard = new int[25];
    for (int k=0; k<25; k++) {
      tmpBoard[k]=utils.gameMainBoard.s[k].col;
    }
    simulatorStartBoard.add (new startBoard(tmpBoard, game.nextPlayer));
    float dx=utils.subL+textWidth("[Return to menu]")+utils.hSpace+textWidth("[Save screenshot]")+utils.hSpace+textWidth("[Save board]")+utils.hSpace, dy=utils.subU+utils.mainH+30;
    text("saved", dx, dy);
  } else if (managerPhase==mP.WaitChoosePlayer) {// 次の手番がマニュアルのとき
    if (gameOptions.get("Order") == 1) {// マウスクリックで次の手番を指定する
      for (int p = 1; p<=4; p++) { //
        if (game.participants[p].mouseOn(0)) {
          game.nextPlayer = p;
        }
      }
      if (1<=game.nextPlayer && game.nextPlayer<=4) {
        for (int p = 1; p<=4; p++) {
          game.participants[p].turn = false;
        }
        game.participants[game.nextPlayer].turn = true;
        managerPhase = mP.AfterChoosePlayer;
        utils.gameMainBoard.display(0);
      }
    }
  } else if (managerPhase==mP.OnMoving && game.participants[game.nextPlayer].myBrain==brain.Human) {// 人がプレイするとき
    int attack=0;
    int mx = int((mouseX-utils.mainL)/utils.mainW);
    int my = int((mouseY-utils.mainU)/utils.mainH);
    if ((0<=mx && mx<=4) && (0<=my && my<=4)) {
      attack= mx+my*5;
      utils.gameMainBoard.buildVP(game.nextPlayer);
      if (utils.gameMainBoard.vp[attack]>0) {
        String strAttack=str(attack+1);
        if (strAttack.length()<2) {
          kifu.string += (kifu.playerColCode[game.nextPlayer]+"0"+strAttack);
        } else {
          kifu.string += (kifu.playerColCode[game.nextPlayer]+strAttack);
        }
        utils.gameMainBoard.move(game.nextPlayer, attack);
        //
        for (int i=0; i<25; i++) {
          utils.gameMainBoard.s[i].marked=0;
        }
        game.participants[game.nextPlayer].noPass = max(0, game.participants[game.nextPlayer].noPass-1);
        managerPhase = mP.AfterMoving;
        for (int p = 1; p<=4; p++) {
          game.participants[p].turn = false;
        }
        background(255);
        utils.gameMainBoard.display(0);
        for (int p = 1; p<=4; p++) {
          game.participants[p].display(0);//
        }
        showReturnButton();
        showScreenCapture();
        showPassButton();
      }
    } else if (buttonPass.mouseOn() && game.participants[game.nextPlayer].noPass==0) {
      kifu.string += (kifu.playerColCode[game.nextPlayer]+"26");
      for (int i=0; i<25; i++) {
        utils.gameMainBoard.s[i].marked=0;
      }
      game.participants[game.nextPlayer].noPass ++;
      managerPhase = mP.AfterMoving;
      for (int p = 1; p<=4; p++) {
        game.participants[p].turn = false;
      }
      background(255);
      utils.gameMainBoard.display(0);
      for (int p = 1; p<=4; p++) {
        game.participants[p].display(0);//
      }
      showReturnButton();
      showScreenCapture();
      showPassButton();
    }
  } else if (managerPhase==mP.OnAttackChance) {
    if (game.participants[game.nextPlayer].myBrain==brain.Human) {// 人がアタックチャンスで消すとき
      int mx = int((mouseX-utils.mainL)/utils.mainW);
      int my = int((mouseY-utils.mainU)/utils.mainH);
      if ((0<=mx && mx<=4) && (0<=my && my<=4)) {
        int attack = mx+my*5;
        String strAttack = str(attack+1);
        if (strAttack.length()<2) {
          kifu.string += ("Y"+"0"+strAttack);
        } else {
          kifu.string += ("Y"+strAttack);
        }
        if (1 <= utils.gameMainBoard.s[attack].col && utils.gameMainBoard.s[attack].col <= 4) {
          utils.gameMainBoard.s[attack].col=5;
          for (int i=0; i<25; i++) {
            utils.gameMainBoard.s[i].marked=0;
          }
          managerPhase = mP.AfterAttackChance;
        }
      }
    }
  }
}
