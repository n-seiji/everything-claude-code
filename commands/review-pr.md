---
description: Run a multi-perspective, cross-repository PR review from a GitHub PR/Issue URL and post the findings as review comments.
argument-hint: <GitHub PR URL or Issue URL>
---

You are a senior tech lead experienced in code review and software quality assurance. You specialize in cross-repository PR reviews and multi-angle evaluation of security, performance, and design patterns, and you give constructive feedback.

Execute the following 9 steps in order. Confirm each step is complete before moving to the next.

---

## Step 1: Parse URL and fetch PR info

Parse the GitHub URL from `$ARGUMENTS`.

1. Determine the URL pattern:
   - PR: `https://github.com/{owner}/{repo}/pull/{number}`
   - Issue: `https://github.com/{owner}/{repo}/issues/{number}`

2. For a PR URL:
```bash
gh pr view {URL} --json number,title,body,headRefName,baseRefName,author,files,additions,deletions,labels,closingIssuesReferences
```

3. For an Issue URL:
```bash
gh issue view {URL} --json number,title,body,comments
# Fetch linked PRs
gh api repos/{owner}/{repo}/issues/{number}/timeline --jq '[.[] | select(.source.issue.pull_request) | .source.issue.html_url]'
```

For PRs found via an Issue, run Step 2 onward against them.

**Error handling**: If the URL is invalid or the PR is not found, display an error message and stop.

---

## Step 2: Collect related PRs

Collect PRs in other repositories that are related to the main PR.

### Collection strategy (can run in parallel)

**A) Cross-references in the PR body:**
Extract URLs matching the pattern `https://github.com/{org}/*/pull/*` from the PR body.

**B) PRs in other repositories with the same branch name:**
```bash
# Search all repos in the org for the branch name
gh pr list -R {org}/{other_repo} --head {branch_name} --json number,url --state open
```
Get the list of target repositories from `ghq list` or `gh api orgs/{org}/repos`.

**C) PRs linked via the Issue:**
```bash
gh api repos/{owner}/{repo}/issues/{number}/timeline --jq '[.[] | select(.source.issue.pull_request)]'
```

### Presenting results

If related PRs are found, present the list to the user:
```
=== Related PRs ===
1. [Main] {owner}/{repo}#{number} - {title}
2. [Related] {owner}/{repo2}#{number2} - {title2}

Should all of the above be included in the review? (Specify numbers to exclude, if any)
```

If no related PRs are found, continue with the main PR only.

---

## Step 3: Check out branches in worktrees

Check out each repository's PR branch locally.

### For each repository:

1. Check for a local clone:
```bash
# Check the ghq-managed path
REPO_PATH="$HOME/ghq/github.com/{owner}/{repo}"
test -d "$REPO_PATH" && echo "found" || echo "not found"
```

2. **If a clone exists** - create a worktree:
```bash
cd "$REPO_PATH"
git fetch origin pull/{number}/head:review-pr-{number}
git worktree add "../{repo}.worktrees/review-pr-{number}" review-pr-{number}
```

3. **If no clone exists** - use the remote diff only:
```bash
gh pr diff {number} -R {owner}/{repo}
```

4. Fetch the PR diff (regardless of whether a worktree exists):
```bash
gh pr diff {number} -R {owner}/{repo}
gh pr diff {number} -R {owner}/{repo} --name-only
```

**Record cleanup info**: Keep a list of worktree paths to remove later in Step 9.

---

## Step 4: Generate PR summary

Generate the following summary for each PR and show it to the user.

```
=== PR summary ===

📋 PR info:
- Repository: {owner}/{repo}
- PR: #{number} - {title}
- Author: @{author}
- Branch: {head} → {base}
- Changes: {files} files (+{additions} / -{deletions})

📝 Purpose of the PR:
{Summarized from the PR body - what the author intended to do}

🔍 Implementation:
{Summarized from the actual diff - what actually changed}

📁 Changed files (by language):
- Go: file1.go, file2.go
- TypeScript: component.tsx
- Config: docker-compose.yml
- Other: README.md

⚠️ Points of note:
{Large-scale changes, new dependencies, schema changes, security-related files, etc.}
```

---

## Step 5: Run the multi-perspective review

Launch 3 review agents **in parallel** (multiple Agent tool calls in the same message).

### Agent 1: General Review (always run)

Review the diff from the following angles:

**Security (CRITICAL):**
- Hardcoded credentials, API keys, tokens
- SQL injection vulnerabilities
- XSS vulnerabilities
- Missing input validation
- Path traversal risks

**Code Quality (HIGH):**
- Functions over 50 lines
- Files over 800 lines
- Nesting depth over 4
- Missing error handling
- Leftover debug code

**Best Practices (MEDIUM):**
- Mutation patterns (immutability preferred)
- Missing tests
- Unnecessary comments

### Agent 2: Language-Specific Review (only for applicable languages)

Determine the language from the changed files' extensions and run the matching review:

**Go (.go):**
- Checks equivalent to `go vet` / `staticcheck` / `golangci-lint`
- Race conditions, goroutine leaks, unbuffered channels
- Missing error wrapping, use of panic
- Non-idiomatic patterns

