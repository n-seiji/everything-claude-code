# everything-coding-agent

[English](README.md) | 日本語

この文書は README.md の日本語版。内容が食い違う場合は英語版を正とする。

Claude Code と Codex 向けの plugin。日々のコーディング作業のための agent、skill、slash command、hook をまとめて提供する: 計画立案、TDD、コード・PR レビュー、ビルドエラー修正、セキュリティレビュー、UI 検証など。

## Claude Code へのインストール

```
/plugin marketplace add n-seiji/everything-coding-agent
/plugin install everything-coding-agent@n-seiji
```

最新版に更新するには `/plugin marketplace update n-seiji` を実行し、続けて `/plugin update everything-coding-agent@n-seiji` を実行する（または再インストールする）。

## Codex へのインストール

Codex は `.agents/plugins/marketplace.json` を読み込み、これはローカルの plugin パス `plugins/everything-coding-agent` を指す。その plugin の `.codex-plugin/plugin.json` は `skills` に自身の `skills/` ディレクトリを指定しているため、Codex はそこからワークフローを読み込む。

```
codex plugin marketplace add n-seiji/everything-coding-agent
codex plugin add everything-coding-agent@n-seiji
```

ローカルチェックアウトを使う場合は、その絶対パスを marketplace として追加し、同じ方法でインストールする。

更新するには: `codex plugin marketplace upgrade n-seiji` を実行し、その後 plugin を削除して再追加する（`codex plugin remove everything-coding-agent@n-seiji` の後に `codex plugin add everything-coding-agent@n-seiji`）。

Codex はトップレベルの `commands/` ディレクトリを読み込まない。同じワークフローは Codex 向けに `plugins/everything-coding-agent/skills/<name>/SKILL.md` として提供されている。

## 構成

| Path | Contents |
|------|----------|
| `commands/` | Claude Code の slash command |
| `agents/` | Claude Code の subagent |
| `skills/` | Claude Code の skill |
| `plugins/everything-coding-agent/skills/` | command をミラーした Codex 向け skill |
| `hooks/hooks.json` + `scripts/hooks/` | hook とその実装 |
| `.claude-plugin/` | Claude Code の plugin manifest と marketplace listing |
| `.codex-plugin/` and `.agents/plugins/` | Codex の plugin と marketplace manifest。ルートの `.codex-plugin/plugin.json` は、marketplace ファイルなしに Codex がこのリポジトリ自体を plugin としてインストールできるようにするもので、`plugins/everything-coding-agent/` 配下のコピーが marketplace から使われる方である。 |

メンテナンス上のルール: `skills/everything-coding-agent/` と `plugins/everything-coding-agent/skills/everything-coding-agent/` は byte-identical を保つこと。`version` フィールドは 3 つの manifest（`.claude-plugin/plugin.json`、`.codex-plugin/plugin.json`、`plugins/everything-coding-agent/.codex-plugin/plugin.json`）すべてで同時に上げること。

## Commands

