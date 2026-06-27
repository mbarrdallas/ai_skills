---
name: doc-creator
description: Generate comprehensive documentation including READMEs, API docs, developer guides, and changelogs. Use when creating documentation for code, writing user guides, documenting APIs, or any technical writing task. Triggers on "write documentation", "create README", "document this", "API docs", "developer guide", or when needing to explain code or systems to others.
---

# Doc Creator

Create clear, comprehensive documentation that serves its readers well. This skill covers technical writing for software projects.

## Documentation Principles

### 1. Know Your Audience
Different docs for different readers:
- **End users:** How to use, tutorials, FAQs
- **Developers:** How it works, API reference, contributing
- **Maintainers:** Architecture, decisions, troubleshooting

### 2. Progressive Disclosure
Lead with essentials, details on demand:
- Start with what it is and why
- Then how to get started
- Then deeper details
- Reference material last

### 3. Show, Don't Just Tell
Examples are essential:
- Working code examples
- Expected outputs
- Common use cases

### 4. Keep It Current
Outdated docs are worse than no docs:
- Update when code changes
- Date-stamp time-sensitive info
- Remove obsolete content

## Documentation Types

### README.md

The front door to your project. Quick orientation.

```markdown
# Project Name

One-line description of what this does.

## Overview
2-3 sentences expanding on what this project does and why it exists.

## Features
- Feature 1
- Feature 2
- Feature 3

## Quick Start

### Prerequisites
- Requirement 1
- Requirement 2

### Installation
```bash
npm install my-package
```

### Basic Usage
```javascript
import { thing } from 'my-package';

const result = thing.doSomething();
console.log(result);
```

## Documentation
- [API Reference](docs/API.md)
- [Developer Guide](docs/DEVELOPER_GUIDE.md)
- [Contributing](CONTRIBUTING.md)

## License
MIT
```

### API Documentation

Reference for programmatic interfaces.

