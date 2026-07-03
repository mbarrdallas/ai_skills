# Lint Report — <domain-or-"all"> — <YYYY-MM-DD>

Scope: <domain slug, or "all" for a full-wiki pass>
Pages reviewed: <count, or "all pages under wiki/<domain>/">
Triggered by: <human request / domain growth threshold / scheduled pass>

---

## Summary

<1-3 sentence summary — same content that goes into the `wiki/log.md` entry
for this pass. Written last, after the sections below are filled in.>

---

## Findings

Only include subsections with actual findings — omit a subsection entirely
if it's clean (don't write "none found" for every category; note it once in
the Summary instead, e.g. "no contradictions or stale claims this pass").

### Contradictions

- **<page A> vs. <page B>**: <what conflicts, and which claim looks more
  current/authoritative, if determinable>. Resolution: <fixed directly /
  filed to BACKLOG.md — human decision needed on which claim is correct>.

### Stale claims

- **<page>**: <claim> is superseded by <newer source/page>, not yet
  updated. Resolution: <fixed directly / filed to BACKLOG.md>.

### Orphan pages

(Content-to-content links only — a page listed in a domain `index.md` but
with zero inbound links from *other content pages* still counts as an
orphan here.)

- **<page>**: no inbound links from other concept/source pages. Resolution:
  <linked it from <page(s)> / filed to BACKLOG.md if unclear where it
  belongs>.

### One-directional links

- **<page A> → <page B>**: A links to B but B doesn't link back.
  Resolution: <fixed directly by adding reciprocal link / filed to
  BACKLOG.md>.

### Missing concept pages

- **<concept name>**: mentioned repeatedly across <page list> but has no
  dedicated page yet. Resolution: filed to BACKLOG.md (new-content
  candidates are not created by the lint agent itself).

### Other missing cross-references

- **<page>**: should link to <page/concept> given <reason>, doesn't yet.
  Resolution: <fixed directly / filed to BACKLOG.md>.

### Data gaps

- **<page/topic>**: <what's missing that a web search or new source could
  fill>. Resolution: filed to BACKLOG.md.

---

## Fixes applied directly this pass

- <file>: <one-line description of the fix>
- <file>: <one-line description of the fix>

(Only unambiguous fixes belong here — e.g. adding a missing reciprocal
link. Anything requiring a content/editorial judgment call goes to
BACKLOG.md instead, not applied silently.)

## BACKLOG.md changes this pass

- Filed: <item> (domain: <slug>)
- Checked off (already resolved): <item>

## `wiki/log.md` entry

```
## [YYYY-MM-DD] lint   | <domain or "all"> | <same short summary as above>
```
