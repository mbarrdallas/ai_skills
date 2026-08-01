- [ ] Automated tests for `scripts/install_skills.sh` / `install_agents.sh`.
  They're currently covered only by a hand-run matrix documented in
  `scripts/README.md`. A test harness would point `$PI_SKILLS_DIR`/
  `$PI_AGENTS_DIR` at a temp dir (both scripts already support this) and
  assert the safety properties: no clobbering of real files, external-pointing
  links untouched, `--check` read-only, `--prune` only removing broken
  in-repo links. (found via: adding the install scripts, 2026-08-01)
- [ ] Consider wiring `install_all.sh --check` into a pre-commit hook or CI
  alongside `validate_all.sh`, so a new skill/agent that was never symlinked
  into the harness fails loudly instead of silently never triggering.
  (found via: adding the install scripts, 2026-08-01)
