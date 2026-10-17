# Remediation Inputs — Issue #523 (cycle 1)

- Timestamp: 2026-09-30T15-20
- Issue: #523 (epic #771 child)
- Branch: bug/blocked-reason-premise-falsified-halt-523-r2 (head fee83a65)
- Source: execution-time finding at plan task P10-T4 of `plan.2026-09-29T15-52.md` (scope-change rule: a finding outside the approved plan opens a new remediation cycle)
- Evidence: `evidence/qa-gates/poshqc-test-final.md`

## Finding F1

- Severity: Blocking
- Check: full Pester gate (`mcp__drm-copilot__run_poshqc_test`), P10-T4
- Failing test: `enforcement hooks supply the checkpoint path explicitly.the orchestrator-state module keeps its four hundred ninety-nine line count`
- Location: `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, the `It` at line 153; assertion `$lineCount | Should -Be 499` at line 163.
- Origin: added by #673 (commit 1329b43e). Its comments state the intent: the #673 spec required that change set to leave `.claude/lib/orchestrator-state/OrchestratorState.psm1` unmodified, and the file sat one line below the repository's 500-line cap, so the count was pinned rather than bounded.
- Cause: #523 Phase 5 (P5-T1) intentionally replaced the 11-line `VALID_BLOCKED_REASONS` block with the 4-line grouped form. The module is now 492 lines (both copies; `git diff --numstat` against the integration ref prints `6	13`). The test passed at the P0-T26 baseline and fails only because of this approved edit.
- Not a pre-existing failure: it is absent from the P0-T26 failing set, so P10-T4's acceptance ("every failing test-case name in this run is in the P0-T26 set") cannot be met.

## Constraints for the remediation plan

- The approved #523 edit to `OrchestratorState.psm1` stays; do not re-add lines to satisfy the pin.
- The durable invariant behind the pin is the 500-line cap in `.claude/rules/general-code-change.md`; the #673 "unmodified" requirement was scoped to the #673 change set and is not a standing invariant.
- Do not modify `.claude/hooks/`, hook state, batch-budget hook files or their tests (issue #769), `.claude/rules/`, or `.github/instructions/`.
- The test file is outside the #523 plan's P7-T14 permitted change set; the remediation plan must record the addition of this one path to the change set and the reason.
- After the fix, the original plan's restart rule applies: the final QA loop resumes from P8-T1 of `plan.2026-09-29T15-52.md` and runs through P12-T4.
