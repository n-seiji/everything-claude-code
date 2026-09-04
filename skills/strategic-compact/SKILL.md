---
name: strategic-compact
description: Use when deciding whether to run /compact, or to understand the plugin's built-in tool-call counter hook.
---

# Strategic Compact Skill

Suggests when to run `/compact` yourself instead of waiting for automatic
compaction to fire mid-task.

## Why Strategic Compaction?

Auto-compaction triggers at arbitrary points, often mid-task, with no
awareness of logical task boundaries. Compacting at logical boundaries instead
works better:
- **After exploration, before execution** - keep the plan, drop research context
- **After completing a milestone** - fresh start for the next phase
- **Before major context shifts** - clear exploration context before a different task

## How It Works

The plugin registers `scripts/hooks/suggest-compact.js` as a `PreToolUse` hook
on the `Edit|Write` matcher (see `hooks/hooks.json`). On each matching tool
call it:

1. Increments a per-session tool-call counter (a temp file keyed by session
   ID).
2. Once the counter reaches `COMPACT_THRESHOLD` (env var, default `50`), logs
   a suggestion to consider `/compact` if you're transitioning phases.
3. After that, logs the same reminder every 25 calls.

The hook only logs a suggestion — it never runs `/compact` itself; you decide
whether the moment is right.

## Configuration

- `COMPACT_THRESHOLD` - tool calls before the first suggestion (default: 50)

## Best Practices

1. **Compact after planning** - Once plan is finalized, compact to start fresh
2. **Compact after debugging** - Clear error-resolution context before continuing
3. **Don't compact mid-implementation** - Preserve context for related changes
4. **Read the suggestion** - The hook tells you *when*, you decide *if*
