---
name: tdd
description: Implement changes with a red-green-refactor test-driven workflow. Use when the user invokes tdd or asks to write tests first.
allowed-tools: Bash, Read, Write, Edit, bash, read_file, write_file
---

# TDD

Drive implementation through tests. The goal is clean code that works — TDD is a development technique, not a testing technique.

## Workflow

1. Write a TODO list of the behaviors to build, in the language of the problem.
2. Pick the next item: the one that teaches the most, or is easiest to make pass.
3. Red: write one failing test for that behavior. Write the assertion first, then the setup needed to reach it. Run it and confirm it fails for the intended reason.
4. Green: make it pass by the fastest means — Fake It (return a constant), then Triangulation (add a second example to force generalization) or Obvious Implementation when the real code is clear.
5. Refactor: remove duplication, including duplication between the test and the code, while green.
6. Tick the TODO item, add newly discovered items, and repeat.

Never write more than one failing test at a time. If a test stays red too long, take a smaller step.

Tests describe WHAT (one behavior per test, Arrange/Act/Assert, no logic, minimal mocking of process boundaries only); production code shows HOW. Coverage is a byproduct and a signal, not a goal — never write a test only to raise a percentage; respect a repository-configured threshold if one exists.
