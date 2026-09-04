---
description: Drive Go changes with TDD — write one failing table-driven subtest at a time, then the minimal code to pass, using go test -race and -cover for feedback.
---

# Go TDD Command

Use focused Go testing to verify behavior, following the `tdd-guide` agent's red-green-refactor methodology.

This command invokes the `tdd-guide` agent. Apply the same red-green-refactor cycle with `go test`; the agent's examples are TypeScript.

## Workflow

1. Write a TODO list of the behaviors the package needs, in the language of the problem.
2. Pick the next item and identify the existing table-driven test style to extend.
3. Red: add one failing subtest case for that behavior, with a clear case name and explicit expected value. Run it and confirm it fails for the intended reason.
4. Green: make it pass by the fastest means — Fake It, then Triangulation (add a second case that forces generalization) or an obvious implementation when the logic is clear.
5. Refactor while green: remove duplication between cases, tighten error messages, keep names accurate.
6. Tick the TODO item, add newly discovered items, and repeat.
7. Run the narrow package test after each cycle, then broader project tests if the blast radius warrants it.
8. Report test commands, pass/fail status, and coverage as a signal for untested behavior — not a target.

Avoid brittle sleeps, network calls, and order-dependent assertions unless the project already uses them intentionally.

## Coverage commands

```bash
go test -race ./...
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
go tool cover -func=coverage.out
```

Coverage highlights untested paths worth a behavior-named test. Never write a test only to move the percentage; respect a repository-configured coverage gate if one exists rather than inventing a target.

## Related commands

- `/go-build` - fix build errors
- `/go-review` - review code after implementation
- `/verify` - run full verification loop
