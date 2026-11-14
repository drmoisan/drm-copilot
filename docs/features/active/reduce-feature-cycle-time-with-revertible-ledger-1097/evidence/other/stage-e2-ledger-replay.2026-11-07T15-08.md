# Stage E2 Ledger Replay (entry 0006, with the template paths)

Timestamp: 2026-11-07T15-08
Command: sh-launched PowerShell 7 running SCRATCH/issue-1097-replay.ps1 -BaseRef <first parent of the reduction: 0006 partial-revert commit>: Test-ProcessReductionLedger over Read-ProcessReductionLedger; git apply -R --check of docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch; Invoke-ProcessReductionRevert of every 0006 Revert Block per path compared with git show <base>:<path>; every Current fence of every entry counted in its target
EXIT_CODE: 0
Output Summary:
  ledger-valid=True rows=6 entries=6 patches=0001-parallel-only-test-gates.patch,0006-test-suite-baseline-restored.patch
  apply-R-check-exit=0
  blocks-0006=25
  replay .agents/skills/atomic-plan-contract/SKILL.md blocks=6 equals-base=True
  replay .claude/skills/atomic-plan-contract/SKILL.md blocks=6 equals-base=True
  replay .claude/skills/execution-environment/SKILL.md blocks=2 equals-base=True
  replay .github/skills/atomic-plan-contract/SKILL.md blocks=6 equals-base=True
  replay docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md blocks=5 equals-base=True
  current-fences-checked=155
  failures=0
  The first partial-revert commit omitted the five templates under docs/features/templates/ (a path filter excluded all of docs/features/ instead of the feature folder only). This replay follows the fix: the stored patch is regenerated from the first parent of that commit over 205 paths, and the entry's Files Changed lists them.
