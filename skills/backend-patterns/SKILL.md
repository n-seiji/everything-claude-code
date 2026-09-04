---
name: backend-patterns
description: Use when designing or reviewing Node.js/Express/Next.js API routes, repositories, caching, auth middleware, or background jobs.
---

# Backend Development Patterns

Backend architecture patterns for scalable, maintainable server-side applications. Handlers and helpers are arrow functions with `Readonly` inputs; no `enum`; no `any`.

## API Design

```typescript
// Resource-based URLs; filtering/sorting/pagination via query params
GET    /api/items                 // list
GET    /api/items/:id             // read
POST   /api/items                 // create
PATCH  /api/items/:id             // partial update
DELETE /api/items/:id             // delete
GET    /api/items?status=active&sort=volume&limit=20&offset=0
```

### Response envelope

```typescript
type ApiResponse<T> = Readonly<{
  success: boolean;
  data?: T;
  error?: string;
  meta?: Readonly<{ total: number; page: number; limit: number }>;
}>;

// success
return NextResponse.json({ success: true, data: items, meta: { total: 100, page: 1, limit: 10 } });
// error
return NextResponse.json({ success: false, error: "Invalid request" }, { status: 400 });
```

### Input validation

Validate every request body/query with a schema and fail fast with details.

```typescript
import { z } from "zod";

const CreateItemSchema = z.object({ name: z.string().min(1).max(200) });

export const POST = async (request: Request) => {
  const body = await request.json();
  const result = CreateItemSchema.safeParse(body);
  if (!result.success) {
    return NextResponse.json({ success: false, error: "Validation failed", details: result.error.issues }, { status: 400 });
  }
  // proceed with result.data
};
```

## Repository & Service Layers

Keep data access behind an interface consumers depend on; keep business logic out of the data-access layer.

```typescript
type ItemFilters = Readonly<{ status?: string; limit?: number }>;

interface ItemRepository {
  findAll(filters?: ItemFilters): Promise<readonly Item[]>;
  findById(id: string): Promise<Item | null>;
  create(data: Readonly<CreateItemDto>): Promise<Item>;
}

const createService = (repo: ItemRepository) => ({
  search: async (query: string, limit = 10): Promise<readonly Item[]> => {
    const embedding = await generateEmbedding(query);
    const ranked = await vectorSearch(embedding, limit);
    const items = await repo.findAll({ limit });
    return items.filter((item) => ranked.some((r) => r.id === item.id));
  },
});
```

## Middleware

```typescript
export const withAuth =
  (handler: NextApiHandler): NextApiHandler =>
  async (req, res) => {
    const token = req.headers.authorization?.replace("Bearer ", "");
    if (!token) return res.status(401).json({ error: "Unauthorized" });
    try {
      req.user = await verifyToken(token);
      return handler(req, res);
    } catch {
      return res.status(401).json({ error: "Invalid token" });
    }
  };
```

## Database Patterns

```typescript
// Select only needed columns, filter/sort/limit in the query
const { data } = await db.from("items").select("id, name, status").eq("status", "active").limit(10);

// Batch-fetch to avoid N+1 queries
const items = await getItems();
const ownerIds = items.map((i) => i.ownerId);
const owners = await getUsers(ownerIds); // 1 query instead of N
const ownerById = new Map(owners.map((o) => [o.id, o]));
```

For multi-table writes that must succeed or fail together, use a database transaction (or an RPC/stored procedure) rather than sequential inserts from application code.

## Caching

Cache-aside: read through the cache, populate on miss, invalidate on write.

```typescript
const getItemCached = async (id: string): Promise<Item> => {
  const cacheKey = `item:${id}`;
  const cached = await redis.get(cacheKey);
  if (cached) return JSON.parse(cached);

  const item = await db.items.findUnique({ where: { id } });
  if (!item) throw new ApiError(404, "Item not found");

  await redis.setex(cacheKey, 300, JSON.stringify(item));
  return item;
};
```

## Error Handling

```typescript
class ApiError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message);
  }
}

const errorHandler = (error: unknown): Response => {
  if (error instanceof ApiError) {
    return NextResponse.json({ success: false, error: error.message }, { status: error.statusCode });
  }
  if (error instanceof z.ZodError) {
    return NextResponse.json({ success: false, error: "Validation failed", details: error.issues }, { status: 400 });
  }
  console.error("Unexpected error:", error);
  return NextResponse.json({ success: false, error: "Internal server error" }, { status: 500 });
};
```

For transient failures against external services, retry with exponential backoff (bounded attempts) rather than failing immediately or looping unbounded.

## Authentication & Authorization

```typescript
type Role = "admin" | "moderator" | "user";
type Permission = "read" | "write" | "delete" | "admin";

const rolePermissions: Readonly<Record<Role, readonly Permission[]>> = {
  admin: ["read", "write", "delete", "admin"],
  moderator: ["read", "write", "delete"],
  user: ["read", "write"],
};

const hasPermission = (role: Role, permission: Permission): boolean =>
  rolePermissions[role].includes(permission);

const requirePermission =
  (permission: Permission) =>
  (handler: (request: Request, user: Readonly<{ id: string; role: Role }>) => Promise<Response>) =>
  async (request: Request) => {
    const user = await requireAuth(request);
    if (!hasPermission(user.role, permission)) throw new ApiError(403, "Insufficient permissions");
    return handler(request, user);
  };
```

Verify JWTs (or session tokens) on every protected route; never trust a client-supplied user id or role.

## Rate Limiting

Track request counts per identifier (IP, API key, user id) in a sliding window, backed by Redis or an in-memory map for single-instance services, and reject over-limit requests with `429`.

## Background Jobs & Queues

Move slow or non-critical work (indexing, email, webhooks) off the request path into a queue; use a durable queue (SQS, Redis-backed, a job runner) in production, and always wrap job execution so one failing job doesn't stop the worker.

## Logging & Monitoring

Log structured JSON, not free text, and attach a request id so a single request's log lines can be correlated.

```typescript
const logger = {
  info: (message: string, context?: Readonly<Record<string, unknown>>) =>
    console.log(JSON.stringify({ timestamp: new Date().toISOString(), level: "info", message, ...context })),
  error: (message: string, error: Error, context?: Readonly<Record<string, unknown>>) =>
    console.log(JSON.stringify({ timestamp: new Date().toISOString(), level: "error", message, error: error.message, ...context })),
};
```

**Remember**: choose the pattern that matches actual scale and risk — a repository layer, cache, or queue adds real cost, so introduce each only when the complexity it solves is present.
