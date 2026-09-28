# Final QA — No New Suppression and No Coverage Exclusion (P6-T8)

Timestamp: 2026-09-27T15-41

Iteration: 1

Command: grep -c -E "noqa|type: ignore|pragma: no cover" tests/scripts/dev_tools/test_blast_radius_regression_452.py

EXIT_CODE: 1

ExpectedExitCode: 1

Output:

```
0
```

Command: git diff --name-only origin/main...HEAD

EXIT_CODE: 0

Output: 42 paths. Three outside the v2 feature folder, all write targets of this plan:

```
tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1
tests/scripts/dev_tools/test_blast_radius_regression_452.py
```

The remaining 39 paths are under docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2 (plan, spec, research, and evidence artifacts).

Command: git status --porcelain

EXIT_CODE: 0

Output:

```
 M docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/plan.2026-09-27T12-15.md
?? docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/evidence/qa-gates/final-python-consumer-coverage.2026-09-27T15-41.md
?? docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/evidence/qa-gates/final-python-pytest-coverage.2026-09-27T15-40.md
?? docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/evidence/qa-gates/final-python-pytest-targeted-coverage.2026-09-27T15-40.md
```

Acceptance evaluation:

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| Suppression count in the consumer | 0 (grep exit 1 expected) | 0, exit 1 | pass |
| pyproject.toml or other coverage configuration in the diff | absent | absent | pass |
| pyproject.toml or other coverage configuration in porcelain | absent | absent | pass |

Output Summary: PASS. Zero noqa, type: ignore, or pragma: no cover markers in the Python consumer. Neither the branch diff against origin/main nor the porcelain capture lists pyproject.toml or any coverage configuration file.
