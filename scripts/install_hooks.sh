#!/usr/bin/env bash
#
# install_hooks.sh - point this repo's git hooks at the version-controlled
# scripts/hooks/ directory.
#
# Uses `git config core.hooksPath` rather than copying files into .git/hooks,
# so the hooks stay under version control: a copy would drift silently and
# would not exist at all for anyone who clones the repo.
#
# Note core.hooksPath is LOCAL to this clone (stored in .git/config), so every
# clone must run this once - it cannot be committed.
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_REL="scripts/hooks"

C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
C_BOLD=$'\033[1m'; C_RESET=$'\033[0m'
ok()   { printf "${C_GREEN}OK${C_RESET}    %s\n" "$1"; }
warn() { printf "${C_YELLOW}WARN${C_RESET}  %s\n" "$1" >&2; }
err()  { printf "${C_RED}ERROR${C_RESET} %s\n" "$1" >&2; }

usage() {
  cat <<'EOF'
Install (or check/remove) this repo's version-controlled git hooks.

Usage:
  install_hooks.sh [--check] [--uninstall] [--quiet]

Options:
  --check      Report whether hooks are wired up; exit 1 if not. Read-only.
  --uninstall  Unset core.hooksPath, reverting to .git/hooks.
  --quiet      Only print problems.
  -h, --help   Show this help.

Installed hooks:
  pre-commit   Validates staged skills/agents/workflows, checks shell syntax,
               and (when a skill/agent is added) verifies harness links.
               Bypass with `git commit --no-verify` or PRECOMMIT_SKIP=1.

Exit codes: 0 ok, 1 not installed (--check) or error.
EOF
}

CHECK=0; UNINSTALL=0; QUIET=0
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --check) CHECK=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --quiet) QUIET=1; shift ;;
    *) err "unknown flag: $1"; usage >&2; exit 1 ;;
  esac
done

cd "$REPO_ROOT" || exit 1
git rev-parse --git-dir >/dev/null 2>&1 || { err "not a git repository: $REPO_ROOT"; exit 1; }

CURRENT="$(git config --local core.hooksPath || true)"

if [ "$UNINSTALL" -eq 1 ]; then
  if [ -n "$CURRENT" ]; then
    git config --local --unset core.hooksPath
    ok "uninstalled - core.hooksPath unset (reverted to .git/hooks)"
  else
    [ "$QUIET" -eq 1 ] || ok "nothing to do - core.hooksPath was not set"
  fi
  exit 0
fi

if [ "$CHECK" -eq 1 ]; then
  if [ "$CURRENT" = "$HOOKS_REL" ]; then
    if [ -x "$HOOKS_REL/pre-commit" ]; then
      [ "$QUIET" -eq 1 ] || ok "hooks installed (core.hooksPath=$HOOKS_REL)"
      exit 0
    fi
    err "core.hooksPath=$HOOKS_REL but $HOOKS_REL/pre-commit is missing or not executable"
    exit 1
  fi
  warn "hooks NOT installed (core.hooksPath='${CURRENT:-<unset>}') - run: ./scripts/install_hooks.sh"
  exit 1
fi

# Install.
if [ -n "$CURRENT" ] && [ "$CURRENT" != "$HOOKS_REL" ]; then
  warn "core.hooksPath was '$CURRENT' - overwriting with '$HOOKS_REL'"
fi

chmod +x "$HOOKS_REL"/* 2>/dev/null || true
git config --local core.hooksPath "$HOOKS_REL"

# .git/hooks entries take precedence in older git only if hooksPath is unset,
# but an existing enabled hook there is still confusing - flag it.
for h in "$REPO_ROOT/.git/hooks/"*; do
  case "$h" in *.sample|*'*') continue ;; esac
  [ -x "$h" ] && warn "an old hook exists at .git/hooks/$(basename "$h") - it is now INACTIVE (core.hooksPath wins). Remove it to avoid confusion."
done

[ "$QUIET" -eq 1 ] || {
  ok "hooks installed (core.hooksPath=$HOOKS_REL)"
  printf '      pre-commit: validates staged skills/agents/workflows\n'
  printf '      bypass:     git commit --no-verify\n'
}
