# Baseline: Jest (extension coverage run and root package suite)

Timestamp: 2026-11-18T07-59
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest
EXIT_CODE: 0
Output Summary: Extension package: 352 suites passed, 5898 tests passed, 0 failed; repo-wide extension coverage lines 97.29% (65686/67513), branches 94.3% (10159/10772). Root package suite: 355 suites passed, 5915 tests passed, 0 failed. Both runs used Jest's normal parallel workers under the launcher, which excludes the integration and golden lanes (see `evidence/other/deviation.integration-lane.2026-11-18T07-59.md`).

## Per-file coverage of existing files this plan edits (from `extensions/drm-copilot/coverage/lcov.info`)

| File | Lines | Branches |
| --- | --- | --- |
| `src/lib/push-down/claude-customizations.ts` | 100.00% (497/497) | 96.83% (61/63) |
| `src/lib/push-down/codex-agents-customizations.ts` | 98.48% (389/395) | 92.54% (62/67) |
| `src/lib/push-down/copilot-customizations.ts` | 100.00% (102/102) | 100.00% (12/12) |
| `src/lib/push-down/copilot-customizations-engine.ts` | 98.00% (440/449) | 86.67% (39/45) |
| `src/lib/push-down/push-down-service-call.ts` | 100.00% (214/214) | 96.43% (27/28) |
| `src/repo-automation-service.ts` | 98.38% (487/495) | 93.48% (43/46) |
| `src/repo-automation-service-push-down.ts` | 93.45% (157/168) | 72.73% (16/22) |
| `src/mcp-tool-inputs.ts` | 94.62% (457/483) | 92.96% (66/71) |
| `src/mcp-tool-inputs-push-down.ts` | 100.00% (107/107) | 100.00% (36/36) |
| `src/mcp-push-down-schema-properties.ts` | 100.00% (59/59) | no branches (0/0) |
| `src/mcp-tools.ts` | 95.98% (454/473) | 92.00% (92/100) |
| `src/repo-automation-command-registration-admin.ts` | 96.90% (407/420) | 89.23% (58/65) |
| `src/repo-automation-service-contract.ts` (edited by P3-T2; type-only module) | 0.00% (0/307) | 0.00% (0/1) |

Note: `src/repo-automation-service-push-down.ts` is below the 75% branch threshold before any change (72.73%); the final gate must show no drop and the plan's changes should raise it.