| Command | Description |
|---------|-------------|
| `/build-fix` | ビルドエラーと型エラーを段階的に修正し、各修正後にビルドを検証する。 |
| `/code-review` | 未コミットの変更に対する、セキュリティと品質の包括的なレビュー。 |
| `/cp` | commit してリモートに push する。 |
| `/cpp` | commit、push し、draft PR を開く。 |
| `/draft-pr` | commit、現在のブランチの push、draft PR の作成を一つの流れで行う。 |
| `/e2e` | Playwright で end-to-end テストを生成・実行する。テストジャーニーを作成し、テストを実行し、スクリーンショット・動画・トレースを取得してアーティファクトをアップロードする。 |
| `/go-build` | Go のビルドエラー、go vet の警告、linter の問題を段階的に修正する。最小限で surgical な修正のために go-build-resolver agent を呼び出す。 |
| `/go-review` | イディオマティックなパターン、並行処理の安全性、エラーハンドリング、セキュリティに関する Go コードの包括的なレビュー。go-reviewer agent を呼び出す。 |
| `/go-test` | Go の TDD ワークフローを強制する。テーブル駆動テストを先に書き、その後実装する。`go test -cover` で 80% 以上のカバレッジを確認する。 |
| `/plan` | 要件を整理し直し、リスクを評価し、段階的な実装計画を作成する。コードに触れる前に確認を待つ。 |
| `/python-review` | PEP 8 準拠、型ヒント、セキュリティ、Pythonic なイディオムに関する Python コードの包括的なレビュー。python-reviewer agent を呼び出す。 |
| `/refactor-clean` | デッドコードを特定して安全に削除し、各削除の前後でテストを検証する。 |
| `/review-pr` | GitHub の PR/Issue URL から、複数の視点によるクロスリポジトリの PR レビューを実行し、指摘をレビューコメントとして投稿する。 |
| `/tdd` | テスト駆動開発のワークフローを強制する。インターフェースを scaffold し、先にテストを生成し、それから最小限の実装でパスさせる。80% 以上のカバレッジを確保する。 |
| `/test-coverage` | テストカバレッジを分析し、カバレッジが不足しているファイルに対して 80% 以上に達するまでテストを生成する。 |
| `/update-docs` | `package.json` と `.env.example` を正として、CONTRIB.md と RUNBOOK.md を同期する。 |
| `/verify` | プロジェクトの検証チェック（ビルド、型、lint、テスト、セキュリティ、git の状態）を実行し、準備状況を報告する。 |

## Agents

| Agent | Description |
|-------|-------------|
| `architect` | システム設計、スケーラビリティ、技術的な意思決定を担当するソフトウェアアーキテクチャの専門家。新機能の計画、大規模なリファクタリング、アーキテクチャ上の意思決定を行うときに積極的に使う。 |
| `build-error-resolver` | ビルドと TypeScript のエラー解決の専門家。ビルドが失敗したり型エラーが発生したときに積極的に使う。アーキテクチャの変更を伴わず、最小限の diff でビルド／型エラーのみを修正する。ビルドを素早く green にすることに専念する。 |
| `code-reviewer` | コードレビューの専門家。品質・セキュリティ・保守性の観点からコードを積極的にレビューする。コードを書いた・変更した直後に使う。すべてのコード変更に対して必ず使うこと。 |
| `database-reviewer` | クエリ最適化、スキーマ設計、セキュリティ、パフォーマンスを担当する PostgreSQL データベースの専門家。SQL を書く、マイグレーションを作成する、スキーマを設計する、データベースのパフォーマンスをトラブルシューティングするときに積極的に使う。Supabase のベストプラクティスを取り入れている。 |
| `design-mockup-author` | ui-directions skill からのみ使う。与えられたデザイントークンとコンポーネント仕様から、Claude Design canvas 用の `.dc.html` artboard 一式を生成する必要があるときに使う。 |
| `doc-updater` | README、ガイド、アーキテクチャ文書がコードから乖離したときに使う。package のスクリプト、env の例、ソースコードからドキュメントを再生成・更新する。 |
| `e2e-runner` | ユーザージャーニーの Playwright end-to-end テストを生成・実行・デバッグするときに使う。ジャーニーを管理し、flaky なテストを隔離し、スクリーンショット・動画・トレースを収集する。 |
| `go-build-resolver` | Go のビルド、vet、コンパイルエラー解決の専門家。最小限の変更でビルドエラー、go vet の問題、linter の警告を修正する。Go のビルドが失敗したときに使う。 |
| `go-reviewer` | イディオマティックな Go、並行処理パターン、エラーハンドリング、パフォーマンスを専門とする Go コードレビューの専門家。すべての Go コード変更に使う。Go プロジェクトでは必ず使うこと。 |
| `planner` | 複雑な機能やリファクタリングのための計画立案の専門家。ユーザーが機能実装、アーキテクチャの変更、複雑なリファクタリングを求めたときに積極的に使う。計画タスクで自動的に有効化される。 |
| `python-reviewer` | PEP 8 準拠、Pythonic なイディオム、型ヒント、セキュリティ、パフォーマンスを専門とする Python コードレビューの専門家。すべての Python コード変更に使う。Python プロジェクトでは必ず使うこと。 |
| `refactor-cleaner` | 未使用コード、重複、リファクタリングを対象としたデッドコードの整理・統合の専門家。デッドコードの削除に積極的に使う。分析ツール（knip、depcheck、ts-prune）を実行してデッドコードを特定し、安全に削除する。 |
| `security-reviewer` | セキュリティ脆弱性の検出と修正の専門家。ユーザー入力、認証、API エンドポイント、機密データを扱うコードを書いた後に積極的に使う。シークレット、SSRF、インジェクション、安全でない暗号、OWASP Top 10 の脆弱性を検出する。 |
| `tdd-guide` | テストを先に書く方法論を強制するテスト駆動開発の専門家。新機能の実装、バグ修正、リファクタリングを行うときに積極的に使う。80% 以上のテストカバレッジを確保する。 |
| `ui-verifier` | ユーザーの実際の Chrome（Claude in Chrome）で稼働中の web アプリを検証し、計測した事実を報告する。UI の変更後、作業完了を報告する前、そして PR に検証エビデンス（スクリーンショット、計測値）が必要なときに積極的に使う。 |

