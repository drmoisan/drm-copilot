# Final QC static - PowerShell

Timestamp: 2026-11-18T00-49
Command: sh SCRATCH/issue-1201-ps-static.sh <the 18 PowerShell files changed or added on the branch, from the name list between the merge base of origin/main and HEAD>; sh SCRATCH/issue-1201-leak-scan.sh
EXIT_CODE: 0
Output Summary:
- Files: the four copies of hook-release-allowance-context.ps1, the four copies of enforce-orchestration-preimplementation-gate-release.ps1, the four gate copies, and the six new test files (including the cases file).
- Step 1 format (check-only Invoke-Formatter compare with scripts/powershell/PoshQC/settings/pssa.settings.psd1; no file written): EXIT_CODE 0; finding count 0 ("format_drift=0"); the formatter changed no file.
- Step 2 PSScriptAnalyzer (repository settings): EXIT_CODE 0; finding count 0.
- Step 3 Invoke-PoshQCLeakScan (branch-current PoshQC module, -Root the worktree): EXIT_CODE 0; "Leak scan: 865 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures." (finding count 0 failures).
- Type checking: not applicable to PowerShell.
