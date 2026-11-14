# Final QC: Pester Suite (P7-T4)

Timestamp: 2026-11-14T09-10
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (run through SCRATCH/issue-1158-launch.sh, which records the launcher exit code); summary read from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`
EXIT_CODE: 0
Output Summary: launcher exit 0, with no queue timeout (no exit 75) and no refusal. `Invoke-PoshQCParallelTest`: 8 workers, all 8 shards exit 0, wall clock 929.63 s. Merged JUnit: 25807 tests in 780 suites; 25797 passed, 0 failures, 0 errors, 10 skipped. Repo-wide line coverage 95.94% (42418 covered, 1793 missed).

## Ledger Cases (from the merged JUnit)

| File | Test cases | Failures |
|---|---|---|
| `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` | 5 | 0 |
| `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1` | 15 | 0 |

## Lane Exclusion (spec D27 live proof)

None of the four integration-named Pester files of P0-T4 appears in the merged JUnit:

| File | Present |
|---|---|
| `Invoke-ParallelAdmission.Integration.Tests.ps1` | no |
| `DocsCompleteIntegration.Tests.ps1` | no |
| `DocsReferenceIntegration.Tests.ps1` | no |
| `codex-pretooluse-integration.Tests.ps1` | no |

## Per-File Line Coverage (threshold 85%)

| File | Line coverage |
|---|---|
| `.claude/hooks/test-execution-policy.ps1` | 100.00% (170/170) |
| `.claude/hooks/test-execution-lock-decision.ps1` | 100.00% (44/44) |
| `.claude/hooks/test-execution-lock.ps1` | 86.96% (40/46) |
| `.claude/hooks/test-execution-command-form.ps1` | 96.74% (267/276) |
| `.claude/hooks/enforce-test-execution-policy.ps1` | 87.88% (116/132) |
| `.codex/hooks/test-execution-policy.ps1` | 100.00% (170/170) |
| `.codex/hooks/test-execution-lock-decision.ps1` | 100.00% (44/44) |
| `.codex/hooks/test-execution-lock.ps1` | 95.65% (44/46) |
| `.codex/hooks/test-execution-command-form.ps1` | 96.74% (267/276) |
| `.codex/hooks/enforce-test-execution-policy.ps1` | 98.54% (135/137) |
| `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` | 89.90% (89/99) |
| `.claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1` | 94.74% (36/38) |
| `PoshQC.Testing.psm1` | 94.17% (210/223) |
| `PoshQC.Parallel.psm1` | 97.40% (150/154) |
| `scripts/dev-tools/run-poshqc-suite.ps1` | 87.50% (49/56) |

Every file is at or above 85%.
