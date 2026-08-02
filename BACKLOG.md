- [ ] Automated tests for `scripts/install_skills.sh` / `install_agents.sh`.
  They're currently covered only by a hand-run matrix documented in
  `scripts/README.md`. A test harness would point `$PI_SKILLS_DIR`/
  `$PI_AGENTS_DIR` at a temp dir (both scripts already support this) and
  assert the safety properties: no clobbering of real files, external-pointing
  links untouched, `--check` read-only, `--prune` only removing broken
  in-repo links. (found via: adding the install scripts, 2026-08-01)
- [x] Wire validation into a pre-commit hook. DONE 2026-08-01: `scripts/hooks/pre-commit` + `scripts/install_hooks.sh` (via `core.hooksPath`), installed by `install_all.sh`. Validates only staged items; harness-link check runs only when a skill/agent is added. CI is still open below.
  alongside `validate_all.sh`, so a new skill/agent that was never symlinked
  into the harness fails loudly instead of silently never triggering.
  (found via: adding the install scripts, 2026-08-01)
- [ ] Run the same validation in CI, so the pre-commit hook isn't the only
  gate (it is per-clone, and `--no-verify` bypasses it silently).
