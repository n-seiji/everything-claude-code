# everything-coding-agent

English | [日本語](README.ja.md)

A plugin for Claude Code and Codex that ships agents, skills, slash commands, and hooks for day-to-day coding work: planning, TDD, code and PR review, build-error fixes, security review, and UI verification.

## Install for Claude Code

```
/plugin marketplace add n-seiji/everything-coding-agent
/plugin install everything-coding-agent@n-seiji
```

To update to the latest version, run `/plugin marketplace update n-seiji` followed by `/plugin update everything-coding-agent@n-seiji` (or reinstall).

## Install for Codex

Codex reads `.agents/plugins/marketplace.json`, which points at the local plugin path `plugins/everything-coding-agent`. That plugin's `.codex-plugin/plugin.json` declares `skills` pointing at its own `skills/` directory, so Codex loads its workflows from there.

```
codex plugin marketplace add n-seiji/everything-coding-agent
codex plugin add everything-coding-agent@n-seiji
```

To use a local checkout, add its absolute path as the marketplace and install from it the same way.

To update: `codex plugin marketplace upgrade n-seiji`, then remove and re-add the plugin (`codex plugin remove everything-coding-agent@n-seiji` followed by `codex plugin add everything-coding-agent@n-seiji`).

Codex does not read the top-level `commands/` directory. The same workflows are available to Codex as `plugins/everything-coding-agent/skills/<name>/SKILL.md`.

## Layout

| Path | Contents |
|------|----------|
| `commands/` | Claude Code slash commands |
| `agents/` | Claude Code subagents |
| `skills/` | Claude Code skills |
| `plugins/everything-coding-agent/skills/` | Codex skills mirroring the commands |
| `hooks/hooks.json` + `scripts/hooks/` | Hooks and their implementations |
| `.claude-plugin/` | Claude Code plugin manifest and marketplace listing |
| `.codex-plugin/` and `.agents/plugins/` | Codex plugin and marketplace manifests; the root `.codex-plugin/plugin.json` lets Codex install the repository itself as a plugin without the marketplace file, and the copy under `plugins/everything-coding-agent/` is the one the marketplace uses. |

Maintenance rules: keep `skills/everything-coding-agent/` and `plugins/everything-coding-agent/skills/everything-coding-agent/` byte-identical. Bump `version` in all three manifests together (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `plugins/everything-coding-agent/.codex-plugin/plugin.json`).

## Commands

| Command | Description |
|---------|-------------|
| `/build-fix` | Incrementally fix build and type errors, verifying the build after each fix. |
| `/code-review` | Comprehensive security and quality review of uncommitted changes. |
| `/e2e` | Generate and run end-to-end tests with Playwright. Creates test journeys, runs tests, captures screenshots/videos/traces, and uploads artifacts. |
| `/go-build` | Fix Go build errors, go vet warnings, and linter issues incrementally. Invokes the go-build-resolver agent for minimal, surgical fixes. |
| `/go-review` | Comprehensive Go code review for idiomatic patterns, concurrency safety, error handling, and security. Invokes the go-reviewer agent. |
| `/go-test` | Drive Go changes with TDD — write one failing table-driven subtest at a time, then the minimal code to pass, using go test -race and -cover for feedback. |
| `/plan` | Restate requirements, assess risks, and create step-by-step implementation plan. WAIT for user CONFIRM before touching any code. |
| `/refactor-clean` | Identify and safely remove dead code, verifying tests before and after each deletion. |
| `/review-pr` | Run a multi-perspective, cross-repository PR review from a GitHub PR/Issue URL and post the findings as review comments. |
| `/tdd` | Drive a change with test-driven development: TODO list, one failing test at a time, fake it / triangulate / obvious implementation, refactor while green. |
| `/test-coverage` | Use the coverage report to find risky untested behavior and add behavior-named tests for it — not to chase a percentage. |
| `/update-docs` | Sync CONTRIB.md and RUNBOOK.md from package.json and .env.example as source of truth. |
| `/verify` | Run project verification checks (build, types, lint, tests, security, git status) and report readiness. |

