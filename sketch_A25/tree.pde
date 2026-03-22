button buttonTree11, buttonTree12, buttonTree13;
button buttonTree21, buttonTree22, buttonTree23;
button buttonTreeColor, buttonTreeDown, buttonTreeUp;

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
    String msg = thisNode.id+"\n("+nf(thisNode.wa[thisNode.player]/thisNode.na,1,3)+")";
    text(msg, int(x+dx), int(y+dy*11));
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
  int now1,prev1,next1;
  int now2,prev2,next2;
  gameTree() {
    treeNode11=new treeNode();
    treeNode12=new treeNode();
    treeNode13=new treeNode();
    treeNode21=new treeNode();
    treeNode22=new treeNode();
    treeNode23=new treeNode();
    
  }
  void initialize() {
    buttonTree11=new button();
    buttonTree12=new button();
    buttonTree13=new button();
    buttonTree21=new button();
    buttonTree22=new button();
    buttonTree23=new button();
    buttonTreeColor=new button();
    buttonTreeDown=new button();
    buttonTreeUp=new button();
    NL1=uct.rootNode.legalMoves;
    prize pz=new prize();
    pz.getPrize3FromNodeList(NL1.get(0).player, NL1);
    for(NL1id=0; NL1id<NL1.size(); NL1id++){
      if(NL1.get(NL1id) == pz.m1) break;
    }
    color2=NL1.get(0).player;
    setAllPanes();
    setButtons();
  }
  void setAllPanes(){
    if (NL1!=null && NL1.size()!=0){
      int noLM1 = NL1.size();
      prev1 = (NL1id+noLM1-1)%noLM1;
      now1 = NL1id%noLM1;
      next1 = (NL1id+1)%noLM1;
      treeNode11.setNode(NL1.get(prev1));
      treeNode12.setNode(NL1.get(now1));
      treeNode13.setNode(NL1.get(next1));
      if (color2==1) NL2 = NL1.get(now1).childR;
      else if (color2==2) NL2 = NL1.get(now1).childG;
      else if (color2==3) NL2 = NL1.get(now1).childW;
      else if (color2==4) NL2 = NL1.get(now1).childB;
      if (NL2!=null && NL2.size()!=0){
        prize pz=new prize();
        pz.getPrize3FromNodeList(NL2.get(0).player, NL2);
        int noLM2 = NL2.size();
        for(NL2id=0; NL2id<noLM2; NL2id++){
          if(NL2.get(NL2id) == pz.m1) break;
        }
        //println("noLM2="+noLM2);
        prev2 = (NL2id+noLM2-1)%noLM2;
        now2 = NL2id%noLM2;
        next2 = (NL2id+1)%noLM2;
        switch(noLM2){
        case 1:
          treeNode21.setNode(null);
          treeNode22.setNode(NL2.get(now2));
          treeNode23.setNode(null);
          break;
        case 2:
          treeNode21.setNode(null);
          treeNode22.setNode(NL2.get(now2));
          treeNode23.setNode(NL2.get(next2));
          break;
        default:
          treeNode21.setNode(NL2.get(prev2));
          treeNode22.setNode(NL2.get(now2));
          treeNode23.setNode(NL2.get(next2));
        }
      } else {
        treeNode21.setNode(null);
        treeNode22.setNode(null);
        treeNode23.setNode(null);
      }
    }
  }
  void setButtons(){
    buttonTree11.setLTWH(utils.unitSize*0.05, utils.mainU+utils.unitSize*0.06, utils.unitSize*0.25, utils.unitSize*0.275);
    buttonTree13.setLTWH(utils.unitSize*0.70, utils.mainU+utils.unitSize*0.06, utils.unitSize*0.25, utils.unitSize*0.275);
    buttonTreeUp.setLTWH(utils.unitSize*0.35,utils.mainU+utils.unitSize*0.35, utils.unitSize*0.1,utils.unitSize*0.05);
    buttonTreeColor.setLTWH(utils.unitSize*0.45,utils.mainU+utils.unitSize*0.35, utils.unitSize*0.1,utils.unitSize*0.05);
    buttonTreeDown.setLTWH(utils.unitSize*0.55,utils.mainU+utils.unitSize*0.35, utils.unitSize*0.1,utils.unitSize*0.05);
    buttonTree21.setLTWH(utils.unitSize*0.05, utils.mainU+utils.unitSize*0.425, utils.unitSize*0.3, utils.unitSize*0.33);
    buttonTree23.setLTWH(utils.unitSize*0.70, utils.mainU+utils.unitSize*0.425, utils.unitSize*0.3, utils.unitSize*0.33);
  }
  void show() {
    background(255);
    textAlign(LEFT, TOP);
    treeNode11.showTreeNode(utils.unitSize*0.05, utils.mainU+utils.unitSize*0.06, utils.unitSize*0.25);
    treeNode12.showTreeNode(utils.unitSize*0.35, utils.mainU, utils.unitSize*0.3);
    treeNode13.showTreeNode(utils.unitSize*0.65, utils.mainU+utils.unitSize*0.06, utils.unitSize*0.25);
    stroke(0);fill(utils.playerColor[color2]);
    rect(utils.unitSize*0.45,utils.mainU+utils.unitSize*0.35, utils.unitSize*0.1,utils.unitSize*0.05);
    stroke(0);fill(255);
    rect(utils.unitSize*0.35,utils.mainU+utils.unitSize*0.35, utils.unitSize*0.1,utils.unitSize*0.05);
    rect(utils.unitSize*0.55,utils.mainU+utils.unitSize*0.35, utils.unitSize*0.1,utils.unitSize*0.05);
    fill(0);
    textAlign(CENTER, CENTER);
    text("↑",utils.unitSize*0.4,utils.mainU+utils.unitSize*0.375);
    text("↓",utils.unitSize*0.6,utils.mainU+utils.unitSize*0.375);
    textAlign(LEFT, TOP);
    treeNode21.showTreeNode(utils.unitSize*0.05, utils.mainU+utils.unitSize*0.425, utils.unitSize*0.3);
    treeNode22.showTreeNode(utils.unitSize*0.35, utils.mainU+utils.unitSize*0.425, utils.unitSize*0.3);
    treeNode23.showTreeNode(utils.unitSize*0.65, utils.mainU+utils.unitSize*0.425, utils.unitSize*0.3);
    textAlign(LEFT, CENTER);
    //top += utils.vStep;
    //left=utils.hOffset;
    //buttonText = "[Back]";
    //buttonStart=new button();
    //buttonStart.setLT(left, top, buttonText);
    //fill(255, 0, 0);
    //text(buttonText, left, top);
    showReturnButton();
    showScreenCapture();
  }
  
  void mousePressedTree(){
    if (buttonTree11.mouseOn()){
      //println("buttonTree11");
      NL1id = prev1;
      setAllPanes();
    } else if (buttonTree13.mouseOn()){
      //println("buttonTree13");
      NL1id = next1;
      setAllPanes();
    } else if (buttonTreeColor.mouseOn()){
      color2++;
      if (color2==5) color2=1;
      setAllPanes();
      
    }
  }

};
