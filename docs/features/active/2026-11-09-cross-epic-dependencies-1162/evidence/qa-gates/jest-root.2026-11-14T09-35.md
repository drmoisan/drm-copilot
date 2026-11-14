# Jest Final Gate, Worktree-Root Configuration — Remediation Cycle 1, P2-T6 (Issue 1162)

Timestamp: 2026-11-14T09-35
Command: node run-jest.cjs --coverage (at the worktree root, Jest normal parallel workers, through sh SCRATCH/issue-1162-jest.sh root final); totals summed from the worktree-root coverage/lcov.info by SCRATCH/issue-1162-lcov.ps1
EXIT_CODE: 0
Output Summary:
- Counts: 346/346 suites passed; 5646/5646 tests passed, 0 failed. Started 2026-11-14T09-35-10Z, ended 2026-11-14T09-35-23Z. Phase 0 baseline: 346 suites, 5641 tests, 0 failed. The 5 additional tests came in with the #1156 merge.
- Repository total (root report): lines 98.30% (70512/71732), branches 93.73% (10580/11288). Phase 0 baseline: the same values.
- The worktree-root `coverage/lcov.info` was written by this run at 2026-11-14T09-35Z.
