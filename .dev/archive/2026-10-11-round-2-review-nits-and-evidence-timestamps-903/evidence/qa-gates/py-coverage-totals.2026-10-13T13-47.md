# Python Coverage Totals (P12-T5)

Timestamp: 2026-10-13T13-47
Command: poetry run python -c "import json,sys;s=json.load(open(sys.argv[1]))['totals'];print('TOTAL line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2))" artifacts/scratch-903/py-coverage-final-903.json; poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/scratch-903/py-coverage-final-903.json --min-line 85 --min-branch 75
EXIT_CODE: 0
HEAD: 4e8d9f92d63c686f64f9f97e975448dc126c92f1
Loop-Iteration: 2
Source: artifacts/scratch-903/py-coverage-final-903.json (written by P12-T4 iteration 2; not committed)

Extraction output (exit 0):
```
TOTAL line 93.8 branch 88.11
```

Threshold command output (exit 0): no output (the command prints nothing on success).

Post-Total-Line: 93.8
Post-Total-Branch: 88.11
Baseline-Line (P0-T20): 93.8
Baseline-Branch (P0-T20): 88.11

Output Summary: PASS. Whole-repo Python line coverage 93.8% and branch coverage 88.11%, equal to the P0-T20 baseline and above the 85%/75% floors. Threshold check exited 0 with no output.
