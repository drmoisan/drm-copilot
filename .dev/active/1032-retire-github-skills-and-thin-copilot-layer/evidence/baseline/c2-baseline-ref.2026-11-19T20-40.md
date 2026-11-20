# C2 Baseline Reference ([P0-T4])

Timestamp: 2026-11-19T20-40
Plan: remediation-plan.2026-11-19T19-58.md
Command: Glob of `<FEATURE>/evidence/regression-testing/{branch-b-pytest-final,branch-b-pester-final,h3-jest-final}.*.md` (lexicographically greatest of each); Read of the three selected records; no gate run (BASELINE-REF decision, OD-4)
EXIT_CODE: 0
Output Summary: Phase 0 baseline of this cycle taken from the three pre-merge final gate records of this branch.
  pytest (branch-b-pytest-final.2026-11-19T19-20.md): 17101 passed, 0 failed, 6 skipped; repository-wide line 98.00% (35359/36079), branch 95.46% (13091/13714).
  Pester (branch-b-pester-final.2026-11-19T19-32.md): ExitCode 0; 29012 tests, 28994 passed, 0 failed, 0 errors, 18 skipped (857 suites); repository-wide line 96.84% (47091 covered, 1539 missed).
  Jest (h3-jest-final.2026-11-19T16-55.md, the newest Jest gate before this cycle): 369 suites and 6115 tests passed, 0 failed; repository-wide lines 97.42% (68402/70212), branches 94.63% (10595/11196).
  Failing tests by name: none in any of the three records.

## Source records

| Gate | Record | Plan of the record |
| --- | --- | --- |
| pytest | `evidence/regression-testing/branch-b-pytest-final.2026-11-19T19-20.md` | `plan-agents-branch-b.md` |
| Pester | `evidence/regression-testing/branch-b-pester-final.2026-11-19T19-32.md` | `plan-agents-branch-b.md` |
| Jest | `evidence/regression-testing/h3-jest-final.2026-11-19T16-55.md` | `plan-h3-sync-writer-retirement.md` |

All required counts and coverage values are present; no premise mismatch.
