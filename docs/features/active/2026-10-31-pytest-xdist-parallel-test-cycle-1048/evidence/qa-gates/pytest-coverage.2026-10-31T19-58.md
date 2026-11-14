# Final QA: pytest with coverage under -n auto (#1048, P10-T4)

Timestamp: 2026-10-31T19-58
Command: poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1048-final.json --cov; poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report SCRATCH/issue-1048-final.json --min-line 85 --min-branch 75
EXIT_CODE: 0
Output Summary:
- Tests: 15875 passed, 6 skipped, 0 failed in 137.60 s (24 xdist workers).
- Terminal TOTAL line: `TOTAL 33243 1099 12480 551 96%`.
- JSON totals: `percent_statements_covered` 96.6940 (32144/33243); `percent_branches_covered` 93.6298 (11685/12480).
- Delta against the P0-T2 serial baseline (96.6940 / 93.6298): +0.0000 statements, +0.0000 branches. No regression.
- Threshold checker exit code: 0 (line floor 85, branch floor 75).
- The Python changes in this item are test-only, plus `pyproject.toml` and `poetry.lock`; no production Python module changed.
- Loop restart at 2026-10-31T20-40 (after the SW04 coverage addition in P10-T7): the same command, with the JSON report at SCRATCH/issue-1048-final2.json, printed `15875 passed, 6 skipped in 152.54s` and `TOTAL 33243 1099 12480 550 96%`; JSON totals `percent_statements_covered` 96.6940 (32144/33243) and `percent_branches_covered` 93.6378 (11686/12480). Statements +0.0000 and branches +0.0080 (one branch) against P0-T2, which matches the run-to-run variance recorded in `pytest-coverage-equality`; no regression. Threshold checker exit code 0.
