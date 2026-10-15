# AC-22 Evidence Location (P8-T10)

Timestamp: 2026-10-07T22-40
Task: [P8-T10]
Command: git status --porcelain --ignored -- artifacts/baselines artifacts/baseline artifacts/qa artifacts/qa-gates artifacts/coverage artifacts/evidence; Glob `artifacts/{baselines,baseline,qa,qa-gates,coverage,evidence}/**`; Glob `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/*/*`
EXIT_CODE: 0
Output Summary: the `--ignored` porcelain output is empty; the `artifacts/` Glob returned no files (none of the six directories exists; `artifacts/` holds only `orchestration/`, `pester/`, `python/`). The feature-evidence Glob lists the Phase 0 artifacts under `evidence/baseline/` (17 files) and the Phase 7 artifacts under `evidence/qa-gates/` (16 P7 files plus the P6-T2 and P8 artifacts), with regression and other evidence under `evidence/regression-testing/` and `evidence/other/`.

## Negative evidence

SearchScope: `artifacts/baselines`, `artifacts/baseline`, `artifacts/qa`, `artifacts/qa-gates`, `artifacts/coverage`, `artifacts/evidence`
SearchPatterns: `**` (Glob); `git status --porcelain --ignored`
SearchResult: none

## Feature evidence (Glob at 22-40)

- `evidence/baseline/`: phase0-instructions-read, line-counts, hook-parity, py-black, py-ruff, py-pyright, py-pytest-coverage, py-coverage-totals, py-r19-focused-coverage, ts-prettier, ts-eslint, ts-typecheck, ts-tsc-jest-diagnostics, ts-jest-coverage, ps-analyze, ps-pester, ps-coverage
- `evidence/qa-gates/`: ac5-threshold-static-check, py-black, py-ruff, py-pyright, py-pytest-coverage, py-coverage-totals, py-parity-and-precedence, ts-prettier, ts-eslint, ts-typecheck, ts-tsc-jest-diagnostics, ts-jest-coverage, ts-precedence-tests, ps-format, ps-analyze, ps-pester, ps-coverage, toolchain-loop-single-pass, ac7-bare-catch, ac4-hook-parity, ac12-precedence-unchanged (plus the P8 artifacts written after this Glob)
- `evidence/regression-testing/`: r16-pester, r16-test-purity, r19-focused-coverage, r18-helper-and-mapping, r18-materializer, r18-authority-production-boundary
- `evidence/other/`: preflight-status, d5-tier-and-dependency-check, d2-materializer-line-count, authority-test-placement

Result: PASS
