# Python Per-File Coverage ([P8-T5])

Timestamp: 2026-09-26T22-23

Command:
1. `poetry run coverage json --data-file=artifacts/.coverage --include="*/pr_context/render_pr_helpers.py,*/pr_context/autoclose.py,*/pr_context/collector.py" --pretty-print -o artifacts/python/coverage-588-final.json`
2. Read of `artifacts/python/coverage-588-final.json`, `files["<path key>"].summary` per file (via `poetry run python -c` one-liner).

EXIT_CODE:
1. 0
2. 0

Output Summary (file-level `summary`; Windows path keys):
- Edited per the state artifact: `scripts\dev_tools\pr_context\render_pr_helpers.py` (PY_BUILDER_FILE, PARAM-ONLY): covered_lines/num_statements 127/132 = 96.21%; covered_branches/num_branches 63/66 = 95.45%. Both at or above 85.00% / 75.00%.
- Not edited (PY_CALLSITE PRESENT), for information: `scripts\dev_tools\pr_context\collector.py` 157/168 = 93.45%; 42/50 = 84.00%.
- For information: `scripts\dev_tools\pr_context\autoclose.py` 45/45 = 100.00%; 16/16 = 100.00%.
