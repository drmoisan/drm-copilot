# Final QC Static: PowerShell (Remediation Cycle 1)

Timestamp: 2026-11-14T16-35
Command: sh SCRATCH/issue-1182-finalstatic.sh r1f (PoshQC format check-only via Invoke-PoshQCFormat with a no-op writer; PSScriptAnalyzer 1.25.0 per file with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-PoshQCLeakScan through the branch-current module; git status --porcelain before and after)
EXIT_CODE: 0
Output Summary:
- Format: FORMAT_EXIT=0, 1711 files scanned, FORMAT_CHANGED=0. Observed result: git status --porcelain identical before and after the whole loop (clean tree), so the formatter rewrote nothing; no restart was needed.
- Analyzer: 0 findings, 0 retries, 0 analyzer errors.
- Leak scan: 823 files, 77 findings, 75 exempt, 2 allowlisted, 0 failures (exit 0).
- Logical line counts: .claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1 136; tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1 297. Both under 500.
- Python static (no Python file changed, recorded for completeness): Black --check exit 0, Ruff exit 0, Pyright exit 0.
