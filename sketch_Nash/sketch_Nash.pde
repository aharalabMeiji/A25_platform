// プレイヤー数と戦略数
int NUM_PLAYERS = 4;
int NUM_ACTIONS = 2; // 各プレイヤー2つの戦略 (0 または 1)

// 16通りの利得表: [P1の戦略][P2の戦略][P3の戦略][P4の戦略][どのプレイヤーの利得か(0-3)]
float[][][][][] payoffs = new float[2][2][2][2][4];

// レグレット・マッチング用の変数
float[][] cumulativeRegrets = new float[NUM_PLAYERS][NUM_ACTIONS];
float[][] strategySum = new float[NUM_PLAYERS][NUM_ACTIONS];

// グラフ描画用の履歴
ArrayList<float[]> strategyHistory = new ArrayList<float[]>();

boolean shuuryou=false;

void setup() {
  size(800, 500);
  frameRate(60);
  float r0=0.457;
  float g0=0.1807;
  float w0=0.1807;
  float b0=0.1807;
  // 1. 利得表の初期化（サンプルデータ: 2^4 = 16通り）
  // 4人の戦略の組み合わせ (s1, s2, s3, s4) に対して、それぞれの利得を設定
  // ここではランダムな利得（-1.0 〜 1.0）をサンプルとして与えています
  randomSeed(50); // 再現性のためにシードを固定
  for (int p = 0; p < 4; p++) {
    payoffs[0][0][0][0][p]=0;
  }
  float rr,rg,rw,rb,gr,gg,gw,gb,wr,wg,ww,wb,br,bg,bw,bb;
  payoffs[1][0][0][0][0]=rr=0.4190-r0;
  payoffs[1][0][0][0][1]=rg=0.1999-g0;
  payoffs[1][0][0][0][2]=rw=0.1999-w0;
  payoffs[1][0][0][0][3]=rb=0.1999-b0;
  
  payoffs[0][1][0][0][0]=gr=0.4120-r0;
  payoffs[0][1][0][0][1]=gg=0.1613-g0;
  payoffs[0][1][0][0][2]=gw=0.2283-w0;
  payoffs[0][1][0][0][3]=gb=0.2283-b0;
  
  payoffs[0][0][1][0][0]=wr=0.4120-r0;
  payoffs[0][0][1][0][1]=wg=0.2283-g0;
  payoffs[0][0][1][0][2]=ww=0.1613-w0;
  payoffs[0][0][1][0][3]=wb=0.2283-b0;
  
  payoffs[0][0][0][1][0]=br=0.4120-r0;
  payoffs[0][0][0][1][1]=bg=0.2283-g0;
  payoffs[0][0][0][1][2]=bw=0.2283-w0;
  payoffs[0][0][0][1][3]=bb=0.1613-b0;
  
  payoffs[1][1][0][0][0]=(rr+gr)/2;
  payoffs[1][1][0][0][1]=(rg+gg)/2;
  payoffs[1][1][0][0][2]=(rw+gw)/2;
  payoffs[1][1][0][0][3]=(rb+gb)/2;

  payoffs[1][0][1][0][0]=(rr+wr)/2;
  payoffs[1][0][1][0][1]=(rg+wg)/2;
  payoffs[1][0][1][0][2]=(rw+ww)/2;
  payoffs[1][0][1][0][3]=(rb+wb)/2;

  payoffs[1][0][0][1][0]=(rr+br)/2;
  payoffs[1][0][0][1][1]=(rg+bg)/2;
  payoffs[1][0][0][1][2]=(rw+bw)/2;
  payoffs[1][0][0][1][3]=(rb+bb)/2;

  payoffs[0][1][1][0][0]=(gr+wr)/2;
  payoffs[0][1][1][0][1]=(gg+wg)/2;
  payoffs[0][1][1][0][2]=(gw+ww)/2;
  payoffs[0][1][1][0][3]=(gb+wb)/2;

  payoffs[0][1][0][1][0]=(gr+br)/2;
  payoffs[0][1][0][1][1]=(gg+bg)/2;
  payoffs[0][1][0][1][2]=(gw+bw)/2;
  payoffs[0][1][0][1][3]=(gb+bb)/2;

  payoffs[0][0][1][1][0]=(wr+br)/2;
  payoffs[0][0][1][1][1]=(wg+bg)/2;
  payoffs[0][0][1][1][2]=(ww+bw)/2;
  payoffs[0][0][1][1][3]=(wb+bb)/2;

  payoffs[1][1][1][0][0]=(rr+gr+wr)/3;
  payoffs[1][1][1][0][1]=(rg+gg+wg)/3;
  payoffs[1][1][1][0][2]=(rw+gw+ww)/3;
  payoffs[1][1][1][0][3]=(rb+gb+wb)/3;

  payoffs[1][1][0][1][0]=(rr+gr+br)/3;
  payoffs[1][1][0][1][1]=(rg+gg+bg)/3;
  payoffs[1][1][0][1][2]=(rw+gw+bw)/3;
  payoffs[1][1][0][1][3]=(rb+gb+bb)/3;

  payoffs[1][0][1][1][0]=(rr+wr+br)/3;
  payoffs[1][0][1][1][1]=(rg+wg+bg)/3;
  payoffs[1][0][1][1][2]=(rw+ww+bw)/3;
  payoffs[1][0][1][1][3]=(rb+wb+bb)/3;

  payoffs[0][1][1][1][0]=(gr+wr+br)/3;
  payoffs[0][1][1][1][1]=(gg+wg+bg)/3;
  payoffs[0][1][1][1][2]=(gw+ww+bw)/3;
  payoffs[0][1][1][1][3]=(gb+wb+bb)/3;

  payoffs[1][1][1][1][0]=(rr+gr+wr+br)/4;
  payoffs[1][1][1][1][1]=(rg+gg+wg+bg)/4;
  payoffs[1][1][1][1][2]=(rw+gw+ww+bw)/4;
  payoffs[1][1][1][1][3]=(rb+gb+wb+bb)/4;
  //println((rr+gr+wr+br)/4,(rg+gg+wg+bg)/4,(rw+gw+ww+bw)/4,(rb+gb+wb+bb)/4);
}

