---
description: Fix Go build errors, go vet warnings, and linter issues incrementally. Invokes the go-build-resolver agent for minimal, surgical fixes.
---

# Go Build and Fix

Fix Go build and static analysis failures with minimal changes.

This command invokes the `go-build-resolver` agent.

## Workflow

1. Discover repository Go commands from `AGENTS.md`, README, Makefile, mise, CI, and scripts.
2. Run the narrowest relevant command first, usually `go test ./...`, `go build ./...`, `go vet ./...`, or the project wrapper.
3. Parse errors by package and file. Fix compile blockers before lint or cleanup issues.
4. Apply one small fix at a time and rerun the relevant command.
5. Use `go mod tidy` only when module files are actually implicated.
6. Finish with a summary of commands run, errors fixed, and any remaining failures.

Preserve existing architecture and generated-code boundaries.

## Diagnostic commands

```bash
go build ./...
go vet ./...
staticcheck ./...       # if available
golangci-lint run       # if available
go mod verify
go mod tidy -v
```

## Stop conditions

Stop and report if: the same error persists after 3 attempts, a fix introduces more errors, the fix requires architectural changes, or a dependency is missing.

## Related commands

- `/go-test` - run tests after build succeeds
- `/go-review` - review code quality
- `/verify` - full verification loop
