# r3 Final File Size (P5-T12, AC-15)

Timestamp: 2026-10-16T22-38
Command: git diff --name-only origin/main...HEAD and git status --porcelain --untracked-files=all (Bash tool; the same two listings are recomputed inside the counting script); export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $a = @(git diff --name-only origin/main...HEAD); $b = @(git status --porcelain --untracked-files=all | ForEach-Object { $_.Substring(3) }); $set = @($a + $b | Sort-Object -Unique | Where-Object { (Test-Path -LiteralPath $_ -PathType Leaf) -and -not $_.EndsWith(".md") }); foreach ($p in $set) { "LINES: $p $((Get-Content -LiteralPath $p).Count)" }; ...' (SCRATCH/issue-953-r3-p5-t12.sh)
EXIT_CODE: 0
Output Summary:
- FILES=32 OVER_500=0 (every count is at most 500)
- The set includes all five required paths (INCLUDES ... True for each).
- Result: PASS.

LINES: .devcontainer/post-create.sh 324
LINES: .github/codex/codex-web-setup.sh 332
LINES: .github/workflows/_poshqc.yml 186
LINES: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.CoverageMerge.psm1 163
LINES: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 33
LINES: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 160
LINES: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Shard.psm1 296
LINES: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 479
LINES: extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 37
LINES: scripts/host-tools.manifest.json 28
LINES: scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1 163
LINES: scripts/powershell/PoshQC/PoshQC.psd1 33
LINES: scripts/powershell/PoshQC/PoshQC.psm1 160
LINES: scripts/powershell/PoshQC/PoshQC.Shard.psm1 296
LINES: scripts/powershell/PoshQC/PoshQC.Testing.psm1 479
LINES: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 37
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 206
LINES: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 118
LINES: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 437
LINES: tests/scripts/dev_tools/test_poshqc_bundled_parity.py 84
LINES: tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 348
LINES: tests/scripts/host-tools.manifest.Tests.ps1 168
LINES: tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1 189
LINES: tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 95
LINES: tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 103
LINES: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 233
LINES: tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 223
LINES: tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 295
LINES: tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 124
LINES: tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1 162
LINES: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 289
LINES: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 217
