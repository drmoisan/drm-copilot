# PowerShell static gate, remediation (P4-T1)

Timestamp: 2026-11-08T15-52
Command: pwsh -NoProfile -File SCRATCH/issue-1128-static.ps1 -Root <worktree> -Phase P4 (Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 plus Invoke-Formatter check-only comparison over .claude/hooks, .claude/lib, tests/scripts/claude-hooks, tests/scripts/claude-lib); then Invoke-PoshQCLeakScan -Root <worktree> via SCRATCH/issue-1128-leak.ps1
EXIT_CODE: 0
Output Summary: Files=713 AnalyzerFindings=0 FormatDriftFiles=0 (baseline: Files=708, AnalyzerFindings=0, FormatDriftFiles=0). Leak scan: 703 files, 72 findings, 70 exempt, 2 allowlisted, 0 failures, exit 0. `git status --porcelain` printed nothing after the run (format check is read-only, tree already committed). A first run of this gate aborted with a PSScriptAnalyzer NullReferenceException on one file in the loop; per-file runs on the edited module and test file each reported COUNT=0, and the rerun with a per-file try/catch completed with zero errors, so the abort was a transient analyzer fault.
