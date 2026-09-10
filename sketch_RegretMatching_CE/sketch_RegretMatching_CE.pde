// Hart-Mas-Colell 型 Regret Matching
// Attack 25: Pass(0) / Answer(1), 4 players R,G,W,B
//
// 目的:
//   1) 100回平均から構成した 16 通りの利得表を用いる
//   2) conditional (pairwise/internal) regret を更新する
//   3) 経験分布 q_T(PPPP) と最大正 conditional regret を描く
//
// プレイヤー順: 0=R, 1=G, 2=W, 3=B
// 行動: 0=Pass(P), 1=Answer(A)

int NUM_PLAYERS = 4;
int NUM_ACTIONS = 2;
int P = 0;
int A = 1;

// [R action][G action][W action][B action][player]
float[][][][][] payoffs = new float[2][2][2][2][4];

// regretSum[player][fromAction][toAction]
// 実際に fromAction を選んだ回だけ、
// u_i(toAction, a_-i) - u_i(fromAction, a_-i) を加える。
float[][][] regretSum = new float[NUM_PLAYERS][NUM_ACTIONS][NUM_ACTIONS];

// 現在の行動プロファイル
int[] currentActions = new int[NUM_PLAYERS];

// 16通りの経験回数。PPPP は index 0。
int[] profileCount = new int[16];

// 反復回数
int iteration = 0;

// Regret Matching の正規化定数。
// 本コードの利得は 0～1、かつ各プレイヤーは2行動なので MU=1 なら十分安全。
float MU = 1.0f;

// 実験設定
int TOTAL_STEPS = 100000;
int STEPS_PER_FRAME = 1000;
int RECORD_EVERY = 100;

// 履歴: {iteration, q_T(PPPP), max positive conditional regret}
ArrayList<float[]> history = new ArrayList<float[]>();

boolean finished = false;
boolean csvSaved = false;

void setup() {
  size(1000, 650);
  frameRate(60);

  buildPayoffTable();

  // 初期プロファイルは任意でよい。
  // 収束の様子を見やすくするため AAAA から開始する。
  for (int p = 0; p < NUM_PLAYERS; p++) {
    currentActions[p] = A;
  }

  // Regret Matching 内の乱数を再現可能にする。
  randomSeed(20260908);

  println("Payoff table built.");
  println("Initial profile = " + profileString(currentActions));
  println("Target iterations = " + TOTAL_STEPS);
}

void draw() {
  background(248);

  if (!finished) {
    int steps = min(STEPS_PER_FRAME, TOTAL_STEPS - iteration);
    for (int k = 0; k < steps; k++) {
      runRegretMatchingStep();
    }

    if (iteration >= TOTAL_STEPS) {
      finished = true;
      recordHistory();
      saveHistoryCSV();
    }
  }

  drawPPPPGraph();
  drawRegretGraph();
  drawStatusPanel();
}

// ------------------------------------------------------------
// 利得表
// ------------------------------------------------------------

void buildPayoffTable() {
  // 元盤面 s。
  // G,W,B は理論上対称なので、100回平均をさらに対称化した値を用いる。
  float[] V0 = {
    0.445600f,
    0.184800f,
    0.184800f,
    0.184800f
  };

  // 各プレイヤーが単独で Answer し、最善着手をした後の利得ベクトル。
  // R: R02 型
  float[] UR = {
    0.430471f,
    0.189843f,
    0.189843f,
    0.189843f
  };

  // G: G07 型。W,B は対称化。
  float[] UG = {
    0.407598f,
    0.149361f,
    0.2215205f,
    0.2215205f
  };

  // W, B は G とのプレイヤー置換対称性から作る。
  float[] UW = {
    0.407598f,
    0.2215205f,
    0.149361f,
    0.2215205f
  };

  float[] UB = {
    0.407598f,
    0.2215205f,
    0.2215205f,
    0.149361f
  };

  float[][] singleAnswer = { UR, UG, UW, UB };

  // 16通りを自動生成。
  // Answer するプレイヤーがいなければ V0。
  // 1人以上いれば、Answer 集合の各プレイヤーが等確率で手番を得るため、
  // 対応する singleAnswer ベクトルの平均を利得とする。
  for (int r = 0; r < 2; r++) {
    for (int g = 0; g < 2; g++) {
      for (int w = 0; w < 2; w++) {
        for (int b = 0; b < 2; b++) {
          int[] acts = { r, g, w, b };
          int answerCount = r + g + w + b;

          for (int p = 0; p < NUM_PLAYERS; p++) {
            if (answerCount == 0) {
              payoffs[r][g][w][b][p] = V0[p];
            } else {
              float sum = 0.0f;
              for (int q = 0; q < NUM_PLAYERS; q++) {
                if (acts[q] == A) {
                  sum += singleAnswer[q][p];
                }
              }
              payoffs[r][g][w][b][p] = sum / answerCount;
            }
          }
        }
      }
    }
  }

  // 内部チェック: 各プロファイルの利得和が 1 に近いか表示。
  float maxError = 0.0f;
  for (int r = 0; r < 2; r++) {
    for (int g = 0; g < 2; g++) {
      for (int w = 0; w < 2; w++) {
        for (int b = 0; b < 2; b++) {
          float s = 0.0f;
          for (int p = 0; p < NUM_PLAYERS; p++) {
            s += payoffs[r][g][w][b][p];
          }
          maxError = max(maxError, abs(s - 1.0f));
        }
      }
    }
  }
  println("max |sum(payoffs)-1| = " + maxError);
}

