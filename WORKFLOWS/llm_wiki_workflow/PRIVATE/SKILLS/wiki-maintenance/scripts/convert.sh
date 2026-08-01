#!/usr/bin/env bash
#
# convert.sh - THE single entry point for converting any source document into
# markdown for an LLM wiki's raw/ layer.
#
# Detects the document type and delegates to the right specialist:
#
#   HTML page (URL or local .html)  -> convert_html.sh   (stdlib Python)
#   everything else (PDF/docx/...)  -> convert_source.sh (markitdown)
#
# Callers should use THIS script and not have to know which converter applies.
# The two specialists remain directly callable for when you want to force a
# particular path.
#
# Detection order (first match wins):
#   1. --as html | --as source        explicit override, no sniffing
#   2. Content-Type header            for http(s) input (via a HEAD request)
#   3. filename extension             .html/.htm  vs  .pdf/.docx/...
#   4. magic bytes / `file` output    for local files
#   5. default                        -> convert_source.sh
#
# Safety net: if convert_source.sh refuses with exit 3 *because* markitdown
# passed raw HTML through, this script automatically retries via
# convert_html.sh rather than dead-ending. That is the exact failure that
# motivated splitting the converters in the first place.
#
# Deliberately self-contained (no scripts/_lib.sh): runs inside consuming wiki
# repos where ai_skills is a git submodule.
#
set -uo pipefail

C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
C_BOLD=$'\033[1m'; C_RESET=$'\033[0m'
info() { printf "%s%s%s %s\n" "$C_BOLD" "$1" "$C_RESET" "$2"; }
ok()   { printf "${C_GREEN}OK${C_RESET}    %s\n" "$1"; }
warn() { printf "${C_YELLOW}WARN${C_RESET}  %s\n" "$1" >&2; }
err()  { printf "${C_RED}ERROR${C_RESET} %s\n" "$1" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Convert any source document (PDF, docx, pptx, xlsx, HTML page, ...) into
markdown for an LLM wiki's raw/ layer. Detects the type and delegates to the
appropriate converter.

Usage:
  convert.sh <input-file-or-url> <output.md> [options]

Options:
  --as html|source   Skip detection and force a converter.
  --force            Write output even if quality heuristics flag it suspect.
  --discard-original Delete a LOCAL original after a good conversion
                     (passed through to convert_source.sh only).
  --keep-nav         Keep nav/header/footer regions (HTML path only).
  --min-words N      Minimum acceptable word count (HTML path only).
  -h, --help         Show this help.

Examples:
  convert.sh https://example.gov/manual.pdf     raw/motorcoach/manual.md
  convert.sh https://webapps.dol.gov/elaws/elg/ raw/motorcoach/dol-elg.md
  convert.sh ./statement.pdf raw/accounting-finance/2026-q1.md --discard-original

Exit codes: propagated from the delegate.
  0 ok, 1 usage/precondition, 2 conversion failed or output exists,
  3 conversion suspect (refused without --force)
EOF
}

INPUT=""; OUTPUT=""; FORCE_AS=""; PASS_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --as)
      FORCE_AS="${2:-}"
      case "$FORCE_AS" in
        html|source) ;;
        *) err "--as expects 'html' or 'source', got '${FORCE_AS:-}'"; exit 1 ;;
      esac
      shift 2 ;;
    --force|--keep-nav|--discard-original) PASS_ARGS+=("$1"); shift ;;
    --min-words) PASS_ARGS+=("$1" "${2:-50}"); shift 2 ;;
    -*) err "unknown flag: $1"; usage >&2; exit 1 ;;
    *)
      if [ -z "$INPUT" ]; then INPUT="$1"
      elif [ -z "$OUTPUT" ]; then OUTPUT="$1"
      else err "unexpected extra argument: $1"; exit 1
      fi
      shift ;;
  esac
done

[ -n "$INPUT" ] && [ -n "$OUTPUT" ] || { usage >&2; exit 1; }

HTML_SH="$SCRIPT_DIR/convert_html.sh"
SOURCE_SH="$SCRIPT_DIR/convert_source.sh"
[ -x "$HTML_SH" ]   || { err "missing or non-executable: $HTML_SH"; exit 1; }
[ -x "$SOURCE_SH" ] || { err "missing or non-executable: $SOURCE_SH"; exit 1; }

