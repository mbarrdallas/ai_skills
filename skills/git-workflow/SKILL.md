---
name: git-workflow
description: Manage git operations including branching strategies, worktrees for parallel development, commits, merges, and pull requests. Use when working with version control, setting up branching strategies, managing parallel work streams, resolving conflicts, or coordinating code changes. Triggers on "git", "branch", "commit", "merge", "worktree", "pull request", or when managing version control operations.
---

# Git Workflow

Effective git practices for solo and team development, including worktrees for parallel execution.

## Branching Strategy

### Branch Types

```
main (or master)
├── Production-ready code
├── Protected - human merge only
└── Tagged releases

develop
├── Integration branch
├── Features merge here first
└── Orchestrator can merge here

feature/<name>
├── New features
├── Branch from: develop
└── Merge to: develop

bugfix/<name>
├── Bug fixes
├── Branch from: develop
└── Merge to: develop

hotfix/<name>
├── Emergency production fixes
├── Branch from: main
└── Merge to: main AND develop

release/<version>
├── Release preparation
├── Branch from: develop
└── Merge to: main AND develop
```

### Naming Conventions

```bash
# Features
feature/user-authentication
feature/payment-integration
feature/JIRA-123-add-search

# Bug fixes
bugfix/login-timeout
bugfix/JIRA-456-fix-crash

# Hotfixes
hotfix/security-patch
hotfix/critical-data-fix

# Releases
release/v1.2.0
release/2024-q1
```

## Git Worktrees

Worktrees allow multiple working directories from the same repository - essential for parallel task execution.

### When to Use Worktrees

- Running multiple tasks in parallel
- Testing a branch while working on another
- Isolating experimental work
- Code review while developing

### Basic Worktree Commands

```bash
# List worktrees
git worktree list

# Add worktree (new branch)
git worktree add <path> -b <branch-name>

# Add worktree (existing branch)
git worktree add <path> <existing-branch>

# Remove worktree
git worktree remove <path>

# Prune stale worktree info
git worktree prune
```

### Worktree Structure for Parallel Tasks

```bash
# Main repo stays on develop
cd /project

# Create worktree directory outside repo
mkdir -p ../worktrees/feature-name

# Create worktree for each parallel task
git worktree add ../worktrees/feature-name/task-1-api -b feature/task-1-api
git worktree add ../worktrees/feature-name/task-2-models -b feature/task-2-models
git worktree add ../worktrees/feature-name/task-3-tests -b feature/task-3-tests
```

```
project/                          # Main repo (on develop)
../worktrees/
└── feature-name/
    ├── task-1-api/               # Worktree for API work
    ├── task-2-models/            # Worktree for model work
    └── task-3-tests/             # Worktree for test work
```

### Worktree Lifecycle

```bash
# 1. Create worktree for task
git worktree add ../worktrees/myfeature/task-1 -b feature/task-1

# 2. Work in worktree
cd ../worktrees/myfeature/task-1
# ... do work ...
git add .
git commit -m "feat: implement task 1"

# 3. Push branch
git push -u origin feature/task-1

# 4. After review/approval, merge to feature branch
cd /project  # back to main repo
git checkout feature/myfeature  # or develop
git merge feature/task-1 --no-ff -m "feat: merge task 1"

# 5. Clean up worktree
git worktree remove ../worktrees/myfeature/task-1
git branch -d feature/task-1
```

## Commit Messages

### Conventional Commits Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change, no feature/fix |
| `perf` | Performance improvement |
| `test` | Adding/fixing tests |
| `chore` | Build, config, etc. |

### Examples

```bash
# Simple commit
git commit -m "feat(auth): add JWT token validation"

# With body
git commit -m "fix(api): handle null user in response

The API was returning 500 when user was null.
Now returns 404 with appropriate message.

Fixes #123"

# Breaking change
git commit -m "feat(api)!: change response format

BREAKING CHANGE: Response now wraps data in 'data' field"
```

### Commit Guidelines

```
✅ Good commits:
- Small, focused changes
- One logical change per commit
- Complete (doesn't break build)
- Well-described

❌ Bad commits:
- "WIP"
- "fix stuff"
- "changes"
- Multiple unrelated changes
- Breaks tests/build
```

## Merging Strategies

### Merge Commit (--no-ff)

```bash
# Creates merge commit, preserves branch history
git checkout develop
git merge feature/my-feature --no-ff -m "feat: merge my-feature"
```

```
  *   Merge branch 'feature/my-feature'
  |\
  | * feat: add feature part 2
  | * feat: add feature part 1
  |/
  * previous commit
```

### Squash Merge

```bash
# Combines all commits into one
git checkout develop
git merge feature/my-feature --squash
git commit -m "feat: add my-feature"
```

```
  * feat: add my-feature
  * previous commit
```

