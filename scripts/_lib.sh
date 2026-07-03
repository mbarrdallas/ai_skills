#!/usr/bin/env bash
# Shared helpers for validate_skill.sh / validate_agent.sh / validate_workflow.sh
# Source this file: source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

set -uo pipefail

# --- Colors (disabled if not a tty) ---
if [ -t 1 ]; then
  C_RED='\033[0;31m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'; C_BOLD='\033[1m'; C_RESET='\033[0m'
else
  C_RED=''; C_GREEN=''; C_YELLOW=''; C_BOLD=''; C_RESET=''
fi

# Counters (validators increment these; caller checks $FAIL_COUNT at the end)
FAIL_COUNT=0
WARN_COUNT=0
PASS_COUNT=0

pass() { PASS_COUNT=$((PASS_COUNT+1)); printf "${C_GREEN}PASS${C_RESET}  %s\n" "$1"; }
warn() { WARN_COUNT=$((WARN_COUNT+1)); printf "${C_YELLOW}WARN${C_RESET}  %s\n" "$1"; }
fail() { FAIL_COUNT=$((FAIL_COUNT+1)); printf "${C_RED}FAIL${C_RESET}  %s\n" "$1"; }
section() { printf "\n${C_BOLD}%s${C_RESET}\n" "$1"; }

# repo_root: locate the ai_skills repo root regardless of cwd.
repo_root() {
  local dir
  dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  echo "$dir"
}

# extract_frontmatter <file>: prints the YAML frontmatter block (between the
# first two '---' lines), or nothing if not present.
extract_frontmatter() {
  local file="$1"
  awk '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { exit }
    infm { print }
  ' "$file"
}

# frontmatter_field <file> <field>: prints the raw value of a top-level
# "field: value" line in the frontmatter (single-line values only).
frontmatter_field() {
  local file="$1" field="$2"
  extract_frontmatter "$file" | sed -n "s/^${field}: *//p" | head -1
}

# has_frontmatter <file>: returns 0 if file starts with a '---' block.
has_frontmatter() {
  local file="$1"
  [ "$(sed -n '1p' "$file")" = "---" ] && grep -q '^---$' <(tail -n +2 "$file")
}

# trim <string>
trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  echo "$s"
}

# split_csv <string>: prints each comma-separated, trimmed item on its own line.
split_csv() {
  local s="$1"
  IFS=',' read -ra parts <<< "$s"
  for p in "${parts[@]}"; do
    trim "$p"
  done
}

# is_kebab_case <string>
is_kebab_case() {
  [[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

# check_no_hardcoded_paths_or_credentials <file> <label>
# Scans a file for hardcoded absolute home-directory paths and
# credential-shaped strings. FAILs (hard rule, per workflow-conventions
# skill) rather than warning, since these break portability/leak info.
# Increments FAIL_COUNT/PASS_COUNT directly via fail()/pass().
check_no_hardcoded_paths_or_credentials() {
  local file="$1" label="$2"
  local path_matches cred_matches
  local found=0

  # Hardcoded absolute home-directory paths: /Users/<name>/... or /home/<name>/...
  path_matches=$(grep -nE '/(Users|home)/[A-Za-z0-9_.-]+/' "$file" 2>/dev/null || true)
  if [ -n "$path_matches" ]; then
    found=1
    fail "$label: hardcoded absolute home-directory path(s) found (use ~ or a relative/LOCATIONS-style reference instead):"
    while IFS= read -r line; do
      [ -n "$line" ] && printf "        %s\n" "$line"
    done <<< "$path_matches"
  fi

  # Credential-shaped strings: common API key/token/secret patterns.
  # Heuristic, not exhaustive - covers the most common accidental-leak shapes.
  # Anchored to line-start (optionally indented) so prose/code mentioning
  # "token"/"secret" in passing (e.g. "const token = auth.createToken(user)")
  # doesn't false-positive - only a config/env-style "key: value" or
  # "KEY=value" assignment at the start of a line counts. Value charset
  # deliberately excludes '.' and '(' so dotted/function-call-shaped code
  # examples (not literal secret values) don't match either.
  cred_matches=$(grep -nEi \
    -e 'AKIA[0-9A-Z]{16}' \
    -e 'gh[pousr]_[A-Za-z0-9]{20,}' \
    -e 'sk-[A-Za-z0-9]{20,}' \
    -e '^[[:space:]]*(api[_-]?key|secret|token|password)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9/_+=-]{12,}' \
    "$file" 2>/dev/null || true)
  if [ -n "$cred_matches" ]; then
    found=1
    fail "$label: possible embedded credential/secret found (never commit real credentials in shared definitions):"
    while IFS= read -r line; do
      [ -n "$line" ] && printf "        %s\n" "$line"
    done <<< "$cred_matches"
  fi

  if [ "$found" -eq 0 ]; then
    pass "$label: no hardcoded absolute paths or embedded credentials found"
  fi
}
