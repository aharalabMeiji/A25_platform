enum brain{
  Human, Random, UCBold, UCB1, UCB2, UCTE10D4, UCBUCT
}

class player {
  int position;// 1~4
  String name;
  brain myBrain;// 
  boolean turn;
  board myBoard;
  float score;
  int yellow=-1;
  int noPass=0;
  player(int _p, String _n, brain _b) {
    position = _p;
    name = _n;
    myBrain = _b;
    turn = false;
    myBoard= new board();
  }
  boolean display(int mode) {
    if (mode==0) {
      int dx = utils.subL+int(utils.mainW+utils.hSpace)*(position-1);
      int dy = utils.subU;
      if (turn)
        strokeWeight(10);
      else
      strokeWeight(2);
      fill(utils.playerColor[position]);
      rect(dx, dy, utils.mainW, utils.mainH);
      strokeWeight(1);
      fill(0);
      textSize(utils.fontSize*0.6);      
      textAlign(CENTER, CENTER);
      text(name, dx+utils.mainW/2, dy+utils.mainH/4);
      int count=0;
      for (int i=0; i<25; i++){
        if (utils.gameMainBoard.s[i].col==position){
          count ++;
        }
      }
      text(count, dx+utils.mainW/2,dy+utils.mainH/2);
      text(score, dx+utils.mainW/2,dy+utils.mainH*3/4);
    }
    return true;
  }
  boolean mouseOn(int mode){
    if (mode==0){
      int dx = utils.subL+int(utils.mainW+utils.hSpace)*(position-1);
      int dy = utils.subU;
      if (dx<mouseX && mouseX<dx+utils.mainW){
        if(dy<mouseY && mouseY<dy+utils.mainH){
          return true;
        }
      }
    }
    return false;
  }
  int callBrain(){
    if (myBrain==brain.Random){
      myBoard.buildVP(position);
      if (myBoard.attackChanceP()){
        yellow=-1;//黄色にするパネルをこの変数に入れておけば、あとでそのように処理をする。
        return chooseOne(myBoard.vp);
      } else {
        return chooseOne(myBoard.vp);
      }
    } else if (myBrain==brain.UCBold){
      return ucbMcBrain(this);
    } else if (myBrain==brain.UCB1){
      return ucbFastBrain(this, ucb1);
    } else if (myBrain==brain.UCB2){
      return ucbFastBrain(this, ucb2);
    } else if (myBrain==brain.UCTE10D4){
      uct.expandThreshold=10;
      uct.terminateThreshold = uct.expandThreshold*1000000;
      uct.depthMax=4;
      uct.cancelCountMax=10;
      return uctMctsBrain(this);//250618 現在の一つの解
    } else if (myBrain==brain.UCBUCT){
      return uctMctsABrain(this, 1000, 1000000, 4);
    }
    return -1; // error or gameEnd
  }
  int callAttackChance(){// すでにある色を黄色へ変更するアルゴリズム
    if (yellow!=-1) return yellow;// 黄色にするパネルをすでに決定済みであれば、それを回答する。
    if (myBrain==brain.Random || myBrain==brain.UCB1 || myBrain==brain.UCTE10D4 || myBrain==brain.UCBUCT ){
      int[] ac = new int[25];
      for (int i=0; i<25; i++){
        if (1<=myBoard.s[i].col && myBoard.s[i].col<=4){
          ac[i]=1;
        }
        else {
          ac[i]=0;
        }
      }
      return chooseOne(ac);
    }
    return -1; // 
  }
  int chooseOne(int[] candidates){// candidates must be a sequence of length 25
    // each elements of candidate must be a non-negative integer
    int sum = 0;
    for (int i=0; i<25; i++){
      sum += candidates[i];
    }
    if (sum==0){
      return -1;
    }
    int roulette = int(random(sum))+1;
    for (int i=0; i<25; i++){
      roulette -= candidates[i];
      if (roulette <=0){
        return i;
      }
    }
    return -1;// error    
  }
};
