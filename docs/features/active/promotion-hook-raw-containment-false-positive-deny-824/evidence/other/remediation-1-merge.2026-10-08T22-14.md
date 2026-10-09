# Remediation 1 Merge (MC-1)

Timestamp: 2026-10-08T22-14
Command: git merge --no-edit origin/epic/enforcement-hook-precision-integration
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: exactly two CONFLICT lines, for CLAUDE_MANIFEST and LEGACY_TEST; CODEX_MANIFEST auto-merged.

```text
Auto-merging extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
CONFLICT (content): Merge conflict in extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
Auto-merging extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
Auto-merging tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
CONFLICT (content): Merge conflict in tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
Automatic merge failed; fix conflicts and then commit the result.
```

## Pre-resolution state:

Command: git ls-files -u
EXIT_CODE: 0
Output Summary: stage 1/2/3 entries for exactly the two conflicted paths.

```text
100644 ab256511a6ec6cdfaee51d297a9641a7d1a9b045 1	extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
100644 a3232290a62547ba105c7a32c38ccb86b988f654 2	extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
100644 05fe997c8f593a60901562c236f67fa4626b4f09 3	extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
100644 735da3f2f96c6864165cb4b08645d6ec90645fa3 1	tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
100644 856d0c73b31e1cdbb0182bf62a8bc74265676eaf 2	tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
100644 5904cc4988bdb6a42f8ada7338025151e0b836da 3	tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```

Command: git status --porcelain
EXIT_CODE: 0
Output Summary: Unmerged codes: `UU` on exactly the two conflicted paths; no `AA`, `DU`, `UD`, `AU`, `UA`, or `DD` line. All other lines are staged auto-merge results (`M ` / `A `) from the integration branch (#565 hooks, mirrors, tests, and #565 feature-folder documents), plus two unstaged (` M`) lines under FEATURE/ (this plan's checklist state and the [P0-T12] append to the git-baseline artifact). Non-FEATURE-565 lines:

```text
M  .claude/hooks/enforce-epic-wave-barrier.ps1
M  .claude/hooks/enforce-feature-folder-order.ps1
M  .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
M  .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
M  .claude/hooks/enforce-parallel-cohort-barrier.ps1
M  .claude/hooks/enforce-parallel-drift-gate.ps1
M  .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
A  .claude/hooks/feature-folder-resolution.ps1
M  .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
M  .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
A  .codex/hooks/feature-folder-resolution.ps1
 M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline/git-baseline.2026-10-08T21-57.md
 M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-09T01-50.md
M  docs/features/epics/enforcement-hook-precision/epic-status.md
M  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
M  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1
M  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
M  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
M  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
M  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1
M  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
A  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-folder-resolution.ps1
UU extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
M  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
M  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
A  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-folder-resolution.ps1
M  extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
A  tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
M  tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
A  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
A  tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
A  tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
M  tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
A  tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1
A  tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
A  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
A  tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
UU tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```

The remaining lines are `A ` or `M ` entries under `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/` (staged auto-merge results; none unmerged).

## Pre-resolution merge check:

Command: sh <SCRATCHPAD>/s-merge-check.sh
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: MERGE_CHECK: FAIL with CONFLICT_MARKER_COUNT: 6 (shows the [P1-T6] check can fail).

```text
MANIFEST_PARSE extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json FAIL
MANIFEST extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json paths=-1 duplicates=-1
ORDER feature-folder-resolution=-1 hook-command-heredoc=-1
MANIFEST_PARSE extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json OK
MANIFEST extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json paths=122 duplicates=0
CODEX_ENTRY .codex/hooks/feature-folder-resolution.ps1 PRESENT
CODEX_ENTRY .codex/hooks/hook-command-heredoc.ps1 PRESENT
SHARED_MODULE_LINES: 2
SHARED_MODULE_COUNT: 9
SHARED_MODULE_DUPLICATES: 0
SHARED_MODULE_MISSING: feature-folder-resolution.ps1
LEGACY_LINES: 501
CONFLICT_MARKER extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:56
CONFLICT_MARKER extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:58
CONFLICT_MARKER extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:60
CONFLICT_MARKER tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30
CONFLICT_MARKER tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:32
CONFLICT_MARKER tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:34
CONFLICT_MARKER_COUNT: 6
MERGE_CHECK: FAIL
```
