class uctNode {
  float na=1;// このノードの試行回数
  float[] wa;// このノードの（誰にとっての）勝利回数
  float[] pa;// このノードの（誰にとっての）累積パネル数
  int []bd;// 盤面// ここをboard 型にするかどうか。
  //float NN=1;// 累計試行回数
  float[] uct;
  int player=0;
  int move=-1;// attack chance時には、625までの数が入る。
  ArrayList<uctNode> children=null;
  String id;
  int depth;
  uctNode parent=null;//必要
  boolean attackChanceNode=false;
  ArrayList<uctNode> activeNodes=null;// アクティブな子ノード
  uctNode ancestor = null;// 第1世代の子ノード
  Thread myThread = null;
  boolean thisIsChanceNode = false;// チャンスノードではない／である
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
    id="";
    depth=0;
    attackChanceNode=false;
    
  }
  boolean setItem(int _p, int _m) {
    player=_p;
    move=_m;
    return false;
  }
  float UCTa(int player, int NN) {// NN:　累計試行回数
    float u1 = wa[player]/na;
    //float u2 = 1.0*sqrt(log(NN)/na);
    float u2 = 1.41421356*sqrt(log(NN)/na);
    //float u2 = 2.0*sqrt(log(NN)/na);
    return u1 + u2;
  }
  float UCTwp(int player, int NN) {// NN:　累計試行回数
    float u1 = (wa[player]+pa[player]*0.04)/2/na;
    float u2 = 1.41421356*sqrt(log(NN)/na);
    return u1 + u2;
  }
  float UCTb(int player, int NN) {// for MCTS
    float u1=0;
    for (int p=1; p>5; p++) {
      if (p==player) {
        u1 += wa[player];
      } else {
        u1 -= wa[p];
      }
      u1 /= na;
    }
    float u2 = 1.41421356*sqrt(log(NN)/na);
    return u1 + u2;
  }
  boolean attackChanceP(){
    int count=0;
    for (int i=0; i<25; i++) {
      if (bd[i]==0) count ++;
    }
    if (count==5) {
      return true;
    }
    return false;
  }

  void printlnBd(){
    print("ボード：");
    for (int kki=0; kki<5; kki++) {
      for (int kkj=0; kkj<5; kkj++) {
        print(" "+bd[kkj+kki*5]);
      }
      print(":");
    }
    println();   
  }
}

class chanceNode extends uctNode{
  // uctNodeに、一旦4つのchaceNodeをぶら下げる。（赤緑白青それぞれに対応させる。）
  // chaceNodeの下に対応させたプレイヤーの着手をぶら下げる。
  // バックプロパゲートの時、４つのchanceNodeの分母をそろえる作業を行う。
  // 分母はそのままで親ノードの成績を調整する、のほうが筋がよいか？
  // ４つのchanceNodeの「赤の」winrateがr_i/n_i (i=1,2,3,4)とかだったりしたとき、
  // n_parent = n_1+n_2+n_3+n_4
  // r_parent = (0.25*r_1/n_1+0.25*r_2/n_2+0.25*r_3/n_3+0.25*r_4/n_4)*n_parent
  // 現状ではここを(r_1+r_2+r_3+r_4)/n_parentで扱っていた。
  // ここを選べるようにしておくのが良いかと。
  
}

uctNode getMaxUcbFromNodeList(int player, ArrayList<uctNode> nds, int NN) {
  float best = 0;
  uctNode bestNd=null;
  for (uctNode nd : nds) {
    float tmpUcb = nd.UCTwp(player, NN);
    if (best < tmpUcb) {
      best = tmpUcb;
      bestNd=nd;
    }
  }
  return bestNd;
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
