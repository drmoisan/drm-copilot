# Local Coverage and JUnit Baseline, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T10-04
Task: P0-T11 (remediation-plan.2026-10-16T08-40.md)
Command: date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M; date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M; poetry run python -I SCRATCH/jacoco_report.py artifacts/pester/powershell-coverage.xml; poetry run python -I SCRATCH/jacoco_targets.py artifacts/pester/powershell-coverage.xml; poetry run python -I SCRATCH/junit_totals.py artifacts/pester/pester-junit.xml; poetry run python -I SCRATCH/junit_status.py artifacts/pester/pester-junit.xml (run via sh SCRATCH/c2_local_cov.sh from WORKTREE)
EXIT_CODE: 0
Output Summary: Files written at 10-02 and 10-03 UTC (RunStart 09-49). Report line coverage 94.58% (11629 covered, 667 missed, 127 source files). jacoco_targets.py NO_MATCH exit 3 (as in cycle 1: the installed-extension runsettings omit the targets file). JUnit TESTCASES=10490, FAILED=0, SKIPPED=10. L = 10490.
OrchestratorDecision: per-copy coverage read from CI artifact 38885695856; local MCP runner reads installed-extension runsettings

RunStart (from latest poshqc-test-baseline-c2): 2026-10-16T09-49
CoverageFileTime: 2026-10-16T10-02
JUnitFileTime: 2026-10-16T10-03

Printed lines:

```text
--- jacoco_report.py
REPORT line_covered=11629 line_missed=667 line_pct=94.58
SOURCEFILES=127
jacoco_report EXIT=0
--- jacoco_targets.py
NO_MATCH
jacoco_targets EXIT=3
--- junit_totals.py
ROOT_TAG=testsuites
ROOT_TESTS=10490
ROOT_FAILURES=0
ROOT_ERRORS=0
TESTCASES=10490
FAILED=0
SKIPPED=10
junit_totals EXIT=0
--- junit_status.py (no filters)
COUNT_MATCHED=10490
COUNT_PASSED=10480
COUNT_FAILED=0
COUNT_SKIPPED=10
junit_status EXIT=0
```

L: 10490
