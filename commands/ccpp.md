---
allowed-tools: Bash(git checkout -b:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(gh pr create:*), Bash(git branch:*)
description: Checkout new branch, commit, push, and open a draft PR
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes:

1. Record the current branch name as the PR target branch (the base branch for the PR)
2. Create and checkout a new branch with an appropriate name based on the changes
3. Stage all relevant changed files with `git add`
4. Create a single commit with an appropriate message following conventional commits format (feat, fix, refactor, docs, test, chore, perf, ci)
5. Push the branch to origin
6. Create a **draft** pull request using `gh pr create --draft --base <recorded-branch>` where `<recorded-branch>` is the branch from step 1
7. You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.
