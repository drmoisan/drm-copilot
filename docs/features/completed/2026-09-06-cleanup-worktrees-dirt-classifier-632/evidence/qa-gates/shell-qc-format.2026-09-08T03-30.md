# P7-T1 — bash formatter (loop restart after the P7-T2 failure)

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T02-40Z (nominal run-timestamp scheme).
Run by: atomic-executor, directly. shfmt and shellcheck are on PATH in this session, so the
toolchain was run first-hand rather than handed to the orchestrator.

This is a FRESH artifact set. The previous Phase 7 attempt failed at P7-T2, so no partial credit
carried over and the loop restarted from this task.

Command: `for r in tools scripts .claude/lib/bash; do [ -d "$r" ] && find "$r" -type f -print0; done | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum`
Before digest: `642907b7252c94350acbb6909218f27d097521ce93dc1900730ceccb5ced1db7`

Command: `bash scripts/bash/shell-qc.sh format`
EXIT_CODE: 0

Command: (same digest command)
After digest: `642907b7252c94350acbb6909218f27d097521ce93dc1900730ceccb5ced1db7`

Output Summary: the two digests are identical, so the formatter rewrote nothing and the loop does
not restart. The digest is the observation that can fail: `shfmt -w` prints nothing and exits 0
on both a clean run and a repairing one, so the exit code alone cannot distinguish them.

The run is not vacuous: `run_format` (`scripts/bash/shell_qc_lib.sh:204-222`) prints a skip
message when discovery finds no scripts and prints the missing-tool block when shfmt cannot be
resolved. Neither message appeared, so shfmt ran over the discovered file list. As a per-file
confirmation, `shfmt -d scripts/bash/cleanup_worktrees_dirt_lib.sh` exits 0 with no output.

The digest value differs from the one recorded in
`evidence/qa-gates/shell-qc-check-failure.2026-09-08T03-10.md` for two reasons that are both
expected: that digest was computed under WSL over a checkout with different line-ending handling,
and the tree has since gained the two wrapper-driven tests and the SC2034 suppression. Only the
before-and-after equality within one sequence is asserted, not equality across sequences.
