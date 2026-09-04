---
description: Run project verification checks (build, types, lint, tests, security, git status) and report readiness.
---

# Verification Command

Run appropriate checks for the current repository state and report whether it's ready for a PR.

## Workflow

1. Discover verification commands from repository instructions, README, package scripts, Makefile, mise, CI, and language config.
2. Choose mode from `$ARGUMENTS`:
   - `quick`: build and type checks.
   - `pre-commit`: focused lint/test checks for changed files.
   - `pre-pr` or `full` (default): build, lint, tests, and security checks when available.
3. Run checks in dependency order: build/type, lint, tests, coverage, security/secrets, git status.
4. Stop early only when a failure blocks later checks.
5. Report:

   ```text
   VERIFICATION: PASS/FAIL
   Build:
   Types:
   Lint:
   Tests:
   Security:
   Git:
   Ready for PR:
   ```

Include exact commands run and any failures, with fix suggestions for critical issues.