## Agents

| Agent | Description |
|-------|-------------|
| `architect` | Software architecture specialist for system design, scalability, and technical decision-making. Use PROACTIVELY when planning new features, refactoring large systems, or making architectural decisions. |
| `build-error-resolver` | Build and TypeScript error resolution specialist. Use PROACTIVELY when build fails or type errors occur. Fixes build/type errors only with minimal diffs, no architectural edits. Focuses on getting the build green quickly. |
| `code-reviewer` | Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code. MUST BE USED for all code changes. |
| `database-reviewer` | PostgreSQL database specialist for query optimization, schema design, security, and performance. Use PROACTIVELY when writing SQL, creating migrations, designing schemas, or troubleshooting database performance. Incorporates Supabase best practices. |
| `design-mockup-author` | Use only from the ui-directions skill, when a set of `.dc.html` artboards for a Claude Design canvas must be produced from given design tokens and component specs. |
| `doc-updater` | Use when README, guides, or architecture docs drift from the code; regenerates and updates documentation from package scripts, env examples, and source. |
| `e2e-runner` | Use when generating, running, or debugging Playwright end-to-end tests for a user journey; manages journeys, quarantines flaky tests, and collects screenshots, videos, and traces. |
| `go-build-resolver` | Go build, vet, and compilation error resolution specialist. Fixes build errors, go vet issues, and linter warnings with minimal changes. Use when Go builds fail. |
| `go-reviewer` | Expert Go code reviewer specializing in idiomatic Go, concurrency patterns, error handling, and performance. Use for all Go code changes. MUST BE USED for Go projects. |
| `planner` | Expert planning specialist for complex features and refactoring. Use PROACTIVELY when users request feature implementation, architectural changes, or complex refactoring. Automatically activated for planning tasks. |
| `refactor-cleaner` | Dead code cleanup and consolidation specialist. Use PROACTIVELY for removing unused code, duplicates, and refactoring. Runs analysis tools (knip, depcheck, ts-prune) to identify dead code and safely removes it. |
| `security-reviewer` | Security vulnerability detection and remediation specialist. Use PROACTIVELY after writing code that handles user input, authentication, API endpoints, or sensitive data. Flags secrets, SSRF, injection, unsafe crypto, and OWASP Top 10 vulnerabilities. |
| `tdd-guide` | Use when implementing a new behavior or fixing a bug: drives the change through a TODO list and small red-green-refactor cycles, with tests written as behavior statements. Also use to add characterization tests before changing unfamiliar code. |
| `ui-verifier` | Verifies a running web app in the user's real Chrome (Claude in Chrome) and reports measured facts. Use PROACTIVELY after UI changes, before reporting work as done, and when a PR needs verification evidence (screenshots, measured values). |

## Skills

**Workflow and meta**
- `everything-coding-agent` — the PR review workflow shared by Codex and Claude Code (see also the `review-pr` Codex skill and `/review-pr` command).
- `continuous-learning` — flags long sessions at SessionEnd as worth mining for reusable patterns; saving a learned skill is a manual step.
- `strategic-compact` — suggests manual context compaction at logical intervals to preserve context through task phases.
- `iterative-retrieval` — a pattern for progressively refining context retrieval to solve the subagent context problem.
- `project-guidelines-example` — an example project-specific guidelines skill template showing architecture, code patterns, testing requirements, and deployment workflow.
- `security-review` — a security checklist and patterns for authentication, user input, secrets, API endpoints, and payment/sensitive features.

**Language and framework**
- `coding-standards` — TypeScript/JavaScript standards for naming, immutability, error handling, input validation, and file layout.
- `frontend-patterns` — React/Next.js patterns for components, hooks, forms, data fetching, error boundaries, and performance-sensitive UI.
- `backend-patterns` — Node.js/Express/Next.js API patterns: routes, repositories, caching, auth middleware, and background jobs.
- `golang-patterns` — idiomatic Go patterns and conventions.
- `golang-testing` — Go testing patterns: table-driven tests, subtests, benchmarks, fuzzing, coverage.

