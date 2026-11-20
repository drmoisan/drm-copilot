Timestamp: 2026-09-07T17:40
Command: bash scripts/bash/shell-qc.sh format
EXIT_CODE: 0
Output Summary: shfmt -w rewrote nothing (no stdout on the clean run, per `run_format` in
scripts/bash/shell_qc_lib.sh:204-224). Immediately afterward, `git status --porcelain -- scripts/bash
tests/shell` produced empty output, confirming this was a no-op run and not a repairing one.
