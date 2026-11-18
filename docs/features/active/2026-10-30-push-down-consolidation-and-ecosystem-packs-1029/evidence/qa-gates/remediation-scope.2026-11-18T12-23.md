# Remediation scope and test-gate selection (cycle 1)

Timestamp: 2026-11-18T12-23
Command: `git diff --name-status REM_BASE HEAD` (REM_BASE: the commit that adds the remediation plan, from `git log --diff-filter=A` on the plan path); `git status --porcelain`; `git grep -c -e harness-generation -- 'tests/*.py' 'tests/*.ts' 'extensions/*.py' 'extensions/*.ts'`
EXIT_CODE: 0
Output Summary: The union of committed and uncommitted changes since REM_BASE is `SRC.md`, `SRC.json`, and files under the feature folder. `git status --porcelain` is empty. The search over `*.py` and `*.ts` under `tests/` and `extensions/` for `harness-generation` returned zero matches (git grep exit 1, no output). Both conditions hold, so the pytest and Jest gates are not run (plan decision D4).

## Paths changed since REM_BASE

Outside the feature folder:

- `M scripts/harness-generation/sources/rules/orchestrator-state.json`
- `M scripts/harness-generation/sources/rules/orchestrator-state.md`

Under the feature folder:

- `M remediation-plan.2026-11-18T11-45.md` (task check-offs)
- `A evidence/other/preflight-fixes.2026-11-18T12-04.md`
- `A evidence/remediation-baseline/remediation-baseline-reference.2026-11-18T12-07.md`
- `A evidence/regression-testing/fail-before.generator-check.2026-11-18T12-08.md`
- `A evidence/regression-testing/fail-before.repo-gate.2026-11-18T12-16.md`
- `A evidence/other/regeneration.2026-11-18T12-21.md`
- `A evidence/qa-gates/final-qc-static.2026-11-18T12-22.md`
- `A evidence/other/correction.final-jest-entry-count.2026-11-18T12-22.md`
- `A evidence/other/task-check.P0-T1.*` through `task-check.P1-T5.*`

## Gate selection

- pytest: not run. `evidence/qa-gates/final-pytest.2026-11-18T11-19.md` remains the current pytest gate record.
- Jest: not run. `evidence/qa-gates/final-jest.2026-11-18T11-19.md` remains the current Jest gate record. Its entry count is corrected by `evidence/other/correction.final-jest-entry-count.2026-11-18T12-22.md`.
- Pester: run once in P1-T7.

## File size

No changed file is a production, test, or script file under the size policy. The two changed files are a Markdown generator body and a JSON section list.
