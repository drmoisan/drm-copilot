# Phase 0 Baseline - Pester Gate (P0-T2)

Timestamp: 2026-11-14T18-45
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launched from the item worktree root by SCRATCH/issue-1187-pester-gate.sh; Invoke-PoshQCParallelTest, 8 shard workers, integration and golden lanes excluded)
EXIT_CODE: 0
Output Summary:
- Run window: 2026-11-14T18-45 to 2026-11-14T18-57 (UTC); Invoke-PoshQCParallelTest: workers=8; wall-clock=723.6s; exit code=0; all 8 shards exited 0.
- Counts (artifacts/pester/pester-junit.xml, merged): tests=26522, passed=26504, failed=0, errors=0, skipped=18 (root disabled=22).
- Pre-existing failing tests: none.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml, report LINE counter): 43686 covered / 1839 missed = 95.96%.
- .claude/hooks/invoke-pretooluse-dispatch.ps1: 37/37 lines = 100.00%.
- .codex/hooks/invoke-pretooluse-dispatch.ps1: 35/35 lines = 100.00%.
- Observation for later gates: parameter-default script blocks are instrumented lines in both dispatchers (the ReadPayload, ReadRegistry, and WriteTrace default lines are listed in the coverage report), so a new default seam line is counted in the per-file figure.
