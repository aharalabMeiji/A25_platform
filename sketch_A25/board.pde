// line 350
class board {
  panel[] s;

  int[] vp;// valid panel
  int[] op;// othello move panel
  float[] sv;// simulation value
  float[] sv2;
  int simulatorNumber;
  boolean attackChanceP;
  int svColor=0;
  board() {
    s = new panel[25];
    vp = new int[25];
    op = new int[25];
    sv = new float[26];
    sv2 = new float[26];
    for (int i = 0; i < 25; i ++) {
      s[i] = new panel(i%5, int(i/5), i+1);
      vp[i] = 0;
      op[i] = 0;
    }
    simulatorNumber=0;
    attackChanceP=false;
  }
  void displayGame(){
    textAlign(CENTER, CENTER);
    for (int i = 0; i < 25; i ++) {
      s[i].displayGame();
    }
  }
  void displaySimRandom(){
    textAlign(CENTER, CENTER);
    background(255);
    //色つけ
    setSvColor();
    for (int i = 0; i < 25; i ++) {
      s[i].sv=sv[i];
      s[i].sv2=sv2[i];
      s[i].displaySimRandom();
    }
    textSize(utils.fontSize);
    textAlign(LEFT, CENTER);
    //ヘッダA、パスの場合のデータ
    if (!attackChanceP()) {
      if (svColor==3) fill(0);
      else fill(utils.playerColor[svColor]);
      text(1.0*sv[25], utils.mainL, utils.mainU-utils.fontSize);
      text(1.0*sv2[25], utils.mainL+utils.fontSize*3.5, utils.mainU-utils.fontSize);
    }
    //ヘッダB、シミュレーション回数
    fill(0);
    textSize(utils.fontSize);
    text("("+simulatorNumber+")", utils.mainL+utils.fontSize*7, utils.mainU-utils.fontSize);
    //ヘッダC、プレイヤー色
    text("player:", utils.mainL+utils.fontSize*12, utils.mainU-utils.fontSize);
    stroke(0);
    fill(utils.playerColor[simulator.nextPlayer]);
    rect(utils.mainL+utils.fontSize*12+textWidth("player: "), utils.mainU-utils.fontSize*1.3, utils.fontSize*2, utils.fontSize*0.8);
    //ヘッダD、ファイル名（とおし番号）      
    fill(0);
    int total = simulatorStartBoard.size();
    int now = (simulator.StartBoardId) % total;
    text(utils.filename+"("+now+")", utils.mainL+utils.fontSize*18.5, utils.mainU-utils.fontSize);
    //盤右下
    String simMethod = "Monte Carlo Method";
    if (gameOptions.get("SimTimes") == 1) simMethod += "(1k)";
    else if (gameOptions.get("SimTimes") == 2) simMethod += "(10k)";
    else simMethod += "(limit)";      
    text(simMethod, utils.subL, utils.subU);
  }
  void displaySimUcb(){
    textAlign(CENTER, CENTER);
    background(255);
    //色つけ
    setSvColor();
    textAlign(CENTER, CENTER);
    for (int i = 0; i < 25; i ++) {
      s[i].sv=sv[i];
      s[i].sv2=sv2[i];
      s[i].displaySimUcb();
    }
    textAlign(LEFT, CENTER);
    //ヘッダA、パスの場合のデータ
    textSize(utils.fontSize);
    if (!attackChanceP()) {
      if (svColor==3) fill(0);
      else fill(utils.playerColor[svColor]);
      textSize(utils.fontSize);
      text(1.0*sv[25], utils.mainL, utils.mainU-utils.fontSize);
      text(1.0*sv2[25], utils.mainL+utils.fontSize*3.5, utils.mainU-utils.fontSize);
    }
    //ヘッダB、シミュレーション回数
    fill(0);
    text("("+simulatorNumber+")", utils.mainL+utils.fontSize*7, utils.mainU-utils.fontSize);
    //ヘッダC、プレイヤー色
    text("player:", utils.mainL+utils.fontSize*12, utils.mainU-utils.fontSize);
    stroke(0);
    fill(utils.playerColor[simulator.nextPlayer]);
    rect(utils.mainL+utils.fontSize*12+textWidth("player: "), utils.mainU-utils.fontSize*1.3, utils.fontSize*2, utils.fontSize*0.8);
    //ヘッダD、ファイル名（とおし番号）      
    fill(0);
    int total = simulatorStartBoard.size();
    int now = (simulator.StartBoardId) % total;
    text(utils.filename+"("+now+")", utils.mainL+utils.fontSize*18.5, utils.mainU-utils.fontSize);
    //盤左下
    String simMethod = "Monte Carlo Method(UCB) ";
    if (gameOptions.get("SimTimes") == 11) simMethod += "(10 sec)";
    else if (gameOptions.get("SimTimes") == 12) simMethod += "(60sec)";
    else simMethod += "(limit)";
    text(simMethod, utils.subL, utils.subU);
  }
  void displaySimUct() {
    textAlign(CENTER, CENTER);
    background(255);
    //Uct :色つけ
    setSvColor();
    textAlign(CENTER, CENTER);
    for (int i = 0; i < 25; i ++) {
      s[i].sv=sv[i];
      s[i].sv2=sv2[i];
      s[i].displaySimUct();
    }
    textAlign(LEFT, CENTER);
    //Uct :ヘッダA、パスの場合のデータ
    textSize(utils.fontSize);
    if (!attackChanceP()) {
      if (svColor==3) fill(0);
      else if(svColor==2) fill(0,128,0);
      else fill(utils.playerColor[svColor]);
      textSize(utils.fontSize);
      text(1.0*sv[25], utils.mainL, utils.mainU-utils.fontSize);
      text(1.0*sv2[25], utils.mainL+utils.fontSize*3.5, utils.mainU-utils.fontSize);
    }
    //Uct :ヘッダB、シミュレーション回数
    fill(0);
    text("("+simulatorNumber+")", utils.mainL+utils.fontSize*7, utils.mainU-utils.fontSize);
    //Uct :ヘッダC、プレイヤー色
    text("player:", utils.mainL+utils.fontSize*12, utils.mainU-utils.fontSize);
    stroke(0);
    fill(utils.playerColor[simulator.nextPlayer]);
    rect(utils.mainL+utils.fontSize*12+textWidth("player: "), utils.mainU-utils.fontSize*1.3, utils.fontSize*2, utils.fontSize*0.8);
    //Uct :ヘッダD、ファイル名（とおし番号）      
    fill(0);
    int total = simulatorStartBoard.size();
    int now = (simulator.StartBoardId) % total;
    text(utils.filename+"("+now+")", utils.mainL+utils.fontSize*18.5, utils.mainU-utils.fontSize);
    //Uct :ヘッダE、ぐるぐる
    switch(uct.underCalculation){
      case 0: 
      fill(#1E90FF);
      ellipse(utils.mainL+utils.fontSize*27.5, utils.mainU-utils.fontSize,utils.fontSize*0.4,utils.fontSize*0.4);
      fill(#80c0ff);
      ellipse(utils.mainL+utils.fontSize*28, utils.mainU-utils.fontSize,utils.fontSize*0.4,utils.fontSize*0.4);
      fill(#dcecfc);
      ellipse(utils.mainL+utils.fontSize*28.5, utils.mainU-utils.fontSize,utils.fontSize*0.4,utils.fontSize*0.4);
      break;
      case 1:
      fill(#1E90FF);
      ellipse(utils.mainL+utils.fontSize*28, utils.mainU-utils.fontSize,utils.fontSize*0.4,utils.fontSize*0.4);
      fill(#80c0ff);
      ellipse(utils.mainL+utils.fontSize*28.5, utils.mainU-utils.fontSize,utils.fontSize*0.4,utils.fontSize*0.4);
      fill(#dcecfc);
      ellipse(utils.mainL+utils.fontSize*27.5, utils.mainU-utils.fontSize,utils.fontSize*0.4,utils.fontSize*0.4);
      break;
      case 2: 
      fill(#1E90FF);
      ellipse(utils.mainL+utils.fontSize*28.5, utils.mainU-utils.fontSize,utils.fontSize*0.4,utils.fontSize*0.4);
      fill(#80c0ff);
      ellipse(utils.mainL+utils.fontSize*27.5, utils.mainU-utils.fontSize,utils.fontSize*0.4,utils.fontSize*0.4);
      fill(#dcecfc);
      ellipse(utils.mainL+utils.fontSize*28, utils.mainU-utils.fontSize,utils.fontSize*0.4,utils.fontSize*0.4);
      break;
      default: fill(#4CAF50);
      text("✓", utils.mainL+utils.fontSize*28, utils.mainU-utils.fontSize);// 
      break;
    }
    //Uct :盤左下
    fill(0);
    String simMethod = "Monte Carlo Tree Search(UCT) ";
    text(simMethod, utils.subL, utils.subU);
    if (gameOptions.get("SimTimes") == 21) simMethod = "E10/D4/wC";
    else if (gameOptions.get("SimTimes") == 22) simMethod = "E10/D4/woC";
    else if (gameOptions.get("SimTimes") == 23) simMethod = "E10/D5/wC";
    else if (gameOptions.get("SimTimes") == 24) simMethod = "E10/D5/woC";
    else if (gameOptions.get("SimTimes") == 26) simMethod = "E100/D4";
    else if (gameOptions.get("SimTimes") == 27) simMethod = "E100/D4";
    else if (gameOptions.get("SimTimes") == 28) simMethod = "E100/D5";
    else if (gameOptions.get("SimTimes") == 29) simMethod = "E100/D5";
    else {
      simMethod="E"+str(gameOptions.get("expandThreshold"))+"/D"+str(gameOptions.get("depthMax"));
      if (gameOptions.get("wCancel")==1) simMethod += "/wC";
      else simMethod += "/woC";
    }
    if (gameOptions.get("chanceNodeOn")==1) simMethod += "/CN";
    if(gameOptions.get("pruning")==1) simMethod += "/P1";
    if(gameOptions.get("pruning")==2) simMethod += "/P2";
    simMethod += "<";
    if(gameOptions.get("Absence0R")==1) simMethod += "R";
    if(gameOptions.get("Absence0G")==1) simMethod += "G";
    if(gameOptions.get("Absence0W")==1) simMethod += "W";
    if(gameOptions.get("Absence0B")==1) simMethod += "B";
    simMethod += "|";
    if(gameOptions.get("Absence1R")==1) simMethod += "R";
    if(gameOptions.get("Absence1G")==1) simMethod += "G";
    if(gameOptions.get("Absence1W")==1) simMethod += "W";
    if(gameOptions.get("Absence1B")==1) simMethod += "B";
    simMethod += ">";
    text(simMethod, utils.subL, utils.subU+utils.vStep);
  }
  //着手可能点のカウント
  int countVp(){
    int no=0;
    for (int k=0; k<25; k++) {
      if (vp[k]>0) {
        no ++;
      }
    }
    return no;
  }
  void setSvColor(){
    for (int i=0; i<25; i++){
      s[i].markColor = svColor;
    }
  }
  boolean buildOP(int pn) {
    boolean ret = false;
    int[]dxa = {-1, -1, -1, 0, 0, 1, 1, 1};
    int[]dya = {-1, 0, 1, -1, 1, -1, 0, 1};
    for (int i = 0; i < 25; i ++) {
      op[i] = 0;
      if (s[i].col==0 || s[i].col==5) {
        int sx = i%5, sy = int(i/5);
        // (-1,-1)
        for (int j = 0; j<8; j++) {
          int dx = dxa[j], dy = dya[j];
          int flag = 1;
          for (int k = 1; k<5; k++) {
            if (0<=sx+dx*k && sx+dx*k<5 && 0<=sy+dy*k && sy+dy*k<5) {
              int ii = (sx+dx*k) + 5*(sy+dy*k);
              if (s[ii].col==0 || s[ii].col==5) break;
              else if (s[ii].col==pn && flag==1) break;
              else if (s[ii].col!=pn && flag==1) {
                flag = 2;
              } else if (s[ii].col==pn && flag==2) {
                flag = 3;
                break;
              }
            } else {
              break;
            }
          }
          if (flag==3) {
            op[i] = 1;
            ret = true;
            break;
          }
        }
      }
    }
    return ret;
  }
  boolean buildVP(int pn) {//
    boolean ret = false;
    boolean opP = buildOP(pn);
    boolean starting = true;
    for (int i = 0; i < 25; i ++) {
      vp[i] = 0;
      if (s[i].col>0) {
        starting = false;
      }
    }
    if (opP) {// There is a panel with othello move
      for (int i = 0; i < 25; i ++) {
        if (op[i]>0) {
          vp[i] = pn;
          ret = true;
        }
      }
      return ret;
    } else {// There isn't a panel with othello move
      for (int i = 0; i < 25; i ++) {
        if (s[i].col==0 || s[i].col==5) {// This is a vacant
          copyBoardToSub(utils.gameSubBoard);
          utils.gameSubBoard.s[i].col = pn;
          boolean subOpP = utils.gameSubBoard.buildOP(pn);
          if (subOpP) {// If the move i occurs a new othello move
            vp[i] = pn;
            ret = true;
          }
        }
      }
      if (ret) {
        return ret;
      } else {// If the move i doesn't occur a new othello move
        for (int i = 0; i < 25; i ++) {
          if (s[i].col==0 || s[i].col==5) {// This is a vacant
            int[]dxa = {-1, -1, -1, 0, 0, 1, 1, 1};
            int[]dya = {-1, 0, 1, -1, 1, -1, 0, 1};
            int sx = i%5, sy = int(i/5);
            for (int j = 0; j<8; j++) {
              int dx = dxa[j], dy = dya[j];
              if (0<=sx+dx && sx+dx<5 && 0<=sy+dy && sy+dy<5) {
                int ii = (sx+dx) + 5*(sy+dy);
                if (s[ii].col!=0 && s[ii].col!=5) {
                  vp[i] = pn;
                  ret = true;
                }
              }
            }
          }
        }
      }
    }
    if (/* ret==false && */starting) {// the start board
      vp[12]=1;
    }
    return ret;
  }
  boolean copyBoardToSub(board sub) {// 'sub' must be already assigned
    for (int i=0; i<25; i++) {
      sub.s[i].col = s[i].col;
    }
    return true;
  }
  boolean copyBoardToBd(int[] sub) {// 'sub' must be already assigned as length 25
    for (int i=0; i<25; i++) {
      sub[i] = s[i].col;
    }
    return true;
  }
  boolean copyBdToBoard(int[] sub) {// 'sub' must be already assigned as length 25
    for (int i=0; i<25; i++) {
      s[i].col = sub[i];
    }
    return true;
  }
  void clearSv() {
    for (int i=0; i<25; i++) {
      sv[i]=sv2[i]=0;
    }
  }
  boolean move(int pn, int attack) {// including othello moves
    s[attack].col = pn;
    int[]dxa = {-1, -1, -1, 0, 0, 1, 1, 1};
    int[]dya = {-1, 0, 1, -1, 1, -1, 0, 1};
    int sx = attack%5, sy = int(attack/5);
    for (int j = 0; j<8; j++) {
      int dx = dxa[j], dy = dya[j];
      int flag = 1;
      int floagK=0;
      for (int k = 1; k < 5; k++) {
        int tx = sx+dx*k, ty = sy+dy*k;
        if (0<=tx && tx<5 && 0<=ty && ty<5) {
          int ii = tx + 5*ty;
          if (s[ii].col==0 || s[ii].col==5) break;
          else if (s[ii].col==pn && flag==1) break;
          else if (s[ii].col!=pn && flag==1) {
            flag = 2;
          } else if (s[ii].col==pn && flag==2) {
            flag = 3;
            floagK = k;
            break;
          }
        }
      }
      if (flag == 3) {
        for (int k = 1; k < floagK; k++) {
          int tx = sx+dx*k, ty = sy+dy*k;
          if (0<=tx && tx<5 && 0<=ty && ty<5) {
            int ii = tx + 5*ty;
            s[ii].col = pn;
          }
        }
      }
    }
    return true;
  }
  boolean attackChanceP() {
    int count0=0, count5=0;
    for (int i=0; i<25; i++) {
      if (s[i].col==0) 
        count0 ++;
      else if (s[i].col==5)
        count5 ++;
    }
    if (count0==5 && count5==0) {
      return true;
    }
    return false;
  }
  boolean afterAttackChanceP() {
    int count=0;
    for (int i=0; i<25; i++) {
      if (s[i].col==0) count ++;
    }
    if (count<=4) {
      return true;
    }
    return false;
  }
  void printLn() {
    for (int i=0; i<25; i++) {
      print(s[i].col);
      if (i%5==4) print("|");
      else print(" ");
    }
    println();
    for (int i=0; i<25; i++) {
      print(vp[i]);
      if (i%5==4) print("|");
      else print(" ");
    }
    println();
  }
  int getCol(int k) {
    if (0<=k && k<25)
      return s[k].col;
    return -1;
  }
  void setCol(int k, int c) {
    if (0<=k && k<25) {
      if (0<=c && c<=5) {
        s[k].col = c;
        return ;
      }
    }
    println("Error. board.setCol("+k+","+c+")");
  }
  void clearCol() {
    for (int k=0; k<25; k++) {
      s[k].col=0;
    }
  }
  void clearMarked() {
    for (int k=0; k<25; k++) {
      s[k].marked=0;
    }
  }
  boolean symmetryLR(){
    for(int j=0; j<5; j++){
      for (int i=0; i<2; i++){
        int k= 5*j + i;
        int kk = 5*j + (4-i);
        if (s[k].col != s[kk].col)
          return false;
      }
    }
    return true;    
  }
  boolean symmetryTB(){
    for(int j=0; j<2; j++){
      for (int i=0; i<5; i++){
        int k= 5*j + i;
        int kk = 5*(4-j) + i;
        if (s[k].col != s[kk].col)
          return false;
      }
    }
    return true;    
  }
  boolean symmetryDiagonal(){
    for(int j=0; j<5; j++){
      for (int i=0; i<5; i++){
        if (i<j){
          int k= 5*j + i;
          int kk = 5*i + j;
          if (s[k].col != s[kk].col)
            return false;
        }
      }
    }
    return true;    
  }
  boolean symmetryAntiDiagonal(){
    for(int j=0; j<5; j++){
      for (int i=0; i<5; i++){
        if (i+j<4){
          int k= 5*j + i;
          int kk = 5*(4-i) + (4-j); 
          if (s[k].col != s[kk].col)
            return false;
        }
      }
    }
    return true;    
  }
  void deleteSymmetricVp(){
    if (this.symmetryLR()){
      for(int j=0; j<5; j++){
        for (int i=3; i<5; i++){
          int k= 5*j + i;
          vp[k]=0;
        }
      }
    } else 
    if (this.symmetryTB()){
      for(int j=3; j<5; j++){
        for (int i=0; i<5; i++){
          int k= 5*j + i;
          vp[k]=0;
        }
      }
    } else 
    if (this.symmetryDiagonal()){
      for(int j=0; j<5; j++){
        for (int i=0; i<5; i++){
          if (i<j){
            int k= 5*j + i;
            vp[k]=0;
          }
        }
      }
    }  else 
    if (this.symmetryAntiDiagonal()){
      for(int j=0; j<5; j++){
        for (int i=0; i<5; i++){
          if (i+j>4){
            int k= 5*j + i;
            vp[k]=0;
          }
        }
      }
    }     
  }
}; // end of class board

int remaingInBd(int[] bd){
  int len = min(bd.length,25);
  int count=0;
  for(int k=0; k<len; k++){
    if(bd[k]==0 || bd[k]==5){
      count++;
    }
  }
  return count;
}

class panel {
  int col = 0;
  int x = 0, y = 0;
  int n = 0;
  int marked = 0;
  int shaded = 0;
  float  sv =0.0;
  float sv2 =0.0;
  int dx=0, dy=0;
  int markColor = 0;
  panel(int _x, int _y, int _n) {
    x = _x;
    y = _y;
    n = _n;
  }
  void drawBackground(){
    dx = utils.mainL + utils.mainW * x;
    dy = utils.mainU + utils.mainH * y;
    fill(utils.playerColor[col]);//
    stroke(0);
    rect(dx, dy, utils.mainW, utils.mainH);
    if ( col==5 ){
      float offset = utils.mainH*0.1;
      fill(utils.playerColor[0]);
      rect(dx+offset, dy+offset, utils.mainW-2*offset, utils.mainH-2*offset);        
    }
  }
  void drawLargeNumber(){
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(utils.fontSize*2);
    text(n, dx+utils.mainW/2, dy+utils.mainH/2-5);
  }
  void markData(){
    textAlign(CENTER, CENTER);
    textSize(utils.fontSize*0.7);
    if (markColor==0 || markColor==3){
    fill(255);stroke(255);
    } else {
      fill(235);stroke(255);
    }
    float wid = textWidth("0000000");
    float hei = utils.fontSize*1.3;
    rect(dx+utils.mainW/2-wid*0.5, dy+utils.mainH/2+utils.fontSize*1.2-hei*0.5, wid, hei);
    if (markColor==0 || markColor==3){
      fill(0);
    } else if (markColor==2){
      fill(0,128,0);
    } else {
      fill(utils.playerColor[markColor]);
    }
    text(sv, dx+utils.mainW/2, dy+utils.mainH/2+utils.fontSize*0.9);
    text(sv2, dx+utils.mainW/2, dy+utils.mainH/2+utils.fontSize*1.5);
  }
  void displayGame(){
    drawBackground();
    drawLargeNumber();
    if (marked>0) {
      fill(utils.playerColor[marked]);
      textSize(utils.fontSize*3);
      text("o", dx+utils.mainW/2, dy+utils.mainH/2);
    }
  }
  void displaySimRandom(){
    drawBackground();
    if (marked>0) markData();
    drawLargeNumber();
  }
  void displaySimUcb(){
    drawBackground();
    if (marked>0) markData();
    drawLargeNumber();
  }
  void displaySimUct() {
    drawBackground();
    if (marked>0) markData();
    drawLargeNumber();
    if (shaded>0) {
      fill(utils.playerShade[shaded]);
      rect(dx+10, dy+10, utils.mainW-20, utils.mainH-20);
    }
  }
};
