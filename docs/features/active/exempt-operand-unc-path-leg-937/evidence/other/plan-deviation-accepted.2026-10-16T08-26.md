# Accepted Plan Deviation and Not-Fixed Items (issue #937, remediation cycle 1)

Timestamp: 2026-10-16T08-26
Command: git diff --numstat HEAD -- docs/features/active/exempt-operand-unc-path-leg-937/plan.2026-10-15T17-45.md
EXIT_CODE: 0
Output Summary: The numstat command printed nothing; the cycle 0 plan is not modified. PA-1 / CR-5 is recorded as an accepted deviation of cycle 0 plan task P3-T12; CR-7 is recorded as not fixed. Both orchestrator dispositions are quoted verbatim below.

Task: P3-T14 (remediation-plan.2026-10-16T03-39.md).

## Accepted deviation: cycle 0 plan task P3-T12 (PA-1, CR-5)

- Plan: `FEATURE/plan.2026-10-15T17-45.md`, task P3-T12, stays unchecked.
- Finding: policy-audit PA-1 and code-review CR-5 (`policy-audit.2026-10-16T03-39.md`, `code-review.2026-10-16T03-39.md`).
- Observed variance: the CI report row moved from 90.42% to 90.41%. The variance comes from coverage attribution on the unchanged `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` lines 116 and 335, a module this branch does not change.
- Status: accepted deviation, not fixed in this item; tracked as a separate follow-up.
- Cycle 1 observation: the cycle 1 CI report row is 90.41 at both the c1 baseline (run 38858408695) and post-change (run 38870746395); see `qa-gates/coverage-delta-c1.2026-10-16T08-25.md`.

Orchestrator disposition, quoted verbatim from `remediation-inputs.2026-10-16T03-39.md`, section "Orchestrator Scope Dispositions (cycle 1)":

> - PA-1 / CR-5 (P3-T12 report-row variance in the unchanged `WorktreeTargetResolution.psm1`): accepted plan deviation; unrelated to the #937 change surface; not fixed in this item.

## Not fixed: CR-7

- Finding: code-review CR-7, single-feature fallback in `Resolve-WorktreeOperandTarget`.
- Status: not fixed in this item.

Orchestrator disposition, quoted verbatim from the same section:

> - CR-7 (single-feature fallback in `Resolve-WorktreeOperandTarget`): unrelated module with documented fallback semantics; not fixed in this item.

## Acceptance evaluation

| Condition | Result |
|---|---|
| Contains `Timestamp:` | met |
| Names PA-1, CR-5, and CR-7 | met |
| Quotes both disposition bullets verbatim | met |
| `git diff --numstat HEAD -- docs/features/active/exempt-operand-unc-path-leg-937/plan.2026-10-15T17-45.md` prints nothing | met |
