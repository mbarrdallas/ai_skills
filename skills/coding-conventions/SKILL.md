---
name: coding-conventions
description: Apply consistent coding standards, naming conventions, and style guidelines across codebases. Use when writing code, reviewing code, establishing project standards, or ensuring consistency in implementation. Triggers on "follow conventions", "code style", "naming convention", "format code", or when implementing code that should match existing patterns. This skill includes language-specific overlays.
---

# Coding Conventions

Apply consistent coding standards to produce clean, maintainable, readable code. This skill covers universal principles and includes language-specific overlays.

## Universal Principles

### 1. Consistency Over Preference
Match the existing codebase style, even if you prefer something different. A consistent codebase is more important than any individual style choice.

### 2. Readability Over Cleverness
Code is read far more often than written. Optimize for understanding.

### 3. Explicit Over Implicit
Don't hide behavior. Make intentions clear.

### 4. Self-Documenting Code
Names and structure should explain what code does. Comments explain why.

## Naming Conventions

### General Rules

```
# Be descriptive
❌ d, tmp, data, info, x
✅ daysSinceLastLogin, temporaryAuthToken, userData

# Use pronounceable names
❌ genymdhms
✅ generationTimestamp

# Use searchable names
❌ 86400
✅ SECONDS_PER_DAY = 86400

# Avoid mental mapping
❌ for i in users: process(i)
✅ for user in users: process(user)
```

### Naming by Type

| Type | Convention | Examples |
|------|------------|----------|
| Classes | PascalCase, nouns | `UserAccount`, `PaymentProcessor` |
| Functions | camelCase/snake_case, verbs | `getUserById`, `validate_input` |
| Variables | camelCase/snake_case, nouns | `activeUsers`, `total_count` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRIES`, `API_BASE_URL` |
| Booleans | is/has/can/should prefix | `isActive`, `hasPermission` |
| Collections | Plural nouns | `users`, `orderItems` |

### Naming by Purpose

```
# Getters - get/fetch/retrieve/load
getUserById()
fetchOrders()

# Setters - set/update/assign
setUserName()
updateStatus()

# Boolean checks - is/has/can/should
isValid()
hasAccess()
canEdit()
shouldRetry()

# Transformers - to/from/as/convert
toJSON()
fromDTO()
asString()

# Finders - find/search/lookup
findByEmail()
searchProducts()

# Creators - create/build/make/generate
createUser()
buildQuery()
generateToken()

# Validators - validate/verify/check/ensure
validateInput()
verifyToken()
ensureAuthenticated()
```

## Code Structure

### Function/Method Design

```python
# Single responsibility - one thing per function
def validate_and_save_and_notify(user):  # ❌ Too many things
    ...

def validate_user(user):     # ✅ One thing
def save_user(user):         # ✅ One thing  
def notify_user(user):       # ✅ One thing

# Small functions (< 20 lines ideal, < 50 max)
# If it needs scrolling, it's probably too long

# Low parameter count (0-3 ideal, 4+ consider object)
def search(query, limit, offset, sort, order, filter, include_deleted):  # ❌
def search(query, options: SearchOptions):  # ✅

# Avoid flag arguments that change behavior
def getUsers(includeDeleted: bool):  # ❌ Two functions in one
def getUsers():              # ✅
def getAllUsersIncludingDeleted():  # ✅
```

### Early Returns

```python
# Avoid deep nesting
def process(data):  # ❌
    if data:
        if data.is_valid:
            if data.user:
                return do_something(data)
    return None

def process(data):  # ✅
    if not data:
        return None
    if not data.is_valid:
        return None
    if not data.user:
        return None
    return do_something(data)
```

### Error Handling

```python
# Be specific about what you catch
try:
    result = api_call()
except Exception:  # ❌ Too broad
    pass

try:
    result = api_call()
except APIError as e:  # ✅ Specific
    log.error(f"API call failed: {e}")
    raise

# Don't swallow errors silently
try:
    save(data)
except:  # ❌ Silent failure
    pass

try:
    save(data)
except SaveError as e:  # ✅ Logged and handled
    log.error(f"Save failed: {e}")
    notify_admin(e)
    raise UserFacingError("Unable to save")
