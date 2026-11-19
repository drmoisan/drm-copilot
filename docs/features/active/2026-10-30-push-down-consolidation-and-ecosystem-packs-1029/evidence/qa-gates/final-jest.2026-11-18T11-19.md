# Final QC: Jest (P5-T2)

Timestamp: 2026-11-18T11-19
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=lcov --coverageReporters=text-summary; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest
EXIT_CODE: 0
Output Summary: Extension package (coverage run): 369 suites, 6119 tests passed, 0 failed, no `coverageThreshold` failure (every per-file entry, including the 14 entries of `jest.push-down-coverage.json`, met); repo-wide lines 97.42% (68431/70241), branches 94.63% (10597/11198). Root package suite: 372 suites, 6136 tests passed, 0 failed. Both ran through Jest's normal parallel workers under the launcher. The first extension launch hit a queue timeout (exit 75) and was re-run. Baseline (P0-T5): extension 5898 passed, lines 97.29%, branches 94.3%; root 5915 passed.

## Per-file coverage of every new and edited `EXT/src` file (from `EXT/coverage/lcov.info`)

| File | Status | Lines | Branches |
| --- | --- | --- | --- |
| `lib/push-down/push-down-destination-manifest.ts` | new | 100.00% (428/428) | 100.00% (89/89) |
| `lib/push-down/push-down-plan-comparator.ts` | new | 100.00% (137/137) | 100.00% (24/24) |
| `lib/push-down/push-down-report.ts` | new | 100.00% (110/110) | 100.00% (14/14) |
| `lib/push-down/push-down-write-if-changed.ts` | new | 100.00% (123/123) | 100.00% (18/18) |
| `lib/push-down/push-down-layer.ts` | new | 100.00% (126/126) | 100.00% (1/1) |
| `lib/push-down/push-down-pack-resolver.ts` | new | 100.00% (341/341) | 96.88% (62/64) |
| `lib/push-down/push-down-pipeline.ts` | new | 99.21% (504/508) | 97.65% (83/85) |
| `lib/push-down/push-down-apply.ts` | new | 100.00% (211/211) | 98.15% (53/54) |
| `lib/push-down/push-down-shared-layer.ts` | new | 100.00% (138/138) | 100.00% (6/6) |
| `lib/push-down/claude-layer.ts` | new | 100.00% (142/142) | 100.00% (4/4) |
| `lib/push-down/push-down-ecosystem-registry.ts` | new | 100.00% (152/152) | 100.00% (16/16) |
| `lib/push-down/push-down-harness.ts` | new | 100.00% (225/225) | 96.00% (48/50) |
| `push-down-command-support.ts` | new | 100.00% (66/66) | 100.00% (7/7) |
| `lib/push-down/claude-customizations.ts` | edited | 100.00% (363/363) | 100.00% (43/43) |
| `lib/push-down/codex-agents-customizations.ts` | edited | 98.56% (411/417) | 95.83% (69/72) |
| `lib/push-down/copilot-customizations.ts` | edited | 100.00% (166/166) | 100.00% (19/19) |
| `lib/push-down/copilot-customizations-engine.ts` | edited | 100.00% (315/315) | 100.00% (34/34) |
| `lib/push-down/push-down-service-call.ts` | edited | 100.00% (202/202) | 100.00% (20/20) |
| `repo-automation-service.ts` | edited | 100.00% (494/494) | 93.75% (45/48) |
| `repo-automation-service-push-down.ts` | edited | 100.00% (227/227) | 100.00% (20/20) |
| `mcp-tool-inputs.ts` | edited | 94.92% (448/472) | 94.67% (71/75) |
| `mcp-tool-inputs-push-down.ts` | edited | 100.00% (180/180) | 100.00% (51/51) |
| `mcp-push-down-schema-properties.ts` | edited | 100.00% (91/91) | no branches |
| `mcp-tools.ts` | edited | 96.86% (463/478) | 93.14% (95/102) |
| `repo-automation-command-registration-admin.ts` | edited | 98.26% (452/460) | 90.28% (65/72) |
| `repo-automation-service-contract.ts` | edited (type-only module) | 0.00% (0/325) | 0.00% (0/1) |

The X8 integration test (`codex-bundle-publish.integration.test.ts`) is in the integration lane, excluded from local runs; it runs in CI (`evidence/other/deviation.integration-lane.2026-11-18T07-59.md`).
