Timestamp: 2026-11-19T18-57
Command: node SCRATCH/issue-1051-lcov.cjs extensions/drm-copilot/coverage/lcov.info <file suffixes> (final Jest coverage run of 2026-11-19, evidence/qa-gates/jest-coverage.2026-11-19T18-44.md), compared with evidence/baseline/jest-coverage.2026-11-19T15-46.md; artifacts/python/coverage.json totals and the Pester JaCoCo LINE counter compared with their baseline artifacts
EXIT_CODE: 0
Output Summary: every new file meets 85% lines and 75% branches; every EDITED-TS file with executable lines and the repo-wide totals are at or above the Phase 0 baseline. Result: PASS.

## New production files (threshold 85% lines, 75% branches; no pre-change run)

| File | Lines | Branches | Meets thresholds |
|---|---|---|---|
| src/lib/push-down-integration/workflow-yaml-reader.ts | 98.46% (701/712) | 97.67% (294/301) | yes |
| src/lib/push-down-integration/integration-items.ts | 100.00% (223/223) | 100.00% (20/20) | yes |
| src/lib/push-down-integration/integration-ecosystems.ts | 100.00% (202/202) | 95.45% (42/44) | yes |
| src/lib/push-down-integration/integration-detect.ts | 100.00% (541/541) | 99.26% (134/135) | yes |
| src/lib/push-down-integration/integration-validate.ts | 100.00% (240/240) | 96.36% (53/55) | yes |
| src/lib/push-down-integration/integration-validate-artifacts.ts | 100.00% (278/278) | 91.89% (68/74) | yes |
| src/lib/push-down/push-down-integration-needed.ts | 100.00% (284/284) | 95.56% (43/45) | yes |
| src/mcp-push-down-integration-tool-definitions.ts | 100.00% (66/66) | 100.00% (1/1) | yes |
| src/mcp-tool-inputs-push-down-integration.ts | 100.00% (37/37) | 100.00% (4/4) | yes |
| src/mcp-handlers/push-down-integration-handlers.ts | 100.00% (72/72) | 100.00% (14/14) | yes |
| src/repo-automation-service-push-down-integration.ts | 100.00% (113/113) | 100.00% (9/9) | yes |

## EDITED-TS files (baseline from [P0-T4], post-change from the final run)

| File | Baseline lines | Final lines | Baseline branches | Final branches | No drop |
|---|---|---|---|---|---|
| src/mcp-tools.ts | 96.86% | 96.93% | 93.14% | 93.27% | yes |
| src/mcp-tool-definitions.ts | 100.00% | 100.00% | no branches | no branches | yes |
| src/mcp-repo-automation-tool-definitions.ts | 100.00% | 100.00% | no branches | no branches | yes |
| src/repo-automation-tool-names.ts | 100.00% | 100.00% | no branches | no branches | yes |
| src/repo-automation-service.ts | 100.00% | 100.00% | 93.75% | 94.00% | yes |
| src/repo-automation-service-contract.ts | no executable lines | no executable lines | - | - | n/a |
| src/lib/push-down/push-down-harness.ts | 100.00% | 100.00% | 96.92% | 98.46% | yes |
| src/lib/push-down/push-down-ecosystem-registry.ts | 100.00% | 100.00% | 100.00% | 100.00% | yes |

## Repo-wide totals

| Gate | Baseline | Final | No drop |
|---|---|---|---|
| Jest lines | 97.44% (69097/70909) | 97.52% (71912/73744) | yes |
| Jest branches | 94.67% (10720/11324) | 94.83% (11416/12038) | yes |
| pytest lines | 98.00% (35359/36079) | 98.00% (35359/36079) | yes |
| pytest branches | 95.46% (13091/13714) | 95.46% (13091/13714) | yes |
| Pester lines | 96.78% (47366/48943) | 96.78% (47366/48943) | yes |

Note: a first final run (2026-11-19T18-18) showed Jest repo-wide branches at 94.66% and push-down-harness.ts branches at 96.83%; the fix and the QA-loop restart are recorded in evidence/other/qa-loop-fix.2026-11-19T18-38.md. The figures above are from the restarted run.

Result: PASS
