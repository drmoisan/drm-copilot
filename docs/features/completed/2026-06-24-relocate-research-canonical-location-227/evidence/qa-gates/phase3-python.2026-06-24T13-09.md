# Phase 3 QA Gate — Python (validate_evidence_locations)

Timestamp: 2026-06-24T13-09

Stage 1 — Black
Command: poetry run black scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py
EXIT_CODE: 0
Output Summary: 2 files left unchanged. Already formatted.

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
Output Summary: 7 passed (was 6; +1 test_artifacts_research_is_forbidden). Coverage for scripts/dev_tools/validate_evidence_locations.py: Stmts=28, Miss=0, Branch=12, BrPart=0, Cover=100% (line 100% >= 85%, branch 100% >= 75%).

Changed-line coverage: the added _FORBIDDEN_PREFIX_TO_CANONICAL entry "artifacts/research/" is exercised by test_artifacts_research_is_forbidden (asserts exactly one violation and that the suggestion names both new roots). No regression on changed lines.

P3-T2 disposition: not-applicable. The module docstring describes the scheme generally ("any file found under a forbidden artifacts/ sub-path is reported as a violation") and does not enumerate individual forbidden prefixes nor claim research under artifacts/ is permitted. No docstring edit was required.

Single-pass result: all four stages clean in a single pass.
