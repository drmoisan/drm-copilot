# Preflight Fixes - Issue 1024 (confirming preflight)

Timestamp: 2026-10-30T21-49
Plan: docs/features/active/2026-10-30-docs-reference-generator-1024/plan.2026-10-30T16-54.md

## Fixes

1. [P0-T6] | validator-blind environment precondition (assertion unchanged) | The worktree uses an in-project `.venv` (`poetry.toml`, `virtualenvs.in-project = true`), and the root `pyproject.toml` reaches the runtime packages only through `develop = true` path dependencies, with no Pytest `pythonpath` entry. An environment created before the integration branch was merged in cannot import `drm_copilot_docs` or `drm_copilot_docs_check`. Without a refresh, the [P0-T6] and [P0-T7] baselines record collection errors for the 1020 and 1021 suites, and the [P1-T4] import fails before [P1-T5] runs `poetry install`. Added one `poetry install` setup step at the start of [P0-T6], marked as setup and not a baseline gate. No task was added, removed, or reordered, and no acceptance condition changed.
2. `## Pre-Mortem` `CI-only behavior` bullet | prose inconsistent with AC-19 | The bullet named `PurePosixPath` as the path mechanism. AC-19 and `test_reference_modules_other_than_writer_perform_no_file_io` ([P6-T4]) forbid any `pathlib` import in `REF` modules other than `writer.py`, so following the bullet in a pure module would fail [P6-T4]. The bullet now states `/`-separated string paths in the pure `REF` modules and `pathlib` only in `writer.py` `FileSystemPagePort` and `cli_generate.py`. The bullet label and the prevention claim are unchanged.

Validation after fixes: branch-current CLI `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` and the installed MCP validator, both re-run after the edits.
