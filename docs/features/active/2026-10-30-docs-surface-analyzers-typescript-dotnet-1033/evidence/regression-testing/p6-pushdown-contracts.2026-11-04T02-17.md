# Phase 6 push-down contract tests ([P6-T8])

Timestamp: 2026-11-04T02-17
Command: sh SCRATCH/issue-1033-pytest-pushdown.sh tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py (runs, from the item worktree, `poetry run pytest -p no:cacheprovider --no-cov -q tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`)
EXIT_CODE: 0
Output Summary: 96 passed, 0 failed, 0 errors (`96 passed in 1.99s`). The four named tests are in the run and pass: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`test_push_down_claude_resource_contracts.py`), `test_bundled_claude_files_are_listed_in_some_pack_manifest` (`test_push_down_claude_pack_manifest_completeness.py`), `test_claude_manifest_powershell_dependency_closure` and `test_every_psscriptroot_occurrence_is_recognized` (`test_push_down_pack_manifest_dependency_closure.py`). No test file is modified (`git status --short` lists no file under `tests/`). CI: `quality-checks7 / Code Quality & Tests (3.11)` through `(3.13)` (the plan's `(3.10)` entry names a version the workflow matrix does not carry; recorded as pending-CI under [P7-T11]).

## Counts

| Scope | passed | failed |
|---|---|---|
| four push-down contract files (no coverage) | 96 | 0 |
