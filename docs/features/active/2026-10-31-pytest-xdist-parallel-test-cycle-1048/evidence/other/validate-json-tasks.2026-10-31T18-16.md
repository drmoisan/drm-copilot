# Governed-JSON validation for .vscode/tasks.json (#1048, P1-T5)

Timestamp: 2026-10-31T18-16
Command: poetry run python -m scripts.dev_tools.validate_json; poetry run python SCRATCH/issue-1048-tasks-check.py "QC: 4 Pytest: run tests" "QC: 4 Pytest: run tests (parallel)" "QC: 4 Pytest: run tests with coverage (parallel)"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `validate_json` (default governed globs `scripts/**/*.json`, `docs/**/*.json`, `examples/**/*.json` in `scripts/dev_tools/json_config.py`) exits 1 with 3700 findings, all in pre-existing repository files (`missing $schema` and `JSON root must be an object for validation` under `docs/features/**/evidence/` and `scripts/`). Zero findings name `.vscode/tasks.json` or any `.vscode` path; `.vscode/tasks.json` is not in the governed globs, and it is JSONC (it starts with `//` comments), so `validate_json` never reads it.
- The only JSON files changed in the worktree are `.vscode/tasks.json` (this task) and `.claude/settings.local.json` (pre-existing local modification, not part of this change), so none of the 3700 findings is introduced by this feature.
- Plan deviation: the P1-T5 and P6-T3 acceptance text "`validate_json` exits 0" is unsatisfiable on the current tree for reasons outside this item. Substitute verification: the JSONC parse of `.vscode/tasks.json` (full-line comments removed, then `json.loads`) succeeds with 54 tasks, and the labels `QC: 4 Pytest: run tests` (`poetry run pytest`, unchanged), `QC: 4 Pytest: run tests (parallel)` (`poetry run pytest -n auto`), and `QC: 4 Pytest: run tests with coverage (parallel)` (`poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov`) are present. Neither new task contains `lexile_corpus_tuner`.
