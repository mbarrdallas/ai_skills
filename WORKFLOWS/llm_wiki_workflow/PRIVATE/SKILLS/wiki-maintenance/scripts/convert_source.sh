#!/usr/bin/env bash
# Convert a non-text source document (PDF, docx, pptx, xlsx, HTML, ...) into
# markdown for ingestion into an LLM wiki's raw/ layer, using markitdown.
#
# Implements the "Non-text source formats" convention in the wiki-maintenance
# skill: raw/ stays uniformly plain-text/markdown so any future agent session
# can read sources without re-running extraction tooling.
#
# Accepts either a local file path or an http(s) URL (URLs are downloaded to a
# temp file, converted, and the temp download is always cleaned up).
#
# Usage:
#   convert_source.sh <input-file-or-url> <output.md> [--discard-original] [--force]
#
# Examples:
#   convert_source.sh ~/Downloads/manual.pdf raw/motorcoach/md-irp-manual.md
#   convert_source.sh "https://example.gov/media/249/download?inline=" \
#       raw/motorcoach/md-irp-manual.md
#   convert_source.sh ./statement.pdf raw/accounting-finance/2026-q1.md --discard-original
#
# Flags:
#   --discard-original  Delete a LOCAL original after a verified-good conversion.
#                       Never implied. Downloaded temp files are always removed
#                       regardless of this flag.
#   --force             Write the output even if quality heuristics flag the
#                       conversion as suspect (e.g. image-only/scanned PDF, or
#                       HTML that markitdown passed through unconverted).
#
# NOTE: for HTML input, prefer the dedicated `convert_html.sh` in this same
# directory. markitdown is unreliable on real-world HTML; this script now
# detects and refuses raw-HTML passthrough rather than letting it reach raw/.
#
# Exit codes: 0 ok, 1 usage/precondition error, 2 conversion failed,
#             3 conversion suspect (refused without --force)

set -uo pipefail

C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
C_BOLD=$'\033[1m'; C_RESET=$'\033[0m'
info() { printf "%s\n" "$1"; }
ok()   { printf "${C_GREEN}OK${C_RESET}    %s\n" "$1"; }
# Warnings explain refusals, so they belong on stderr alongside err() - not on
# stdout, where they get lost whenever a caller pipes stdout elsewhere.
warn() { printf "${C_YELLOW}WARN${C_RESET}  %s\n" "$1" >&2; }
err()  { printf "${C_RED}ERROR${C_RESET} %s\n" "$1" >&2; }

usage() {
  sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-1}"
}

# --- parse args -------------------------------------------------------------
INPUT=""; OUTPUT=""; DISCARD_ORIGINAL=0; FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --discard-original) DISCARD_ORIGINAL=1 ;;
    --force)            FORCE=1 ;;
    -h|--help)          usage 0 ;;
    -*) err "unknown flag: $1"; usage 1 ;;
    *)  if   [ -z "$INPUT"  ]; then INPUT="$1"
        elif [ -z "$OUTPUT" ]; then OUTPUT="$1"
        else err "unexpected extra argument: $1"; usage 1
        fi ;;
  esac
  shift
done

[ -n "$INPUT" ]  || { err "missing <input-file-or-url>"; usage 1; }
[ -n "$OUTPUT" ] || { err "missing <output.md>"; usage 1; }

case "$OUTPUT" in
  *.md) ;;
  *) err "output must end in .md (raw/ is uniformly markdown): $OUTPUT"; exit 1 ;;
esac

if [ -e "$OUTPUT" ] && [ "$FORCE" -eq 0 ]; then
  err "output already exists: $OUTPUT"
  err "raw/ sources are immutable once ingested - pick a new slug, or pass --force if you are deliberately replacing a bad conversion."
  exit 1
fi

command -v markitdown >/dev/null 2>&1 || {
  err "markitdown not found on PATH."
  err "Install with:  pipx install markitdown[all]   (or: pip install 'markitdown[all]')"
  err "See https://github.com/microsoft/markitdown"
  exit 1
}

# --- resolve input (download if URL) ---------------------------------------
TMPDIR_SELF=""
cleanup() { [ -n "$TMPDIR_SELF" ] && rm -rf "$TMPDIR_SELF"; }
trap cleanup EXIT

SRC="$INPUT"
SOURCE_URL=""
IS_DOWNLOAD=0

case "$INPUT" in
  http://*|https://*)
    command -v curl >/dev/null 2>&1 || { err "curl not found on PATH (needed for URL input)"; exit 1; }
    SOURCE_URL="$INPUT"
    IS_DOWNLOAD=1
    TMPDIR_SELF="$(mktemp -d)"
    SRC="$TMPDIR_SELF/download.bin"
    info "${C_BOLD}Downloading${C_RESET} $INPUT"
    # Some government/CDN hosts reject default curl UA; send a browser-ish one.
    http_code="$(curl -sSL -A "Mozilla/5.0" -o "$SRC" -w '%{http_code}' "$INPUT")" || {
      err "download failed"; exit 1; }
    if [ "$http_code" != "200" ]; then
      err "download returned HTTP $http_code"; exit 1
    fi
    ok "downloaded ($(wc -c <"$SRC" | tr -d ' ') bytes, $(file -b "$SRC" 2>/dev/null || echo 'unknown type'))"
    ;;
  *)
    [ -f "$INPUT" ] || { err "input file not found: $INPUT"; exit 1; }
    ;;
