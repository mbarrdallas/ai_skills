# Python Coding Conventions

Language-specific overlay for Python. Use alongside the main coding-conventions skill.

## Naming

```python
# snake_case for functions and variables
def get_user_by_id(user_id):
    active_users = []

# PascalCase for classes
class UserAccount:
    pass

# UPPER_SNAKE_CASE for constants
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30

# _leading_underscore for private/internal
def _helper_function():
    pass

class MyClass:
    def _internal_method(self):
        pass
```

## Type Hints

```python
from typing import Any, Optional, Union
from collections.abc import Sequence

# Always use type hints for function signatures
def process(data: dict[str, Any]) -> Result:
    ...

def get_user(user_id: int) -> Optional[User]:
    ...

def handle_items(items: Sequence[Item]) -> list[Result]:
    ...

# Use | for unions (Python 3.10+)
def parse(value: str | int) -> str:
    ...

# Or Union for older versions
def parse(value: Union[str, int]) -> str:
    ...
```

## Strings

```python
# Use f-strings for formatting
name = f"Hello, {user.name}!"
message = f"Found {count} items in {elapsed:.2f}s"

# Use triple quotes for multi-line
query = """
    SELECT *
    FROM users
    WHERE active = true
"""

# Raw strings for regex
pattern = r"\d{3}-\d{4}"
```

## Context Managers

```python
# Always use context managers for resources
with open(filepath) as f:
    data = f.read()

with db.connection() as conn:
    conn.execute(query)

# Multiple context managers
with open(input_file) as infile, open(output_file, 'w') as outfile:
    outfile.write(infile.read())

# Create custom context managers
from contextlib import contextmanager

@contextmanager
def timer(name: str):
    start = time.time()
    try:
        yield
    finally:
        elapsed = time.time() - start
        print(f"{name}: {elapsed:.2f}s")
```

## Docstrings

```python
def calculate_total(items: list[Item], tax_rate: float = 0.0) -> Decimal:
    """
    Calculate the total price of items with optional tax.
    
    Args:
        items: List of items to total.
        tax_rate: Tax rate as decimal (0.1 = 10%). Defaults to 0.0.
        
    Returns:
        Total price as Decimal, including tax if specified.
        
    Raises:
        ValueError: If items list is empty.
        ValueError: If tax_rate is negative.
        
    Example:
        >>> items = [Item(price=10), Item(price=20)]
        >>> calculate_total(items, tax_rate=0.1)
        Decimal('33.00')
    """
    if not items:
        raise ValueError("Items list cannot be empty")
    ...


class UserService:
    """
    Service for managing user operations.
    
    Attributes:
        db: Database connection instance.
        cache: Optional cache for user lookups.
        
    Example:
        >>> service = UserService(db=get_db())
        >>> user = service.get_by_id(123)
    """
    
    def __init__(self, db: Database, cache: Optional[Cache] = None):
        """Initialize UserService with database connection."""
        self.db = db
        self.cache = cache
```

## Imports

```python
# Standard library first
import os
import sys
from collections import defaultdict
from pathlib import Path

# Third-party second (blank line separator)
import requests
from sqlalchemy import create_engine
from pydantic import BaseModel

# Local imports third (blank line separator)
from myapp.models import User
from myapp.utils import helpers
from . import local_module

# Avoid wildcard imports
from module import *  # ❌ Never do this
from module import specific_thing  # ✅
```

## Classes

```python
from dataclasses import dataclass
from typing import ClassVar

# Use dataclasses for data containers
@dataclass
class User:
    id: int
    name: str
    email: str
    active: bool = True

# Use __slots__ for memory efficiency (many instances)
class Point:
    __slots__ = ['x', 'y']
    
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

# Properties for computed attributes
class Rectangle:
    def __init__(self, width: float, height: float):
        self._width = width
        self._height = height
    
    @property
    def area(self) -> float:
        return self._width * self._height
    
    @property
    def width(self) -> float:
        return self._width
    
    @width.setter
    def width(self, value: float) -> None:
        if value <= 0:
            raise ValueError("Width must be positive")
        self._width = value

# Class methods and static methods
class DateHelper:
    @classmethod
    def from_string(cls, date_str: str) -> 'DateHelper':
        """Create instance from string."""
        return cls(parse_date(date_str))
    
    @staticmethod
    def is_weekend(date: datetime) -> bool:
        """Check if date falls on weekend."""
        return date.weekday() >= 5
```

