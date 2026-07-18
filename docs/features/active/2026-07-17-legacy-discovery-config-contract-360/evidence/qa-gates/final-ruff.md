# Final QC — Ruff (P5-T2)

Timestamp: 2026-07-18T14-40
Command: `poetry run ruff check .`
EXIT_CODE: 0
Output Summary: PASS. "All checks passed!" — zero lint errors. Bandit S506 is not
triggered because the loader uses `yaml.safe_load` (not `yaml.load`). Earlier TC002/TC003
findings on `tests/scripts/dev_tools/discovery/test_profile_cli.py` (type-only imports of
`Path` and `pytest`) were resolved by moving those imports into a `TYPE_CHECKING` block
(refactor, not suppression).
