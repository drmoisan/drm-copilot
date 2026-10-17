# r2 final file sizes (P5-T8, AC-15, CR-17)

Timestamp: 2026-10-16T16-52
Command: git diff --name-only origin/main...HEAD; git status --porcelain --untracked-files=all; sh "SCRATCH/issue-953-r2-p5-t8.sh" (union of both listings, kept when Test-Path -LiteralPath <path> -PathType Leaf is true, .md paths dropped, (Get-Content -LiteralPath <path>).Count per path)
EXIT_CODE: 0
Output Summary: 29 paths; every count is at most 500 (OVER_500=0); all seven required paths are included.
  .devcontainer/post-create.sh 324
  .github/codex/codex-web-setup.sh 332
  .github/workflows/_poshqc.yml 186
  extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.CoverageMerge.psm1 163
  extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 33
  extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 160
  extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Shard.psm1 256
  extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 479
  extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 37
  scripts/host-tools.manifest.json 28
  scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1 163
  scripts/powershell/PoshQC/PoshQC.psd1 33
  scripts/powershell/PoshQC/PoshQC.psm1 160
  scripts/powershell/PoshQC/PoshQC.Shard.psm1 256
  scripts/powershell/PoshQC/PoshQC.Testing.psm1 479
  scripts/powershell/PoshQC/settings/pester.runsettings.psd1 37
  tests/scripts/dev_tools/test_poshqc_bundled_parity.py 84
  tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 348
  tests/scripts/host-tools.manifest.Tests.ps1 168
  tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1 189
  tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 95
  tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 103
  tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 233
  tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 172
  tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 295
  tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 124
  tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1 162 (157 after P1-T9; 162 after the P5 restart-rule TS04 fix)
  tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 289
  tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 217
