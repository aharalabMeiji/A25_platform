// ------------------------------------------------------------
// board[0]  board[1]  board[2]  board[3]  board[4]
// board[5]  ...
// ...
// board[20] ...                          board[24]
//
// 戻り値:
// 対称性によって同値になるマスの集合。
// 現在は「要素数2以上」の同値類だけを返す。
// singleton も必要なら INCLUDE_SINGLETONS = true にする。
// ------------------------------------------------------------

boolean INCLUDE_SINGLETONS = false;


ArrayList<int[]> symmetryClasses(int[] board) {

  ArrayList<Integer> validSymmetries = new ArrayList<Integer>();

  // 0～7 の8種類の正方形の対称変換について、
  // board を変えないものだけを採用する
  for (int s = 0; s < 8; s++) {
    if (isBoardSymmetric(board, s)) {
      validSymmetries.add(s);
    }
  }

  ArrayList<int[]> result = new ArrayList<int[]>();
  boolean[] used = new boolean[25];

  for (int i = 0; i < 25; i++) {

    if (used[i]) continue;

    ArrayList<Integer> orbit = new ArrayList<Integer>();

    // i を有効な対称変換で動かした先を集める
    for (int k = 0; k < validSymmetries.size(); k++) {
      int s = validSymmetries.get(k);
      int j = transformIndex(i, s);

      if (!orbit.contains(j)) {
        orbit.add(j);
      }
    }

    // 小さい番号順に並べる
    java.util.Collections.sort(orbit);

    // 同値類に属するマスを使用済みにする
    for (int k = 0; k < orbit.size(); k++) {
      used[orbit.get(k)] = true;
    }

    // 現在は singleton は出力しない
    if (orbit.size() >= 2 || INCLUDE_SINGLETONS) {

      int[] c = new int[orbit.size()];

      for (int k = 0; k < orbit.size(); k++) {
        c[k] = orbit.get(k);
      }

      result.add(c);
    }
  }

  return result;
}


// ------------------------------------------------------------
// symmetry が board 全体を不変にするか
// ------------------------------------------------------------
boolean isBoardSymmetric(int[] board, int symmetry) {

  for (int i = 0; i < 25; i++) {

    int j = transformIndex(i, symmetry);

    if (board[i] != board[j]) {
      return false;
    }
  }

  return true;
}


// ------------------------------------------------------------
// マス番号 i を、8種類の正方形の対称変換で移す
//
// symmetry
// 0 : 恒等変換
// 1 : 左右反転
// 2 : 上下反転
// 3 : 180度回転
// 4 : 90度回転
// 5 : 270度回転
// 6 : 左上－右下の対角線で反転
// 7 : 右上－左下の対角線で反転
// ------------------------------------------------------------
int transformIndex(int i, int symmetry) {

  int row = i / 5;
  int col = i % 5;

  int newRow = row;
  int newCol = col;

  switch(symmetry) {

  case 0:    // 恒等
    newRow = row;
    newCol = col;
    break;

  case 1:    // 左右反転
    newRow = row;
    newCol = 4 - col;
    break;

  case 2:    // 上下反転
    newRow = 4 - row;
    newCol = col;
    break;

  case 3:    // 180度回転
    newRow = 4 - row;
    newCol = 4 - col;
    break;

  case 4:    // 90度回転
    newRow = col;
    newCol = 4 - row;
    break;

  case 5:    // 270度回転
    newRow = 4 - col;
    newCol = row;
    break;

  case 6:    // 左上－右下対角線
    newRow = col;
    newCol = row;
    break;

  case 7:    // 右上－左下対角線
    newRow = 4 - col;
    newCol = 4 - row;
    break;
  }

  return newRow * 5 + newCol;
}

boolean isSymmetricPosition(int[] board, int i, int j) {

  // 範囲外なら false
  if (i < 0 || i >= 25 || j < 0 || j >= 25) {
    return false;
  }

  // 8種類の対称変換を調べる
  for (int s = 0; s < 8; s++) {

    // この対称変換が盤面 board を保ち、
    // かつ i が j に移るなら true
    if (isBoardSymmetric(board, s)
        && transformIndex(i, s) == j) {
      return true;
    }
  }

  return false;
}
//対称性を考慮した代表番号を求める
int canonicalMove(int[] board, int move) {

  if (move==25) return 25;
  int representative = move;

  // boardを保つ8種類の対称変換を調べる
  for (int s = 0; s < 8; s++) {

    if (isBoardSymmetric(board, s)) {

      int j = transformIndex(move, s);

      // 同値類の中で最小の番号を代表番号とする
      if (j < representative) {
        representative = j;
      }
    }
  }

  return representative;
}

//Maxn と Paranoid の出現頻度を、対称性を考慮して数える
// 26(pass)も考慮に入れる。
ArrayList<duplicate> countSymmetricMoves(
  int[] board,
  int[] maxnMove,
  int[] paraMove
) {

  int[] maxnCount = new int[26];
  int[] paraCount = new int[26];

  // Maxn
  for (int i = 0; i < maxnMove.length; i++) {

    int move = maxnMove[i];

    if (move < 0 || move >= 26) continue;

    int representative = canonicalMove(board, move);

    maxnCount[representative]++;
  }

  // Paranoid
  for (int i = 0; i < paraMove.length; i++) {

    int move = paraMove[i];

    if (move < 0 || move >= 26) continue;

    int representative = canonicalMove(board, move);

    paraCount[representative]++;
  }


  ArrayList<duplicate> result =
    new ArrayList<duplicate>();

  // 少なくとも一方で出現した同値類を登録
  for (int i = 0; i < 26; i++) {

    if (maxnCount[i] > 0 || paraCount[i] > 0) {

      result.add(
        new duplicate(
          i,
          maxnCount[i],
          paraCount[i]
        )
      );
    }
  }

  return result;
}

// 確認用の表示関数
void printSymmetricDistribution(
  int[] board,
  int[] maxnMove,
  int[] paraMove
) {

  ArrayList<duplicate> list =
    countSymmetricMoves(board, maxnMove, paraMove);

  println("representative : Maxn , Paranoid");

  for (duplicate d : list) {

    float pm =
      (float)d.maxnScore / maxnMove.length;

    float pp =
      (float)d.paraScore / paraMove.length;

    println(
      str(d.number+1)
      + " : "
      + d.maxnScore + " (" + pm + ")"
      + " , "
      + d.paraScore + " (" + pp + ")"
    );
  }
}
String textSymmetricDistribution(
  int[] board,
  int[] maxnMove,
  int[] paraMove
) {
  String ret="";
  ArrayList<duplicate> list =
    countSymmetricMoves(board, maxnMove, paraMove);

  println("representative : Maxn , Paranoid");

  for (duplicate d : list) {

    float pm =
      (float)d.maxnScore / maxnMove.length;

    float pp =
      (float)d.paraScore / paraMove.length;

    ret += (
      str(d.number+1)
      + "," + d.maxnScore + "," + pm + ","
      + d.paraScore + "," + pp + ","
    );
  }
  return ret;
}

//確率分布としての距離
float symmetricDistributionDistance(
  int[] board,
  int[] maxnMove,
  int[] paraMove
) {

  ArrayList<duplicate> list =
    countSymmetricMoves(board, maxnMove, paraMove);

  float sum = 0.0;

  for (duplicate d : list) {

    float p =
      (float)d.maxnScore / maxnMove.length;

    float q =
      (float)d.paraScore / paraMove.length;

    sum += abs(p - q);
  }

  return 0.5 * sum;
}
