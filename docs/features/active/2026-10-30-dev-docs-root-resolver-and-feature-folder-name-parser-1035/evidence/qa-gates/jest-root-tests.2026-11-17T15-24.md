# Root Jest Gate (Remediation Cycle 1, P3-T4)

Timestamp: 2026-11-17T15-24
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest --coverage (sh SCRATCH/issue-1035-jest.sh p3; root `node run-jest.cjs`, normal parallel workers, integration lane excluded). Per-file comparison by SCRATCH/issue-1035-lcovcmp.py against a copy of the D-R5 reference report taken before the run.
EXIT_CODE: 0
Output Summary: Test Suites: 354 passed, 354 total. Tests: 5898 passed, 5898 total. coverage/lcov.info written 2026-11-17T15-23-40 UTC at HEAD e10f769352dffd18ac3608d74c41fd2c4db6244c. Totals from lcov.info: line 98.21% (71738/73045), branch 93.98% (10784/11475).

D-R5 reference: reviewer-coverage-rerun.2026-11-17T12-05.md (root report written 2026-11-17T11:49:30Z; that file was copied to SCRATCH/ts-ref/root/ before this run). Reference totals line 98.21% (71738/73045), branch 93.98% (10784/11475). Per-file comparison: 290 files in both reports, none only in one, 0 files with a lower line or branch figure; the totals are identical.

`git diff --stat <Baseline-Head> -- '*.ts' '*.tsx' '*.cjs' '*.mjs'`: empty (exit 0); no TypeScript or JavaScript file changed in this cycle.