## Skills

**ワークフローとメタ**
- `everything-coding-agent` — Codex と Claude Code の両方で共有される PR レビューワークフロー（`review-pr` Codex skill と `/review-pr` command も参照）。
- `continuous-learning` — SessionEnd 時に長いセッションを検出し、再利用可能なパターンを掘り起こす価値があると示す。学習済み skill として保存するのは手動のステップ。
- `strategic-compact` — タスクのフェーズを通じてコンテキストを保持するため、論理的な区切りで手動でのコンテキスト圧縮を提案する。
- `iterative-retrieval` — subagent のコンテキスト問題を解決するために、コンテキスト取得を段階的に洗練させていくパターン。
- `project-guidelines-example` — アーキテクチャ、コードパターン、テスト要件、デプロイワークフローを示す、プロジェクト固有ガイドライン skill のサンプルテンプレート。
- `security-review` — 認証、ユーザー入力、シークレット、API エンドポイント、決済・機密機能のためのセキュリティチェックリストとパターン。

**言語とフレームワーク**
- `coding-standards` — 命名、イミュータビリティ、エラーハンドリング、入力検証、ファイル構成に関する TypeScript/JavaScript の標準。
- `frontend-patterns` — コンポーネント、hook、フォーム、データフェッチ、error boundary、パフォーマンスが重要な UI に関する React/Next.js のパターン。
- `backend-patterns` — ルーティング、リポジトリ、キャッシュ、認証ミドルウェア、バックグラウンドジョブに関する Node.js/Express/Next.js API のパターン。
- `golang-patterns` — イディオマティックな Go のパターンと慣習。
- `golang-testing` — テーブル駆動テスト、サブテスト、ベンチマーク、fuzzing、カバレッジなど Go のテストパターン。
- `python-patterns` — Pythonic なイディオム、PEP 8 標準、型ヒント、ベストプラクティス。
- `python-testing` — pytest を使った Python テスト: TDD 方法論、fixture、モック、パラメータ化、カバレッジ。
- `java-coding-standards` — Spring Boot サービス向けの Java コーディング標準: 命名、イミュータビリティ、Optional の使い方、stream、例外、ジェネリクス。
- `jpa-patterns` — エンティティ設計、リレーション、クエリ最適化、トランザクション、監査に関する JPA/Hibernate のパターン。
- `springboot-patterns` — Spring Boot のアーキテクチャパターン、REST API 設計、レイヤードサービス、キャッシュ、非同期処理。
- `springboot-security` — 認証・認可、バリデーション、CSRF、シークレット、ヘッダー、レート制限に関する Spring Security のベストプラクティス。
- `springboot-tdd` — JUnit 5、Mockito、MockMvc、Testcontainers、JaCoCo を使った Spring Boot の TDD。
- `springboot-verification` — Spring Boot プロジェクトのための検証ループ: ビルド、静的解析、カバレッジ付きテスト、セキュリティスキャン。

**データ**
- `postgres-patterns` — クエリ最適化、スキーマ設計、インデックス、セキュリティに関する PostgreSQL のパターン。
- `clickhouse-io` — 高パフォーマンスな分析ワークロード向けの ClickHouse データベースパターン、クエリ最適化、分析。

