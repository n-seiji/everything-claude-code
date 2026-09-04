---
name: go-test
description: Add or run Go tests using idiomatic table-driven testing and focused verification. Use when the user invokes go-test or asks for Go test coverage.
allowed-tools: Bash, Read, Write, Edit, bash, read_file, write_file
---

# Go Test

Use focused, TDD-driven Go testing to verify behavior.

## Workflow

1. Write a TODO list of the behaviors the package needs, in the language of the problem.
2. Pick the next item and identify the existing table-driven test style to extend.
3. Red: add one failing subtest case with a clear case name and explicit expected value. Run it and confirm it fails for the intended reason.
4. Green: make it pass by the fastest means — Fake It, then Triangulation (a second case that forces generalization) or an obvious implementation when the logic is clear.
5. Refactor while green: remove duplication between cases, tighten error messages.
6. Tick the TODO item, add newly discovered items, and repeat.
7. Run the narrow package test after each cycle, then `go test -race ./...` for broader confidence.
8. Report test commands, pass/fail status, and coverage as a signal for untested behavior, not a target.

Avoid brittle sleeps, network calls, and order-dependent assertions unless the project already uses them intentionally. Never write a test only to raise coverage; respect a repository-configured threshold if one exists.
