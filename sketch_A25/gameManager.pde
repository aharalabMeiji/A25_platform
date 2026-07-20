// game manager line 1450
mP managerPhase;
dP displayManager;
sP simulationManager;

enum dP{// display manager
  onSimulator, onGame, onContents, onTree, onExperiment
}

enum mP{// game manager
  PrepareGame, GameStart,
  WaitChoosePlayer,AfterChoosePlayer,
  BeforeMoving,OnMoving,AfterMoving,
  BeforeAttackChance,OnAttackChance,AfterAttackChance,
  ErrorStop,
  Halt,
  T1,T2,T3,T4,T5,T6,T7,
  GameEnd 
}

enum sP{// simulation manager
  GameStart, setStartBoard, runMC, GameEnd 
}
