# Final QC - PowerShell static (P4-T1)

Timestamp: 2026-11-14T22-57
Command: pwsh -NoProfile -File SCRATCH/issue-1188-static.ps1 -ListFile SCRATCH/issue-1188-final-files.txt
EXIT_CODE: 0
Output Summary: 13 changed .ps1 files (git diff --name-only against the merge base of origin/main and HEAD, plus git status --porcelain): format 0 changes, PSScriptAnalyzer 0 findings, leak scan 0 failures. No restart was needed.

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| Format (check-only, no-change observation) | Invoke-Formatter -ScriptDefinition <CRLF-normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, compared with the input, nothing written | 0 | 0 (13 `Already formatted:` lines) |
| Lint | Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information | 0 | 0 |
| Leak scan | Invoke-PoshQCLeakScan -Root <worktree> (branch-current scripts/powershell/PoshQC/PoshQC.psd1) | 0 | 0 failures (840 files, 78 findings, 76 exempt, 2 allowlisted) |
| Type check | not applicable to PowerShell | - | - |

Files: .claude/hooks and .codex/hooks enforce-orchestration-preimplementation-gate-epic-scope.ps1 and enforce-orchestration-preimplementation-gate-operands.ps1; the four bundle copies of those files; tests/scripts/claude-hooks enforce-orchestration-preimplementation-gate-operands.Cases.ps1, .Parity.Tests.ps1, and .Tests.ps1; tests/scripts/codex-hooks enforce-orchestration-preimplementation-gate-operands.Tests.ps1 and legacy-codex-hook-contracts.Tests.ps1.
