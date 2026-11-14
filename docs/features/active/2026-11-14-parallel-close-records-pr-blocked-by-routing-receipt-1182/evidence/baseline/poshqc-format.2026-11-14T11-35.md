# Phase 0 Baseline: PoshQC Format (check-only)

Timestamp: 2026-11-14T11-35
Command: sh SCRATCH/issue-1182-static.sh base (pwsh -File SCRATCH/issue-1182-static.ps1: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <worktree> -WriteFile { no-op } -Logger { collect 'Formatted:' lines })
EXIT_CODE: 0
Output Summary:
- FORMAT_EXIT=0 over FILES_SCANNED=1701 PowerShell files.
- FORMAT_CHANGED=0: the formatter reported no file that would be rewritten (finding count 0).
- Check-only: the WriteFile seam is a no-op, so the step cannot rewrite a tracked file.
- git status --porcelain before the step: empty (0 lines).
- git status --porcelain after the step: no modified tracked file; two untracked entries, tests/scripts/claude-hooks/enforce-model-routing-receipt.ParallelRecords.Tests.ps1 and tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1, which the executor created with the Write tool for [P1-T1] while the step ran; the formatter did not write them.