```markdown
# API Reference

## Overview
Brief description of the API and common patterns.

## Authentication
How to authenticate with the API.

## Endpoints

### Create Resource
`POST /resources`

Create a new resource.

**Request Headers:**
| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer token |
| Content-Type | Yes | application/json |

**Request Body:**
```json
{
  "name": "string (required)",
  "description": "string (optional)",
  "tags": ["array", "of", "strings"]
}
```

**Response:** `201 Created`
```json
{
  "id": "res_abc123",
  "name": "My Resource",
  "description": null,
  "tags": [],
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Errors:**
| Code | Description |
|------|-------------|
| 400 | Invalid request body |
| 401 | Authentication required |
| 403 | Insufficient permissions |

**Example:**
```bash
curl -X POST https://api.example.com/resources \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "My Resource"}'
```

---

### Get Resource
`GET /resources/{id}`
[Continue pattern...]
```

### Developer Guide

How the system works internally.

```markdown
# Developer Guide

## Architecture Overview

High-level description of how the system is built.

```
┌─────────┐     ┌─────────┐     ┌─────────┐
│   API   │────▶│ Service │────▶│   DB    │
└─────────┘     └─────────┘     └─────────┘
```

## Key Components

### Component Name
- **Location:** `src/components/name/`
- **Purpose:** What it does
- **Key files:**
  - `index.ts` - Entry point
  - `handler.ts` - Request handling
  - `service.ts` - Business logic

## Data Flow

1. Request arrives at API layer
2. Validated and parsed
3. Passed to service layer
4. Business logic executed
5. Data persisted/retrieved
6. Response formatted and returned

## Design Decisions

### Decision: Using X for Y
**Context:** We needed to choose between A and B
**Decision:** Chose A
**Rationale:** Better for our use case because...
**Consequences:** Need to handle...

## Development Setup

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Redis

### Local Setup
```bash
# Clone repo
git clone https://github.com/org/repo.git
cd repo

# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your values

# Start dependencies
docker-compose up -d

# Run migrations
npm run migrate

# Start dev server
npm run dev
```

## Testing

### Running Tests
```bash
npm test              # All tests
npm test -- --watch   # Watch mode
npm run test:e2e      # E2E tests
```

### Writing Tests
- Unit tests in `__tests__/` directories
- E2E tests in `tests/e2e/`
- Use factories for test data
- One assertion per test (or one logical assertion)

## Common Tasks

### Adding a New Endpoint
1. Define route in `src/routes/`
2. Add handler in `src/handlers/`
3. Add service method in `src/services/`
4. Add tests
5. Update API docs

### Database Migrations
```bash
# Create migration
npm run migrate:create -- --name add_users_table

# Run migrations
npm run migrate

# Rollback
npm run migrate:rollback
```
```

### CHANGELOG.md

Track changes between versions.

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Feature X

## [1.2.0] - 2024-01-15

### Added
- User authentication with JWT
- Rate limiting on API endpoints

### Changed
- Improved error messages
- Updated dependencies

### Fixed
- Login timeout issue (#123)
- Data validation edge case

### Security
- Patched XSS vulnerability

## [1.1.0] - 2024-01-01

### Added
- Initial release
```

## Writing Guidelines

### Headlines

```markdown
# Use Title Case for Main Headers

## Use Sentence case for subheaders

### lowercase is fine for deep sections (optional)
```

### Code Examples

```markdown
# Always specify language for syntax highlighting
```python
def example():
    return "highlighted"
```

# Show expected output
```bash
$ npm run build
> Building...
> Done in 2.3s
```

# Include necessary context
```javascript
// First, import the module
import { auth } from './auth';

// Then use it
const token = auth.createToken(user);
```
```

### Lists

```markdown
# Use bullets for unordered items
- Item one
- Item two
- Item three

# Use numbers for sequential steps
1. First, do this
2. Then do this
3. Finally, do this

# Use definition style for term/description
**Term:** Definition or description of the term.
```

### Tables

```markdown
# Use tables for structured data
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Unique identifier |
| name | string | No | Display name |

# Align columns for readability in source
| Left   | Center | Right |
|:-------|:------:|------:|
| data   | data   | data  |
```

### Links

```markdown
# Inline links
See the [API documentation](docs/API.md) for details.

# Reference links (for repeated URLs)
See the [API docs][api] and [user guide][guide].

[api]: docs/API.md
[guide]: docs/USER_GUIDE.md
```

### Callouts

```markdown
> **Note:** This is important information.

> **Warning:** This could cause problems if ignored.

> **Tip:** This is a helpful suggestion.

> ⚠️ **Deprecated:** This will be removed in v2.0.
```

## Documentation Checklist

### README
- [ ] Clear one-line description
- [ ] What it does and why
- [ ] Quick start / installation
- [ ] Basic usage example
- [ ] Links to detailed docs
- [ ] License

### API Docs
- [ ] All endpoints documented
- [ ] Request/response formats shown
- [ ] Authentication explained
- [ ] Error codes listed
- [ ] Examples for each endpoint

### Developer Guide
- [ ] Architecture overview
- [ ] Setup instructions
- [ ] Key components explained
- [ ] Common tasks documented
- [ ] Testing instructions

### Every Doc
- [ ] Accurate (matches current code)
- [ ] Has working examples
- [ ] No broken links
- [ ] Spell-checked

## Common Mistakes

### Too Little Context
❌ `Run npm install`
✅ `Run npm install to install dependencies`

### Missing Examples
❌ "Use the createUser function to create users"
✅ Shows actual code with expected output

### Outdated Information
❌ References old API that no longer exists
✅ Updated when code changes

### Assuming Knowledge
❌ "Just configure the middleware"
✅ Shows exactly how to configure with code example

### Wall of Text
❌ Long paragraphs without structure
✅ Headers, bullets, code blocks break up content
