# Move cleanup-worktrees Scripts into the Skill Folder (P2-T1)

Timestamp: 2026-09-28T22-02
Command: sh SCRATCH/move-cleanup-scripts.sh ; git ls-files -- .claude/skills/cleanup-merged-worktrees/scripts ; git status --porcelain -- scripts .claude/skills/cleanup-merged-worktrees/scripts
EXIT_CODE: 0
Output Summary: Ten `MOVED` lines. `git ls-files` lists exactly the ten inventory basenames under `.claude/skills/cleanup-merged-worktrees/scripts/`. Status prints exactly ten lines, each beginning `R`.

```text
R  scripts/bash/cleanup-worktrees.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh
R  scripts/bash/cleanup_worktrees_actions_lib.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh
R  scripts/bash/cleanup_worktrees_detached_lib.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh
R  scripts/bash/cleanup_worktrees_dirt_lib.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_dirt_lib.sh
R  scripts/bash/cleanup_worktrees_enumerate_lib.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh
R  scripts/bash/cleanup_worktrees_lib.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_lib.sh
R  scripts/bash/cleanup_worktrees_preserve_eol_lib.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_eol_lib.sh
R  scripts/bash/cleanup_worktrees_preserve_lib.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh
R  scripts/bash/cleanup_worktrees_report_records_lib.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh
R  scripts/bash/cleanup_worktrees_scan_helper.sh -> .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh
```
