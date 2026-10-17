# Python Red Run (Remediation Cycle 3) [expect-fail]

Timestamp: 2026-10-16T06-25
Task: [P1-T5]
Command: poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `5 failed, 34 passed in 0.55s`. The failing nodes are exactly the five expected nodes, each with the stated signature.

Failing nodes and first error line:

- `test_plan_gate_scratch_whitespace.py::test_whitespace_class_matches_typescript` FAILED: `KeyError: 'PLAN_WHITESPACE_CLASS'` (`plan_gate_commands` does not declare the class yet).
- `test_plan_gate_scratch_whitespace.py::test_whitespace_class_declared_once_per_runtime` FAILED: `AssertionError: PLAN_WHITESPACE_CLASS declarations differ: {'scripts/dev_tools/plan_gate_commands.py': 0, 'scripts/dev_tools/plan_gate_scratch.py': 1, 'scripts/dev_tools/plan_gate_discrimination.py': 0, 'extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts': 0, 'extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts': 1, 'extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts': 0}` (declaration in both G10 modules, in neither extractor module).
- `test_plan_gate_discrimination_literals.py::test_g6_normalization_uses_plan_whitespace_class[nel-only-line]` FAILED: `AssertionError: assert ([], ['[P2-T1...line token.']) == ([], ['[P2-T1...hat exists.'])` (G6 cross-line warning reported instead of the G5 finding).
- `test_plan_gate_discrimination_literals.py::test_g6_normalization_uses_plan_whitespace_class[nel-joined-line]` FAILED: `AssertionError: assert ([], ['[P2-T1...hat exists.']) == ([], ['[P2-T1...line token.'])` (G5 finding reported instead of the G6 warning).
- `test_plan_gate_scratch_docs.py::test_rule_file_states_g6_whitespace_alignment` FAILED: `AssertionError: rule file lacks ['declared once per runtime', 'G6 uses the same class', 'plan-quotation exoneration, which reads the plan text']`.

Expected-pass nodes observed PASSED (from the `-v` per-node lines):

- `test_g6_normalization_uses_plan_whitespace_class[bom-only-line]` PASSED
- `test_g6_normalization_uses_plan_whitespace_class[bom-joined-line]` PASSED
- Every pre-existing test in the three files PASSED (34 passed in total, including the two byte-order-mark nodes).

Grep counts recorded from the Phase 1 edit tasks:

| Task | File | Pattern | Count |
| --- | --- | --- | --- |
| [P1-T1] | `test_plan_gate_scratch_whitespace.py` | `^def test_whitespace_class_declared_once_per_runtime\(` | 1 |
| [P1-T1] | same | `vars\(plan_gate_commands\)` | 1 |
| [P1-T1] | same | `plan_gate_scratch as plan_gate_scratch` | 0 |
| [P1-T1] | same | line count `^` | 191 (150 before) |
| [P1-T1] | same | raw-character pattern | 0 |
| [P1-T2] | `test_plan_gate_discrimination_literals.py` | `^def test_g6_normalization_uses_plan_whitespace_class\(` | 1 |
| [P1-T2] | same | `id="(nel-only-line\|bom-only-line\|nel-joined-line\|bom-joined-line)"` | 4 |
| [P1-T2] | same | line count `^` | 451 (387 before) |
| [P1-T2] | same | raw-character pattern | 0 |
| [P1-T3] | `test_plan_gate_scratch_docs.py` | `^def test_rule_file_states_g6_whitespace_alignment\(` | 1 |
| [P1-T3] | same | line count `^` | 210 (189 before) |
