# Python Test Baseline (P0-T8)

- Timestamp: 2026-07-02T19-35
- Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools`
- EXIT_CODE: 0

## Output Summary

`1157 passed, 19 skipped in 7.76s` (skips are pre-existing, documented `.codex`/`.agents`
gitignored-environment skips unrelated to this feature).

Baseline coverage over `scripts.dev_tools` (via `coverage json`):

- Line coverage (`percent_statements_covered`): 86.02% (7606 covered statement lines of
  8842, plus 226 excluded lines).
- Branch coverage (`percent_branches_covered`): 75.36% (2380 covered branches of 3158;
  440 partial).
- Combined pytest-cov "Cover" column total (statements+branches blended): 83%.

Both the 85% line-coverage floor and the 75% branch-coverage floor from
`.claude/rules/quality-tiers.md` are met at baseline (line coverage is 86.02%, just above
the 85% floor; branch coverage is 75.36%, just above the 75% floor). This baseline is
recorded for delta comparison in P6-T5.
