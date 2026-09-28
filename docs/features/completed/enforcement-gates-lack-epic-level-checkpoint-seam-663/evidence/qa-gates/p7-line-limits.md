# Line Limits and Base Check ([P7-T1], AC-24)

Timestamp: 2026-09-25T19-49
Command: git rev-parse origin/main; then sh <SCRATCHPAD>/i663/run.sh p7-lines  (fresh PowerShell 7 process; `@(Get-Content -LiteralPath <file>).Count` for each of the 23 files)
EXIT_CODE: 0
Output Summary: `git rev-parse origin/main` printed d754f83f714b087e404577cb7a1b02f48d2023bb, equal to `ORIGIN_MAIN_SHA:` in `evidence/baseline/p0-base-ref.md`; no rebase is needed. 23 counts recorded; the maximum is 496 (`tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`); every count is at most 500.

## git rev-parse origin/main

```
d754f83f714b087e404577cb7a1b02f48d2023bb
```

## Line Counts

| File | Lines |
| --- | --- |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 488 |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 483 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 127 |
| .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 384 |
| .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 144 |
| .claude/hooks/enforce-model-routing-receipt.ps1 | 295 |
| .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 366 |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | 176 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 488 |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | 313 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | 466 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | 473 |
| tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 | 352 |
| tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | 92 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | 100 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | 158 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | 204 |
| tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | 149 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | 227 |
| tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | 491 |
| tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | 208 |
| tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py | 496 |
| tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py | 353 |

FileCount: 23
MaxLines: 496
Result: PASS (23 counts, all at most 500; origin/main unchanged)

## Addendum after the [P8-T7] pass-1 remediation (2026-09-25T20-15)

The pass-1 remediation added five rows to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`. A re-run of `sh <SCRATCHPAD>/i663/run.sh p7-lines` reports that file at 310 lines (was 227); FileCount 23 and MaxLines 496 are unchanged, so every count remains at most 500.
