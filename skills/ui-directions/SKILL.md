---
name: ui-directions
description: Use when the user says 「デザインパターン提案して」「UI の案いくつか」「どんな見た目がいいか迷ってる」 (propose design patterns / a few UI options / undecided on the look), when a screen family (list/settings/detail) needs a shared visual pattern, or before building a new area's screens.
---

# UI Directions

A workflow that lays out several UI directions side by side as artboards on a Claude Design canvas, compares them, picks one, and then codifies it into rules / primitives.

## Steps

1. **Gather real values first (don't design from memory)**
   - Design token definitions (e.g. Tailwind `@theme`, `tokens.css`, a theme file)
   - Shared UI primitives (button / card / badge / field, etc.): their implementation and variant definitions
   - Pull exact classes/px from the existing screen closest to the request (header, sidebar, table)
   - Treat any legacy or reference screenshot the user provides as a "structural reference" only — don't copy its colors or corner radii

2. **Name 2–3 directions with explicit axes**
   - Example: follow the existing panel style / filter bar + table / high-density + conditional side panel
   - Add the intent and trade-offs for each direction. Pick one leading candidate, but argue honestly for the others too (don't make them look weak just to pad out the set)
   - Add one "applied to another screen type" artboard for the leading candidate (e.g. if a list screen is the main subject, add one settings-form artboard). This shows the direction is a general pattern, not a one-off screen

3. **Delegate artboard creation to the `design-mockup-author` subagent**
   - Hand over: the token table (hex/px), component anatomy, sample data (real column names, realistic row data), each direction's spec, the sidebar/header content to replicate identically across all artboards, the frame size (e.g. desktop 1440×900), and a reference to the format conventions (the "Authoring the seed .dc.html" and "Quick syntax card" sections of the `design` skill's SKILL.md)
   - Require as output: `Main.dc.html` for the leading candidate, `DirectionA.dc.html` / `DirectionB.dc.html` / … for the other directions, and a `canvas.json` with intent/trade-off annotations above each direction

4. **Assemble with the `design` skill's helper**
   - Call `/design` to get the base directory, then run `seed-canvas.mjs --template … --out <name>.html --title … --artboard … --canvas canvas.json`, followed by `--check`
   - Use the design name under consideration for the file name/title. Don't use a generic name like `design.html`

5. **Always eyeball it before publishing**
   - The Chrome extension blocks `file://`, so start a static server (e.g. `python3 -m http.server <port>`) in the directory holding the seeded html and open `http://localhost:<port>/<name>.html`
   - Artboards mount lazily and thumbnails stay blank for a while — wait about 10 seconds
   - Expand (▷) and screenshot each artboard; for obvious defects (e.g. a button wrapping — add `white-space:nowrap; flex-shrink:0`, or a wrong header label) edit the `.dc.html` directly and re-seed
   - Always kill the http server after checking

6. **Publish as the `design` skill instructs**
   - Set the contract pin, capabilities chosen from the `artifact-capabilities` roster, and the favicon
   - After publishing, hand the user the link plus a one-line description of each direction

7. **Restructure and codify after the decision**
   - Re-seed using `pages`: page 1 "Adopted: X" with Main, the applied example, and a note on the decision rationale (target and type); page 2 "Considered alternatives" with the other directions and their notes
   - Republish at the same path
   - Codify: in the repo's rules location (e.g. `.claude/rules/<area>-screens.md`), write a recipe with correct/incorrect examples, a decision-criteria table, and exceptions
   - Only promote to a primitive what is actually used in 2+ places. Always confirm with the user before adding promotion targets

## Pitfalls

- `file://` is blocked by the Chrome extension. Always view through an http server
- Canvas thumbnails stay blank until mounted. Don't judge before publishing out of impatience
- An annotation y-offset around -160 lands above the name strip as a rule of thumb. Check it doesn't overlap the artboard
- Keep sidebar/header markup byte-identical across all artboards. Don't copy by hand — generate it with a small build script
- JPEG screenshots can crush low-contrast text into illegibility. For suspicious spots, check the computed color via JS
