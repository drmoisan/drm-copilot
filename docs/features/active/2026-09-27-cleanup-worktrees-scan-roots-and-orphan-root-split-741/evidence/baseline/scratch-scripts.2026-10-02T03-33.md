# P0-T4 Scratch scripts A1 and A2 (deviated)

Timestamp: 2026-10-02T03-33
Command: none (plan command `sha256sum SCRATCH/changed-line-coverage.sh SCRATCH/function-identity.sh` not run; task deviated under DEV-2)
EXIT_CODE: n/a-deviated
Output Summary:
- Deviation DEV-2 (operator decision 2026-10-01, Option A, binding): the worktree isolation guard refuses command text containing bash, pwsh, or wsl, and the operator prohibited routing around it with an `sh file.sh` wrapper. Scratch scripts A1 (`changed-line-coverage.sh`) and A2 (`function-identity.sh`) are therefore not written to SCRATCH and not hashed.
- A2 replacement (P1-T6, P2-T9): in segment 3 the function-identity check is performed by `git show df5eb303129a30289a7d81775fdadaa40631be63:.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh` plus a Read/Grep comparison of the `run_report_scans` and `classify_all_branches` bodies against the working tree.
- A1 replacement (P0-T12, P2-T12): per-file line rates are read by the orchestrator from the CI `cov.xml` artifact of the shell-coverage run.
- No hash lines exist for this task.
