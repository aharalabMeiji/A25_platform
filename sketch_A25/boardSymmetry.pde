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
