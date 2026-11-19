# Final QC: Jest (P3-T2)

Timestamp: 2026-11-19T10-38
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (node run-jest.cjs in extensions/drm-copilot through the launcher; integration lane excluded); per-file figures read from extensions/drm-copilot/coverage/lcov.info (copy kept as SCRATCH/final-lcov.info)
EXIT_CODE: 0
Output Summary: Test Suites 374 passed of 374; Tests 6184 passed, 0 failed (baseline 369 suites, 6119 tests). Repo-wide: lines 97.44% (69097/70909), branches 94.66% (10720/11324), statements 97.44%, functions 92.86%. Every per-file `coverageThreshold` entry, including the two new ones, is satisfied (a threshold miss would make the run exit non-zero).

| File | Lines | Branches |
| --- | --- | --- |
| `src/lib/push-down/push-down-ci-workflows.ts` (new) | 100.00% (338/338) | 97.10% (67/69) |
| `src/lib/push-down/push-down-ci-layer.ts` (new) | 100.00% (218/218) | 96.67% (29/30) |
| `src/lib/push-down/push-down-layer.ts` | 100.00% (131/131) | 100.00% (1/1) |
| `src/lib/push-down/push-down-pipeline.ts` | 99.22% (508/512) | 97.75% (87/89) |
| `src/lib/push-down/push-down-harness.ts` | 100.00% (292/292) | 96.92% (63/65) |
| `src/lib/push-down/push-down-service-call.ts` | 100.00% (208/208) | 100.00% (22/22) |
| `src/mcp-push-down-schema-properties.ts` | 100.00% (100/100) | no branches |
| `src/mcp-tool-inputs-push-down.ts` | 100.00% (193/193) | 100.00% (55/55) |
| `src/repo-automation-service-contract.ts` | 0.00% (0/327), type declarations only | 0.00% (0/1) |
| `src/repo-automation-service-push-down.ts` | 100.00% (233/233) | 100.00% (22/22) |
