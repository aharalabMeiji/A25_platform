// contents line 750

void showContents() {
  if (buttons==null) {
    buttons = new ArrayList<button>();
  } else {
    buttons.clear();
  }
  background(255);
  fill(0);
  textSize(utils.fontSize);
  textAlign(LEFT, CENTER);
  text("Attack 25 simulator", 20, 20);
  float top=60, left=utils.hOffset;
  String buttonText="";
  // gameMode
  buttonText = "Game";
  buttonMenuGame = new button();
  buttonMenuGame.setLT(left, top, buttonText);
  buttonMenuGame.setItem("gameMode", 0);
  //buttons.add(buttonMenuGame);
  if (gameOptions.get("gameMode") == 0) fill(255, 0, 0);
  else fill(0);
  text(buttonText, left, top);
  left += (textWidth(buttonText)+20);
  buttonText = "Simulation";
  buttonMenuSimulation = new button();
  buttonMenuSimulation.setLT(left, top, buttonText);
  buttonMenuSimulation.setItem("gameMode", 1);
  buttons.add(buttonMenuSimulation);
  if (gameOptions.get("gameMode") == 1) fill(255, 0, 0);
  else fill(0);
  text(buttonText, left, top);
  //
  fill(0);
  text(filenamePath, utils.mainL+utils.fontSize*22, utils.mainU-utils.fontSize);
  //
  top += utils.vStep;
  left=utils.hOffset;
  if (gameOptions.get("gameMode") == 0) {// Game options
    // Player1
    String captionText = "Player1(Red):   ";
    fill(0);
    text(captionText, left, top);
    left += (textWidth(captionText)+utils.hSpace);
    buttonText = "[Human]";
    button buttonHuman1=new button();
    buttonHuman1.setLT(left, top, buttonText);
    buttonHuman1.setItem("Player1", 0);
    buttons.add(buttonHuman1);
    if (gameOptions.get("Player1") == 0) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Random]";
    button buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Player1", 1);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Player1") == 1) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Heuristic]";
    button buttonHeuristic1=new button();
    buttonHeuristic1.setLT(left, top, buttonText);
    buttonHeuristic1.setItem("Player1", 2);
    //buttons.add(buttonHeuristic1);
    if (gameOptions.get("Player1")%10 == 2) fill(255, 0, 0);
    else fill(0);
    fill(200, 200, 200);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[UCB]";
    button buttonUCT1=new button();
    buttonUCT1.setLT(left, top, buttonText);
    buttonUCT1.setItem("Player1", 3);
    buttons.add(buttonUCT1);
    if (gameOptions.get("Player1")%10 == 3) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+10);
    //
    buttonText = "[UCT]";
    button buttonUCTMCTS1=new button();
    buttonUCTMCTS1.setLT(left, top, buttonText);
    buttonUCTMCTS1.setItem("Player1", 4);
    buttons.add(buttonUCTMCTS1);
    if (gameOptions.get("Player1")%10==4) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);

    // Player2
    top += utils.vStep;
    left=utils.hOffset;
    captionText = "Player2(Green):";
    fill(0);
    text(captionText, left, top);
    left += (textWidth(captionText)+utils.hSpace);
    buttonText = "[Human]";
    buttonHuman1=new button();
    buttonHuman1.setLT(left, top, buttonText);
    buttonHuman1.setItem("Player2", 0);
    buttons.add(buttonHuman1);
    if (gameOptions.get("Player2") == 0) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Random]";
    buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Player2", 1);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Player2") == 1) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Heuristic]";
    buttonHeuristic1=new button();
    buttonHeuristic1.setLT(left, top, buttonText);
    buttonHeuristic1.setItem("Player2", 2);
    //buttons.add(buttonHeuristic1);
    if (gameOptions.get("Player2") == 2) fill(255, 0, 0);
    else fill(0);
    fill(200, 200, 200);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[UCB]";
    buttonUCT1=new button();
    buttonUCT1.setLT(left, top, buttonText);
    buttonUCT1.setItem("Player2", 3);
    buttons.add(buttonUCT1);
    if (gameOptions.get("Player2") == 3) fill(255, 0, 0);
    else fill(0);
    //fill(200, 200, 200);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[UCT]";
    buttonUCTMCTS1=new button();
    buttonUCTMCTS1.setLT(left, top, buttonText);
    buttonUCTMCTS1.setItem("Player2", 4);
    buttons.add(buttonUCTMCTS1);
    if (gameOptions.get("Player2")%10==4) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);

    // Player3
    top += utils.vStep;
    left=utils.hOffset;
    captionText = "Player3(White):";
    fill(0);
    text(captionText, left, top);
    left += (textWidth(captionText)+utils.hSpace);
    buttonText = "[Human]";
    buttonHuman1=new button();
    buttonHuman1.setLT(left, top, buttonText);
    buttonHuman1.setItem("Player3", 0);
    buttons.add(buttonHuman1);
    if (gameOptions.get("Player3") == 0) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Random]";
    buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Player3", 1);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Player3") == 1) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Heuristic]";
    buttonHeuristic1=new button();
    buttonHeuristic1.setLT(left, top, buttonText);
    buttonHeuristic1.setItem("Player3", 2);
    //buttons.add(buttonHeuristic1);
    if (gameOptions.get("Player3") == 2) fill(255, 0, 0);
    else fill(0);
    fill(200, 200, 200);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[UCB]";
    buttonUCT1=new button();
    buttonUCT1.setLT(left, top, buttonText);
    buttonUCT1.setItem("Player3", 3);
    buttons.add(buttonUCT1);
    if (gameOptions.get("Player3") == 3) fill(255, 0, 0);
    else fill(0);
    //fill(200, 200, 200);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[UCT]";
    buttonUCTMCTS1=new button();
    buttonUCTMCTS1.setLT(left, top, buttonText);
    buttonUCTMCTS1.setItem("Player3", 4);
    buttons.add(buttonUCTMCTS1);
    if (gameOptions.get("Player3")%10==4) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);

    // Player4
    top += utils.vStep;
    left=utils.hOffset;
    captionText = "Player4(Blue):  ";
    fill(0);
    text(captionText, left, top);
    left += (textWidth(captionText)+utils.hSpace);
    buttonText = "[Human]";
    buttonHuman1=new button();
    buttonHuman1.setLT(left, top, buttonText);
    buttonHuman1.setItem("Player4", 0);
    buttons.add(buttonHuman1);
    if (gameOptions.get("Player4") == 0) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Random]";
    buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Player4", 1);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Player4") == 1) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Heuristic]";
    buttonHeuristic1=new button();
    buttonHeuristic1.setLT(left, top, buttonText);
    buttonHeuristic1.setItem("Player4", 2);
    //buttons.add(buttonHeuristic1);
    if (gameOptions.get("Player4") == 2) fill(255, 0, 0);
    else fill(0);
    fill(200, 200, 200);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[UCB]";
    buttonUCT1=new button();
    buttonUCT1.setLT(left, top, buttonText);
    buttonUCT1.setItem("Player4", 3);
    buttons.add(buttonUCT1);
    if (gameOptions.get("Player4") == 3) fill(255, 0, 0);
    else fill(0);
    //fill(200, 200, 200);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[UCT]";
    buttonUCTMCTS1=new button();
    buttonUCTMCTS1.setLT(left, top, buttonText);
    buttonUCTMCTS1.setItem("Player4", 4);
    buttons.add(buttonUCTMCTS1);
    if (gameOptions.get("Player4")%10==4) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);


    // Order
    top += utils.vStep;
    left=utils.hOffset;
    captionText = "Order:";
    fill(0);
    text(captionText, left, top);
    left += (textWidth(captionText)+utils.hSpace);
    //
    buttonText = "[Auto(Random)]";
    buttonHuman1=new button();
    buttonHuman1.setLT(left, top, buttonText);
    buttonHuman1.setItem("Order", 0);
    buttons.add(buttonHuman1);
    if (gameOptions.get("Order") == 0) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Manual]";
    buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Order", 1);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Order") == 1) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Conditional Random]";
    buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Order", 3);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Order") == 3) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[in order]";
    buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Order", 4);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Order") == 4) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);


    // Times
    top += utils.vStep;
    left=utils.hOffset;
    captionText = "Times:";
    fill(0);
    text(captionText, left, top);
    left += (textWidth(captionText)+utils.hSpace);
    buttonText = "[Once]";
    buttonHuman1=new button();
    buttonHuman1.setLT(left, top, buttonText);
    buttonHuman1.setItem("Times", 1);
    buttons.add(buttonHuman1);
    if (gameOptions.get("Times") == 1) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[10 times]";
    buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Times", 10);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Times") == 10) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[100 times]";
    buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Times", 100);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Times") == 100) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[1000 times]";
    buttonRandom1=new button();
    buttonRandom1.setLT(left, top, buttonText);
    buttonRandom1.setItem("Times", 1000);
    buttons.add(buttonRandom1);
    if (gameOptions.get("Times") == 1000) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    top += utils.vStep;
    left=utils.hOffset;
    //
    buttonText = "[New list]";
    buttonNew = new button();
    buttonNew.setLT(left, top, buttonText);
    fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Open file]";
    buttonOpenFile = new button();
    buttonOpenFile.setLT(left, top, buttonText);
    fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Save file]";
    buttonSaveFile = new button();
    buttonSaveFile.setLT(left, top, buttonText);
    fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Delete from list]";
    buttonDeleteFromList = new button();
    buttonDeleteFromList.setLT(left, top, buttonText);
    fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Kifu Folder]";
    buttonKifuFolder = new button();
    buttonKifuFolder.setLT(left, top, buttonText);
    fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    top += utils.vStep;
    left=utils.hOffset;
    int total = simulatorStartBoard.size();
    if (total>0) {
      float smallBoardDispSize = utils.fontSize;
      float boardDispSize = smallBoardDispSize*1.5;
      int now = (simulator.StartBoardId) % total;
      int prev = (simulator.StartBoardId + total -1 ) % total;
      int next = (simulator.StartBoardId + 1 ) % total;
      buttonPrevBoard = new button();
      buttonPrevBoard.setLT(int(left), int(top+boardDispSize*1.5+smallBoardDispSize*2.5), " ");
      buttonPrevBoard.wid=smallBoardDispSize*5;
      buttonPrevBoard.hei=smallBoardDispSize*5;
      simulatorStartBoard.get(prev).display(0, int(left), int(top+boardDispSize*1.5), int(smallBoardDispSize), int(smallBoardDispSize));
      textAlign(LEFT, CENTER);
      fill(0);
      text(prev, left, top+boardDispSize*7);
      simulatorStartBoard.get(now).display(0, int(left+smallBoardDispSize*7), int(top), int(boardDispSize), int(boardDispSize));
      fill(0);
      text(now, left+smallBoardDispSize*7, top+boardDispSize*7);
      buttonNextBoard = new button();
      buttonNextBoard.setLT(int(left+boardDispSize*5+smallBoardDispSize*9), int(top+boardDispSize*1.5+smallBoardDispSize*2.5), " ");
      buttonNextBoard.wid=smallBoardDispSize*5;
      buttonNextBoard.hei=smallBoardDispSize*5;
      simulatorStartBoard.get(next).display(0, int(left+boardDispSize*5+smallBoardDispSize*9), int(top+boardDispSize*1.5), int(smallBoardDispSize), int(smallBoardDispSize));
      fill(0);
      text(next, left+boardDispSize*5+smallBoardDispSize*9, top+boardDispSize*7);
      top += utils.vStep*7;
    }
    // Start
    top += utils.vStep;
    left=utils.hOffset;
    buttonText = "S T A R T";
    buttonStart=new button();
    buttonStart.setLT(left, top, buttonText);
    fill(255, 0, 0);
    text(buttonText, left, top);
  } else if (gameOptions.get("gameMode") == 1) {///////////////////////////////////////// Simulation options
    fill(0);
    text(filenamePath, utils.mainL+utils.fontSize*22, utils.mainU-utils.fontSize);
    // シミュレーション方法選択
    //top += utils.vStep;
    left=utils.hOffset;
    String captionText = "Sim :";
    fill(0);
    text(captionText, left, top);
    //gameOptions.set("SimTimes", 2);
    left += (textWidth(captionText)+utils.hSpace);
    //
    buttonText = "[MC]";
    button buttonSimMethod1=new button();
    buttonSimMethod1.setLT(left, top, buttonText);
    buttonSimMethod1.setItem("SimMethod", 1);
    buttons.add(buttonSimMethod1);
    if (gameOptions.get("SimMethod") == 1) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[UCB1]";
    button buttonSimMethod2=new button();
    buttonSimMethod2.setLT(left, top, buttonText);
    buttonSimMethod2.setItem("SimMethod", 2);
    buttons.add(buttonSimMethod2);
    if (gameOptions.get("SimMethod") == 2) fill(255, 0, 0);
    else fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[UCT]";
    button buttonSimMethod3=new button();
    buttonSimMethod3.setLT(left, top, buttonText);
    buttonSimMethod3.setItem("SimMethod", 3);
    buttons.add(buttonSimMethod3);
    if (gameOptions.get("SimMethod") == 3) fill(255, 0, 0);
    else fill(0);
    //fill(200, 200, 200);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    // シミュレーション回数
    // Times
    if (gameOptions.get("SimMethod") == 1) {//[fullRandom]
      top += utils.vStep;
      left=utils.hOffset;
      captionText = "Time:";
      fill(0);
      text(captionText, left, top);
      left += (textWidth(captionText)+utils.hSpace);
      //
      buttonText = "[1K]";
      button buttontimes1=new button();
      buttontimes1.setLT(left, top, buttonText);
      buttontimes1.setItem("SimTimes", 1);
      buttons.add(buttontimes1);
      if (gameOptions.get("SimTimes") == 1) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
      //
      buttonText = "[10K]";
      button buttontimes2=new button();
      buttontimes2.setLT(left, top, buttonText);
      buttontimes2.setItem("SimTimes", 2);
      buttons.add(buttontimes2);
      if (gameOptions.get("SimTimes") == 2) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
      //
      buttonText = "[limit]";
      button buttontimes3=new button();
      buttontimes3.setLT(left, top, buttonText);
      buttontimes3.setItem("SimTimes", 3);
      buttons.add(buttontimes3);
      if (gameOptions.get("SimTimes") == 3) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
    } else if (gameOptions.get("SimMethod") == 2 ){//[UCB]
      top += utils.vStep;
      left=utils.hOffset;
      captionText = "Time:";
      fill(0);
      text(captionText, left, top);
      left += (textWidth(captionText)+utils.hSpace);
      //
      buttonText = "[10 sec]";
      button buttontimes1=new button();
      buttontimes1.setLT(left, top, buttonText);
      buttontimes1.setItem("SimTimes", 11);
      buttons.add(buttontimes1);
      if (gameOptions.get("SimTimes") == 11) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
      //
      buttonText = "[60 secs]";
      button buttontimes2=new button();
      buttontimes2.setLT(left, top, buttonText);
      buttontimes2.setItem("SimTimes", 12);
      buttons.add(buttontimes2);
      if (gameOptions.get("SimTimes") == 12) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
      //
      buttonText = "[limit]";
      button buttontimes3=new button();
      buttontimes3.setLT(left, top, buttonText);
      buttontimes3.setItem("SimTimes", 13);
      buttons.add(buttontimes3);
      if (gameOptions.get("SimTimes") == 13) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
      //
    } else {//gameOptions.get("SimMethod") == 3 
      //println("L561@contents",gameOptions.get("SimTimes"));
      top += utils.vStep;
      left=utils.hOffset;
      captionText = "Time:";
      fill(0);
      text(captionText, left, top);
      left += (textWidth(captionText)+utils.hSpace);
      //
      buttonText = "[D4/wC]";
      button buttontimes1=new button();
      buttontimes1.setLT(left, top, buttonText);
      buttontimes1.setItem("SimTimes", 21);
      buttons.add(buttontimes1);
      if (gameOptions.get("SimTimes") == 21) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
      //
      buttonText = "[D4/woC]";
      button buttontimes2=new button();
      buttontimes2.setLT(left, top, buttonText);
      buttontimes2.setItem("SimTimes", 22);
      buttons.add(buttontimes2);
      if (gameOptions.get("SimTimes") == 22) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
      //
      buttonText = "[D5/wC]";
      button buttontimes3=new button();
      buttontimes3.setLT(left, top, buttonText);
      buttontimes3.setItem("SimTimes", 23);
      buttons.add(buttontimes3);
      if (gameOptions.get("SimTimes") == 23) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
      //
      buttonText = "[D5/woC]";
      button buttontimes4=new button();
      buttontimes4.setLT(left, top, buttonText);
      buttontimes4.setItem("SimTimes", 24);
      buttons.add(buttontimes4);
      if (gameOptions.get("SimTimes") == 24) fill(255, 0, 0);
      else fill(0);
      text(buttonText, left, top);
      left += (textWidth(buttonText)+utils.hSpace);
      //
    }
    if (gameOptions.get("SimMethod") == 3 ){
      top += utils.vStep;
      left=utils.hOffset;
      //
      fill(255, 0, 0);
      if (gameOptions.get("SimTimes") == 21) text("visit/node=10, max depth=4, with cancelling",left,top);
      else if (gameOptions.get("SimTimes") == 22) text("visit/node=10, max depth=4, w/o cancelling",left,top);
      else if (gameOptions.get("SimTimes") == 23) text("visit/node=10, max depth=5, with cancelling",left,top);
      else if (gameOptions.get("SimTimes") == 24) text("visit/node=10, max depth=5, w/o cancelling",left,top);
    }
    //
    top += utils.vStep;
    left=utils.hOffset;
    //
    buttonText = "[New list]";
    buttonNew = new button();
    buttonNew.setLT(left, top, buttonText);
    fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Open file]";
    buttonOpenFile = new button();
    buttonOpenFile.setLT(left, top, buttonText);
    fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "("+filenamePath+")";
    //buttonOpenPsrFile = new button();
    //buttonOpenPsrFile.setLT(left, top, buttonText);
    //fill(0);
    //text(buttonText, left, top);
    //left += (textWidth(buttonText)+utils.hSpace);
    //
    top += utils.vStep;
    left = utils.hOffset;
    buttonText = "[Save TXT file]";
    buttonSaveFile = new button();
    buttonSaveFile.setLT(left, top, buttonText);
    fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    buttonText = "[Delete from list]";
    buttonDeleteFromList = new button();
    buttonDeleteFromList.setLT(left, top, buttonText);
    fill(0);
    text(buttonText, left, top);
    left += (textWidth(buttonText)+utils.hSpace);
    //
    top += utils.vStep;
    left=utils.hOffset;
    int total = simulatorStartBoard.size();
    if (total>0) {
      float smallBoardDispSize = utils.fontSize;
      float boardDispSize = smallBoardDispSize*1.5;
      int now = (simulator.StartBoardId) % total;
      int prev = (simulator.StartBoardId + total -1 ) % total;
      int next = (simulator.StartBoardId + 1 ) % total;
      buttonPrevBoard = new button();
      buttonPrevBoard.setLT(int(left), int(top+boardDispSize*1.5+smallBoardDispSize*2.5), " ");
      buttonPrevBoard.wid=smallBoardDispSize*5;
      buttonPrevBoard.hei=smallBoardDispSize*5;
      simulatorStartBoard.get(prev).display(0, int(left), int(top+boardDispSize*1.5), int(smallBoardDispSize), int(smallBoardDispSize));
      textAlign(LEFT, CENTER);
      fill(0);
      text(prev, left, top+boardDispSize*7);
      simulatorStartBoard.get(now).display(0, int(left+smallBoardDispSize*7), int(top), int(boardDispSize), int(boardDispSize));
      fill(0);
      text(now, left+smallBoardDispSize*7, top+boardDispSize*7);
      buttonNextBoard = new button();
      buttonNextBoard.setLT(int(left+boardDispSize*5+smallBoardDispSize*9), int(top+boardDispSize*1.5+smallBoardDispSize*2.5), " ");
      buttonNextBoard.wid=smallBoardDispSize*5;
      buttonNextBoard.hei=smallBoardDispSize*5;
      simulatorStartBoard.get(next).display(0, int(left+boardDispSize*5+smallBoardDispSize*9), int(top+boardDispSize*1.5), int(smallBoardDispSize), int(smallBoardDispSize));
      fill(0);
      text(next, left+boardDispSize*5+smallBoardDispSize*9, top+boardDispSize*7);
      top += utils.vStep*7;
      //int now = (simulator.StartBoardId) % total;
      //int prev = (simulator.StartBoardId + total -1 ) % total;
      //int next = (simulator.StartBoardId + 1 ) % total;
      //buttonPrevBoard = new button();
      //buttonPrevBoard.setLT(int(left), int(top+utils.fontSize*1.3), " ");
      //buttonPrevBoard.wid=utils.fontSize*2.5;
      //buttonPrevBoard.hei=utils.fontSize*2.5;
      //simulatorStartBoard.get(prev).display(0, int(left), int(top+utils.fontSize*0.42), int(utils.fontSize*0.5), int(utils.fontSize*0.5));
      //textAlign(LEFT, CENTER);
      //fill(0);
      //text(prev, left, top+utils.fontSize*0.5*9);
      //simulatorStartBoard.get(now).display(0, int(left+utils.fontSize*4), int(top), int(utils.fontSize*0.67), int(utils.fontSize*0.67));
      //fill(0);
      //text(now, left+utils.fontSize*4.08, top+utils.fontSize*4.5);
      //buttonNextBoard = new button();
      //buttonNextBoard.setLT(int(left+utils.fontSize*9.17), int(top+utils.fontSize*1.67), " ");
      //buttonNextBoard.wid=utils.fontSize*2.5;
      //buttonNextBoard.hei=utils.fontSize*2.5;
      //simulatorStartBoard.get(next).display(0, int(left+utils.fontSize*9.17), int(top+utils.fontSize*0.4), int(utils.fontSize*0.5), int(utils.fontSize*0.5));
      //fill(0);
      //text(next, left+utils.fontSize*9.17, top+utils.fontSize*4.5);
      //top += utils.vStep*2.5;
    }
    // Start
    top += utils.vStep;
    left=utils.hOffset;
    buttonText = "S T A R T";
    buttonStart=new button();
    buttonStart.setLT(left, top, buttonText);
    fill(255, 0, 0);
    text(buttonText, left, top);
  }
}