// ------------------------------------------------------------
// Hart-Mas-Colell 型 Regret Matching 1 ステップ
// ------------------------------------------------------------

void runRegretMatchingStep() {
  // 時刻 t で実際に選ばれたプロファイルを経験分布に記録。
  int idx = profileIndex(currentActions);
  profileCount[idx]++;

  // 実際の利得。
  float[] actualPayoffs = getPayoffVector(currentActions);

  // conditional regret を更新。
  // プレイヤー p が実際に j を選んだ今回についてのみ、j -> k の regret を足す。
  for (int p = 0; p < NUM_PLAYERS; p++) {
    int j = currentActions[p];
    int k = 1 - j; // 2行動なので代替行動は1つだけ

    int[] hypothetical = copyActions(currentActions);
    hypothetical[p] = k;

    float hypotheticalPayoff = getPayoff(hypothetical, p);
    float oneStepRegret = hypotheticalPayoff - actualPayoffs[p];

    regretSum[p][j][k] += oneStepRegret;
  }

  iteration++;

  // 一定間隔で経験分布と regret を記録。
  if (iteration % RECORD_EVERY == 0) {
    recordHistory();
  }

  // 次時刻の行動を決める。
  // 現在行動 j から代替行動 k へ移る確率を
  // positive average conditional regret / MU とする。
  int[] nextActions = new int[NUM_PLAYERS];

  for (int p = 0; p < NUM_PLAYERS; p++) {
    int j = currentActions[p];
    int k = 1 - j;

    float avgRegret = regretSum[p][j][k] / iteration;
    float positiveRegret = max(0.0f, avgRegret);
    float switchProb = constrain(positiveRegret / MU, 0.0f, 1.0f);

    if (random(1.0f) < switchProb) {
      nextActions[p] = k;
    } else {
      nextActions[p] = j;
    }
  }

  for (int p = 0; p < NUM_PLAYERS; p++) {
    currentActions[p] = nextActions[p];
  }
}

// ------------------------------------------------------------
// 収束指標
// ------------------------------------------------------------

void recordHistory() {
  if (iteration <= 0) return;

  float qPPPP = (float)profileCount[0] / (float)iteration;
  float maxRegret = getMaxPositiveConditionalRegret();

  // 同じ iteration を二重記録しない。
  if (history.size() > 0) {
    float[] last = history.get(history.size() - 1);
    if ((int)last[0] == iteration) return;
  }

  float[] row = { (float)iteration, qPPPP, maxRegret };
  history.add(row);
}

float getMaxPositiveConditionalRegret() {
  if (iteration <= 0) return 0.0f;

  float ans = 0.0f;
  for (int p = 0; p < NUM_PLAYERS; p++) {
    for (int j = 0; j < NUM_ACTIONS; j++) {
      for (int k = 0; k < NUM_ACTIONS; k++) {
        if (j == k) continue;
        float r = regretSum[p][j][k] / iteration;
        ans = max(ans, max(0.0f, r));
      }
    }
  }
  return ans;
}

// ------------------------------------------------------------
// グラフ
// ------------------------------------------------------------

void drawPPPPGraph() {
  int x0 = 70;
  int y0 = 55;
  int gw = 650;
  int gh = 235;

  fill(255);
  stroke(180);
  rect(x0, y0, gw, gh);

  stroke(225);
  line(x0, y0 + gh/2, x0 + gw, y0 + gh/2);

  fill(70);
  textSize(13);
  text("Empirical frequency of PPPP", x0, 35);
  text("1.0", x0 - 35, y0 + 5);
  text("0.5", x0 - 35, y0 + gh/2 + 5);
  text("0.0", x0 - 35, y0 + gh + 5);

  if (history.size() < 2) return;

  noFill();
  stroke(30, 90, 180);
  strokeWeight(2);
  beginShape();
  for (int i = 0; i < history.size(); i++) {
    float[] h = history.get(i);
    float x = map(h[0], 0, TOTAL_STEPS, x0, x0 + gw);
    float y = map(h[1], 0, 1, y0 + gh, y0);
    vertex(x, y);
  }
  endShape();
  strokeWeight(1);

  fill(70);
  textSize(11);
  text("0", x0 - 3, y0 + gh + 20);
  text(str(TOTAL_STEPS), x0 + gw - 45, y0 + gh + 20);
  text("iteration T", x0 + gw/2 - 30, y0 + gh + 35);
}

