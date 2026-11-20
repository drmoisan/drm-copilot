# Sort-Site Inventory Baseline (P0-T4)

Timestamp: 2026-10-12T15-03
Command: git grep -n -E "\.(sort|toSorted)\([[:space:]]*\)" -- extensions/drm-copilot/src/lib (run from the repository root)
EXIT_CODE: 0
Output Summary:
Match count: 19 (equals the 19 pairs in the plan "Site inventory"). PASS.
All paths relative to extensions/drm-copilot/src/lib/:
- push-down/claude-pack-selection.ts:117
- push-down/claude-pack-selection.ts:299
- push-down/codex-pack-selection.ts:66
- push-down/codex-pack-selection.ts:71
- push-down/codex-pack-selection.ts:100
- push-down/codex-pack-selection.ts:108
- push-down/codex-pack-selection.ts:232
- resolve/file-prompt-transforms.ts:184
- resolve/file-prompt-transforms.ts:191
- subagent-tree/tree-assembler.ts:181
- subagent-tree/tree-formatter.ts:29
- validate/codex-topology-resolver.ts:123
- validate/epic-orchestrator-state-core.ts:203
- validate/epic-planner-git-integrity.ts:284
- validate/orchestrator-state-codex-model-routing.ts:457
- validate/orchestrator-state-codex-topology.ts:299
- validate/orchestrator-state-core.ts:253
- validate/orchestrator-state-core.ts:285
- validate/orchestrator-state-model-routing-existence.ts:66
