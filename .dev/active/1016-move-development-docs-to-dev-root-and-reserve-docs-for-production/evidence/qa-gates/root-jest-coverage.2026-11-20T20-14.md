# Root Jest Gate [P2-T7] — remediation cycle 1

Timestamp: 2026-11-20T20-14
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest --coverage --coverageReporters=lcov --coverageReporters=text-summary (repository root, normal workers; final QA loop pass 2 through sh SCRATCH/issue-1016-c1-gate.sh, head 520617870)
EXIT_CODE: 0
Output Summary: Test Suites: 415 passed, 415 total; Tests: 6724 passed, 6724 total; 0 failed. Root totals from the text summary and coverage/lcov.info: lines 98.44% (81575/82866), branches 94.63% (12706/13426). The canonical `coverage/lcov.info` exists, modified 2026-11-20 15:03:59 -0500, later than the last code commit 520617870 (2026-11-20 14:59:01 -0500).
Comparison with review-coverage-check.2026-11-20T18-28.md (lines 98.52%, branches 94.61%, from a direct run including the integration lane): branches are not below it; lines are 0.08 points below it because the launcher excludes the four integration-lane suites. Recorded as a non-blocking deviation in evidence/other/root-jest-baseline-deviation.2026-11-20T20-14.md (accept_nonblocking_deviation under OD-1). Against the like-for-like launcher run of [P1-T8] (lines 98.44%, branches 94.62%) neither total drops.
