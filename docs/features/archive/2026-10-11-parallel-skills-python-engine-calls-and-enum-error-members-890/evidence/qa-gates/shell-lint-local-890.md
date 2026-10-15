# Local Shell Lint Pre-Check (Issue #890)

Task: P1-T15 (pre-check before mirroring). Both tools were run by direct invocation, never through `sh`, `bash`, or `pwsh`. CI `shell-qc.sh check` (read in P2-T14) remains the authoritative gate; local versions differ from the CI pins (CI pins shfmt 3.8.0 and uses apt shellcheck).

## shfmt

Timestamp: 2026-10-12T20-19
Command: `shfmt -d .claude/lib/bash/parallel-mutation.sh .claude/lib/bash/remove-parallel-item.sh .claude/lib/bash/parallel-mutation-cli.sh .claude/lib/bash/parallel-mutation-ops.sh .claude/lib/bash/mutate-parallel-run.sh`
EXIT_CODE: 0
Output Summary: empty output (no diff; no file would change). Local version: shfmt v3.12.0.

## shellcheck

Timestamp: 2026-10-12T20-19
Command: `shellcheck .claude/lib/bash/parallel-mutation.sh .claude/lib/bash/remove-parallel-item.sh .claude/lib/bash/parallel-mutation-cli.sh .claude/lib/bash/parallel-mutation-ops.sh .claude/lib/bash/mutate-parallel-run.sh`
EXIT_CODE: 0
Output Summary: empty output (no findings). Local version: ShellCheck 0.11.0.

No finding required a fix; both commands passed on the first run.
