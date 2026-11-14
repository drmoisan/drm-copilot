# Jest gate (P5-T8)

Timestamp: 2026-11-14T06-59
Command: node run-jest.cjs --coverage (in extensions/drm-copilot, through sh SCRATCH/issue-1162-jest-gate.sh; Jest normal parallel workers); per-file figures read from extensions/drm-copilot/coverage/lcov.info (copy kept as SCRATCH/issue-1162-jest-lcov-final.info) by SCRATCH/issue-1162-lcov-figures.ps1
EXIT_CODE: 0
Output Summary:
- Counts: 343 suites passed of 343; 5624 tests passed, 0 failed (19.7 s). Phase 0 baseline: 340 suites, 5476 tests, 0 failed. The per-file coverageThreshold entries of extensions/drm-copilot/jest.config.cjs were enforced and none failed.
- Repository total (v8 provider): lines 97.18% (64509/66375), branches 94.00% (9936/10570). Phase 0 baseline: lines 97.15%, branches 93.87%.
- epic-orchestrator-state-resolution.ts: line 98.85% (514/520), branch 96.99% (129/133). Baseline 97.91% / 93.85%.
- epic-orchestrator-state-core.ts: line 100.00% (401/401), branch 96.15% (75/78). Baseline 100.00% / 96.10%.
- epic-orchestrator-state-wave-barrier.ts: line 100.00% (327/327), branch 98.55% (68/69). Baseline 100.00% / 98.08%.
- epic-planner-state-core.ts: line 100.00% (501/501), branch 96.97% (128/132). Baseline 100.00% / 96.85%.
- Zero failures; each of the four files is at or above 85% line and 75% branch coverage.
