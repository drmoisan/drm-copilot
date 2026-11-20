# Phase 2 [expect-fail] Regression Run — Issue #272

Timestamp: 2026-07-02T18-52
Command: `mcp__drm-copilot__run_poshqc_test` (scan folder: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`), confirmed in detail via a direct `Invoke-Pester -Configuration $config` run against the same test file (same Pester v5.x engine; the MCP tool's own summary does not print per-test failure detail).
EXIT_CODE: 2 (MCP tool call) / non-zero (direct Pester confirmation call)
Output Summary: 46 passed, 2 failed, against the unmodified `.claude/hooks/enforce-pr-author-skill.ps1`. The two new `It` blocks added in P2-T1/P2-T2 (`Context 'orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED)'`) both fail with:

```
CommandNotFoundException: Could not find Command Invoke-OrchestratorStatePreflight
```

Failing test names:
- `orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED).blocks gh pr create --body-file when the checkpoint is missing`
- `orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED).blocks gh pr create --body-file with the summarized output when --require-complete fails`

This confirms neither an `Invoke-OrchestratorStatePreflight` function nor the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` reason code exists yet in the unmodified hook, satisfying the Phase 2 `[expect-fail]` requirement before the Phase 3 minimal fix is implemented. All 46 pre-existing tests continued to pass unmodified.