# ---- type detection -------------------------------------------------------
detect_kind() {
  local in="$1" ct="" lower=""
  lower="$(printf '%s' "$in" | tr '[:upper:]' '[:lower:]')"

  case "$in" in
    http://*|https://*)
      # Strip query string before extension matching so ...?inline= still works.
      local path_only="${lower%%\?*}"
      case "$path_only" in
        *.pdf|*.docx|*.doc|*.pptx|*.ppt|*.xlsx|*.xls|*.csv|*.epub|*.zip) echo source; return ;;
        *.html|*.htm) echo html; return ;;
      esac
      if command -v curl >/dev/null 2>&1; then
        ct="$(curl -sSLI --compressed -m 20 \
              -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
              "$in" 2>/dev/null \
              | tr -d '\r' | awk -F': ' 'tolower($1)=="content-type"{print tolower($2)}' | tail -1)"
      fi
      case "$ct" in
        *pdf*|*officedocument*|*msword*|*excel*|*powerpoint*|*epub*|*octet-stream*) echo source; return ;;
        *html*|*xhtml*) echo html; return ;;
      esac
      # No usable signal (e.g. HEAD blocked). A bare URL with no file extension
      # is far more often a web page than a binary document.
      case "$path_only" in
        */) echo html; return ;;
        *.*) echo source; return ;;
        *) echo html; return ;;
      esac
      ;;
    *)
      case "$lower" in
        *.html|*.htm|*.xhtml) echo html; return ;;
        *.pdf|*.docx|*.doc|*.pptx|*.ppt|*.xlsx|*.xls|*.csv|*.epub) echo source; return ;;
      esac
      if [ -f "$in" ]; then
        if command -v file >/dev/null 2>&1; then
          local ftype
          ftype="$(file -b "$in" 2>/dev/null | tr '[:upper:]' '[:lower:]')"
          case "$ftype" in
            *html*) echo html; return ;;
            *pdf*|*word*|*excel*|*powerpoint*|*opendocument*|*zip*) echo source; return ;;
          esac
        fi
        # Sniff leading bytes as a last resort.
        local head5
        head5="$(head -c 512 "$in" 2>/dev/null | tr -d '\0' | tr '[:upper:]' '[:lower:]')"
        case "$head5" in
          *'<!doctype html'*|*'<html'*) echo html; return ;;
          %pdf*) echo source; return ;;
        esac
      fi
      echo source
      ;;
  esac
}

if [ -n "$FORCE_AS" ]; then
  KIND="$FORCE_AS"
  info "Type" "$KIND (forced via --as)"
else
  KIND="$(detect_kind "$INPUT")"
  info "Type" "$KIND (detected)"
fi

run_html() {
  local args=()
  # convert_source-only flags are meaningless on the HTML path.
  for a in "${PASS_ARGS[@]+"${PASS_ARGS[@]}"}"; do
    [ "$a" = "--discard-original" ] && continue
    args+=("$a")
  done
  "$HTML_SH" "$INPUT" "$OUTPUT" "${args[@]+"${args[@]}"}"
}

run_source() {
  local args=()
  # HTML-only flags are meaningless on the markitdown path.
  local skip_next=0
  for a in "${PASS_ARGS[@]+"${PASS_ARGS[@]}"}"; do
    if [ "$skip_next" = 1 ]; then skip_next=0; continue; fi
    case "$a" in
      --keep-nav) continue ;;
      --min-words) skip_next=1; continue ;;
    esac
    args+=("$a")
  done
  "$SOURCE_SH" "$INPUT" "$OUTPUT" "${args[@]+"${args[@]}"}"
}

if [ "$KIND" = "html" ]; then
  run_html
  exit $?
fi

# markitdown path, with an automatic HTML fallback.
SRC_ERR="$(mktemp)"
trap 'rm -f "$SRC_ERR"' EXIT
run_source 2> >(tee "$SRC_ERR" >&2)
RC=$?

if [ "$RC" -eq 3 ] && grep -qi "raw HTML" "$SRC_ERR" 2>/dev/null; then
  warn "markitdown returned raw HTML - retrying automatically via convert_html.sh"
  # convert_source.sh refuses without writing, but it may leave a .rejected file.
  rm -f "${OUTPUT}.rejected"
  run_html
  exit $?
fi

exit "$RC"
