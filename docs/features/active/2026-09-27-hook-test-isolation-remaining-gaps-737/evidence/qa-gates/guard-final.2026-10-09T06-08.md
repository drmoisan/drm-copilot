# P10-T2 Final guard run on the current population

Timestamp: 2026-10-09T06-08
Command: Route C: CR-ENUM, then CR-PESTER-LIST over N2 and N5 with the AC-4, AC-6 and AC-7 patterns via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
POPULATION-SURFACE: tests/scripts/claude-hooks | suites=130
POPULATION-SURFACE: tests/scripts/codex-hooks | suites=52
POPULATION-TOTAL: 182
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | Passed=290 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | Passed=10 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
NAMED: AC-4 * | Passed=190 | Failed=0 | Total=190
NAMED: AC-6 * | Passed=95 | Failed=0 | Total=95
NAMED: AC-6 probe* | Passed=2 | Failed=0 | Total=2
NAMED: AC-6 suite* | Passed=2 | Failed=0 | Total=2
NAMED: AC-6 helper* | Passed=4 | Failed=0 | Total=4
NAMED: AC-7 * | Passed=4 | Failed=0 | Total=4
TOTAL: Passed=300 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
