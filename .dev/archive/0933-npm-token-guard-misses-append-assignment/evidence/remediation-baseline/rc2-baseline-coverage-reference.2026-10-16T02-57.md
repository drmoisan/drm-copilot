# rc2 Baseline Coverage Reference (P0-T13)

Timestamp: 2026-10-16T02-57
Command: grep -h -F -e "line coverage " -e "branch coverage " -e " passed, " docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-pytest-coverage.2026-10-16T01-47.md docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-coverage-percentages.2026-10-16T01-47.md
EXIT_CODE: 0
Output Summary: five lines, verbatim:

```text
line coverage 93.79748270779 is below the required floor 100.0.
branch coverage 88.11243718592965 is below the required floor 100.0.
================= 7104 passed, 6 skipped in 148.60s (0:02:28) =================
line coverage 93.79748270779 is below the required floor 100.0.
branch coverage 88.11243718592965 is below the required floor 100.0.
```

BaselineLinePercent: 93.79748270779
BaselineBranchPercent: 88.11243718592965
ReferencePassedCount: 7104
ReferenceSkippedCount: 6

Note: the baseline is read from the recorded runs rather than re-measured, because no executable line changes in this cycle and decision D6 fixes the floor to the item's original pre-change values.
