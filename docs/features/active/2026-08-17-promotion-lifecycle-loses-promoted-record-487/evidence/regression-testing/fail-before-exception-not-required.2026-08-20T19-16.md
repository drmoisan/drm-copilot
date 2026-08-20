# Fail-Before Exception Dossier — Not Required [P1-T12]

Timestamp: 2026-08-20T19-16

## Disposition

**No exception dossier is required.** P1-T12 conditions the dossier on a failing run being structurally impossible for one or more of P1-T1 through P1-T9. That condition does not hold: a real failing run was captured for every task that requires one, in both languages.

| Task | Fail-before status | Evidence artifact |
| --- | --- | --- |
| P1-T1 | Failing run captured | `evidence/regression-testing/fail-before-ts-jest.2026-08-20T19-16.md` |
| P1-T2 | Failing run captured | `evidence/regression-testing/fail-before-ts-jest.2026-08-20T19-16.md` |
| P1-T3 | Failing run captured | `evidence/regression-testing/fail-before-ts-jest.2026-08-20T19-16.md` |
| P1-T4 | Not a fail-before task — pre-existing-behavior guard, passed before the fix | `evidence/regression-testing/fail-before-ts-jest.2026-08-20T19-16.md` |
| P1-T5 | Failing run captured | `evidence/regression-testing/fail-before-ts-jest.2026-08-20T19-16.md` |
| P1-T6 | Failing run captured (two failure-arm cases) | `evidence/regression-testing/fail-before-ts-jest.2026-08-20T19-16.md` |
| P1-T7 | Failing run captured (one failure-arm case) | `evidence/regression-testing/fail-before-ts-jest.2026-08-20T19-16.md` |
| P1-T8 | Failing run captured | `evidence/regression-testing/fail-before-py-pytest.2026-08-20T19-16.md` |
| P1-T9 | Failing run captured | `evidence/regression-testing/fail-before-py-pytest.2026-08-20T19-16.md` |

TypeScript fail-before run: `EXIT_CODE: 1`, 7 failed / 217 passed / 224 total.
Python fail-before run: `EXIT_CODE: 1`, 2 failed / 23 passed.

## Auditable Absence Record

SearchScope: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/` searched recursively, which includes the canonical fail-before scopes `evidence/regression-testing/` and `evidence/baseline/`. The feature is not versioned (no `v1/`, `v2/` subfolders), so the feature root is the only scope.

SearchPatterns: `fail-before-exception.*.md`

SearchResult: none. The recursive search returned no matching file and exited 0. The `evidence/regression-testing/` directory contains only `fail-before-py-pytest.2026-08-20T19-16.md` and `fail-before-ts-jest.2026-08-20T19-16.md`.

The absence of a dossier is correct and intended here: the fail-before requirement is satisfied by actual failing runs, which is the preferred form of the evidence, so the dossier alternative was never reached.
