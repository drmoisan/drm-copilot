# Preflight In-Place Fixes (Plan A, confirming preflight after the OD-2 revision)

Timestamp: 2026-11-15T17-28
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/plan.2026-10-30T17-06.md

## Fixes

1. `## Acceptance Criteria Traceability` (plan B column) | citation correction | The plan B task identifiers were re-mapped to the current task list of `owner-decision-plan.md` and its own `## Acceptance Criteria Traceability`: SPEC-AC-06 B P0-T2 to B P0-T1; SPEC-AC-08 B P1-T6 to B P1-T5; SPEC-AC-09 B P1-T6 to B P1-T5; SPEC-AC-10 B P1-T5 to B P1-T4; SPEC-AC-12 B P1-T6 to B P1-T5, B P2-T2; SPEC-AC-16 B P2-T3 to B P2-T2, B P2-T3; SPEC-AC-21 adds B P0-T1; SPEC-AC-22 B P0-T2 to B P0-T1; SPEC-AC-23 B P2-T6 to B P2-T5; SPEC-AC-24 B P2-T5 to B P2-T2; SPEC-AC-25 B P2-T8 to B P2-T5; SPEC-AC-26 adds B P0-T4; US-AC-CP B P1-T6 to B P1-T5. The paragraph after the table now names plan B P2-T6 (the check-off task) instead of P2-T7 (the self-review task). Plan B was not edited.
2. `## Gate Shape` (task-check bullet) | stale tool-route reference | "the brief's `New-PesterConfiguration` route" replaced with a reference to the task-check Pester route stated in the brief's `## PowerShell Route and PoshQC MCP Limits` at execution time, because the O2 synchronization with `origin/main` replaces that route with the test-execution launcher. The assertion is unchanged.

## Validation

- Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan`: EXIT_CODE 0 after the fixes.
- MCP `validate_orchestration_artifacts` (`plan`): ok.
