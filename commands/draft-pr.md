# Draft PR Command

Create a commit, push the current branch, and open a **draft PR** in one flow.

## Usage

`/draft-pr <commit-message> [pr-title]`

Examples:
- `/draft-pr "fix: sanitize session id path"`
- `/draft-pr "refactor: remove deprecated commands" "Refactor command set"`

## Steps

1. Ensure you're on a feature branch (not `main`).
2. Show changed files and ask for final confirmation.
3. Run:

```bash
git add -A
git commit -m "<commit-message>"
git push -u origin "$(git branch --show-current)"
```

4. Create draft PR:

```bash
gh pr create --draft --fill
```

If `pr-title` is provided, use:

```bash
gh pr create --draft --title "<pr-title>" --fill
```

## Rules

- Never run this flow unless user explicitly invokes `/draft-pr`.
- If there are no staged/changed files, stop and report.
- If commit fails, stop and report the error without retrying destructive actions.
