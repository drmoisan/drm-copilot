# Python Baseline Per-File Coverage ([P0-T19])

Timestamp: 2026-09-26T21-22

Command:
1. `poetry run coverage json --data-file=artifacts/.coverage --include="*/pr_context/render_pr_helpers.py,*/pr_context/autoclose.py,*/pr_context/collector.py" --pretty-print -o artifacts/python/coverage-588-baseline.json`
2. Read of `artifacts/python/coverage-588-baseline.json`, `files["<path key>"].summary` per file (via `poetry run python -c` one-liner).

EXIT_CODE:
1. 0
2. 0

Output Summary (file-level `summary`; path keys use the Windows separator):
- `scripts\dev_tools\pr_context\render_pr_helpers.py` (PY_BUILDER_FILE): covered_lines/num_statements 125/130 = 96.15%; covered_branches/num_branches 61/64 = 95.31%.
- `scripts\dev_tools\pr_context\collector.py`: 157/168 = 93.45%; 42/50 = 84.00%.
- `scripts\dev_tools\pr_context\autoclose.py` (information only): 45/45 = 100.00%; 16/16 = 100.00%.
- No file this plan may edit is below 85% line or 75% branch.
