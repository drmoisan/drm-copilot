# PowerShell Final Static Loop — Remediation Cycle 1, Restart ([P2-T1] loop restart after the [P2-T2] coverage fix)

Timestamp: 2026-11-08T20-30
Command: sh SCRATCH/issue-1139-rc1-static.sh (same four files and steps as powershell-static.2026-11-08T20-19.md: Invoke-Formatter check-only comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, then Invoke-PoshQCLeakScan -Root of the branch-current PoshQC module)
EXIT_CODE: 0
Output Summary: Re-run after adding `B7 rejects the calendar-invalid ISO 8601 shape <Recorded>` to OrchestratorStateOwnerDirectives.Tests.ps1 (now 387 lines). Formatter: 4 files compared, 0 would change. Analyzer: 0 findings. Leak scan: exit 0, "719 files, 74 findings, 72 exempt, 2 allowlisted, 0 failures". Porcelain listed only the edited test file, so the loop rewrote nothing.

| Step | Exit code | Findings |
|---|---|---|
| Format (check-only) | 0 | 0 files would change |
| Analyze | 0 | 0 |
| Leak scan | 0 | 0 failures |
| Type check | - | not applicable for PowerShell |
