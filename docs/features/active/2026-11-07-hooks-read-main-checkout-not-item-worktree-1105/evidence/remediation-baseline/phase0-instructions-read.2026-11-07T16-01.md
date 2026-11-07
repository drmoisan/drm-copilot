# Phase 0: Policy Reads (Issue 1105, Remediation Cycle 1)

Timestamp: 2026-11-07T16-01
Task: [P0-T1]
Policy Order: CLAUDE.md, general code change, general unit test, PowerShell, Python (contract tests only), quality tiers, execution-environment brief, then the remediation inputs.

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/python.md` (contract tests only; no Python file is edited)
6. `.claude/rules/quality-tiers.md` (`quality-tiers.yml` governs tier gates only where present)
7. `.claude/skills/execution-environment/SKILL.md`
8. `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/remediation-inputs.2026-11-07T15-37.md`

Baseline artifacts this cycle compares against (greatest match under `FEATURE/evidence/baseline/`):

- `pester-parallel.2026-11-07T14-41.md`: ExitCode 0; 15553 tests, 15543 passed, 0 failed, 10 skipped; repository line coverage 94.01%; per-file coverage for the six hooks edited this cycle (task-researcher 98.17%, prd-feature 100.00%, required-artifact 98.44%, planner 99.53%, executor 99.42%, feature-review-coverage 100.00%).
- `pytest-parallel.2026-11-07T14-43.md`: EXIT_CODE 0; 16179 passed, 0 failed, 6 skipped.
- `poshqc-format.2026-11-07T14-34.md`: 295 files scanned; 0 files the formatter would change.
- `poshqc-analyze.2026-11-07T14-34.md`: 295 files scanned; 0 findings.
