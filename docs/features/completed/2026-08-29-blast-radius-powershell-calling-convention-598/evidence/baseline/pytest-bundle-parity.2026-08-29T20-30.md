# Bundle-parity baseline — issue #598

Timestamp: 2026-08-29T20-30
Task: [P0-T9]

Command:
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`

EXIT_CODE: 0

BaselineParityExitCode: 0

Output Summary: `1 passed in 0.08s`. The single selected test passed on the recorded run.

## First attempt and the remedy applied

The first invocation of this command exited 1 with the assertion message:

```
AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
```

`.claude/state/python-batch-budget.default.json` had been recreated after the `[P0-T3]` clearing,
with a last-write time of 2026-08-29 20:32:21, which falls inside the `[P0-T7]` Pester run window.
The plan's `[P0-T9]` prose predicted that nothing between `[P0-T3]` and `[P0-T9]` recreates a file
under `.claude/state/`; that prediction is falsified by the Pester suite, which exercises the Python
batch-budget hook and leaves its state file on disk under the real repository root.

`[P0-T9]` states the remedy for a non-zero exit directly: re-run the `[P0-T3]` clearing command so
the recorded assertion path is removed, then re-run this task. That was done:

1. `pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/state' -File -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force"`
2. The `[P0-T3]` inventory command was re-run and printed `none`.
3. The parity command above was re-run and exited 0.

This observation does not change any later step: the plan's sequencing constraint 3 already places a
`.claude/state/` clearing step (command 6) between the Pester step (command 5) and the parity step
(command 7) of every batch gate, which is the same ordering that resolved the failure here.

## Acceptance evaluation

- The integer exit code is recorded, and `BaselineParityExitCode:` holds it.
- `BaselineParityExitCode:` is `0`, as acceptance requires.
- This recorded value `0` is the fixed comparand for every per-batch parity gate in Phases 1
  through 7.