## Error Handling

```python
# Be specific with exceptions
try:
    result = api.fetch(url)
except requests.Timeout:
    logger.warning(f"Timeout fetching {url}")
    return default_value
except requests.HTTPError as e:
    logger.error(f"HTTP error {e.response.status_code}")
    raise
except requests.RequestException as e:
    logger.error(f"Request failed: {e}")
    raise ServiceUnavailable(f"API unavailable: {url}")

# Create custom exceptions
class ValidationError(Exception):
    """Raised when validation fails."""
    
    def __init__(self, field: str, message: str):
        self.field = field
        self.message = message
        super().__init__(f"{field}: {message}")

# Use exception chaining
try:
    process(data)
except ProcessError as e:
    raise ApplicationError("Processing failed") from e
```

## List/Dict Comprehensions

```python
# Use comprehensions for simple transformations
squares = [x**2 for x in range(10)]
active_users = [u for u in users if u.active]
user_emails = {u.id: u.email for u in users}

# Don't over-complicate - use regular loops if complex
# ❌ Too complex
result = [transform(x) for x in items if validate(x) and x.active and x.score > threshold]

# ✅ Use loop for clarity
result = []
for x in items:
    if not validate(x):
        continue
    if not x.active:
        continue
    if x.score <= threshold:
        continue
    result.append(transform(x))
```

## Generators

```python
# Use generators for large sequences
def read_large_file(filepath: Path):
    """Yield lines from large file without loading all into memory."""
    with open(filepath) as f:
        for line in f:
            yield line.strip()

# Generator expressions
sum_of_squares = sum(x**2 for x in range(1000000))

# Use itertools for efficient iteration
from itertools import islice, chain, groupby

first_ten = list(islice(large_iterator, 10))
```

## Testing (pytest)

```python
import pytest
from unittest.mock import Mock, patch

# Test naming
def test_should_return_user_when_valid_id():
    ...

def test_should_raise_not_found_when_invalid_id():
    ...

# Fixtures
@pytest.fixture
def sample_user():
    return User(id=1, name="Test", email="test@example.com")

@pytest.fixture
def db_session():
    session = create_test_session()
    yield session
    session.rollback()
    session.close()

# Parametrized tests
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("World", "WORLD"),
    ("", ""),
])
def test_uppercase(input, expected):
    assert uppercase(input) == expected

# Mocking
def test_api_call_with_mock():
    with patch('myapp.api.requests.get') as mock_get:
        mock_get.return_value.json.return_value = {"data": "test"}
        result = fetch_data()
        assert result == {"data": "test"}
```

## Common Patterns

```python
# Null coalescing with or (careful with falsy values)
name = user.name or "Anonymous"

# Better: explicit None check
name = user.name if user.name is not None else "Anonymous"

# EAFP (Easier to Ask Forgiveness than Permission)
# Pythonic approach
try:
    value = my_dict[key]
except KeyError:
    value = default

# Or use dict.get()
value = my_dict.get(key, default)

# Walrus operator (Python 3.8+)
if (n := len(items)) > 10:
    print(f"Processing {n} items")

# Unpacking
first, *rest = items
a, b, *_ = values  # Ignore remaining

# Enumerate with start index
for i, item in enumerate(items, start=1):
    print(f"{i}. {item}")

# Zip for parallel iteration
for name, score in zip(names, scores):
    print(f"{name}: {score}")
```

## Tools

```bash
# Formatting
black .                    # Auto-format code
isort .                    # Sort imports

# Linting
ruff check .               # Fast linter (recommended)
flake8 .                   # Classic linter
pylint .                   # Comprehensive linter

# Type checking
mypy .                     # Static type checker
pyright .                  # Alternative type checker

# Configuration in pyproject.toml
```

```toml
# pyproject.toml
[tool.black]
line-length = 88

[tool.isort]
profile = "black"

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "W"]

[tool.mypy]
python_version = "3.11"
strict = true
```