**ドキュメント**
- `nutrient-document-processing` — Nutrient DWS API を使ってドキュメントを処理・変換・OCR・抽出・redact・署名・記入する。

**UI**
- `ui-directions` — ユーザーが選択できるよう、複数の UI 方向性の候補を並べて配置する。
- `ui-verify` — Claude in Chrome を介して実ブラウザで UI の変更を検証する。

**個人の好み**
- `seiji-communication-prefs`、`seiji-judgment-prefs`、`seiji-tech-prefs`、`seiji-workflow-prefs` — メンテナーの作業上の好み（コミュニケーションスタイル、意思決定、コーディング／技術的な好み、ワークフローの習慣）。自分自身の好み skill を作るテンプレートとして有用。

## Hooks

Hook は `hooks/hooks.json` で定義されており、実装は `scripts/hooks/` にある。

| Event | What it does |
|-------|--------------|
| `PreToolUse` (Bash) | 開発サーバーの起動（`npm run dev` 等）を tmux の外で実行することをブロックし、ログにアクセスできる状態を保つ。 |
| `PreToolUse` (Bash) | tmux の中にいない場合、長時間実行するコマンド（install、test、build、docker など）で tmux を使うようリマインドする。 |
| `PreToolUse` (Bash) | `git push` の前に変更内容をレビューするようリマインドする。 |
| `PreToolUse` (Write) | ドキュメントを一箇所にまとめるため、少数の例外的な場所を除いて新しい `.md`/`.txt` ファイルの作成をブロックする。 |
| `PreToolUse` (Edit/Write) | 論理的な区切りで手動でのコンテキスト圧縮を提案する。 |
| `PreCompact` | コンテキスト圧縮の前に状態を保存する。 |
| `SessionStart` | 新しいセッションで、以前のコンテキストを読み込み、プロジェクトのパッケージマネージャーを検出する。 |
| `PostToolUse` (Bash) | `gh pr create` の後に PR の URL とレビューコマンドをログに記録する。 |
| `PostToolUse` (Bash) | ビルドコマンドの後、ブロックせずに非同期のビルド分析 hook を実行する。 |
| `PostToolUse` (Edit/Write) | 編集後に Prettier で JS/TS ファイルを自動フォーマットする。 |
| `PostToolUse` (Edit/Write) | `.ts`/`.tsx` ファイルの編集後に TypeScript のチェックを実行する。 |
| `PostToolUse` (Edit/Write) | 編集された JS/TS ファイルに残っている `console.log` 文について警告する。 |
| `Stop` | 各レスポンスの後、変更されたファイルに `console.log` がないか確認する。 |
| `SessionEnd` | セッションの状態を永続化し、抽出可能なパターンがないかセッションを評価する。 |

2 つの hook はツール呼び出し自体をブロックする: tmux の外での開発サーバー起動チェックと、新規 markdown ファイルチェック（README/CLAUDE/AGENTS/CONTRIBUTING ファイル、`skills/`、`agents/`、`commands/`、`docs/`、`.claude/`、`.claude-plugin/` 配下の `.md`、`/tmp` または `/private/tmp` 配下のファイルを例外とする）である。邪魔になる場合は、`hooks/hooks.json` からそのエントリを削除するか、自分の設定で上書きすること。

## Prerequisites

- Node.js
- [`gh`](https://cli.github.com/)（GitHub CLI）
- [`rg`](https://github.com/BurntSushi/ripgrep)（ripgrep）
- Optional: [`ghq`](https://github.com/x-motemen/ghq)（`/review-pr` がローカルのクローンを見つけるために使う）、Claude in Chrome extension（`ui-verifier` が使う）、Playwright（e2e ワークフローが使う）

## Not distributed

`rules/`、`settings.json`、`plugins/config.json` は [Claude Code plugin reference](https://code.claude.com/docs/en/plugins-reference) における plugin コンポーネントではないため、自分の dotfiles で管理すること。

## Manifest gotchas

Claude Code の plugin manifest validator が課しているが十分に文書化されていない制約については `.claude-plugin/PLUGIN_SCHEMA_NOTES.md` を参照。

## License

MIT.

affaan-m/everything-claude-code (MIT) から派生。
