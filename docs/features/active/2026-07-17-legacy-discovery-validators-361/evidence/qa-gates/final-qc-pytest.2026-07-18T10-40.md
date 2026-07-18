Timestamp: 2026-07-18T10-40
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: 1717 passed, 0 failed. Aggregate post-change coverage
totals (11342 statements, 4242 branches): post-change line coverage =
88.21% (10005/11342 statements covered); post-change branch coverage =
79.02% (3352/4242 branches covered). Both figures were computed from
`coverage json` totals (`percent_statements_covered` and
`percent_branches_covered`) generated immediately after this pytest run
against the same `.coverage` data, for the same reason documented in the
P0-T10 baseline artifact (the combined "Cover" column blends statements and
branches into one figure). Both meet the uniform thresholds (line >= 85%,
branch >= 75%) with no regression against the P0-T10 baseline (88.07% line,
78.87% branch).
