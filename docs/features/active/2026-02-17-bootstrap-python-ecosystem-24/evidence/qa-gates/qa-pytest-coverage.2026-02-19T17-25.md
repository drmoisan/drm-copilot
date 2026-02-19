# QA Gate Evidence: Pytest coverage run

Timestamp: 2026-02-19T17-25
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 1
Output Summary: Pytest exited with code 1 because no tests were collected; coverage reported 0% with warnings about missing imports and no data collected.

Output (excerpt):
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49
configfile: pyproject.toml
testpaths: tests
plugins: anyio-4.12.1, cov-7.0.0
collected 0 items
C:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module src/lexile_corpus_tuner was never imported. (module-not-imported)
C:\Users\DanMoisan\repos\drm-copilot.worktrees\copilot-worktree-2026-02-18T01-26-49\.venv\Lib\site-packages\coverage\control.py:958: CoverageWarning: No data was collected. (no-data-collected)

TOTAL 3889 3889 0%

Command exited with code 1
