# Stub `rev-list` Key Derivation — Range Form Unchanged

Timestamp: 2026-09-07T20-48
Task: [P1-T3]
Issue: #632

## Command form actually used (execution amendment EA-1)

The plan's command block is written as bare `wsl -d Ubuntu -- bash -lc 'cd /mnt/c/.../agent-a3944b95a7d58e712 && ...'`, which names the preparation worktree and uses the forbidden bare-`wsl` form. The commands below were run under Git Bash with the working directory set to this worktree root.

## Observation 1 — the `main..<branch>` range form still keys as before

Command: `CLEANUP_WT_STUB_SCENARIO=tests/fixtures/cleanup_worktrees/scenarios/unmerged bash tests/fixtures/cleanup_worktrees/stub-bin/git rev-list --no-merges main..feature-unmerged 2>/dev/null`
EXIT_CODE: 0

Stdout, verbatim:

```
commit dead0001
dead0001|Dan Moisan|2026-07-20T09:00:00-07:00
```

Command: `cat tests/fixtures/cleanup_worktrees/scenarios/unmerged/rev-list.feature-unmerged.out`
EXIT_CODE: 0

Stdout, verbatim:

```
commit dead0001
dead0001|Dan Moisan|2026-07-20T09:00:00-07:00
```

The two are byte-identical, so the range form still derives the key `rev-list.feature-unmerged` and the existing scenarios are unaffected.

## Observation 2 — the range-free form

The range-free branch derives its key from the trailing non-option revision operand instead of from the absent range. Without the change, `rev-list --max-count=201 HEAD` derives the key `rev-list.` for every range-free call, so no scenario can supply a per-revision response.

The range-free key `rev-list.HEAD` is not behaviorally observable at this point in the plan, because no checked-in scenario carries a `rev-list.HEAD.out` response until [P2-T6] creates one. Its behavioral gate is classify-suite test 11, which replays that response and reads nothing if the key were still derived as `rev-list.`.

## Gate still owed to the orchestrator

`bats tests/shell/test_cleanup_worktrees_classification.bats` is part of this task's stated acceptance and is a bash-toolchain gate this executor is denied (EA-4). It is owed from the orchestrator.

Output Summary: The `main..<branch>` range form produces stdout byte-identical to the checked-in `rev-list.feature-unmerged.out` fixture, so the existing key derivation is preserved. The range-free form now keys on the trailing revision operand. The bats leg of the acceptance is outstanding.
