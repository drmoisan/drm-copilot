# Static Baseline - PowerShell Format (P0-T2)

Timestamp: 2026-11-23T12-56
Command: sh SCRATCH/issue-1221-static-ps.sh check .claude/lib/docs tests/scripts/claude-lib/docs (imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat with a recording, non-writing -WriteFile seam and scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary: FILES_SCANNED=214, FILES_NEEDING_FORMAT=0. Finding count: 0. No file was written; the baseline was captured before any write-mode formatter ran.
