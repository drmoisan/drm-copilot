# P2-T17 Post-push kcov line coverage from the pull request ci.yml run

Timestamp: 2026-10-10T10-16
Command: gh pr checks 878; gh run view 38058213183 --log --job 114230920484 | grep "Bash coverage (lines): [0-9]"; gh run view 38058213183 --log --job 114230920484 | grep -c "not ok"; gh run download 38058213183 -n shell-coverage -D SCRATCH/ci-final; grep -F 'filename=".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh"' SCRATCH/ci-final/cov.xml; awk over cov.xml for line number 352 of the enumerate library
EXIT_CODE: 0
Output Summary:
- PUSHED_SHA = e87f9788aa39158644bcf834563df2c6f5b1eea3 (PR #878 headRefOid and worktree HEAD at run time). FINAL_RUN_ID = 38058213183, FINAL_JOB_ID = 114230920484. Shell Coverage (Bats + kcov) job conclusion: success (pass, 8m5s).
- FINAL_AGGREGATE = 94.5 (log line `Bash coverage (lines): 94.5%`); BASELINE_AGGREGATE = 94.2; difference +0.3. Threshold 85.0: met.
- `grep -c "not ok"` on the job log printed 0 (grep exit 1, the pass condition).
- FINAL_ENUM_RATE = 0.954 (`line-rate="0.954"`); BASELINE_ENUM_RATE = 0.953. Thresholds 0.850 and no regression: met.
- CHANGED_LINE = 352 (`cleanup_wt_is_absolute_path "$parent" || continue`). cov.xml element: `<line number="352" hits="1"/>`, K = 1 (executed). Threshold K >= 1: met.
- Informational: scan helper line-rate 0.873 (baseline 0.873); detached library line-rate 1.000 (baseline 1.000).
- Whole PR check rollup: all 20 checks reported pass at this head.
