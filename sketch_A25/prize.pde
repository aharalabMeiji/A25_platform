class prize {
  float w1, w2, w3, w4, w5;
  float p1, p2, p3, p4, p5;
  uctNode m1, m2, m3, m4, m5;
  prize() {
  }
  float getWinrate(int i) {
    switch(i) {
    case 1:
      return w1;
    case 2:
      return w2;
    case 3:
      return w3;
    case 4:
      return w4;
    case 5:
      return w5;
    default:
      return 0;
    }
  }
  float getPanels(int i) {
    switch(i) {
    case 1:
      return p1;
    case 2:
      return p2;
    case 3:
      return p3;
    case 4:
      return p4;
    case 5:
      return p5;
    default:
      return 0;
    }
  }
  uctNode getMove(int i) {
    switch(i) {
    case 1:
      return m1;
    case 2:
      return m2;
    case 3:
      return m3;
    case 4:
      return m4;
    case 5:
      return m5;
    default:
      return null;
    }
  }
  boolean Compare(int i, float winrate, float panels){
    switch(i) {
    case 1:
      return w1<winrate || (w1==winrate && p1<panels);
    case 2:
      return w2<winrate || (w2==winrate && p2<panels);
    case 3:
      return w3<winrate || (w3==winrate && p3<panels);
    case 4:
      return w4<winrate || (w4==winrate && p4<panels);
    case 5:
      return w5<winrate || (w5==winrate && p5<panels);
    default:
      return false;
    }
  }

  void getPrize5FromNodeList(int player, ArrayList<uctNode> nds){
    w1=w2=w3=w4=w5=0;
    p1=p2=p3=p4=p5=0;
    m1=m2=m3=m4=m5=null;
    for (uctNode nd : nds) {
      float tmpWinrate = nd.wa[player] / nd.na;
      float tmpPanels = nd.pa[player] / nd.na;
      if (Compare(1, tmpWinrate, tmpPanels)){
        w5=w4;p5=p4;m5=m4;
        w4=w3;p4=p3;m4=m3;
        w3=w2;p3=p2;m3=m2;
        w2=w1;p2=p1;m2=m1;
        w1=tmpWinrate;
        p1=tmpPanels;
        m1=nd;
      } else 
      if (Compare(2, tmpWinrate, tmpPanels)){
        w5=w4;p5=p4;m5=m4;
        w4=w3;p4=p3;m4=m3;
        w3=w2;p3=p2;m3=m2;
        w2=tmpWinrate;
        p2=tmpPanels;
        m2=nd;
      } else 
      if (Compare(3, tmpWinrate, tmpPanels)){
        w5=w4;p5=p4;m5=m4;
        w4=w3;p4=p3;m4=m3;        
        w3=tmpWinrate;
        p3=tmpPanels;
        m3=nd;
      } else 
      if (Compare(4, tmpWinrate, tmpPanels)){
        w5=w4;p5=p4;m5=m4;
        w4=tmpWinrate;
        p4=tmpPanels;
        m4=nd;
      } else 
      if (Compare(5, tmpWinrate, tmpPanels)){
        w5=tmpWinrate;
        p5=tmpPanels;
        m5=nd;
      }
    }
  }
  void getPrize3FromNodeList(int player, ArrayList<uctNode> nds){
    w1=w2=w3=w4=w5=0;
    p1=p2=p3=p4=p5=0;
    m1=m2=m3=m4=m5=null;
    for (uctNode nd : nds) {
      float tmpWinrate = nd.wa[player] / nd.na;
      float tmpPanels = nd.pa[player] / nd.na;
      if (Compare(1, tmpWinrate, tmpPanels)){
        w3=w2;p3=p2;m3=m2;
        w2=w1;p2=p1;m2=m1;
        w1=tmpWinrate;
        p1=tmpPanels;
        m1=nd;
      } else 
      if (Compare(2, tmpWinrate, tmpPanels)){
        w3=w2;p3=p2;m3=m2;
        w2=tmpWinrate;
        p2=tmpPanels;
        m2=nd;
      } else 
      if (Compare(3, tmpWinrate, tmpPanels)){
        w3=tmpWinrate;
        p3=tmpPanels;
        m3=nd;
      }
    }
  }
  void getPrize1FromNodeList(int player, ArrayList<uctNode> nds){
    w1=w2=w3=w4=w5=0;
    p1=p2=p3=p4=p5=0;
    m1=m2=m3=m4=m5=null;
    for (uctNode nd : nds) {
      float tmpWinrate = nd.wa[player] / nd.na;
      float tmpPanels = nd.pa[player] / nd.na;
      if (Compare(1, tmpWinrate, tmpPanels)){
        w1=tmpWinrate;
        p1=tmpPanels;
        m1=nd;
      }
    }
  }
  int getLength(){
    if (m1==null){
      return 0;
    } else 
    if (m1==null){
      return 1;
    } else 
    if (m2==null){
      return 2;
    } else 
    if (m3==null){
      return 3;
    } else 
    if (m4==null){
      return 4;
    } else {
      return 5;
    }
  }
}

  
