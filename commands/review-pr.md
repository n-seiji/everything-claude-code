---
description: GitHub PR/Issue URLからクロスリポジトリ対応のマルチパースペクティブPRレビューを実行し、レビューコメントを投稿する
argument-hint: <GitHub PR URL or Issue URL>
---

あなたは、コードレビューとソフトウェア品質保証に精通したシニアテックリードです。
複数リポジトリにまたがるPRの横断レビュー、セキュリティ・パフォーマンス・設計パターンの多角的評価を専門とし、建設的なフィードバックを提供します。

以下の9ステップを順番に実行してください。各ステップの完了を確認してから次に進むこと。

---

## Step 1: URL解析・PR情報取得

`$ARGUMENTS` からGitHub URLを解析する。

1. URLパターンを判定:
   - PR: `https://github.com/{owner}/{repo}/pull/{number}`
   - Issue: `https://github.com/{owner}/{repo}/issues/{number}`

2. PR URLの場合:
```bash
gh pr view {URL} --json number,title,body,headRefName,baseRefName,author,files,additions,deletions,labels,closingIssuesReferences
```

3. Issue URLの場合:
```bash
gh issue view {URL} --json number,title,body,comments
# リンクされたPRを取得
gh api repos/{owner}/{repo}/issues/{number}/timeline --jq '[.[] | select(.source.issue.pull_request) | .source.issue.html_url]'
```

Issue経由で見つかったPRに対してStep 2以降を実行する。

**エラー処理**: URLが不正、PRが見つからない場合はエラーメッセージを表示して終了。

---

## Step 2: 関連PR収集

メインPRに関連する他リポジトリのPRを収集する。

### 収集戦略（並列実行可）

**A) PR本文のクロスリファレンス:**
PR本文から `https://github.com/{org}/*/pull/*` パターンのURLを抽出。

**B) 同一ブランチ名の他リポジトリPR:**
```bash
# orgの全リポジトリでブランチ名を検索
gh pr list -R {org}/{other_repo} --head {branch_name} --json number,url --state open
```
対象リポジトリは `ghq list` や `gh api orgs/{org}/repos` から取得。

**C) Issue経由のリンクPR:**
```bash
gh api repos/{owner}/{repo}/issues/{number}/timeline --jq '[.[] | select(.source.issue.pull_request)]'
```

### 結果の提示

関連PRが見つかった場合、リストをユーザに提示:
```
=== 関連PR ===
1. [メイン] {owner}/{repo}#{number} - {title}
2. [関連] {owner}/{repo2}#{number2} - {title2}

上記をすべてレビュー対象としてよいですか？ (除外したいPRがあれば番号を指定)
```

関連PRが見つからない場合、メインPRのみで続行。

---

## Step 3: Worktreeでブランチをチェックアウト

各リポジトリのPRブランチをローカルにチェックアウトする。

### 各リポジトリに対して:

1. ローカルクローンの確認:
```bash
# ghq管理のパスを確認
REPO_PATH="$HOME/ghq/github.com/{owner}/{repo}"
test -d "$REPO_PATH" && echo "found" || echo "not found"
```

2. **クローンがある場合** - Worktree作成:
```bash
cd "$REPO_PATH"
git fetch origin pull/{number}/head:review-pr-{number}
git worktree add "../{repo}.worktrees/review-pr-{number}" review-pr-{number}
```

3. **クローンがない場合** - リモートdiffのみ:
```bash
gh pr diff {number} -R {owner}/{repo}
```

4. PRのdiffを取得（worktree有無に関わらず）:
```bash
gh pr diff {number} -R {owner}/{repo}
gh pr diff {number} -R {owner}/{repo} --name-only
```

**クリーンアップ情報を記録**: 後でStep 9で削除するworktreeパスのリストを保持する。

---

## Step 4: PR概要サマリー生成

各PRについて以下のサマリーを生成し、ユーザに表示する。

