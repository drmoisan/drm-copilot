# Final QC - Pester Gate (P3-T2)

Timestamp: 2026-11-24T06-53
Command: sh <worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, 8 workers, integration and golden lanes excluded); counts from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml (SCRATCH/issue-1221-pester-summary.ps1)
EXIT_CODE: 0
Output Summary: Launcher exit 0 at head 684e3feca plus the fixed test below. tests=29739, passed=29721, failures=0, errors=0, skipped=18 (disabled=22). Repo-wide line coverage 96.87% (47676 covered, 1540 missed) against the Phase 0 baseline 96.85%. Zero new failing tests. DocsFamilyCheck.psm1 100% (95/95), at or above the 85% gate and the 90% target.

## Comparison with the Phase 0 Baseline (`pester-baseline.2026-11-23T13-14.md`)

| File | Baseline | Final | Result |
|---|---|---|---|
| repo-wide | 96.85% (47360/48901) | 96.87% (47676/49216) | no drop |
| .claude/lib/docs/DocsFamilyCheck.psm1 | new file | 100% (95/95) | >= 85% gate, >= 90% target |
| .claude/lib/docs/DocsValidation.psm1 | 98.72% (154/156) | 98.74% (157/159) | no drop |
| .claude/lib/docs/DocsValidateCommands.psm1 | 100% (102/102) | 100% (105/105) | no drop |
| .claude/lib/docs/DocsCoverageReport.psm1 | 100% (78/78) | 100% (97/97) | no drop |
| .claude/lib/docs/DocsLedgerCommands.psm1 | 99.69% (325/326) | 99.70% (329/330) | no drop |

Failing tests at baseline: none. Failing tests now: none. The test count grew from 29478 to 29739 through this item's new suites and the #1219 suites brought in by the integration merge.

## Runs

1. 2026-11-24T05-33 run (after 7 queue timeouts, exit 75, while another worktree held the lock): exit 1, 29 tests passed per shard summary except one failure in shard 7: `coverage.reports placeholder counts for pages that contain the token` (`DocsLedgerCommands.Tests.ps1`, from #1219). The test asserted that the line before the placeholder lines is the `parity` line; after the integration merge the family lines of `ConvertTo-DocsCoverageReportLine` sit between them. Fix (test side, merge integration): the assertion now expects `$lines[-5]` to be the zero `families:` summary line and `$lines[-6]` to match `^parity `; no assertion was removed. Targeted check of the file: 26 passed, 0 failed.
2. The loop restarted from step 1 (format, analyzer, TypeScript static) and the full gate was re-run: 2026-11-24T06-38 start (after 1 queue timeout), exit 0, the result above.
