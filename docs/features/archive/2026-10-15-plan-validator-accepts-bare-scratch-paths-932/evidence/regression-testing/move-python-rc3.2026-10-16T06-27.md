# Python Declaration Move (Remediation Cycle 3)

Timestamp: 2026-10-16T06-27
Task: [P2-T2]
Command: poetry run python SCRATCH/stage/move_whitespace_class.py python
EXIT_CODE: 0
Output Summary: `PYTHON_DECLARATIONS: scratch=0 commands=1`. No `ANCHOR_NOT_FOUND:` line.

Effect (`git diff --stat` after the run): `scripts/dev_tools/plan_gate_commands.py` +35 lines; `scripts/dev_tools/plan_gate_scratch.py` -9 lines (the six-line comment block and the three declaration lines, formerly lines 73-81). The declaration lines were inserted verbatim after `split_plan_lines`, followed by `_PLAN_WHITESPACE_RUN_RE` and `normalize_plan_whitespace`.

Grep tool counts on `scripts/dev_tools/plan_gate_commands.py` (output mode `count`):

| Pattern | Count |
| --- | --- |
| `^PLAN_WHITESPACE_CLASS = \(` | 1 |
| `^def normalize_plan_whitespace\(` | 1 |
| raw-character pattern from Conventions | 0 |
| line count `^` | 438 (403 before; at most 500) |
