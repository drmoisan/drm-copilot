# Final QC: PowerShell static (P5-T1, restarted loop)

Timestamp: 2026-11-24T11-53
Command: pwsh -NoProfile -File SCRATCH/issue-1233-ps-static-runtime.ps1 -Root <item worktree> (through SCRATCH/issue-1233-ps-static.sh, run p5b-ps-static after the fix in evidence/other/final-qa-remediation.2026-11-24T11-53.md): Invoke-PoshQCFormat -WriteFile { no-op } ; Invoke-PoshQCAnalyze (pssa.settings.psd1) ; Invoke-PoshQCLeakScan
EXIT_CODE: 0
Output Summary:
- Format: Invoke-PoshQCFormat with the non-writing -WriteFile seam; exit 0; finding count 0 (0 "Formatted:" lines; 1883 "Already formatted:"). `git status --porcelain` listed the same entries before and after the run (the uncommitted fix files and evidence only); no file was rewritten.
- Lint: Invoke-PoshQCAnalyze; exit 0; finding count 0 ("PSScriptAnalyzer passed: no findings").
- Leak scan: Invoke-PoshQCLeakScan; exit 0; 0 failures ("Leak scan: 911 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.").
- Zero new findings against baseline-powershell-static.2026-11-24T05-22.md.
