# Final gate — pytest parallel ([P7-T2])

Timestamp: 2026-11-18T01-46
Command: sh SCRATCH/issue-1028-retry.sh pytest tests --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1028-pytest-final.json (the launcher runs `poetry run pytest -n auto`, and `--cov` uses the `[tool.coverage.run]` source list); figures read from the JSON report (SCRATCH/issue-1028-pycov.ps1)
EXIT_CODE: 0
Output Summary: 17122 passed, 0 failed and 6 skipped in 196.10 s, with no failing node ID; the Phase 0 baseline was 17111 passed. Repository-wide line coverage is 98.00% (35359 of 36079) and branch coverage is 95.46% (13091 of 13714). The Phase 0 figures were 97.98% line and 95.39% branch.

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/codex_native_converter/mapping.py` | 96.43% (54/56) | 92.31% (24/26) |
| `scripts/dev_tools/codex_native_converter/engine.py` | 98.97% (96/97) | 96.88% (31/32) |
| `scripts/dev_tools/codex_native_converter/pipeline.py` | 98.77% (80/81) | 95.00% (38/40) |
| `scripts/dev_tools/codex_native_converter/validation.py` | 98.28% (57/58) | 96.88% (31/32) |
