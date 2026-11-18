# Generator drift baseline (correction plan [P0-T1])

Timestamp: 2026-11-18T11-31
Command: pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check (run from a launcher script under SCRATCH)
EXIT_CODE: 1
Output Summary: pre-change state, drift present. Output lines: `DRIFT .claude/rules/orchestrator-state.md (content differs)`; `DRIFT extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md (content differs)`; `harness-generation: 2 finding(s)`.
