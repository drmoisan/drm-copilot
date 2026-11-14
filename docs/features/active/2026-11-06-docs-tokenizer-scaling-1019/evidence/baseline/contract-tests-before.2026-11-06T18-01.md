# Contract Tests Baseline - Issue 1019

Timestamp: 2026-11-06T18-01
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q
EXIT_CODE: 0
Output Summary: 16 passed, 0 failed, in 0.36 s (pytest summary line `16 passed in 0.36s`).

## Environment Observation

`poetry env info -p`, run from this worktree, resolves to the `.venv` of the main checkout, a shared environment rather than one inside this worktree. The tests are read-only, so `poetry run` is acceptable there. `poetry install` was not run.
