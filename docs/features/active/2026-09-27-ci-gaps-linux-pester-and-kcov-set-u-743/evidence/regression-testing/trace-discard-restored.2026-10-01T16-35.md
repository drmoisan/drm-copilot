# Trace-Discard Restore Check (P2-T8)

Timestamp: 2026-10-01T16-35

Command: sha256sum scripts/bash/shell_qc_lib.sh (pre-mutation)
EXIT_CODE: 0
Output Summary: `a7c80174472820f587db24dd3fdf747aee464d0e4c7cd0eb4192ca8778dd4443`

Restore method: the pre-mutation file was copied to `<session-scratchpad>` before the mutation and copied back after the filtered run.

Command: sha256sum scripts/bash/shell_qc_lib.sh (post-restore)
EXIT_CODE: 0
Output Summary: `a7c80174472820f587db24dd3fdf747aee464d0e4c7cd0eb4192ca8778dd4443`, equal to the pre-mutation hash.
