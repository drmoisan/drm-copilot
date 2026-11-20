# Final Python Per-File Coverage (P7-T6)

Timestamp: 2026-10-16T01-08
Command: poetry run coverage json --data-file=artifacts/.coverage --include="*validate_epic_planner_state.py" --pretty-print -o SCRATCH/543/coverage-final.json (then read files[key].summary with the SCRATCH reader script)
EXIT_CODE: 0
Loop iteration: 1
Output Summary:
- JSON key: scripts\dev_tools\validate_epic_planner_state.py
- covered_lines/num_statements: 174/188 = 92.55% line (>= 85.00)
- covered_branches/num_branches: 86/100 = 86.00% branch (>= 75.00)
- missing_lines: [121, 127, 143, 144, 149, 150, 152, 154, 156, 189, 271, 280, 282, 346]
- missing_branches: [[120, 121], [126, 127], [142, 143], [148, 149], [151, 152], [153, 154], [155, 156], [169, 173], [184, 189], [211, 209], [270, 271], [279, 280], [281, 282], [345, 346]]
- Baseline (P0-T11): 167/182 = 91.76% line, 81/96 = 84.38% branch. Lines 271, 280, 282, and 346 are the baseline-missing lines 227, 236, 238, and 326 shifted by the edit; baseline-missing line 255 (logical_agent error) is now covered.
