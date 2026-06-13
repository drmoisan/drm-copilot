# Orchestrator-State Remediation-Cycle Invariants

This rule governs remediation-cycle records in the orchestrator-state checkpoint at `artifacts/orchestration/orchestrator-state.json`. It documents three invariants that must hold for each remediation cycle so that resume and review workflows do not depend on a structurally invalid checkpoint.

## Foreign Schema Warning (do not copy verbatim)

A hardened snapshot from another repository contains a JSON Schema for the orchestrator-state artifact whose `$id` references a foreign origin (`drmoisan.github.io/mix-calculator/`). That schema MUST NOT be copied verbatim into this repository: its `$id`, its top-level required-field set, and its cycle-level `additionalProperties: false` do not match this repository's checkpoint contract. The invariants below are re-expressed here as prose and enforced by validator logic in `scripts/dev_tools/validate_orchestrator_state.py`, not by importing a foreign schema file.

## Scope and Backward Compatibility

These invariants apply only when the checkpoint contains a top-level `remediation_loop` with a `cycles` array. A checkpoint with no `remediation_loop` (the existing step-based checkpoint shape) is unaffected: it validates exactly as before and produces no new errors. The invariants are additive.

## Invariants (per remediation cycle)

1. **Non-empty `plan_path`.** Each cycle's `plan_path` must be a non-empty string. A missing value, a non-string value, or an empty/whitespace-only string is a malformed cycle.

2. **Execution requires cleared preflight.** A cycle's `execution_status` may be in `{in_progress, complete, failed}` only when that cycle's `preflight.final_status` is exactly `'clear'`. Any other preflight status with one of those execution statuses is a malformed cycle (execution was recorded before preflight cleared).

3. **Exit gate requires zero blocking findings.** When a cycle's `exit_condition_met == true`, its `blocking_count` must be `0`. A non-zero `blocking_count` with `exit_condition_met == true` is a malformed cycle (the exit gate was marked satisfied while blocking findings remained).

## Enforcement

- `scripts/dev_tools/validate_orchestrator_state.py` appends one error per violated invariant when a `remediation_loop` is present, using the existing validator message style (literal, checkpoint-context prefixed). The validator returns a list of error strings and does not mutate its input.
- The validator is consumed by the MCP tool `validate_orchestration_artifacts`; backward compatibility for existing step-based checkpoints is preserved.
