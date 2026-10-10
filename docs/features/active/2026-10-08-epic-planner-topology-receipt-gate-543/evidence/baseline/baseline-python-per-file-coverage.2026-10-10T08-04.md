# Baseline Python Per-File Coverage (Issue #543)

Timestamp: 2026-10-10T08-04
Task: [P0-T11]
Command: poetry run coverage json --data-file=artifacts/.coverage --include="*validate_epic_planner_state.py" --pretty-print -o artifacts/python/coverage-543-topology-baseline.json
EXIT_CODE: 0
Output Summary:
- JSON key: `scripts\dev_tools\validate_epic_planner_state.py` (written to the gitignored intermediate `artifacts/python/coverage-543-topology-baseline.json`).
- Line coverage: covered_lines 166 / num_statements 181 = 91.71%
- Branch coverage: covered_branches 79 / num_branches 94 = 84.04%
- missing_lines: [121, 127, 143, 144, 149, 150, 152, 154, 156, 189, 227, 236, 238, 255, 324]
- missing_branches: [[120, 121], [126, 127], [142, 143], [148, 149], [151, 152], [153, 154], [155, 156], [169, 173], [184, 189], [211, 209], [226, 227], [235, 236], [237, 238], [250, 255], [323, 324]]
- Thresholds: line 91.71 >= 85.00 and branch 84.04 >= 75.00; the baseline stop condition does not trigger.
