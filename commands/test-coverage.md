---
description: Use the coverage report to find risky untested behavior and add behavior-named tests for it — not to chase a percentage.
---

# Test Coverage

Find untested behavior and add tests for it:

1. Run tests with coverage: npm test --coverage or pnpm test --coverage

2. Analyze the coverage report (coverage/coverage-summary.json) to locate untested paths

3. Prioritize risky, untested behavior: business logic, error handling, edge cases (null, undefined, empty), boundary conditions, security-sensitive paths

4. For each gap, write a behavior-named test that asserts what the code should do, not that it merely runs

5. Verify new tests pass

6. Show before/after coverage metrics

7. If the repository has a configured coverage threshold, confirm it is met; do not invent a percentage target where none exists

Do not add tests solely to move a number. A high percentage with weak assertions is worse than a lower one with meaningful tests.
