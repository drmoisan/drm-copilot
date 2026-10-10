# P2-T16 Predicate rows after the CR-2 and CR-3 fixes

Timestamp: 2026-10-09T03-09
Command: Route C: CR-PESTER-LIST over N3 and N3b with the twelve AC-8 through AC-13 patterns against the hardened EpicStateIsolation.Helpers.ps1 via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | Passed=10 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | Passed=10 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
NAMED: AC-8 non-compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-8 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-9 non-compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-9 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-10 non-compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-10 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-11 non-compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-11 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-12 non-compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-12 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-13 non-compliant* | Passed=7 | Failed=0 | Total=7
NAMED: AC-13 compliant* | Passed=3 | Failed=0 | Total=3
TOTAL: Passed=20 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
AC-13-ROWS-FIXED: AC-13 non-compliant parse error returned as a finding
