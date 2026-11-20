# Fail-before: harness generator check (rules surface)

Timestamp: 2026-11-18T12-08
Command: sh SCRATCH/issue-1029-gen.sh rules check (runs `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface rules -Check` from the worktree root)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Unchanged tree (HEAD after P0-T1). Output, verbatim:
  DRIFT .claude/rules/orchestrator-state.md (content differs)
  DRIFT extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md (content differs)
  harness-generation: 2 finding(s)
The drift lines name `GEN` and `GENB` only; no other path is reported.
