# Non-blocking Deviation: Integration and Golden Lanes Excluded from the Local Final Gates (remediation cycle 1, P3-T5)

Timestamp: 2026-11-14T15-30
Command: comparison of the integration-named test counts in the Phase 0 baseline artifacts with the final gate artifacts of this cycle (evidence/qa-gates/coverage-comparison.2026-11-14T15-30.md)
EXIT_CODE: 0
Output Summary: the final local gates run through the launcher, which excludes the integration and golden lanes (ledger entry 0012). The Phase 0 runs included 41 Pester, 11 pytest, and 16 Jest integration-named tests; the final runs did not collect them (none of the four integration-named Pester files appears in the merged JUnit). No coverage drop is attributable to the exclusion. CI integration and golden lanes are evidence; the jobs below cover the excluded tests on the pull-request head.

## Subtracted Tests

| Gate | Files | Tests in the Phase 0 baseline | CI job of record |
|---|---|---|---|
| Pester | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1, tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1, tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1 | 30 | poshqc / PowerShell QC |
| Pester | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | 11 | poshqc / PowerShell hook suites (Linux) |
| pytest | tests/scripts/dev_tools/test_pr_context_integration.py, tests/scripts/dev_tools/atomic_executor/test_unicode_integration.py | 11 | quality-checks7 / Code Quality & Tests (3.13) |
| Jest | extensions/drm-copilot/test/extension.collect-commit-context.integration.test.ts, extensions/drm-copilot/test/extension.integration.test.ts, extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts, extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts | 16 | drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) |

The CI results of these jobs on the pull-request head are pending; the orchestrator compares them in the CI cross-check.
