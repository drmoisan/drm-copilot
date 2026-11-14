# Final QC: Pester Suite (P7-T4, loop restart after the #1159 and #1179 merges)

Timestamp: 2026-11-14T10-34
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (through SCRATCH/issue-1158-launch.sh); summary read from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`
EXIT_CODE: 0
Output Summary: the launcher exited 0, with no queue timeout and no refusal. `Invoke-PoshQCParallelTest` ran 8 workers; all 8 shards exited 0; wall clock 968.43 s. Merged JUnit: 26112 tests in 788 suites, 26094 passed, 0 failures, 0 errors, 18 skipped. Repo-wide line coverage is 95.89% (43031 covered, 1844 missed). The tree is registration branch B: the hook is a member of the four `pretooluse-dispatch.json` copies.

## Ledger and Registration Cases (from the merged JUnit)

| File | Test cases | Failures |
|---|---|---|
| `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` | 5 | 0 |
| `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1` | 15 | 0 |
| `tests/scripts/claude-hooks/test-execution-policy.Registration.Tests.ps1` (branch B rows) | 18 | 0 |
| `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` (#1159 registry and timeout-sum suite) | 91 | 0 |

In the parity suite:

- both `has parity envelopes for enforce-test-execution-policy.ps1` rows (Claude and Codex) report `Passed`, not skipped;
- both `envelope bash-direct-test-runner yields the same per-hook and combined decisions in both modes` rows pass.

## Lane Exclusion (spec D27 live proof)

None of the four integration-named Pester files of P0-T4 appears in the merged JUnit:

- `Invoke-ParallelAdmission.Integration.Tests.ps1`
- `DocsCompleteIntegration.Tests.ps1`
- `DocsReferenceIntegration.Tests.ps1`
- `codex-pretooluse-integration.Tests.ps1`

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
