---
name: project-guidelines-example
description: Use as a template when creating a project-specific guidelines skill; not applied to real work by itself.
---

# Project Guidelines Skill (Example)

This is an example of a project-specific skill. Use this as a template for your own projects.

All names, URLs, and keys below are placeholders.

---

## When to Use

Reference this skill when working on the specific project it's designed for. Project skills contain architecture overview, file structure, code patterns, testing requirements, and deployment workflow.

---

## Architecture Overview

**Tech Stack:**
- **Frontend**: Next.js 15, TypeScript, React
- **Backend**: Go (net/http or chi), sqlc or database/sql
- **Database**: PostgreSQL
- **Deployment**: Google Cloud Run
- **Testing**: `go test`, Vitest + React Testing Library, Playwright (E2E)

**Services:**
```
┌───────────────────────────────┐
│ Frontend: Next.js + TS         │
│ Deployed: Vercel / Cloud Run   │
└───────────────────────────────┘
              │
              ▼
┌───────────────────────────────┐
│ Backend: Go + chi + sqlc       │
│ Deployed: Cloud Run            │
└───────────────────────────────┘
        │            │
        ▼            ▼
  ┌──────────┐  ┌──────────┐
  │ Postgres │  │  Redis   │
  └──────────┘  └──────────┘
```

---

## File Structure

```
project/
├── frontend/
│   └── src/
│       ├── app/               # Next.js app router pages
│       │   ├── api/           # API routes
│       │   ├── (auth)/        # Auth-protected routes
│       │   └── workspace/     # Main app workspace
│       ├── components/        # React components (ui/, forms/, layouts/)
│       ├── hooks/             # Custom React hooks
│       ├── lib/               # Utilities
│       └── types/             # TypeScript definitions
│
├── backend/
│   ├── cmd/server/main.go     # Entry point
│   ├── internal/
│   │   ├── http/              # Handlers, routing
│   │   ├── domain/            # Core types, business logic
│   │   ├── store/             # Database access
│   │   └── auth/              # Authentication
│   └── go.mod
│
├── deploy/                    # Deployment configs
└── docs/                      # Documentation
```

Tests live next to sources as `*_test.go`.

---

## Code Patterns

### API Response Format (Go)

```go
type ApiResponse[T any] struct {
	Success bool   `json:"success"`
	Data    *T     `json:"data,omitempty"`
	Error   string `json:"error,omitempty"`
}

func OK[T any](data T) ApiResponse[T] {
	return ApiResponse[T]{Success: true, Data: &data}
}

func Fail[T any](err string) ApiResponse[T] {
	return ApiResponse[T]{Success: false, Error: err}
}
```

### Frontend API Calls (TypeScript)

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
}

const fetchApi = async <T,>(
  endpoint: string,
  options?: RequestInit
): Promise<ApiResponse<T>> => {
  try {
    const response = await fetch(`/api${endpoint}`, options)
    if (!response.ok) {
      return { success: false, error: `HTTP ${response.status}` }
    }
    return await response.json()
  } catch (error) {
    return { success: false, error: String(error) }
  }
}
```

### External API Integration via Interface (Go)

Define a small interface at the call site so it can be faked in tests:

```go
type Analyzer interface {
	Analyze(ctx context.Context, content string) (Result, error)
}

type Result struct {
	Summary    string
	Confidence float64
}

func Summarize(ctx context.Context, a Analyzer, content string) (Result, error) {
	res, err := a.Analyze(ctx, content)
	if err != nil {
		return Result{}, fmt.Errorf("analyze: %w", err)
	}
	return res, nil
}
```

### Custom Hooks (React)

```typescript
import { useState, useCallback } from 'react'

interface UseApiState<T> {
  data: T | null
  loading: boolean
  error: string | null
}

export const useApi = <T,>(fetchFn: () => Promise<ApiResponse<T>>) => {
  const [state, setState] = useState<UseApiState<T>>({ data: null, loading: false, error: null })

  const execute = useCallback(async () => {
    setState(prev => ({ ...prev, loading: true, error: null }))
    const result = await fetchFn()
    if (result.success) {
      setState({ data: result.data!, loading: false, error: null })
    } else {
      setState({ data: null, loading: false, error: result.error! })
    }
  }, [fetchFn])

  return { ...state, execute }
}
```

---

## Testing Requirements

### Backend (`go test`)

```bash
go test -race ./...   # race detection
go test -cover ./...  # coverage
```

**Table-driven test example:**
```go
func TestSummarize(t *testing.T) {
	tests := []struct{ name, content, want string }{
		{"short text", "hi", "hi summary"},
		{"empty text", "", ""},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := fakeSummarize(tt.content); got != tt.want {
				t.Errorf("fakeSummarize(%q) = %q; want %q", tt.content, got, tt.want)
			}
		})
	}
}
```

### Frontend (React Testing Library)

```bash
# Run tests
npm run test

# Run with coverage
npm run test -- --coverage

# Run E2E tests
npm run test:e2e
```

**Test structure:**
```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { WorkspacePanel } from './WorkspacePanel'

describe('WorkspacePanel', () => {
  it('renders workspace correctly', () => {
    render(<WorkspacePanel />)
    expect(screen.getByRole('main')).toBeInTheDocument()
  })
})
```


---

## Deployment Workflow

### Pre-Deployment Checklist

- [ ] All tests passing locally
- [ ] `npm run build` succeeds (frontend); `go build ./...` and `go test -race ./...` pass (backend)
- [ ] No hardcoded secrets, env vars documented, migrations ready

### Deployment Commands

```bash
cd frontend && npm run build && gcloud run deploy frontend --source .
cd backend && gcloud run deploy backend --source .
```

### Environment Variables

```bash
NEXT_PUBLIC_API_URL=https://api.example.com   # frontend
DATABASE_URL=postgres://...                    # backend
EXTERNAL_API_KEY=xxx...                        # backend
```

---

## Critical Rules

1. **No emojis** in code, comments, or documentation
2. **Immutability** - never mutate objects or arrays
3. **TDD** - write a failing test first; treat coverage as a signal, not a target
4. **Many small files** - 200-400 lines typical, 800 max
5. **No console.log** in production code
6. **Error handling** - wrap Go errors with context, use try/catch in TS
7. **Input validation** at API boundaries (request structs / Zod)

---

## Related Skills

- `coding-standards`, `golang-patterns`, `frontend-patterns`
