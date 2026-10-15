# PowerShell Test (P12-T14)

Timestamp: 2026-10-13T13-18
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]
EXIT_CODE: 7
HEAD: 92e85dd747c6cbabda41de18c0637c3139cb0414
Loop-Iteration: 1

EXIT_CODE is the MCP call disposition only. CI (P12-T22 and P12-T23) governs test results.

## MCP result (verbatim, worktree path redacted)

```
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "<worktree>",
  "summary": "Command exited with code 7."
}
```

## Acceptance deviation

ACCEPTANCE-DEVIATION: the task acceptance requires `"ok":true` or the P0-T29 disposition (`"ok":true`). This call returned `"ok":false` (exit 7). Per the orchestrator directive for segment 4, the result is recorded as call disposition only and is not remediated in this segment: the seven failures are the known #737 F-2 Discovery-guard findings, which the plan routes to CI (P12-T23) and the P12-T27 withhold decision. The flagged suites were not edited and the P12-T27 withhold was not applied here.

## Supplementary local observation (not an acceptance input)

- Local JUnit (`artifacts/pester/pester-junit.xml`, git-ignored, written by this call) summary: `tests="9414" errors="0" failures="7" disabled="1"`.
- The seven failing testcases are all rows of `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (`discovery guard (both hook surfaces).AC-4 <suite> complies with the baseline isolation form for every closure seam`) for these suites:
  - `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`
  - `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`
  - `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`
  - `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`
  - `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`
  - `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
  - `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`
- This set is identical to the set recorded in `evidence/regression-testing/p10-ps-test.2026-10-13T12-45.md` and `p11-ps-test.2026-10-13T13-00.md`. No new failure since Phase 10.

Output Summary: Call disposition `"ok":false` (exit 7). Local JUnit: 9414 tests, 7 failures, all the known F-2 Discovery-guard rows routed to P12-T27. Recorded as an acceptance deviation under the orchestrator directive; CI governs.
