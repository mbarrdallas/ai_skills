---
name: codebase-analysis
description: Analyze existing codebases to understand architecture, patterns, conventions, and structure. Use when examining unfamiliar code, onboarding to a project, planning modifications to existing systems, understanding how components interact, or documenting existing architecture. Triggers on phrases like "analyze this codebase", "understand this code", "how does this project work", "what patterns does this use", or when needing to work with existing code.
---

# Codebase Analysis

A systematic approach to understanding existing codebases. This skill helps you quickly gain deep understanding of unfamiliar code, identify patterns and conventions, and document architecture for future reference.

## When to Use This Skill

- Onboarding to a new project
- Before modifying existing code
- Understanding how features are implemented
- Identifying patterns to follow
- Documenting architecture
- Code review preparation
- Planning refactoring efforts

## Analysis Framework

### Level 1: Bird's Eye View (5 minutes)

Start with the big picture before diving into details.

```
1. Read README.md and any docs/
2. Check package.json / requirements.txt / build files
3. List top-level directories
4. Identify entry points (main, index, app)
5. Note the tech stack
```

**Output:** Mental model of what this project does and how it's organized.

### Level 2: Architecture Discovery (15 minutes)

Understand the structural patterns.

```
1. Identify architectural pattern:
   - Monolith vs microservices
   - MVC / MVVM / Clean Architecture / etc.
   - Event-driven / Request-response
   
2. Map major components:
   - What are the main modules/packages?
   - What does each one do?
   - How do they communicate?

3. Find the data layer:
   - Database connections
   - Models/schemas
   - Data access patterns (ORM, raw SQL, etc.)

4. Identify external integrations:
   - APIs consumed
   - Third-party services
   - Message queues
```

**Output:** Component diagram (even if just mental or sketched).

### Level 3: Convention Discovery (10 minutes)

Learn how this codebase likes things done.

```
1. Naming conventions:
   - Files: kebab-case, camelCase, PascalCase?
   - Functions/methods: verbs? prefixes?
   - Classes: nouns? suffixes like Service, Controller?
   - Variables: abbreviations allowed?

2. File organization:
   - Feature-based or layer-based?
   - Where do tests live?
   - Where do types/interfaces go?

3. Code patterns:
   - Error handling approach
   - Async patterns (callbacks, promises, async/await)
   - Dependency injection style
   - State management approach

4. Testing patterns:
   - Test framework
   - Naming conventions
   - Mock/stub approach
   - Coverage expectations
```

**Output:** List of conventions to follow.

### Level 4: Deep Dive (as needed)

For specific areas requiring detailed understanding.

```
1. Trace a request/feature end-to-end:
   - Entry point → processing → data → response
   - Note all files touched
   - Understand the flow

2. Identify hot paths:
   - Most frequently modified files (git history)
   - Most imported modules
   - Core business logic

3. Find the gotchas:
   - Complex areas
   - Technical debt
   - Non-obvious behaviors
   - Outdated patterns
```

## Analysis Checklist

### Project Structure
- [ ] Identified main directories and their purposes
- [ ] Found entry points
- [ ] Located configuration files
- [ ] Found documentation

### Tech Stack
- [ ] Primary language(s)
- [ ] Framework(s)
- [ ] Database(s)
- [ ] Build tools
- [ ] Key dependencies

### Architecture
- [ ] Overall pattern (MVC, etc.)
- [ ] Major components mapped
- [ ] Data flow understood
- [ ] External integrations identified

### Conventions
- [ ] Naming conventions documented
- [ ] File organization pattern clear
- [ ] Coding patterns identified
- [ ] Test patterns understood

### Quality Indicators
- [ ] Test coverage level
- [ ] Linting configuration
- [ ] Type safety level
- [ ] Documentation quality

## Output Format

When documenting analysis, use this structure:

```markdown
# Codebase Analysis: [Project Name]

## Overview
[What this project does in 2-3 sentences]

## Tech Stack
- **Language:** 
- **Framework:**
- **Database:**
- **Key Dependencies:**

## Architecture

### Pattern
[Architectural pattern and rationale]

### Components
| Component | Location | Purpose |
|-----------|----------|---------|
| [name] | [path] | [what it does] |

### Data Flow
[How data moves through the system]

## Directory Structure
```
[annotated tree view]
```

## Conventions

### Naming
- Files: [pattern]
- Functions: [pattern]
- Classes: [pattern]

### Patterns
- Error handling: [approach]
- Async: [approach]
- State: [approach]

## Key Files
Files essential to understanding this codebase:
- `path/to/file` - [why it's important]

## Integration Points
Where new code typically connects:
- [location] - [for what purpose]

## Notes
[Anything else important]
```

## Common Patterns to Recognize

### Backend Patterns
- **Repository Pattern:** Data access abstracted behind interfaces
- **Service Layer:** Business logic separate from controllers
- **Middleware:** Request/response processing chain
- **Event Sourcing:** State as sequence of events

### Frontend Patterns
- **Component-Based:** UI as tree of components
- **State Management:** Centralized (Redux) vs distributed
- **Routing:** File-based vs configured
- **Data Fetching:** Client-side vs server-side

### General Patterns
- **Dependency Injection:** Dependencies passed in, not created
- **Factory Pattern:** Object creation abstracted
- **Observer Pattern:** Pub/sub for events
- **Strategy Pattern:** Algorithms encapsulated and swappable

## Red Flags to Note

Watch for these during analysis:
- God classes/modules doing too much
- Circular dependencies
- Inconsistent naming
- Dead code / unused dependencies
- Missing tests for critical paths
- Hardcoded configuration
- No error handling
- Outdated dependencies

## Tips for Efficient Analysis

1. **Follow the tests** - Tests often document intended behavior
2. **Check git history** - Recent changes show active areas
3. **Read the types** - Type definitions reveal structure
4. **Find the happy path first** - Understand normal flow before edge cases
5. **Ask questions** - Note what's unclear for follow-up
6. **Don't boil the ocean** - Focus on what you need to understand
