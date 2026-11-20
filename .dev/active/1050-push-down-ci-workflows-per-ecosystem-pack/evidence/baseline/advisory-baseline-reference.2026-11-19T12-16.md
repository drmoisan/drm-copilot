# Advisory-Fix Baseline Reference (P0-T1)

Timestamp: 2026-11-19T12-16
Command: none (reference only)
EXIT_CODE: 0
Output Summary: No new run. The advisory-fix plan compares against these existing artifacts:
- Static baselines: `evidence/qa-gates/final-pwsh-static.2026-11-19T11-02.md`, `evidence/qa-gates/final-yaml-static.2026-11-19T11-02.md`, `evidence/qa-gates/final-ts-static.2026-11-19T11-02.md`.
- Pester Phase 0 baseline: `evidence/baseline/baseline-pester.2026-11-19T08-55.md` — 29212 tests, 0 failures, 18 skipped; repo-wide line coverage 96.77% (47184/48759).
- Jest Phase 0 baseline: `evidence/baseline/baseline-jest.2026-11-19T08-55.md` — 369 suites, 6119 tests passed, 0 failed; lines 97.42%, branches 94.63% (suite `jest-extension`).
- Prior final Pester figure: `evidence/qa-gates/final-pester.2026-11-19T11-46.md` — 29237 tests, 0 failures; `scripts/ci/Set-CiRequiredChecks.ps1` line coverage 98.08% (51/52); repo-wide 96.77% (47235/48811).
