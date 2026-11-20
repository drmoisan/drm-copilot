# QA Gate: Shell Tests with Coverage

Timestamp: 2026-11-03T12-55
Task: [P7-T3]
Route: C (CI dispatch of `.github/workflows/_shell-coverage.yml` on `bug/cleanup-preserve-older-snapshot-1027-r2`, run 41638835200, head commit 16a1a6e77, conclusion success). Route W was not used: at baseline (P0-T5) it ran but wrote no `cov.xml` under the `/mnt/c` mount, so the plan's Route C fallback applies.
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-preserve-older-snapshot-1027-r2 (the job runs `bash scripts/bash/shell-qc.sh check` and then `bash scripts/bash/shell-qc.sh test --coverage`); results read with `gh run view 41638835200 --log` and `gh run download 41638835200 -n shell-coverage`
EXIT_CODE: 0
Output Summary:
- TAP plan line: `1..759` (baseline 733; plus 17 merge, 7 fallback, and 2 commit-phase merge tests); 759 `ok`, 0 `not ok`.
- Headline: `Bash coverage (lines): 95.3%` (cov.xml aggregate line-rate 0.953, 3375 of 3543 lines); `Bash coverage 95.3% meets the minimum line coverage of 85%.`
- `cov.xml` line-rate of `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh`: 0.970 (100 measured lines; uncovered: the `cat-file` base-blob read-failure refusal, the `cat-file` merged-blob read-failure refusal, and the `done` line of the line-split loop).
- `cov.xml` line-rate of `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`: 0.908.
- `cov.xml` line-rate of `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`: 0.977.
- The same run's `Run shell-qc check (shfmt diff + shellcheck)` step passed on `ubuntu-latest` with the CI-pinned shfmt 3.8.0.
