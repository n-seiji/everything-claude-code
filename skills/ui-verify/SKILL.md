---
name: ui-verify
description: Use when the user says 「動作確認して」「スクショ撮って」「実機で見て」, after any UI change before reporting it done, or when writing a PR's 動作確認 section.
---

# UI Verify

実行中の web app を `ui-verifier` subagent 経由で実 Chrome 上で動作確認し、実測結果を PR / 報告に残す workflow。

## 使うとき / 使わないとき

- レイアウト崩れ、フォーカス移動、ダイアログの開閉、ルーティング遷移など「実際に描画・操作して初めてわかること」に使う
- unit test / component test の代替ではない。ロジックの正しさは既存テストで担保し、このスキルは「画面で見える事実」の確認に使う

## 環境準備

1. dev server がどの worktree を serve すべきか確認する（CORS でオリジンが絞られている場合、ポートを保持できるのは 1 worktree だけ）
2. 既存の dev server を停止し、対象 worktree から background で起動する。ログは scratchpad に出す
3. 確認後は元の worktree の dev server に戻し、その旨を報告に明記する
4. 確認のために branch 切り替えや DB row の変更が必要な場合、切り替えた事実と元に戻したことを報告に残す

## `ui-verifier` subagent への依頼内容

以下を numbered list で明記して依頼する。

1. URL・ポート
2. ログイン状態（済みであること）
3. 対象 worktree / branch
4. チェック項目（番号付き）と、各項目の期待結果・測定すべき JS の事実（`getBoundingClientRect` 等）

## PR へのスクリーンショット添付

1. 接続済み Chrome で対象 PR ページを開く
2. `find` で **new comment フォームに属する** `input[type=file]` を特定する（PR 本文編集フォームのものと混同しない）
3. `file_upload` でアップロードし、「Uploading」の文字が消えるまで待つ
4. `javascript_tool` でその textarea から `<img ... src="https://github.com/user-attachments/assets/...">` の行を読み取る
5. textarea 内のそれらの行を消す（コメントは送信しない）
6. 取得した画像 URL を使い、`gh pr comment --body-file` / `gh pr edit --body-file` でコメント・本文を投稿する
7. tabs group を見失うことがあるため、途中で失敗したら `tabs_context_mcp {createIfEmpty: true}` を再実行する

## PR への報告フォーマット

- 動作確認テーブル（`項目 / 結果 / 実測値`）
- スクリーンショット
- 自動化した確認 / 手動で確認した項目の内訳
