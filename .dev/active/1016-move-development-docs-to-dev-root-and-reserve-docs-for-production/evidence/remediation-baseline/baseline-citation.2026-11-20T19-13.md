# Remediation Baseline Citation — remediation cycle 1 [P0-T2]

Timestamp: 2026-11-20T19-13
Command: file reads only (Read and grep) of evidence/qa-gates/ts-static.2026-11-20T18-10.md, py-static.2026-11-20T18-10.md, ps-static.2026-11-20T18-10.md, ts-test-coverage.2026-11-20T18-10.md, py-test-coverage.2026-11-20T18-10.md, ps-test-coverage.2026-11-20T18-10.md, coverage-delta.2026-11-20T18-10.md and review-coverage-check.2026-11-20T18-28.md; nothing was re-run
EXIT_CODE: 0
Output Summary: The stage B final QA loop at the reviewed head f744ce9e0 is this cycle's `Phase 0 baseline`. Figures copied from the cited artifacts:
- Pester (ps-test-coverage.2026-11-20T18-10.md): tests 29157, failures 0, errors 0, disabled 22; repo-wide line coverage 96.84% (47286/48827).
- pytest (py-test-coverage.2026-11-20T18-10.md): 17104 passed, 6 skipped, 0 failed, 0 errors; lines 96.66% (17720/18332), branches 92.53% (6194/6694).
- Jest extension (ts-test-coverage.2026-11-20T18-10.md): 412 suites, 6685 tests passed, 0 failed; lines 97.58% (74504/76344), branches 94.95% (11903/12536).
- Root Jest (review-coverage-check.2026-11-20T18-28.md): 419 suites, 6717 tests passed; lines 98.52% (81621/82839), branches 94.61% (12729/13454).
- Per-file (coverage-delta.2026-11-20T18-10.md): `layout-map.ts` lines 156/156 (100.00%), branches 21/21 (100.00%); `migration-plan.ts` lines 587/587 (100.00%), branches 145/148 (97.97%).
- Static baselines: ts-static, py-static and ps-static 2026-11-20T18-10 as recorded (clean).
Note: those runs had the leftover untracked `docs/features` directory on disk (the F3 defect); the final gate judges the F3 test against the clean layout of [P0-T3].
