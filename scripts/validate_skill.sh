#!/usr/bin/env bash
# Validate one or more skill directories against the ai_skills standard:
#   <skill-dir>/SKILL.md must have YAML frontmatter with:
#     - name: kebab-case, matches directory basename
#     - description: non-empty, reasonably descriptive (>= 40 chars),
#       ideally mentions when to use the skill ("use when"/"trigger")
#   and non-empty body content after the frontmatter.
#
# Usage:
#   scripts/validate_skill.sh                 # validate all skills/*
#   scripts/validate_skill.sh <skill-dir>      # validate one skill directory
#   scripts/validate_skill.sh <skill-dir> ...  # validate several

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"

ROOT="$(repo_root)"

validate_one_skill() {
  local dir="$1"
  local name_dir skill_md fm_name fm_desc body_len
  dir="${dir%/}"
  name_dir="$(basename "$dir")"
  skill_md="$dir/SKILL.md"

  section "Skill: $name_dir  ($dir)"

  if [ ! -f "$skill_md" ]; then
    fail "$name_dir: missing SKILL.md"
    return
  fi
  pass "$name_dir: SKILL.md exists"

  if ! has_frontmatter "$skill_md"; then
    fail "$name_dir: SKILL.md has no YAML frontmatter (--- ... ---) block"
    return
  fi
  pass "$name_dir: has YAML frontmatter block"

  fm_name="$(frontmatter_field "$skill_md" name)"
  fm_desc="$(frontmatter_field "$skill_md" description)"

  if [ -z "$fm_name" ]; then
    fail "$name_dir: frontmatter missing 'name' field"
  else
    pass "$name_dir: has 'name' field ($fm_name)"
    if ! is_kebab_case "$fm_name"; then
      warn "$name_dir: name '$fm_name' is not kebab-case"
    fi
    if [ "$fm_name" != "$name_dir" ]; then
      warn "$name_dir: frontmatter name '$fm_name' does not match directory name '$name_dir'"
    fi
  fi

  if [ -z "$fm_desc" ]; then
    fail "$name_dir: frontmatter missing 'description' field"
  else
    pass "$name_dir: has 'description' field"
    if [ "${#fm_desc}" -lt 40 ]; then
      warn "$name_dir: description is short (${#fm_desc} chars) - may trigger poorly"
    fi
    if ! echo "$fm_desc" | grep -qiE "use when|trigger"; then
      warn "$name_dir: description doesn't mention 'use when' / 'trigger' conditions - may reduce auto-triggering accuracy"
    fi
  fi

  body_len="$(tail -n +2 "$skill_md" | awk 'BEGIN{c=0} /^---$/{c++; next} c>=1' | wc -c | tr -d ' ')"
  if [ "$body_len" -lt 50 ]; then
    warn "$name_dir: SKILL.md body content looks very short ($body_len bytes after frontmatter)"
  else
    pass "$name_dir: SKILL.md has body content"
  fi

  check_no_hardcoded_paths_or_credentials "$skill_md" "$name_dir"
}

targets=()
if [ "$#" -eq 0 ]; then
  if [ -d "$ROOT/skills" ]; then
    while IFS= read -r d; do
      targets+=("$d")
    done < <(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d | sort)
  fi
else
  targets=("$@")
fi

if [ "${#targets[@]}" -eq 0 ]; then
  echo "No skill directories found to validate."
  exit 0
fi

for t in "${targets[@]}"; do
  validate_one_skill "$t"
done

section "Summary"
echo "Pass: $PASS_COUNT  Warn: $WARN_COUNT  Fail: $FAIL_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
