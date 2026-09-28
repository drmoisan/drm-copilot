# Phase 0 Baseline — Targeted Blast-Radius Coverage (P0-T24)

Timestamp: 2026-09-27T14-45

Command: poetry run pytest tests --cov=scripts.dev_tools._blast_radius_conflicts --cov=scripts.dev_tools._blast_radius_glob --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_validation --cov=scripts.dev_tools.compute_blast_radius --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json

EXIT_CODE: 0

Command: poetry run python `<scratchpad>`/coverage_totals.py

EXIT_CODE: 0

Term-missing table (exactly the five modules):

```
Name                                            Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------
scripts\dev_tools\_blast_radius_conflicts.py       62      0     22      0   100%
scripts\dev_tools\_blast_radius_extraction.py     101      0     46      0   100%
scripts\dev_tools\_blast_radius_glob.py            58      1     28      1    98%   222
scripts\dev_tools\_blast_radius_validation.py     101      0     32      0   100%
scripts\dev_tools\compute_blast_radius.py          72      0     10      0   100%
-------------------------------------------------------------------------------------------
TOTAL                                             394      1    138      1    99%
====================== 5149 passed, 5 skipped in 13.74s =======================
```

Helper output:

```
GENERATED_AT=2026-09-27T14:39:28.449205
TOTAL_LINE=393/394=99.75
TOTAL_BRANCH=137/138=99.28
FILE _blast_radius_conflicts.py line=100.00 branch=100.00
FILE _blast_radius_extraction.py line=100.00 branch=100.00
FILE _blast_radius_glob.py line=98.28 branch=96.43
FILE _blast_radius_validation.py line=100.00 branch=100.00
FILE compute_blast_radius.py line=100.00 branch=100.00
```

Output Summary: Targeted baseline line 99.75% (393/394), branch 99.28% (137/138). Per-module line/branch: _blast_radius_conflicts 100.00/100.00; _blast_radius_extraction 100.00/100.00; _blast_radius_glob 98.28/96.43; _blast_radius_validation 100.00/100.00; compute_blast_radius 100.00/100.00. 5149 passed, 5 skipped.
