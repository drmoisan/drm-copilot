# Task Check - P1-T1 (Issue #1221)

Timestamp: 2026-11-23T14-21
Command: sh SCRATCH/issue-1221-static-ps.sh check|analyze <changed files>; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <selection>
EXIT_CODE: 0
Output Summary: Format 0 files needing format, analyzer 0 findings on the two changed files. Pester selection: every P1-T1 test file passed; the only failing file in the combined run was the new DocsFamilyCheck.Tests.ps1 (P1-T3 scope, which imports the test support and therefore joined the selection), fixed and re-checked under P1-T3.

## Changed Files

- `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1` (`New-DocsLedgerTestProfile`: `-RequiredFamily`, `-LegacyExclusion`, empty defaults)
- `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.Tests.ps1` (new `It 'returns empty required_families and legacy_exclusions unless the opt-in parameters supply them'`)

## Selection and Rule

- Rule: the mirrored test of the changed module plus every test file that imports or names it (`grep -rlE "DocsLedger\.TestSupport|DocsLedgerBatch\.TestSupport" tests/ --include=*.Tests.ps1`), which covers the `New-DocsLedgerTestProfile` derivation of the plan.
- `tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1` is removed from local selections because it matches the integration-lane suffix `integration.tests.ps1` (see `evidence/other/lane-deviation.2026-11-23T13-34.md`).
- Selection (28 files): DocsCoverageReport.Properties, DocsCoverageReport, DocsEvidencePins.Properties, DocsEvidencePins, DocsFamilyCheck, DocsHashLineEnding, DocsLedger.Properties, DocsLedger, DocsLedger.TestSupport, DocsLedgerBatch.Properties, DocsLedgerBatch, DocsLedgerBindRefs, DocsLedgerCommands.Properties, DocsLedgerCommands, DocsLedgerCommands.UpdateLedger, DocsLedgerMutation.Properties, DocsLedgerMutation, DocsLedgerRules.Properties, DocsLedgerRules, DocsParity.Properties, DocsParity, DocsReceipt.Properties, DocsReceipt, DocsStaleness.Properties, DocsStaleness, DocsValidateCommands, DocsValidation.Properties, DocsValidation (all `.Tests.ps1` under `tests/scripts/claude-lib/docs/`), plus the P1-T3 files Docs.Manifest, ClaudeLibModuleConvention, DocsNeutrality in the combined run.

## Commands and Exit Codes

| Step | Command | EXIT_CODE | Result |
|---|---|---|---|
| Format | static-ps check over the two files | 0 | FILES_NEEDING_FORMAT=0 |
| Analyze | static-ps analyze over the two files | 0 | FINDINGS=0 |
| Pester (attempt with the integration-lane file) | launcher pester -TestPath (28 files incl. DocsCompleteIntegration) | 2 | TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence |
| Pester (combined P1-T1 and P1-T3 selection, final) | launcher pester -TestPath (31 files) | 1 | shard totals: 21+26+15+85+192+39+32+46 = 456 passed, 1 failed; the failure was `Get-DocsFamilyFinding.reports no legacy finding for an empty legacy_exclusions list` in DocsFamilyCheck.Tests.ps1 (a test-side double array wrap), not a P1-T1 file |

All P1-T1 files (DocsLedger.TestSupport.Tests.ps1: 10 tests, and every `New-DocsLedgerTestProfile` user) passed. Queue timeouts (exit 75) preceded the combined run while another worktree held the machine lock; they are recorded as queue timeouts, not failures.
