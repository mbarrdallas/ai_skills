#!/usr/bin/env bash
# Validate one or more agent definition files against the ai_skills standard:
#   YAML frontmatter with required fields: name, description, tools, skills,
#   spawns, model. name should be kebab-case and correspond to the filename
#   (snake_case). skills:/spawns: entries should resolve to real
#   skills/agents (warn only - some references may be aspirational).
#
# Usage:
#   scripts/validate_agent.sh                  # validate all AGENTS/*.md
#                                               #   and WORKFLOWS/*/PRIVATE/AGENTS/*.md
#   scripts/validate_agent.sh <agent-file.md>   # validate one agent file
#   scripts/validate_agent.sh <file> ...        # validate several

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"

ROOT="$(repo_root)"
REQUIRED_FIELDS=(name description tools skills spawns model)

# skill_exists <skill-name>: true if skills/<name>/SKILL.md exists, a
# root-level symlink/dir <name>/SKILL.md exists (e.g. skill-creator,
# grill-me), or a workflow-private WORKFLOWS/*/PRIVATE/SKILLS/<name>/SKILL.md
# exists (workflow-scoped skills used by only one workflow's agent(s)).
skill_exists() {
  local name="$1"
  [ -f "$ROOT/skills/$name/SKILL.md" ] && return 0
  [ -f "$ROOT/$name/SKILL.md" ] && return 0
  find "$ROOT/WORKFLOWS" -type f -path "*/PRIVATE/SKILLS/$name/SKILL.md" 2>/dev/null | grep -q . && return 0
  return 1
}

# agent_file_exists <agent-name-kebab>: true if a matching agent file exists
# anywhere under AGENTS/ or */PRIVATE/AGENTS/ (kebab-case -> snake_case filename).
agent_file_exists() {
  local kebab="$1" snake
  snake="$(echo "$kebab" | tr '-' '_')"
  find "$ROOT/AGENTS" "$ROOT/WORKFLOWS" -type f -name "${snake}.md" 2>/dev/null | grep -q .
}

validate_one_agent() {
  local file="$1"
  local base fm_name fm_desc fm_tools fm_skills fm_spawns fm_model snake_expected

  section "Agent: $file"

  if [ ! -f "$file" ]; then
    fail "$file: file does not exist"
    return
  fi

  if ! has_frontmatter "$file"; then
    fail "$file: no YAML frontmatter (--- ... ---) block"
    return
  fi
  pass "$file: has YAML frontmatter block"

  local missing=()
  for field in "${REQUIRED_FIELDS[@]}"; do
    local val
    val="$(frontmatter_field "$file" "$field")"
    if [ -z "$val" ]; then
      missing+=("$field")
    fi
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    fail "$file: missing required frontmatter field(s): ${missing[*]}"
  else
    pass "$file: all required frontmatter fields present (${REQUIRED_FIELDS[*]})"
  fi

  fm_name="$(frontmatter_field "$file" name)"
  fm_desc="$(frontmatter_field "$file" description)"
  fm_tools="$(frontmatter_field "$file" tools)"
  fm_skills="$(frontmatter_field "$file" skills)"
  fm_spawns="$(frontmatter_field "$file" spawns)"
  fm_model="$(frontmatter_field "$file" model)"

  if [ -n "$fm_name" ]; then
    if ! is_kebab_case "$fm_name"; then
      warn "$file: name '$fm_name' is not kebab-case"
    fi
    base="$(basename "$file" .md)"
    snake_expected="$(echo "$fm_name" | tr '-' '_')"
    if [ "$base" != "$snake_expected" ]; then
      warn "$file: filename '$base.md' does not match expected snake_case of name ('$snake_expected.md')"
    fi
  fi

  if [ -n "$fm_desc" ] && [ "${#fm_desc}" -lt 20 ]; then
    warn "$file: description is very short (${#fm_desc} chars)"
  fi

  if [ -n "$fm_tools" ]; then
    local n_tools
    n_tools="$(split_csv "$fm_tools" | wc -l | tr -d ' ')"
    if [ "$n_tools" -lt 1 ]; then
      warn "$file: tools field looks empty"
    fi
  fi

  if [ -n "$fm_skills" ] && [ "$fm_skills" != "none" ]; then
    while IFS= read -r s; do
      [ -z "$s" ] && continue
      if ! skill_exists "$s"; then
        warn "$file: skill '$s' referenced but not found under skills/ or repo root"
      fi
    done < <(split_csv "$fm_skills")
  fi

  if [ -n "$fm_spawns" ] && [ "$fm_spawns" != "none" ]; then
    while IFS= read -r a; do
      [ -z "$a" ] && continue
      if ! agent_file_exists "$a"; then
        warn "$file: spawned agent '$a' has no matching AGENTS/*.md or */PRIVATE/AGENTS/*.md file (may be aspirational)"
      fi
    done < <(split_csv "$fm_spawns")
  fi

  if [ -n "$fm_model" ] && [[ ! "$fm_model" =~ ^claude- ]]; then
    warn "$file: model '$fm_model' doesn't look like a recognized claude-* model id"
  fi

  if ! grep -q "^## Completion" "$file"; then
    warn "$file: no '## Completion' section - agent may not emit a status code convention"
  fi
}

targets=()
if [ "$#" -eq 0 ]; then
  while IFS= read -r f; do
    targets+=("$f")
  done < <(find "$ROOT/AGENTS" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort)
  while IFS= read -r f; do
    targets+=("$f")
  done < <(find "$ROOT/WORKFLOWS" -type f -path "*/PRIVATE/AGENTS/*.md" 2>/dev/null | sort)
else
  targets=("$@")
fi

if [ "${#targets[@]}" -eq 0 ]; then
  echo "No agent files found to validate."
  exit 0
fi

for t in "${targets[@]}"; do
  validate_one_agent "$t"
done

section "Summary"
echo "Pass: $PASS_COUNT  Warn: $WARN_COUNT  Fail: $FAIL_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
