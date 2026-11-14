# PowerShell Final QC (static) — [P6-T1]

Timestamp: 2026-11-14T02-56
Command: sh SCRATCH/issue-1156-ps-static.sh (pwsh 7: per file, Invoke-Formatter -ScriptDefinition <content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file content; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, direct run) over the 39 .ps1/.psm1/.psd1 files added or modified since the merge base of origin/main and HEAD, bundle copies included
EXIT_CODE: 0
Output Summary: final pass: 39 files, 0 files with format drift, 0 analyzer findings. Two earlier passes failed and were fixed (loop restarted from the format step each time).

## Loop passes

| Pass | Step | Command | Exit | Findings |
|---|---|---|---|---|
| 1 | format (compare) | Invoke-Formatter vs file text | 172 (combined) | 5 files with drift: Invoke-RegenerationPath.ps1 and its bundle copy, Invoke-RegenerationPath.Merge.Tests.ps1, RegenerationResultScenario.ps1, RegenerationResultTable.psd1 |
| 1 | analyze | Invoke-ScriptAnalyzer per file | (same run) | 167 (74 PSUseConsistentIndentation, 26 PSAlignAssignmentStatement, 35 PSReviewUnusedParameter, 26 PSUseOutputTypeCorrectly, 3 PSUseShouldProcessForStateChangingFunctions, 2 PSAvoidAssignmentToAutomaticVariable, 1 PSUseSingularNouns) |
| fix | format (write) | Invoke-Formatter output written to the 4 source files; bundle copy re-copied | 0 | whitespace and alignment only |
| 2 | format + analyze | same | 67 | 0 drift; 67 findings (OutputType, unused stub parameters, ShouldProcess on New-* test helpers, plural noun, automatic-variable parameter name) |
| fix | edits | see below | 0 | - |
| 3 | format + analyze | same | 0 | 0 drift, 0 findings |

## Fixes in pass 2

- enforce-epic-merge-gate-regeneration.ps1 (4 copies): Get-EpicMergeGateRegenerationMember declares OutputType object[] (comma return).
- hook-epic-regeneration.ps1 (4 copies): Get-EpicRegenerationConfigPattern and Read-EpicRegenerationConfig declare OutputType string[] and object[]; the unused-parameter deny predicate is the parameterless script block { $false }.
- Invoke-RegenerationPath.ps1 (2 copies): Get-RegenerationSortedPath declares string[] and object[]; New-RegenerationResult carries a PSAvoidAssignmentToAutomaticVariable suppression for the -Event parameter, whose name mirrors the spec D17 result key (same attribute form as the existing ShouldProcess suppression on that builder).
- Tests: helper renames New-GateRegenerationEvent to Get-GateRegenerationEvent, New-R73Pair to Get-R73Pair (with OutputType hashtable), New-RegenerationGateEvent to Get-RegenerationGateEvent, Assert-RscContains to Assert-RscLiteralPresent; LiveHead captured through a local before the closure; OutputType object[] on three scenario helpers; a file-level PSReviewUnusedParameter suppression with param() on three test files whose seam stubs mirror production signatures (the established repository form). No assertion changed.

## Behavior check after the fixes (debugging run, not a gate)

Invoke-Pester over the 15 changed test files plus hook-dependency-guard-completeness, ClaudeLibModuleConvention, and codex-epic-runtime-contracts: 1801 passed, 0 failed.
