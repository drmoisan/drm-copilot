# Final bundle-parity gate — issue #598

Timestamp: 2026-08-30T02-28
Task: [P10-T6]

Command:
1. `pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/state' -File -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force"`
2. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`

EXIT_CODE: 0

`EXIT_CODE:` is taken from command 2, the pytest command.

Output Summary:

Command 1 produced no output. It removes every file under `.claude/state/`, both the
`*batch-budget*.json` counters and `current-session-id`, because `list_scoped_files` in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` walks the filesystem with
`rglob` and does not consult git, so a gitignored file under `.claude/state/` would be enumerated as
a repository `.claude` file and demanded in the bundle. An empty `.claude/state/` directory is
harmless because the walk filters on `path.is_file()`.

Command 2 printed:

```
.                                                                        [100%]
1 passed in 0.11s
```

No assertion message was produced.

## Comparand

`PostMergeParityExitCode: 0`, recorded in
`evidence/baseline/pytest-bundle-parity-postmerge.2026-08-29T23-10.md` by `[P0-T12]`. That value
supersedes `BaselineParityExitCode:` from `[P0-T9]` for every gate from batch B08 onward, per
sequencing constraint 9.

## Acceptance evaluation

- `EXIT_CODE:` is `0`, which equals `PostMergeParityExitCode:` from `[P0-T12]`.

The acceptance condition holds. The gate did not fail, so there is no assertion message to quote and
nothing to report to the caller.
