# Coverage Delta and Changed-Line Coverage (P2-T6; AC-8)

Timestamp: 2026-10-12T15-19
Command: git grep -n -F -e ".sort(compareCodePoint)" -- extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts extensions/drm-copilot/src/lib/subagent-tree/tree-assembler.ts extensions/drm-copilot/src/lib/subagent-tree/tree-formatter.ts extensions/drm-copilot/src/lib/resolve/file-prompt-transforms.ts extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-topology.ts extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts extensions/drm-copilot/src/lib/validate/orchestrator-state-model-routing-existence.ts (run from the repository root)
EXIT_CODE: 0
Output Summary:
- git grep exit 0; line count 19 (expected 19).
- None of the 19 post-change converted sort lines appears in the P2-T5 `Uncovered Line #s` column; changed-line coverage is 100%.
- Every TARGET-PROD file is at or above 85% lines and 75% branches; no file's line coverage decreased, and no file's branch coverage decreased.
- No `jest.config.cjs` entry was added, and no production path was added to any coverage exclude list (`extensions/drm-copilot/jest.config.cjs` is unchanged against the merge base).
- Note: for a file at 100% `% Lines`, the v8 `Uncovered Line #s` column lists lines with partly covered branches, so an entry there for such a file is a branch observation, not an unexecuted line.

## git grep output (post-change file:line pairs)

```
extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts:118
extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts:300
extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts:68
extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts:74
extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts:103
extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts:112
extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts:237
extensions/drm-copilot/src/lib/resolve/file-prompt-transforms.ts:188
extensions/drm-copilot/src/lib/resolve/file-prompt-transforms.ts:195
extensions/drm-copilot/src/lib/subagent-tree/tree-assembler.ts:181
extensions/drm-copilot/src/lib/subagent-tree/tree-formatter.ts:30
extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts:125
extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts:204
extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts:285
extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts:459
extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-topology.ts:300
extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts:254
extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts:286
extensions/drm-copilot/src/lib/validate/orchestrator-state-model-routing-existence.ts:68
```

## Per-file baseline vs post-change

| File (src/lib/...) | Baseline % Lines (P0-T8) | Post % Lines (P2-T5) | Baseline % Branch | Post % Branch | Post-change sort lines | In Uncovered Line #s? (P2-T5 column) |
|---|---|---|---|---|---|---|
| push-down/claude-pack-selection.ts | 100 | 100 | 98 | 98 | 118, 300 | No (`90`) |
| push-down/codex-pack-selection.ts | 98.33 | 98.36 | 97.14 | 97.18 | 68, 74, 103, 112, 237 | No (`202-205`) |
| subagent-tree/tree-assembler.ts | 99.45 | 99.45 | 90 | 90 | 181 | No (`119`) |
| subagent-tree/tree-formatter.ts | 100 | 100 | 100 | 100 | 30 | No (empty) |
| resolve/file-prompt-transforms.ts | 100 | 100 | 86.66 | 87.09 | 188, 195 | No (`43,105,161,196`) |
| validate/codex-topology-resolver.ts | 97.38 | 97.4 | 94.73 | 94.73 | 125 | No (`91-92,96-100`) |
| validate/epic-orchestrator-state-core.ts | 97.96 | 98.78 | 91.2 | 93.54 | 204 | No (`182-183,360-361,365-366`) |
| validate/epic-planner-git-integrity.ts | 100 | 100 | 93.9 | 93.97 | 285 | No (`54,61,68,207,223`) |
| validate/orchestrator-state-codex-model-routing.ts | 95.67 | 95.68 | 93.96 | 94.06 | 459 | No (`164-165,325-329,339-342,352-356,360,362-365`) |
| validate/orchestrator-state-codex-topology.ts | 96.27 | 96.28 | 95.04 | 95.04 | 300 | No (`44-45,56-57,61-68`) |
| validate/orchestrator-state-core.ts | 98.9 | 98.91 | 96.25 | 96.25 | 254, 286 | No (`309,311-314`) |
| validate/orchestrator-state-model-routing-existence.ts | 100 | 100 | 100 | 100 | 68 | No (empty) |

Result: PASS.
