# Python Format Baseline — [P0-T4]

Timestamp: 2026-08-26T07-51
Task: [P0-T4]
Command: `poetry run black --check .`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6b0c3b38073271d8`
EXIT_CODE: 0

## Full output

```
All done! \u2728 \U0001f370 \u2728
450 files would be left unchanged.
```

(The escape sequences are the console encoding of the tool's decorative characters on this terminal; they carry no result signal.)

## Exit-code capture method

The command's output was redirected to a file and the exit code read from `$?` immediately after, with no pipe in the chain. A pipe would have yielded the status of the last stage rather than of `black`, so a failing check could have read as a pass. The recorded 0 is `black`'s own status.

## Observation beyond the exit code

The plan's standing rules record that `black` prints a summary line containing `left unchanged` on a clean run and prints a line containing `reformatted` when it rewrites a file, exiting 0 in both cases. In `--check` mode it exits 1 rather than 0 when a file would be reformatted. Both observations are consistent here:

- The summary line contains the literal `left unchanged`.
- No output line contains the literal `reformatted`.
- The exit code is 0, which under `--check` additionally proves no file would be reformatted.

**Files scanned: 450. Files that would be reformatted: 0. Files that would be left unchanged: 450.**

## Why the check-only form is used at baseline

This task deliberately uses `--check` rather than the write-mode `black .`. The write-mode form would repair any pre-existing formatting drift silently and still exit 0, which would make the baseline a record of the repaired state rather than of the state as found, and would convert the Phase 8 formatting gate into a blanket waiver. Substituting the write-mode form here is the exact defect class this feature repairs (issue #519 class 2), so the substitution is prohibited by the plan and was not made.

Because the check-only form does not write, this command is not a write-mode register invocation and no observation marker obligation attaches to it. The write-mode form runs later at [P8-T1], where the plan requires the summary line to be recorded as the observation beyond the exit code.

## Output Summary

`poetry run black --check .` exited 0. 450 files scanned; 0 would be reformatted; 450 would be left unchanged. The summary line carries the literal `left unchanged` and no line carries `reformatted`. No pre-existing Python formatting drift exists in this worktree at baseline.
