# Final QA Gate — Python (full loop)

Timestamp: 2026-06-24T13-09

Stage 1 — Black
Command: poetry run black scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py
EXIT_CODE: 0
Output Summary: 2 files left unchanged.

Stage 2 — Ruff
Command: poetry run ruff check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py
EXIT_CODE: 0
Output Summary: All checks passed.

Stage 3 — Pyright
Command: poetry run pyright scripts/dev_tools/validate_evidence_locations.py
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations.

Stage 4 — Pytest (coverage)
Command: poetry run pytest tests/scripts/dev_tools/test_validate_evidence_locations.py --cov=scripts.dev_tools.validate_evidence_locations --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: 7 passed. Coverage for scripts/dev_tools/validate_evidence_locations.py: Stmts=28, Miss=0, Branch=12, BrPart=0, Cover=100% (line 100% >= 85%, branch 100% >= 75%).

Single-pass result: all four stages clean in a single pass.
