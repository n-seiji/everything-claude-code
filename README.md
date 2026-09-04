# everything-coding-agent (fork)

[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) のフォーク。
Claude Code と Codex の両方で使える coding agent plugin として、agents / skills / commands / hooks を配布する。

## フォークで変更した点

- 不要なドキュメント（中国語翻訳、Django skills）を削除して軽量化
- `.claude-plugin/marketplace.json` を `n-seiji` namespace で公開
- `.codex-plugin/plugin.json` を追加し、Codex から `plugins/everything-coding-agent/skills/` を読み込めるようにした
- 旧 `install.sh` ベースのインストール経路（`.claude/settings.json`、`rules/` 含む）は廃止
- Codex で `/` 候補に出したい workflow を `plugins/everything-coding-agent/skills/*/SKILL.md` として公開
- Claude Code 固有/実験系の古い slash command を削除し、保守対象の workflow に整理
- 新規コマンドを追加:
  - `/cp` — commit and push
  - `/cpp` — commit, push, and open a draft PR
  - `/draft-pr` — draft PR 作成フロー

## インストール

### Claude Code CLI から導入

```text
/plugin marketplace add n-seiji/everything-coding-agent
/plugin install everything-coding-agent@n-seiji
```

### Codex で使う場合

Codex CLI は `.agents/plugins/marketplace.json` を marketplace index として読み、インストール対象の plugin は `.codex-plugin/plugin.json` から `skills/` を読み込む。
リポジトリを marketplace として追加してから plugin を install する。

```text
codex plugin marketplace add n-seiji/everything-coding-agent
codex plugin list | rg -i everything-coding-agent
codex plugin add everything-coding-agent@n-seiji
```

ローカル checkout を使う場合:

```text
codex plugin marketplace add /absolute/path/to/everything-coding-agent
codex plugin add everything-coding-agent@n-seiji
```

Codex では Claude Code の top-level `commands/` はそのまま slash command としては読まれないため、候補に出したい workflow は `plugins/everything-coding-agent/skills/<name>/SKILL.md` として配置している。install 後は `/everything`、`/review`、`/go`、`/tdd` などで候補を絞り込める。

インストール済み plugin を更新する場合は、marketplace を更新してから plugin を入れ直す。

```text
codex plugin marketplace upgrade n-seiji
codex plugin remove everything-coding-agent@n-seiji
codex plugin add everything-coding-agent@n-seiji
```

### dotfiles 経由（自分用 / 推奨）

[n-seiji/dotfiles](https://github.com/n-seiji/dotfiles) の `home/programs/claude.nix` で
flake input としてこのリポジトリを取り込み、`~/.claude/plugins/marketplaces/n-seiji` に
symlink + `enabledPlugins` で有効化する。`home-manager switch` で反映。

## 配布物

| 種別 | パス | 用途 |
|------|------|------|
| agents | `agents/*.md` | planner, code-reviewer, tdd-guide, ui-verifier ほか 10 種の subagent |
| skills | `skills/*/SKILL.md` | Claude Code 向けの upstream skills |
| codex skills | `plugins/everything-coding-agent/skills/*/SKILL.md` | Codex の `/` 候補に出す workflow skills |
| shared commands | `skills/everything-coding-agent/commands/*.md` | Codex / Claude Code 両対応の skill command |
| commands | `commands/*.md` | Claude Code 向け slash command |
| hooks | `hooks/` | PreToolUse / PostToolUse / Stop |

## 配布外（dotfiles 側で管理）

`rules/`、`settings.json`、`plugins/config.json` は
[plugin reference](https://code.claude.com/docs/en/plugins-reference) の component
仕様に含まれず、プラグインからは配布できない。ユーザ環境への配置は dotfiles で行う。
この前提は Claude Code 向けで、`hooks/hooks.json` も Claude Code 用マニフェストのまま管理している。

- `~/.claude/rules/` — dotfiles `home/files/claude/rules/` を symlink
- `~/.claude/settings.json` — dotfiles の base + `enabledPlugins` をマージしてビルド
- `~/.claude/plugins/config.json` — dotfiles で配置

## 追加コマンド

| コマンド | 説明 |
|----------|------|
| `/build-fix` | build error の段階的修正 |
| `/code-review` | 汎用コードレビュー |
| `/cp` | 変更をステージ → コミット → プッシュ |
| `/cpp` | 変更をステージ → コミット → プッシュ → draft PR 作成 |
| `/draft-pr` | draft PR 作成フロー（ブランチチェック付き） |
| `/e2e` | E2E test 作成/実行/調査 |
| `/go-build` | Go build / vet / lint failure の修正 |
| `/go-review` | Go 向けコードレビュー |
| `/go-test` | Go test / table-driven test workflow |
| `/plan` | 実装計画作成 |
| `/python-review` | Python 向けコードレビュー |
| `/refactor-clean` | dead code / cleanup refactor |
| `/review-pr` | GitHub PR review |
| `/tdd` | test-driven development workflow |
| `/test-coverage` | coverage gap の調査とテスト追加 |
| `/update-docs` | docs 更新 |
| `/verify` | build/lint/test などの検証 |

Claude Code 固有/実験系だった `multi-*`, `ccpp`, `checkpoint`, `sessions`, `learn`, `evolve`, `instinct-*`, `orchestrate`, `pm2`, `setup-pm`, `skill-create`, `update-codemaps`, `eval` は削除済み。

## Upstream

- Upstream: [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)
- License: MIT
