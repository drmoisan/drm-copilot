# Push-Down Contract Baseline ([P0-T7])

Timestamp: 2026-11-03T21-49
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:cacheprovider (run inside the item worktree through PowerShell 7 Set-Location; project pytest options include --strict-markers --strict-config)
EXIT_CODE: 0
Output Summary: 43 passed, 0 failed in 1.94s (serial). The same four files with -n auto (pytest-xdist): 43 passed, 0 failed in 2.69s, exit 0. Failing tests: none.

## Serial run

```text
...........................................                              [100%]
43 passed in 1.94s
```

## Parallel run (same four files, `-n auto`)

```text
43 passed in 2.69s
```

Exit code 0.
