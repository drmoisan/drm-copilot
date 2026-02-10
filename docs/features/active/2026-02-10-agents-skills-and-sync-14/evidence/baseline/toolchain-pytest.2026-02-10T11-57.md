Timestamp: 2026-02-10T11-57
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output (abbreviated):
============================= test session starts =============================
platform win32 -- Python 3.13.7, pytest-9.0.2, pluggy-1.6.0
rootdir: D:\repos\drm-copilot.worktrees\copilot-worktree-2026-02-10T12-03-39
configfile: pyproject.toml
collected 767 items
...
=============================== tests coverage ================================
_______________ coverage: platform win32, python 3.13.7-final-0 _______________

Name                                                       Stmts   Miss  Cover  Missing
--------------------------------------------------------------------------------------
TOTAL                                                       5677    927    84%
============================= 767 passed in 6.25s =============================
CoverageWarnings:
- Module src/lexile_corpus_tuner was never imported. (module-not-imported)
