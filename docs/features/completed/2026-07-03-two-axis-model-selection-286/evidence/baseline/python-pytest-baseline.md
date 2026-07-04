# Phase 0 — Python Test / Coverage Baseline

Timestamp: 2026-07-03T16-43

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Output Summary:
- Tests: 1204 passed, 19 skipped (skips are `.codex`/`.agents` gitignored-in-CI content-parity tests, expected).
- TOTAL combined coverage (line + branch, `--cov-branch`): 84%.
- Aggregate statement counts: 9054 statements, 1242 missed; 3262 branches, 447 partial.
- Line coverage baseline is 84% aggregate. This is a pre-existing repository-wide figure driven by host-bound scripts with low coverage (e.g., `shell_qc.py` 0%, `tk_dialog_helpers.py` 45%). The uniform coverage gate for this feature is enforced on the changed/new modules (per-module >= 85% line, >= 75% branch) and no-regression-on-changed-lines, per `.claude/rules/quality-tiers.md`. New feature modules are measured individually in Phase 1 and Phase 3 tasks and in P8-T4.
