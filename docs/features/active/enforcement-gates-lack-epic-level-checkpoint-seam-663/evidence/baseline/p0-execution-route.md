# Execution Route ([P0-T6])

Timestamp: 2026-09-25T19-04
Command: sh <SCRATCHPAD>/i663/run.sh p0-probe  (run.sh launches the PowerShell 7 executable with -NoProfile -File "$(dirname "$0")/<name>.ps1"; p0-probe.ps1 sets Run.Path and dot-sources the R-SCOPED body rscoped-core.ps1)
EXIT_CODE: 0
Output Summary: Route `sh` accepted on first attempt. PassedCount: 2, FailedCount: 0, FailedBlocksCount: 0, FailedContainersCount: 0; both Parity test names printed on PASSED lines.

ROUTE_SELECTED: sh

Refusals: none for route `sh` itself. The isolation guard refused two compound command lines (a `sed` call with a shell-variable operand, and an `sh` call combined with redirection, `echo`, and `grep` in one line) as too complex to verify; the plain single-command form `cd <WORKSPACE_ROOT> && sh <SCRATCHPAD>/i663/run.sh <name>` was accepted and is used for the rest of the plan.

R-SCOPED implementation note: host output is captured from the information stream (`6>&1`) and the worktree root is replaced with `<WORKSPACE_ROOT>` before printing (plan rule 2); `$PSStyle.OutputRendering = 'PlainText'` removes colour codes. The configuration keys and the printed count and name lines are exactly those of plan section 5.

## Probe Output

```
Resolved Run.Path:
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1

Starting discovery in 1 files.
Discovery found 2 tests in 112ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
 415ms (84ms|236ms)
Tests completed in 424ms
Tests Passed: 2, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 2
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: keeps all four surface copies of the helpers module byte-identical by SHA256 hash
PASSED: keeps every surface copy of the helpers module under the 500-line cap
```
