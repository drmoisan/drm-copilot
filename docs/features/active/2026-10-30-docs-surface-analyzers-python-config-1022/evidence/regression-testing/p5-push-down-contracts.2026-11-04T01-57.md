# [P5-T4] Push-down contract tests through Poetry (issue #1022)

Timestamp: 2026-11-04T01-57
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p5t4-pytest.ps1 (the launcher runs `Set-Location` to the item worktree, then `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -p no:randomly -o addopts='' -q -rA`)
EXIT_CODE: 0
Output Summary: 34 passed in 1.73s, 0 failed, 0 errored, 0 skipped. Per file: `test_push_down_claude_resource_contracts.py` 14 passed; `test_push_down_claude_pack_manifest_completeness.py` 2 passed; `test_push_down_pack_manifest_dependency_closure.py` 18 passed. The four named tests passed: `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`. No Python test file was added or edited.

## Launcher note

- A first run exited 4 before collection: `pytest-cov` is not installed in this worktree's Poetry environment, so the project `addopts` entry `--cov-report=lcov:artifacts/python/lcov.info` was rejected as an unrecognized argument. The launcher therefore passes `-o addopts=''` (dropping `-ra --cov-report=... --strict-markers --strict-config` for this run; `-rA` restores the per-test summary). The three contract test files assert file parity and manifest closure and carry no coverage requirement; the same files run with the full `addopts` in CI (`quality-checks7 / Code Quality & Tests (3.11)` through `(3.13)`).

## Acceptance criteria checked off

- spec S18 (every created or edited `.claude/lib/docs/` file has a byte-identical bundle copy, every new file is listed in `pack-manifests/core.json` and none in `pack-manifests/python.json`, and `Docs.Manifest.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass): proven by [P5-T1], [P5-T2], [P5-T3] and this task; [P6-T7] re-runs the same tests after the final format pass.

CI: `quality-checks7 / Code Quality & Tests (3.11)` through `(3.13)`.
