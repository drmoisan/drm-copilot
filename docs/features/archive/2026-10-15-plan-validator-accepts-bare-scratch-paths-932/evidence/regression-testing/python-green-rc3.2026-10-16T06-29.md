# Python Green Run with Coverage (Remediation Cycle 3)

Timestamp: 2026-10-16T06-29
Task: [P2-T5]
Command: poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_commands.py --deselect=tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_matches_typescript --deselect=tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_declared_once_per_runtime --cov=scripts.dev_tools.plan_gate_commands --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: `92 passed, 2 deselected in 0.82s` (0 failed). The four `test_g6_normalization_uses_plan_whitespace_class` nodes (including `nel-only-line` and `nel-joined-line`, red in [P1-T5]) pass.

term-missing rows:

```text
Name                                            Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\plan_gate_commands.py           111      1     40      2    98%   398->400, 405
scripts\dev_tools\plan_gate_discrimination.py     134     17     52      2    87%   129-132, 137-141, 146-151, 213, 252
scripts\dev_tools\plan_gate_scratch.py             52      0     16      0   100%
TOTAL                                             297     18    108      4    93%
```

- `plan_gate_scratch.py`: 100% with an empty `Missing` column.
- `plan_gate_commands.py`: `normalize_plan_whitespace` occupies lines 342-362; none of those lines is in the `Missing` column. The listed `398->400, 405` are the pre-existing baseline misses `363->365, 370` shifted by the 35 inserted lines.
- `plan_gate_discrimination.py`: lines 129-151 are the production git seam, not exercised by this subset (the [P5-T4] full set exercises it); 213 and 252 are the pre-existing baseline misses 212 and 251 shifted by one line (the added import). The changed lines in `_window_join` and `_has_cross_line_presence` are not listed.
- The two deselected nodes read the TypeScript modules changed in Phase 3; [P3-T6] runs them.
