# Coverage Delta (P5-T5)

Timestamp: 2026-11-18T11-35
Command: node SCRATCH/issue-1029-lcov.cjs on the P0-T5 and P5-T2 `EXT/coverage/lcov.info` copies; node SCRATCH/issue-1029-pycov-diff.cjs artifacts/python/issue-1029-base-coverage.json artifacts/python/issue-1029-final-coverage.json
EXIT_CODE: 0
Output Summary: Every new `extensions/drm-copilot/src` file is at or above 85% lines and 75% branches (lowest: 99.21% lines, 96.00% branches). No edited file drops against the `Phase 0 baseline`; four rise. Jest repo-wide coverage rises. pytest repo-wide lines are unchanged; branches differ by one branch in an untouched file whose coverage depends on thread timing (below). Pester: no merged coverage at baseline or final (both runs carry the same pre-existing failure); no PowerShell file is in scope. No new failing test against any baseline.

## Repo-wide

| Gate | Baseline (P0) | Final (P5) | Delta |
| --- | --- | --- | --- |
| Jest extension lines | 97.29% (65686/67513) | 97.42% (68431/70241) | +0.13 |
| Jest extension branches | 94.30% (10159/10772) | 94.63% (10597/11198) | +0.33 |
| Jest extension tests | 5898 passed, 0 failed | 6119 passed, 0 failed | +221 tests |
| Jest root tests | 5915 passed, 0 failed | 6136 passed, 0 failed | +221 tests |
| pytest lines | 98.00% (35359/36079) | 98.00% (35359/36079) | 0 |
| pytest branches | 95.46% (13092/13714) | 95.46% (13091/13714) | -1 branch, see below |
| pytest tests | 17122 passed, 0 failed | 17122 passed, 0 failed | 0 |
| Pester tests | 29032, 1 pre-existing failure | 29032, same single failure | no new failure |

The one-branch pytest difference is `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` branch 395->362: the loop-back edge of a polling loop that reads a reader-thread queue with a 0.1 s timeout. Whether that edge executes depends on thread scheduling, so the count differs between runs. This item changes no Python production file and does not touch that module or its tests. Across this item's runs on the same Python code the total was 13092 (baseline P0, gate P4) and 13091 (gates P1, P2, P3 and final), which shows the variation is run-to-run, not a change. It is not a regression of this item.

## Edited existing files (baseline P0-T5 vs final P5-T2)

| File | Baseline lines | Final lines | Baseline branches | Final branches | Changed-code coverage |
| --- | --- | --- | --- | --- | --- |
| `lib/push-down/claude-customizations.ts` | 100.00% | 100.00% | 96.83% | 100.00% | 100% of changed lines |
| `lib/push-down/codex-agents-customizations.ts` | 98.48% | 98.56% | 92.54% | 95.83% | new `buildCodexLayer` and adapter fully covered |
| `lib/push-down/copilot-customizations.ts` | 100.00% | 100.00% | 100.00% | 100.00% | 100% |
| `lib/push-down/copilot-customizations-engine.ts` | 98.00% | 100.00% | 86.67% | 100.00% | 100% |
| `lib/push-down/push-down-service-call.ts` | 100.00% | 100.00% | 96.43% | 100.00% | 100% |
| `repo-automation-service.ts` | 98.38% | 100.00% | 93.48% | 93.75% | 100% |
| `repo-automation-service-push-down.ts` | 93.45% | 100.00% | 72.73% | 100.00% | 100% |
| `mcp-tool-inputs.ts` | 94.62% | 94.92% | 92.96% | 94.67% | changed lines (re-export only) covered |
| `mcp-tool-inputs-push-down.ts` | 100.00% | 100.00% | 100.00% | 100.00% | 100% |
| `mcp-push-down-schema-properties.ts` | 100.00% | 100.00% | n/a | n/a | 100% |
| `mcp-tools.ts` | 95.98% | 96.86% | 92.00% | 93.14% | 100% (new mapping lines) |
| `repo-automation-command-registration-admin.ts` | 96.90% | 98.26% | 89.23% | 90.28% | new QuickPick and warning lines covered |
| `repo-automation-service-contract.ts` | 0.00% (type-only) | 0.00% (type-only) | 0.00% | 0.00% | type declarations only; no executable code |

## New files (judged against the thresholds; no pre-change run)

| File | Lines | Branches | Meets 85/75 |
| --- | --- | --- | --- |
| `lib/push-down/push-down-destination-manifest.ts` | 100.00% | 100.00% | yes |
| `lib/push-down/push-down-plan-comparator.ts` | 100.00% | 100.00% | yes |
| `lib/push-down/push-down-report.ts` | 100.00% | 100.00% | yes |
| `lib/push-down/push-down-write-if-changed.ts` | 100.00% | 100.00% | yes |
| `lib/push-down/push-down-layer.ts` | 100.00% | 100.00% | yes |
| `lib/push-down/push-down-pack-resolver.ts` | 100.00% | 96.88% | yes |
| `lib/push-down/push-down-pipeline.ts` | 99.21% | 97.65% | yes |
| `lib/push-down/push-down-apply.ts` | 100.00% | 98.15% | yes |
| `lib/push-down/push-down-shared-layer.ts` | 100.00% | 100.00% | yes |
| `lib/push-down/claude-layer.ts` | 100.00% | 100.00% | yes |
| `lib/push-down/push-down-ecosystem-registry.ts` | 100.00% | 100.00% | yes |
| `lib/push-down/push-down-harness.ts` | 100.00% | 96.00% | yes |
| `push-down-command-support.ts` | 100.00% | 100.00% | yes |

New-code coverage across the 13 new modules: 2703 of 2707 lines (99.85%) and 425 of 432 branches (98.38%), above the 90% new-code rule.
