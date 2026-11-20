# Pester Final Gate ([P2-T4])

Timestamp: 2026-11-19T11-59
Plan: plan.2026-10-30T18-39.md
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest over the scan folders of config/poshqc-scan.json, integration and golden lanes excluded); counts from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml through sh SCRATCH/issue-1032-ps.sh issue-1032-pester-summary.ps1
EXIT_CODE: 0
Output Summary: ExitCode 0 (workers 8, wall-clock 669.55s); merged JUnit: 858 test suites, 29026 tests, 29008 passed, 0 failed, 0 errors, 18 skipped (three earlier attempts exited 75, queue timeout). Repository-wide PowerShell line coverage 96.77% (47184 covered, 1575 missed), equal to the Phase 0 baseline.

ExitCode: 0

## Named Suites (tests / failures)

UPDATED-PESTER-SUITES: `claude-architecture-doc` 7/0, `documentation-workflow.CommitStage` 28/0, `less-evidence-contract` 65/0, `light-remediation-skill-contract` 66/0, `owner-directives-skill-contract` 71/0, `NestingDepthContract` 9/0, `parallel-gate-wording` 100/0, `planning-contract-wording` 87/0, `test-cadence-wording` 130/0, `docs-authoring-roles.Skills` 86/0, `docs-authoring-roles.Templates` 97/0, `docs-authoring-roles.Mirrors` 25/0 (the helper `DocsAuthoringRoles.Helpers.ps1` is exercised by these), `ProcessReductionLedger` 69/0.

UNCHANGED-AGENT-PESTER: `legacy-discovery-agent-roles` 15/0, `agents-attribution` 1/0, `DiscoveryStart` (claude-lib) 72/0, `discovery-start` (copilot-hooks; three describe-level suites) 13/0, 10/0, 21/0, `policy-toolchain-naming` 18/0.

LEDGER-CHAIN-TESTS: `ProcessReductionChain.Ledger` 5/0, `ProcessReductionLedger` 69/0. GUARD-SUITE: `copilot-layer-retirement` 16/0. `HarnessParityMatrix.RepoGate` 7/0. `FileSizePolicy.RepoGate` 5/0.
