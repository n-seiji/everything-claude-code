# Plugin Manifest Schema Notes

This document captures constraints of the Claude Code plugin manifest validator that are enforced but not fully documented in public schema references.

If you edit `.claude-plugin/plugin.json`, read this first.

---

## Required Fields

### `version` (MANDATORY)

The `version` field is required by the validator even if omitted from some examples. If missing, installation may fail during marketplace install or CLI validation.

```json
{
  "version": "1.4.2"
}
```

---

## Field Shape Rules

The following fields **must always be arrays**:

* `agents`
* `commands`
* `skills`
* `hooks` (if present)

Even if there is only one entry, strings are not accepted.

### Invalid

```json
{
  "agents": "./agents"
}
```

### Valid

```json
{
  "agents": ["./agents/planner.md"]
}
```

---

## Path Resolution Rules

### Agents must use explicit file paths

The validator does not accept directory paths for `agents`. Even the following fails:

```json
{
  "agents": ["./agents/"]
}
```

Instead, enumerate agent files explicitly:

```json
{
  "agents": [
    "./agents/planner.md",
    "./agents/architect.md",
    "./agents/code-reviewer.md"
  ]
}
```

### Commands and skills

* `commands` and `skills` accept directory paths only when wrapped in arrays.
* Explicit file paths are safest and most future-proof.

---

## Validator Behavior Notes

* `claude plugin validate` is stricter than some marketplace previews.
* Validation may pass locally but fail during install if paths are ambiguous.
* Errors are often generic (`Invalid input`) and do not indicate the root cause.
* Cross-platform installs (especially Windows) are less forgiving of path assumptions.

Assume the validator is hostile and literal.

---

## The `hooks` field: do not add it to `plugin.json`

Claude Code automatically loads `hooks/hooks.json` from any installed plugin by convention. If you also declare it in `plugin.json`, you get:

```
Duplicate hooks file detected: ./hooks/hooks.json resolves to already-loaded file.
The standard hooks/hooks.json is loaded automatically, so manifest.hooks should
only reference additional hook files.
```

If you add additional hook files beyond `hooks/hooks.json`, those can be declared in the manifest. The standard `hooks/hooks.json` must not be.

---

## Known Anti-Patterns

These look correct but are rejected:

* String values instead of arrays
* Arrays of directories for `agents`
* Missing `version`
* Relying on inferred paths
* Assuming marketplace behavior matches local validation
* Adding `"hooks": "./hooks/hooks.json"` — auto-loaded by convention, causes a duplicate error

Avoid cleverness. Be explicit.

---

## Minimal Known-Good Example

```json
{
  "version": "1.4.2",
  "agents": [
    "./agents/planner.md",
    "./agents/code-reviewer.md"
  ],
  "commands": ["./commands/"],
  "skills": ["./skills/"]
}
```

Notice there is no `"hooks"` field — `hooks/hooks.json` is loaded automatically by convention.

---

## Recommendation for Contributors

Before submitting changes that touch `plugin.json`:

1. Use explicit file paths for agents.
2. Ensure all component fields are arrays.
3. Include a `version`.
4. Run:

```bash
claude plugin validate .claude-plugin/plugin.json
```

If in doubt, choose verbosity over convenience.
