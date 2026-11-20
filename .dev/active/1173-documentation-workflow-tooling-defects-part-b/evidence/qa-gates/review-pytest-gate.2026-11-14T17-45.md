# Review Rerun: pytest Coverage Gate (feature review)

Timestamp: 2026-11-14T17-45
Command: sh SCRATCH/fr1173-pytest.sh (from the item worktree root: env -u VIRTUAL_ENV poetry run pytest tests -n auto -q -m "not integration and not golden" --cov --cov-branch --cov-report=term; the repository addopts write artifacts/python/lcov.info)
EXIT_CODE: 0
Output Summary:
- Reason: the merge of origin/main (commit ec00c5389f10) is newer than the executor's Python coverage report, so the feature-review coverage Stop hook reported it stale.
- Run window (UTC, clock-read): 2026-11-14T17:41:32Z to 2026-11-14T17:44:41Z at head ec00c5389f10be134de8390cf839365fea5c5687, clean tree.
- 16951 passed, 6 skipped, 0 failed in 186.39 s.
- Repository-configured coverage sources: TOTAL 35910 statements, 809 missed, 13688 branches, 551 partial; line 97.75%, branch 95.97%.
- Changed modules: docs_python_native/call_sites.py 105 statements 0 missed, 38 branches 0 partial; cli.py 141 statements 1 missed, 64 branches 1 partial; cli_argparse.py 213 statements 0 missed, 114 branches 1 partial (same figures as the final QC run).
- Deviation note: run through a scratch launcher calling `poetry run pytest -n auto` with coverage options, not through `run-test-suite.sh pytest`; integration and golden markers were excluded as the launcher does.
