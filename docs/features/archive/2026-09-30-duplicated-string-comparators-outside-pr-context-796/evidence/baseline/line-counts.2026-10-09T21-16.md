# Baseline: Line counts of 33 pre-existing core Blast-radius files (P0-T16)

Timestamp: 2026-10-09T21-16
Command: git grep --untracked -c -E "^" -- <the 33 pre-existing core Blast-radius paths> (run from REPO)
EXIT_CODE: 0
Output Summary:
33 path:count lines (verbatim):
extensions/drm-copilot/jest.config.cjs:470
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:309
extensions/drm-copilot/src/lib/codex-native-converter/intermediate-state.ts:153
extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts:319
extensions/drm-copilot/src/lib/codex-native-converter/models.ts:280
extensions/drm-copilot/src/lib/codex-native-converter/pipeline-traces.ts:122
extensions/drm-copilot/src/lib/codex-native-converter/pipeline.ts:155
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:209
extensions/drm-copilot/src/lib/codex-native-converter/reporting.ts:239
extensions/drm-copilot/src/lib/codex-native-converter/validation.ts:372
extensions/drm-copilot/src/lib/pr-context/autoclose.ts:294
extensions/drm-copilot/src/lib/pr-context/collector-core.ts:382
extensions/drm-copilot/src/lib/pr-context/collector-output.ts:494
extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:312
extensions/drm-copilot/src/lib/pr-context/feature-docs.ts:312
extensions/drm-copilot/src/lib/pr-context/models.ts:391
extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts:430
extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts:387
extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:260
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:394
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts:200
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts:306
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts:447
extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts:448
extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts:204
extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts:133
extensions/drm-copilot/src/lib/subagent-tree/tree-assembler.ts:189
extensions/drm-copilot/test/lib/codex-native-converter/inventory.test.ts:168
extensions/drm-copilot/test/lib/pr-context/models.test.ts:486
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts:183
extensions/drm-copilot/test/lib/push-down/copilot-customizations-engine.test.ts:244
extensions/drm-copilot/test/lib/subagent-tree/quick-pick-labels.test.ts:206
extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts:167

Comparison with planning-time counts: collector-output.ts 494 (plan 494), pr-context models.ts 391 (plan 391), models.test.ts 486 (plan 486), jest.config.cjs 470 (plan 470). No difference; headroom unchanged.
