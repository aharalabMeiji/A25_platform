
//board uctBoard, uctSubBoard;

class uctNode {
  float na=1;// このノードの試行回数
  float[] wa;// このノードの（誰にとっての）勝利回数
  float[] pa;// このノードの（誰にとっての）累積パネル数
  int []bd;// 盤面
  //float NN=1;// 累計試行回数
  float[] uct;
  int player=0;
  int move=-1;// attack chance時には、625までの数が入る。
  ArrayList<uctNode> children=null;
  uctNode parent=null;//不要なら後でやめる

  uctNode() {
    na=1;
    wa=new float[5];
    for (int p=0; p<5; p++) wa[p]=0;
    pa=new float[5];
    for (int p=0; p<5; p++) pa[p]=0;
    bd= new int[25];
    //NN=1;
    uct=new float[5];
    for (int p=0; p<5; p++) uct[p]=0;
    children = null;
  }
  boolean setItem(int _p, int _m) {
    player=_p;
    move=_m;
    return false;
  }
  float UCTa(int player, int NN) {// NN:　累計試行回数
    float u1 = wa[player]/na;
    float u2 = 1.41421356*sqrt(log(NN)/na);
    return u1 + u2;
  }
}

int XXXBrain(player pl) {
  pl.myBoard.buildVP(pl.position);
  // ここまでで、選ばれる権利のあるパネルの重みがすべて１になっている。
  //pl.myBoard.vp に、候補を整数値（大きい値ほど選ばれる確率が大きい）で入れておく。
  //候補を一つに絞ってもよいが、いつでも同じ動作になってしまうので、複数個の候補を重みをつけておくとよい。
  if (pl.myBoard.attackChanceP()) {
    // 本当は、置く場所と、をセットで回答させたい。
    pl.yellow=-1;//消す場所をここに入れておけば、あとでそのように処理をする。
  }
  return pl.chooseOne(pl.myBoard.vp);//配列vpの重みでランダムに一つ選ぶ
}

int XXXAttackChance(player pl) {
  if (pl.yellow!=-1) return pl.yellow;// すでに決定済みであれば、それを回答する。
  int[] ac = new int[25];
  for (int i=0; i<25; i++) {
    if (1<=pl.myBoard.s[i].col && pl.myBoard.s[i].col<=4) {
      ac[i]=1;
    } else {
      ac[i]=0;
    }
  }
  // ここまでで、選ばれる権利のあるパネルの重みがすべて１になっている。
  return pl.chooseOne(ac);//配列acの重みでランダムに一つ選ぶ
}
