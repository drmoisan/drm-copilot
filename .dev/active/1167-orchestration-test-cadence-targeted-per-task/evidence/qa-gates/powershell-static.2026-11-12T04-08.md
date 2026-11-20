# PowerShell Final-QC Static ([P2-T1])

Timestamp: 2026-11-12T04-08
Command: sh SCRATCH/issue-1167-psstatic.sh tests/scripts/claude-runtime (pwsh 7: Invoke-Formatter check per file with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-ScriptAnalyzer -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information; Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary:
- Step 1 format check: files=37 (36 at [P0-T1] plus the new test-cadence-wording.Tests.ps1), drift 0, exit 0, finding count 0.
- Step 2 PSScriptAnalyzer: 0 findings (Phase 0: 0), exit 0; 0 findings in tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1.
- Step 3 type check: not applicable for PowerShell.
- Step 4 Invoke-PoshQCLeakScan: 742 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures; exit 0.
- git status --porcelain before and after the format step: unchanged (no file rewritten).
