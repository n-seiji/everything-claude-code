---
description: Restate requirements, assess risks, and create step-by-step implementation plan. WAIT for user CONFIRM before touching any code.
---

# Plan Command

Produce a concrete implementation plan and wait for user confirmation before editing.

This command invokes the `planner` agent.

## Workflow

1. Restate the goal and constraints.
2. Inspect the repository enough to identify architecture, ownership boundaries, commands, and risk.
3. Break the work into ordered steps with dependencies.
4. Call out risks, validation commands, migrations, compatibility concerns, and open questions.
5. End by asking for confirmation or the specific decision needed.

Do not modify files while using this command unless the user explicitly says to proceed.

## Related commands

After planning:
- `/tdd` to implement with test-driven development
- `/build-fix` if build errors occur
- `/code-review` to review completed implementation
