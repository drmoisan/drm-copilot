# P5-T33 Guard pass-after run

Timestamp: 2026-10-09T05-30
Command: Route C: CR-PESTER-LIST over N2 and N5 with the AC-4, AC-6, AC-2, AC-3, AC-5 and AC-7 patterns via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | Passed=288 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | Passed=10 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
NAMED: AC-4 * | Passed=189 | Failed=0 | Total=189
NAMED: AC-6 * | Passed=94 | Failed=0 | Total=94
NAMED: AC-2 * | Passed=6 | Failed=0 | Total=6
NAMED: AC-2 non-vacuity* | Passed=2 | Failed=0 | Total=2
NAMED: AC-2 no hard-coded* | Passed=2 | Failed=0 | Total=2
NAMED: AC-2 missing* | Passed=1 | Failed=0 | Total=1
NAMED: AC-2 unparseable* | Passed=1 | Failed=0 | Total=1
NAMED: AC-3 * | Passed=2 | Failed=0 | Total=2
NAMED: AC-5 * | Passed=3 | Failed=0 | Total=3
NAMED: AC-7 * | Passed=4 | Failed=0 | Total=4
TOTAL: Passed=298 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
