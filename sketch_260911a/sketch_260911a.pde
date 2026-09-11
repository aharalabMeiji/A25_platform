int[] maxnMove = {
  1,1,2,3,3,4,5,5,5,6,
  6,3,4,6,6,7,1,2,8,9
};

int[] paraMove = {
  5,2,3,6,5,7,8,6,5,1,
  2,3,4,6,2,3,7,6,1,7
};


class duplicate {
  int number;
  int maxnScore;
  int paraScore;

  duplicate(int n, int m, int p) {
    number = n;
    maxnScore = m;
    paraScore = p;
  }
}


void setup() {
  ArrayList<duplicate> result = countDuplicates(maxnMove, paraMove);

  for (duplicate d : result) {
    println("[" + d.number + ", "
                + d.maxnScore + ", "
                + d.paraScore + "]");
  }
}


ArrayList<duplicate> countDuplicates(int[] maxnMove, int[] paraMove) {

  ArrayList<duplicate> result = new ArrayList<duplicate>();

  // すでに調べた整数を記録する
  ArrayList<Integer> checked = new ArrayList<Integer>();

  // maxnMove に現れる数を調べる
  for (int i = 0; i < maxnMove.length; i++) {
    int n = maxnMove[i];

    if (!checked.contains(n)) {
      addDuplicateIfNecessary(n, maxnMove, paraMove, result);
      checked.add(n);
    }
  }

  // paraMove にしか現れない数も調べる
  for (int i = 0; i < paraMove.length; i++) {
    int n = paraMove[i];

    if (!checked.contains(n)) {
      addDuplicateIfNecessary(n, maxnMove, paraMove, result);
      checked.add(n);
    }
  }

  return result;
}


// 1つの整数 n について出現回数を数える
void addDuplicateIfNecessary(
  int n,
  int[] maxnMove,
  int[] paraMove,
  ArrayList<duplicate> result
) {

  int maxnCount = 0;
  int paraCount = 0;

  for (int i = 0; i < maxnMove.length; i++) {
    if (maxnMove[i] == n) {
      maxnCount++;
    }
  }

  for (int i = 0; i < paraMove.length; i++) {
    if (paraMove[i] == n) {
      paraCount++;
    }
  }

  // ------------------------------------------------
  // 「重複」の判定条件。
  // 現在は40個全体で2回以上出たものだけ採用する。
  // 後で仕様を変える場合は、ここだけ変更すればよい。
  // ------------------------------------------------
  //if (maxnCount + paraCount >= 2) {
    result.add(new duplicate(n, maxnCount, paraCount));
  //}
}
