# Final QC: Pester Gate (P4-T2)

Timestamp: 2026-11-24T17-21
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, coverage on, integration and golden lanes excluded; launched through SCRATCH/issue-1220-retry.sh); counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml with SCRATCH/issue-1220-pester-summary.ps1
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 783.6s, exit code 0. Tests total 30098, passed 30080, failed 0, errors 0, skipped 18. Repo-wide line coverage 96.89% (48009 covered, 1541 missed). Attempts 1 to 8 ended with launcher exit 75 (queue timeouts: the machine test-suite lock was held by other worktrees), recorded as queue timeouts, not failures; attempt 9 ran the gate.

Merged report write time (UTC): 2026-11-24T17:21:47Z.

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| .claude/lib/docs/DocsPageMetadata.psm1 | 128 | 0 | 100% |
| .claude/lib/docs/DocsPageFrontMatter.psm1 | 189 | 0 | 100% |
| .claude/lib/docs/DocsValidation.psm1 | 164 | 2 | 98.8% |
| .claude/lib/docs/DocsValidateCommands.psm1 | 108 | 0 | 100% |
| .claude/lib/docs/DocsReferenceFrontMatter.psm1 | 91 | 0 | 100% |
| .claude/lib/docs/DocsReviewCadence.psm1 (new) | 76 | 0 | 100% |
| .claude/lib/docs/DocsStaleness.psm1 | 46 | 0 | 100% |
| .claude/lib/docs/DocsCompleteGate.psm1 | 39 | 0 | 100% |

Failures: none. The 18 skipped tests equal the Phase 0 baseline skip count.
