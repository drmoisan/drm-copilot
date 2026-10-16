# Local Canonical Coverage and JUnit, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T11-57
Task: P4-T6 (remediation-plan.2026-10-16T08-40.md)
Command: mcp__drm-copilot__run_poshqc_test with workspace_root WORKTREE and no scan_folders (the final-pass P4-T3 call); files read with date -u -r, SCRATCH/jacoco_report.py, SCRATCH/jacoco_targets.py, SCRATCH/junit_totals.py, SCRATCH/junit_status.py (via sh SCRATCH/c2_local_cov.sh from WORKTREE)
EXIT_CODE: 0
Output Summary: Files written at 11-54 (coverage) and 11-56 (JUnit), both at or after RunStart 11-42. Report line coverage 94.58% (11629 covered, 667 missed, 127 source files), at least 85.00. jacoco_targets.py prints NO_MATCH and exits 3, as expected under the OrchestratorDecision. JUnit TESTCASES=10507 = L + 17 (L = 10490 from coverage-local-baseline-c2.2026-10-16T10-04.md), FAILED=0, SKIPPED=10. No run_poshqc_test call follows P4-T3.
OrchestratorDecision: per-copy coverage read from CI artifact 38898218767; local MCP runner reads installed-extension runsettings
RunStart: 2026-10-16T11-42 (from poshqc-test-final-c2.2026-10-16T11-56.md)

## File times

```text
coverage mtime: 2026-10-16T11-54
junit mtime: 2026-10-16T11-56
```

## Command: poetry run python -I SCRATCH/jacoco_report.py artifacts/pester/powershell-coverage.xml

EXIT_CODE: 0

```text
REPORT line_covered=11629 line_missed=667 line_pct=94.58
SOURCEFILES=127
```

## Command: poetry run python -I SCRATCH/jacoco_targets.py artifacts/pester/powershell-coverage.xml

EXIT_CODE: 3

```text
NO_MATCH
```

## Command: poetry run python -I SCRATCH/junit_totals.py artifacts/pester/pester-junit.xml

EXIT_CODE: 0

```text
ROOT_TAG=testsuites
ROOT_TESTS=10507
ROOT_FAILURES=0
ROOT_ERRORS=0
TESTCASES=10507
FAILED=0
SKIPPED=10
```

## Command: poetry run python -I SCRATCH/junit_status.py artifacts/pester/pester-junit.xml (no filters)

EXIT_CODE: 0

```text
COUNT_MATCHED=10507
COUNT_PASSED=10497
COUNT_FAILED=0
COUNT_SKIPPED=10
```

## Acceptance

- Both file times at or after RunStart (11-54 and 11-56 versus 11-42): met.
- `jacoco_report.py` REPORT `line_pct` at least 85.00 (94.58): met.
- `jacoco_targets.py` result recorded as observed (NO_MATCH, exit 3; per-copy values come from P4-T12): met.
- `junit_totals.py` prints `FAILED=0` and `TESTCASES=` equal to L + 17 = 10490 + 17 = 10507: met.
- No coverage configuration edited and no XML copied into `artifacts/pester/`: met.
