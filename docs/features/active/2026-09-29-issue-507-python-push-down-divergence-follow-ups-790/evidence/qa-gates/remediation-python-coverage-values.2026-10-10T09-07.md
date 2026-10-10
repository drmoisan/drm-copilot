# P2-T5 Python Per-Module Numeric Line and Branch Coverage (final)

Timestamp: 2026-10-10T09-07
Command: poetry run python -c "<JSON summary reader over artifacts/python/coverage-790-remediation.json; prints LINE and BRANCH per AC-22 module>"; poetry run python -c "<filesystem FS_BRANCHES detail reader>"
EXIT_CODE: 0
Output Summary:
Loop iteration 1. Both commands exit 0.

First command output:
```
scripts/dev_tools/push_down_claude_filesystem.py LINE 92.92 BRANCH 78.57
scripts/dev_tools/push_down_claude_gitignore_merge.py LINE 100.0 BRANCH 100.0
scripts/dev_tools/push_down_claude_customizations.py LINE 93.67 BRANCH 87.5
scripts/dev_tools/push_down_claude_pack_selection.py LINE 93.98 BRANCH 83.33
```
Second command output:
```
FS_BRANCHES 22 OF 28 MISSING [122, 128, 135, 145, 148, 182, 183, 326]
```
Covered branches 22 (>= 21) of 28; MISSING contains none of 407, 409, 410, 411, 412, 413, 414.

Baseline (P0-T7) versus final versus delta:

| Module | Baseline LINE | Baseline BRANCH | Final LINE | Final BRANCH | Delta LINE | Delta BRANCH |
|---|---|---|---|---|---|---|
| push_down_claude_filesystem.py | 88.5 | 64.29 | 92.92 | 78.57 | +4.42 | +14.28 |
| push_down_claude_gitignore_merge.py | 100.0 | 100.0 | 100.0 | 100.0 | 0.00 | 0.00 |
| push_down_claude_customizations.py | 93.67 | 87.5 | 93.67 | 87.5 | 0.00 | 0.00 |
| push_down_claude_pack_selection.py | 93.98 | 83.33 | 93.98 | 83.33 | 0.00 | 0.00 |

Thresholds: every LINE >= 85 and every BRANCH >= 75. Met.
