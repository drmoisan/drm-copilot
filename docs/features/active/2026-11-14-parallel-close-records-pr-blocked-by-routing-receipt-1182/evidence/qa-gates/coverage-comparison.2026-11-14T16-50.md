# Coverage Comparison: PowerShell (Remediation Cycle 1)

Timestamp: 2026-11-14T16-50
Command: pwsh -File SCRATCH/issue-1182-summ.ps1 -Root <worktree> (reads artifacts/pester/powershell-coverage.xml of the one final Invoke-PoshQCParallelTest run, window 2026-11-14T16-36 to 2026-11-14T16-50)
EXIT_CODE: 0
Output Summary:
- Source of the reference figures: evidence/remediation-baseline/leg-baseline.2026-11-14T15-42.md (per-file figure from the main plan's coverage-comparison.2026-11-14T14-36.md; repo-wide figure from the Phase 0 baseline). Threshold: 85% line coverage; Pester measures no branch coverage, so no branch gate applies.

| File | Reference | Post-change | Change | Threshold (85%) | Disposition |
|---|---|---|---|---|---|
| .claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1 | 100.00% (32/32) | 100.00% (35/35) | no drop (3 added lines, all covered) | met | PASS |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 (unchanged this cycle) | 96.53% (167/173) | 96.53% (167/173) | none | met | PASS |

- Repo-wide line coverage: Phase 0 baseline 96.02% (42083/43827) -> post-change 96.03% (42209/43953). No drop.
- Result: zero failures, no per-file or repo-wide drop, per-file coverage of the changed hook above 85%. PASS.
