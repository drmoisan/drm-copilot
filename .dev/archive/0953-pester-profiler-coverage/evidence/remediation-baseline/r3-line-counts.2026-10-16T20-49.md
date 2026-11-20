# r3 Line Counts (P0-T12)

Timestamp: 2026-10-16T20-49
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; foreach ($p in @(<the nine paths below>)) { "LINES: $p $((Get-Content -LiteralPath $p).Count)" }' (SCRATCH/issue-953-r3-p0-t12.sh)
EXIT_CODE: 0
Output Summary:
- All nine counts equal the planning-time values. Result: PASS.

LINES: scripts/powershell/PoshQC/PoshQC.Shard.psm1 256
LINES: scripts/powershell/PoshQC/PoshQC.Testing.psm1 479
LINES: scripts/powershell/PoshQC/README.md 98
LINES: tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 172
LINES: tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1 162
LINES: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 114
LINES: tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1 179
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 203
LINES: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 434
