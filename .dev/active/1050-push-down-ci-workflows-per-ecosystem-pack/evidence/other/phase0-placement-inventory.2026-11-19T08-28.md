# Phase 0 Placement and Rule-K Inventory (P0-T2)

Timestamp: 2026-11-19T08-28
Command: sh SCRATCH/issue-1050-p0t2.sh (wc -l over the edited files; grep over docs/engineering/process-reductions/); grep -rn -e "codex-native-converter/validation" -e "Refresh rule" -e "Skipped-check semantics" -e "rulesets/15241672" docs/engineering/process-reductions/; grep over extensions/drm-copilot/test for Object.keys/toEqual over push-down schema properties and resolver results
EXIT_CODE: 0
Output Summary: All counts leave headroom below 800; both placements clear; one rule-K case. Result: PASS.

## Physical Line Counts (wc -l)

| File | Lines | Expected addition | Headroom |
| --- | --- | --- | --- |
| `extensions/drm-copilot/jest.config.cjs` | 627 | 8 (two entries) | clear |
| `PD/push-down-layer.ts` | 126 | small | clear |
| `PD/push-down-pipeline.ts` | 508 | small | clear |
| `PD/push-down-harness.ts` | 225 | moderate | clear |
| `PD/push-down-service-call.ts` | 202 | small | clear |
| `extensions/drm-copilot/src/mcp-push-down-schema-properties.ts` | 91 | small | clear |
| `extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts` | 180 | small | clear |
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` | 325 | small | clear |
| `extensions/drm-copilot/src/repo-automation-service-push-down.ts` | 227 | small | clear |

## Ledger Placement

| Location | Search | Result |
| --- | --- | --- |
| Final entry of the `coverageThreshold` map (`./src/lib/codex-native-converter/validation.ts`, end of file) | no `Current` fence or patch hunk under `docs/engineering/process-reductions/` contains the entry; the only `jest.config.cjs` hunk (`patches/0010-early-dependent-starts.patch`) is anchored near the start of the map | clear |
| `Refresh rule` bullet of `## CI Shape and Required Checks` (six brief copies) | `Refresh rule`, `Skipped-check semantics`, `rulesets/15241672` have zero matches under `docs/engineering/process-reductions/` | clear |

## Rule-K Cases

| File | Test name | Kind |
| --- | --- | --- |
| `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` | `keeps Copilot push-down schemas to the documented optional fields` | exact `Object.keys(properties).sort()` key set of the Copilot push-down schema on both surfaces |

No resolver-result case passes `ci_workflows` input (searched every `resolvePushDown*ToolInput(` call in `extensions/drm-copilot/test/`), so no resolver case needs a rule-K update.

Result: PASS