void draw() {
  if(shuuryou) return;
  background(245);
  
  if (strategyHistory.size()>=(width-250)/10) shuuryou=true;
  // 1フレームあたり100回シミュレーションを回して高速に収束させる
  for (int step = 0; step < 2; step++) {
    runRegretMatchingStep();
  }
  
  // 現在の平均戦略（ナッシュ均衡の近似値）を履歴に保存
  float[] currentEquilibrium = new float[NUM_PLAYERS];
  for (int p = 0; p < NUM_PLAYERS; p++) {
    float sum = strategySum[p][0] + strategySum[p][1];
    if (sum > 0) {
      currentEquilibrium[p] = strategySum[p][0] / sum; // 戦略0を選ぶ確率
    } else {
      currentEquilibrium[p] = 0.5;
    }
  }
  strategyHistory.add(currentEquilibrium);
  if (strategyHistory.size() > (width - 250)/10) {
    strategyHistory.remove(0);
  }
  
  // --- 画面描画処理 ---
  drawGraph();
  drawStatusPanel(currentEquilibrium);
}

// レグレット・マッチングの1ステップを実行する関数
void runRegretMatchingStep() {
  int[] currentActions = new int[NUM_PLAYERS];
  float[][] currentStrategies = new float[NUM_PLAYERS][NUM_ACTIONS];
  
  // 1. 現在の後悔の度合い（正の値のみ）から、今回の選択確率を計算
  for (int p = 0; p < NUM_PLAYERS; p++) {
    float regretSum = 0;
    for (int a = 0; a < NUM_ACTIONS; a++) {
      currentStrategies[p][a] = max(0, cumulativeRegrets[p][a]);
      regretSum += currentStrategies[p][a];
    }
    
    // 全ての後悔が0以下なら、等確率(0.5ずつ)で選択
    if (regretSum > 0) {
      for (int a = 0; a < NUM_ACTIONS; a++) {
        currentStrategies[p][a] /= regretSum;
      }
    } else {
      for (int a = 0; a < NUM_ACTIONS; a++) {
        currentStrategies[p][a] = 1.0 / NUM_ACTIONS;
      }
    }
    
    // 確率分布に基づいて、今回の行動をランダムに決定
    currentActions[p] = (random(1.0) < currentStrategies[p][0]) ? 0 : 1;
    
    // 平均戦略（これがナッシュ均衡に収束する）を累積
    for (int a = 0; a < NUM_ACTIONS; a++) {
      strategySum[p][a] += currentStrategies[p][a];
    }
  }
  
  // 2. 実際に選ばれた行動の組み合わせから、各プレイヤーの実際の利得を計算
  int s1 = currentActions[0];
  int s2 = currentActions[1];
  int s3 = currentActions[2];
  int s4 = currentActions[3];
  
  float[] actualPayoffs = payoffs[s1][s2][s3][s4];
  
  // 3. 「もし別の行動をとっていたら得られた利得」を計算し、後悔を更新
  for (int p = 0; p < NUM_PLAYERS; p++) {
    for (int a = 0; a < NUM_ACTIONS; a++) {
      // プレイヤーpだけが行動を a に変え、他プレイヤーはそのままだった場合の利得
      float hypotheticalPayoff = 0;
      if (p == 0) hypotheticalPayoff = payoffs[a][s2][s3][s4][0];
      else if (p == 1) hypotheticalPayoff = payoffs[s1][a][s3][s4][1];
      else if (p == 2) hypotheticalPayoff = payoffs[s1][s2][a][s4][2];
      else if (p == 3) hypotheticalPayoff = payoffs[s1][s2][s3][a][3];
      
      // 後悔 ＝「たられば利得」 ー 「実際の利得」
      float regret = hypotheticalPayoff - actualPayoffs[p];
      cumulativeRegrets[p][a] += regret;
    }
  }
}

