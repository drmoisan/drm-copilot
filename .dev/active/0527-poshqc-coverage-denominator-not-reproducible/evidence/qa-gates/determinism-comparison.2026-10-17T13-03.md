# Determinism Comparison, Runs A, B, C (round 2, P2-T4)

Timestamp: 2026-10-17T13-03
Command: sh SCRATCH/issue-527-launch-compare.sh run-a,run-b,run-c (compares `SCRATCH/run-a`, `SCRATCH/run-b`, `SCRATCH/run-c`; this artifact supersedes `determinism-comparison.2026-10-02T08-45.md` by sorting last; the older file is not edited)
EXIT_CODE: 0
Output Summary: the three local runs agree. KEY_SET_EQUAL is True for B and C against A, PER_FILE_DIFF_COUNT is 0 for both, ROOT_LINE_TOTAL is 19095 in all three, and SUM_FILE_TOTALS equals ROOT_LINE_TOTAL in each run. File count is 215 and KEY_SHA256 is identical across A, B, and C.

| Run | Current directory | Files | ROOT_LINE_TOTAL | SUM_FILE_TOTALS | KEY_SHA256 | JUnit failures |
| --- | --- | --- | --- | --- | --- | --- |
| A | `<ROOT>` | 215 | 19095 | 19095 | 08ab3a8d86d003c06f1baa8276fccd32c7d0acc0c11254f90f6c218b118449a5 | 0 |
| B | `<ROOT>/tests/scripts` | 215 | 19095 | 19095 | 08ab3a8d86d003c06f1baa8276fccd32c7d0acc0c11254f90f6c218b118449a5 | 0 |
| C | `SCRATCH/run-c-cwd` (outside the repository tree) | 215 | 19095 | 19095 | 08ab3a8d86d003c06f1baa8276fccd32c7d0acc0c11254f90f6c218b118449a5 | 0 |

```text
== COMPARE run-b AGAINST run-a
KEY_SET_EQUAL=True
PER_FILE_DIFF_COUNT=0
KEYS_ONLY_IN_FIRST=0
KEYS_ONLY_IN_OTHER=0
LINE_TOTAL_DIFFERING_FILES=0
ROOT_LINE_TOTAL_EQUAL=True
== COMPARE run-c AGAINST run-a
KEY_SET_EQUAL=True
PER_FILE_DIFF_COUNT=0
KEYS_ONLY_IN_FIRST=0
KEYS_ONLY_IN_OTHER=0
LINE_TOTAL_DIFFERING_FILES=0
ROOT_LINE_TOTAL_EQUAL=True
PROCESS_EXIT=0
```

Basis: `KEY_SHA256` is the SHA-256 of the ordinally sorted `package|sourcefile` key list, joined by LF, with each package attribute normalized to a repository-relative path. The round 2 spec revision records the CI merged report at 215 files and a LINE total of 19095 for the same tree; the CI comparison is the pending leg recorded in `ci-leg-pending.2026-10-17T13-03.md`.
