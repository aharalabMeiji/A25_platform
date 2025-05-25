// game manager
mP managerPhase;
dP displayManager;
sP simulationManager;

enum dP{// display manager
  onSimulator,onGame,onContents
}

enum mP{// game manager
  GameStart,
  WaitChoosePlayer,AfterChoosePlayer,
  BeforeMoving,OnMoving,AfterMoving,
  BeforeAttackChance,OnAttackChance,AfterAttackChance,
  ErrorStop,
  Halt,
  GameEnd 
}

enum sP{// simulation manager
  GameStart, setStartBoard, runMC, GameEnd 
}
