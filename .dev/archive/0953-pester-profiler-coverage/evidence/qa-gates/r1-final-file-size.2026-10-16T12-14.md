# Remediation Cycle 1 - Final File Size (P5-T6, AC-15)

Timestamp: 2026-10-16T12-14
Command: git diff --name-only origin/main...HEAD; git status --porcelain --untracked-files=all (Bash tool); sh SCRATCH/issue-953-r1-p5-t6.sh (pwsh -NoProfile -Command: union of both listings, keep Test-Path -LiteralPath <path> -PathType Leaf, drop paths ending in .md, (Get-Content -LiteralPath <path>).Count per path)
EXIT_CODE: 0
Output Summary: 18 non-markdown changed files; every count is at most 500 (maximum 463).
SIZE: .devcontainer/post-create.sh 324
SIZE: .github/codex/codex-web-setup.sh 332
SIZE: .github/workflows/_poshqc.yml 90
SIZE: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 152
SIZE: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 463
SIZE: extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 37
SIZE: scripts/host-tools.manifest.json 28
SIZE: scripts/powershell/PoshQC/PoshQC.psm1 152
SIZE: scripts/powershell/PoshQC/PoshQC.Testing.psm1 463
SIZE: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 37
SIZE: tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 348
SIZE: tests/scripts/host-tools.manifest.Tests.ps1 168
SIZE: tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 95
SIZE: tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 103
SIZE: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 233
SIZE: tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 295
SIZE: tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 124
SIZE: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 289
Required members present with expected counts: PoshQC.Testing.psm1 463; PoshQC.psm1 152 (PSM1_BASELINE_LINES 149 + 3); PoshQC.RunSettings.Tests.ps1 233; PoshQC.TestingSeamDefaults.Tests.ps1 124.
tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 is not in the set.
