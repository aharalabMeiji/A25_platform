import java.io.FileWriter;

int experimentGameNumber = 3;// シミュレーションゲーム数
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
//player UCTplayer;
player MAXNplayer;
player PARAplayer;
//player HYBRplayer;

void showExperiment(){
  if(managerPhase == mP.PrepareGame){
    //int a = 1/0;
    if(utils.experimentMainBoard==null) utils.experimentMainBoard=new board();
    if (UCBplayer == null) UCBplayer = new player(1, "ucb0", brainType.UCB1);
    //if (UCTplayer == null)  UCTplayer = new player(1, "ucb0", brainType.UCTE10D4);
    if (MAXNplayer == null)  MAXNplayer = new player(1, "ucb0", brainType.ExpMaxn);
    if (PARAplayer == null)  PARAplayer = new player(1, "ucb0", brainType.ExpPara);
    //if (HYBRplayer == null)  HYBRplayer = new player(1, "ucb0", brainType.UCTD4P1Hybrid);
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
      println("failure");
    managerPhase = mP.T3;
  } else if (managerPhase == mP.T2){
    // UCTで次の手を決める。
    //game.participants[game.nextPlayer] = UCTplayer;
    //game.participants[game.nextPlayer].position = game.nextPlayer;
    //game.participants[game.nextPlayer].yellow = -1;
    //utils.experimentMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
    //uct1Attack = game.participants[game.nextPlayer].callBrain();
    //uct1Yellow = game.participants[game.nextPlayer].yellow;
    //uct1Text=kifu.playerColCode[game.nextPlayer]+nf(uct1Attack+1,2);
    //if (uct1Yellow!=-1){
    //  uct1Text += "Y"+nf(uct1Yellow+1,2);
    //}
    //utils.experimentMainBoard.buildVP(game.nextPlayer);///// out of index?
    //if (uct1Attack<25 && utils.experimentMainBoard.vp[uct1Attack]<=0)
    //  println("failure");
    ////game.participants[game.nextPlayer] = new player(game.nextPlayer, "ucb0", brainType.UCB1);//たぶんいらない
    //managerPhase = mP.T3;
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
      println("failure");
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
      println("failure");
    managerPhase = mP.T6;
  } else if (managerPhase == mP.T5){
    //p1-hybridで次の手を決める。
    //game.participants[game.nextPlayer] = HYBRplayer;
    //game.participants[game.nextPlayer].position = game.nextPlayer;
    //game.participants[game.nextPlayer].yellow = -1;
    //utils.experimentMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
    //hybrAttack = game.participants[game.nextPlayer].callBrain();
    //hybrYellow = game.participants[game.nextPlayer].yellow;
    //hybrText=kifu.playerColCode[game.nextPlayer]+nf(hybrAttack+1,2);
    //if (hybrYellow!=-1){
    //  hybrText += "Y"+nf(hybrYellow+1,2);
    //}
    //utils.experimentMainBoard.buildVP(game.nextPlayer);
    //if (hybrAttack<25 && utils.experimentMainBoard.vp[hybrAttack]<=0)
    //  println("failure");
    //managerPhase = mP.T6;
  } else if (managerPhase == mP.T6){
    //turnCount++;    
    println(kifu.string+","+game.nextPlayer+","+ucbText+","+maxnText+","+paraText);
    //println(kifu.string+","+game.nextPlayer+","+ucbText+","+uct1Text+","+maxnText+","+paraText+","+hybrText);
    text("kifu/kifu"+ kifu.mmddhhmm+"-"+nf(experimentTurnCount,2), width/2,50);
    if(!maxnText.equals(paraText) && maxnYellow==-1 && paraYellow==-1){// 着手が一致しなかったならば(アタックチャンス除外）
      int stableCheck=20;
      int[] localBoard=new int[25];
      int[] localMaxn=new int[20];
      int[] localPara=new int[20];
      for(int k=0; k<25; k++){   localBoard[k]=utils.experimentMainBoard.getCol(k); }
      println("確定するかどうかのチェック");
      for (int x=0; x<stableCheck; x++){
        println("maxn"+x);
        game.participants[game.nextPlayer] = MAXNplayer;
        game.participants[game.nextPlayer].position = game.nextPlayer;
        game.participants[game.nextPlayer].yellow = -1;
        utils.experimentMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's. //<>//
        int maxnAttack0 = game.participants[game.nextPlayer].callBrain();
        int maxnYellow0 = game.participants[game.nextPlayer].yellow;
        String maxnText0=kifu.playerColCode[game.nextPlayer]+nf(maxnAttack0+1,2);
        if (maxnYellow0!=-1){
          maxnText0 += "Y"+nf(maxnYellow0+1,2);
        }
        // 合法手であるかどうかの再チェック
        utils.experimentMainBoard.buildVP(game.nextPlayer);
        if (0<=maxnAttack0 && maxnAttack0<25 && utils.experimentMainBoard.vp[maxnAttack0]<=0){
          println("maxn合法手でない");
          localMaxn[x] = -1;
          continue;
        } else if(maxnAttack0==-1){
          println("不正終了");
        }
        //
        localMaxn[x] = maxnAttack0 ;
      }
      for (int x=0; x<stableCheck; x++){
        println("para"+x);
        game.participants[game.nextPlayer] = PARAplayer;
        game.participants[game.nextPlayer].position = game.nextPlayer;
        game.participants[game.nextPlayer].yellow = -1;
        utils.experimentMainBoard.copyBoardToSub(game.participants[game.nextPlayer].myBoard);// copy a current board to the player's.
        int paraAttack0 = game.participants[game.nextPlayer].callBrain();
        int paraYellow0 = game.participants[game.nextPlayer].yellow;
        String paraText0=kifu.playerColCode[game.nextPlayer]+nf(paraAttack0+1,2);
        if (paraYellow0!=-1){
          paraText0 += "Y"+nf(paraYellow0+1,2);
        }
        utils.experimentMainBoard.buildVP(game.nextPlayer);
        if (paraAttack0<25 && utils.experimentMainBoard.vp[paraAttack0]<=0){
          println("para合法手でない");
          localPara[x] = -1;
          continue;
        } else if(paraAttack0==-1){
          println("不正終了");
        }
        // 
        localPara[x] = paraAttack0;
      }
      println("データを残す");
      String distributionText="";
      printSymmetricDistribution(localBoard,localMaxn, localPara);
      print("Distance="+symmetricDistributionDistance(localBoard,localMaxn, localPara));
      distributionText += (symmetricDistributionDistance(localBoard,localMaxn, localPara));
      distributionText += (","+textSymmetricDistribution(localBoard,localMaxn, localPara));
      background(255);
      utils.experimentMainBoard.displayGame();
      //game.participants[game.nextPlayer].displayGame();//
      experimentTurnCount++;
      println("kifu/kifu"+ kifu.mmddhhmm+"-"+nf(experimentTurnCount,2)+":"+kifu.playerColCode[game.nextPlayer]);
      textSize(utils.fontSize*2);
      text("kifu/kifu"+ kifu.mmddhhmm+"-"+nf(experimentTurnCount,2)+":"+kifu.playerColCode[game.nextPlayer], width/2, height*0.9);
      appendText(kifu.kifuFullPath, kifu.mmddhhmm+"-"+str(experimentTurnCount)+","+str(experimentGameCount)+","+kifu.string+","+game.nextPlayer+","+ucbText+","+maxnText+","+paraText+","+distributionText);
      //appendText(kifu.kifuFullPath, kifu.mmddhhmm+"-"+str(experimentTurnCount)+","+kifu.string+","+game.nextPlayer+","+ucbText+","+uct1Text+","+maxnText+","+paraText+","+hybrText);
      //画面保存
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
      managerPhase = mP.GameStart;
      println("new game");
    } else if (utils.experimentMainBoard.attackChanceP==false && remain05 == 4 && remain0 == 4) {// アタックチャンス（着手後に色を消すことができる。）
      utils.experimentMainBoard.attackChanceP=true;
      managerPhase = mP.WaitChoosePlayer;
    } else {
      managerPhase = mP.WaitChoosePlayer;
    }
    // さもなくば　mP.WaitChoosePlayerへ
  }
}

