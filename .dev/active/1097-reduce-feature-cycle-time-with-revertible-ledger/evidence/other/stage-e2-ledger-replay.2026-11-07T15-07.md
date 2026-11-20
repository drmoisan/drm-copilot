# Stage E2 Ledger Replay (entry 0006)

Timestamp: 2026-11-07T15-07
Command: sh-launched PowerShell 7 running SCRATCH/issue-1097-replay.ps1: Test-ProcessReductionLedger over Read-ProcessReductionLedger; git apply -R --check of docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch; Invoke-ProcessReductionRevert of every 0006 Revert Block per path compared with git show HEAD:<path>; every Current fence of every entry counted in its target
EXIT_CODE: 0
Output Summary:
  ledger-valid=True rows=6 entries=6 patches=0001-parallel-only-test-gates.patch,0006-test-suite-baseline-restored.patch
  apply-R-check-exit=0
  blocks-0006=25
  replay .agents/skills/atomic-plan-contract/SKILL.md blocks=6 equals-HEAD=True
  replay .claude/skills/atomic-plan-contract/SKILL.md blocks=6 equals-HEAD=True
  replay .claude/skills/execution-environment/SKILL.md blocks=2 equals-HEAD=True
  replay .github/skills/atomic-plan-contract/SKILL.md blocks=6 equals-HEAD=True
  replay docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md blocks=5 equals-HEAD=True
  current-fences-checked=155
  failures=0
  Ledger: 6 index rows, 6 entries (0001 to 0006), stored patches 0001 and 0006; 0001 Status 'Partially reverted by 0006'.
  0006 stored patch: 200 paths (git diff --binary --no-renames HEAD over the path set, taken before the commit).
  0005 fences updated in both Current and Prior so the entry still reverts on the new tree (14 blocks).
