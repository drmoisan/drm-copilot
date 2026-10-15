# P4-T10 Probe harness rows and the guard row for the harness suite

Timestamp: 2026-10-09T03-30
Command: Route C: CR-PESTER-LIST over N5 (empty patterns); CR-PESTER-LIST over N2 with the AC-4 pattern for the N5 path via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
RUN-1 (N5, empty patterns)
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | Passed=10 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
TOTAL: Passed=10 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
RUN-2 (N2, pattern AC-4 for the N5 path)
NAMED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1* | Passed=1 | Failed=0 | Total=1
RUN-2-EXIT_CODE_COMPUTED: 1