### Rebase

```bash
# Replay commits on top of target
git checkout feature/my-feature
git rebase develop
# Then fast-forward merge
git checkout develop
git merge feature/my-feature
```

```
  * feat: add feature part 2
  * feat: add feature part 1
  * previous commit
```

### When to Use Each

| Strategy | Use When |
|----------|----------|
| Merge commit | Default for features, preserves history |
| Squash | Many small/messy commits, want clean history |
| Rebase | Linear history preferred, before PR |

## Conflict Resolution

### Identifying Conflicts

```bash
# After merge/rebase shows conflict
git status
# Shows: both modified: path/to/file

# View conflict markers in file
<<<<<<< HEAD
current branch content
=======
incoming branch content
>>>>>>> feature/other-branch
```

### Resolving Conflicts

```bash
# Option 1: Manual resolution
# Edit file to remove markers and keep correct code
# Then:
git add path/to/file
git commit  # or git rebase --continue

# Option 2: Keep ours (current branch)
git checkout --ours path/to/file
git add path/to/file

# Option 3: Keep theirs (incoming branch)
git checkout --theirs path/to/file
git add path/to/file

# Abort if needed
git merge --abort
# or
git rebase --abort
```

### Preventing Conflicts

1. **Pull frequently** - Stay up to date with target branch
2. **Small, focused changes** - Less overlap
3. **Communicate** - Know who's working where
4. **Use worktrees** - Isolate parallel work

## Common Operations

### Starting New Work

```bash
# Update develop
git checkout develop
git pull

# Create feature branch
git checkout -b feature/my-feature

# Or with worktree
git worktree add ../worktrees/my-feature -b feature/my-feature
```

### Saving Work in Progress

```bash
# Stash changes
git stash push -m "WIP: description"

# List stashes
git stash list

# Apply and remove stash
git stash pop

# Apply and keep stash
git stash apply stash@{0}
```

### Undoing Changes

```bash
# Undo uncommitted changes to file
git checkout -- path/to/file

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Revert a pushed commit (creates new commit)
git revert <commit-hash>
```

### Viewing History

```bash
# Log with graph
git log --oneline --graph --all

# Show specific file history
git log -p -- path/to/file

# Find who changed a line
git blame path/to/file

# Search commits
git log --grep="search term"
```

## Pull Request Workflow

### Before Creating PR

```bash
# Update feature branch with latest develop
git checkout feature/my-feature
git fetch origin
git rebase origin/develop
# Resolve any conflicts

# Run tests
npm test  # or equivalent

# Push
git push -u origin feature/my-feature
```

### PR Checklist

- [ ] Tests pass
- [ ] Code follows conventions
- [ ] Commits are clean (squash if needed)
- [ ] Description explains changes
- [ ] Linked to issue/ticket
- [ ] Ready for review

### After PR Approved

```bash
# Merge via GitHub/GitLab UI (preferred)
# Or manually:
git checkout develop
git pull
git merge feature/my-feature --no-ff
git push

# Clean up
git branch -d feature/my-feature
git push origin --delete feature/my-feature
```

## Security: Pre-Push Checklist

**ALWAYS check before pushing to any remote branch:**

```bash
# Review what you're about to commit
git diff --staged

# Search for common sensitive patterns
git diff --staged | grep -iE '(password|secret|api_key|token|credential|private_key)'
```

**Never commit:**
- API keys or tokens
- Passwords or secrets
- Private keys (SSH, SSL, etc.)
- `.env` files with real values
- Personal information (emails, addresses, etc.)
- Database connection strings with credentials
- AWS/GCP/Azure credentials
- **Workflow planning artifacts** — files like `IMPLEMENTATION_SPEC*.md`, `TEST_COVERAGE*.md`, `ORCHESTRATOR_STATE.md`, `TASK_PLAN.md` belong in `active_workflows/`, not the code repo. Add them to `.gitignore` if they appear near code.

**Use `.gitignore`:**
```gitignore
.env
.env.*
*.pem
*.key
credentials.json
secrets/
```

**If accidentally committed:**
```bash
# Remove from history (if not pushed)
git reset --soft HEAD~1
# Edit out the sensitive data, then recommit

# If already pushed - rotate the exposed credentials immediately!
```

## Best Practices

### Daily Workflow

1. Pull latest develop before starting
2. Work in feature branch (or worktree)
3. Commit frequently with good messages
4. **Review diff for sensitive data before pushing**
5. Push at end of day (backup)
6. Create PR when ready

### Branch Hygiene

- Delete merged branches
- Don't let branches get stale
- Rebase long-lived branches regularly
- Use worktrees for truly parallel work

### Commit Hygiene

- Atomic commits (one logical change)
- Don't commit broken code
- Don't commit secrets
- Clean up before PR (interactive rebase)
