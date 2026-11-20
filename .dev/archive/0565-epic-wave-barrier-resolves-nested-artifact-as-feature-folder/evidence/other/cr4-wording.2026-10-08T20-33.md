# CR-4 Wording: Old Text Absent, New Text Present

Timestamp: 2026-10-08T20-33
Command: (1) grep -c "worktree-resolution module '" .claude/hooks/enforce-epic-wave-barrier.ps1 .claude/hooks/enforce-parallel-cohort-barrier.ps1 .claude/hooks/enforce-parallel-drift-gate.ps1 (exit 1, no match); (2) grep -c "the dependency '" .claude/hooks/enforce-epic-wave-barrier.ps1 .claude/hooks/enforce-parallel-cohort-barrier.ps1 .claude/hooks/enforce-parallel-drift-gate.ps1
EXIT_CODE: 0
Output Summary: The first command prints :0 for all three files (grep exits 1 when nothing matches); the second prints :1 for all three files. EXIT_CODE records the second command, per the plan.

```
.claude/hooks/enforce-epic-wave-barrier.ps1:0
.claude/hooks/enforce-parallel-cohort-barrier.ps1:0
.claude/hooks/enforce-parallel-drift-gate.ps1:0
.claude/hooks/enforce-epic-wave-barrier.ps1:1
.claude/hooks/enforce-parallel-cohort-barrier.ps1:1
.claude/hooks/enforce-parallel-drift-gate.ps1:1
```
