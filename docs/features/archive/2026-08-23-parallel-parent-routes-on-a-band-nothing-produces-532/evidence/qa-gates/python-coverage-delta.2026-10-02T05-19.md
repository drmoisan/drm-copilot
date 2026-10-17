# Python Coverage Delta (P7-T12)

Timestamp: 2026-10-02T05-19
Command: git diff -U0 74e1d674 -- scripts/dev_tools/validate_parallel_planner_state.py
EXIT_CODE: 0
Output Summary:
scripts/dev_tools/validate_parallel_planner_state.py
Baseline (P0-T16, evidence/baseline/python-pytest-coverage.2026-10-02T04-29.md, artifacts/python/coverage-532-baseline.json): line 112/112 = 100.00%; branch 46/46 = 100.00%
Final (P7-T4, evidence/qa-gates/python-pytest-coverage.2026-10-02T05-19.md, artifacts/python/coverage-532-final.json): line 115/115 = 100.00%; branch 46/46 = 100.00%
Delta: line +0.00 points, branch +0.00 points; final is not below baseline.
New module (P7-T4): scripts/dev_tools/_parallel_planner_state_routing.py line 50/50 = 100.00%; branch 16/16 = 100.00%
Changed hunks (new-side line numbers): 7-11 docstring, 45-47 import of validate_ready_item_routing, 244-246 comment, 362 and 365-367 and 373-375 docstring, 397-400 ready-gate loop body, 426 docstring.
Changed executable lines: 45-47 (import statement), 397 (entry_context assignment), 399 (_validate_ready_item call), 400 (validate_ready_item_routing call); line 398 is a comment.
missing_lines for the file in artifacts/python/coverage-532-final.json: [] (summary missing_lines 0).
Changed executable lines present in missing_lines: 0.
PLAN DEVIATION DEV-1 - the plan's diff anchor b7b4a2dc is executed as the merge-base 74e1d674.
