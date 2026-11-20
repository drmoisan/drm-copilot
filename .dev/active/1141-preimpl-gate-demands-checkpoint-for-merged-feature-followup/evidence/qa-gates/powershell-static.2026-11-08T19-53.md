# PowerShell Final Static Loop (issue #1141, [P5-T1])

Timestamp: 2026-11-08T19-53
Command: sh SCRATCH/issue-1141-static.sh <11 changed .ps1 files> (pwsh 7: per file Invoke-Formatter -ScriptDefinition <LF-normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the input (check-only); Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; @(Get-Content).Count; then Import-Module scripts/powershell/PoshQC/PoshQC.psd1 and Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary:
- Format (Invoke-Formatter, check-only): exit 0; drift count 0 of 11 files.
- Lint (Invoke-ScriptAnalyzer, repo settings): exit 0; 0 findings in every file.
- Type check: not applicable to PowerShell.
- Invoke-PoshQCLeakScan -Root: exit 0; "Leak scan: 715 files, 74 findings, 72 exempt, 2 allowlisted, 0 failures." (baseline 713 files; the two new test files add no failure and no allowlist entry). config/poshqc-leak-allowlist.json has no diff from the merge base of origin/main and HEAD.
- No step changed a file, so no restart was needed.

| File | Drift | PSSA findings | Lines ([P0-T2] baseline) |
| --- | --- | --- | --- |
| .claude/hooks/hook-epic-fan-in.ps1 | no | 0 | 488 (345) |
| .codex/hooks/hook-epic-fan-in.ps1 | no | 0 | 488 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-epic-fan-in.ps1 | no | 0 | 488 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-epic-fan-in.ps1 | no | 0 | 488 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | no | 0 | 402 (396) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | no | 0 | 462 (456) |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | no | 0 | 402 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | no | 0 | 462 |
| tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1 | no | 0 | 473 (282) |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.MergedFollowUp.Tests.ps1 | no | 0 | 296 (new) |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-merged-follow-up.Tests.ps1 | no | 0 | 186 (new) |

`hook-epic-fan-in.ps1` is 488 physical lines, within the 500-line cap.
