---
description: Enforce test-driven development workflow. Scaffold interfaces, generate tests FIRST, then implement minimal code to pass. Ensure 80%+ coverage.
---

# TDD Command

Drive implementation through a red-green-refactor test-driven workflow.

This command invokes the `tdd-guide` agent.

## Workflow

1. Clarify the behavior and observable contract.
2. Inspect existing test patterns and choose the narrowest test layer that proves the behavior.
3. Write or modify a test that fails for the intended reason.
4. Run the narrow test and confirm the failure.
5. Implement the smallest code change to pass.
6. Re-run the test, then relevant broader checks.
7. Refactor only with tests green.
8. Check coverage and add more tests if below 80% (100% for critical code such as financial calculations, auth, or security logic).

If a true red test is impractical, explain why and choose the closest verification path.

## Related commands

- `/plan` first to understand what to build
- `/build-fix` if build errors occur
- `/code-review` to review implementation
- `/test-coverage` to verify coverage
