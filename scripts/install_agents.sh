#!/usr/bin/env bash
# Symlink this repo's agent definitions into the pi harness agents directory so
# they can be invoked as subagents.
#
# Scope:
#   - links every AGENTS/*.md, excluding SELF_IMPROVEMENT_LOG.md (a log, not an
#     agent)
#   - workflow-private agents (WORKFLOWS/*/PRIVATE/AGENTS/*) are linked only
#     with --private, and only if they declare a `name:` in frontmatter. Per
#     AGENTS.md these are case-by-case, not a hard requirement, so they are
#     opt-in here. Existing private links are never removed.
#   - private agents are linked under their frontmatter `name:` (e.g.
#     feature-development-orchestrator.md), matching how they're invoked,
#     rather than their filename
#   - never touches links that point outside this repo (e.g. pi's own bundled
#     example agents: planner, reviewer, scout, worker), except with --prune,
#     which only removes BROKEN links
#
# Usage:
#   install_agents.sh [--check] [--private] [--prune] [--quiet]
#
# Flags:
#   --check    Report what would change; make no modifications. Exits 1 if
#              anything is out of sync.
#   --private  Also link workflow-private agents (WORKFLOWS/*/PRIVATE/AGENTS/*).
#   --prune    Remove broken symlinks in the target dir that point into this
#              repo. Never removes valid links or anything pointing elsewhere.
#   --quiet    Only print changes, warnings, and the summary.
#
# Target dir: $PI_AGENTS_DIR, else $PI_AGENT_DIR/agents, else ~/.pi/agent/agents
#
# Exit codes: 0 in sync / changes applied, 1 out of sync (--check) or error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"

ROOT="$(repo_root)"

CHECK=0; PRIVATE=0; PRUNE=0; QUIET=0
while [ $# -gt 0 ]; do
  case "$1" in
    --check)   CHECK=1 ;;
    --private) PRIVATE=1 ;;
    --prune)   PRUNE=1 ;;
    --quiet)   QUIET=1 ;;
    -h|--help) sed -n '2,33p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) fail "unknown argument: $1"; exit 1 ;;
  esac
  shift
done

TARGET="${PI_AGENTS_DIR:-${PI_AGENT_DIR:-$HOME/.pi/agent}/agents}"

section "Agents -> $TARGET"
[ "$CHECK" -eq 1 ] && printf "(check mode - no changes will be made)\n"

if [ ! -d "$TARGET" ]; then
  if [ "$CHECK" -eq 1 ]; then
    fail "target dir does not exist: $TARGET"
    printf "\nSummary\nPass: %d  Warn: %d  Fail: %d\n" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"
    exit 1
  fi
  mkdir -p "$TARGET" || { fail "could not create $TARGET"; exit 1; }
  pass "created target dir $TARGET"
fi

CHANGED=0

link_one() {
  # link_one <source-file> <dest-basename>
  local src="$1" name="$2" existing
  local dest="$TARGET/$name"

  if [ -L "$dest" ]; then
    existing="$(readlink "$dest")"
    if [ "$existing" = "$src" ]; then
      [ "$QUIET" -eq 0 ] && pass "$name: already linked"
      return
    fi
    case "$existing" in
      "$ROOT"/*)
        CHANGED=1
        if [ "$CHECK" -eq 1 ]; then
          warn "$name: link points to a different path in this repo, would relink"
          printf "        from: %s\n          to: %s\n" "$existing" "$src"
        else
          ln -sfn "$src" "$dest" && pass "$name: relinked (was $existing)"
        fi
        ;;
      *)
        warn "$name: exists but points OUTSIDE this repo - left untouched"
        printf "        %s -> %s\n" "$dest" "$existing"
        ;;
    esac
    return
  fi

  if [ -e "$dest" ]; then
    warn "$name: exists and is not a symlink (real file) - left untouched"
    return
  fi

  CHANGED=1
  if [ "$CHECK" -eq 1 ]; then
    warn "$name: MISSING - would link (agent not invocable until linked)"
  else
    ln -sfn "$src" "$dest" && pass "$name: linked"
  fi
}

# --- public agents ----------------------------------------------------------
while IFS= read -r file; do
  link_one "$file" "$(basename "$file")"
done < <(find "$ROOT/AGENTS" -maxdepth 1 -type f -name "*.md" \
           ! -name "SELF_IMPROVEMENT_LOG.md" 2>/dev/null | sort)

# --- workflow-private agents (opt-in) --------------------------------------
if [ "$PRIVATE" -eq 1 ]; then
  section "Workflow-private agents"
  found_private=0
  while IFS= read -r file; do
    found_private=1
    # Link under the frontmatter `name:` - that's how the agent is invoked, and
    # private files are often generically named (e.g. orchestrator_agent.md).
    agent_name="$(frontmatter_field "$file" name)"
    if [ -z "$agent_name" ]; then
      warn "$(basename "$file"): no 'name:' in frontmatter, skipping (cannot determine link name)"
      continue
    fi
    link_one "$file" "${agent_name}.md"
  done < <(find "$ROOT/WORKFLOWS" -path "*/PRIVATE/AGENTS/*.md" -type f 2>/dev/null | sort)
  [ "$found_private" -eq 0 ] && warn "no workflow-private agents found"
fi

# --- prune broken links pointing into this repo -----------------------------
section "Stale links"
found_stale=0
while IFS= read -r link; do
  tgt="$(readlink "$link")"
  case "$tgt" in
    "$ROOT"/*)
      [ -e "$tgt" ] && continue
      found_stale=1; CHANGED=1
      if [ "$PRUNE" -eq 1 ] && [ "$CHECK" -eq 0 ]; then
        rm -f "$link" && pass "$(basename "$link"): pruned broken link"
      else
        warn "$(basename "$link"): BROKEN link into this repo -> $tgt$([ "$PRUNE" -eq 0 ] && echo ' (use --prune to remove)')"
      fi
      ;;
  esac
done < <(find "$TARGET" -maxdepth 1 -type l 2>/dev/null | sort)
[ "$found_stale" -eq 0 ] && [ "$QUIET" -eq 0 ] && pass "no broken links into this repo"

printf "\nSummary\nPass: %d  Warn: %d  Fail: %d\n" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"

if [ "$CHECK" -eq 1 ]; then
  if [ "$CHANGED" -eq 1 ] || [ "$FAIL_COUNT" -gt 0 ]; then
    printf "Agents are OUT OF SYNC - run without --check to fix.\n"
    exit 1
  fi
  printf "Agents are in sync.\n"
fi
[ "$FAIL_COUNT" -gt 0 ] && exit 1
exit 0
