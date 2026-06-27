---
name: api-design
description: Design clean, consistent, and usable APIs including REST endpoints, function interfaces, and module boundaries. Use when designing HTTP APIs, library interfaces, service contracts, or any programmatic interface between components. Triggers on "design an API", "create endpoints", "define the interface", "API specification", or when planning how components will communicate.
---

# API Design

Design APIs that are intuitive, consistent, and maintainable. This skill covers REST APIs, function/method interfaces, and module boundaries.

## Core Principles

### 1. Consistency Over Cleverness
Users learn patterns. Once they understand one endpoint/function, they should be able to predict others.

### 2. Explicit Over Implicit
Don't hide behavior. If something important happens, it should be visible in the interface.

### 3. Hard to Misuse
Good APIs make wrong usage difficult. Guide users toward correct usage through design.

### 4. Minimal Surface Area
Expose only what's needed. Every public interface is a commitment to maintain.

## REST API Design

### URL Structure

```
# Resources are nouns (plural)
GET    /users              # List users
POST   /users              # Create user
GET    /users/{id}         # Get specific user
PUT    /users/{id}         # Replace user
PATCH  /users/{id}         # Update user fields
DELETE /users/{id}         # Delete user

# Nested resources for relationships
GET    /users/{id}/posts   # User's posts
POST   /users/{id}/posts   # Create post for user

# Use query params for filtering/pagination
GET    /users?status=active&page=2&limit=20
GET    /posts?author={userId}&sort=-created
```

### Naming Conventions

**Do:**
- Use plural nouns: `/users`, `/orders`, `/products`
- Use kebab-case: `/user-profiles`, `/order-items`
- Use lowercase: `/api/v1/users`
- Be specific: `/orders/{id}/line-items` not `/orders/{id}/items`

**Don't:**
- Use verbs in URLs: ~~`/getUsers`~~, ~~`/createOrder`~~
- Use actions as resources: ~~`/user/login`~~ (use `/auth/token` instead)
- Mix conventions: ~~`/Users`~~, ~~`/user_profiles`~~

### HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Retrieve resource(s) | Yes | Yes |
| POST | Create resource | No | No |
| PUT | Replace resource entirely | Yes | No |
| PATCH | Partial update | Yes* | No |
| DELETE | Remove resource | Yes | No |

*PATCH should be idempotent when properly implemented

### Response Codes

```
# Success
200 OK              - General success, body contains result
201 Created         - Resource created, include Location header
204 No Content      - Success, no body (e.g., DELETE)

# Client Errors
400 Bad Request     - Invalid request format/data
401 Unauthorized    - Authentication required
403 Forbidden       - Authenticated but not permitted
404 Not Found       - Resource doesn't exist
409 Conflict        - Conflicts with current state
422 Unprocessable   - Valid format but semantic errors

# Server Errors
500 Internal Error  - Unexpected server failure
502 Bad Gateway     - Upstream service failure
503 Unavailable     - Temporarily unavailable
```

### Request/Response Format

```json
// Request: POST /users
{
  "email": "user@example.com",
  "name": "Jane Doe",
  "role": "member"
}

// Response: 201 Created
{
  "id": "usr_123abc",
  "email": "user@example.com",
  "name": "Jane Doe",
  "role": "member",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}

// Error Response: 400 Bad Request
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Pagination

```json
// Request
GET /users?page=2&limit=20

// Response
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": true
  }
}

// Or cursor-based for large datasets
{
  "data": [...],
  "pagination": {
    "cursor": "eyJpZCI6MTIzfQ==",
    "hasMore": true
  }
}
```

### Filtering & Sorting

```
# Filtering
GET /products?category=electronics&minPrice=100&maxPrice=500
GET /users?status=active&role=admin

# Sorting (- prefix for descending)
GET /posts?sort=-createdAt,title
GET /products?sort=price,-rating

# Field selection
GET /users?fields=id,name,email
```

### Versioning

```
# URL versioning (recommended for simplicity)
/api/v1/users
/api/v2/users

# Header versioning
Accept: application/vnd.api+json;version=1

# Query param versioning
/api/users?version=1
```

## Function/Method Interface Design

### Naming

```python
# Verbs for actions
def create_user(data):
def validate_input(schema, data):
def send_notification(user, message):