class duplicate {
  int number;
  int maxnScore;
  int paraScore;

  duplicate(int n, int m, int p) {
    number = n;
    maxnScore = m;
    paraScore = p;
  }
}


void setDuplicates(int[] maxnMove, int[] paraMove) {
  ArrayList<duplicate> result = countDuplicates(maxnMove, paraMove);

  for (duplicate d : result) {
    println("[" + d.number + ", "
                + d.maxnScore + ", "
                + d.paraScore + "]");
  }
}


ArrayList<duplicate> countDuplicates(int[] maxnMove, int[] paraMove) {

  ArrayList<duplicate> result = new ArrayList<duplicate>();

  // すでに調べた整数を記録する
  ArrayList<Integer> checked = new ArrayList<Integer>();

  // maxnMove に現れる数を調べる
  for (int i = 0; i < maxnMove.length; i++) {
    int n = maxnMove[i];

    if (!checked.contains(n)) {
      addDuplicateIfNecessary(n, maxnMove, paraMove, result);
      checked.add(n);
    }
  }

  // paraMove にしか現れない数も調べる
  for (int i = 0; i < paraMove.length; i++) {
    int n = paraMove[i];

    if (!checked.contains(n)) {
      addDuplicateIfNecessary(n, maxnMove, paraMove, result);
      checked.add(n);
    }
  }

  return result;
}


