# PowerShell QA: Branch-Current Pester, Single Process (P6-T6)

Timestamp: 2026-10-29T15-15
Command: sh SCRATCH/issue-992-ps.sh test (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -DisableKoverageCopy; scan folders from config/poshqc-scan.json, which include tests/scripts; coverage population from config/poshqc-coverage.json)
EXIT_CODE: 0
Output Summary: From artifacts/pester/pester-junit.xml: tests=12104, failures=0, errors=0, skipped=10 (runner: 12094 passed, 0 failed, 10 skipped; 739.1 s). The 22 cases of the new hook suite are present in the JUnit file. From artifacts/pester/powershell-coverage.xml: repo-wide LINE 18349/19746 = 92.93%.

| File | LINE coverage | Threshold 85% |
| --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1` | 38/38 = 100.00% | met |
| `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` | 119/119 = 100.00% | met |
| `.claude/hooks/validate-orchestrator-output-feature-folder.ps1` | 25/27 = 92.59% | met |
| `.claude/hooks/validate-orchestrator-output.ps1` | 118/119 = 99.16% | met |

The two unexecuted lines of `validate-orchestrator-output-feature-folder.ps1` are the default real-git invoker script block of `Invoke-FeatureFolderGitExe` and the call that uses it when no invoker is injected; tests never start git.
