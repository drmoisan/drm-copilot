# Baseline Shell Coverage

Timestamp: 2026-11-03T12-30
Task: [P0-T5]
Route: C (CI dispatch of `.github/workflows/_shell-coverage.yml` on `bug/cleanup-preserve-older-snapshot-1027-r2`, run 41634792230, head commit 0fa5e2f89, conclusion success).
Route W attempt: started (WSL Ubuntu resolves kcov, bats, shfmt, and shellcheck in a login shell) but did not produce a usable result. The kcov output directory under the `/mnt/c` mount was empty, so no `cov.xml` and no `Bash coverage (lines):` headline were written, and two negative-control tests in `tests/shell/test_cleanup_worktrees_dirt_classify.bats` (434, 456) failed only under that mount. Per the plan, Route C replaced Route W.
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-preserve-older-snapshot-1027-r2 (the job runs `bash scripts/bash/shell-qc.sh test --coverage`); results read with `gh run view 41634792230 --log` and `gh run download 41634792230 -n shell-coverage`
EXIT_CODE: 0
Output Summary:
- TAP plan line: `1..733`; `not ok` count: 0.
- Headline: `Bash coverage (lines): 95.2%` (cov.xml aggregate line-rate 0.952, 3272 of 3437 lines).
- `cov.xml` line-rate of `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`: 0.906.
- `cov.xml` line-rate of `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`: 0.976.
- For reference, `cleanup_worktrees_preserve_eol_lib.sh`: 0.870.
