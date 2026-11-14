# Preflight Fixes: Plan B (Issue #1025), Round 3 (Final)

Timestamp: 2026-10-31T17-40
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/owner-decision-plan.md
Preflight signal: PREFLIGHT: ALL CLEAR
Convergence: CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Round-2 Defects Re-Checked (Decision H2)

1. Override to `native` keeping `target_paths` and `generated_from`: resolved. Rule 3 removes both fields for a `native` override, rule 3a excludes `native` and `dropped` overrides from `OverridesWithoutRule`, rule 9 states that a `native` override is never unsettled for reason `pending-source`, P1-T2 asserts `NativeOverrideWithTargets: 0`, and P1-T3 asserts `NativeOverrideWithTargets: 0` and `NativeOverrideUnsettled: 0`. Consistent with spec `## Owner Stop`, Decision H2, second bullet.
2. Rule 6 versus owner overrides: resolved. Rule 1 states that an override takes precedence over the E3 result for `copilot:agent:*` entries and generally; rule 6 applies the E3 drop only to entries that are not overridden; rule 9 removes E3 as a settlement condition for overridden `copilot:agent:*` entries; P1-T3 asserts `OverrideDispositionMismatch: 0`. Consistent with spec Decision H2, first bullet.

## Language Classification Check

Compliant with the owner rule: no new Python (P2-T6 asserts `AddedPy: 0`), existing Python run only, pushed-down content limited to Markdown contracts, session-only PowerShell helpers and `sh` launchers that are never committed, no TypeScript, E2 not used.

## Fixes Applied (task text and preamble only; no task added, removed or reordered)

1. `## Decision Application Rules`, rule 1 | internal consistency | Rule 1 stated that no later rule changes an overridden entry's `decision_ref`, while rule 3 leaves a `native` override's `decision_ref` for rule 9 and rule 9 removes `decision_ref` from settled entries. Reworded rule 1 so that rules 4 to 8 do not change `decision_ref` and only rule 9 settlement sets `decision_status` and `decision_ref`. This matches rule 3, rule 9 and spec Decision H2; no acceptance condition changed.
2. `## Decision Application Rules`, rules 4 and 7 | internal consistency | Rule 1 states that the `notes` changes of rules 4 to 8 still apply to an overridden entry, but rule 3 replaces the `decision_ref` of a `dropped` override before rules 4 and 7 select entries by `decision_ref`. Rules 4 and 7 now select by the `decision_ref` plan A wrote. No acceptance condition changed.

## Validators

MCP `validate_orchestration_artifacts` (`plan`) returned `ok: true` before and after the fixes. `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exited 0 (`plan validation passed`) after the fixes.
