# Expect-Fail Regression Run (issue #1012)

Timestamp: 2026-10-31T10-42
Command: sh SCRATCH/issue-1012-ps.sh SCRATCH/issue-1012-pester.ps1 -ScanFolderList "tests/scripts/claude-hooks/validate-orchestrator-output-rejection.Tests.ps1;tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1" (Invoke-PoshQCTest, branch-current), then poetry run pytest -p no:cacheprovider -q --no-cov tests/scripts/dev_tools/test_parallel_mutation_rejection_signal_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Pester (artifacts/pester/pester-junit.xml): total 66, passed 12, failed 54, skipped 0
- Pytest: 24 failed, 4 passed (exit 1)
- Every failure is the expected pre-implementation failure; no row failed for an unrelated reason.

## Pester: validate-orchestrator-output-rejection.Tests.ps1 (P1-T1)

All 38 rows fail with `This test should run but it did not. Most likely a setup in some parent block failed.` The `BeforeAll` dot-source of `.claude/hooks/validate-orchestrator-output-rejection.ps1` fails because the sibling does not exist before P2-T2.

| Failing test name | Rows | Reason |
| --- | --- | --- |
| baseline mock interception probe | 1 | sibling absent (setup failed) |
| Get-ParallelMutationRejectionCode.parses the code <Code> from a valid final line | 4 | sibling absent (setup failed) |
| Get-ParallelMutationRejectionCode.tolerates a trailing CRLF after a valid line | 1 | sibling absent (setup failed) |
| Get-ParallelMutationRejectionCode.tolerates trailing blank lines after a valid line | 1 | sibling absent (setup failed) |
| Get-ParallelMutationRejectionCode.returns null for <Case> | 9 | sibling absent (setup failed) |
| Test-ParallelRunStateAbsent.returns true for <Case> | 5 | sibling absent (setup failed) |
| Test-ParallelRunStateAbsent.returns false for <Case> | 5 | sibling absent (setup failed) |
| Get-OrchestratorOutputRejectionDecision.allows when every gate holds | 1 | sibling absent (setup failed) |
| Get-OrchestratorOutputRejectionDecision.returns null for <Case> | 6 | sibling absent (setup failed) |
| Get-ParallelMutationRejectionHint.returns an empty string for <Case> | 2 | sibling absent (setup failed) |
| Get-ParallelMutationRejectionHint.names the signal form and the rule heading for a parallel NoTarget block | 1 | sibling absent (setup failed) |
| Get-ParallelMutationRejectionHint.lists every allowed code when the final line carries the prefix and an invalid code | 1 | sibling absent (setup failed) |
| sibling structure.defines exactly the four helpers and contains no import, process start, or call-operator invocation | 1 | sibling absent (setup failed) |

## Pester: validate-orchestrator-output.MutationRejection.Tests.ps1 (P1-T2)

Failing rows (16), each named as failing before P2-T1 through P2-T3:

| Failing test name | Reason |
| --- | --- |
| AC-1 allows kickoff_artifact_missing with stop_hook_active false | blocks: NoTarget (TARGET_WORKTREE_NOT_DERIVABLE), no allow path |
| AC-1 allows run_not_started with stop_hook_active false | blocks: NoTarget, no allow path |
| AC-1 allows items_in_flight with stop_hook_active false | blocks: NoTarget, no allow path |
| AC-1 allows unknown_item with stop_hook_active false | blocks: NoTarget, no allow path |
| AC-1 allows kickoff_artifact_missing with stop_hook_active true | blocks: NoTarget, repairable block not released |
| AC-1 allows run_not_started with stop_hook_active true | blocks: NoTarget, repairable block not released |
| AC-1 allows items_in_flight with stop_hook_active true | blocks: NoTarget, repairable block not released |
| AC-1 allows unknown_item with stop_hook_active true | blocks: NoTarget, repairable block not released |
| AC-4 blocks as NoTarget with the hint line when stop_hook_active is False | message lacks the hint line |
| AC-4 blocks as NoTarget with the hint line when stop_hook_active is True | message lacks the hint line |
| AC-6 blocks and lists the allowed codes when stop_hook_active is False | message lacks the allowed-code list |
| AC-6 blocks and lists the allowed codes when stop_hook_active is True | message lacks the allowed-code list |
| AC-8 allows when the only live text is blank | blocks: NoTarget, no allow path |
| AC-8 allows when the only live text is a valid checkpoint recording run-b | blocks: NoTarget, no allow path |
| AC-2 exits 0 for a valid signal with no live parallel checkpoint | hook tail exits 2 |
| AC-11 pins the hook code array to the rule section table | rule heading absent (index -1) |

Passing rows (12), as the plan requires: the probe row; AC-3 (2 rows: resolved checkpoint read with the routing seam invoked, and missing `next_step` blocks); AC-7 (Ambiguous and Rejected); AC-8 block rows (unparseable, JSON array, off-route, slugless, and resolver-NoTarget with the named slug); AC-9 (orchestrator-state and epic-orchestrator-state unchanged).

## Pytest: test_parallel_mutation_rejection_signal_contracts.py (P1-T3)

Failing (24): every test that reads the rule section or asserts a mapped code, the heading citation, or a required statement:

- test_rule_section_heading_appears_once
- test_rule_section_sits_between_enum_ownership_and_f7_seam
- test_rule_section_table_defines_four_unique_codes
- test_rule_section_states_output_signal_and_not_an_enum
- test_skill_section_emits_only_mapped_codes (6 parametrized cases)
- test_skill_emits_only_rule_codes (4 cases)
- test_skill_cites_rule_heading (4 cases)
- test_skill_states_run_existence_check_first (3 cases)
- test_skill_states_unmapped_paths_emit_no_signal (3 cases)

Passing (4): test_skill_does_not_restate_full_code_set for the four skills, which the plan permits before the change because no skill yet names a code.
