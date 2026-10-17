# Final File Size Check AC-15 (issue #953, P6-T16, post-split restart pass)

Timestamp: 2026-10-16T10-00
Command: SCRATCH/issue-953-p6-t16.sh: union of `git diff --name-only origin/main...HEAD` and the paths in `git status --porcelain --untracked-files=all`, filtered to paths where `Test-Path -LiteralPath <path> -PathType Leaf` is true and the path does not end in `.md`; `(Get-Content -LiteralPath <path>).Count` for each
EXIT_CODE: 0
Output Summary: 17 files in the changed-file set; the largest is 461 lines, so every count is at most 500. The set includes tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 (163), tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 (103), scripts/powershell/PoshQC/PoshQC.Testing.psm1 (461), tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 (289, after the decision D9 split), and tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 (295, committed in 9e2378321 and listed by the base diff).

| Path | Lines |
|---|---|
| .devcontainer/post-create.sh | 324 |
| .github/codex/codex-web-setup.sh | 332 |
| .github/workflows/_poshqc.yml | 90 |
| extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 149 |
| extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | 461 |
| extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | 37 |
| scripts/host-tools.manifest.json | 28 |
| scripts/powershell/PoshQC/PoshQC.psm1 | 149 |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 461 |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | 37 |
| tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | 291 |
| tests/scripts/host-tools.manifest.Tests.ps1 | 168 |
| tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 | 95 |
| tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 | 103 |
| tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | 163 |
| tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 | 295 |
| tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | 289 |

MAX_LINES: 461
ALL_LE_500: True
