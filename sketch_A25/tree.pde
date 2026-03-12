void showTree(){
  
}


class treeNode{
  uctNode thisNode;
  void showTreeNode(float x, float y, float wid){
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
