# PowerShell static QA gate (P5-T1)

Timestamp: 2026-11-08T14-18
Command: pwsh -NoProfile -File SCRATCH/issue-1128-static.ps1 -Phase P5 (Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 plus Invoke-Formatter check-only over .claude/hooks, .claude/lib, tests/scripts/claude-hooks, tests/scripts/claude-lib); pwsh -NoProfile -File SCRATCH/issue-1128-leak.ps1 (Invoke-PoshQCLeakScan -Root)
EXIT_CODE: 0
Output Summary: Loop passes. First pass found 7 analyzer findings (PSUseOutputTypeCorrectly in RunbookCommandVersion.psm1, PSReviewUnusedParameter x2 and PSAlignAssignmentStatement x4 in the new hook tests) and 1 format-drift file; they were fixed and the gates re-run. Final pass: Files=713 AnalyzerFindings=0 FormatDriftFiles=0 (P0-T1 baseline: Files=708 AnalyzerFindings=0 FormatDriftFiles=0, so no increase). Leak scan: 702 files, 72 findings, 70 exempt, 2 allowlisted, 0 failures, exit 0. The check-only format pass leaves git status --porcelain unchanged.

Second pass (after the OrchestratorState.Tests.ps1 order-dependence fix): Files=713 AnalyzerFindings=0 FormatDriftFiles=0, leak scan 0 failures, exit 0.
