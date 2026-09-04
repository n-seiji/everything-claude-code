---
description: Generate and run end-to-end tests with Playwright. Creates test journeys, runs tests, captures screenshots/videos/traces, and uploads artifacts.
---

# E2E Command

Generate, run, or debug end-to-end tests.

This command invokes the `e2e-runner` agent.

## Workflow

1. Identify the target user journey and existing E2E framework. Prefer existing Playwright, Cypress, or project-specific conventions.
2. Inspect test structure, page objects, fixtures, environment setup, and CI commands.
3. For new coverage, write a focused test for the requested journey with stable selectors and clear assertions.
4. For failures, reproduce the failure, inspect screenshots/traces/logs when available, and fix the smallest root cause.
5. Run the narrow E2E command first, then broader checks when needed.
6. Report generated tests, artifacts, failures, and remaining risks.

Do not invent credentials or bypass application auth. Ask for missing secrets only when needed.

## Project-specific critical flows

List the journeys that must always pass here (none yet).

## CI/CD Integration

```yaml
# .github/workflows/e2e.yml
- name: Install Playwright
  run: npx playwright install --with-deps

- name: Run E2E tests
  run: npx playwright test

- name: Upload artifacts
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: playwright-report
    path: playwright-report/
```

## Quick Commands

```bash
npx playwright test                          # Run all E2E tests
npx playwright test tests/e2e/foo.spec.ts    # Run specific test file
npx playwright test --headed                 # Headed mode
npx playwright test --debug                  # Debug a test
npx playwright codegen http://localhost:3000 # Generate test code
npx playwright show-report                   # View HTML report
```

## Related commands

- `/plan` to identify critical journeys to test
- `/tdd` for unit tests (faster, more granular)
- `/code-review` to verify test quality
