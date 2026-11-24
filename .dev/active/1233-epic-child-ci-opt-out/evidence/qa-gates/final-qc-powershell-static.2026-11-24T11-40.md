# Final QC: PowerShell static (P5-T1)

Timestamp: 2026-11-24T11-40
Command: pwsh -NoProfile -File SCRATCH/issue-1233-ps-static-runtime.ps1 -Root <item worktree> (through SCRATCH/issue-1233-ps-static.sh): Invoke-PoshQCFormat -Root <worktree> -WriteFile { no-op } ; Invoke-PoshQCAnalyze -Root <worktree> (scripts/powershell/PoshQC/settings/pssa.settings.psd1) ; Invoke-PoshQCLeakScan -Root <worktree>
EXIT_CODE: 0
Output Summary:
- Format: command Invoke-PoshQCFormat with the non-writing -WriteFile seam; exit 0; finding count 0 ("Formatted:" lines: 0; "Already formatted:" lines: 1883). `git status --porcelain` was empty before and after the run (no file rewritten).
- Lint: command Invoke-PoshQCAnalyze; exit 0; finding count 0 ("PSScriptAnalyzer passed: no findings").
- Leak scan: command Invoke-PoshQCLeakScan; exit 0; failure count 0 ("Leak scan: 911 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.").
- Type check: not applicable to PowerShell.
- Comparison with baseline-powershell-static.2026-11-24T05-22.md: format drift 0 -> 0, analyzer findings 0 -> 0, leak-scan failures 0 -> 0 (907 -> 911 files scanned: the four new test files). Zero new findings.
