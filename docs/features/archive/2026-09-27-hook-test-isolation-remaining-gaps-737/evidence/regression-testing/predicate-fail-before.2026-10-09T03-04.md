# P2-T8 Predicate rows against the unmodified predicate [expect-fail]

Timestamp: 2026-10-09T03-04
Command: Route C: CR-PESTER-LIST over N3 and N3b with the twelve AC-8 through AC-13 patterns against the unmodified EpicStateIsolation.Helpers.ps1 via pwsh -NoProfile -File
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | Passed=9 | Failed=1 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | Passed=5 | Failed=5 | Skipped=0 | NotRun=0 | ProbeRows=0
NAMED: AC-8 non-compliant* | Passed=0 | Failed=1 | Total=1
NAMED: AC-8 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-9 non-compliant* | Passed=0 | Failed=1 | Total=1
NAMED: AC-9 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-10 non-compliant* | Passed=0 | Failed=1 | Total=1
NAMED: AC-10 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-11 non-compliant* | Passed=0 | Failed=1 | Total=1
NAMED: AC-11 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-12 non-compliant* | Passed=0 | Failed=1 | Total=1
NAMED: AC-12 compliant* | Passed=1 | Failed=0 | Total=1
NAMED: AC-13 non-compliant* | Passed=6 | Failed=1 | Total=7
NAMED: AC-13 compliant* | Passed=3 | Failed=0 | Total=3
FAILED: CR-2 false-pass paths.AC-8 non-compliant ordering against a helper dot-source :: Expected the actual value to be greater than 0, because the import and mock precede the hook dot-source, but got 0.
FAILED: CR-2 false-pass paths.AC-9 non-compliant mock and import only inside a function body :: Expected the actual value to be greater than 0, because a function body that is never invoked does not isolate the suite, but got 0.
FAILED: CR-2 false-pass paths.AC-10 non-compliant second top-level Describe lacks isolation :: Expected the actual value to be greater than 0, because every top-level BeforeAll must isolate, not only the first, but got 0.
FAILED: CR-2 false-pass paths.AC-11 non-compliant later non-null Mock of the same seam :: Expected the actual value to be greater than 0, because a later non-null Mock of the same seam overrides the null Mock, but got 0.
FAILED: CR-2 false-pass paths.AC-12 non-compliant module file name only in a non-import argument :: Expected the actual value to be greater than 0, because a string that merely contains the file name is not an import path, but got 0.
FAILED: CR-3 predicate branches.AC-13 non-compliant parse error returned as a finding :: The term 'Get-EpicStateIsolationTextFinding' is not recognized as a name of a cmdlet, function, script file, or executable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
TOTAL: Passed=14 | Failed=6 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
