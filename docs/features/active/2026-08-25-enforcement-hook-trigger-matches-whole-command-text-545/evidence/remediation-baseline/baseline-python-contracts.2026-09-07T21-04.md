# Baseline — Python Contract Suites (cycle 2)

Timestamp: 2026-09-07T21-04
Task: [P0-T8]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -p no:cacheprovider --no-header -q
EXIT_CODE: 0

## Result — combined run

```
......................                                                   [100%]
22 passed in 0.27s
```

Recorded summary line: **`22 passed`**. Matches the acceptance condition exactly.

## Result — seam module alone

Command: poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -p no:cacheprovider --no-header -q
EXIT_CODE: 0

```
..........                                                               [100%]
10 passed in 0.04s
```

Recorded summary line: **`10 passed`**. This is the number `[P3-T10]` compares against after Edit 4
modifies `.claude/hooks/enforce-parallel-abandon-gate.ps1`. The suite's
`test_hook_states_each_token_exactly_once` asserts a whole-file occurrence count of exactly 1 per
token over that hook, and a comment counts, so any restatement of either abandon literal in Edit 4
would drop this figure below 10.

## Ordering note — `.claude/state/` is clean at this point

`test_push_down_claude_resource_contracts.py` enumerates `.claude/**` from the filesystem and fails
when `.claude/state/` is non-empty (known issue #510). This task deliberately runs **before** any
PowerShell batch opens, so no `powershell-batch-budget.*.json` file exists yet. Confirmed
immediately before the run:

```
$ ls -1a .claude/state/
./
../
```

The directory holds no entry other than `.` and `..`. That ordering is a property of the plan and
must be preserved; running this task after a batch has opened would produce a spurious failure
attributable to ambient state rather than to this cycle's change.

## Python coverage

No Python coverage figure is required or recorded for this cycle, because this cycle edits no
Python production source file — every edit in the plan's six-edit set targets a `.ps1` hook or a
`.Tests.ps1` suite, and the three Python suites above are read-only contract checks over the
PowerShell tree.

## Output Summary

Both runs exit 0. The combined run of the three contract suites reports `22 passed`; the seam module
alone reports `10 passed`. `.claude/state/` was confirmed empty before the run, so the known issue
#510 interaction with `test_push_down_claude_resource_contracts.py` did not arise. No Python
production file is edited by this cycle, so no Python coverage figure is required and none is
recorded.
