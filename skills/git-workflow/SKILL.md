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

### Invariant: `develop` is always a descendant of `main`

**Rule: `main` must always be an ancestor of `develop` (equivalently:
`develop` is always a proper branch-off of `main`, never diverged from
it). Nothing should ever be committed directly to `main` that isn't
already on `develop`.**

Check this invariant any time before merging:

```bash
git merge-base --is-ancestor main develop && echo OK || echo "VIOLATION: develop has diverged from main"
```

**Keep this true by preferring `--ff-only` for `develop → main` merges**,
not `--no-ff`:

```bash
git checkout main
git merge develop --ff-only
git push origin main
```

`--ff-only` refuses to create a merge commit — it only succeeds if `main`
can simply fast-forward to wherever `develop` already is. This guarantees
`main` never accumulates a commit `develop` doesn't have, so the invariant
holds automatically with no follow-up sync needed. If `--ff-only` fails,
that's a signal `main` has commits `develop` lacks (see the sync procedure
below) — don't reach for `--no-ff` on `main` just to force it through.

Only use a merge commit (`--no-ff`) directly on `main` for genuine
hotfix/release scenarios where history needs to show a distinct merge point
— and even then, immediately sync it back to `develop` afterward (see
below) so the invariant is restored right away, not left violated.

### Sync the source branch before merging long-lived branches back

If the invariant above has already been violated (e.g. a hotfix or a
`--no-ff` merge commit landed directly on `main`), recover it before
continuing normal `develop → main` merges:

**Rule: before merging `develop` into `main` (or any long-lived branch A
into long-lived branch B), first check whether they've diverged. If B has
commits A doesn't have, merge B into A first, then merge A back into B.**

Two long-lived branches (`main`/`develop`, or similar) can silently diverge
over time — e.g. a hotfix or a feature landed directly on `main` without
ever being synced back to `develop`. If you merge `develop` into `main` in
that state, you risk one of two bad outcomes depending on merge direction
and tooling: `main`-only work getting overwritten/orphaned, or a confusing
merge commit whose diff includes changes nobody intended to touch. Merging
`main` into `develop` *first* guarantees `develop` is a strict superset of
`main` before you merge it back — so merging `develop → main` afterward is
guaranteed to be either a clean fast-forward or a merge that adds *only*
the new work, with nothing dropped or reordered.

**Procedure:**

```bash
# 1. Check for divergence
git merge-base --is-ancestor main develop && echo "no divergence, safe to fast-forward/merge directly"
git log develop..main --oneline   # commits on main that develop doesn't have
git log main..develop --oneline   # commits on develop that main doesn't have

# 2. If both logs are non-empty, they've diverged - sync first.
#    Dry-run to confirm no real file conflicts before committing:
git checkout develop
git merge main --no-ff --no-commit
git status --short          # review what would change
git diff --cached --stat    # inspect the actual diff
git merge --abort           # if anything looks wrong, stop here and investigate

# 3. If the dry-run looked clean, do it for real:
git merge main --no-ff -m "merge: main into develop (sync before merging develop back to main)"
git push origin develop

# 4. Now merge develop into main - guaranteed clean given step 3:
git checkout main
git merge develop --no-ff -m "merge: develop into main (<summary of what's landing>)"
git push origin main
```

If branches have **not** diverged (`main` is already an ancestor of
`develop`), skip straight to a plain fast-forward merge/push — no need for
the sync step.

This applies to solo repos just as much as team repos — it's easy for a
single developer to merge a fix straight to `main` once and forget to sync
it back to `develop`, and the divergence compounds silently until the next
`develop → main` merge surfaces it.

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
