---
name: coding-standards
description: Use when writing or reviewing TypeScript/JavaScript for naming, immutability, error handling, input validation, and file layout.
---

# Coding Standards & Best Practices

Universal coding standards for TypeScript/JavaScript projects.

## Code Quality Principles

- **Readability first** — clear names, self-documenting code, consistent formatting.
- **KISS** — simplest solution that works; no premature optimization.
- **DRY** — extract shared logic into functions/modules instead of copy-paste.
- **YAGNI** — don't build for hypothetical future needs; add complexity only when required.

## TypeScript/JavaScript Standards

### Naming

```typescript
// GOOD: descriptive
const isUserAuthenticated = true;
const totalRevenue = 1000;

const fetchMarketData = async (marketId: string): Promise<Market> => { /* ... */ };
const isValidEmail = (email: string): boolean => /.+@.+/.test(email);

// BAD: unclear
const flag = true;
const x = 1000;
const market = async (id) => { /* ... */ };
```

### Functions: arrow functions only

Define functions as `const fn = () => {}`. Do not use `function` declarations, except for generator functions (`function*`); note the reason in a comment if `function` appears elsewhere.

Code examples elsewhere in this plugin may still use `function` for brevity; the rule applies to code you write.

### Immutability (critical)

Never mutate existing objects or arrays; always produce a new copy.

```typescript
// GOOD
const updatedUser = { ...user, name: "New Name" };
const updatedItems = [...items, newItem];

// BAD
user.name = "New Name"; // mutation
items.push(newItem); // mutation
```

### Error handling

Handle errors explicitly at every level; never swallow them silently.

```typescript
const fetchData = async (url: string): Promise<unknown> => {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    return await response.json();
  } catch (error) {
    console.error("Fetch failed:", error);
    throw new Error("Failed to fetch data");
  }
};
```

### Type safety: no `any`

Use concrete types or generics. If a third-party type is genuinely missing, use `unknown` plus a type guard, and document why with an inline lint-disable comment — never `any` silently.

```typescript
// GOOD
type Market = Readonly<{
  id: string;
  name: string;
  status: "active" | "resolved" | "closed";
  createdAt: Date;
}>;

const getMarket = (id: string): Promise<Market> => { /* ... */ };

// BAD
const getMarket = (id: any): Promise<any> => { /* ... */ };
```

### No `enum`

Use a union type or an `as const` array/object instead of `enum`.

```typescript
// GOOD
const MARKET_STATUSES = ["active", "resolved", "closed"] as const;
type MarketStatus = (typeof MARKET_STATUSES)[number];

// BAD
enum MarketStatus { Active, Resolved, Closed }
```

### `Readonly` and `readonly` arrays

Apply `Readonly<T>` to object parameters/props and `readonly T[]` to array parameters, so callers cannot mutate what they pass in.

```typescript
type ButtonProps = Readonly<{
  label: string;
  onClick: () => void;
}>;

const sum = (values: readonly number[]): number =>
  values.reduce((total, value) => total + value, 0);
```

### Minimal `export`

Export only what other files actually import. Keep internal helpers unexported; test them through the public API.

```typescript
// GOOD: only the public entry point is exported
const PREFIX = "item_";
const toOption = (item: Readonly<{ id: string; name: string }>) => ({
  value: `${PREFIX}${item.id}`,
  label: item.name,
});
export const buildOptions = (items: readonly { id: string; name: string }[]) =>
  items.map(toOption);
```

## Input Validation

Validate all data at system boundaries (user input, API responses, file content) using schema-based validation, and fail fast with a clear error.

```typescript
import { z } from "zod";

const CreateMarketSchema = z.object({
  name: z.string().min(1).max(200),
  endDate: z.string().datetime(),
});

const parsed = CreateMarketSchema.parse(body);
```

## File Organization

- Many small, focused files beat few large ones: aim for 200–400 lines, 800 max.
- Organize by feature/domain, not by technical type.
- Naming: components `PascalCase.tsx`, hooks `useX.ts`, utilities `camelCase.ts`, types `x.types.ts`.

## Comments and Commit Messages

- Code shows HOW. Keep comments minimal.
- Tests state WHAT: the test name and assertions are the behavior statement.
- Commit messages explain WHY: what problem the change solves and why this approach.
- Code comments explain WHY NOT: the alternative that was rejected, the constraint that forced the shape, the trap a reader would fall into. A comment that restates the code is removed.

```typescript
// GOOD: explains why not (rejected alternative)
// Not using setTimeout here: it drifts under load; setInterval + drift-correction is exact
const delay = Math.min(1000 * 2 ** retryCount, 30000);

// BAD: states the obvious
// increment counter by 1
count++;
```

## Code Smells to Avoid

- **Long functions** (>50 lines) — split into smaller, named steps.
- **Deep nesting** (>3–4 levels) — use early returns/guard clauses instead.
- **Magic numbers** — extract named constants (`MAX_RETRIES`, `DEBOUNCE_DELAY_MS`).

## Code Quality Checklist

Before marking work complete:

- [ ] Names are clear and functions are small (<50 lines)
- [ ] Files are focused (<800 lines) and organized by feature
- [ ] No mutation; immutable update patterns used throughout
- [ ] Errors are handled explicitly, never swallowed
- [ ] All boundary input is schema-validated
- [ ] No `any`, no `enum`; `Readonly`/`readonly` applied to props and array params
- [ ] Only genuinely shared symbols are exported
