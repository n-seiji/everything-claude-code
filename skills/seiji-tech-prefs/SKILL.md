---
name: seiji-tech-prefs
description: Use when writing or reviewing code for seiji (n-seiji) — building UI, calling or defining APIs, writing SQL, structuring React/TypeScript, styling with Tailwind, handling errors, designing data for later aggregation, or reviewing a diff. Covers seiji's concrete technical and coding preferences.
---

# seiji's technical and coding preferences

seiji's concrete technical preferences, extracted from 800+ past instructions.

## Iron rules (strongly and repeatedly requested)

- **Obsess over UI appearance and detail.** Don't miss duplicate displays, unnecessary text, missing animations, height jumps, or spacing issues. Squash pixel-level inconsistencies.
- **Standardize on OpenAPI contract-driven development + orval + TanStack Query.** APIs should flow from an OpenAPI definition to auto-generated types and hooks.
- **Prioritize conformance to existing implementation and conventions above all.** Match the surrounding code's patterns, naming, and structure. Don't introduce your own style.
- **Favor real data and real API connectivity over mocks.** If you want to use Faker for a quick placeholder display, say so explicitly, but by default verify against real data.
- **For SQL, prioritize lightness, production-ready formatting, and copy-paste runnability.** Avoid heavy queries; hand them over in a form that can be run as-is. Cross-check against existing SQL definitions.
- **Pair root-cause investigation, point-in-time/edge-case verification, and presenting multiple options as a set.** Go beyond surface-level fixes to the actual cause. Verify boundary conditions.
- **Run rule-compliant, multi-agent comprehensive review, prioritizing bug elimination above all.**
- **Prioritize flows and affordances that improve real operational efficiency.** Design UI that makes operations easier.
- **Consolidate Tailwind usage into design tokens; avoid arbitrary values and hardcoded colors.**
- **Frameworkize error handling and eliminate Sentry monitoring noise.**

## Other tendencies

- Clear React/code-convention preferences: avoid overusing `useEffect`, use named exports, avoid variable shadowing.
- Design data to accumulate for later aggregation, going as far as the DB definition.
- Avoid adding dependencies lightly; enforce custom implementation and DRY in code.
- Connect business structure and compliance considerations to the implementation.

## Common violations (red flags — fix on sight)

- Hitting the API by hand (not going through OpenAPI → orval / TanStack)
- Introducing your own style without looking at the surrounding existing patterns
- Using hardcoded colors or arbitrary values in Tailwind
- Missing duplicate UI displays, unnecessary text, or missing animations
- Calling it "done" while still on mocks, without verifying real API connectivity
- Settling for a symptomatic fix without addressing the root cause or edge cases
