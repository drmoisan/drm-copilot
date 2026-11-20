# Jest Gate, root configuration (feature-review re-audit of remediation cycle 1)

Timestamp: 2026-11-13T14-11
Command: sh SCRATCH/r1164c1_rootjest.sh (in the item worktree root: node run-jest.cjs --coverage with normal workers, under the root jest.config.cjs, which matches tests/unit/**/*.test.ts and extensions/drm-copilot/test/**/*.test.ts); figures read by the reviewer from the coverage/lcov.info this run wrote
EXIT_CODE: 0
Output Summary:
- Run by the feature-review agent on head 90d84af13 (clean worktree), 2026-11-13T14:11:06Z to 14:11:30Z UTC, after the validate-feature-review-coverage Stop hook reported the root report coverage/lcov.info absent. The cycle's earlier Jest gate (jest-gate.2026-11-13T13-52.md, extension-scoped) is unchanged.
- Test Suites: 344 passed, 344 total; Tests: 5519 passed, 5519 total (0 failed); Time 22.515 s.
- coverage/lcov.info written 2026-11-13T14:11:30Z; 284 source files.
- Repo-wide (lcov totals): line 69970 / 71190 = 98.29%; branch 10432 / 11140 = 93.64%. At or above 85% line and 75% branch.
- Per-file (lcov LH/LF, BRH/BRF), changed TypeScript production files:
  - extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts: line 480/493 = 97.36%, branch 103/106 = 97.17%; uncovered lines 133 to 137 and 484 to 491, outside the changed hunk (lines 108 to 127).
  - extensions/drm-copilot/src/lib/validate/parallel-state-records.ts: line 658/658 = 100.00%, branch 141/141 = 100.00%.
  - extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts: line 468/468 = 100.00%, branch 48/49 = 97.96%.
  - extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts: line 324/326 = 99.39%, branch 35/38 = 92.11%.
- Comparison: the four per-file figures equal those of the extension-scoped cycle gate (jest-gate.2026-11-13T13-52.md) and are not below the cycle Phase 0 figures (remediation-baseline/jest-gate.2026-11-11T06-25.md). No root-configuration Phase 0 run exists, so the repo-wide root figure is compared with the thresholds only.
- No failing test.
