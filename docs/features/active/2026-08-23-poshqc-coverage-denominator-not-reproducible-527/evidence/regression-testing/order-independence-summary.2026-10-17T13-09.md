# Order Independence Summary (round 2, P4-T4)

Timestamp: 2026-10-17T13-09
Command: sh SCRATCH/issue-527-launch-compare.sh run-a,shuffle-527,shuffle-1017,shuffle-20261017
EXIT_CODE: 0
Output Summary: for each of the three shuffled runs against run A, KEY_SET_EQUAL is True, PER_FILE_DIFF_COUNT is 0, and ROOT_LINE_TOTAL equals run A (19095). Each shuffled run reports 0 JUnit failures and population source `config` (215 files). AC-19 inputs are met: three recorded seeds, three distinct file orders, zero failures in each, same normalized key set and root LINE total as the unshuffled run.

| Run | Seed | JUnit failures | Files | ROOT_LINE_TOTAL | KEY_SET_EQUAL vs run A | PER_FILE_DIFF_COUNT |
| --- | --- | --- | --- | --- | --- | --- |
| run-a (unshuffled, scan-folder order) | n/a | 0 | 215 | 19095 | reference | reference |
| shuffle-527 | 527 | 0 | 215 | 19095 | True | 0 |
| shuffle-1017 | 1017 | 0 | 215 | 19095 | True | 0 |
| shuffle-20261017 | 20261017 | 0 | 215 | 19095 | True | 0 |

```text
== COMPARE shuffle-527 AGAINST run-a
KEY_SET_EQUAL=True
PER_FILE_DIFF_COUNT=0
KEYS_ONLY_IN_FIRST=0
KEYS_ONLY_IN_OTHER=0
LINE_TOTAL_DIFFERING_FILES=0
ROOT_LINE_TOTAL_EQUAL=True
== COMPARE shuffle-1017 AGAINST run-a
KEY_SET_EQUAL=True
PER_FILE_DIFF_COUNT=0
KEYS_ONLY_IN_FIRST=0
KEYS_ONLY_IN_OTHER=0
LINE_TOTAL_DIFFERING_FILES=0
ROOT_LINE_TOTAL_EQUAL=True
== COMPARE shuffle-20261017 AGAINST run-a
KEY_SET_EQUAL=True
PER_FILE_DIFF_COUNT=0
KEYS_ONLY_IN_FIRST=0
KEYS_ONLY_IN_OTHER=0
LINE_TOTAL_DIFFERING_FILES=0
ROOT_LINE_TOTAL_EQUAL=True
PROCESS_EXIT=0
```
