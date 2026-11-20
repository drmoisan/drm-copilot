# PowerShell Static Baseline (issue #1141, [P0-T2])

Timestamp: 2026-11-08T19-09
Command: sh SCRATCH/issue-1141-static.sh <four files> (pwsh 7: per file Invoke-Formatter -ScriptDefinition <LF-normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the input (check-only); Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; @(Get-Content).Count; then Import-Module scripts/powershell/PoshQC/PoshQC.psd1 and Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary:
- Formatter drift count: 0 of 4 files.
- Analyzer findings: 0 total (0 per file).
- Invoke-PoshQCLeakScan -Root: exit 0; "Leak scan: 713 files, 74 findings, 72 exempt, 2 allowlisted, 0 failures."
- Physical line counts: hook-epic-fan-in.ps1 345; Claude epic-scope 396; Codex epic-scope 456; hook-epic-fan-in.Tests.ps1 282.

| File | Formatter drift | PSSA findings | Physical lines |
| --- | --- | --- | --- |
| .claude/hooks/hook-epic-fan-in.ps1 | no | 0 | 345 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | no | 0 | 396 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | no | 0 | 456 |
| tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1 | no | 0 | 282 |

Note: the leak scan logged a warning that the configured scan folder `tests/powershell` does not exist in this tree and was skipped; this is pre-existing configuration and does not affect the result.
