# Remediation Cycle 1 Line Limits ([P3-T1], AC-24)

Timestamp: 2026-09-25T21-28
Command: sh <SCRATCHPAD>/rem1/runout.sh p3-lines  (git rev-parse origin/main; @(Get-Content -LiteralPath <path>).Count for the ten section 5 paths)
EXIT_CODE: 0
Output Summary: origin/main is d754f83f714b087e404577cb7a1b02f48d2023bb and equals ORIGIN_MAIN_SHA in rem1-base-ref.md. Ten counts: helpers copies 497 (cap 500), EpicScopeResolution.psm1 copies 369 (cap 400), suites 487, 494, 383, 329 (cap 500). None over cap.

## Output

```
git rev-parse origin/main: d754f83f714b087e404577cb7a1b02f48d2023bb
Matches ORIGIN_MAIN_SHA d754f83f714b087e404577cb7a1b02f48d2023bb: True
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 497 (cap 500, within)
- .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 497 (cap 500, within)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 497 (cap 500, within)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 497 (cap 500, within)
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1: 369 (cap 400, within)
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/EpicScopeResolution.psm1: 369 (cap 400, within)
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1: 487 (cap 500, within)
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1: 494 (cap 500, within)
- tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1: 383 (cap 500, within)
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1: 329 (cap 500, within)
Counts recorded: 10; over cap: 0
PROCESS_EXIT_CODE: 0
```
