class button{
  float left=100, top=100;
  float wid=80,hei=utils.fontSize;
  String dictKey="";
  int dictInt=0;
  void setLT(float _l, float _t, String text){
    left = _l;
    top = _t;
    wid = textWidth(text)+5;
    hei=utils.fontSize;
  }
  void setItem(String k,int i){
    dictKey = k;
    dictInt = i;
  }
  boolean mouseOn(){
    if (left<mouseX && mouseX<left+wid){
      if (top-hei/2<mouseY && mouseY <top+hei/2){
        return true;
      }
    }
    return false;
  }
};
