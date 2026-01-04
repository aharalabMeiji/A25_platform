//uctNodeは使うよ
multiUcbClass multiUcb = new multiUcbClass();
class multiUcbClass {
  player thisPlayer=null;
  int playerPosition=0;
  int answerMove=0;  
  int noValidMoves=0;
  player[] thisParticipants=null;
  winPoints thisWinPoint;
  prize thisPrize;
  board mainBoard, subBoard;
  boolean isAttackChance=false;
  int[] tmpBoard = null;
  uctNode rootNode = null;
  uctNode newNode = null;
  multiUcbClass(){
    tmpBoard = new int[25]; 
  }
  int multiUcbBrain(player pl) { //
    //ここから
    startTime=millis();
    thisPlayer = pl;// 複製をつくるかどうかは要議論
    playerPosition = pl.position;
    //if ((answerMove = joseki(pl))==-1) return -1;// 定跡リストを使うならここをコメアウト
    if ((answerMove = preparation())==-1) return -1;
    if ((answerMove = firstPlayout(pl))==-1) return -1; 
    println("multiUcb ");//print main parameters 
    while (true) {
      if ((answerMove = mainLoop(pl))!=-1) return answerMove;
    }// end of while(true)
  }
  
  int preparation(){
    // 初期パラメータの設定
    initializeParameters();
    // 着手可能点をリストアップ
    makeLegalMovesList();
    // ゲーム終了場面であればここで終了
    if (isEndGame()) return -1;
    // 選択肢が１つであればここで終了
    if (isOneMoveBoard()) return 0;
    // ルートノードの作成
    buildRootNode();
    // アタックチャンスかどうかを判定する
    isAttackChance=isAttackChance();    
    if (isAttackChance){
      // 着手可能点のノードを作ってルートノードにぶら下げる１(AC)
      buildLegalMoveNodesAC();
      // パスも合法手としてルートノードにぶら下げる
      buildPassMoveNode();
    } else {
      // 着手可能点のノードを作ってルートノードにぶら下げる２(非AC)
      buildLegalMoveNodesNonAC();
    }
    // ここで設定すべきパラメータを調整する
    addInitilization();
    // 返すべき値を返す
    return returnOptimizedMove();
  }
  
  
  int firstPlayout(player pl){
    return -1;
  }
  
  int mainLoop(player pl){
    return -1;
  }

  void initializeParameters(){
    thisParticipants = new player[5];
    for (int p=1; p<5; p++) {
      thisParticipants[p] = new player(p, "random", brainType.Random);
    }
    for (int k=0; k<=25; k++) {//たぶん不要
      thisPlayer.myBoard.sv[k]=0;
      thisPlayer.myBoard.sv2[k]=0;
    }//たぶん不要
    thisPlayer.yellow=-1;//たぶん不要
    thisPlayer.myBoard.simulatorNumber=0;
    thisWinPoint=null;
    thisPrize=new prize();
    mainBoard = new board();
    subBoard = new board();
    newNode = null;
  }
  void makeLegalMovesList(){   
    assert thisPlayer!=null;
    thisPlayer.myBoard.buildVP(playerPosition);
    noValidMoves=0;
    for (int k=0; k<25; k++) {
      if (thisPlayer.myBoard.vp[k]>0) {
        noValidMoves ++;
      }
    }
  }
  boolean isEndGame(){
    if (noValidMoves==0) return true;
    return false;
  }
  boolean isOneMoveBoard(){
    if (noValidMoves==1) return true;
    return false;
  }
  void buildRootNode(){
    rootNode = new uctNode();
    rootNode.parent = null;
    rootNode.legalMoves = new ArrayList<uctNode>();
    //rootNode.cancelCount=0;
    thisPlayer.myBoard.copyBoardToBd(rootNode.bd);

  }
  boolean isAttackChance(){
    return false;
  }
  void buildLegalMoveNodesNonAC(){
    for (int k=0; k<25; k++) {
      if (thisPlayer.myBoard.vp[k]>0) {
        newNode = new uctNode();
        newNode.setItem(playerPosition, k);
        newNode.id = rootNode.id + (":"+kifu.playerColCode[playerPosition]+nf(k+1, 2));
        newNode.depth = 1;
        rootNode.legalMoves.add(uct.newNode);//ルートノードにぶら下げる
        newNode.ancestor = uct.newNode;// 自分自身が先祖
        newNode.parent = null;//逆伝播をここで切りたいので
        newNode.onRGWB = new boolean[5];
        for(int p=1; p<5; p++){//4つのチャンスノードは有効
          uct.newNode.onRGWB[p]=true;
        }
        thisPlayer.myBoard.copyBoardToSub(mainBoard);
        mainBoard.move(playerPosition, k);//一手進める
        mainBoard.copyBoardToBd(newNode.bd);
        newNode.attackChanceNode=false;
      }
    }  
  }
  void buildPassMoveNode(){
    if (thisPlayer.noPass==0) {
      newNode = new uctNode();
      newNode.setItem(playerPosition, 25);
      newNode.id = rootNode.id+(":"+kifu.playerColCode[playerPosition]+nf(26, 2));
      newNode.depth = 1;
      rootNode.legalMoves.add(newNode);//ルートノードにぶら下げる
      newNode.ancestor = newNode;
      newNode.parent = null;//
      newNode.onRGWB = new boolean[5];
      for(int p=1; p<5; p++){//ノードをつるさない場合はフラグを倒しておく
        if (uct.isPassAtDepth1Node(newNode, p)) newNode.onRGWB[p]=false;
        else newNode.onRGWB[p]=true;
      } 
      thisPlayer.myBoard.copyBoardToSub(mainBoard);
      mainBoard.copyBoardToBd(newNode.bd);
      newNode.attackChanceNode=false;//念のため倒しておく。
    }
  }
  void buildLegalMoveNodesAC(){
  }
  void addInitilization(){
  }
  int returnOptimizedMove(){
    return -1;
  }
  
};
