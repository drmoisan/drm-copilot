# Baseline — Pyright

Timestamp: 2026-10-10T08-04
Task: [P0-T5]
Command: poetry run pyright scripts/dev_tools/skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
EXIT_CODE: 0

Output Summary:
- `0 errors, 0 warnings, 0 informations`
- Informational stderr lines (not diagnostics): `venv .venv subdirectory not found in venv path <worktree root>.` (the agent worktree has no local `.venv`; Poetry's environment was used) and a pyright version-available notice (v1.1.409 -> v1.1.414).
