# pytest final gate with coverage (issue #1157, cycle 1, P2-T5, finding F2)

Timestamp: 2026-11-13T15-55
Command: sh SCRATCH/issue-1157-pytest.sh --cov-branch --cov-report=term-missing --cov (in the item worktree with VIRTUAL_ENV unset: poetry run pytest -n auto -q -rfE -p no:cacheprovider --junitxml=SCRATCH/issue-1157-pytest-junit.xml --cov-branch --cov-report=term-missing --cov; the project addopts adds --cov-report=lcov:artifacts/python/lcov.info)
EXIT_CODE: 0
Output Summary:
- "16598 passed, 6 skipped in 286.91s (0:04:46)"; failed 0; errors 0 (JUnit: tests=16604, failures=0, errors=0, skipped=6). Run start 2026-11-13T15-49.
- Phase 0 baseline comparison: baseline 16590 passed, 0 failed; no node fails here, so no new failing test.
- Terminal TOTAL row: Stmts 35355, Miss 1021, Branch 13424, BrPart 556, Cover 96%.
- artifacts/python/lcov.info (written by this run, mtime 2026-11-13T15:54:03Z): LF 35355, LH 34334 (missed 1021); BRF 13424, BRH 12668. Line coverage 97.11% (34334/35355).
- Merge-base CI TOTAL (CI run 43170341553, from baseline-reference.2026-11-13T14-43.md): 35355 statements, 1035 missed; 13424 branches, 554 partial.
- Comparison: statements and branches are equal. Missed lines are 14 fewer and partial branches 2 more. git diff --name-only from the merge base over the coverage source set (src, scripts/dev_tools, packages/discovery-runtime/src, .claude/lib/docs/python) lists 0 files, so every file that contributes to the difference is outside this branch; the difference comes from host-dependent execution paths of unchanged files (this run on Windows, the CI run on ubuntu-latest).
- No production Python file changed: the only Python file in the branch diff is tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py.
