#!/usr/bin/env bash
# Symlink this repo's public skills into the pi harness skills directory so
# they're discoverable and can auto-trigger.
#
# Skills only auto-trigger if the harness can see them, and per AGENTS.md that
# symlink step "is easy to forget and the skill will silently never trigger
# without it". This script makes it a one-liner instead of a manual chore.
#
# Scope:
#   - links every directory in skills/ that contains a SKILL.md
#   - does NOT link workflow-private skills (WORKFLOWS/*/PRIVATE/SKILLS/*),
#     which are intentionally not globally auto-triggering
#   - does NOT link THIRDPARTY skills unless --thirdparty is passed
#   - never touches links that point outside this repo (e.g. pi's own bundled
#     skills), except with --prune, which only removes BROKEN links
#
# Usage:
#   install_skills.sh [--check] [--thirdparty] [--prune] [--quiet]
#
# Flags:
#   --check       Report what would change; make no modifications. Exits 1 if
#                 anything is out of sync (useful in CI / before committing).
#   --thirdparty  Also link THIRDPARTY/anthropic_skills/skills/*. Off by
#                 default: that set is large and curated by hand.
#   --prune       Remove broken symlinks in the target dir that point into
#                 this repo (e.g. left by a renamed/deleted skill). Never
#                 removes valid links or anything pointing elsewhere.
#   --quiet       Only print changes, warnings, and the summary.
#
# Target dir: $PI_SKILLS_DIR, else $PI_AGENT_DIR/skills, else ~/.pi/agent/skills
#
# Exit codes: 0 in sync / changes applied, 1 out of sync (--check) or error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"

ROOT="$(repo_root)"

CHECK=0; THIRDPARTY=0; PRUNE=0; QUIET=0
while [ $# -gt 0 ]; do
  case "$1" in
    --check)      CHECK=1 ;;
    --thirdparty) THIRDPARTY=1 ;;
    --prune)      PRUNE=1 ;;
    --quiet)      QUIET=1 ;;
    -h|--help)    sed -n '2,32p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) fail "unknown argument: $1"; exit 1 ;;
  esac
  shift
done

TARGET="${PI_SKILLS_DIR:-${PI_AGENT_DIR:-$HOME/.pi/agent}/skills}"

section "Skills -> $TARGET"
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
  # link_one <source-dir> <label>
  local src="$1" label="$2" name existing
  name="$(basename "$src")"
  local dest="$TARGET/$name"

  if [ ! -f "$src/SKILL.md" ]; then
    warn "$label: no SKILL.md, skipping"
    return
  fi

  if [ -L "$dest" ]; then
    existing="$(readlink "$dest")"
    if [ "$existing" = "$src" ]; then
      [ "$QUIET" -eq 0 ] && pass "$name: already linked"
      return
    fi
    # Points somewhere else - only reclaim it if it points into this repo.
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
    warn "$name: exists and is not a symlink (real file/dir) - left untouched"
    return
  fi

  CHANGED=1
  if [ "$CHECK" -eq 1 ]; then
    warn "$name: MISSING - would link (skill cannot auto-trigger until linked)"
  else
    ln -sfn "$src" "$dest" && pass "$name: linked"
  fi
}

while IFS= read -r dir; do
  link_one "$dir" "skills/$(basename "$dir")"
done < <(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d | sort)

if [ "$THIRDPARTY" -eq 1 ]; then
  section "THIRDPARTY skills"
  if [ -d "$ROOT/THIRDPARTY/anthropic_skills/skills" ]; then
    while IFS= read -r dir; do
      link_one "$dir" "THIRDPARTY/$(basename "$dir")"
    done < <(find "$ROOT/THIRDPARTY/anthropic_skills/skills" -mindepth 1 -maxdepth 1 -type d | sort)
  else
    warn "THIRDPARTY/anthropic_skills/skills not found (submodule not initialized?)"
  fi
fi

# --- prune broken links pointing into this repo -----------------------------
section "Stale links"
found_stale=0
while IFS= read -r link; do
  tgt="$(readlink "$link")"
  case "$tgt" in
    "$ROOT"/*)
      [ -e "$tgt" ] && continue   # valid
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
    printf "Skills are OUT OF SYNC - run without --check to fix.\n"
    exit 1
  fi
  printf "Skills are in sync.\n"
fi
[ "$FAIL_COUNT" -gt 0 ] && exit 1
exit 0
