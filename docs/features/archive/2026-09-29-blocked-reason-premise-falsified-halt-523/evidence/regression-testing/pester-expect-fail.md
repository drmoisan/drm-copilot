# P2-T13 Pester regression and parity suites before the fix (expect-fail)

Timestamp: 2026-09-30T10-44
Command: $r=Invoke-Pester -Path tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1 -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"
Route: PowerShell execution route (scratchpad .sh file calling pwsh -NoProfile -Command, run with sh); the route additionally printed each failed test's ExpandedPath.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Printed line: `Passed=47 Failed=17` (EXIT_CODE is `[int]($r.FailedCount -gt 0)`).
- New-member acceptance failures (5): `base membership.accepts the non-mechanical member` for premise_falsified, external_dependency, policy_hold, awaiting_ci, human_decision_required.
- Case-variant rejection failures (3): `base membership.rejects the case variant NONE`, `rejects the case variant Validator_Failed`, and `PR-creation readiness.blocks readiness for NONE` (`PREMISE_FALSIFIED` was already rejected because it is not in the pre-fix vocabulary under any casing).
- Grouped-array failures (2): `publishes the mechanical and non-mechanical partitions from the oracle` (`$script:MECHANICAL_BLOCKED_REASONS` not set) and `publishes the vocabulary as none plus both partitions` (count 7, expected 12).
- Parity failures (7): plain-error equality for accepts_awaiting_ci, accepts_external_dependency, accepts_human_decision_required_without_human_interaction, accepts_policy_hold, accepts_premise_falsified, completion_blocks_premise_falsified, rejects_case_variant_none.
- Result: expected failure observed.
