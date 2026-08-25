# Batch-Budget Counter Reset Before Batch 2 (issue #516)

Timestamp: 2026-08-24T16-06
Command: inspect `.claude/state/` and delete any file whose name begins with `powershell-batch-budget.`, then re-inspect
EXIT_CODE: 0

## Result

```text
directory existed: False
post-check directory exists: False
```

## Interpretation

`.claude/state/` did not exist at the moment [P3-T1] ran, so there was no session-keyed budget state file to delete and the counter is reset by construction. The plan anticipates this outcome explicitly: the directory is created by the batch-budget hook on its first governed write, so an absent directory is an acceptable result of the inspection and is recorded as such rather than treated as a failure.

## Why the directory was already absent — full history in this session

The directory was created and removed twice earlier in this execution, and both removals are recorded rather than silent:

1. **Created 15:27**, during Phase 0, when the batch-budget hook observed a throwaway coverage-reading script written to the session scratchpad directory outside this worktree. Removed at 15:29 because its presence broke `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which enumerates every on-disk `.claude/**` file and requires a bundled counterpart. Recorded in `evidence/baseline/baseline-pytest-pushdown-parity.2026-08-23T23-25.md`.
2. **Recreated during Phases 1 and 2**, by the governed writes of the two new test suites and the Claude hook copy. Removed at 16:03, immediately before the [P2-T5] parity leg, for the same reason. Recorded in `evidence/regression-testing/pass-after-claude-batch.2026-08-23T23-25.md`, command block 2.

The 16:03 removal is what left the directory absent when [P3-T1] ran. That removal served the [P2-T5] parity requirement; this task independently re-verifies the post-condition [P3-T1] actually asserts, and finds it satisfied.

## Acceptance Condition

> `.claude/state/` either does not exist or, where it exists, a `Get-ChildItem` of it filtered on that name prefix returns no file.

**Satisfied by the first disjunct:** the directory does not exist. The PowerShell production-file budget consumed by batch 1 is therefore cleared, and Phase 3 may write the two Codex hook copies.

No file deleted by this task or by either earlier removal is tracked: `.gitignore:68` lists `.claude/state/`, confirmed by `git check-ignore -v` during Phase 0. None of these removals can appear in the [P5-T1] changed-path union.

Output Summary: The batch-budget counter is reset. `.claude/state/` did not exist when [P3-T1] ran, which the plan names as an acceptable outcome, so no file required deletion and the post-check confirms the directory is still absent. The full create/remove history within this session is recorded above, with each removal cross-referenced to the artifact that documents it. Batch 2 is now clear to write the two Codex hook copies; no Codex hook write occurred before this task completed, which [P2-T6] independently confirmed by observing no `.codex/` path in the changed-file list.
