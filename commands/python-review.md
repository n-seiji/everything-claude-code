---
description: Comprehensive Python code review for PEP 8 compliance, type hints, security, and Pythonic idioms. Invokes the python-reviewer agent.
---

# Python Code Review

Review Python code with Python-specific checks.

This command invokes the `python-reviewer` agent.

## Workflow

1. Inspect changed Python files and related tests, config, dependencies, and CI.
2. Read repository guidance before reviewing.
3. Check for:
   - Unsafe `eval`, `exec`, pickle, YAML loading, shell execution, SQL construction, and path handling.
   - Missing or misleading type hints, mutable defaults, broad exception swallowing, and resource leaks.
   - Async misuse, concurrency hazards, and blocking operations in async paths.
   - Packaging, dependency, import, and environment issues.
   - Missing tests for edge cases and error paths.
4. Run or inspect `ruff`, `mypy`, `pytest`, `bandit`, or project wrappers when practical.
5. Return findings first with severity and file:line references.

Do not edit files during review unless asked.

## Approval criteria

| Status | Condition |
|--------|-----------|
| Approve | No CRITICAL or HIGH issues |
| Warning | Only MEDIUM issues (merge with caution) |
| Block | CRITICAL or HIGH issues found |

## Related commands

- `/tdd` first to ensure tests pass
- `/code-review` for non-Python specific concerns
- `/build-fix` if static analysis tools fail
