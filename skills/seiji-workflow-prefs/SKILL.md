---
name: seiji-workflow-prefs
description: Use when doing development work for seiji (n-seiji) — creating GitHub issues, opening or updating PRs, handling PR review comments from AI reviewers/bots, branching, git worktree work, commits/pushes, delegating implementation to subagents, deploying, or reporting work status.
---

# seiji's workflow preferences

The fixed process seiji expects for "how development work proceeds," extracted from 800+ past instructions.

## Iron rules (strongly and repeatedly requested)

- **Delegate implementation to subagents; own planning, investigation, and review yourself.** Before entering the code-writing phase, always draft an implementation plan, present it, and get approval. Assume the actual implementation is delegated to an Agent tool subagent (`model: "sonnet"`) by default. Edit directly yourself only when seiji explicitly says "you can do this one yourself" or when the subagent has stalled. When delegating, state the finalized plan, reference files, and constraints (tests, coding conventions) explicitly in the prompt. If there are several independent tasks, dispatch them in parallel in a single message.
- **Be suspicious of whether the subagent is actually running.** After delegating, check and report whether it's really working. If there's no response for a long time, proactively report the possibility of a stall and propose switching to direct work or providing a prompt. Don't cling to delegation.
- **Create PRs as draft by default.** Draft even without explicit instruction. For changes spanning multiple repos, open a separate draft PR per repo. Wait for seiji's separate approval before converting to a regular PR or merging.
- **Always complete the "address → reply → resolve" triad for PR review comments.** Even after addressing a comment, check all threads at the end to make sure none are left unresolved. For AI reviewer (bot) findings, triage by severity (IMPORTANT / HIGH or above) rather than handling every item, and give a reason for anything left unaddressed. Repeatedly check whether new comments have appeared.
- **Run PR review with multiple specialized agents in parallel, leaving results as inline comments on GitHub.** Use pr-review-toolkit and similar. Post only the specified severity/items, not everything. Follow "comment, don't fix" instructions and don't fix things on your own. Verify Critical findings by actually running the code. Leave impact scope and path information in the comments too.
- **Do code changes on a worktree slot; never edit the base clone.** Use the specified slot number if given, or check for a free slot first. The base clone is for verification only. Remove unneeded worktrees after finishing. Always track and report which worktree you're working in.
- **Explicitly confirm the branch's base every time.** Follow the specification for develop / release / hotfix / an existing feature branch. Follow the specified PR base too. In a stacked-PR setup, propagate fixes on an earlier PR to later PRs. Across repos, check each repo's origin branch individually. Update the branch before starting work.
- **Commit / push only at seiji's explicit direction and timing.** During prototyping, verification, or UI-check stages, respect "don't commit" if told so. After completion, commit/push in a batch as instructed, and clearly report "everything is pushed" once done. Destructive git operations like force push may be performed by seiji themself, so confirm before acting.
- **Separate work into phases and proceed with staged approval.** Don't jump straight into implementation; first present the design proposal, an implementation sketch, and the impact scope, and get a go-ahead. For UI changes, do the edit first, then set up a step to verify on the actual screen. Stay within the instructed scope (e.g. conflict resolution only) and don't move to the next stage on your own.
- **Investigate the real codebase before implementing and map out the blast radius.** Nail down callers and ripple effects before moving to an implementation request. Cross-check SQL/schema against existing definitions and past examples. For bugs, trace git history and reflog back to identify the causing commit.
- **Persist deliverables in issues / PRs / Notion / markdown, and manage the links between them.** Make investigation, spec decisions, and incident response durable. Set up both parent-child (sub-issue) and reference relations, link existing PRs, and leave implementation prompts in comments. If assumptions change, update the issue body and record why alternatives were rejected. Follow the established issue-filing procedure if one exists, and get preview approval before filing.
- **Never take an agent's report at face value — verify it.** Don't stop at "done"; show the evidence. Recheck yourself whether things are unaddressed / unresolved, whether pushes actually happened, and the subagent's running status before reporting.
- **After implementation, wrap up with review, a check for leftover code, and passing tests.** Run an independent review in a separate thread/subagent (does it match intent, does it comply with `.claude` rules, any unintended changes mixed in, any leftover unused code) and consider refactoring. Get lint/tests passing. Always fix CI failures.
- **Follow a skill's procedure and output format strictly; make improvements permanent by updating the skill.** Don't just save behavioral improvements to memory temporarily — update the skill body itself.
- **For work spanning multiple repos, plan / PR / push each one individually.**
- **Treat conflict resolution as a quick, routine task** and respond to it promptly.

## Other tendencies

- New APIs follow the fixed procedure: OpenAPI definition → auto-generation.
- Split large work into phases and proceed in stages.
- Nail down specs through a one-question-at-a-time Q&A style discussion.
- Build new templates on top of existing operational assets.

## Common violations (red flags — stop on sight)

- Starting to write code without presenting a plan
- Creating a regular PR instead of a draft
- Addressing a comment but forgetting to resolve it, or leaving threads unresolved
- Editing the base clone directly, or being unclear about which worktree you're in
- Moving to the next phase without waiting for approval
- Reporting "done" without verifying against real behavior
