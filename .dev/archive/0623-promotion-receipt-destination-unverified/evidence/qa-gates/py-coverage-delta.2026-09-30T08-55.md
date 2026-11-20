# Python Coverage Delta (#623)

Timestamp: 2026-09-30T08-55
Command: grep -n -F -e "<literal>" "scripts/dev_tools/potential_to_issue.py" (four literals); NODE-PYCOV against artifacts/python/coverage.json (produced by P8-T5 pass 2) with trailing arguments 469 470 471 472
EXIT_CODE: 0
Output Summary: Post-change potential_to_issue.py coverage is not lower than baseline on either metric. `executed=` lists all four changed lines (469,470,471,472); `missing_branches_from=` is empty, so no missing branch starts at line 469.

## Changed-line greps (each printed exactly one line)

```
469:    if not filesystem.exists(dest_path):
470:        _emit(f"Promoted file missing after move: {dest_path}")
471:        return PromotionOutcome(exit_code=1, messages=messages)
472:    _emit(f"Moved potential file to promoted folder: {dest_path}")
```

## Baseline (P0-T18) vs post-change (P8-T5)

| File | Metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- | --- |
| potential_to_issue.py | line | 190/200 = 95.00% | 177/178 = 99.44% | +4.44 |
| potential_to_issue.py | branch | 54/66 = 81.82% | 49/54 = 90.74% | +8.92 |
| potential_to_issue_filesystem.py (new) | line | n/a | 31/31 = 100.00% | n/a |
| potential_to_issue_filesystem.py (new) | branch | n/a | 14/14 = 100.00% | n/a |
| TOTAL | line | 15811/16937 = 93.35% | 15829/16946 = 93.41% | +0.06 |
| TOTAL | branch | 5270/6106 = 86.31% | 5279/6108 = 86.43% | +0.12 |

New/changed-code coverage: potential_to_issue.py lines 469-472, 4 of 4 executed (100%), with no missing branch from line 469; the new module is fully covered (lines and branches).

## NODE-PYCOV output (verbatim)

```
scripts/dev_tools/potential_to_issue.py lines=177/178 branches=49/54 executed=469,470,471,472 missing_branches_from=
scripts/dev_tools/potential_to_issue_filesystem.py lines=31/31 branches=14/14
TOTAL lines=15829/16946 branches=5279/6108
```
