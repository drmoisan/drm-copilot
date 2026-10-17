# Baseline Shell Check (P0-T4)

Timestamp: 2026-10-01T23:14:00-04:00
Command: sh scripts/bash/shell-qc.sh check
EXIT_CODE: 0 (the Bash tool reported no error; the exit code was not echoed because the guard refuses chained forms)
Output Summary: no stdout or stderr, which is the plan's success case for SHFMT and SHELLCHECK present. The command was not denied by the guard in this session.

## Deviation D3 (single probe, then withheld)
This single run was made as a probe of the guard before operator rule Option A was applied to this task set; the guard did not deny it and it returned empty output. Under Option A the plan's remaining shell-qc invocations (P0-T5, P0-T6, P4-T1, P4-T2, P4-T4, P4-T5) are not run locally. This result is a local observation only; the CI job `shell-coverage` on the pushed head remains the authority. No pre-existing finding was printed, so there is none to list by file.
