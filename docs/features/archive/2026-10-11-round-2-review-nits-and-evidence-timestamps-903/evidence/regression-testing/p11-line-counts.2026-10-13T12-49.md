# P11-T12 Phase 11 line counts

Timestamp: 2026-10-13T12-49
Command: wc -l <six files edited in P11-T1 to P11-T9> (run against <worktree>)
EXIT_CODE: 0
Output Summary:
- Every file is at most 500 lines. `PublishMcpNpmWorkflow.Tests.ps1` is 270 lines (P11-T9 limit: at most 300).

| Lines | File |
|---|---|
| 267 | tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 |
| 81 | tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1 |
| 179 | tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1 |
| 268 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 |
| 150 | tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 |
| 270 | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 |
