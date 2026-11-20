# Phase 0 baseline — pytest parallel gate

Timestamp: 2026-11-17T18-50
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1028-pytest-p0.json (the launcher runs `poetry run pytest -n auto`; `--cov` uses the `[tool.coverage.run]` source list); figures read from the JSON report (SCRATCH/issue-1028-pycov.ps1)
EXIT_CODE: 0
Output Summary: 17111 passed, 0 failed, 6 skipped in 194.04 s; no pre-existing failure (no failing node ID). Repo-wide: line 97.98% (35367/36096), branch 95.39% (13088/13720), combined terminal TOTAL 97%. Per file under `scripts/dev_tools/codex_native_converter/`:
- `mapping.py`: line 96.36% (53/55), branch 92.31% (24/26)
- `engine.py`: line 97.03% (98/101), branch 91.18% (31/34)
- `pipeline.py`: line 95.74% (90/94), branch 88.64% (39/44)
- `validation.py`: line 96.61% (57/59), branch 93.75% (30/32)
