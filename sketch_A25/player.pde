enum brain{
  Human, Random, UCT1, UCT2
}

class player {
  int position;// 1~4
  String name;
  brain myBrain;// 
  boolean turn;
  board myBoard;
  float score;
  int yellow=-1;
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
        // 本当は、置く場所と、をセットで回答させたい。
        yellow=-1;//消す場所をここに入れておけば、あとでそのように処理をする。
        return chooseOne(myBoard.vp);
      } else {
        return chooseOne(myBoard.vp);
      }
    } else if (myBrain==brain.UCT1){
      return uctMcBrain(this);
    }
    return -1; // error    
  }
  int callAttackChance(){// すでにある色を黄色へ変更するアルゴリズム
    if (yellow!=-1) return yellow;// すでに決定済みであれば、それを回答する。
    if (myBrain==brain.Random || myBrain==brain.UCT1){
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