**Data**
- `postgres-patterns` — PostgreSQL patterns for query optimization, schema design, indexing, and security.
- `clickhouse-io` — ClickHouse database patterns, query optimization, and analytics for high-performance analytical workloads.

**Documents**
- `nutrient-document-processing` — process, convert, OCR, extract, redact, sign, and fill documents using the Nutrient DWS API.

**UI**
- `ui-directions` — lay out several UI direction options side by side for the user to choose from.
- `ui-verify` — verify UI changes work correctly in a real browser via Claude in Chrome.

**Personal preferences**
- `seiji-communication-prefs`, `seiji-judgment-prefs`, `seiji-tech-prefs`, `seiji-workflow-prefs` — the maintainer's working preferences (communication style, decision-making, coding/technical preferences, and workflow habits). Useful as a template for your own preference skills.

## Hooks

Hooks are defined in `hooks/hooks.json`, with implementations in `scripts/hooks/`.

| Event | What it does |
|-------|--------------|
| `PreToolUse` (Bash) | Blocks running a dev server (`npm run dev` and equivalents) outside tmux, so logs stay accessible. |
| `PreToolUse` (Bash) | Reminds you to use tmux for long-running commands (install, test, build, docker, etc.) when not already inside tmux. |
| `PreToolUse` (Bash) | Reminds you to review changes before `git push`. |
| `PreToolUse` (Write) | Blocks creation of new `.md`/`.txt` files outside a small set of exempt locations, to keep documentation consolidated. |
| `PreToolUse` (Edit/Write) | Suggests manual context compaction at logical intervals. |
| `PreCompact` | Saves state before context compaction. |
| `SessionStart` | Loads previous context and detects the project's package manager on a new session. |
| `PostToolUse` (Bash) | Logs the PR URL and a review command after `gh pr create`. |
| `PostToolUse` (Bash) | Runs an async build-analysis hook after a build command, without blocking. |
| `PostToolUse` (Edit/Write) | Auto-formats JS/TS files with Prettier after edits. |
| `PostToolUse` (Edit/Write) | Runs a TypeScript check after editing `.ts`/`.tsx` files. |
| `PostToolUse` (Edit/Write) | Warns about `console.log` statements left in edited JS/TS files. |
| `Stop` | Checks for `console.log` in modified files after each response. |
| `SessionEnd` | Persists session state and evaluates the session for extractable patterns. |

Two hooks block tool calls outright: the dev-server-outside-tmux check and the new-markdown-file check (which exempts README/CLAUDE/AGENTS/CONTRIBUTING files, any `.md` under `skills/`, `agents/`, `commands/`, `docs/`, `.claude/`, `.claude-plugin/`, and files under `/tmp` or `/private/tmp`). Remove either hook from `hooks/hooks.json` or override it in your own settings if it gets in the way.

## Prerequisites

- Node.js
- [`gh`](https://cli.github.com/) (GitHub CLI)
- [`rg`](https://github.com/BurntSushi/ripgrep) (ripgrep)
- Optional: [`ghq`](https://github.com/x-motemen/ghq) (used by `/review-pr` to locate local clones), the Claude in Chrome extension (used by `ui-verifier`), and Playwright (used by the e2e workflows)

## Not distributed

`rules/`, `settings.json`, and `plugins/config.json` are not plugin components per the [Claude Code plugin reference](https://code.claude.com/docs/en/plugins-reference), so manage them in your own dotfiles.

## Manifest gotchas

See `.claude-plugin/PLUGIN_SCHEMA_NOTES.md` for constraints the Claude Code plugin manifest validator enforces but doesn't fully document.

## License

MIT.

Derived from affaan-m/everything-claude-code (MIT).