// 1つの整数 n について出現回数を数える
void addDuplicateIfNecessary(
  int n,
  int[] maxnMove,
  int[] paraMove,
  ArrayList<duplicate> result
) {

  int maxnCount = 0;
  int paraCount = 0;

  for (int i = 0; i < maxnMove.length; i++) {
    if (maxnMove[i] == n) {
      maxnCount++;
    }
  }

  for (int i = 0; i < paraMove.length; i++) {
    if (paraMove[i] == n) {
      paraCount++;
    }
  }

  // ------------------------------------------------
  // 「重複」の判定条件。
  // 現在は40個全体で2回以上出たものだけ採用する。
  // 後で仕様を変える場合は、ここだけ変更すればよい。
  // ------------------------------------------------
  //if (maxnCount + paraCount >= 2) {
    result.add(new duplicate(n, maxnCount, paraCount));
  //}
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

int expSimCount=0;
String expSimFileName="sB07-0907.csv";
File expSimFile;

void showExpSim(){// 100 times simulation
  //盤面と手番は与えられている
  // 盤面：
  // 手番：
  // セッティングは変更可能だが、いちおうE100D4P1を100回想定している。
  // csvへ出力：E100D4P1_20260907.csvのような感じ
  // 横方向は、着手可能場所ごとに、RGWBの推定勝率を書く感じ。
  // たとえば、id, R10_R, R10_G, R10_W,　R10_B, R15_R, R15_G, R15_W,　R15_B, ... のような感じ。
  UCT1(); //<>//
  // 結果を吸い取れるか。
  if (simulationManager==sP.GameEnd){
    println("once end");
    int legalMovesN=uct.rootNode.legalMoves.size();
    try {
      FileWriter writer = new FileWriter(expSimFileName, true);
      String lineData=""; 
      for (int xi=0; xi<legalMovesN; xi++){
        uctNode nd = uct.rootNode.legalMoves.get(xi);
        lineData += (nd.id+","+nd.wa[1]+","+nd.wa[2]+","+nd.wa[3]+","+nd.wa[4]+","+nd.na);
        if(xi<legalMovesN-1) lineData += ",";
      }
      writer.write(lineData + "\n");
      writer.close();
    }
    catch (IOException e) {
      println("error"+e.getMessage());
    }

    expSimCount++;
    if (expSimCount==100)
      simulationManager = sP.gameHalt;
    else 
      simulationManager = sP.GameStart;
  }
}
