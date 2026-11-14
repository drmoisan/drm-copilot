# Coverage Delta and Changed-Line Hits (P6-T9)

Timestamp: 2026-11-04T04-18
Command: git diff -U0 MB -- scripts/dev-tools/activate.ps1 scripts/dev-tools/HostBootstrapWorkspace.psm1 scripts/dev-tools/DrmCopilotPromptSupport.ps1 scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 ; pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-linehits.ps1 (reads the line elements of the P6-T8 coverage XML)
EXIT_CODE: 0
Output Summary:

Per-file line coverage, baseline (P0-T6) versus final (P6-T8):

| File | Baseline | Final |
|---|---|---|
| scripts/dev-tools/activate.ps1 | 92.45 | 98.11 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1 | 96.88 | 100 |
| scripts/dev-tools/DrmCopilotPromptSupport.ps1 | 65.79 | 86.84 |
| scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 | 89.13 | 91.3 |

Executable lines added or changed in `git diff -U0 MB` (comment and help lines excluded), with the covered-instruction count of each line in the final XML (the JaCoCo `ci` attribute; a value of at least 1 means the line was executed):

| File:line (post-change) | Changed statement | covered instructions |
|---|---|---|
| scripts/dev-tools/activate.ps1:138 | `elseif ($CurrentPath.StartsWith($VenvRoot + [System.IO.Path]::DirectorySeparatorChar, ...))` | 1 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1:75 | `Resolve-WorkspaceRoot` return with `Combine($PWD.ProviderPath, ...)` | 1 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1:176 | `Resolve-ProjectRepoRoot` explicit repo root return | 1 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1:187 | `Resolve-ProjectRepoRoot` drm-copilot target return | 2 |
| scripts/dev-tools/DrmCopilotPromptSupport.ps1:13 | `Get-DrmCopilotNormalizedPath` return | 1 |
| scripts/dev-tools/DrmCopilotPromptSupport.ps1:127 | `Resolve-DrmCopilotActivationScriptPath` return | 1 |
| scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1:98 | `if ($folderText -match '^(?:[A-Za-z]:|[\\/])')` | 1 |

- Every changed executable line is covered (7 of 7), and every per-file figure rose, so there is no regression on changed lines (AC9).
- The line numbers above are post-change positions; the baseline XML has no instrumented statement at six of them because the edits added comment lines above the changed statements.
