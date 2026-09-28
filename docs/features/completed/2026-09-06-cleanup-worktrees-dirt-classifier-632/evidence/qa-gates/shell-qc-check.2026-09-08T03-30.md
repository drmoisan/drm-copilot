# P7-T2 — bash lint and format-diff (loop restart; the previous attempt failed here)

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T02-40Z (nominal run-timestamp scheme).
Run by: atomic-executor, directly. shellcheck 0.11.0.

Command: `bash scripts/bash/shell-qc.sh check`
EXIT_CODE: 0

Output Summary: the command emitted no `shfmt` diff hunk and no `shellcheck` finding for any
file, including the new `scripts/bash/cleanup_worktrees_dirt_lib.sh`. `run_check`
(`scripts/bash/shell_qc_lib.sh:165-190`) runs `shfmt -d` once over the full discovered list and
`shellcheck` once per file, returning the maximum exit code, so a zero exit means every file was
clean under both tools.

## The previous failure and its resolution

The prior attempt recorded in `evidence/qa-gates/shell-qc-check-failure.2026-09-08T03-10.md`
exited 1 with one finding: SC2034 against `CLEANUP_WT_CLEAR_DISPOSABLE=1` in
`scripts/bash/cleanup-worktrees.sh`. It is resolved by a line-scoped, justified
`# shellcheck disable=SC2034`, and the test gap the finding pointed at is closed by a
wrapper-driven positive/negative test pair. Both are recorded in
`evidence/qa-gates/wrapper-clear-flag-mutation.2026-09-08T03-30.md`, including the mutation run
that demonstrates the new pair can fail and the probe that demonstrates the suppression is
line-scoped rather than file-scoped.

## Per-file confirmation

Command: `shellcheck -x scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup-worktrees.sh`
EXIT_CODE: 0

Command: `shfmt -d scripts/bash/cleanup_worktrees_dirt_lib.sh`
EXIT_CODE: 0, no output.
