# Final QC: Pester Suite (P7-T4, loop restart after the #1162 merge and the new-code coverage tests)

Timestamp: 2026-11-14T11-16
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (through SCRATCH/issue-1158-launch.sh); summary read from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`
EXIT_CODE: 0
Output Summary: the launcher exited 0, with no queue timeout and no refusal. `Invoke-PoshQCParallelTest` ran 8 workers, and all 8 shards exited 0; wall clock 730.75 s. The merged JUnit holds 26384 tests in 795 suites: 26366 passed, 0 failures, 0 errors, 18 skipped. Repo-wide line coverage is 95.95% (43537 covered, 1839 missed). Every PowerShell production file of this item is at or above 90% line coverage, which meets the new-code rule.

## Ledger and Registration Cases (from the merged JUnit)

| File | Test cases | Failures |
|---|---|---|
| `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` | 5 | 0 |
| `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1` | 15 | 0 |
| `tests/scripts/claude-hooks/test-execution-policy.Registration.Tests.ps1` (branch B rows) | 18 | 0 |
| `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` | 91 | 0 |

Both `has parity envelopes for enforce-test-execution-policy.ps1` rows report `Passed`.

## Lane Exclusion (spec D27 live proof)

None of the four integration-named Pester files of P0-T4 appears in the merged JUnit:

- `Invoke-ParallelAdmission.Integration.Tests.ps1`
- `DocsCompleteIntegration.Tests.ps1`
- `DocsReferenceIntegration.Tests.ps1`
- `codex-pretooluse-integration.Tests.ps1`

## Per-File Line Coverage (threshold 85%; new-code rule 90%)

| File | Line coverage |
|---|---|
| `.claude/hooks/test-execution-policy.ps1` | 100.00% (170/170) |
| `.claude/hooks/test-execution-lock-decision.ps1` | 100.00% (44/44) |
| `.claude/hooks/test-execution-lock.ps1` | 91.30% (42/46) |
| `.claude/hooks/test-execution-command-form.ps1` | 96.74% (267/276) |
| `.claude/hooks/enforce-test-execution-policy.ps1` | 91.67% (121/132) |
| `.codex/hooks/test-execution-policy.ps1` | 100.00% (170/170) |
| `.codex/hooks/test-execution-lock-decision.ps1` | 100.00% (44/44) |
| `.codex/hooks/test-execution-lock.ps1` | 95.65% (44/46) |
| `.codex/hooks/test-execution-command-form.ps1` | 96.74% (267/276) |
| `.codex/hooks/enforce-test-execution-policy.ps1` | 98.54% (135/137) |
| `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` | 92.93% (92/99) |
| `.claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1` | 94.74% (36/38) |
| `PoshQC.Testing.psm1` | 94.17% (210/223) |
| `PoshQC.Parallel.psm1` | 97.40% (150/154) |
| `scripts/dev-tools/run-poshqc-suite.ps1` | 91.07% (51/56) |
