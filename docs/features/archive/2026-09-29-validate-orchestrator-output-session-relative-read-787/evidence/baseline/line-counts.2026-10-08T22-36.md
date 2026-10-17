# Pre-Change Line Counts, LC-BASE (P0-T17)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 <LC-BASE: HOOK T-MAIN T-DISPATCH T-ROUTING T-HUMAN WAVE WRR MANIFEST PIN CORE>
EXIT_CODE: 0
Output Summary:
.claude/hooks/validate-orchestrator-output.ps1 LineCount=421
tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 LineCount=490
tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 LineCount=316
tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 LineCount=146
tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 LineCount=126
.claude/hooks/enforce-epic-wave-barrier.ps1 LineCount=376
.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 LineCount=497
tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 LineCount=107
tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py LineCount=370
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json LineCount=214

BASE_HOOK_LINES=421
BASE_MAIN_LINES=490

Result: PASS (10 LineCount lines).
