# Baseline — Pytest with Coverage

Timestamp: 2026-06-13T11-51
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: PASS. 1096 passed, 19 skipped. Coverage TOTAL (combined line+branch report): 82% (statements 8093, missed 1232; branches 2872, partial 419). This combined TOTAL is the baseline reference for no-regression comparison. Per-line and per-branch figures are reported per-file by term-missing; the repository CI gate enforces the 85% line / 75% branch policy via pyproject configuration. The 19 skips are codex/agents gitignored-directory tests unrelated to this feature. Coverage LCOV written to artifacts/python/lcov.info.
