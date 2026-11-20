# Regeneration (rules surface)

Timestamp: 2026-11-18T12-21
Command: sh SCRATCH/issue-1029-gen.sh rules (runs `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface rules` from the worktree root); then `git diff --exit-code HEAD -- .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md .agents/skills/orchestrator-state/SKILL.md`; then `git status --porcelain`
EXIT_CODE: 0
Output Summary: The generator printed `harness-generation: no drift` and exited 0. The `git diff --exit-code HEAD` over `GEN`, `GENB`, and `CDX` exited 0, so the generated output is byte-identical to the committed files. `git status --porcelain` printed nothing, so no path other than the already committed `SRC.md`, `SRC.json`, and feature-folder files changed. Result: PASS.
Existing test disposition: `tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1` asserts the `## Release-Commit Allowance Scope` heading in `GEN` and `GENB`. It is unchanged, because both files stay byte-identical.
