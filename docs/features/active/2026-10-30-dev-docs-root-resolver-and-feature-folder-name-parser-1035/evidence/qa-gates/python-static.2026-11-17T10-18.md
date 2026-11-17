# Python Static Gate (P9-T3, restart)

Timestamp: 2026-11-17T10-18
Command: sh SCRATCH/issue-1035-p9t3-run.sh (from the worktree root with VIRTUAL_ENV unset; configuration in pyproject.toml)
EXIT_CODE: 0
Output Summary: Restart of the Python loop from formatting after two tests were added to tests/scripts/dev_tools/test_feature_docs.py during P9-T4 (python-tests.2026-11-17T10-18.md records why). The earlier record python-static.2026-11-17T10-14.md stands for the tree before that change. One pass, no failure and no fix.

| Step | Command | EXIT_CODE | Findings |
| --- | --- | --- | --- |
| Format | poetry run black --check scripts/dev_tools/ tests/scripts/dev_tools/ | 0 | 0 files to reformat; "674 files would be left unchanged." |
| Lint | poetry run ruff check scripts/dev_tools/ tests/scripts/dev_tools/ | 0 | 0 ("All checks passed!") |
| Type check | poetry run pyright scripts/dev_tools/ tests/scripts/dev_tools/ | 0 | 0 errors, 0 warnings, 0 informations |
