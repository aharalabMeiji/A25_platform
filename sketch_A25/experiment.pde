int experimentGameNumber = 10;// シミュレーションゲーム数
int experimentGameCount = 0;// シミュレーションゲームのカウント
int experimentTurnCount = 0;

int ucbAttack,ucbYellow;
String ucbText;
int uct1Attack,uct1Yellow;
String uct1Text;
int maxnAttack,maxnYellow;
String maxnText;
int paraAttack,paraYellow;
String paraText;
int hybrAttack,hybrYellow;
String hybrText;
player UCBplayer;
player UCTplayer;
player MAXNplayer;
player PARAplayer;
player HYBRplayer;


void showExperiment(){
  if(managerPhase == mP.PrepareGame){
    //int a = 1/0;
    if(utils.experimentMainBoard==null) utils.experimentMainBoard=new board();
    if (UCBplayer == null) UCBplayer = new player(1, "ucb0", brainType.UCB1);
    if (UCTplayer == null)  UCTplayer = new player(1, "ucb0", brainType.UCTE10D4);
    if (MAXNplayer == null)  MAXNplayer = new player(1, "ucb0", brainType.UCTD4P1);
    if (PARAplayer == null)  PARAplayer = new player(1, "ucb0", brainType.UCTD4P1Para);
    if (HYBRplayer == null)  HYBRplayer = new player(1, "ucb0", brainType.UCTD4P1Hybrid);
    for(int p=1; p<5; p++){
      game.participants[p] = new player(p, "ucb"+str(p), brainType.UCB1);
    }
    utils.experimentMainBoard.attackChanceP=false;//アタックチャンス終了フラグはいったん寝せておく
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
    kifu.kifuFullPath = folder.getAbsolutePath() + "\\" + kifu.mmddhhmm+".txt";
    experimentGameCount = 0;
    game.editMode=false;// 盤面の編集モードOFF
    game.editBoard=null;// 盤面の編集モードOFF
    managerPhase=mP.GameStart;
  }
  else if(managerPhase == mP.GameStart){
    if (experimentGameCount == experimentGameNumber){
      managerPhase = mP.GameEnd;
    } else {
      kifu.string="";// 初期盤面以降の着手をここに記録する。
      utils.experimentMainBoard.clearCol();// 盤面のクリア
      utils.experimentMainBoard.clearMarked();// 盤面のマーキングのクリア
      // 手番のルールを初期化
      order.type=0;// random order
      order.init();
      managerPhase=mP.WaitChoosePlayer;// show setting and wait start
      experimentGameCount++;
    }
  } else if (managerPhase == mP.WaitChoosePlayer){
    game.nextPlayer = order.getNext();// 次の手番を決める //
    for (int p = 1; p<=4; p++) {
      game.participants[p].turn = false;
    }
    game.participants[game.nextPlayer].turn = true;
    // 画面に盤面を表示
    background(255);
    utils.experimentMainBoard.displayGame();
    for (int p = 1; p<=4; p++) {
      game.participants[p].displayGame();//
    }
    managerPhase = mP.OnMoving;
  } else if (managerPhase == mP.OnMoving){
    // とりま画面表示
    frameRate(10);
    background(255);
    utils.experimentMainBoard.displayGame();
    //for (int p = 1; p<=4; p++) {
    //  game.participants[p].displayGame();//
    //}
    managerPhase = mP.T1;
  } else if (managerPhase == mP.T1){
    // UCBで次の手を決める。
    println("next = "+kifu.playerColCode[game.nextPlayer]);
    game.participants[game.nextPlayer] = UCBplayer;
    game.participants[game.nextPlayer].position = game.nextPlayer;
    game.participants[game.nextPlayer].yellow = -1;
    utils.experimentMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
    ucbAttack = game.participants[game.nextPlayer].callBrain();
    ucbYellow = game.participants[game.nextPlayer].yellow;
    ucbText=kifu.playerColCode[game.nextPlayer]+nf(ucbAttack+1,2);
    if (ucbYellow!=-1){
      ucbText += "Y"+nf(ucbYellow+1,2);
    }
    utils.experimentMainBoard.buildVP(game.nextPlayer);
    if (ucbAttack<25 && utils.experimentMainBoard.vp[ucbAttack]<=0)
      println("failure"); //<>//
    managerPhase = mP.T2;
  } else if (managerPhase == mP.T2){
    // UCTで次の手を決める。
    game.participants[game.nextPlayer] = UCTplayer;
    game.participants[game.nextPlayer].position = game.nextPlayer;
    game.participants[game.nextPlayer].yellow = -1;
    utils.experimentMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
    uct1Attack = game.participants[game.nextPlayer].callBrain();
    uct1Yellow = game.participants[game.nextPlayer].yellow;
    uct1Text=kifu.playerColCode[game.nextPlayer]+nf(uct1Attack+1,2);
    if (uct1Yellow!=-1){
      uct1Text += "Y"+nf(uct1Yellow+1,2);
    }
    utils.experimentMainBoard.buildVP(game.nextPlayer);///// out of index?
    if (uct1Attack<25 && utils.experimentMainBoard.vp[uct1Attack]<=0)
      println("failure"); //<>//
    game.participants[game.nextPlayer] = new player(game.nextPlayer, "ucb0", brainType.UCB1);
    managerPhase = mP.T3;
  } else if (managerPhase == mP.T3){
    // p1-maxnで次の手を決める。
    game.participants[game.nextPlayer] = MAXNplayer;
    game.participants[game.nextPlayer].position = game.nextPlayer;
    game.participants[game.nextPlayer].yellow = -1;
    utils.experimentMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
    maxnAttack = game.participants[game.nextPlayer].callBrain();
    maxnYellow = game.participants[game.nextPlayer].yellow;
    maxnText=kifu.playerColCode[game.nextPlayer]+nf(maxnAttack+1,2);
    if (maxnYellow!=-1){
      maxnText += "Y"+nf(maxnYellow+1,2);
    }
    utils.experimentMainBoard.buildVP(game.nextPlayer);
    if (maxnAttack<25 && utils.experimentMainBoard.vp[maxnAttack]<=0)
      println("failure"); //<>//
    managerPhase = mP.T4;
  } else if (managerPhase == mP.T4){
    // p1-paranoidで次の手を決める。
    game.participants[game.nextPlayer] = PARAplayer;
    game.participants[game.nextPlayer].position = game.nextPlayer;
    game.participants[game.nextPlayer].yellow = -1;
    utils.experimentMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
    paraAttack = game.participants[game.nextPlayer].callBrain();
    paraYellow = game.participants[game.nextPlayer].yellow;
    paraText=kifu.playerColCode[game.nextPlayer]+nf(paraAttack+1,2);
    if (paraYellow!=-1){
      paraText += "Y"+nf(paraYellow+1,2);
    }
    utils.experimentMainBoard.buildVP(game.nextPlayer);
    if (paraAttack<25 && utils.experimentMainBoard.vp[paraAttack]<=0)
      println("failure"); //<>//
    managerPhase = mP.T5;
  } else if (managerPhase == mP.T5){
    // p1-hybridで次の手を決める。
    game.participants[game.nextPlayer] = HYBRplayer;
    game.participants[game.nextPlayer].position = game.nextPlayer;
    game.participants[game.nextPlayer].yellow = -1;
    utils.experimentMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
    hybrAttack = game.participants[game.nextPlayer].callBrain();
    hybrYellow = game.participants[game.nextPlayer].yellow;
    hybrText=kifu.playerColCode[game.nextPlayer]+nf(hybrAttack+1,2);
    if (hybrYellow!=-1){
      hybrText += "Y"+nf(hybrYellow+1,2);
    }
    utils.experimentMainBoard.buildVP(game.nextPlayer);
    if (hybrAttack<25 && utils.experimentMainBoard.vp[hybrAttack]<=0)
      println("failure"); //<>//
    managerPhase = mP.T6;
  } else if (managerPhase == mP.T6){
    //turnCount++;    
    println(kifu.string+","+game.nextPlayer+","+ucbText+","+uct1Text+","+maxnText+","+paraText+","+hybrText);
    text("kifu/kifu"+ kifu.mmddhhmm+"-"+nf(experimentTurnCount,2), width/2,50);
    if(!maxnText.equals(paraText)){
      background(255);
      utils.experimentMainBoard.displayGame();
      //game.participants[game.nextPlayer].displayGame();//
      experimentTurnCount++;
      println("kifu/kifu"+ kifu.mmddhhmm+"-"+nf(experimentTurnCount,2)+":"+kifu.playerColCode[game.nextPlayer]);
      textSize(utils.fontSize*2);
      text("kifu/kifu"+ kifu.mmddhhmm+"-"+nf(experimentTurnCount,2)+":"+kifu.playerColCode[game.nextPlayer], width/2, height*0.9);
      appendText(kifu.kifuFullPath, str(experimentTurnCount)+","+kifu.string+","+game.nextPlayer+","+ucbText+","+uct1Text+","+maxnText+","+paraText+","+hybrText);
      save("kifu/kifu"+ kifu.mmddhhmm+"/"+ kifu.mmddhhmm+"-"+nf(experimentTurnCount,2)+".png"); 
    }
    
    managerPhase = mP.T7;
  } else if (managerPhase == mP.T7){
    // UCBの手を実行する。
    kifu.string += ucbText;
    utils.experimentMainBoard.buildVP(game.nextPlayer);
    if (ucbAttack==25) {        // パスを選択
      managerPhase = mP.AfterMoving;
      game.participants[game.nextPlayer].noPass+=2;// 向こう２ターンはパス禁止
    } else if (utils.experimentMainBoard.vp[ucbAttack]>0){
      utils.experimentMainBoard.move(game.nextPlayer, ucbAttack);// 着手可能ならば着手する
      if (ucbYellow!=-1){
        utils.experimentMainBoard.s[ucbYellow].col = 5;
      }
      game.participants[game.nextPlayer].noPass = max(0, game.participants[game.nextPlayer].noPass-1);
    } else {
      println("failure"); //<>//
    }
    managerPhase = mP.AfterMoving;
  } else if (managerPhase == mP.AfterMoving){
    //とりま表示
    background(255);
    utils.experimentMainBoard.displayGame();
    //for (int p = 1; p<=4; p++) {
    //  game.participants[p].displayGame();//
    //}
    // ゲームが終わっていたら　mP.GameStartへ
    int remain05 = 0;
    int remain0 =0;
    for (int i=0; i<25; i++) {
      if (utils.experimentMainBoard.getCol(i)==0) {
        remain0 ++;
        remain05 ++;
      } else if (utils.experimentMainBoard.getCol(i)==5) {
        remain05 ++;
      }
    }
    if (remain05 == 0) {
      managerPhase = mP.GameEnd;
    } else if (utils.experimentMainBoard.attackChanceP==false && remain05 == 4 && remain0 == 4) {// アタックチャンス（着手後に色を消すことができる。）
      utils.experimentMainBoard.attackChanceP=true;
      managerPhase = mP.WaitChoosePlayer;
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

void appendText(String filename, String text) {
  try {
    FileWriter fw = new FileWriter(filename, true);  // true → append
    fw.write(text + "\n");
    fw.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
}
