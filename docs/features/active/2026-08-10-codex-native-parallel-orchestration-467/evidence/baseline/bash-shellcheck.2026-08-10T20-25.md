# Bash Static-Analysis Baseline

Timestamp: `2026-08-10T23-12`

Exact command: `bash scripts/bash/shell-qc.sh check`

Exact command exit code: `1`

Exact command output summary: Windows resolved `bash` to `C:\WINDOWS\system32\bash.exe`; its WSL relay failed before analysis because `/bin/bash` is unavailable. Checked-file count for the exact invocation: `0`.

Corrective scoped command: `& 'C:\Program Files\Git\bin\bash.exe' scripts/bash/shell-qc.sh check`

Corrective exit code: `0`

Checked-file count: `17`

Warning count: `0`

Error count: `0`

Discovery command: `& 'C:\Program Files\Git\bin\bash.exe' -lc 'source scripts/bash/shell_qc_lib.sh; discover_shell_scripts | wc -l'`

Discovery exit code: `0`

Protected-source verification: `git diff --name-only -- .claude` returned 0 paths. Canonical `.claude/` assets remain unchanged.
