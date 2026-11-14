# Final QC: Pester Suite (remediation cycle 1, P3-T2)

Timestamp: 2026-11-14T15-28
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (through SCRATCH/issue-1158-final-qa.sh), which runs Invoke-PoshQCParallelTest from scripts/powershell/PoshQC/PoshQC.psd1; summary read from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml (SCRATCH/issue-1158-final-report.sh)
EXIT_CODE: 0
Output Summary: the launcher exited 0 with no queue timeout and no refusal. Invoke-PoshQCParallelTest ran 8 workers, all 8 shards exited 0, wall clock 918.69 s. The merged JUnit holds 26420 tests in 796 suites: 26402 passed, 0 failures, 0 errors, 18 skipped. Repo-wide line coverage is 95.95% (43560 covered, 1839 missed). Every PowerShell production file in the branch diff from the merge base of origin/main and HEAD that lies in the coverage population is at or above 85% line coverage, and at or above 90%.

## Named Suites (merged JUnit)

| File | Tests | Failures | Skipped |
|---|---|---|---|
| tests/scripts/claude-hooks/test-execution-policy.Registration.Tests.ps1 | 18 | 0 | 2 (the Codex-only command_windows row, skipped by its -Skip condition for the two .claude registry copies) |
| tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | 792 | 0 | 0 |
| tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 43 | 0 | 0 |
| tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 | 5 | 0 | 0 |
| tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1 | 15 | 0 | 0 |
| tests/scripts/powershell/PoshQC/PoshQC.ParallelScoped.Tests.ps1 | 12 | 0 | 0 |

Lane exclusion: none of Invoke-ParallelAdmission.Integration.Tests.ps1, DocsCompleteIntegration.Tests.ps1, DocsReferenceIntegration.Tests.ps1, or codex-pretooluse-integration.Tests.ps1 appears in the merged JUnit.

## Per-File Line Coverage (PowerShell production files in the branch diff)

| File | Line coverage |
|---|---|
| .claude/hooks/test-execution-policy.ps1 | 100.00% (170/170) |
| .claude/hooks/test-execution-lock-decision.ps1 | 100.00% (44/44) |
| .claude/hooks/test-execution-lock.ps1 | 91.30% (42/46) |
| .claude/hooks/test-execution-command-form.ps1 | 96.74% (267/276) |
| .claude/hooks/enforce-test-execution-policy.ps1 | 91.67% (121/132) |
| .codex/hooks/test-execution-policy.ps1 | 100.00% (170/170) |
| .codex/hooks/test-execution-lock-decision.ps1 | 100.00% (44/44) |
| .codex/hooks/test-execution-lock.ps1 | 95.65% (44/46) |
| .codex/hooks/test-execution-command-form.ps1 | 96.74% (267/276) |
| .codex/hooks/enforce-test-execution-policy.ps1 | 98.54% (135/137) |
| .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 | 92.93% (92/99) |
| .claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1 | 94.74% (36/38) |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 94.17% (210/223) |
| scripts/powershell/PoshQC/PoshQC.Parallel.psm1 | 97.74% (173/177) |
| scripts/dev-tools/run-poshqc-suite.ps1 | 91.07% (51/56) |

The .agents copies of the launcher scripts and every bundle copy under extensions/drm-copilot/resources/ (including templates/run-poshqc-suite.ps1 and templates/run-poshqc-test.ps1) are byte-identical to files above or are outside the Pester coverage roots of config/poshqc-coverage.json; they have no entry in the coverage report.
