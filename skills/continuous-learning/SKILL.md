---
name: continuous-learning
description: Use to understand or configure the plugin's SessionEnd hook that flags sessions worth extracting reusable patterns from.
---

# Continuous Learning Skill

Flags Claude Code sessions worth mining for reusable patterns once they end.

## How It Works

The plugin registers `scripts/hooks/evaluate-session.js` on the `SessionEnd`
event (see `hooks/hooks.json`). At session end it:

1. Reads `skills/continuous-learning/config.json` for `min_session_length`
   (default 10) and `learned_skills_path` (default
   `~/.claude/skills/learned/`, resolved via `getLearnedSkillsDir()` in
   `scripts/lib/utils.js`).
2. Counts user messages in the session transcript.
3. Skips sessions shorter than `min_session_length`.
4. For longer sessions, logs a signal that the session should be reviewed for
   extractable patterns, and where to save any learned skill.

The hook only flags sessions and reports the target directory — it does not
write skill files itself. Extracting and saving a pattern as a skill under
`~/.claude/skills/learned/` is a manual step done by reviewing the flagged
session.

## Configuration

Edit `skills/continuous-learning/config.json`:

```json
{
  "min_session_length": 10,
  "extraction_threshold": "medium",
  "auto_approve": false,
  "learned_skills_path": "~/.claude/skills/learned/",
  "patterns_to_detect": [
    "error_resolution",
    "user_corrections",
    "workarounds",
    "debugging_techniques",
    "project_specific"
  ],
  "ignore_patterns": [
    "simple_typos",
    "one_time_fixes",
    "external_api_issues"
  ]
}
```

`patterns_to_detect` and `ignore_patterns` describe the kinds of patterns worth
capturing when reviewing a flagged session; the hook itself only checks
message count against `min_session_length`.

## Pattern Types

| Pattern | Description |
|---------|-------------|
| `error_resolution` | How specific errors were resolved |
| `user_corrections` | Patterns from user corrections |
| `workarounds` | Solutions to framework/library quirks |
| `debugging_techniques` | Effective debugging approaches |
| `project_specific` | Project-specific conventions |
