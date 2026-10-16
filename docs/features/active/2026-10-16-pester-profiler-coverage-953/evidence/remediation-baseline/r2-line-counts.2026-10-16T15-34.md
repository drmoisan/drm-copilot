# r2 baseline line counts (P0-T12)

Timestamp: 2026-10-16T15-34
Command: sh "SCRATCH/issue-953-r2-p0-t12.sh" (pwsh text: foreach ($p in @(<the ten paths below>)) { "LINES: $p $((Get-Content -LiteralPath $p).Count)" })
EXIT_CODE: 0
Output Summary: all ten counts equal the planning-time values; the PLAN_HEAD line citations hold.

LINES: scripts/powershell/PoshQC/PoshQC.Testing.psm1 484
LINES: scripts/powershell/PoshQC/PoshQC.Shard.psm1 165
LINES: scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1 156
LINES: scripts/powershell/PoshQC/README.md 87
LINES: .github/workflows/_poshqc.yml 185
LINES: extensions/drm-copilot/CHANGELOG.md 38
LINES: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 121
LINES: tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 137
LINES: tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1 171
LINES: tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1 115
