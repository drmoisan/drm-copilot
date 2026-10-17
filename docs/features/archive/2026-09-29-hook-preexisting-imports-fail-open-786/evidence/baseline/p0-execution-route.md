# Execution Route ([P0-T3])

Timestamp: 2026-10-09T21-52
Command: sh <SCRATCHPAD>/p0-probe.sh tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 (route sh; the probe script <SCRATCHPAD>/p0-probe.ps1 is the R-SCOPED body; launched through the generic route wrapper <SCRATCHPAD>/r.sh, which runs `pwsh -NoProfile -File <SCRATCHPAD>/<name>.ps1` from the worktree root)
EXIT_CODE: 0
Output Summary: route `sh` ran; PassedCount: 2, FailedCount: 0, FailedBlocksCount: 0, FailedContainersCount: 0.

ROUTE-ATTEMPT: sh | ran
ROUTE_SELECTED: sh

Notes: route `pwsh-file` was not attempted because route `sh` ran first. The Bash isolation guard refused command lines that combined `sh` with redirection or `echo`, and a separate PreToolUse hook refuses a `cd`-chained `grep`/`cat`; the accepted invocation form is `cd <WORKSPACE_ROOT> && sh <SCRATCHPAD>/r.sh <name> <arguments>`, where `r.sh` writes the script output to `<SCRATCHPAD>/<name>.out` and prints `EXIT=<code>`.

Probe output:

```text

Starting discovery in 1 files.
Discovery found 2 tests in 134ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 583ms (106ms|366ms)
Tests completed in 599ms
Tests Passed: 2, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 2
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | result=Passed | passed=2 | failed=0
PASSED: keeps all four surface copies of the helpers module byte-identical by SHA256 hash
PASSED: keeps every surface copy of the helpers module under the 500-line cap
```
