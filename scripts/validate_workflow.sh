#!/usr/bin/env bash
# Validate one or more workflow directories against the ai_skills standard:
#   <workflow-dir>/WORKFLOW.md must exist with non-trivial content.
#   Recommended: BACKLOG.md, FOLDER_STRUCTURE.md present (warn only).
#   If agents/ (or PRIVATE/AGENTS/) exists, every *.md entry must resolve
#   (symlinks must not be broken) and must itself pass validate_agent.sh.
#
# Usage:
#   scripts/validate_workflow.sh                  # validate all WORKFLOWS/*
#   scripts/validate_workflow.sh <workflow-dir>    # validate one workflow
#   scripts/validate_workflow.sh <dir> ...         # validate several

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"

ROOT="$(repo_root)"

validate_agent_dir_entries() {
  # $1 = directory containing agent .md files/symlinks (e.g. agents/, PRIVATE/AGENTS/)
  local dir="$1" label="$2"
  local f
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if [ -L "$f" ] && [ ! -e "$f" ]; then
      fail "$label: broken symlink: $f -> $(readlink "$f")"
      continue
    fi
    pass "$label: $f resolves"
    # Delegate full agent validation; fold its fail/warn/pass counts into ours,
    # suppressing its own nested "Summary" block to keep top-level output clean.
    "$SCRIPT_DIR/validate_agent.sh" "$f" > /tmp/validate_agent_out.$$ 2>&1
    local rc=$?
    grep -Ev '^Summary$|^Pass: [0-9]+ +Warn: [0-9]+ +Fail: [0-9]+$' /tmp/validate_agent_out.$$ | sed '/^Agent: /d'
    local sub_pass sub_warn sub_fail
    sub_pass=$(grep -c '^PASS' /tmp/validate_agent_out.$$)
    sub_warn=$(grep -c '^WARN' /tmp/validate_agent_out.$$)
    sub_fail=$(grep -c '^FAIL' /tmp/validate_agent_out.$$)
    PASS_COUNT=$((PASS_COUNT+sub_pass))
    WARN_COUNT=$((WARN_COUNT+sub_warn))
    FAIL_COUNT=$((FAIL_COUNT+sub_fail))
    rm -f /tmp/validate_agent_out.$$
    if [ "$rc" -ne 0 ] && [ "$sub_fail" -eq 0 ]; then
      # validate_agent.sh failed for a reason not captured as a FAIL line
      # (e.g. file-not-found) - count it explicitly so exit code stays honest.
      fail "$label: $f failed validate_agent.sh (exit $rc)"
    fi
  done < <(find "$dir" -maxdepth 1 -type f -o -type l 2>/dev/null | grep '\.md$' | sort)
}

validate_skill_dir_entries() {
  # $1 = directory containing skill subdirectories (e.g. PRIVATE/SKILLS/)
  local dir="$1" label="$2"
  local d
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    "$SCRIPT_DIR/validate_skill.sh" "$d" > /tmp/validate_skill_out.$$ 2>&1
    local rc=$?
    grep -Ev '^Summary$|^Pass: [0-9]+ +Warn: [0-9]+ +Fail: [0-9]+$' /tmp/validate_skill_out.$$ | sed '/^Skill: /d'
    local sub_pass sub_warn sub_fail
    sub_pass=$(grep -c '^PASS' /tmp/validate_skill_out.$$)
    sub_warn=$(grep -c '^WARN' /tmp/validate_skill_out.$$)
    sub_fail=$(grep -c '^FAIL' /tmp/validate_skill_out.$$)
    PASS_COUNT=$((PASS_COUNT+sub_pass))
    WARN_COUNT=$((WARN_COUNT+sub_warn))
    FAIL_COUNT=$((FAIL_COUNT+sub_fail))
    rm -f /tmp/validate_skill_out.$$
    if [ "$rc" -ne 0 ] && [ "$sub_fail" -eq 0 ]; then
      fail "$label: $d failed validate_skill.sh (exit $rc)"
    fi
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
}

validate_one_workflow() {
  local dir="$1"
  dir="${dir%/}"
  local name workflow_md
  name="$(basename "$dir")"
  workflow_md="$dir/WORKFLOW.md"

  section "Workflow: $name  ($dir)"

  if [ ! -f "$workflow_md" ]; then
    fail "$name: missing WORKFLOW.md"
    return
  fi
  pass "$name: WORKFLOW.md exists"

  local wf_len
  wf_len="$(wc -c < "$workflow_md" | tr -d ' ')"
  if [ "$wf_len" -lt 200 ]; then
    warn "$name: WORKFLOW.md looks very short ($wf_len bytes)"
  else
    pass "$name: WORKFLOW.md has substantive content"
  fi

  if [ -f "$dir/BACKLOG.md" ]; then
    pass "$name: has BACKLOG.md"
  else
    warn "$name: missing BACKLOG.md (recommended)"
  fi

  if [ -f "$dir/FOLDER_STRUCTURE.md" ]; then
    pass "$name: has FOLDER_STRUCTURE.md"
  else
    warn "$name: missing FOLDER_STRUCTURE.md (recommended)"
  fi

  check_no_hardcoded_paths_or_credentials "$workflow_md" "$name/WORKFLOW.md"
  [ -f "$dir/BACKLOG.md" ] && check_no_hardcoded_paths_or_credentials "$dir/BACKLOG.md" "$name/BACKLOG.md"
  [ -f "$dir/FOLDER_STRUCTURE.md" ] && check_no_hardcoded_paths_or_credentials "$dir/FOLDER_STRUCTURE.md" "$name/FOLDER_STRUCTURE.md"

  if [ -d "$dir/agents" ]; then
    validate_agent_dir_entries "$dir/agents" "$name/agents"
  fi

  if [ -d "$dir/PRIVATE/AGENTS" ]; then
    validate_agent_dir_entries "$dir/PRIVATE/AGENTS" "$name/PRIVATE/AGENTS"
  fi

  if [ ! -d "$dir/agents" ] && [ ! -d "$dir/PRIVATE/AGENTS" ]; then
    warn "$name: no agents/ or PRIVATE/AGENTS/ directory found - workflow has no linked agent definitions"
  fi

  if [ -d "$dir/PRIVATE/SKILLS" ]; then
    validate_skill_dir_entries "$dir/PRIVATE/SKILLS" "$name/PRIVATE/SKILLS"
  fi
}

targets=()
if [ "$#" -eq 0 ]; then
  if [ -d "$ROOT/WORKFLOWS" ]; then
    while IFS= read -r d; do
      targets+=("$d")
    done < <(find "$ROOT/WORKFLOWS" -mindepth 1 -maxdepth 1 -type d | sort)
  fi
else
  targets=("$@")
fi

if [ "${#targets[@]}" -eq 0 ]; then
  echo "No workflow directories found to validate."
  exit 0
fi

for t in "${targets[@]}"; do
  validate_one_workflow "$t"
done

section "Summary"
echo "Pass: $PASS_COUNT  Warn: $WARN_COUNT  Fail: $FAIL_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