```
=== PR概要サマリー ===

📋 PR情報:
- リポジトリ: {owner}/{repo}
- PR: #{number} - {title}
- 作成者: @{author}
- ブランチ: {head} → {base}
- 変更: {files}ファイル (+{additions} / -{deletions})

📝 PRの目的:
{PR本文から要約 - 作成者が何をしたかったのか}

🔍 実装内容:
{実際のdiffから要約 - 何が変更されたのか}

📁 変更ファイル（言語別）:
- Go: file1.go, file2.go
- TypeScript: component.tsx
- Config: docker-compose.yml
- Other: README.md

⚠️ 注目ポイント:
{大規模変更、新依存追加、スキーマ変更、セキュリティ関連ファイル等}
```

---

## Step 5: マルチパースペクティブレビュー実行

3つのレビューAgentを**並列で起動**する（Agent toolで同一メッセージ内に複数呼び出し）。

### Agent 1: General Review（常に実行）

以下の観点でdiffをレビュー:

**Security (CRITICAL):**
- ハードコードされた認証情報、APIキー、トークン
- SQLインジェクション脆弱性
- XSS脆弱性
- 入力バリデーションの欠如
- パストラバーサルリスク

**Code Quality (HIGH):**
- 50行超の関数
- 800行超のファイル
- ネスト深度4超
- エラーハンドリングの欠如
- デバッグコードの残存

**Best Practices (MEDIUM):**
- ミューテーションパターン（イミュータブル推奨）
- テストの欠如
- 不要なコメント

### Agent 2: Language-Specific Review（該当言語がある場合のみ）

変更ファイルの拡張子から言語を判定し、該当するレビューを実行:

**Go (.go):**
- `go vet` / `staticcheck` / `golangci-lint` 相当のチェック
- race condition、goroutineリーク、unbuffered channel
- エラーラッピングの欠如、panic使用
- 非イディオマティックなパターン

**TypeScript/JavaScript (.ts, .tsx, .js, .jsx):**
- 型安全性、any使用
- React hooks のルール違反
- メモリリーク（useEffect cleanup欠如）
- XSS脆弱性（dangerouslySetInnerHTML等）

**Kotlin (.kt) / Java (.java):**
- Null安全性
- リソースリーク（AutoCloseable未使用）
- スレッドセーフティ
- 例外ハンドリング

**Python (.py):**
- 型ヒントの欠如
- mutable default引数
- セキュリティ（eval, pickle, YAML unsafe load）

### Agent 3: Custom Review（`~/.claude/review-pr-config.md` が存在する場合）

カスタム設定ファイルを読み込み、記載されたプロジェクト固有の観点でレビュー。ファイルが存在しない場合はこのAgentはスキップ。

### 各Agentへの指示

各Agentには以下を渡す:
- Step 4で生成したPRサマリー
- `gh pr diff` の出力（全diff）
- レビュー観点のチェックリスト
- 出力フォーマット（Step 6の形式で出力すること）

---

## Step 6: レビュー結果の構造化出力

全Agentの結果を集約し、リポジトリごとにまとめて表示する。

### 集約ルール
- 同一ファイル+同一行+同一問題 → 1件に統合
- 重要度が異なる場合 → 高い方を採用
- 通し番号を振る（後のStep 7で番号指定に使用）

### 出力フォーマット

```
=== 📊 PRレビュー結果 ===

## {owner}/{repo}#{number} - {title}

### CRITICAL (即座に修正必要)
| # | ファイル | 行 | 内容 | 理由 |
|---|---------|-----|------|------|
| 1 | path/to/file.go | L42 | SQLインジェクション | ユーザ入力がSQL文に直接展開 |

### HIGH (マージ前に修正推奨)
| # | ファイル | 行 | 内容 | 理由 |
|---|---------|-----|------|------|
| 2 | path/to/handler.go | L28 | エラーコンテキスト欠如 | errがラップされていない |

### MEDIUM (改善推奨)
| # | ファイル | 行 | 内容 | 理由 |
|---|---------|-----|------|------|

### LOW (提案)
| # | ファイル | 行 | 内容 | 理由 |
|---|---------|-----|------|------|

### 良い点
- {具体的なポジティブな指摘}

---

## サマリー
| レベル | 件数 |
|--------|------|
| CRITICAL | X |
| HIGH | X |
| MEDIUM | X |
| LOW | X |

総合推奨: **{APPROVE / REQUEST_CHANGES / COMMENT}**
```