# Nouns/adjectives for state queries
def is_valid(data):
def has_permission(user, action):
def get_user(user_id):

# Be specific about what's returned
def get_user_by_email(email):      # Better than get_user(email)
def find_users_by_status(status):  # Returns multiple
def get_active_user_count():       # Returns count, not users
```

### Parameters

```python
# Few required params, sensible defaults
def search_users(
    query: str,                    # Required
    *,                             # Force keyword arguments
    limit: int = 20,               # Optional with default
    offset: int = 0,
    include_inactive: bool = False
) -> list[User]:
    ...

# Use objects for many related params
@dataclass
class SearchOptions:
    limit: int = 20
    offset: int = 0
    include_inactive: bool = False
    sort_by: str = "created_at"

def search_users(query: str, options: SearchOptions = None):
    ...

# Avoid boolean flags that change behavior drastically
# Bad: def get_data(include_deleted: bool)
# Good: def get_data() and def get_all_data_including_deleted()
```

### Return Types

```python
# Be consistent about what's returned
def get_user(id: str) -> User | None:      # None if not found
def get_user_or_fail(id: str) -> User:     # Raises if not found
def find_users(query: str) -> list[User]:  # Empty list if none

# Use result objects for operations that can fail
@dataclass
class Result[T]:
    success: bool
    data: T | None
    error: str | None

def create_user(data: UserInput) -> Result[User]:
    ...
```

### Error Handling

```python
# Use specific exception types
class UserNotFoundError(Exception):
    def __init__(self, user_id: str):
        self.user_id = user_id
        super().__init__(f"User not found: {user_id}")

class ValidationError(Exception):
    def __init__(self, field: str, message: str):
        self.field = field
        self.message = message
        super().__init__(f"{field}: {message}")

# Document what exceptions can be raised
def get_user(user_id: str) -> User:
    """
    Get user by ID.
    
    Raises:
        UserNotFoundError: If user doesn't exist
        DatabaseError: If database connection fails
    """
    ...
```

## Module/Component Interface Design

### Boundaries

```
# Clear input/output contracts
┌─────────────────────────────────────┐
│           Auth Module               │
├─────────────────────────────────────┤
│ Inputs:                             │
│   - credentials                     │
│   - tokens                          │
│                                     │
│ Outputs:                            │
│   - User (authenticated)            │
│   - Token                           │
│   - AuthError                       │
│                                     │
│ Does NOT:                           │
│   - Store user data                 │
│   - Send emails                     │
│   - Access other modules directly   │
└─────────────────────────────────────┘
```

### Dependency Direction

```
# Dependencies point inward (Clean Architecture)

UI Layer          → depends on → Application Layer
Application Layer → depends on → Domain Layer
Domain Layer      → depends on → Nothing

# Abstractions at boundaries
interface UserRepository:
    def get(id: str) -> User
    def save(user: User) -> None

# Implementations provided externally
class PostgresUserRepository(UserRepository):
    ...
```

## API Documentation Template

```markdown
# API Specification

## Base URL
`https://api.example.com/v1`

## Authentication
All endpoints require Bearer token:
```
Authorization: Bearer <token>
```

## Endpoints

### Create User
`POST /users`

Create a new user account.

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | User's email address |
| name | string | Yes | Display name |
| role | string | No | User role (default: "member") |

**Response:** `201 Created`
```json
{
  "id": "usr_123",
  "email": "user@example.com",
  ...
}
```

**Errors:**
| Code | Description |
|------|-------------|
| 400 | Invalid request body |
| 409 | Email already exists |

### Get User
`GET /users/{id}`
...
```

## Design Checklist

### Before Designing
- [ ] Who will use this API?
- [ ] What are the common use cases?
- [ ] What are the edge cases?
- [ ] What constraints exist (performance, compatibility)?

### During Design
- [ ] Are names clear and consistent?
- [ ] Are there sensible defaults?
- [ ] Is error handling explicit?
- [ ] Is it hard to misuse?
- [ ] Is the surface area minimal?

### After Design
- [ ] Can a new user understand it quickly?
- [ ] Does it handle expected errors gracefully?
- [ ] Is it documented?
- [ ] Is it versioned/evolvable?
