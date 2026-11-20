# Bash Per-File Coverage from CI (P10-T6)

Timestamp: 2026-09-28T22-35
Command: gh run download 36513322997 -n shell-coverage -D SCRATCH/shell-cov-final ; poetry run python SCRATCH/cobertura-files.py SCRATCH/shell-cov-final/cov.xml scripts/ba?h/shell_qc_lib.sh <ten .claude/skills/cleanup-merged-worktrees/scripts/ paths>
EXIT_CODE: 0
Output Summary: No `MISSING` line. Each of the ten skill scripts is measured by kcov under its new `.claude/skills/cleanup-merged-worktrees/scripts/` path (the AC5 coverage observation). Every file's line-rate equals its P0-T19 baseline line-rate at the old `scripts/bash/` path, so none is lower. Total line-rate is 0.933, unchanged.

| File | Baseline line-rate (old path) | Post-change line-rate (new path) |
| --- | --- | --- |
| scripts/bash/shell_qc_lib.sh | 0.865 | 0.865 |
| cleanup-worktrees.sh | 0.976 | 0.976 |
| cleanup_worktrees_actions_lib.sh | 0.953 | 0.953 |
| cleanup_worktrees_detached_lib.sh | 1.000 | 1.000 |
| cleanup_worktrees_dirt_lib.sh | 0.942 | 0.942 |
| cleanup_worktrees_enumerate_lib.sh | 0.924 | 0.924 |
| cleanup_worktrees_lib.sh | 0.954 | 0.954 |
| cleanup_worktrees_preserve_eol_lib.sh | 0.870 | 0.870 |
| cleanup_worktrees_preserve_lib.sh | 0.906 | 0.906 |
| cleanup_worktrees_report_records_lib.sh | 0.890 | 0.890 |
| cleanup_worktrees_scan_helper.sh | 0.875 | 0.875 |

```text
COBERTURA-TOTAL line-rate=0.933
COBERTURA file=scripts/bash/shell_qc_lib.sh line-rate=0.865
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh line-rate=0.976
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh line-rate=0.953
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh line-rate=1.000
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_dirt_lib.sh line-rate=0.942
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh line-rate=0.924
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_lib.sh line-rate=0.954
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_eol_lib.sh line-rate=0.870
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh line-rate=0.906
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh line-rate=0.890
COBERTURA file=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh line-rate=0.875
```
