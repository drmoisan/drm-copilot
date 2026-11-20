# H3 Ledger Region Map ([P0-T1], H3-REGION-MAP)

Timestamp: 2026-11-19T14-36
Plan: plan-h3-sync-writer-retirement.md
Command: sh SCRATCH/issue-1032-r1-run.sh issue-1032-h3-regionmap.ps1 (parses every entry's Prior Text with Get-ProcessReductionRevertBlock and every stored patch with Get-ProcessReductionPatchHunk; selects each block or hunk whose path is a Phase 1 edit target; a row is in-region when the block Current, or the hunk context plus + lines, holds a text the Phase 1 edit removes or rewrites; also scans every ledger file for the writer tokens)
EXIT_CODE: 0
Output Summary: 4 blocks on Phase 1 targets (entry 0001 blocks 5 to 8, all `.vscode/tasks.json`), all outside; 0 stored-patch hunks on any Phase 1 target; 0 ledger files mention a writer token or `Sync AGENTS.md`. LEDGER-STEP applies to no Phase 1 task.

Anchor texts tested: `sync-agents-from-instructions`, `syncAgentsFromInstructions`, `SyncAgentsFromInstructions`, `Sync AGENTS.md`, `executeBundledScript`, `seven catalog entries`, `## [Unreleased]`, `CLR-`.

The four `.vscode/tasks.json` blocks hold the `QC: 4 Pytest` task text; the removed task object (between the preceding task and `TS: 1 Prettier: format`) holds the writer path token, so any block Current spanning it would hold that token. None does; the chain test's substring match of each block is unaffected by the removal.

## Rows (entry or patch | block or hunk | status)

- 0001-parallel-only-test-gates.md | block 5 `### Revert Block: .vscode/tasks.json` | outside
- 0001-parallel-only-test-gates.md | block 6 `### Revert Block: .vscode/tasks.json` | outside
- 0001-parallel-only-test-gates.md | block 7 `### Revert Block: .vscode/tasks.json` | outside
- 0001-parallel-only-test-gates.md | block 8 `### Revert Block: .vscode/tasks.json` | outside
- scripts/dev-tools/sync-agents-from-instructions.ps1 | no block or hunk | outside
- extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1 | no block or hunk | outside
- tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | no block or hunk | outside
- config/poshqc-shard-weights.json | no block or hunk | outside
- extensions/drm-copilot/src/repo-automation-command-registration-admin.ts | no block or hunk | outside
- extensions/drm-copilot/package.json | no block or hunk | outside
- extensions/drm-copilot/test/extension.test.ts | no block or hunk | outside
- extensions/drm-copilot/test/extension.integration.test.ts | no block or hunk | outside
- extensions/drm-copilot/test/extension.workflow-commands.test.ts | no block or hunk | outside
- extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts | no block or hunk | outside
- extensions/drm-copilot/test/lib/push-down/reference-rewrites.test.ts | no block or hunk | outside
- scripts/dev_tools/push_down_copilot_customizations_rewrites.py | no block or hunk | outside
- tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py | no block or hunk | outside
- README.md | no block or hunk | outside
- extensions/drm-copilot/README.md | no block or hunk | outside
- extensions/drm-copilot/CHANGELOG.md | no block or hunk | outside
- tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1 (GUARD-SUITE) | no block or hunk | outside
