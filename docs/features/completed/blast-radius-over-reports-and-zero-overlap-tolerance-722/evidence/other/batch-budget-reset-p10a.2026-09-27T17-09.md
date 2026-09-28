# PowerShell Batch-Budget Reset, Phase 10 First Batch (P10-T1)

Timestamp: 2026-09-27T17-09
Command: sh SCRATCH/run-ps.sh SCRATCH/reset-batch-budget.ps1 -Kind powershell
EXIT_CODE: 0
Output Summary: The reset script (A8) exited 0 and removed one PowerShell batch-budget state file ("RESET removed=1"). The first PowerShell batch of Phase 10 (P10-T2 through P10-T6: three production and two test files) opens with an empty budget.

## Printed output

```text
RESET file=powershell-batch-budget.worktree-agent-a7614a4e8c3c79cff-ef7479b3.json
RESET removed=1
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
