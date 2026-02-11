---
description: Commit changes, push branch, and open a draft PR
agent: build
---

# Draft PR Command

Create a commit, push the current branch, and open a **draft PR** in one flow.

Arguments: $ARGUMENTS

## Your Task

1. Parse arguments as:
   - `commit-message` (required)
   - `pr-title` (optional)
2. Verify current branch is not `main`.
3. Show changed files and ask for confirmation.
4. Execute:

```bash
git add -A
git commit -m "<commit-message>"
git push -u origin "$(git branch --show-current)"
```

5. Create draft PR:
   - With title: `gh pr create --draft --title "<pr-title>" --fill`
   - Without title: `gh pr create --draft --fill`

## Safety

- Never run unless user explicitly invoked `/draft-pr`.
- If no changes exist, stop and report.
- On any failure, stop immediately and report next manual action.
