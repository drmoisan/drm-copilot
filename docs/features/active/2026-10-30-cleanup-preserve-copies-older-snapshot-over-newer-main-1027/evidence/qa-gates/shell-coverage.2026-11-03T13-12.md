# QA Gate: Shell Tests with Coverage (loop pass 2)

Timestamp: 2026-11-03T13-12
Task: [P7-T3] (re-run after the self-review remediation)
Route: C (CI dispatch of `.github/workflows/_shell-coverage.yml` on `bug/cleanup-preserve-older-snapshot-1027-r2`, run 41640864723, head commit 456b9da17, conclusion success). Route W is not used because at baseline it wrote no `cov.xml` under the `/mnt/c` mount.
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-preserve-older-snapshot-1027-r2 (the job runs `bash scripts/bash/shell-qc.sh check` and then `bash scripts/bash/shell-qc.sh test --coverage`); results read with `gh run view 41640864723 --log` and `gh run download 41640864723 -n shell-coverage`
EXIT_CODE: 0
Output Summary:
- TAP plan line: `1..761` (baseline 733; plus 19 merge, 7 fallback, and 2 commit-phase merge tests); 0 `not ok`.
- Headline: `Bash coverage (lines): 95.3%` (cov.xml aggregate line-rate 0.953, 3377 of 3543 lines); `Bash coverage 95.3% meets the minimum line coverage of 85%.`
- `cov.xml` line-rate of `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh`: 0.990 (one uncovered line: the `done` line of the line-split loop, which kcov does not attribute).
- `cov.xml` line-rate of `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`: 0.908.
- `cov.xml` line-rate of `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`: 0.977.
