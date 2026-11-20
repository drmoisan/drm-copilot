# Phase 0 PowerShell Linter Baseline — Issue #673 ([P0-T6])

Timestamp: 2026-09-17T10-31

Command: sh "<HOME>/AppData/Local/Temp/claude/C--Users-<USER>-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/p0t6.sh"
(route a-prime per `execution-route.md`; the script sets the working directory to the workspace root and launches `"<PROGRAM_FILES>/PowerShell/7/pwsh.exe" -NoProfile -File .../f673-exec/p0t6.ps1`). The PowerShell body, in order:
```
Set-Location -LiteralPath '<WORKTREE_ROOT>'
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
$files = @(Get-PoshQCFileList -Root '<WORKTREE_ROOT>' | Where-Object { $_.Extension -in '.ps1', '.psm1' })
foreach ($file in $files) { $records += @(Invoke-ScriptAnalyzer -Path $file.FullName -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information -ErrorAction Stop) }
# counts derived by grouping $records on Severity; per-file records matched on full ScriptPath
```

EXIT_CODE: 0

Output Summary:
- Scanned file count (filtered `Get-PoshQCFileList` result, `.ps1`/`.psm1` only): 484
- Total captured DiagnosticRecord count: 0
- Error-severity count: 0
- Warning-severity count: 0
- Information-severity count: 0
- PSScriptAnalyzer version: 1.25.0
- Per-file record counts for the four in-scope hooks (each confirmed present in the scanned set):
  - `.claude/hooks/enforce-pr-author-skill.ps1`: 0 records
  - `.claude/hooks/enforce-pr-author-skill-helpers.ps1`: 0 records
  - `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`: 0 records
  - `.claude/hooks/enforce-model-routing-receipt.ps1`: 0 records
- In-scope hook records (RuleName, Severity, Line): none.

Execution note: the first launch of this script used `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force`
and exited 1 with `The specified module 'scripts/powershell/PoshQC/PoshQC.psd1' was not loaded because no valid
module file was found in any module directory.` (PowerShell treats a path without a leading `./` as a module
name). The same file was then imported as `./scripts/powershell/PoshQC/PoshQC.psd1`, and the run above
completed with exit code 0. The root passed to `Get-PoshQCFileList` is the recorded F5_WORKSPACE_ROOT, not a
directory above it.

Verbatim script output:
```
Location: <WORKTREE_ROOT>
PSScriptAnalyzerVersion: 1.25.0
ScannedFileCount: 484
TotalRecordCount: 0
ErrorCount: 0
WarningCount: 0
InformationCount: 0
HookFile: .claude/hooks/enforce-pr-author-skill.ps1 InScanSet=1 RecordCount=0
HookFile: .claude/hooks/enforce-pr-author-skill-helpers.ps1 InScanSet=1 RecordCount=0
HookFile: .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 InScanSet=1 RecordCount=0
HookFile: .claude/hooks/enforce-model-routing-receipt.ps1 InScanSet=1 RecordCount=0
AllRecords:
```
