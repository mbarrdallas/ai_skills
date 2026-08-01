#!/usr/bin/env bash
#
# convert_html.sh - convert an HTML page (file or URL) into clean markdown for
# an LLM wiki's raw/ layer.
#
# WHY THIS EXISTS SEPARATELY FROM convert_source.sh
# --------------------------------------------------
# convert_source.sh delegates to `markitdown`, which handles PDF/docx/pptx/xlsx
# well but is unreliable on real-world HTML: on at least one .gov page
# (webapps.dol.gov, whose markup opens with a `<!--doctype html-->` comment
# before the real DOCTYPE) markitdown emitted the raw HTML unchanged, and the
# raw file silently entered the wiki full of <script> blocks. This script is
# HTML-specific, stdlib-only, and refuses to write output that still contains
# markup.
#
# Deliberately self-contained (no scripts/_lib.sh): this runs inside consuming
# wiki repos where ai_skills is a git submodule, so it must not depend on the
# parent repo's helper layout.
#
# Requires: python3 (stdlib only - no pip installs, no network libraries) and,
# for URL input, curl.
#
set -euo pipefail

BOLD=$'\033[1m'; RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; RST=$'\033[0m'
info()  { printf '%s%s%s %s\n' "$BOLD" "$1" "$RST" "$2"; }
warn()  { printf '%sWARN%s %s\n' "$YEL" "$RST" "$1" >&2; }
err()   { printf '%sERROR%s %s\n' "$RED" "$RST" "$1" >&2; }
ok()    { printf '%sOK%s %s\n' "$GRN" "$RST" "$1"; }

usage() {
  cat <<'EOF'
Convert an HTML page (local file or http(s) URL) into clean markdown for
ingestion into an LLM wiki's raw/ layer.

Keeps: headings, paragraphs, lists, links (with URLs resolved to absolute),
tables, blockquotes, code, emphasis. Drops: script/style/head/comments, and
nav/header/footer/aside chrome plus common boilerplate link text.

Usage:
  convert_html.sh <input-file-or-url> <output.md> [options]

Options:
  --force          Write output even if quality heuristics flag it as suspect.
  --keep-nav       Keep <nav>/<header>/<footer>/<aside> regions (default: drop).
  --min-words N    Minimum word count before output is considered suspect.
                   Default: 50.
  -h, --help       Show this help.

Examples:
  convert_html.sh https://webapps.dol.gov/elaws/elg/ raw/motorcoach/dol-elg.md
  convert_html.sh ./saved-page.html raw/llm-research/some-article.md

Exit codes:
  0  success
  1  unexpected error (missing dependency, download failure, bad usage)
  2  refused: output file exists (use a different name or remove it first)
  3  refused: conversion looks bad (still contains markup, or too little text).
     Re-run with --force to write it anyway.
EOF
}

INPUT=""; OUTPUT=""; FORCE=0; KEEP_NAV=0; MIN_WORDS=50
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --force) FORCE=1; shift ;;
    --keep-nav) KEEP_NAV=1; shift ;;
    --min-words) MIN_WORDS="${2:-50}"; shift 2 ;;
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
command -v python3 >/dev/null 2>&1 || { err "python3 not found"; exit 1; }

if [ -e "$OUTPUT" ]; then
  err "output already exists: $OUTPUT"
  err "raw/ is immutable by convention - pick a new name or remove it deliberately."
  exit 2
fi

TMPDIR_C="$(mktemp -d)"
# shellcheck disable=SC2317
cleanup() { rm -rf "$TMPDIR_C"; }
trap cleanup EXIT

SRC_HTML="$TMPDIR_C/page.html"
BASE_URL=""

case "$INPUT" in
  http://*|https://*)
    command -v curl >/dev/null 2>&1 || { err "curl not found (needed for URL input)"; exit 1; }
    info "Downloading" "$INPUT"
    # A browser-ish UA: several .gov hosts 403 default curl.
    HTTP_CODE="$(curl -sSL --compressed \
      -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
      -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
      -H "Accept-Language: en-US,en;q=0.9" \
      -o "$SRC_HTML" -w '%{http_code}' "$INPUT" || true)"
    if [ "$HTTP_CODE" != "200" ]; then
      err "download returned HTTP $HTTP_CODE"
      if [ "$HTTP_CODE" = "403" ]; then
        err "host is blocking automated access. Try a Wayback snapshot, e.g.:"
        err "  convert_html.sh \"http://web.archive.org/web/2024/$INPUT\" $OUTPUT"
      fi
      exit 1
    fi
    BASE_URL="$INPUT"
    ;;
  *)
    [ -f "$INPUT" ] || { err "no such file: $INPUT"; exit 1; }
    cp "$INPUT" "$SRC_HTML"
    ;;
esac

mkdir -p "$(dirname "$OUTPUT")"
RAW_MD="$TMPDIR_C/out.md"

KEEP_NAV="$KEEP_NAV" BASE_URL="$BASE_URL" SRC_URL="$INPUT" \
python3 - "$SRC_HTML" "$RAW_MD" <<'PYEOF'
"""HTML -> markdown, stdlib only, deterministic."""
import html
import os
import re
import sys
from html.parser import HTMLParser
from urllib.parse import urljoin