esac

# --- convert ---------------------------------------------------------------
mkdir -p "$(dirname "$OUTPUT")"
TMP_OUT="$(mktemp)"
trap 'cleanup; rm -f "$TMP_OUT"' EXIT

PAGES="$(file -b "$SRC" 2>/dev/null | grep -oE '[0-9]+ pages' | grep -oE '[0-9]+' || true)"

info "${C_BOLD}Converting${C_RESET} via markitdown${PAGES:+ ($PAGES pages)}"
if ! markitdown "$SRC" >"$TMP_OUT" 2>"$TMP_OUT.err"; then
  err "markitdown failed:"
  sed 's/^/      /' "$TMP_OUT.err" >&2
  rm -f "$TMP_OUT.err"
  exit 2
fi
rm -f "$TMP_OUT.err"

# --- quality heuristics ----------------------------------------------------
# Catch the failure mode the skill calls out: scanned/image-only PDFs with no
# extractable text layer convert "successfully" into near-empty markdown.
BYTES="$(wc -c <"$TMP_OUT" | tr -d ' ')"
ALNUM="$(tr -cd '[:alnum:]' <"$TMP_OUT" | wc -c | tr -d ' ')"
suspect=0

if [ "$ALNUM" -lt 200 ]; then
  warn "conversion contains almost no text ($ALNUM alphanumeric chars)"
  suspect=1
fi
if [ -n "$PAGES" ] && [ "$PAGES" -gt 0 ] 2>/dev/null; then
  per_page=$(( ALNUM / PAGES ))
  if [ "$per_page" -lt 100 ]; then
    warn "only ~$per_page alphanumeric chars per page across $PAGES pages - likely a scanned/image-only PDF with no text layer"
    suspect=1
  fi
fi

# Catch a SECOND real failure mode: markitdown silently passing HTML through
# unconverted. Observed on webapps.dol.gov, whose markup opens with a bogus
# `<!--doctype html-->` comment before the real DOCTYPE; markitdown emitted the
# page's raw HTML (scripts, stylesheets and all) and every text-volume
# heuristic above happily passed it, so a raw/ file full of <script> blocks
# entered the wiki unnoticed.
HTML_HITS="$(grep -c -oE '<(html|body|div|span|script|style|meta|link|!DOCTYPE)' "$TMP_OUT" 2>/dev/null || true)"
HTML_HITS="${HTML_HITS:-0}"
if [ "$HTML_HITS" -gt 3 ]; then
  warn "output contains $HTML_HITS raw HTML fragments - markitdown appears to have passed the source through unconverted"
  warn "for HTML input use the dedicated converter instead: convert_html.sh <url-or-file> <output.md>"
  suspect=1
fi

if [ "$suspect" -eq 1 ] && [ "$FORCE" -eq 0 ]; then
  err "conversion looks suspect - refusing to write $OUTPUT"
  # Report the diagnosis that actually applies, rather than always blaming OCR.
  if [ "$HTML_HITS" -gt 3 ]; then
    err "Diagnosis: the output is still raw HTML ($HTML_HITS markup fragments) -"
    err "markitdown passed the source through without converting it."
    err "Use the dedicated HTML converter instead:"
    err "  convert_html.sh '$INPUT' $OUTPUT"
  else
    err "Diagnosis: almost no extractable text - probably an image-only/scanned"
    err "document needing OCR first."
    err "Flag it to the human rather than ingesting a broken conversion."
  fi
  err "Re-run with --force only if the output is genuinely correct as-is."
  exit 3
fi

mv "$TMP_OUT" "$OUTPUT"
ok "wrote $OUTPUT ($BYTES bytes, $(wc -l <"$OUTPUT" | tr -d ' ') lines)"

# --- original handling -----------------------------------------------------
if [ "$IS_DOWNLOAD" -eq 1 ]; then
  info "Temp download discarded (per convention: markdown is the raw source going forward)."
elif [ "$DISCARD_ORIGINAL" -eq 1 ]; then
  rm -f "$SRC" && ok "discarded original: $SRC"
else
  warn "original kept: $SRC"
  warn "Convention is to discard it once the conversion is confirmed readable. Verify the output, then:"
  printf "        rm %q\n" "$SRC"
fi

# --- provenance reminder ---------------------------------------------------
printf "\n${C_BOLD}Record provenance in the source page:${C_RESET}\n"
printf "  - converted with markitdown on %s\n" "$(date +%F)"
[ -n "$SOURCE_URL" ] && printf "  - retrieved from %s\n" "$SOURCE_URL"
printf "  - original %s\n" "$([ "$IS_DOWNLOAD" -eq 1 ] || [ "$DISCARD_ORIGINAL" -eq 1 ] && echo "discarded after conversion" || echo "NOT yet discarded - see above")"
printf "\nNext: read the conversion in full and spot-check fidelity before ingesting.\n"
