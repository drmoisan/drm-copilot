# P7 Contract Module Toolchain (P2-T2)

Timestamp: 2026-10-13T11-17
Command: poetry run black --check tests/scripts/dev_tools/test_evidence_timestamp_contracts.py
EXIT_CODE: 0
Output Summary: Final pass of the three checks exited 0 (Black `1 file would be left unchanged.`, Ruff `All checks passed!`, Pyright `0 errors, 0 warnings, 0 informations`). The first pass required a Black rewrite, recorded below.

## First pass (before rewrite)

- `poetry run black --check tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` -> EXIT_CODE 1: `would reformat tests\scripts\dev_tools\test_evidence_timestamp_contracts.py` / `1 file would be reformatted.`
- `poetry run ruff check tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` -> EXIT_CODE 1: `E501 Line too long (89 > 88)` at line 201 (the `test_atomic_plan_contract_matches_bundled_mirror` signature) / `Found 1 error.`
- `poetry run pyright tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` -> EXIT_CODE 0: `0 errors, 0 warnings, 0 informations`

## Rewrite

- `poetry run black tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` -> EXIT_CODE 0: `reformatted tests\scripts\dev_tools\test_evidence_timestamp_contracts.py` / `1 file reformatted.` (the long signature was wrapped; file now 212 lines)

## Rerun (final)

### Black
Command: poetry run black --check tests/scripts/dev_tools/test_evidence_timestamp_contracts.py
EXIT_CODE: 0
Output: `All done!` / `1 file would be left unchanged.`

### Ruff
Command: poetry run ruff check tests/scripts/dev_tools/test_evidence_timestamp_contracts.py
EXIT_CODE: 0
Output: `All checks passed!`

### Pyright
Command: poetry run pyright tests/scripts/dev_tools/test_evidence_timestamp_contracts.py
EXIT_CODE: 0
Output: `0 errors, 0 warnings, 0 informations`