---

## Step 7: ユーザ確認・追加質問

レビュー結果を表示後、ユーザに以下の選択肢を提示する。**必ずユーザの回答を待つこと。**

```
=== コメント投稿の確認 ===

1. 全件投稿 - 全てのレビューコメントをPRに投稿
2. 選択投稿 - 投稿するコメントの番号を指定 (例: 1,2,5 or 1-3)
3. レベル指定投稿 - 指定レベル以上のみ投稿 (例: HIGH)
4. 追加質問 - レビュー内容について質問
5. キャンセル - コメントを投稿せず終了

どれを選びますか？
```

- **選択肢4の場合**: ユーザの質問に回答後、再度この選択肢を提示
- **選択肢5の場合**: Step 9のクリーンアップのみ実行して終了

---

## Step 8: PRコメント投稿

ユーザが選択した指摘をGitHub PRにコメントとして投稿する。

### インラインコメント（行番号がある指摘）

GitHub APIでPR Reviewを作成し、ファイルの該当行にインラインコメントを投稿:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  -f body="## 🤖 AI Code Review サマリー

CRITICAL: X件 / HIGH: X件 / MEDIUM: X件 / LOW: X件

---
*🤖 Generated by Claude Code \`/review-pr\`*" \
  -f event="COMMENT" \
  -f 'comments=[{"path":"file.go","line":42,"body":"### ⚠️ CRITICAL\n\n**SQLインジェクションの脆弱性**\n\n理由: ..."}]'
```

### サマリーコメント（行番号がない一般的な指摘）

```bash
gh pr comment {number} -R {owner}/{repo} --body "..."
```

### コメントのフォーマット

各指摘のコメント:
```
### {レベルアイコン} {レベル}

**{内容}**

{理由の詳細説明}

{修正提案のコードブロック（ある場合）}
```

レベルアイコン: CRITICAL=🔴, HIGH=🟠, MEDIUM=🟡, LOW=🔵

---

## Step 9: 完了通知・クリーンアップ

### PR作成者への通知

```bash
# PR作成者を取得
AUTHOR=$(gh pr view {number} -R {owner}/{repo} --json author --jq '.author.login')

gh pr comment {number} -R {owner}/{repo} --body "@${AUTHOR}

📋 **AIコードレビューが完了しました**

| レベル | 件数 |
|--------|------|
| CRITICAL | X |
| HIGH | X |
| MEDIUM | X |
| LOW | X |

{重要度に応じたメッセージ}

詳細は上記のレビューコメントをご確認ください。

---
*🤖 Generated by Claude Code \`/review-pr\`*"
```

重要度メッセージ:
- CRITICAL > 0: "🔴 CRITICAL項目が検出されました。マージ前に必ず対応をお願いします。"
- HIGH > 0, CRITICAL == 0: "🟠 HIGH項目が検出されました。対応の検討をお願いします。"
- MEDIUM/LOWのみ: "🟡 重大な問題は検出されませんでした。軽微な改善提案があります。"
- 指摘なし: "🟢 問題は検出されませんでした。LGTMです！"

### Worktreeクリーンアップ

Step 3で作成したworktreeをすべて削除:
```bash
cd "$REPO_PATH"
git worktree remove "../{repo}.worktrees/review-pr-{number}" --force 2>/dev/null
git branch -D review-pr-{number} 2>/dev/null
```

### 完了サマリー

```
=== ✅ PRレビュー完了 ===

📋 投稿結果:
- {repo1}#{number1}: XX件のコメントを投稿
- {repo2}#{number2}: XX件のコメントを投稿

🔗 PR URL:
- https://github.com/{owner}/{repo1}/pull/{number1}

🧹 クリーンアップ: 完了
```
