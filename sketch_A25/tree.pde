void showTree(){
  if (tree.treeNode1.thisNode==null){
    background(255);
    tree.treeNode1.setNode(uct.rootNode);
  } else {
    tree.treeNode1.showTreeNode(width/3, utils.mainU,width/3);
  }
}


class treeNode{
  uctNode thisNode=null;
  void setNode(uctNode nd){
    thisNode = nd;
  }
  void showTreeNode(float x, float y, float wid){
    stroke(0);noFill();
    rect(x,y,wid,wid*1.5,10);
    startBoard tmpBoard=new startBoard(thisNode.bd, thisNode.player);
    float dx = wid/12.0;
    float dy = dx*2/3;
    tmpBoard.display(0,int(x+dx),int(y+dy),int(2*dx),int(2*dy));
    return;
  }
};

gameTree tree=new gameTree();
class gameTree{
  treeNode treeNode1;
  treeNode treeNode21;
  treeNode treeNode22;
  treeNode treeNode23;
  gameTree(){
    treeNode1=new treeNode();
    treeNode21=new treeNode();
    treeNode22=new treeNode();
    treeNode23=new treeNode();
  }
  void init(){
    if(uct !=null && uct.rootNode!=null){
      treeNode1.thisNode = uct.rootNode;
    }
  }
};
