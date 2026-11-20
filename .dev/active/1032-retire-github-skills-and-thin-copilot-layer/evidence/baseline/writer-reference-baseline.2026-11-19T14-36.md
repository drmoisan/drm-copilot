# Writer Reference Baseline ([P0-T1])

Timestamp: 2026-11-19T14-36
Plan: plan-h3-sync-writer-retirement.md
Command: git grep -c -F -e 'sync-agents-from-instructions' -- . ':!docs/features/' ; git grep -c -F -e 'syncAgentsFromInstructions' -- . ':!docs/features/'
EXIT_CODE: 0
Output Summary: `sync-agents-from-instructions` in 19 tracked files (57 matching lines); `syncAgentsFromInstructions` in 13 tracked files (26 matching lines); 23 distinct files in total.

## `sync-agents-from-instructions` (file:count)

- .github/agents/atomic_planning.agent.md: 4
- .github/agents/powershell-atomic-planning.agent.md: 4
- .vscode/tasks.json: 1
- config/poshqc-shard-weights.json: 1
- docs/research/20260321-bundle-sync-agents-implementation-research.md: 15
- docs/research/20260412-codex-github-skills-agents-migration-implementation-research.md: 3
- extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md: 4
- extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-planning.agent.md: 4
- extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1: 1
- extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts: 2
- extensions/drm-copilot/src/repo-automation-command-registration-admin.ts: 1
- extensions/drm-copilot/test/extension.integration.test.ts: 1
- extensions/drm-copilot/test/extension.workflow-commands.test.ts: 1
- extensions/drm-copilot/test/lib/push-down/reference-rewrites.test.ts: 4
- scripts/dev-tools/sync-agents-from-instructions.ps1: 1
- scripts/dev_tools/push_down_copilot_customizations_rewrites.py: 2
- scripts/harness-generation/HarnessInstructions.psm1: 2
- tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1: 4
- tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py: 2

## `syncAgentsFromInstructions` (file:count)

- README.md: 2
- docs/research/20260321-bundle-sync-agents-implementation-research.md: 4
- docs/research/20260412-codex-github-skills-agents-migration-implementation-research.md: 2
- extensions/drm-copilot/README.md: 2
- extensions/drm-copilot/package.json: 1
- extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts: 1
- extensions/drm-copilot/src/repo-automation-command-registration-admin.ts: 2
- extensions/drm-copilot/test/extension.integration.test.ts: 2
- extensions/drm-copilot/test/extension.test.ts: 3
- extensions/drm-copilot/test/extension.workflow-commands.test.ts: 4
- extensions/drm-copilot/test/lib/push-down/reference-rewrites.test.ts: 1
- scripts/dev_tools/push_down_copilot_customizations_rewrites.py: 1
- tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py: 1

## Note

`scripts/harness-generation/HarnessInstructions.psm1` (added by child 3, #1028, through the integration-branch sync) is the one hit outside the files Phase 1 edits or deletes and outside the `historical` and `example` classes; it is carried to P2-T4.
