# Block-Reason Discrimination Suite — Unmodified and Passing (issue #413, [P4-T3])

Timestamp: 2026-07-25T17-17

Command: `pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 -Output Detailed"` (run at repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`)

EXIT_CODE: 0

Output Summary:

- Discovery: 6 tests in 1 file.
- Result: **Tests Passed: 6, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0** (733ms).

Individual results:

| Context | Test | Result |
|---|---|---|
| default routing invoker threads `--require-model-routing` | passes both `--require-complete` and `--require-model-routing` to the Python CLI | PASSED (49ms) |
| MODEL_ROUTING_BLOCKED surfacing | blocks DONE with `MODEL_ROUTING_BLOCKED` when the validator names `model_routing_receipts` | PASSED (134ms) |
| MODEL_ROUTING_BLOCKED surfacing | blocks DONE with `MODEL_ROUTING_BLOCKED` when the validator names `complexity_assessments` | PASSED (10ms) |
| MODEL_ROUTING_BLOCKED surfacing | falls back to `ROUTING_CONTRACT_BLOCKED` for a generic routing error | PASSED (7ms) |
| capability detection (portable-path routing) | surfaces `MODEL_ROUTING_BLOCKED` via the portable path for an uncovered delegated agent when the probe reports unavailable | PASSED (79ms) |
| capability detection (portable-path routing) | does not block a covered checkpoint on the portable path when the probe reports unavailable | PASSED (18ms) |

## Test file is diff-untouched

Command: `git diff --name-only -- tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1`

EXIT_CODE: 0. Output: empty — the file has no changes.

## The discrimination regex is unchanged in the hook diff

Command: `git diff -- .claude/hooks/validate-orchestrator-output.ps1`

EXIT_CODE: 0. The hook diff contains exactly two hunks:

1. `@@ -165,9 +165,15 @@` — the `.DESCRIPTION` docstring correction inside
   `Invoke-RoutingContractValidation`.
2. `@@ -219,9 +225,11 @@` — the inline decision comment and the
   `$hasErrors = ($exitCode -ne 0)` decision line inside `Invoke-RoutingContractValidation`.

Neither hunk reaches `Invoke-OrchestratorOutputValidation`, so the
`model_routing_receipts|complexity_assessments` regex that discriminates
`MODEL_ROUTING_BLOCKED:` from `ROUTING_CONTRACT_BLOCKED:` is textually unchanged. The
discrimination remains evaluated only when `HasErrors` is true, which after the fix means
only on a non-zero exit, where `ErrorText` carries the validator's stderr error lines and the
discriminating tokens appear exactly as before.

Verdict: block-reason discrimination preserved; suite passes unmodified.
