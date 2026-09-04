---
name: seiji-judgment-prefs
description: Use when making design, scoping, or technical decisions for seiji (n-seiji) — deciding what to build or cut, sizing scope, choosing between approaches, weighing DB schema changes or migrations, splitting work into separate PRs/issues, or judging robustness, cost, and compliance impact.
---

# seiji's judgment and decision-making preferences

Consistent decision axes seiji applies to "what to choose," extracted from 800+ past instructions.

## Iron rules (strongly and repeatedly requested)

- **Apply YAGNI rigorously.** Aggressively cut unneeded features and elements. Don't build what isn't needed now.
- **Keep scope minimal and proceed in stages.** Don't widen scope all at once; start from the necessary range.
- **Reuse existing assets and mechanisms first.** Before creating a new table, check whether an existing column can do the job. Build on existing operations, implementation, and conventions.
- **Never take an agent's conclusion or proposal at face value — push back for the reasoning.** Always confirm "why is this the right call."
- **Have alternatives considered before implementation starts.** Lay out options and their trade-offs before choosing.
- **Split off derived issues or large changes into a separate PR / issue / later work.** Don't mix them into the main thread.
- **Be strongly wary of the cost and risk of DB schema changes and migrations.** Avoid them where possible; when necessary, scrutinize the impact precisely.
- **When undecided, make a call and move forward. Skip it if it's too hard.** Don't stall chasing perfection.
- **Verify robustness, non-destructiveness, and blast radius.** Ensure existing behavior isn't broken and that past-point-in-time values can still be guaranteed, etc.
- **Prioritize separating production from other environments and controlling by permissions.** Factor environment and permission differences into decisions.
- **Bring legal, compliance, and audit considerations into the decision early** (relevant laws for the business domain).
- **Use cost, low implementation cost, and simplicity as decision axes.** Choose the cheap, simple path.
- **Prioritize clarity, limiting the amount of information shown, and placement suited to use.** Trim what's shown and put it where it's used.
- **Trace the origin and validity of "why it's like this."** Confirm the history of the current state (since when, whose change) before acting.
- **For unreleased features, drop backward compatibility and change boldly.** If it hasn't shipped to production yet, don't worry about compatibility.
- **Tightly scope the target range** (clearly limit what's displayed or processed).
- **Keep options few and be willing to decide quickly — but reconsider if demand becomes clear.**

## Other tendencies

- Use loose coupling and easy replaceability as a design decision axis (with future migration in mind).
- For heavy aggregations, consider batching and accumulation, and insist on accuracy.
- Verbalize discomfort and stop to reconsider; don't hesitate to change direction.
- Value consistency: information visible to customers should also be visible on internal screens.
- Don't take naming and terminology lightly; work them out for accuracy and clarity.
- Reduce individual implementation effort through componentization and shared code.
- Propose your own workaround for environment constraints and move past them quickly.
- Don't over-engineer features meant to be temporary or one-off.

## Common violations (red flags — stop on sight)

- Adding a new table or feature without checking existing columns/mechanisms first
- Expanding scope beyond what was requested "while at it"
- Presenting only one option and jumping straight to implementation
- Casually proposing a schema change or migration
- Changing something without investigating "why it's currently like this"
