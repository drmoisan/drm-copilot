# PowerShell Baseline: Branch-Current Pester, Single Process (P0-T5)

Timestamp: 2026-10-29T14-35
Command: sh SCRATCH/issue-992-ps.sh test (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -DisableKoverageCopy; scan folders from config/poshqc-scan.json, which include tests/scripts)
EXIT_CODE: 0
Output Summary: From artifacts/pester/pester-junit.xml: tests=12016, failures=0, errors=0, skipped=10 (runner reported 12006 passed, 0 failed, 10 skipped; 703.79 s). From artifacts/pester/powershell-coverage.xml: repo-wide LINE 18275/19670 = 92.91%; `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` LINE 116/116 = 100.00%; `.claude/hooks/validate-orchestrator-output.ps1` LINE 110/111 = 99.10%.
