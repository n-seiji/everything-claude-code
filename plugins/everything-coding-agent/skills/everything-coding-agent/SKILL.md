---
name: everything-coding-agent
description: Use from Codex or Claude Code when the user asks for review-pr or wants a GitHub PR or Issue URL reviewed. Local diff review is `code-review` (a Codex skill / Claude Code command).
allowed-tools: Bash, Read, Write, Edit, bash, read_file, write_file
---

# Everything Coding Agent

This skill exposes host-neutral workflows from `everything-coding-agent`.
Claude Code uses the top-level `commands/` directory; Codex loads this
skill directory through `.codex-plugin/plugin.json`.

## PR Review Workflow

Use this workflow when the user asks for `review-pr`, PR review, or provides a
GitHub PR/Issue URL.

### 1. Resolve the Review Target

- Accept a GitHub PR URL, GitHub Issue URL, PR number, or "current branch PR".
- For a PR URL, fetch:

  ```bash
  gh pr view <url> --json number,title,body,headRefName,baseRefName,author,files,additions,deletions,labels,closingIssuesReferences,url
  ```

- For an Issue URL, fetch the issue and linked PRs:

  ```bash
  gh issue view <url> --json number,title,body,comments,url
  gh api repos/<owner>/<repo>/issues/<number>/timeline --jq '[.[] | select(.source.issue.pull_request) | .source.issue.html_url]'
  ```

- If no explicit target is supplied, resolve the current branch PR with
  `gh pr view --json ...`.
- Stop with a clear error if the PR cannot be resolved.

### 2. Discover Related PRs

Look for related PRs before reviewing:

- PR body links matching `https://github.com/<owner>/<repo>/pull/<number>`.
- Linked PRs from `closingIssuesReferences`.
- Same branch name in sibling repositories when the organization and local
  checkout structure make that practical.

If multiple PRs are found, summarize them and ask the user which ones to
include. If none are found, review only the main PR.

### 3. Gather Diff, Rules, and Project Guidance

For every selected PR:

```bash
gh pr diff <number> -R <owner>/<repo>
gh pr diff <number> -R <owner>/<repo> --name-only
```

Before judging style, architecture, testing, or acceptable risk, actively
search the target repository for rules and documentation. Use local files when
there is a checkout/worktree; otherwise use GitHub APIs or the PR diff context
available through `gh`.

Look for, at minimum:

- agent instructions: `AGENTS.md`, `CLAUDE.md`, `.cursorrules`,
  `.cursor/rules/*`, `.github/copilot-instructions.md`
- repository docs: `README.md`, `CONTRIBUTING.md`, `docs/**`,
  `docs/guideline/**`, architecture decision records
- review and issue templates: `.github/pull_request_template*`,
  `.github/ISSUE_TEMPLATE/**`
- language/tooling rules: lint, formatter, typecheck, test, OpenAPI, schema,
  migration, CI, or package-manager config
- domain-specific docs referenced by the changed files or PR body

Useful local search commands:

```bash
rg --files -g 'AGENTS.md' -g 'CLAUDE.md' -g '.cursorrules' -g '.cursor/rules/**' -g '.github/copilot-instructions.md'
rg --files docs .github | sort
rg --files | rg '(^|/)(README|CONTRIBUTING|architecture|guideline|openapi|schema|migration|lint|test|ci|pull_request_template)'
```

When guidance is found:

- summarize the relevant rules before the findings or in the PR summary
- apply those rules as review criteria, not optional background
- cite the rule/doc path in any finding that depends on it
- if a rule conflicts with generic best practice, prefer the repository rule
  unless it creates a clear security, data integrity, or correctness problem
- if no guidance is found, say so and proceed with the general review criteria

Prefer reviewing from a local checkout or worktree when available. If a local
checkout is not available, use the `gh pr diff` output directly.

### 4. Summarize the PR

Before listing findings, write a short summary:

- repository and PR number/title
- author and head/base branches
- files changed, additions, deletions
- stated purpose from the PR body
- actual implementation summary from the diff
- risk hotspots such as schema changes, auth, payments, batch jobs, external
  service calls, or large generated diffs

### 5. Review Perspectives

Run the review from these perspectives. Use parallel subagents if the host
supports them; otherwise do the passes sequentially.

**General correctness and maintainability**

- behavior regressions
- missing edge cases
- error handling and recovery
- excessive complexity, duplication, or unclear ownership
- tests missing for changed behavior

**Security**

- hardcoded secrets or credentials
- injection risks
- broken authz/authn boundaries
- unsafe file paths or command execution
- sensitive data logging
- unsafe external input handling

**Language-specific review**

- Go: context as first parameter, error wrapping, goroutine lifecycle, race
  risks, SQL query performance, GORM batch insert patterns, map preallocation.
- TypeScript/JavaScript: type safety, React hook correctness, XSS, async error
  handling, cleanup of subscriptions/effects.

**Project-specific review**

Apply discovered repository rules, docs, and business rules. If the target
repository handles money, multi-tenant data, or OpenAPI-driven APIs, add checks
for financial correctness, tenant scoping, migration safety, and contract
drift.

### 6. Output Format

Lead with findings. Keep summaries secondary.

```markdown
## Findings

| Severity | File | Line | Issue |
|---|---|---:|---|
| CRITICAL | path/file.go | 42 | Short issue title |

### CRITICAL

1. `path/file.go:42` - Explain the bug, impact, and concrete fix.

### HIGH

1. `path/file.go:80` - Explain the bug, impact, and concrete fix.

### MEDIUM

1. `path/file.go:120` - Explain the issue and recommended fix.

### LOW

1. `path/file.go:160` - Explain the suggestion.

## Summary

- Verdict: `APPROVE`, `COMMENT`, or `REQUEST_CHANGES`
- Reviewed PRs: `<owner>/<repo>#<number>`
- Repository guidance used: `<paths read, or "none found">`
- Tests or checks inspected/run: `<commands or not run>`
```

Use these severity meanings:

- `CRITICAL`: exploitable security issue, data loss, financial/accounting
  corruption, or production outage risk.
- `HIGH`: likely behavioral bug, authorization break, migration hazard, or
  missing test for risky behavior.
- `MEDIUM`: maintainability, performance, or edge-case issue that should be
  addressed soon.
- `LOW`: minor improvement or style issue.

If there are no findings, say that clearly and mention residual test gaps.

### 7. Comment Posting

Do not post GitHub comments without explicit user approval. After presenting
findings, ask whether to:

1. post all findings
2. post only selected numbers
3. post only findings at or above a severity
4. skip posting

When posting, prefer inline PR review comments for findings with stable file
and line locations. Use a summary comment for general findings or when inline
positions are unavailable.

### 8. Cleanup

Remove temporary worktrees or branches created only for review. Do not remove
user worktrees, uncommitted user changes, or unrelated branches.

## Slash Commands

- `/everything-coding-agent:review-pr <GitHub PR URL or Issue URL>` - run the
  PR review workflow above.

Plain-language requests such as "このPRをreview-prっぽくレビューして" (review this PR review-pr style) should trigger
the same workflow.
