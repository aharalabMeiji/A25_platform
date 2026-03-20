button buttonTree11, buttonTree12, buttonTree13;
button buttonTree21, buttonTree22, buttonTree23;
button buttonTreeColor;


class treeNode {
  uctNode thisNode=null;
  void setNode(uctNode nd) {
    thisNode = nd;
  }
  void showTreeNode(float x, float y, float wid) {
    if (thisNode==null) return;
    stroke(0);
    noFill();
    rect(x, y, wid, wid*1.1, 10);
    startBoard tmpBoard=new startBoard(thisNode.bd, thisNode.player);
    float dx = wid/12.0;
    float dy = dx*0.8;
    tmpBoard.display(1, int(x+dx), int(y+dy), int(2*dx), int(2*dy));
    fill(0);
    //textSize(utils.fontSize);
    String msg = thisNode.id+"("+nf(thisNode.wa[thisNode.player]/thisNode.na,1,3)+")";
    text(msg, int(x+dx), int(y+dy*12));
  }
};

gameTree tree=new gameTree();
class gameTree {
  treeNode treeNode11;
  treeNode treeNode12;// main 
  treeNode treeNode13;
  treeNode treeNode21;
  treeNode treeNode22;
  treeNode treeNode23;
  ArrayList<uctNode> NL1=null;
  ArrayList<uctNode> NL2=null;
  ArrayList<uctNode> NL3=null;
  int color1=0, color2=0, color3=0;
  int NL1id=0, NL2id=0, NL3id=0;
  gameTree() {
    treeNode11=new treeNode();
    treeNode12=new treeNode();
    treeNode13=new treeNode();
    treeNode21=new treeNode();
    treeNode22=new treeNode();
    treeNode23=new treeNode();
  }
  void initialize() {
    NL1=uct.rootNode.legalMoves;
    prize pz=new prize();
    pz.getPrize3FromNodeList(uct.rootNode.legalMoves.get(0).player, uct.rootNode.legalMoves); //<>//
    for(NL1id=0; NL1id<uct.rootNode.legalMoves.size(); NL1id++){
      if(uct.rootNode.legalMoves.get(NL1id) == pz.m1) break;
    }
    color2=2;
    setAllPanes();
  }
  void setAllPanes(){
    if (NL1!=null && NL1.size()!=0){
      int noLM1 = NL1.size();
      int prev = (NL1id+noLM1-1)%noLM1;
      int now = NL1id%noLM1;
      int next = (NL1id+1)%noLM1;
      treeNode11.setNode(NL1.get(prev));
      treeNode12.setNode(NL1.get(now));
      treeNode13.setNode(NL1.get(next));
      if (color2==1) NL2 = NL1.get(now).childR;
      else if (color2==2) NL2 = NL1.get(now).childG;
      else if (color2==3) NL2 = NL1.get(now).childW;
      else if (color2==4) NL2 = NL1.get(now).childB;
      if (NL2!=null && NL2.size()!=0){
        int noLM2 = NL2.size();
        println("noLM2="+noLM2);
        prev = (NL2id+noLM2-1)%noLM2;
        now = NL2id%noLM2;
        next = (NL2id+1)%noLM2;
        treeNode22.setNode(NL2.get(now));
        if(noLM2>=2){
          treeNode23.setNode(NL2.get(next));
          if (noLM2>=3){
            treeNode21.setNode(NL2.get(prev));
          }
        }
      } else {
        treeNode21.setNode(null);
        treeNode22.setNode(null);
        treeNode23.setNode(null);
      }
    }
  }
  void show() {
    background(255);
    treeNode11.showTreeNode(utils.unitSize*0.05, utils.mainU+utils.unitSize*0.06, utils.unitSize*0.25);
    treeNode12.showTreeNode(utils.unitSize*0.35, utils.mainU, utils.unitSize*0.3);
    treeNode13.showTreeNode(utils.unitSize*0.70, utils.mainU+utils.unitSize*0.06, utils.unitSize*0.25);
    stroke(0);fill(utils.playerColor[color2]);
    rect(utils.unitSize*0.35,utils.mainU+utils.unitSize*0.35, utils.unitSize*0.3,utils.unitSize*0.05);
    treeNode21.showTreeNode(utils.unitSize*0.05, utils.mainU+utils.unitSize*0.425, utils.unitSize*0.2);
    treeNode22.showTreeNode(utils.unitSize*0.4, utils.mainU+utils.unitSize*0.425, utils.unitSize*0.2);
    treeNode23.showTreeNode(utils.unitSize*0.70, utils.mainU+utils.unitSize*0.425, utils.unitSize*0.2);
    //top += utils.vStep;
    //left=utils.hOffset;
    //buttonText = "[Back]";
    //buttonStart=new button();
    //buttonStart.setLT(left, top, buttonText);
    //fill(255, 0, 0);
    //text(buttonText, left, top);
    showReturnButton();
    
  }
  

};
