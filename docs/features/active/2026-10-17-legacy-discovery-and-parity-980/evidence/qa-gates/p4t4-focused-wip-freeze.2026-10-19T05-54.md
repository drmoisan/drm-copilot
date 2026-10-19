# P4-T4 focused checked-WIP freeze

Timestamp: 2026-10-19T05-54
Command: `poetry run python SCRATCH/issue-980-freeze.py`
EXIT_CODE: 0
Output Summary: Eight new source/test/fixture paths are frozen after 61 passing cases and a clean ordered Black/Ruff/Pyright/Pytest sequence. Task acceptance remains pending.

Production coverage is 251/254 statements and 104/110 branch destinations; every measured new class/callable range meets 90% statements. All 34 accepted predecessor/interface hashes match the retained baseline. Exact paths, hashes, raw receipts and limitations are in the paired JSON.

The approved split keeps pure parsing and key/error records in configuration_input.py and finite selection/provenance projection in configuration.py. Tests are split by the same responsibility. All rendered evidence is LF-only UTF-8; earlier diagnostics are preserved separately.
