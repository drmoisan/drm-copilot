# Baseline Python Per-File Coverage (P0-T11)

Timestamp: 2026-10-16T00-33
Command: poetry run coverage json --data-file=artifacts/.coverage --include="*validate_epic_planner_state.py" --pretty-print -o SCRATCH/543/coverage-baseline.json (then read files[key].summary with a SCRATCH reader script)
EXIT_CODE: 0
Output Summary:
- JSON key: scripts\dev_tools\validate_epic_planner_state.py
- covered_lines/num_statements: 167/182 = 91.76% line
- covered_branches/num_branches: 81/96 = 84.38% branch
- missing_lines: [121, 127, 143, 144, 149, 150, 152, 154, 156, 189, 227, 236, 238, 255, 326]
- missing_branches: [[120, 121], [126, 127], [142, 143], [148, 149], [151, 152], [153, 154], [155, 156], [169, 173], [184, 189], [211, 209], [226, 227], [235, 236], [237, 238], [250, 255], [325, 326]]
- Thresholds: line 91.76 >= 85.00 and branch 84.38 >= 75.00; no stop condition.
