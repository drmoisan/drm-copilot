# Final QA: Push-Down Contracts ([P7-T7])

Timestamp: 2026-11-04T02-03
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:cacheprovider (run inside the item worktree through SCRATCH/issue-1023-push-down-contracts.sh; project pytest options include --strict-markers --strict-config)
EXIT_CODE: 0
Output Summary: 43 passed, 0 failed in 1.86s (serial), exit 0. The same four files with -n auto (pytest-xdist): 43 passed, 0 failed in 3.15s, exit 0. Failing tests: none (baseline [P0-T7]: 43 passed, none failing). The ten new bundle copies and the edited entry-script copy match their repository sources, every manifested PowerShell file's $PSScriptRoot dependencies are manifested in core.json, and the bundled files are listed in a pack manifest. CI: quality-checks7 / Code Quality & Tests (3.11), (3.12), (3.13).

## Serial run

```text
...........................................                              [100%]
43 passed in 1.86s
```

## Parallel run (same four files, `-n auto`)

```text
...........................................                              [100%]
43 passed in 3.15s
```

Exit code 0 for both.
