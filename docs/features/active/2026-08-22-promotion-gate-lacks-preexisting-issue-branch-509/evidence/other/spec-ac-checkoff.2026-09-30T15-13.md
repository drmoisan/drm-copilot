# Spec Acceptance-Criteria Check-Off (P8-T22)

Timestamp: 2026-09-30T15-13
Task: [P8-T22]
AC source: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md` (Work Mode full-bug; spec is the sole AC source)

Checked off in this task: AC-19 (backing P8-T19) and AC-22 (backing P8-T13, P8-T16, P8-T18). AC-1, AC-3 to AC-17, AC-20, and AC-21 were checked off by earlier tasks when their evidence was verified. Only the checkbox characters were changed; `git diff --stat HEAD -- spec.md` shows 2 insertions and 2 deletions.

Command: grep -c -F -e "- [x] AC-" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md
EXIT_CODE: 0
Output Summary: `20` (task text expects `21`).

Command: grep -c -F -e "- [ ] AC-" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md
EXIT_CODE: 0
Output Summary: `2` (task text expects `1`). The unchecked criteria are AC-2 (spec line 313) and AC-18 (spec line 329).

## Criterion-to-evidence map

| AC | State | Backing artifacts |
| --- | --- | --- |
| AC-1 | checked | `evidence/regression-testing/py-split-suites.2026-09-30T14-13.md` (P1-T6), `evidence/other/split-commit.2026-09-30T14-16.md` (P1-T13), `evidence/regression-testing/py-split-at-commit.2026-09-30T14-16.md` (P1-T14) |
| AC-2 | **unchecked** | `evidence/qa-gates/split-line-counts.2026-09-30T14-14.md` (P1-T9, pass); `evidence/qa-gates/file-size-gate.2026-09-30T15-10.md` (P8-T17, **FAIL**: `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` has 744 lines) |
| AC-3 | checked | `evidence/regression-testing/py-split-suites.2026-09-30T14-13.md` (P1-T6) |
| AC-4 | checked | `evidence/regression-testing/py-importers-unchanged.2026-09-30T14-14.md` (P1-T7), `evidence/regression-testing/py-import-direction.2026-09-30T14-14.md` (P1-T8), `evidence/regression-testing/py-adoption-imports.2026-09-30T14-21.md` (P3-T6) |
| AC-5 | checked | `evidence/regression-testing/py-regression-expect-fail.2026-09-30T14-17.md` (P2-T3), `evidence/regression-testing/py-regression-pass-after.2026-09-30T14-19.md` (P3-T3) |
| AC-6, AC-7, AC-8 | checked | `evidence/regression-testing/py-adoption-unit.2026-09-30T14-21.md` (P3-T5), `evidence/regression-testing/ps-test-mcp.2026-09-30T14-34.md` (P5-T11), `evidence/regression-testing/ts-adoption-tests.2026-09-30T14-40.md` (P6-T6) |
| AC-9 | checked | P3-T3, P3-T5, P5-T11, P6-T6 artifacts above |
| AC-10 | checked | `evidence/regression-testing/py-regression-pass-after.2026-09-30T14-19.md` (P3-T3), `evidence/regression-testing/py-parity-pass.2026-09-30T14-24.md` (P4-T31) |
| AC-11 | checked | `evidence/regression-testing/py-presence-gating.2026-09-30T14-21.md` (P3-T7), P4-T31, P5-T11, `evidence/regression-testing/ts-validate-dir-pass-after.2026-09-30T14-40.md` (P6-T8) |
| AC-12, AC-13 | checked | `evidence/regression-testing/py-parity-pass.2026-09-30T14-24.md` (P4-T31), P5-T11, P6-T6 |
| AC-14 | checked | P3-T6, `evidence/regression-testing/ts-adoption-imports.2026-09-30T14-40.md` (P6-T7), P6-T8 |
| AC-15 | checked | `evidence/regression-testing/ps-bundle-copy.2026-09-30T14-34.md` (P5-T4), `evidence/regression-testing/ps-core-json.2026-09-30T14-29.md` (P5-T5), `evidence/regression-testing/ps-runsettings.2026-09-30T14-29.md` (P5-T6), P5-T11, `evidence/regression-testing/ps-bundle-tests.2026-09-30T14-36.md` (P5-T12) |
| AC-16 | checked | `evidence/regression-testing/ps-case-sensitive-operators.2026-09-30T14-32.md` (P5-T3, P5-T10), P5-T11 |
| AC-17 | checked | `evidence/regression-testing/codex-variants.2026-09-30T14-43.md` (P7-T7), `evidence/regression-testing/docs-mirror-tests.2026-09-30T14-44.md` (P7-T8), `evidence/regression-testing/docs-tokens.2026-09-30T14-44.md` (P7-T9) |
| AC-18 | **unchecked (by design)** | P7-T9 artifact; `evidence/other/follow-up-requests.2026-09-30T15-13.md` (P8-T20, P8-T21); the orchestrator's post-execution `new_potential_entry` step. Left for feature-review to check off once the two potential entries exist. |
| AC-19 | checked (this task) | `evidence/qa-gates/diff-scope.2026-09-30T15-12.md` (P8-T19) |
| AC-20 | checked | `evidence/qa-gates/py-black.2026-09-30T14-46.md`, `py-ruff.2026-09-30T14-48.md`, `py-pyright.2026-09-30T14-49.md`, `py-module-coverage.2026-09-30T14-50.md`, `py-pytest-coverage.2026-09-30T14-51.md` (P8-T5 to P8-T9), `py-coverage-delta.2026-09-30T15-11.md` (P8-T15) |
| AC-21 | checked | `evidence/qa-gates/jest-threshold-entries.2026-09-30T14-38.md` (P6-T3), `ts-format.2026-09-30T14-45.md`, `ts-lint.2026-09-30T14-45.md`, `ts-typecheck.2026-09-30T14-45.md`, `ts-coverage.2026-09-30T14-46.md` (P8-T1 to P8-T4), `ts-coverage-delta.2026-09-30T15-10.md` (P8-T14) |
| AC-22 | checked (this task) | `evidence/qa-gates/ps-test-coverage.2026-09-30T15-08.md` (P8-T13), `evidence/qa-gates/ps-coverage-delta.2026-09-30T15-12.md` (P8-T16), `evidence/qa-gates/no-temp-files.2026-09-30T15-11.md` (P8-T18) |

AC-18 is left for feature-review.

Result: FAIL against the task's acceptance counts (20/2 observed against 21/1 expected). The difference is AC-2, which cannot be checked off because P8-T17 failed. P8-T22 is left unchecked.
