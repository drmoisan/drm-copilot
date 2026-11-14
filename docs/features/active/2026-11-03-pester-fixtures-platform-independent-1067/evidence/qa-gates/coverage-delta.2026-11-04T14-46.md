# Coverage Delta and Changed-Line Hits (P6-T9, second restart pass after resume)

Timestamp: 2026-11-04T14-46
Command: git diff -U0 MB HEAD -- scripts/dev-tools/activate.ps1 scripts/dev-tools/HostBootstrapWorkspace.psm1 scripts/dev-tools/DrmCopilotPromptSupport.ps1 scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 ; LINE elements of the P6-T8 coverage XML as printed by SCRATCH/issue-1067-coverage.ps1
EXIT_CODE: 0
Output Summary:

Per-file line coverage, baseline (P0-T6, `evidence/baseline/coverage-baseline.2026-11-04T03-57.md`) versus final (P6-T8, `evidence/qa-gates/coverage-final.2026-11-04T14-46.md`):

| File | Baseline | Final |
|---|---|---|
| scripts/dev-tools/activate.ps1 | 92.45 | 98.11 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1 | 96.88 | 100 |
| scripts/dev-tools/DrmCopilotPromptSupport.ps1 | 65.79 | 86.84 |
| scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 | 89.13 | 91.3 |

Executable lines added or changed in `git diff -U0 MB HEAD` (comment and comment-based-help lines excluded), with the covered-instruction count (`ci`) of each line in the final XML; a value of at least 1 means the line ran:

| File and post-change line | Changed statement | ci |
|---|---|---|
| scripts/dev-tools/activate.ps1, line 138 | `elseif ($CurrentPath.StartsWith($VenvRoot + [System.IO.Path]::DirectorySeparatorChar, ...))` | 1 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1, line 75 | `Resolve-WorkspaceRoot` return with `Combine($PWD.ProviderPath, ...)` | 1 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1, line 176 | `Resolve-ProjectRepoRoot` explicit repo root return | 1 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1, line 187 | `Resolve-ProjectRepoRoot` drm-copilot target return | 2 |
| scripts/dev-tools/DrmCopilotPromptSupport.ps1, line 13 | `Get-DrmCopilotNormalizedPath` return | 1 |
| scripts/dev-tools/DrmCopilotPromptSupport.ps1, line 127 | `Resolve-DrmCopilotActivationScriptPath` return | 1 |
| scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1, line 98 | `if ($folderText -match '^(?:[A-Za-z]:|[\\/])')` | 1 |

- All 7 changed executable lines are covered, and every per-file figure rose from baseline, so changed lines show no coverage regression (AC9).
