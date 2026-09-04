---
name: frontend-patterns
description: Use when building React/Next.js components, hooks, forms, data fetching, error boundaries, or performance-sensitive UI.
---

# Frontend Development Patterns

React/Next.js patterns for maintainable, performant user interfaces. Components are arrow functions with `Readonly` props; arrays passed as props/args are `readonly`; no `enum`; no `any`.

## Component Patterns

### Composition over inheritance

```typescript
type CardProps = Readonly<{
  children: React.ReactNode;
  variant?: "default" | "outlined";
}>;

export const Card = ({ children, variant = "default" }: CardProps) => (
  <div className={`card card-${variant}`}>{children}</div>
);
export const CardHeader = ({ children }: Readonly<{ children: React.ReactNode }>) => (
  <div className="card-header">{children}</div>
);

// Usage: <Card><CardHeader>Title</CardHeader></Card>
```

### Compound components

Share implicit state between related components via context, rather than prop-drilling.

```typescript
type TabsContextValue = Readonly<{ activeTab: string; setActiveTab: (tab: string) => void }>;
const TabsContext = createContext<TabsContextValue | undefined>(undefined);

export const Tabs = ({ children, defaultTab }: Readonly<{ children: React.ReactNode; defaultTab: string }>) => {
  const [activeTab, setActiveTab] = useState(defaultTab);
  return <TabsContext.Provider value={{ activeTab, setActiveTab }}>{children}</TabsContext.Provider>;
};

export const Tab = ({ id, children }: Readonly<{ id: string; children: React.ReactNode }>) => {
  const context = useContext(TabsContext);
  if (!context) throw new Error("Tab must be used within Tabs");
  return (
    <button className={context.activeTab === id ? "active" : ""} onClick={() => context.setActiveTab(id)}>
      {children}
    </button>
  );
};
```

## Custom Hooks

Build small, composable hooks; keep each hook focused on one concern (see the project's testability rules: pure logic in, side effects isolated).

```typescript
export const useToggle = (initialValue = false): readonly [boolean, () => void] => {
  const [value, setValue] = useState(initialValue);
  const toggle = useCallback(() => setValue((v) => !v), []);
  return [value, toggle] as const;
};

export const useDebounce = <T,>(value: T, delayMs: number): T => {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const handle = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(handle);
  }, [value, delayMs]);
  return debounced;
};

// Async fetch hook: expose { data, error, loading, refetch }
type UseQueryOptions<T> = Readonly<{
  onSuccess?: (data: T) => void;
  onError?: (error: Error) => void;
  enabled?: boolean;
}>;

export const useQuery = <T,>(key: string, fetcher: () => Promise<T>, options?: UseQueryOptions<T>) => {
  const [state, setState] = useState<{ data: T | null; error: Error | null; loading: boolean }>({
    data: null,
    error: null,
    loading: false,
  });

  const refetch = useCallback(async () => {
    setState((s) => ({ ...s, loading: true, error: null }));
    try {
      const result = await fetcher();
      setState({ data: result, error: null, loading: false });
      options?.onSuccess?.(result);
    } catch (err) {
      const error = err as Error;
      setState((s) => ({ ...s, error, loading: false }));
      options?.onError?.(error);
    }
  }, [fetcher, options]);

  useEffect(() => {
    if (options?.enabled !== false) void refetch();
  }, [key, refetch, options?.enabled]);

  return { ...state, refetch };
};
```

Prefer a data-fetching library (TanStack Query, SWR) over hand-rolled `useQuery` for real server state; the pattern above is the shape to replicate if one isn't available.

## State Management: Context + Reducer

Use for state shared across a subtree that changes together. Model actions as a discriminated union, not an `enum`.

```typescript
type State = Readonly<{ items: Item[]; selected: Item | null; loading: boolean }>;
type Action =
  | { type: "setItems"; payload: readonly Item[] }
  | { type: "select"; payload: Item }
  | { type: "setLoading"; payload: boolean };

const reducer = (state: State, action: Action): State => {
  switch (action.type) {
    case "setItems":
      return { ...state, items: [...action.payload] };
    case "select":
      return { ...state, selected: action.payload };
    case "setLoading":
      return { ...state, loading: action.payload };
  }
};
```

Prefer `useState`/`useReducer` for local UI state, router search params for URL state, and a data-fetching library for server state — reach for Context only when state is genuinely shared and updates infrequently.

## Performance Optimization

```typescript
// Memoize expensive computation and stable callbacks
const sortedItems = useMemo(() => [...items].sort((a, b) => b.volume - a.volume), [items]);
const handleSearch = useCallback((query: string) => setSearchQuery(query), []);

// Wrap pure leaf components
export const ItemCard = React.memo(({ item }: Readonly<{ item: Item }>) => (
  <div className="item-card">{item.name}</div>
));

// Code-split heavy components
const HeavyChart = lazy(() => import("./HeavyChart"));
export const Dashboard = () => (
  <Suspense fallback={<Spinner />}>
    <HeavyChart />
  </Suspense>
);
```

For long lists, virtualize with a library such as `@tanstack/react-virtual` rather than rendering every row — render only the visible window plus a small overscan buffer.

## Forms

Validate on submit (and optionally on blur), keep errors in local state, and never mutate `formData` directly.

```typescript
type FormValues = Readonly<{ name: string; endDate: string }>;
type FormErrors = Readonly<{ name?: string; endDate?: string }>;

const validate = (values: FormValues): FormErrors => {
  const errors: { name?: string; endDate?: string } = {};
  if (!values.name.trim()) errors.name = "Name is required";
  if (!values.endDate) errors.endDate = "End date is required";
  return errors;
};
```

Prefer a form library (React Hook Form, Formik) for anything beyond a couple of fields; hand-rolled state works for simple cases.

## Error Boundaries

Wrap page-level and section-level UI in an error boundary with a retry path, ideally paired with your data-fetching library's reset mechanism (e.g. TanStack Query's `QueryErrorResetBoundary`).

```typescript
type BoundaryState = Readonly<{ hasError: boolean; error: Error | null }>;

export class ErrorBoundary extends React.Component<Readonly<{ children: React.ReactNode }>, BoundaryState> {
  state: BoundaryState = { hasError: false, error: null };
  static getDerivedStateFromError(error: Error): BoundaryState {
    return { hasError: true, error };
  }
  render() {
    if (this.state.hasError) {
      return (
        <div className="error-fallback">
          <p>{this.state.error?.message}</p>
          <button onClick={() => this.setState({ hasError: false })}>Try again</button>
        </div>
      );
    }
    return this.props.children;
  }
}
```

## Accessibility

- Support keyboard navigation on any interactive widget (arrow keys, `Enter`, `Escape`) and expose the right ARIA role/state (`role="combobox"`, `aria-expanded`).
- On opening a modal/dialog, move focus into it (`aria-modal="true"`); on close, restore focus to the element that opened it.
- Prefer semantic HTML elements over ARIA roles bolted onto generic `div`s wherever the semantics match.

**Remember**: choose the pattern that fits the component's actual complexity — don't add abstraction (context, virtualization, compound components) before it's needed.
