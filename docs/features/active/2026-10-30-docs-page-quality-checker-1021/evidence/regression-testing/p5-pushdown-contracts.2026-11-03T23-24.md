# P5 Push-Down Contract Tests - Issue #1021

Timestamp: 2026-11-03T23-24
Task: [P5-T4] (also proves [P5-T2])
Command: `sh SCRATCH/issue-1021-pytest.sh` (`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -p no:cacheprovider --no-cov -q`); `sh SCRATCH/issue-1021-pytest-xdist.sh` (the same files with `--strict-markers --strict-config -n auto`)
EXIT_CODE: 0
Output Summary: serial run `32 passed`; `-n auto` run `32 passed`; 0 failed in both. The collected node IDs include `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_claude_manifest_powershell_dependency_closure` and `test_every_psscriptroot_occurrence_is_recognized`. Neither test file is modified (`git status --porcelain -- tests/scripts/dev_tools` prints nothing). CI: `quality-checks7 / Code Quality & Tests (3.11)` through `(3.13)`.

## Additional verification (execution-environment `## Contract Tests That Pin Mirrored Files`)

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -p no:cacheprovider --no-cov -q --strict-markers --strict-config -n auto`
EXIT_CODE: 0
Output Summary: `13 passed`. Every bundled file, the thirteen new ones included, is listed in a pack manifest.
