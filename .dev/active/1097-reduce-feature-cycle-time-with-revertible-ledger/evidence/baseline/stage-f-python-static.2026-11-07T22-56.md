# Stage F Python Static Baseline

Timestamp: 2026-11-07T22-55
Command: poetry run black --check, poetry run ruff check --no-fix, poetry run pyright over scripts/dev_tools/plan_gate_document.py, scripts/dev_tools/plan_gate_discrimination.py, scripts/dev_tools/validate_orchestration_artifacts.py, tests/scripts/dev_tools/test_plan_gate_document_parity.py, tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py, tests/scripts/dev_tools/test_plan_gate_document_docs.py (from the worktree root, PYTHONPATH set to the worktree's packages/discovery-runtime/src; launcher stored under SCRATCH)
EXIT_CODE: 0
Output Summary:
  Black: 6 files would be left unchanged (0 files to reformat); exit 0.
  Ruff: All checks passed! (0 findings); exit 0.
  Pyright: 0 errors, 0 warnings, 0 informations; exit 0.
  The new test file tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py does not exist yet and has no pre-change figure.
