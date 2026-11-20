# Remediation Cycle 1 QA Gate — Issue 1130 (finding F1, task P0-T1)

Timestamp: 2026-11-08T15-40
Command: env -u VIRTUAL_ENV <main .venv python> -m pytest -n auto -q -p no:cacheprovider --cov=scripts --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1130-cov-cycle1.json (launcher SCRATCH/issue-1130-pytest-cycle1.sh, run from the item worktree root)
EXIT_CODE: 0
Output Summary:
- pytest -n auto: 16537 passed, 0 failed, 6 skipped in 192.49s; scripts coverage TOTAL 94% (17653 statements, 915 missed; 6418 branches, 431 partial).
- Black --check on tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py: 1 file would be left unchanged (exit 0).
- Ruff check on the same file: All checks passed! (exit 0).
- Pyright --venvpath <main checkout> on the same file: 0 errors, 0 warnings, 0 informations (exit 0).
- Codex generator check (scripts.dev_tools.generate_codex_agent_variants --check): exit 0.
- The full run includes the Codex manifest-completeness, dependency-closure, bundle-parity, and test_ci_gate_epic_child_contracts.py tests, all passing.

Change summary:
- Added `.agents/skills/ci-workflows/SKILL.md` to the `paths` array of the Codex `core.json` pack manifest, in alphabetical position among the `.agents/skills/*` entries.
- Removed `.agents/skills/ci-workflows/SKILL.md` from `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`.
- Skill text unchanged.