```

## Comments

### When to Comment

```python
# Explain WHY, not WHAT (the code shows what)
❌ # Increment counter by 1
   counter += 1

✅ # Use counter > 0 to prevent race condition in cleanup
   counter += 1

# Document non-obvious behavior
✅ # OAuth tokens expire after 1 hour, so refresh at 50 min
   REFRESH_THRESHOLD = 50 * 60

# Explain complex algorithms
✅ # Using Floyd's cycle detection: fast pointer moves 2x
   # to detect if linked list has a cycle in O(1) space

# Mark TODOs with context
✅ # TODO(JIRA-123): Replace with batch API when available
   for item in items:
       api.update(item)
```

### When NOT to Comment

```python
# Don't explain obvious code
❌ # Get the user
   user = get_user(id)

# Don't leave commented-out code
❌ # old_function()
   # another_old_thing()
   new_function()

# Don't lie (outdated comments)
❌ # Returns user count
   def get_users():  # Actually returns users, not count
       return db.query(User).all()
```

## File Organization

### Module Structure
```
# Imports at top, grouped and ordered
1. Standard library imports
2. Third-party imports
3. Local imports

# Then constants
# Then classes/functions (public first, private later)
# Main block at end (if script)
```

### File Length
- Aim for < 300 lines per file
- If > 500 lines, consider splitting
- One main concept per file

## Language-Specific Overlays

### Python

```python
# Use snake_case for functions/variables
def get_user_by_id(user_id):
    active_users = []

# Use PascalCase for classes
class UserAccount:
    pass

# Use type hints
def process(data: dict[str, Any]) -> Result:
    ...

# Use f-strings
name = f"Hello, {user.name}!"

# Use context managers
with open(file) as f:
    data = f.read()

# Docstrings for public functions
def calculate_total(items: list[Item]) -> Decimal:
    """
    Calculate the total price of items.
    
    Args:
        items: List of items to total
        
    Returns:
        Total price as Decimal
        
    Raises:
        ValueError: If items list is empty
    """
```

### TypeScript/JavaScript

```typescript
// Use camelCase for functions/variables
function getUserById(userId: string): User {
    const activeUsers: User[] = [];
}

// Use PascalCase for classes/interfaces/types
interface UserAccount {
    id: string;
    email: string;
}

class UserService {
    // ...
}

// Use const by default, let when reassignment needed
const config = loadConfig();
let attempts = 0;

// Use arrow functions for callbacks
users.filter(user => user.isActive);

// Use template literals
const message = `Hello, ${user.name}!`;

// Use async/await over promises
async function fetchUser(id: string): Promise<User> {
    const response = await api.get(`/users/${id}`);
    return response.data;
}

// Use optional chaining and nullish coalescing
const name = user?.profile?.name ?? 'Anonymous';
```

### Go

```go
// Use camelCase for private, PascalCase for public
func getUserByID(userID string) *User {  // private
    return nil
}

func GetUserByID(userID string) *User {  // public (exported)
    return nil
}

// Use short names in small scopes
for i, v := range items {
    // i and v are fine here
}

// Use descriptive names in larger scopes
func processOrder(order *Order) error {
    // 'order' is clear throughout function
}

// Handle errors explicitly
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}

// Use defer for cleanup
func readFile(path string) ([]byte, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer f.Close()
    return io.ReadAll(f)
}
```

## Testing Conventions

```python
# Test naming: should_expectedBehavior_when_condition
def test_should_return_user_when_valid_id_provided():
    ...

def test_should_raise_error_when_user_not_found():
    ...

# Arrange-Act-Assert pattern
def test_user_creation():
    # Arrange
    data = {"email": "test@example.com"}
    
    # Act
    user = create_user(data)
    
    # Assert
    assert user.email == "test@example.com"

# One assertion per test (or one logical assertion)
def test_user_has_correct_properties():  # ✅ One logical thing
    user = create_user(data)
    assert user.email == expected_email
    assert user.name == expected_name
    assert user.is_active == True
```

## Applying to Existing Codebases

1. **First, observe** - Identify existing patterns
2. **Match existing style** - Even if you'd do it differently
3. **Propose changes separately** - Don't mix style changes with features
4. **Use tooling** - Linters, formatters enforce consistency
5. **Document decisions** - Add style guide if none exists
