# Baseline: PSScriptAnalyzer (Issue #973)

Timestamp: 2026-10-17T13-07
Command: sh SCRATCH/issue-973-run.sh issue-973-analyze.ps1 -Root <worktree> -FileList <seven files> (PowerShell 7; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, per file)
EXIT_CODE: 0

| File | Findings |
|---|---|
| `scripts/ci/CiChangeScope.psm1` | 0 |
| `scripts/ci/Invoke-CiChangeScope.ps1` | 0 |
| `tests/scripts/ci/CiChangeScope.Tests.ps1` | 0 |
| `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` | 0 |
| `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` | 0 |
| `tests/scripts/workflows/CiWorkflow.Tests.ps1` | 0 |
| `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` | 0 |

Output Summary: ANALYZE_TOTAL=0. No findings in any of the seven files (no rule names to list).
