# Task Check [P1-T5] — remediation cycle 1 (F2)

Timestamp: 2026-11-20T19-27
Command: sh SCRATCH/issue-1016-doccheck.sh spec.md "supersedes user-story criterion (c) 1" "**A14 (decision step).**", run before the task's commit
EXIT_CODE: 0
Output Summary: The literal `supersedes user-story criterion (c) 1` occurs once, on the A14 bullet line (line 374). Lines beginning with `- [`: 53 in the worktree, 53 in HEAD. `git diff HEAD -- spec.md` changes exactly one line, the A14 bullet; no acceptance checkbox changed.

Changed files: .dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/spec.md.
Selection: none; spec.md is a feature record that no contract test reads.
