# Final Python Per-File Coverage (Issue #543)

Timestamp: 2026-10-10T08-17
Task: [P7-T6]
Loop iteration: 1
Command: poetry run coverage json --data-file=artifacts/.coverage --include="*validate_epic_planner_state.py" --pretty-print -o artifacts/python/coverage-543-topology-final.json
EXIT_CODE: 0
Output Summary:
- JSON key: `scripts\dev_tools\validate_epic_planner_state.py` (gitignored intermediate `artifacts/python/coverage-543-topology-final.json`).
- Line coverage: covered_lines 167 / num_statements 182 = 91.76%
- Branch coverage: covered_branches 81 / num_branches 96 = 84.38%
- missing_lines: [121, 127, 143, 144, 149, 150, 152, 154, 156, 189, 227, 236, 238, 255, 326]
- missing_branches: [[120, 121], [126, 127], [142, 143], [148, 149], [151, 152], [153, 154], [155, 156], [169, 173], [184, 189], [211, 209], [226, 227], [235, 236], [237, 238], [250, 255], [325, 326]]
- Thresholds met: line 91.76 >= 85.00; branch 84.38 >= 75.00.
