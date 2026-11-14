# Pester Phase 0 Baseline (P0-T2)

Timestamp: 2026-11-13T19-35
Command: sh SCRATCH/issue-1169-pester.sh p0 (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode; then SCRATCH/issue-1169-summ.ps1 reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- Gate: one Invoke-PoshQCParallelTest run, 8 shard processes, every shard exit 0, wall-clock 793.65 s; merged reports written.
- JUnit (artifacts/pester/pester-junit.xml): 21666 tests, 21656 passed, 0 failed, 0 errors, 10 skipped.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 95.83% (37807/39454).
- Per-file line coverage of the existing files this plan changes:
  - .claude/hooks/hook-docs-only-diff.ps1: 98.43% (125/127)
  - .codex/hooks/hook-docs-only-diff.ps1: 97.64% (124/127)
  - .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 96.32% (157/163)
  - .codex/hooks/enforce-orchestration-preimplementation-gate.ps1: 100.00% (173/173)
  - .claude/hooks/enforce-model-routing-receipt.ps1: 95.70% (89/93)
  - .claude/hooks/enforce-docs-complete-gate.ps1: 94.57% (87/92)
  - .claude/lib/docs/DocsCompleteGate.psm1: 100.00% (38/38)
  - .claude/lib/docs/DocsLedgerCommands.psm1: 99.14% (345/348)
  - .claude/lib/docs/DocsProfileCommands.psm1: 97.33% (73/75)
  - .claude/lib/docs/Invoke-DocsCommand.ps1: 89.56% (163/182)
- The coverage population comes from config/poshqc-coverage.json roots (.claude/hooks, .claude/lib, .claude/skills, .codex/hooks, .github/hooks, .codex/scripts, scripts), so new files under those roots are measured without a configuration change.