src_path, out_path = sys.argv[1], sys.argv[2]
keep_nav = os.environ.get("KEEP_NAV") == "1"
base_url = os.environ.get("BASE_URL") or ""

DROP_ENTIRELY = {"script", "style", "head", "noscript", "svg", "form",
                 "iframe", "template", "select", "button"}
CHROME = {"nav", "header", "footer", "aside"}
BLOCK = {"p", "div", "section", "article", "main", "br", "hr", "tr"}
HEADINGS = {f"h{i}": i for i in range(1, 7)}

# Boilerplate link/list text common to government and CMS sites.
NOISE = (
    "skip to main", "skip navigation", "search dol", "dol home", "return to top",
    "top of page", "freedom of information", "privacy and security",
    "accessibility", "site map", "siteindex", "a to z index", "plug-ins",
    "important website notices", "subscribe to the", "office of inspector general",
    "read the dol newsletter", "emergency accountability", "espa\u00f1ol",
    "cookie", "javascript must be enabled", "share on", "print this page",
)


class Converter(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.out = []
        self.drop_depth = 0
        self.chrome_depth = 0
        self.pre_depth = 0
        self.list_stack = []      # 'ul' | 'ol'
        self.ol_counters = []
        self.heading = None
        self.buf = []
        self.href = None
        self.link_text = []
        self.in_link = False
        self.emph = 0
        self.strong = 0
        self.in_td = False
        self.row = []
        self.table_rows = []
        self.in_table = 0

    # -- helpers ---------------------------------------------------------
    def skipping(self):
        return self.drop_depth > 0 or (self.chrome_depth > 0 and not keep_nav)

    def flush(self):
        text = "".join(self.buf).strip()
        self.buf = []
        if not text:
            return
        text = re.sub(r"[ \t]+", " ", text)
        if self.heading:
            self.out.append(("heading", self.heading, text))
        elif self.list_stack:
            self.out.append(("item", len(self.list_stack), text,
                             self.list_stack[-1], self._next_num()))
        else:
            self.out.append(("para", text))

    def _next_num(self):
        if self.list_stack and self.list_stack[-1] == "ol" and self.ol_counters:
            self.ol_counters[-1] += 1
            return self.ol_counters[-1]
        return None

    # -- tag handling ----------------------------------------------------
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag in DROP_ENTIRELY:
            self.drop_depth += 1
            return
        if tag in CHROME:
            self.chrome_depth += 1
            return
        if self.skipping():
            return

        if tag == "pre":
            self.flush(); self.pre_depth += 1; return
        if tag in HEADINGS:
            self.flush(); self.heading = HEADINGS[tag]; return
        if tag in ("ul", "ol"):
            self.flush(); self.list_stack.append(tag)
            if tag == "ol":
                self.ol_counters.append(0)
            return
        if tag == "li":
            self.flush(); return
        if tag == "a":
            self.in_link = True
            self.href = a.get("href")
            self.link_text = []
            return
        if tag in ("strong", "b"):
            self.strong += 1; self.buf.append("**"); return
        if tag in ("em", "i"):
            self.emph += 1; self.buf.append("*"); return
        if tag == "code" and self.pre_depth == 0:
            self.buf.append("`"); return
        if tag == "blockquote":
            self.flush(); self.out.append(("quote_start",)); return
        if tag == "table":
            self.flush(); self.in_table += 1; self.table_rows = []; return
        if tag == "tr" and self.in_table:
            self.row = []; return
        if tag in ("td", "th") and self.in_table:
            self.in_td = True; self.buf = []; return
        if tag == "br":
            self.buf.append(" "); return
        if tag == "hr":
            self.flush(); self.out.append(("hr",)); return
        if tag in BLOCK:
            self.flush(); return

    def handle_endtag(self, tag):
        if tag in DROP_ENTIRELY:
            self.drop_depth = max(0, self.drop_depth - 1); return
        if tag in CHROME:
            self.chrome_depth = max(0, self.chrome_depth - 1); return
        if self.skipping():
            return

        if tag == "pre":
            text = "".join(self.buf).rstrip(); self.buf = []
            if text:
                self.out.append(("code", text))
            self.pre_depth = max(0, self.pre_depth - 1)
            return
        if tag in HEADINGS:
            self.flush(); self.heading = None; return
        if tag in ("ul", "ol"):
            self.flush()
            if self.list_stack:
                popped = self.list_stack.pop()
                if popped == "ol" and self.ol_counters:
                    self.ol_counters.pop()
            return
        if tag == "li":
            self.flush(); return
        if tag == "a":
            label = "".join(self.link_text).strip()
            label = re.sub(r"\s+", " ", label)
            self.in_link = False
            href = (self.href or "").strip()
            self.href = None
            if not label:
                return
            if (not href) or href.startswith("#") or href.lower().startswith("javascript"):
                self.buf.append(label); return
            if base_url:
                href = urljoin(base_url, href)
            self.buf.append(f"[{label}]({href})")
            return
        if tag in ("strong", "b"):
            if self.strong:
                self.strong -= 1; self.buf.append("**")
            return
        if tag in ("em", "i"):
            if self.emph:
                self.emph -= 1; self.buf.append("*")
            return
        if tag == "code" and self.pre_depth == 0:
            self.buf.append("`"); return
        if tag == "blockquote":
            self.flush(); self.out.append(("quote_end",)); return
        if tag in ("td", "th") and self.in_table:
            cell = re.sub(r"\s+", " ", "".join(self.buf)).strip()
            self.buf = []; self.in_td = False
            self.row.append(cell); return
        if tag == "tr" and self.in_table:
            if any(c for c in self.row):
                self.table_rows.append(self.row)
            self.row = []; return
        if tag == "table":
            if self.table_rows:
                self.out.append(("table", self.table_rows))
            self.table_rows = []
            self.in_table = max(0, self.in_table - 1)
            return
        if tag in BLOCK:
            self.flush(); return

    def handle_data(self, data):
        if self.skipping():
            return
        if self.pre_depth:
            self.buf.append(data); return
        if not data.strip():
            if self.buf and not self.buf[-1].endswith(" "):
                self.buf.append(" ")
            return
        if self.in_link:
            self.link_text.append(data)
        else:
            self.buf.append(data)


raw = open(src_path, encoding="utf-8", errors="replace").read()
raw = re.sub(r"(?is)<!--.*?-->", "", raw)  # comments (incl. bogus pre-DOCTYPE ones)

c = Converter()
c.feed(raw)
c.close()
c.flush()

lines = []
in_quote = False


def is_noise(t):
    low = t.lower()
    return any(n in low for n in NOISE)


for node in c.out:
    kind = node[0]
    if kind == "heading":
        _, level, text = node
        if is_noise(text):
            continue
        lines += ["", "#" * min(level, 6) + " " + text, ""]
    elif kind == "para":
        text = node[1]
        if is_noise(text) or len(text) < 3:
            continue
        lines += [("> " + text) if in_quote else text, ""]
    elif kind == "item":
        _, depth, text, kind_l, num = node
        if is_noise(text):
            continue
        indent = "  " * (depth - 1)
        bullet = f"{num}." if (kind_l == "ol" and num) else "-"
        lines.append(f"{indent}{bullet} {text}")
    elif kind == "code":
        lines += ["", "```", node[1], "```", ""]
    elif kind == "table":
        rows = node[1]
        width = max(len(r) for r in rows)
        rows = [r + [""] * (width - len(r)) for r in rows]
        lines += ["", "| " + " | ".join(rows[0]) + " |",
                  "|" + "|".join([" --- "] * width) + "|"]
        for r in rows[1:]:
            lines.append("| " + " | ".join(r) + " |")
        lines.append("")
    elif kind == "quote_start":
        in_quote = True
    elif kind == "quote_end":
        in_quote = False
        lines.append("")
    elif kind == "hr":
        lines += ["", "---", ""]

md = "\n".join(lines)
md = re.sub(r"\n{3,}", "\n\n", md)
md = re.sub(r"[ \t]+\n", "\n", md).strip() + "\n"

open(out_path, "w", encoding="utf-8").write(md)
PYEOF

[ -s "$RAW_MD" ] || { err "conversion produced no output"; exit 3; }

# ---- Quality gates -------------------------------------------------------
TAGS="$(grep -c -oE '<(html|body|div|span|script|style|a |p>|table|meta|link)' "$RAW_MD" 2>/dev/null || true)"
TAGS="${TAGS:-0}"
WORDS="$(wc -w < "$RAW_MD" | tr -d ' ')"

SUSPECT=0
if [ "$TAGS" -gt 3 ]; then
  warn "output still contains $TAGS HTML-looking fragments - conversion may have failed"
  SUSPECT=1
fi
if [ "$WORDS" -lt "$MIN_WORDS" ]; then
  warn "output has only $WORDS words (minimum $MIN_WORDS) - page may be JS-rendered"
  SUSPECT=1
fi

if [ "$SUSPECT" -eq 1 ] && [ "$FORCE" -eq 0 ]; then
  err "refusing to write a suspect conversion. Inspect it, then re-run with --force if it is genuinely fine:"
  err "  $RAW_MD"
  cp "$RAW_MD" "${OUTPUT}.rejected" 2>/dev/null || true
  err "  (a copy was left at ${OUTPUT}.rejected for inspection)"
  exit 3
fi

cp "$RAW_MD" "$OUTPUT"
ok "wrote $OUTPUT ($WORDS words)"

printf '\n%sRecord provenance in the source page:%s\n' "$BOLD" "$RST"
printf '  - converted from HTML with convert_html.sh on %s\n' "$(date +%Y-%m-%d)"
printf '  - retrieved from %s\n' "$INPUT"
if [ "$SUSPECT" -eq 1 ]; then
  printf '  - %sconversion was flagged suspect and written with --force - spot-check fidelity%s\n' "$YEL" "$RST"
fi
printf '\nNext: read the conversion in full and spot-check fidelity before ingesting.\n'
