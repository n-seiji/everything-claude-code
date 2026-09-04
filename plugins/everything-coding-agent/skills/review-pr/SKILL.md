---
name: review-pr
description: Review a GitHub pull request using the everything-coding-agent multi-perspective PR review workflow. Use when the user invokes review-pr, asks to review a PR, provides a GitHub PR or Issue URL, or wants repository-guided code review.
allowed-tools: Bash, Read, Write, Edit, bash, read_file, write_file
---

# Review PR

Run the everything-coding-agent PR review workflow for a GitHub PR or linked
Issue. Codex lists this skill as `/review-pr`.

## Workflow

1. Resolve the review target.
   - Accept a GitHub PR URL, GitHub Issue URL, PR number, or "current branch PR".
   - For a PR URL, run:

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

2. Discover related PRs.
   - Look for PR body links, linked issues, and same-branch PRs in sibling
     repositories when practical.
   - If multiple PRs are found, summarize them and ask which ones to include.

3. Gather diffs, repository rules, and docs.
   - For every selected PR:

     ```bash
     gh pr diff <number> -R <owner>/<repo>
     gh pr diff <number> -R <owner>/<repo> --name-only
     ```

   - Actively search the repository for guidance before reviewing:
     `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.cursor/rules/**`,
     `.github/copilot-instructions.md`, `README.md`, `CONTRIBUTING.md`,
     `docs/**`, `docs/guideline/**`, PR templates, CI/lint/test/OpenAPI/schema
     config, and docs referenced by changed files or the PR body.
   - Apply discovered guidance as review criteria. Cite the path when a finding
     depends on it. If no guidance is found, say so.

4. Review from these perspectives.
   - General correctness and maintainability.
   - Security: secrets, injection, auth boundaries, unsafe paths/commands,
     sensitive logging, external input handling.
   - Language-specific checks: Go, TypeScript/JavaScript, Python, Java/Kotlin
     as applicable.
   - Project-specific rules and business invariants found in repository docs.

5. Output findings first.

   ```markdown
   ## Findings

   ### CRITICAL
   1. `path/file.go:42` - Impact and concrete fix.

   ### HIGH
   1. `path/file.go:80` - Impact and concrete fix.

   ### MEDIUM
   1. `path/file.go:120` - Recommendation.

   ### LOW
   1. `path/file.go:160` - Suggestion.

   ## Summary
   - Verdict: `APPROVE`, `COMMENT`, or `REQUEST_CHANGES`
   - Reviewed PRs: `<owner>/<repo>#<number>`
   - Repository guidance used: `<paths read, or "none found">`
   - Tests or checks inspected/run: `<commands or not run>`
   ```

6. Do not post GitHub comments without explicit approval.
   - Ask whether to post all findings, selected findings, findings above a
     severity, or skip posting.
   - Prefer inline review comments when stable file/line positions are
     available.

7. Cleanup temporary worktrees or review-only branches. Never remove unrelated
   user worktrees, uncommitted changes, or branches.
