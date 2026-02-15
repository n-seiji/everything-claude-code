# everything-claude-code (fork)

[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) のフォーク。
Claude Code の settings、commands、plugins、rules を一括管理し、`install.sh` で `~/.claude/` へデプロイする。

## フォークで変更した点

- 不要なドキュメント（中国語翻訳、Django skills）を削除して軽量化
- `install.sh` を新規作成 — settings / plugins / commands / rules をワンコマンドでインストール
- `.claude/settings.json` を追加 — permissions（allow / deny）、plugins、hooks を一括管理
- `.claude/plugins/` を追加 — typescript-lsp, gopls-lsp プラグインの設定
- 新規コマンドを追加:
  - `/cp` — commit and push
  - `/cpp` — commit, push, and open a draft PR
  - `/draft-pr` — draft PR 作成フロー

## インストール

```bash
git clone https://github.com/n-seiji/everything-claude-code.git
cd everything-claude-code

# settings + plugins + commands のみ
./install.sh

# rules も含める場合（言語を指定）
./install.sh typescript
./install.sh typescript python golang
```

### install.sh の動作

| 対象 | インストール先 | 方式 |
|------|----------------|------|
| `settings.json` | `~/.claude/settings.json` | symlink |
| `plugins/config.json` | `~/.claude/plugins/config.json` | symlink |
| `plugins/installed_plugins.json` | `~/.claude/plugins/installed_plugins.json` | copy（既存時はスキップ） |
| `settings.local.json.example` | `~/.claude/settings.local.json` | copy（既存時はスキップ） |
| `commands/*.md` | `~/.claude/commands/` | symlink |
| `rules/common/` | `~/.claude/rules/common/` | copy（言語引数指定時のみ） |
| `rules/<lang>/` | `~/.claude/rules/<lang>/` | copy（言語引数指定時のみ） |

既存ファイルがある場合は `.bak` にバックアップしてから上書きする（symlink の場合）。

## ディレクトリ構成

```
.claude/
  settings.json                  # permissions, plugins, hooks
  settings.local.json.example    # ローカル上書き用テンプレート
  plugins/
    config.json                  # plugin リポジトリ設定
    installed_plugins.json       # インストール済みプラグイン

commands/                        # /cp, /cpp, /draft-pr など追加コマンド
rules/                           # common/ + typescript/ + python/ + golang/
agents/                          # planner, code-reviewer, tdd-guide など
skills/                          # TDD, backend-patterns, security-review など
hooks/                           # PreToolUse, PostToolUse, Stop hooks
mcp-configs/                     # MCP サーバー設定
```

## settings.json の概要

### Permissions (allow)

- `WebSearch`, `WebFetch` (GitHub, MDN, Go, Rust, TypeScript, React, Anthropic docs など)
- `Bash`: git 操作全般、`gh` CLI（PR, issue, run）、バージョン確認
- 各種開発ドキュメントサイトへのアクセス

### Permissions (deny)

- `~/.ssh/`, `~/.aws/`, `~/.gnupg/` への読み書き
- `.env`, `.env.*` ファイルへのアクセス
- `gh` による破壊的操作（issue delete, repo delete など）

### Plugins

- `typescript-lsp@claude-plugins-official`
- `gopls-lsp@claude-plugins-official`
- `everything-claude-code`（このリポジトリ自体）

## 追加コマンド

| コマンド | 説明 |
|----------|------|
| `/cp` | 変更をステージ → コミット → プッシュ |
| `/cpp` | 変更をステージ → コミット → プッシュ → draft PR 作成 |
| `/draft-pr` | draft PR 作成フロー（ブランチチェック付き） |

upstream 由来のコマンド（`/plan`, `/tdd`, `/code-review`, `/build-fix` など）もそのまま利用可能。

## Upstream

- Upstream: [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)
- License: MIT
