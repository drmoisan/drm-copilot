# Python Coverage Totals Baseline (P0-T20)

Timestamp: 2026-10-13T00-14
Command: poetry run python -c "import json,sys;s=json.load(open(sys.argv[1]))['totals'];print('TOTAL line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2))" artifacts/scratch-903/py-coverage-baseline-903.json
EXIT_CODE: 0
BASE: fd81a43b45de65078236da6c1cbfd077c3eb010c
Source: artifacts/scratch-903/py-coverage-baseline-903.json (written by P0-T19; not committed)

Output:
```
TOTAL line 93.8 branch 88.11
```

Baseline-Line: 93.8
Baseline-Branch: 88.11

Output Summary: Whole-repo Python baseline line coverage 93.8% and branch coverage 88.11%, read from the printed `TOTAL line ... branch ...` line. Both exceed the 85% line and 75% branch floors.
