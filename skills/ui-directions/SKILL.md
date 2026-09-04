---
name: ui-directions
description: Use when the user says 「デザインパターン提案して」「UI の案いくつか」「どんな見た目がいいか迷ってる」, when a screen family (一覧/設定/詳細) needs a shared visual pattern, or before building a new area's screens.
---

# UI Directions

複数の UI 方向性を Claude Design キャンバス上に artboard として並べて比較し、1 つ選んでから rules / primitive に落とし込む workflow。

## 手順

1. **実値を先に集める（記憶で設計しない）**
   - デザイントークン: `src/styles.css` の `@theme`（tailwind theme）
   - primitive の実装: `src/components/*/variants.ts` と card / badge / button / field 本体
   - 依頼に一番近い既存画面（header、sidebar、table）から正確な class / px を抜き出す
   - ユーザーが渡した legacy / 参考スクリーンショットは「構造の参考」としてのみ扱う（配色や角丸まで模倣しない）

2. **軸を明示して 2〜3 方向を命名する**
   - 例: パネル踏襲 / フィルターバー+テーブル / 高密度+条件サイドパネル
   - 各方向に狙いとトレードオフを添える。有力候補を 1 つ選びつつ、他の方向も誠実に主張する（弱く見せて消化試合にしない）
   - 有力候補には「別の画面種別への適用例」artboard を 1 つ追加する（例: 一覧が主題なら設定フォームを 1 枚）。これで方向性が単発画面向けでなく汎用パターンであることを示す

3. **artboard の作成は `design-mockup-author` subagent に委譲する**
   - 渡すもの: トークン表（hex / px）、component anatomy、サンプルデータ（実際のカラム名・現実的な行データ）、各方向の spec、全 artboard で同一に複製する sidebar / header の内容、frame サイズ 1440×900、フォーマット規約への参照（`design` skill の SKILL.md「Authoring the seed .dc.html」「Quick syntax card」節）
   - 成果物として要求するもの: 有力候補 = `Main.dc.html`、他方向 = `DirectionA.dc.html` / `DirectionB.dc.html` / …、各方向の上に狙い・トレードオフの注釈を持つ `canvas.json`

4. **`design` skill のヘルパーで組み立てる**
   - `/design` を呼んで base directory を取得し、`seed-canvas.mjs --template … --out <name>.html --title … --artboard … --canvas canvas.json` を実行後 `--check`
   - ファイル名・title は検討中のデザイン名にする。`design.html` のような汎用名にしない

5. **公開前に必ず目視する**
   - Chrome extension は `file://` をブロックするため、seed した html のディレクトリで `python3 -m http.server <port>` を立て `http://localhost:<port>/<name>.html` を開く
   - artboard は遅延マウントされ、サムネイルはしばらく白いままなので 10 秒ほど待つ
   - 各 artboard を展開（▷）してスクリーンショットし、明らかな不備（例: ボタンの折り返し → `white-space:nowrap; flex-shrink:0` を追加、ヘッダー文言の誤り）は `.dc.html` を直接編集して re-seed する
   - 確認後は必ず http server を kill する

6. **`design` skill の指示どおりに公開する**
   - contract pin、`artifact-capabilities` の roster から選んだ capabilities、favicon を設定
   - 公開後、リンクと各方向 1 行ずつの説明をユーザーに渡す

7. **決定後の再構成とコード化**
   - `pages` を使って re-seed する: page-1「採用: X」に Main + 適用例 + 決定理由（対象・型）のメモ、page-2「検討した案」に他の方向とそのメモ
   - 同じ path で republish する
   - コード化: `.claude/rules/<area>-screens.md` に CORRECT/WRONG 付きのレシピ、判断基準の表、例外を書く
   - primitive 昇格は実際の利用箇所が 2 つ以上あるものだけに限る。増やす前にユーザーに確認する（例: 今回は PageHeader は昇格、DataTable / Pagination は見送り）

## 落とし穴

- `file://` は Chrome extension でブロックされる。必ず http server 経由で見る
- canvas のサムネイルはマウントされるまで白紙。焦って公開前に判断しない
- 注釈の y offset は目安 -160 だと name strip の上に来る。artboard に重ならない位置を確認する
- sidebar / header の markup は全 artboard でバイト単位まで同一にする。手でコピーせず、小さな build script で生成させる
- JPEG スクリーンショットはコントラストの低い文字を潰して見せることがある。怪しい箇所は JS で computed color を確認する
