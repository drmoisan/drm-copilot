# Final gate — Jest coverage, extension ([P7-T2])

Timestamp: 2026-11-18T01-46
Command: sh SCRATCH/issue-1028-retry.sh jest-extension --coverage (the `jest-extension` launcher suite, `node run-jest.cjs` in `extensions/drm-copilot/` with its normal parallel workers); figures read from `extensions/drm-copilot/coverage/lcov.info` (SCRATCH/issue-1028-lcov.ps1)
EXIT_CODE: 0
Output Summary: 351 of 351 suites and 5895 of 5895 tests passed, with 0 failures; the `coverageThreshold` entries hold, including the appended per-file entries. The lcov totals over 261 files are 97.29% line (65685 of 67512) and 94.31% branch (10158 of 10771). The Phase 0 figures were 97.25% line and 94.20% branch.

| File | Line | Branch |
| --- | --- | --- |
| `src/lib/codex-native-converter/mapping.ts` | 99.24% (260/262) | 95.12% (39/41) |
| `src/lib/codex-native-converter/engine-pipeline.ts` | 99.29% (281/283) | 90.24% (37/41) |
| `src/lib/codex-native-converter/pipeline.ts` | 100.00% (151/151) | 100.00% (28/28) |
| `src/lib/codex-native-converter/pipeline-render.ts` | 100.00% (302/302) | 96.00% (48/50) |
| `src/lib/codex-native-converter/validation.ts` | 100.00% (362/362) | 94.23% (49/52) |
