# Final pytest gate compared with the Phase 0 baseline

Timestamp: 2026-11-15T01-16
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term-missing (launcher pytest suite, which runs pytest -n auto)
EXIT_CODE: 0
Output Summary: 16949 passed, 6 skipped, 0 failed in 169.47 s.
Baseline: 16941 passed, 6 skipped, 0 failed. Difference: +8 tests (the new workflow contract tests), no new failing test.
Total coverage (TOTAL row): 35910 statements, 810 missed, 13688 branches, 552 partial, 97%. Baseline: 35910 statements, 810 missed, 13688 branches, 551 partial, 97%. Statement, miss, and branch counts are identical, so line coverage (97.74%) and the rounded total are unchanged; the partial-branch count differs by one in code this feature does not change (no Python production file is edited), a run-to-run difference of the parallel runner. The combined total stays at 97%, above the 85% line floor and the 75% branch floor (the term-missing table prints one combined figure; the per-type figures are read from the JSON report in CI by the unchanged threshold step).
Comparison: no new failing test, no repo-wide line coverage drop, no per-file figure to compare because no Python production file changed. The JSON threshold step (85 line, 75 branch) is unchanged in the workflow.
