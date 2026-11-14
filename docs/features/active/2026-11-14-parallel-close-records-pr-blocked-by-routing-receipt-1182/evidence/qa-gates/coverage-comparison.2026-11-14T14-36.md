# Coverage Comparison: PowerShell (AC-24)

Timestamp: 2026-11-14T14-36
Command: pwsh -File SCRATCH/issue-1182-summ.ps1 -Root <worktree> (reads artifacts/pester/powershell-coverage.xml of the final Invoke-PoshQCParallelTest run started 2026-11-14T14-14)
EXIT_CODE: 0
Output Summary:
- Source of post-change figures: the merged artifacts/pester/powershell-coverage.xml of the one final gate run. Source of baseline figures: evidence/baseline/pester-parallel.2026-11-14T11-50.md (Phase 0 baseline). Threshold: 85% line coverage; Pester measures no branch coverage, so no branch gate applies.
- Per-file line coverage:

| File | Phase 0 baseline | Post-change | Change | Threshold (85%) | Disposition |
|---|---|---|---|---|---|
| .claude/hooks/hook-parallel-records-context.ps1 | N/A - no pre-change run (new file) | 100.00% (57/57) | N/A | met | PASS |
| .claude/hooks/enforce-model-routing-receipt-parallel.ps1 | N/A - no pre-change run (new file) | 100.00% (21/21) | N/A | met | PASS |
| .claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1 | N/A - no pre-change run (new file) | 100.00% (32/32) | N/A | met | PASS |
| .claude/hooks/enforce-model-routing-receipt.ps1 | 96.00% (96/100) | 96.36% (106/110) | +0.36 points | met | PASS |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 96.47% (164/170) | 96.53% (167/173) | +0.06 points | met | PASS |

- New and changed lines: the three new files are fully covered; the 10 lines added to enforce-model-routing-receipt.ps1 and the 3 lines added to enforce-orchestration-preimplementation-gate.ps1 are all covered (covered-line counts rose by exactly 10 and 3).
- Repo-wide line coverage: Phase 0 baseline 96.02% (42083/43827) -> post-change 96.03% (42206/43950). No drop.
- Result: every file meets the 85% threshold and neither changed hook dropped against the Phase 0 baseline. PASS.
