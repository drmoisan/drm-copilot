# CI Gate Manifest Test Before Manifest Entry (P1-T19) [expect-fail]

Timestamp: 2026-09-28T22-02
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: The script exited 0 because A2 reports test failures in its output rather than through its exit code. The output shows `TotalCount=2`, `PassedCount=0`, and `FailedCount=2`, so both manifest-membership tests fail before the core.json entry exists. This is the fail-before evidence for AC3.

```text
TotalCount=2
PassedCount=0
FailedCount=2
FAILED: CiGate core.json manifest membership.lists the CI gate parser path in core.json paths
FAILED: CiGate core.json manifest membership.lists the CI gate parser path exactly once
```
