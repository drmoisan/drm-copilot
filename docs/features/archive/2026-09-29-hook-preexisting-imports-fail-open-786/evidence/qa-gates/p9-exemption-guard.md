# Exemption Guard ([P9-T2])

Timestamp: 2026-10-10T00-36
Command: R-SCOPED over tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
EXIT_CODE: 0
Output Summary: PassedCount 10, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0. The repository and mirror rows of G1, G2, and G3 and the rows GF1 to GF4 appear on PASSED: lines. G2 now passes because the #690 copies were migrated (Phases 5 and 6) and H7 and H8 were converted (Phase 8).

```text

Starting discovery in 1 files.
Discovery found 10 tests in 123ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-import-failure-exemptions.Guard.Tests.ps1 10.55s (10.18s|271ms)
Tests completed in 10.56s
Tests Passed: 10, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 10
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | result=Passed | passed=10 | failed=0
PASSED: G1: repository finds every named handler exemption at its handler site
PASSED: G1: mirror finds every named handler exemption at its handler site
PASSED: G2: repository reports no scoped import-failure handler outside the named-exemption list
PASSED: G2: mirror reports no scoped import-failure handler outside the named-exemption list
PASSED: G3: repository finds the deny code of every named handler exemption in its deny path
PASSED: G3: mirror finds the deny code of every named handler exemption in its deny path
PASSED: GF1: reports a named exemption whose handler site no longer exists
PASSED: GF2: reports a scoped import-failure handler that is not in the named-exemption list
PASSED: GF3: reports a named exemption whose deny code no longer appears in its deny path
PASSED: GF4: does not report a conforming named exemption
```
