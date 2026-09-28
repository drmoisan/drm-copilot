# Remediation Cycle 1 - P0-T4 Execution Route Probe

Timestamp: 2026-09-27T04-49
Command: sh <SCRATCHPAD>/c1-p0-probe.sh
EXIT_CODE: 0
Output Summary: The rule-3 route works. R-SCOPED over the Parity suite printed PassedCount: 2, FailedCount: 0, FailedBlocksCount: 0, FailedContainersCount: 0, and both PASSED lines.

ROUTE: sh

Launcher line (`<SCRATCHPAD>/c1-p0-probe.sh`):

```text
exec pwsh -NoProfile -File "$(dirname "$0")/c1-p0-probe.ps1"
```

Script: `<SCRATCHPAD>/c1-p0-probe.ps1` dot-sources `<SCRATCHPAD>/c1-rlib.ps1` (R-SCOPED and R-COV-C1 of remediation-plan section 6) and runs R-SCOPED with `Run.Path` = `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`.

Probe output (ANSI color codes removed; worktree root replaced by `<WORKSPACE_ROOT>`):

```text
Starting discovery in 1 files.
Discovery found 2 tests in 132ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 483ms (93ms|283ms)
Tests completed in 505ms
Tests Passed: 2, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 2
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671).keeps all four surface copies of the helpers module byte-identical by SHA256 hash
PASSED: enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671).keeps every surface copy of the helpers module under the 500-line cap
```
