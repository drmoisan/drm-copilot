# Extension Jest Gate (Remediation Cycle 1, P3-T4)

Timestamp: 2026-11-17T15-24
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (sh SCRATCH/issue-1035-jest.sh p3; `node run-jest.cjs` in extensions/drm-copilot, normal parallel workers, integration lane excluded). Per-file comparison by SCRATCH/issue-1035-lcovcmp.py against a copy of the D-R5 reference report taken before the run.
EXIT_CODE: 0
Output Summary: Test Suites: 351 passed, 351 total. Tests: 5881 passed, 5881 total; the per-file coverageThreshold map is enforced by the coverage run, which exited 0. extensions/drm-copilot/coverage/lcov.info written 2026-11-17T15-23-53 UTC at HEAD e10f769352dffd18ac3608d74c41fd2c4db6244c. Totals from lcov.info: line 97.25% (65742/67598), branch 94.20% (10149/10774).

D-R5 reference: typescript-tests.2026-11-17T10-25.md, the greatest `typescript-tests.*.md` in evidence/qa-gates/ (extension report written 2026-11-17T10:25:22Z; that file was copied to SCRATCH/ts-ref/ext/ before this run). Reference totals line 97.25%, branch 94.20%. Per-file comparison: 261 files in both reports, none only in one, 0 files with a lower line or branch figure; the totals are identical.

`git diff --stat <Baseline-Head> -- '*.ts' '*.tsx' '*.cjs' '*.mjs'`: empty (exit 0).
