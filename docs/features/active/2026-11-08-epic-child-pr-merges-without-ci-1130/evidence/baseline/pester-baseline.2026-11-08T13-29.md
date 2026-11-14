# Phase 0 baseline: Pester

Timestamp: 2026-11-08T13-13
Command: sh SCRATCH/issue-1130-pester.sh (pwsh 7 imports the worktree scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCParallelTest -Root <item worktree>)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=855.89s; exit code=0.
- artifacts/pester/pester-junit.xml: tests=19584, failures=0, errors=0, skipped=0.
- artifacts/pester/powershell-coverage.xml repo-wide LINE: 35308 covered / 36947 = 95.56%.
- In-scope per-file LINE coverage:
  - .claude/hooks/enforce-epic-merge-gate.ps1 141/143 = 98.60%
  - .claude/hooks/enforce-epic-merge-gate-green-ci.ps1 57/57 = 100.00%
  - .claude/hooks/enforce-epic-merge-gate-review.ps1 162/163 = 99.39%
  - .claude/hooks/enforce-epic-merge-gate-authorization.ps1 102/103 = 99.03%
  - .claude/hooks/enforce-epic-merge-gate-command.ps1 55/55 = 100.00%
  - .claude/hooks/enforce-epic-merge-gate-resolution.ps1 44/47 = 93.62%
  - .codex/hooks/enforce-epic-merge-gate.ps1 167/168 = 99.40%
  - .codex/hooks/enforce-epic-merge-gate-review.ps1 151/163 = 92.64%
  - .codex/hooks/enforce-epic-merge-gate-command.ps1 55/55 = 100.00%
  - enforce-epic-merge-gate-child-ci.ps1 (both copies): new file, no pre-change run; judged against the 85% line threshold.
