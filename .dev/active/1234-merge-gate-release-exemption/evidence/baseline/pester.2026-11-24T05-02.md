# Pester Gate Phase 0 Baseline (P0-T2)

Timestamp: 2026-11-24T05-02
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run with coverage; integration and golden lanes excluded by the launcher)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-24T04-46, finished 2026-11-24T05-00; workers=8; wall-clock 741.61 s; all 8 shards exited 0; no queue timeout (exit 75) occurred.
- Counts from artifacts/pester/pester-junit.xml (written 2026-11-24T05-00): tests 29292, failures 0, errors 0, disabled 22. Failing tests: none.
- Repo-wide line coverage from artifacts/pester/powershell-coverage.xml (written 2026-11-24T05-00): 96.85% (47435 of 48976 lines).
- `.claude/hooks/enforce-epic-merge-gate.ps1`: 98.64% (145 of 147).
- `.codex/hooks/enforce-epic-merge-gate.ps1`: 99.45% (180 of 181).
- `.claude/hooks/hook-release-pull-request-context.ps1`: 100% (27 of 27).
- Counts and percentages were read by SCRATCH/issue-1234-pester-summary.ps1 from the files above, not from a PoshQC MCP result. Copies of both files are kept under SCRATCH/baseline-pester/ for the P4-T3 comparison.
