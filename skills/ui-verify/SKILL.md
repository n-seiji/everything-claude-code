---
name: ui-verify
description: Use when the user says 「動作確認して」「スクショ撮って」「実機で見て」 (check it works / take a screenshot / try it on the real app), after any UI change before reporting it done, or when writing a PR's 動作確認 (verification) section.
---

# UI Verify

A workflow that verifies a running web app in real Chrome via the `ui-verifier` subagent, and records measured results in a PR / report.

## When to use it / when not to

- Use it for things you can only learn by actually rendering and interacting: layout breakage, focus movement, dialog open/close, routing transitions
- Not a substitute for unit/component tests. Logic correctness is covered by existing tests; this skill is for confirming "facts visible on screen"

## Environment setup

1. Confirm which worktree the dev server should be serving (if CORS restricts the origin, only one worktree can hold the port)
2. Stop the existing dev server and start it from the target worktree in the background. Send logs to the scratchpad
3. After verification, switch the dev server back to the original worktree and note that explicitly in the report
4. If a branch switch or DB row change was needed for verification, record both the switch and the fact that it was reverted in the report

## What to request from the `ui-verifier` subagent

Spell out the following as a numbered list in the request.

1. URL and port
2. Login state (must already be logged in)
3. Target worktree / branch
4. Check items (numbered), each with the expected result and the JS fact to measure (e.g. `getBoundingClientRect`)

## Attaching screenshots to a PR

1. Open the target PR page in connected Chrome
2. Use `find` to locate the `input[type=file]` that belongs to the **new comment form** (don't confuse it with the one in the PR body edit form)
3. Upload it with `file_upload` and wait until the "Uploading" text disappears
4. Use `javascript_tool` to read the `<img ... src="https://github.com/user-attachments/assets/...">` line from that textarea
5. Delete those lines from the textarea (don't submit the comment)
6. Use the obtained image URL to post the comment/body via `gh pr comment --body-file` / `gh pr edit --body-file`
7. The tabs group can get lost; if something fails partway, re-run `tabs_context_mcp {createIfEmpty: true}`

## PR report format

- A verification table (`Item / Result / Measured value`)
- Screenshots
- A breakdown of which checks were automated vs. done manually
