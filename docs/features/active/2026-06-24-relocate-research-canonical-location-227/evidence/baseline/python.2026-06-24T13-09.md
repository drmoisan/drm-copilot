# Baseline — Python (Black / Ruff / Pyright / Pytest)

Timestamp: 2026-06-24T13-09

Stage 1 — Black
Command: poetry run black --check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py
EXIT_CODE: 0
Output Summary: 2 files would be left unchanged. Already formatted.

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
Note: The plan lists --cov=scripts/dev_tools/validate_evidence_locations (slash form). That slash form yields "module never imported / no data" because the test imports the dotted module scripts.dev_tools.validate_evidence_locations. The dotted-module --cov target is the mechanically equivalent form that matches the test's import and is used here and in P9.
EXIT_CODE: 0
Output Summary: 6 passed. Coverage for scripts/dev_tools/validate_evidence_locations.py: Stmts=28, Miss=0, Branch=12, BrPart=0, Cover=100% (line 100%, branch 100%).
