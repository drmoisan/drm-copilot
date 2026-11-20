# Preflight Fixes — regenerate-after-integration-merge (Issue #1156)

Timestamp: 2026-11-09T22-22
Plan: docs/features/active/regenerate-after-integration-merge-1156/plan.2026-11-09T16-31.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects are returned separately; the fixes below are task-text and preamble edits only, with no task added, removed, or reordered)

## Fixes

1. `## Execution Rules` | validator-blind existing-test constraint | Added a `Library convention` bullet naming the existing disk-discovering suite `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` and the three conventions it asserts for every `.psm1` under `.claude/lib`. The suite is unchanged; the new modules of [P1-T1], [P1-T2], and [P1-T3] fall inside its discovery, so the [P6-T2] zero-failure condition already required it. No assertion changes.
2. `[P3-T2]` | glob tokens in plan prose (owner constraint) | Replaced the two wildcard test-file references with the enumerated files present in `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`. The disposition (unchanged) is the same.
3. `## Test Plan` | glob tokens in plan prose (owner constraint) | Replaced each `.*` evidence suffix with the `.<timestamp>.md` form used elsewhere in the plan.
4. `[P4-T1]` | literal-formatting inconsistency with the asserted token | The task text said "writes no `cycles[]` entry", which does not contain the [P4-T6] token `writes no remediation_loop.cycles[] entry`. The text now states that phrase in plain text without backticks. The [P4-T6] assertion is unchanged.
5. `[P4-T7]` | incomplete citation of the fixture shape | Named the four keys that `REQUIRED_FIXTURE_KEYS` in `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py` demands (`name`, `notes`, `checkpoint`, `expected_errors`). The plan named only `name` and `expected_errors`. No assertion changes.