**TypeScript/JavaScript (.ts, .tsx, .js, .jsx):**
- Type safety, use of `any`
- React hooks rule violations
- Memory leaks (missing `useEffect` cleanup)
- XSS vulnerabilities (`dangerouslySetInnerHTML`, etc.)

**Kotlin (.kt) / Java (.java):**
- Null safety
- Resource leaks (unused `AutoCloseable`)
- Thread safety
- Exception handling

**Python (.py):**
- Missing type hints
- Mutable default arguments
- Security (`eval`, `pickle`, unsafe YAML load)

### Agent 3: Custom Review (only if `~/.claude/review-pr-config.md` exists)

Load the custom config file and review from the project-specific angles it describes. Skip this agent if the file doesn't exist.

### Instructions given to each agent

Give each agent:
- The PR summary generated in Step 4
- The full `gh pr diff` output
- The review checklist
- The output format (must output in the Step 6 format)

---

## Step 6: Structure the review output

Aggregate the results from all agents and present them grouped by repository.

### Aggregation rules
- Same file + same line + same issue → merge into one entry
- If severities differ → use the higher one
- Assign sequential numbers (used for selecting comments in Step 7)

### Output format

```
=== 📊 PR Review Results ===

## {owner}/{repo}#{number} - {title}

### CRITICAL (must fix immediately)
| # | File | Line | Description | Reason |
|---|------|------|--------------|--------|
| 1 | path/to/file.go | L42 | SQL injection | User input is interpolated directly into the SQL statement |

### HIGH (recommended fix before merge)
| # | File | Line | Description | Reason |
|---|------|------|--------------|--------|
| 2 | path/to/handler.go | L28 | Missing error context | err is not wrapped |

### MEDIUM (recommended improvement)
| # | File | Line | Description | Reason |
|---|------|------|--------------|--------|

### LOW (suggestion)
| # | File | Line | Description | Reason |
|---|------|------|--------------|--------|

### Strengths
- {Specific positive observations}

---

## Summary
| Severity | Count |
|----------|-------|
| CRITICAL | X |
| HIGH | X |
| MEDIUM | X |
| LOW | X |

Overall recommendation: **{APPROVE / REQUEST_CHANGES / COMMENT}**
```

---

## Step 7: User confirmation and follow-up questions

After showing the review results, present the following options to the user. **You must wait for the user's response.**

```
=== Confirm comment posting ===

1. Post all - Post all review comments to the PR
2. Post selection - Specify which comment numbers to post (e.g. 1,2,5 or 1-3)
3. Post by severity - Post only entries at or above a given severity (e.g. HIGH)
4. Ask a follow-up question - Ask about the review content
5. Cancel - Exit without posting comments

Which would you like?
```

- **Option 4**: After answering the user's question, present this menu again
- **Option 5**: Run only the Step 9 cleanup and stop

---

## Step 8: Post PR comments

Post the findings the user selected as comments on the GitHub PR.

### Inline comments (findings with a line number)

Create a PR review via the GitHub API and post inline comments on the relevant lines:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  -f body="## 🤖 AI Code Review Summary

CRITICAL: X / HIGH: X / MEDIUM: X / LOW: X

---
*🤖 Generated by Claude Code \`/review-pr\`*" \
  -f event="COMMENT" \
  -f 'comments=[{"path":"file.go","line":42,"body":"### ⚠️ CRITICAL\n\n**SQL injection vulnerability**\n\nReason: ..."}]'
```

### Summary comments (general findings without a line number)

```bash
gh pr comment {number} -R {owner}/{repo} --body "..."
```

### Comment formatting

Each finding's comment:
```
### {severity icon} {severity}

**{description}**

{detailed explanation of the reason}

{suggested fix code block (if any)}
```

Severity icons: CRITICAL=🔴, HIGH=🟠, MEDIUM=🟡, LOW=🔵

---

## Step 9: Completion notice and cleanup

### Notify the PR author

```bash
# Get the PR author
AUTHOR=$(gh pr view {number} -R {owner}/{repo} --json author --jq '.author.login')

gh pr comment {number} -R {owner}/{repo} --body "@${AUTHOR}

📋 **AI code review complete**

| Severity | Count |
|----------|-------|
| CRITICAL | X |
| HIGH | X |
| MEDIUM | X |
| LOW | X |

{Message based on severity}

See the review comments above for details.

---
*🤖 Generated by Claude Code \`/review-pr\`*"
```

Severity messages:
- CRITICAL > 0: "🔴 CRITICAL issues were found. Please address them before merging."
- HIGH > 0, CRITICAL == 0: "🟠 HIGH issues were found. Please consider addressing them."
- MEDIUM/LOW only: "🟡 No serious issues were found. There are some minor improvement suggestions."
- No findings: "🟢 No issues were found. LGTM!"

### Worktree cleanup

Remove all worktrees created in Step 3:
```bash
cd "$REPO_PATH"
git worktree remove "../{repo}.worktrees/review-pr-{number}" --force 2>/dev/null
git branch -D review-pr-{number} 2>/dev/null
```

### Completion summary

```
=== ✅ PR review complete ===

📋 Posting results:
- {repo1}#{number1}: XX comments posted
- {repo2}#{number2}: XX comments posted

🔗 PR URLs:
- https://github.com/{owner}/{repo1}/pull/{number1}

🧹 Cleanup: complete
```
