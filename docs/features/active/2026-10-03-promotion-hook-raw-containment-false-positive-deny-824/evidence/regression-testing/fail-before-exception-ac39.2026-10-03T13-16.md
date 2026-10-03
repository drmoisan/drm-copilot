# Fail-before exception dossier — AC-39 (review note B, issue #824)

Timestamp: 2026-10-03T13-16
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p5-t20.ps1 -Worktree WORKTREE (the P1-T12 WHY-COUNT check, run after this dossier was written)
EXIT_CODE: 0
Output Summary: the dossier carries exactly one line that begins with the WhyFailingRunImpossible key (WHY-COUNT=1).

WhyFailingRunImpossible: AC-39 narrows an existing test's search scope. At BASE_SHA 079ebb9fad8fab1ee24e137e5bc605fc1df1948a neither feature-review agent copy contains `80%` or `90%`, so the old and the narrowed assertion both pass and no failing run of the production text exists.

Alternative proof:

- `test_retired_threshold_scan_reads_coverage_context_only` (run in P5-T19, FEATURE/evidence/other/r1-p5-t19.2026-10-03T13-16.md, `81 passed`) shows that `80%` in a paragraph without `coverage` is not flagged and `80%` in a paragraph containing `coverage` is flagged.
- The P5-T19 numstat (`31	1`) shows that only one existing line of the test file (former line 393) changed.

SearchScope: FEATURE/evidence/regression-testing/
SearchPatterns: `fail-before-exception*.md`
SearchResult: FEATURE/evidence/regression-testing/fail-before-exception-ac39.2026-10-03T13-16.md (this dossier); FEATURE/evidence/regression-testing/fail-before-exception.2026-10-03T13-03.md (the P1-T12 dossier)
