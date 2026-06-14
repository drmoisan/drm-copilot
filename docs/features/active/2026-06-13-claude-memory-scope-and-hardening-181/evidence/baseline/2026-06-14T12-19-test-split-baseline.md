# Baseline — Issue #181 Test-Only Split (remediation-loop tests)

Timestamp: 2026-06-14T12-19

## Scope
Test-only hardening for issue #181 (Option 1: split test module).
- Production files touched: 0
- Test files touched: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` (split)
- New test file: `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py`

## Pre-change line counts
Command: `wc -l`
- `tests/scripts/dev_tools/test_validate_orchestrator_state.py`: 498
- `scripts/dev_tools/validate_orchestrator_state.py`: 416 (production, must remain unchanged)

## Black
Command: `poetry run black --check tests/scripts/dev_tools/test_validate_orchestrator_state.py scripts/dev_tools/validate_orchestrator_state.py`
EXIT_CODE: 0
Output Summary: 2 files would be left unchanged.

## Ruff
Command: `poetry run ruff check tests/scripts/dev_tools/test_validate_orchestrator_state.py scripts/dev_tools/validate_orchestrator_state.py`
EXIT_CODE: 0
Output Summary: All checks passed!

## Pytest + coverage (validator module)
Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py --cov=scripts.dev_tools.validate_orchestrator_state --cov-branch --cov-report=term-missing -q`
EXIT_CODE: 0
Output Summary: 14 passed. validate_orchestrator_state.py coverage 82% (line+branch).
Missing lines include 198, 203, 210-211 — the malformed-`cycles` paths targeted by the new negative tests.

## Validator behavior verification (no production defect)
Confirmed in `scripts/dev_tools/validate_orchestrator_state.py`:
- Lines 209-211: non-dict cycle entry appends "Checkpoint remediation cycle #{index} must be an object."
- Lines 202-203: `if not isinstance(cycles, list): return errors` — non-list `cycles` (string or dict) produces no cycle errors (intentional pass-through).
Behavior matches the task description. No production change required.
