# Post-merge bundle-parity baseline — issue #598

Timestamp: 2026-08-29T23-10
Task: [P0-T12]

Command:
1. `pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/state' -File -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force"`
2. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`

EXIT_CODE: 0

`EXIT_CODE:` is taken from command 2, the pytest command.

Output Summary:

Command 2 printed:

```
.                                                                        [100%]
1 passed in 0.09s
```

The run passed, so there is no assertion message to record.

PostMergeParityExitCode: 0

## Clearing step

Command 1 removed every file under `.claude/state/`. A confirming enumeration
(`Get-ChildItem -Path '.claude/state' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name`)
printed no names, so the parity scope carried no gitignored file when command 2 ran.

## Supersession

`PostMergeParityExitCode:` supersedes `BaselineParityExitCode:` from `[P0-T9]` as the parity
comparand for every batch gate from B08 onward and for `[P7-T9]` and `[P10-T6]`.

SupersededBaselineParityExitCode: 0

The superseded pre-merge value, recorded in
`evidence/baseline/pytest-bundle-parity.2026-08-29T20-30.md`, is `0`. The two values are identical,
so no divergence is attributable to the merge.

## Re-run condition

This task is re-run once after `[P0-T14]` if that task records a `PostMergeFormatterDrift:` list
containing any path under `.claude/` or under
`extensions/drm-copilot/resources/claude-customizations/`. The outcome of that condition is recorded
in the `[P0-T14]` artifact.

ReRunRequiredAfterP0T14: no — `[P0-T14]` subsequently recorded `PostMergeFormatterDrift: none` in
`evidence/baseline/poshqc-format-postmerge.2026-08-29T23-10.md`. That list contains no path under
`.claude/` and no path under `extensions/drm-copilot/resources/claude-customizations/`, so the
formatter changed no file inside the parity scope after this measurement, the re-run condition does
not fire, and this artifact is not superseded.

## Acceptance evaluation

- The artifact records `PostMergeParityExitCode:` holding the integer exit code.
- That value is `0`.

Both acceptance conditions hold. The stop-and-report branch does not fire.
