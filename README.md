[English](#English)

# A25_platform
AI研究のためのアタック25のシミュレータ

## このシステムについて

本システムは、「パネルクイズアタック２５」において、クイズ部分を省略し、ランダムな順番で4名のプレイヤーがパネルをとるというボードゲームだけに着目して、UCBアルゴリズムによるモンテカルロ法のAIと、UCTアルゴリズムによるモンテカルロ木探索のAIを提供するものです。使用言語は 
processingです。内容は２つの部分からなり、一つはAIと人間によるゲームをおこなえる「ゲームモード」、もう一つは特定の盤面においてAIによる解析を行う「シミュレーションモード」からなっています。

最新リリースはA25_251002版 [https://github.com/aharalabMeiji/A25_platform/releases/tag/251002] です。processing4 で実行することができます。

このシステムの著者は阿原一志（明治大学）と浜向直（北海道大学）です。

## このシステムについての強いお願い

1. 本システムはAI研究のために開発されたものです。本システムを著者に無断で商業目的に利用することはできません。
2. パネルクイズアタック２５、またはそれに類する番組などにおいて、本システムを（番組などの運営者の決めたルールを逸脱するような）不正利用はしないでください。また、不正利用をした者に何らかの損害があったとしても、著者はその責任を取りません。
3. 本システムはＵＣＢやＵＣＴという、ゲーム情報学において既知のアルゴリズムを本ゲームに適用したものです。したがってＡＩの着手を最善であることを保証しません。本システムの計算結果がすべて正しいわけではありませんし、本システムの計算結果と異なる見解がすべて誤っているわけでもありません。
4. ブログなどのウェブ上の記事や、ユーチューブなどの動画において、本システムの画面・本システムによる計算結果を引用する場合には、このページ
https://github.com/aharalabMeiji/A25_platform/tree/main
のＵＲＬを必ず引用してください。引用のない使用はできません。
5. 本システムはGNU General Public License v3.0を宣言しています。システムの改変や２次利用については、このライセンス条項に従います。

## このシステムについてのリクエスト

本システムについて、不具合がありましたら報告していただけるとありがたいです。また、システムの中には作りかけの部分もあり、随時内容を追加する予定です。

## ＵＣＴによるＡＩについて

深さ４と深さ５の2種類で、幅優先探索をするプログラムです。最高確率のものを限定するだけでしたら、統計的に有意になったところで打ち切るのがよく、ｗCと書いたオプションでは、この途中打ち切りが行われています。ゲームモードにあるUCTは深さ４（４手読み）打ち切りアリ（D4wC)の版です。

UCT（4手読み）はUCB（1手読み）より強くなければいけませんが、UCT一人とUCB3人で1000回対戦させたところ約27パーセントの勝率でした。

## English

# A25_platform
AI Simulator for Attack 25 boardgame

## About This System

This system focuses solely on the board game aspect of "Panel Quiz Attack 25," omitting the quiz portion and having four players take panels in random order. It provides AI based on the Monte Carlo method using the UCB algorithm and AI based on Monte Carlo tree search using the UCT algorithm. The language used is 
processing. The content consists of two parts: the "game mode," where games are played between AI and humans, and the "simulation mode," where AI analysis is performed on specific board layouts.

The latest release is version A25_251002 [https://github.com/aharalabMeiji/A25_platform/releases/tag/251002]. It can be run on Processing 4.

The authors of this system are Kazushi Ahara (Meiji University) and Nao Hamamuki (Hokkaido University).

## Important Request Regarding This System

1. This system was developed for AI research purposes. Commercial use is prohibited without the author's permission.
2. Do not misuse this system in ways that violate the program operators' rules on Panel Quiz Attack 25 or similar programs. The author will not be held responsible for any damages caused by those who misuse the system.
3. This system uses well-known game-theoretic methods, such as UCB and UCT. It does not promise that the AI's moves are perfect. The AI's calculations may be wrong, and different views could still be right.
4. When referencing this system's screens or calculation results in web articles, such as blogs, or in videos, such as YouTube, you must include the URL of this page: https://github.com/aharalabMeiji/A25_platform/tree/main
Unauthorized use without proper attribution is prohibited.
5. This system declares the GNU General Public License v3.0. Modification or secondary use of the system must comply with the terms of this license.

## Requests Regarding This System

If you happen to encounter any issues with this system, please let them know. Additionally, some parts of the system are still under development, and we plan to add content as needed.

## About the AI Using UCT

This program performs a breadth-first search at depths 4 and 5. If the goal is to select the move with the highest probability, it is best to terminate the search once a statistically significant result is reached. The option labeled wC implements this early termination. The UCT option in the game mode is the depth 4 (4-move lookahead) version with termination enabled (D4wC).

UCT (4-move lookahead) must be stronger than UCB (1-move lookahead). However, when pitting one UCT player against three UCB players in 1,000 matches, the UCT player's win rate was approximately 27%.
