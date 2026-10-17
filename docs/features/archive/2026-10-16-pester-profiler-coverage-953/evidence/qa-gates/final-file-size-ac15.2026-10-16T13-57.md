# Final QC: File Size AC-15 (P8-T16 / P6-T16, sharding path)

Timestamp: 2026-10-16T13-57
Command: sh "SCRATCH/issue-953-p8-t16-p6-t16.sh" — union of `git diff --name-only origin/main...HEAD` and `git status --porcelain --untracked-files=all`, existing leaf files only, `.md` dropped, `(Get-Content -LiteralPath <path>).Count` per path.
EXIT_CODE: 0

Output Summary:
- 29 paths; maximum 484 lines; all at most 500.
- .devcontainer/post-create.sh 324
- .github/codex/codex-web-setup.sh 332
- .github/workflows/_poshqc.yml 185
- extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.CoverageMerge.psm1 156
- extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 33
- extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 160
- extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Shard.psm1 165
- extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 484
- extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 37
- scripts/host-tools.manifest.json 28
- scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1 156
- scripts/powershell/PoshQC/PoshQC.psd1 33
- scripts/powershell/PoshQC/PoshQC.psm1 160
- scripts/powershell/PoshQC/PoshQC.Shard.psm1 165
- scripts/powershell/PoshQC/PoshQC.Testing.psm1 484 (at most 500; substitution 5: only the 500-line limit applies)
- scripts/powershell/PoshQC/settings/pester.runsettings.psd1 37
- tests/scripts/dev_tools/test_poshqc_bundled_parity.py 84
- tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 348
- tests/scripts/host-tools.manifest.Tests.ps1 168
- tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1 171
- tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 95
- tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 103
- tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 233
- tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 137
- tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 295
- tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 124
- tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1 115
- tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 289
- tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 121
- Required paths present in the set: PoshQC.RunSettings.Tests.ps1, PoshQC.ModuleCoverage.Tests.ps1, PoshQC.Testing.psm1, PoshQC.Tests.ps1 (289), PoshQC.TestingCommands.Tests.ps1 (295): all True.
- Result: PASS (AC-15).
