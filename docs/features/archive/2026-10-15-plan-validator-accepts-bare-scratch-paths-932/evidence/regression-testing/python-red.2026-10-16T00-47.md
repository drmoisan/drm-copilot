# Python Red Set — Issue #932

Timestamp: 2026-10-16T00-47
Task: [P1-T8] [expect-fail]
Command: poetry run pytest -v --continue-on-collection-errors tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_parity.py::test_no_repr_formatting_in_gate_messages
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary: `4 failed, 2 passed, 2 errors`. Every failure and error matches an expected signature in the plan.

Collection errors (expected: ModuleNotFoundError for `scripts.dev_tools.plan_gate_scratch`):
- ERROR `tests/scripts/dev_tools/test_plan_gate_scratch.py` — `E   ModuleNotFoundError: No module named 'scripts.dev_tools.plan_gate_scratch'`
- ERROR `tests/scripts/dev_tools/test_scratch_location_contracts.py` — `E   ModuleNotFoundError: No module named 'scripts.dev_tools.plan_gate_scratch'`

Failures (expected):
- FAILED `test_plan_gate_scratch_docs.py::test_rule_file_documents_g10` — `AssertionError: rule file lacks ['| **G10** |', '### G10 — ships as Blocking', ...]`
- FAILED `test_plan_gate_scratch_docs.py::test_atomic_plan_contract_states_shipped_set_through_g10` — `assert 'The complete shipped set is therefore G1 through G10.' in <skill text>`
- FAILED `test_plan_gate_scratch_docs.py::test_discrimination_docstrings_name_g10` — `assert 'G1 through G10' in "Discriminate falsifiable ..."`
- FAILED `test_plan_gate_parity.py::test_no_repr_formatting_in_gate_messages` — `FileNotFoundError: [Errno 2] No such file or directory: '<repo>/scripts/dev_tools/plan_gate_scratch.py'`

Passing (expected):
- PASSED `test_plan_gate_scratch_docs.py::test_rule_file_bundle_copy_is_byte_identical`
- PASSED `test_plan_gate_scratch_docs.py::test_rule_frontmatter_paths_reach_scratch_gate_modules`

First-run note: the first run of this command (same minute) reported the `test_plan_gate_scratch.py` collection error as `ImportError: cannot import name 'plan_gate_scratch' from 'scripts.dev_tools'`, because the [P1-T1] file imported the module object through `from scripts.dev_tools import plan_gate_commands, plan_gate_scratch`. Within [P1-T1]'s scope the test now imports `FENCE_RE` directly from `scripts.dev_tools.plan_gate_scratch` (same assertion: the G10 fence pattern equals the extractor's `_FENCE_RE` pattern), and the rerun recorded above shows the expected `ModuleNotFoundError` signature.

Grep counts recorded for earlier Phase 1 tasks:
- [P1-T1] `tests/scripts/dev_tools/test_plan_gate_scratch.py`, pattern `^def (<13 required names>)\(` — 13.
- [P1-T2] `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`, pattern `^def (<5 required names>)\(` — 5; pattern `^ENFORCEMENT_TOKEN = ` — 1.
- [P1-T4] `tests/scripts/dev_tools/test_scratch_location_contracts.py`: `FORBIDDEN_SCRATCH_PATHS` — 0; `^def scratch_violations\(` — 1; `^def test_scratch_pattern_check_self_test\(` — 1; `^SCRATCHPAD_ROOT_RE = ` — 1. File length 341 lines.
- [P1-T3] `tests/scripts/dev_tools/test_plan_gate_parity.py`: `— currently$` — 0; file length 494 lines; `_PYTHON_GATE_MODULES` has four entries, `plan_gate_scratch.py` last.

SPEC-DEVIATION: NFR-4 docstring reword — `test_plan_gate_parity.py` lines 8–13 were reworded in place (no line added) to name the discrimination, coverage, observability, and scratch modules and to refer to the TypeScript gate modules without a fixed count, in addition to the module-list entry NFR-4 names.
