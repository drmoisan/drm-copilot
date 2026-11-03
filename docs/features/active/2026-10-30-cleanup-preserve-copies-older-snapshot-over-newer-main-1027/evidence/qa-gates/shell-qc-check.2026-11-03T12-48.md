# QA Gate: Shell Lint (shfmt diff and shellcheck)

Timestamp: 2026-11-03T12-48
Task: [P7-T2]
Route: L (Git Bash, local shfmt and shellcheck)
Command: sh SCRATCH/issue-1027-shell-qc.sh check (runs `scripts/bash/shell-qc.sh check`: `shfmt -d` over the discovered scripts, then `shellcheck` per file)
EXIT_CODE: 0
Output Summary: no diff output and no shellcheck finding (combined output: 0 lines). The discovered set includes the new `cleanup_worktrees_preserve_merge_lib.sh` and its bundle mirror under `extensions/drm-copilot/resources/`. CI repeats this step as `Run shell-qc check (shfmt diff + shellcheck)` in the P7-T3 run.
