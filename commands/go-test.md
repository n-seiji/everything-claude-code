---
description: Enforce TDD workflow for Go. Write table-driven tests first, then implement. Verify 80%+ coverage with go test -cover.
---

# Go TDD Command

Use focused Go testing to verify behavior, following the `tdd-guide` agent's red-green-refactor methodology.

This command invokes the `tdd-guide` agent. Apply the same red-green-refactor cycle with `go test`; the agent's examples are TypeScript.

## Workflow

1. Identify the package, behavior, and existing test style.
2. For new behavior or bug fixes, write a failing test first when feasible.
3. Prefer table-driven tests with clear case names, explicit expected values, and meaningful error messages.
4. Use mocks, fixtures, and integration helpers already present in the repository.
5. Run the narrow package test first, then broader project tests if the blast radius warrants it.
6. Report test commands, pass/fail status, and coverage gaps.

Avoid brittle sleeps, network calls, and order-dependent assertions unless the project already uses them intentionally.

## Coverage commands

```bash
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
go tool cover -func=coverage.out
go test -race -cover ./...
```

## Coverage targets

| Code Type | Target |
|-----------|--------|
| Critical business logic | 100% |
| Public APIs | 90%+ |
| General code | 80%+ |
| Generated code | Exclude |

## Related commands

- `/go-build` - fix build errors
- `/go-review` - review code after implementation
- `/verify` - run full verification loop
