# Phase 0 Upstream Gate (P0-T1)

Timestamp: 2026-11-19T08-27
Command: gh pr view 1208 --json state,mergedAt,baseRefName; git merge-base --is-ancestor origin/epic/shared-agent-harness-layer-integration HEAD; git show origin/epic/shared-agent-harness-layer-integration:docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/spec.md | grep -c '^## Destination Manifest Schema'; sh SCRATCH/issue-1050-p0t1.sh (grep -cE per symbol)
EXIT_CODE: 0
Output Summary: #1029 PR #1208 merged into the integration branch; integration branch is an ancestor of HEAD; #1049 spec heading present on the integration branch; every symbol present; brief copy set has six entries; #1028 generator present. Result: PASS.

## Upstream Rows

| Item | Observation | Status |
| --- | --- | --- |
| #1029 PR #1208 merged | state MERGED, baseRefName epic/shared-agent-harness-layer-integration, mergedAt 2026-11-19T08:08:11Z | present |
| Ancestry: origin/epic/shared-agent-harness-layer-integration ancestor of HEAD | `git merge-base --is-ancestor` exit 0 | present |
| #1049 spec on integration branch with `## Destination Manifest Schema` | heading count 1 | present |
| #1049 merge | not required (plan D6) | n/a |

## Symbol Rows

| Symbol | File | Status |
| --- | --- | --- |
| `PushDownLayer` | `PD/push-down-layer.ts` | present |
| `LAYER_ROOT_FILES` | `PD/push-down-layer.ts` | present |
| `buildSharedLayer` | `PD/push-down-shared-layer.ts` | present |
| `pushDownHarness` (with recorded-selection reuse) | `PD/push-down-harness.ts` | present |
| `resolvePayloadVersion` | `PD/push-down-harness.ts` | present |
| `runPushDownPipeline` with `overwriteUnmanaged` | `PD/push-down-pipeline.ts` | present |
| `applyPushDownPlan` | `PD/push-down-apply.ts` | present |
| `parseDestinationManifest` (layer `shared` accepted) | `PD/push-down-destination-manifest.ts` | present |
| `hashPayloadText` | `PD/push-down-destination-manifest.ts` | present |
| `DESTINATION_MANIFEST_RELATIVE_PATH` | `PD/push-down-destination-manifest.ts` | present |
| `DESTINATION_MANIFEST_SCHEMA_VERSION` = `1.0.0` | `PD/push-down-destination-manifest.ts` | present |
| `classifyPayloadFile` | `PD/push-down-plan-comparator.ts` | present |
| `PUSH_DOWN_CONFLICT_LINE_PREFIX` | `PD/push-down-report.ts` | present |
| `assertSingleCsharpToolchain` | `PD/claude-pack-selection.ts` | present |
| `resolvePushDownCopilotCustomizationsToolInput` | `extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts` | present |
| `buildInMemoryFileSystem` | `PDT/push-down.test-helpers.ts` | present |
| `seedSharedLayerManifest` | `PDT/push-down-pipeline.test-helpers.ts` | present |

## Brief Copy Set (`_BRIEF_COPIES` of `test_execution_environment_brief_contracts.py`)

1. `.claude/skills/execution-environment/SKILL.md`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
3. `.agents/skills/execution-environment/SKILL.md`
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
5. `.github/skills/execution-environment/SKILL.md`
6. `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

generator: present (`scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills`, #1028)

Result: PASS
