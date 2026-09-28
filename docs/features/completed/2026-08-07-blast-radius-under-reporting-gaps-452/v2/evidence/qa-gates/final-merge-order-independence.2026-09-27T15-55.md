# Final QA — Merge-Order Independence (P8-T4)

Timestamp: 2026-09-27T15-55

Execution note: the worktree Bash hook refuses a `cd` chained with `grep`, so each file operand was passed as `<worktree root>`/ followed by the repository-relative path shown below. The files searched are identical; the output prefixes are recorded here in repository-relative form.

Command: grep -c -E 'compute_cohorts|pcoh_compute_cohorts|parallel_cohort|parallel_drift|parallel_mutation|recompute_conflicts_with_observed' tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 1

ExpectedExitCode: 1

```
tests/scripts/dev_tools/test_blast_radius_regression_452.py:0
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1:0
```

Command (positive control): grep -c -E 'conflicts\(|Test-BlastRadiusConflict' tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 0

```
tests/scripts/dev_tools/test_blast_radius_regression_452.py:1
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1:2
```

Acceptance evaluation:

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| Cohort/scheduling call count per file | 0 each | 0 and 0, exit 1 | pass |
| Contention-result call count per file | at least 1 each | 1 and 2 | pass |

Output Summary: PASS. Neither consumer calls cohort scheduling, drift, mutation, or observed-conflict recomputation; both make their verdict assertions on the contention result (conflicts( in Python, Test-BlastRadiusConflict in PowerShell), so they are independent of the #722 merge order (AC-14).
