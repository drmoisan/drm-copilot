# Bash Format Baseline

Timestamp: 2026-08-12T05-28

Command: `wsl.exe -d Ubuntu --cd 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25' -- bash scripts/bash/shell-qc.sh format`

WSL Inner Command: `bash scripts/bash/shell-qc.sh format`

EXIT_CODE: 0

Output Summary: The repository Bash formatter completed successfully under the installed Ubuntu WSL distribution and made no tracked shell-file changes.

## Environment reconciliation

The initial Windows `bash scripts/bash/shell-qc.sh format` invocation selected the default `docker-desktop` distribution and returned exit code 1 because `/bin/bash` was absent. The first explicit Ubuntu invocation returned exit code 1 because `shfmt` was absent. The required `shfmt`, `shellcheck`, `bats`, and `kcov` packages were then installed in Ubuntu, and the Bash loop restarted from the successful format command above.

