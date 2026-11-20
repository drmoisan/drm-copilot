# PowerShell Final-QC Static Artifact [P2-T3] — remediation cycle 1

Timestamp: 2026-11-20T20-08
Command: sh SCRATCH/issue-1016-c1-gate.sh SCRATCH/c1f2 all, PowerShell steps through the sh launcher route (pwsh -NoProfile -File SCRATCH/issue-1016-psstatic2.ps1: branch-current PoshQC.psd1, Invoke-PoshQCFormat -Root <worktree> with a non-writing WriteFile seam, then Invoke-ScriptAnalyzer per file with scripts/powershell/PoshQC/settings/pssa.settings.psd1; pwsh -NoProfile -File SCRATCH/issue-1016-leakscan.ps1: Invoke-PoshQCLeakScan -Root <worktree>); git -C <worktree> status --porcelain --untracked-files=no captured before and after the run
EXIT_CODE: 0
Output Summary: Final QA loop pass 2 at head 520617870; all three steps exit 0 with zero findings.

| Step | Command | Exit | Findings |
| --- | --- | --- | --- |
| Format | Invoke-PoshQCFormat, non-writing seam | 0 | 1866 files, 0 `Formatted:` (drift) lines; tracked porcelain output identical before and after the run (0 lines both times) |
| Lint | Invoke-ScriptAnalyzer per file, pssa.settings.psd1 | 0 | 1866 files, 0 findings, 0 analyzer retries |
| Leak scan | Invoke-PoshQCLeakScan -Root | 0 | `Leak scan: 902 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.` (0 failing findings); one warning that the configured scan folder `tests/powershell` does not exist, which the scan skips |
