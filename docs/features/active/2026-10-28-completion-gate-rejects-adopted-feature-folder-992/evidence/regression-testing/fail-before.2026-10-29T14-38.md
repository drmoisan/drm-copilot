# Fail-Before Run (P1-T11) [expect-fail]

Timestamp: 2026-10-29T14-38
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py -q -p no:cacheprovider --no-cov -rf
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The fix is not yet implemented (before P2-T1), so the reworked and new tests fail in all three runtimes as intended. Python: 60 failed, 52 passed.

## Corpus minimum derivation

| Enumeration | Count |
| --- | --- |
| Directory listing: `ls tests/fixtures/orchestrator_state_issue_adoption/*.json \| wc -l` | 48 |
| Python parity suite collected `test_corpus_document_reproduces_the_expected_routing_errors[...]` cases | 48 |

Value written: 48 (34 baseline plus 14 new files) to `MINIMUM_CORPUS_COUNT` in `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` and `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts`, and to `$minimumFixtureCount` in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1`.

## Per-runtime commands and results

| Runtime | Command | EXIT_CODE | Result |
| --- | --- | --- | --- |
| Python | pytest command above | 1 | 60 failed, 52 passed |
| TypeScript | `node run-jest.cjs test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts test/lib/validate/orchestrator-state-issue-adoption.test.ts test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts` (in extensions/drm-copilot) | 1 | 3 suites failed; 16 tests failed, 77 passed; the feature-folder suite fails to load (`Cannot find module '../../../src/lib/validate/orchestrator-state-feature-folder-record'`) |
| PowerShell | Invoke-Pester, one process, over `OrchestratorStateIssueAdoption.Parity.Tests.ps1`, `OrchestratorStateIssueAdoption.Tests.ps1`, `OrchestratorStateFeatureFolderRecord.Tests.ps1`, `validate-orchestrator-output.FeatureFolder.Tests.ps1` (via SCRATCH launcher) | 1 | 86 failed, 84 passed; 2 containers failed (the two new suites) |

## Failing test names

Corpus cases failing in all three parity suites (Python `test_corpus_document_reproduces_the_expected_routing_errors[...]`, Jest `issue-adoption routing-contract parity › reproduces the expected routing-contract errors for ...`, Pester `Issue-adoption routing-contract parity.reproduces the expected routing-contract errors for ...`), 15 per runtime:

- waives-new-active-feature-folder (reworked)
- valid-large-waives-feature-folder-with-record
- valid-bug-preparation-waives-feature-folder-with-record
- waives-feature-folder-record-not-object
- waives-feature-folder-path-mismatch
- waives-feature-folder-path-outside-active
- waives-feature-folder-path-dot-segment
- waives-feature-folder-path-trailing-slash
- waives-feature-folder-checkpoint-folder-absent
- waives-feature-folder-checkpoint-folder-non-string
- waives-feature-folder-record-fields-in-rule-order
- waives-feature-folder-on-remediation-route
- waives-feature-folder-with-successful-receipt
- waives-feature-folder-without-potential-to-issue
- feature-folder-record-invalid-tool-not-waived

Rewritten existing tests (one per runtime):

- Python `test_waiving_new_active_feature_folder_without_record_reports_rule_10` (observed the old `cannot be waived` error)
- Jest `resolveIssueAdoption enforces the closed waivable set (AC-8) › reports rule 10 when waiving the feature-folder tool without a record`
- Pester `Issue adoption enforces the closed waivable set (AC-8).reports rule 10 when waiving the feature-folder tool without a record`

New test files: Python `test_orchestrator_state_issue_adoption_feature_folder.py` (44 of its tests fail, including `test_require_complete_text_accepts_adopted_feature_folder`); Jest `orchestrator-state-issue-adoption-feature-folder.test.ts` (module not found); Pester `OrchestratorStateFeatureFolderRecord.Tests.ps1` (48 failed) and `validate-orchestrator-output.FeatureFolder.Tests.ps1` (22 failed).

The unchanged corpus cases `waives-validate-orchestration-artifacts`, `case-variant-tool-name`, and `absent-key-large-missing-receipt` pass in all three runtimes in this run.