void drawRegretGraph() {
  int x0 = 70;
  int y0 = 365;
  int gw = 650;
  int gh = 190;
  float yMax = 0.04f;

  fill(255);
  stroke(180);
  rect(x0, y0, gw, gh);

  stroke(225);
  line(x0, y0 + gh/2, x0 + gw, y0 + gh/2);

  fill(70);
  textSize(13);
  text("Maximum positive conditional regret", x0, y0 - 18);
  text(nf(yMax, 1, 3), x0 - 48, y0 + 5);
  text(nf(yMax/2, 1, 3), x0 - 48, y0 + gh/2 + 5);
  text("0.000", x0 - 48, y0 + gh + 5);

  if (history.size() < 2) return;

  noFill();
  stroke(190, 70, 50);
  strokeWeight(2);
  beginShape();
  for (int i = 0; i < history.size(); i++) {
    float[] h = history.get(i);
    float x = map(h[0], 0, TOTAL_STEPS, x0, x0 + gw);
    float y = map(constrain(h[2], 0, yMax), 0, yMax, y0 + gh, y0);
    vertex(x, y);
  }
  endShape();
  strokeWeight(1);

  fill(70);
  textSize(11);
  text("0", x0 - 3, y0 + gh + 20);
  text(str(TOTAL_STEPS), x0 + gw - 45, y0 + gh + 20);
  text("iteration T", x0 + gw/2 - 30, y0 + gh + 35);
}

void drawStatusPanel() {
  int x = 760;

  fill(20);
  textSize(17);
  text("Regret Matching", x, 55);

  textSize(13);
  fill(70);
  text("Hart-Mas-Colell type", x, 78);
  text("P = Pass, A = Answer", x, 100);

  textSize(14);
  fill(20);
  text("Iteration: " + iteration, x, 145);
  text("Current: " + profileString(currentActions), x, 170);

  if (iteration > 0) {
    float q = (float)profileCount[0] / (float)iteration;
    float mr = getMaxPositiveConditionalRegret();
    text("q_T(PPPP): " + nf(q, 1, 6), x, 205);
    text("max regret: " + nf(mr, 1, 7), x, 230);
  }

  textSize(12);
  fill(80);
  text("Positive conditional regrets", x, 280);
  String[] names = { "R", "G", "W", "B" };
  int y = 305;
  for (int p = 0; p < NUM_PLAYERS; p++) {
    float rPA = 0.0f;
    float rAP = 0.0f;
    if (iteration > 0) {
      rPA = max(0.0f, regretSum[p][P][A] / iteration);
      rAP = max(0.0f, regretSum[p][A][P] / iteration);
    }
    text(names[p] + "  P->A " + nf(rPA, 1, 6)
      + "   A->P " + nf(rAP, 1, 6), x, y);
    y += 25;
  }

  if (finished) {
    fill(0, 120, 60);
    textSize(14);
    text("Finished", x, 445);
    fill(70);
    textSize(11);
    text("CSV saved:", x, 470);
    text("regret_matching_history.csv", x, 488);
  }
}

// ------------------------------------------------------------
// CSV 保存
// ------------------------------------------------------------

void saveHistoryCSV() {
  if (csvSaved) return;

  String[] lines = new String[history.size() + 1];
  lines[0] = "iteration,q_PPPP,max_positive_conditional_regret";

  for (int i = 0; i < history.size(); i++) {
    float[] h = history.get(i);
    lines[i+1] = (int)h[0] + "," + h[1] + "," + h[2];
  }

  saveStrings("regret_matching_history.csv", lines);
  csvSaved = true;
  println("Saved regret_matching_history.csv");
}

// ------------------------------------------------------------
// 補助関数
// ------------------------------------------------------------

float[] getPayoffVector(int[] a) {
  float[] ans = new float[NUM_PLAYERS];
  for (int p = 0; p < NUM_PLAYERS; p++) {
    ans[p] = payoffs[a[0]][a[1]][a[2]][a[3]][p];
  }
  return ans;
}

float getPayoff(int[] a, int player) {
  return payoffs[a[0]][a[1]][a[2]][a[3]][player];
}

int[] copyActions(int[] src) {
  int[] dst = new int[src.length];
  for (int i = 0; i < src.length; i++) dst[i] = src[i];
  return dst;
}

int profileIndex(int[] a) {
  return a[0] * 8 + a[1] * 4 + a[2] * 2 + a[3];
}

String profileString(int[] a) {
  String s = "";
  for (int i = 0; i < NUM_PLAYERS; i++) {
    s += (a[i] == P) ? "P" : "A";
  }
  return s;
}
