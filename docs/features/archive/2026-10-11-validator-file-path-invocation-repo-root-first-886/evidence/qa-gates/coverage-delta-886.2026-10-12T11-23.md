# Coverage delta (issue #886)

Timestamp: 2026-10-12T11-23

Command: git diff origin/main -U0 -- scripts/dev_tools/validate_orchestration_artifacts.py

EXIT_CODE: 0

Output Summary: coverage for `scripts.dev_tools.validate_orchestration_artifacts`.

| Metric | Baseline (P0-T7) | Post-change (P2-T4) | Delta |
|---|---|---|---|
| Statements | 149 | 149 | 0 |
| Covered lines | 146 | 146 | 0 |
| Line coverage | 97.99% | 97.99% | 0.00 |
| Branches | 56 | 56 | 0 |
| Covered branches | 52 | 52 | 0 |
| Branch coverage | 92.86% | 92.86% | 0.00 |

Changed-code coverage: the diff changes one executable line (line 17, the bootstrap statement; line 16 is a comment). Line 17 is absent from `missing_lines` ([409, 411, 413]) in coverage-final-886.json and from the term-missing `Missing` column (`409, 411, 413, 436->440`), so changed-code line coverage is 1 of 1 executable changed lines covered.
