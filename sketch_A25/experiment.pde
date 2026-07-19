void showExperiment(){
  int gameNumber = 1;// シミュレーションゲーム数
  int gameCount = 0;// シミュレーションゲームのカウント
  player UCBplayer = new player(1, "ucb0", brainType.UCB1);
  player UCTplayer = new player(1, "ucb0", brainType.UCTE10D4);
  player MAXNplayer = new player(1, "ucb0", brainType.UCTD4P1);
  player PARAplayer = new player(1, "ucb0", brainType.UCTD4P1Para);
  player HYBRplayer = new player(1, "ucb0", brainType.UCTD4P1Hybrid);
  if(managerPhase == mP.PrepareGame){
    for(int p=1; p<5; p++){
      game.participants[p] = new player(p, "ucb"+str(p), brainType.UCB1);
    }
    utils.gameMainBoard.attackChanceP=false;//アタックチャンス終了フラグはいったん寝せておく
    game.previousPlayer=0;//次の手番を決めるためのフラグ。たぶん不要。
    game.nextPlayer=0;//最初のプレーヤーは決めない。
    kifu.kifuValid=true;// １つ１つの棋譜ファイルを出力します。
    kifu.mmddhhmm = nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2);
    File folder = new File(sketchPath("kifu/kifu"+ kifu.mmddhhmm));
    if (!folder.exists()) {
      folder.mkdirs();
      println("フォルダを作成しました。"+folder.getAbsolutePath());
    }
    // 特に保存ファイル名が指定されていなければ、自分でフォルダを作って、そこに保存する。
    kifu.kifuFullPath = folder.getAbsolutePath() + "\\" + kifu.mmddhhmm+"_";
    gameCount = 0;
    game.editMode=false;// 盤面の編集モードOFF
    game.editBoard=null;// 盤面の編集モードOFF
    managerPhase=mP.GameStart;
  }
  else if(managerPhase == mP.GameStart){
    if (gameCount == gameNumber){
      managerPhase = mP.GameEnd;
    } else {
      kifu.string="";// 初期盤面以降の着手をここに記録する。
      utils.gameMainBoard.clearCol();// 盤面のクリア
      utils.gameMainBoard.clearMarked();// 盤面のマーキングのクリア
      // 手番のルールを初期化
      order.type=0;// random order
      order.init();
      managerPhase=mP.WaitChoosePlayer;// show setting and wait start
      gameCount++;
    }
  } else if (managerPhase == mP.WaitChoosePlayer){
    game.nextPlayer = order.getNext();// 次の手番を決める //
    for (int p = 1; p<=4; p++) {
      game.participants[p].turn = false;
    }
    game.participants[game.nextPlayer].turn = true;
    // 画面に盤面を表示
    background(255);
    utils.gameMainBoard.displayGame();
    for (int p = 1; p<=4; p++) {
      game.participants[p].displayGame();//
    }
    managerPhase = mP.OnMoving;
  } else if (managerPhase == mP.OnMoving){
    // とりま画面表示
    background(255);
    utils.gameMainBoard.displayGame();
    for (int p = 1; p<=4; p++) {
      game.participants[p].displayGame();//
    }

    // UCBで次の手を決める。
    utils.gameMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
    int UcbAttack = game.participants[game.nextPlayer].callBrain();
    // UCTで次の手を決める。
    // p1-maxnで次の手を決める。
    // p1-paranoidで次の手を決める。
    // p1-hybridで次の手を決める。
    println(kifu.string+","+game.nextPlayer+","+UcbAttack);

    // UCBの手を実行する。
    kifu.string += (kifu.playerColCode[game.nextPlayer]+nf(UcbAttack+1,2));
    utils.gameMainBoard.buildVP(game.nextPlayer);
    if (UcbAttack==25) {        // パスを選択
      managerPhase = mP.AfterMoving;
      game.participants[game.nextPlayer].noPass+=2;// 向こう２ターンはパス禁止
    } else if (utils.gameMainBoard.vp[UcbAttack]>0) {
      utils.gameMainBoard.move(game.nextPlayer, UcbAttack);// 着手可能ならば着手する
      game.participants[game.nextPlayer].noPass = max(0, game.participants[game.nextPlayer].noPass-1);
    }
    managerPhase = mP.AfterMoving;
  } else if (managerPhase == mP.OnAttackChance){
    ;
  } else if (managerPhase == mP.AfterMoving){
    //とりま表示
    background(255);
    utils.gameMainBoard.displayGame();
    for (int p = 1; p<=4; p++) {
      game.participants[p].displayGame();//
    }
    // ゲームが終わっていたら　mP.GameStartへ
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
    } else if (utils.gameMainBoard.attackChanceP==false && remain05 == 4 && remain0 == 4) {// アタックチャンス（着手後に色を消すことができる。）
      utils.gameMainBoard.attackChanceP=true;
      managerPhase = mP.OnAttackChance;
    } else {
      managerPhase = mP.WaitChoosePlayer;
    }
    // さもなくば　mP.WaitChoosePlayerへ
  }
}

//enum mP{// game manager
//  GameStart,
//  WaitChoosePlayer,AfterChoosePlayer,
//  BeforeMoving,OnMoving,AfterMoving,
//  BeforeAttackChance,OnAttackChance,AfterAttackChance,
//  ErrorStop,
//  Halt,
//  GameEnd 
//}
