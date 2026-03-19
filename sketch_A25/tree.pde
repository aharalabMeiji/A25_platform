button buttonTreePrev, buttonTreeNext;

void showTree() {
  if (tree.treeNode12.thisNode==null) {
    background(255);
    buttonTreePrev = new button();
    buttonTreeNext = new button();
    int noLegalMoves = uct.rootNode.legalMoves.size();
    prize prize=new prize();
    prize.getPrize3FromNodeList(simulator.nextPlayer, uct.rootNode.legalMoves);
    int prev=0, now=0, next=0;
    for (int m=0; m<noLegalMoves; m++) {
      if (uct.rootNode.legalMoves.get(m)==prize.m1) {
        now = m;
        prev = (m+noLegalMoves-1)%noLegalMoves;
        next = (m+1)%noLegalMoves;
        break;
      }
    }
    tree.treeNode11.setNode(uct.rootNode.legalMoves.get(prev));
    tree.treeNode12.setNode(uct.rootNode.legalMoves.get(now));
    tree.treeNode13.setNode(uct.rootNode.legalMoves.get(next));
  } else {
    tree.treeNode11.showTreeNode(utils.unitSize*0.05, utils.mainU+utils.unitSize*0.06, utils.unitSize*0.25);
    tree.treeNode12.showTreeNode(utils.unitSize*0.35, utils.mainU, utils.unitSize*0.3);
    tree.treeNode13.showTreeNode(utils.unitSize*0.70, utils.mainU+utils.unitSize*0.06, utils.unitSize*0.25);
  }
}


class treeNode {
  uctNode thisNode=null;
  void setNode(uctNode nd) {
    thisNode = nd;
  }
  void showTreeNode(float x, float y, float wid) {
    stroke(0);
    noFill();
    rect(x, y, wid, wid*1.1, 10);
    startBoard tmpBoard=new startBoard(thisNode.bd, thisNode.player);
    float dx = wid/12.0;
    float dy = dx*0.8;
    tmpBoard.display(1, int(x+dx), int(y+dy), int(2*dx), int(2*dy));
    fill(0);
    //textSize(utils.fontSize);
    String msg = thisNode.id+"("+(thisNode.wa[thisNode.player]/thisNode.na)+")";
    text(msg, int(x+dx), int(y+dy*12));
    return;
  }
};

gameTree tree=new gameTree();
class gameTree {
  treeNode treeNode11;
  treeNode treeNode12;
  treeNode treeNode13;
  treeNode treeNode21;
  treeNode treeNode22;
  treeNode treeNode23;
  gameTree() {
    treeNode11=new treeNode();
    treeNode12=new treeNode();
    treeNode13=new treeNode();
    treeNode21=new treeNode();
    treeNode22=new treeNode();
    treeNode23=new treeNode();
  }
  void init() {
    if (uct !=null && uct.rootNode!=null) {
      treeNode12.thisNode = uct.rootNode;
    }
  }
};
