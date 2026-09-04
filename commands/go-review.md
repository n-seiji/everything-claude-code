---
description: Comprehensive Go code review for idiomatic patterns, concurrency safety, error handling, and security. Invokes the go-reviewer agent.
---

# Go Code Review

Review Go code with Go-specific checks.

This command invokes the `go-reviewer` agent.

## Workflow

1. Inspect changed Go files with `git diff -- '*.go'` plus related generated schemas, SQL, config, and tests.
2. Read repository guidance and Go conventions before reviewing.
3. Check for:
   - Incorrect error handling, missing context, lost cancellation, and panic misuse.
   - Data races, goroutine leaks, channel misuse, and lock ordering issues.
   - SQL/command injection, unsafe path handling, auth boundary mistakes, and sensitive logs.
   - Non-idiomatic APIs, overbroad interfaces, missing table tests, and weak edge coverage.
   - Performance issues such as missing map/slice capacity when sizes are known.
4. Run or inspect `go test`, `go vet`, `golangci-lint`, `staticcheck`, or project wrappers when practical.
5. Return findings first with severity and file:line references.

Do not edit files during review unless asked.

## Approval criteria

| Status | Condition |
|--------|-----------|
| Approve | No CRITICAL or HIGH issues |
| Warning | Only MEDIUM issues (merge with caution) |
| Block | CRITICAL or HIGH issues found |

## Related commands

- `/go-test` first to ensure tests pass
- `/go-build` if build errors occur
- `/code-review` for non-Go specific concerns
