# Final Bash shfmt and ShellCheck Gate

Timestamp: `2026-08-11T16:44:30.0615493-04:00`

Command: `C:\Program Files\Git\bin\bash.exe scripts/bash/shell-qc.sh check`

EXIT_CODE: `0`

Output Summary: The final P6-T14 check completed successfully through the supported Git Bash entrypoint. All shell files discovered by `shell-qc.sh` were shfmt-clean and ShellCheck-clean.

## Toolchain result

- shfmt: `v3.12.0`.
- ShellCheck: `0.11.0`.
- Discovered shell files: `17`.
- Formatting findings: `0`.
- ShellCheck findings: `0`.
- New Bash suppression additions relative to baseline HEAD `fe0413d4aca1e76b2d02d05701fba79a887d5405`: `0`.
- Command elapsed time: `5.948 seconds`.

## Size and immutability checks

- Files above `500` physical lines: `0`.
- Maximum discovered shell-file size: `479` lines at `scripts/bash/cleanup_worktrees_lib.sh`.
- `.claude/` baseline/current files: `150 / 150`; manifest mismatches: `0`; status paths: `0`.
- `.codex/state`: absent.
- `git diff --check`: exit `0`, no output.

`P6_T14_STATUS: COMPLETE`