// 確率が収束していく様子を描画するグラフ
void drawGraph() {
  int graphWidth = width - 250;
  int graphHeight = height - 100;
  
  // グラフの枠線
  stroke(180);
  fill(255);
  rect(50, 50, graphWidth, graphHeight);
  
  // 目盛り線 (0.0, 0.5, 1.0)
  stroke(220);
  line(50, 50 + graphHeight/2, 50 + graphWidth, 50 + graphHeight/2);
  fill(100);
  textSize(12);
  text("1.0", 25, 55);
  text("0.5", 25, 55 + graphHeight/2);
  text("0.0", 25, 55 + graphHeight);
  text("Probability of Strategy 0 over Time", 50, 35);

  // プレイヤーごとの色定義
  int[] colors = { color(230, 50, 50), color(50, 150, 50), color(50, 50, 230), color(200, 150, 0) };
  
  // 履歴プロット
  noFill();
  strokeWeight(2);
  for (int p = 0; p < 2; p++) {
    stroke(colors[p]);
    beginShape();
    for (int i = 0; i < strategyHistory.size(); i++) {
      float x = 50 + i*10;
      float y = 50 + graphHeight * (1.0 - strategyHistory.get(i)[p]);
      vertex(x, y);
    }
    endShape();
  }
  strokeWeight(1);
}

// 画面右側に現在の収束値をテキスト表示するパネル
void drawStatusPanel(float[] currentEquilibrium) {
  int panelX = width - 180;
  int[] colors = { color(230, 50, 50), color(50, 150, 50), color(50, 50, 230), color(200, 150, 0) };
  
  fill(0);
  textSize(16);
  text("Current Status", panelX, 70);
  textSize(12);
  text("(Equilibrium Probabilities)", panelX, 90);
  
  for (int p = 0; p < NUM_PLAYERS; p++) {
    int y = 140 + p * 80;
    
    // カラーマーカー
    fill(colors[p]);
    noStroke();
    rect(panelX, y - 15, 12, 12);
    
    // テキスト表示
    fill(0);
    textSize(14);
    text("Player " + (p+1), panelX + 20, y - 4);
    textSize(13);
    fill(80);
    text("Strategy 0: " + nf(currentEquilibrium[p] * 100, 1, 1) + "%", panelX + 20, y + 16);
    text("Strategy 1: " + nf((1.0 - currentEquilibrium[p]) * 100, 1, 1) + "%", panelX + 20, y + 34);
  }
}
