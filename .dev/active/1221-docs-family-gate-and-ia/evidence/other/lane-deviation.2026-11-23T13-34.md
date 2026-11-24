# Non-Blocking Deviation - Integration-Lane Test File (Issue #1221)

Timestamp: 2026-11-23T13-34
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <P1-T1 selection including tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1>
EXIT_CODE: 2
Output Summary: The launcher refused the selection with "TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence (test-execution policy)." config/test-execution-policy.json lists the integration-lane file-name suffix "integration.tests.ps1", which DocsCompleteIntegration.Tests.ps1 matches (case-insensitive ordinal suffix). The file is therefore CI-only evidence locally.

## Effect on This Plan

- `tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1` (an R1 fixture named by P1-T2 and AC-17) is excluded from every local task check and from the local Phase 0 baseline and phase gates; the full local Pester gate already excludes it through `-ExcludeTestFileSuffix`.
- Its pass is evidenced by the CI Pester shards (`poshqc / PowerShell QC shard 1` to `shard 6`, aggregated by `poshqc / PowerShell QC`), as the test-execution-policy skill requires for integration lanes.
- The file is unchanged by this item (see `r1-fixture-inventory`): its only profile source is `New-DocsLedgerTestProfile`, which declares no families after P1-T1, so the family check adds no finding to it.
- This is a non-blocking deviation; no policy file was changed.
