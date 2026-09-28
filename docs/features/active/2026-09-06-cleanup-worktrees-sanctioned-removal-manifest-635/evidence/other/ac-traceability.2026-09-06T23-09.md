# Acceptance-Criteria Traceability Record — Issue 635

Timestamp: 2026-09-08T08-52

Task: [P8-T8]

Command:
`grep -n "^- \[.\] \*\*AC-" docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/spec.md`

EXIT_CODE: 0

## Scope and source

Work mode is `full-bug`, so `spec.md` is the sole resolved acceptance-criteria source per
`.claude/skills/acceptance-criteria-tracking/SKILL.md`. `user-story.md` is present in the feature
folder but is not an AC source under this mode and is not read for check-off.

This record is the final reconciliation of checkbox state, not the first time any box was set. The
skill directs check-off as each plan task passes verification, so most boxes were set during Phases
1 through 7 as their tasks completed. [P8-T5] decided the last outstanding criterion.

## Reconciliation result

| Measure | Count |
| --- | --- |
| Criteria in `spec.md` | **37** |
| Checked `- [x]` | **37** |
| Unchecked `- [ ]` | **0** |

Verified mechanically rather than by inspection: `grep -c "^- \[x\] \*\*AC-"` returns **37** and
`grep -c "^- \[ \] \*\*AC-"` returns **0** against `spec.md`, and the two counts sum to the 37
criteria the specification defines. No criterion text was modified; the only edits were `- [ ]` to
`- [x]`. No criterion was added to `spec.md`.

## Mapping — 37 identifiers, each appearing exactly once

| AC | Plan task that satisfies it | Evidence artifact that proves it | Final checkbox state |
| --- | --- | --- | --- |
| AC-01 | [P3-T8] | `evidence/regression-testing/pass-after-manifest-allow-epic.2026-09-06T23-09.md` | `[x]` |
| AC-02 | [P3-T9] | `evidence/regression-testing/pass-after-manifest-allow-parallel.2026-09-06T23-09.md` | `[x]` |
| AC-03 | [P3-T6] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-04 | [P3-T7] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-05 | [P3-T10] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-06 | [P3-T11] | `evidence/qa-gates/non-widening-pin.2026-09-06T23-09.md` | `[x]` |
| AC-07 | [P3-T12] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-08 | [P3-T13] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-09 | [P3-T14] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-10 | [P3-T15] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-11 | [P3-T16] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-12 | [P3-T17] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-13 | [P3-T18] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-14 | [P3-T19] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-15 | [P3-T20] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-16 | [P3-T21] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-17 | [P3-T22] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-18 | [P3-T23] | `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` | `[x]` |
| AC-19 | [P1-T3] | `evidence/qa-gates/batch-a-suite.2026-09-06T23-09.md` | `[x]` |
| AC-20 | [P1-T3] | `evidence/qa-gates/batch-a-suite.2026-09-06T23-09.md` | `[x]` |
| AC-21 | [P6-T6] | `evidence/qa-gates/push-down-resource-contracts-state-exempt.2026-09-06T23-09.md`, reconfirmed by `evidence/qa-gates/push-down-resource-contracts-state-exempt-final.2026-09-06T23-09.md` | `[x]` |
| AC-22 | [P6-T5] | `evidence/qa-gates/pack-manifest-completeness.2026-09-06T23-09.md` | `[x]` |
| AC-23 | [P6-T7], contributed to by [P1-T9] | `evidence/qa-gates/no-python-guard-final.2026-09-06T23-09.md` | `[x]` |
| AC-24 | [P6-T3] and [P6-T4] | `evidence/qa-gates/final-coverage.2026-09-06T23-09.md` | `[x]` |
| AC-25 | [P8-T5] | `evidence/qa-gates/final-coverage.2026-09-06T23-09.md` | `[x]` |
| AC-26 | [P7-T1] | `evidence/qa-gates/hookpayload-no-diff.2026-09-06T23-09.md` | `[x]` |
| AC-27 | [P7-T5], contributed to by [P1-T10] and [P3-T25] | `evidence/qa-gates/line-counts-final.2026-09-06T23-09.md` | `[x]` |
| AC-28 | [P7-T6] | `evidence/qa-gates/no-temp-files.2026-09-06T23-09.md` | `[x]` |
| AC-29 | [P7-T2] | `evidence/qa-gates/codex-hook-no-diff.2026-09-06T23-09.md` | `[x]` |
| AC-30 | [P7-T3] | `evidence/qa-gates/scope-boundary-no-diff.2026-09-06T23-09.md` | `[x]` |
| AC-31 | [P7-T4] | `evidence/qa-gates/must-not-touch-intact.2026-09-06T23-09.md` | `[x]` |
| AC-32 | [P4-T1] | `evidence/qa-gates/skill-text-verification.2026-09-06T23-09.md` | `[x]` |
| AC-33 | [P4-T2] | `evidence/qa-gates/skill-text-verification.2026-09-06T23-09.md` | `[x]` |
| AC-34 | [P4-T3] | `evidence/qa-gates/skill-text-verification.2026-09-06T23-09.md` | `[x]` |
| AC-35 | [P4-T4] | `evidence/qa-gates/skill-text-verification.2026-09-06T23-09.md` | `[x]` |
| AC-36 | [P4-T5] | `evidence/qa-gates/skill-text-verification.2026-09-06T23-09.md` | `[x]` |
| AC-37 | [P8-T4], together with [P8-T1] and [P8-T3] | `evidence/qa-gates/final-test-mcp.2026-09-06T23-09.md` | `[x]` |

The table contains exactly **37** rows, one per identifier, with no identifier repeated and none
omitted. The plan-task column was derived from the `(Satisfies AC-nn.)` annotations carried in the
plan's task text rather than assigned by judgement, so a third party re-reading the plan obtains the
same assignment. Where an annotation reads `Contributes to`, the completing task is listed first and
the contributing tasks are named after it.

For `AC-32` through `AC-36` the evidence artifact named is
`evidence/qa-gates/skill-text-verification.2026-09-06T23-09.md`, written by [P4-T6], which is the
only artifact recording the Phase 4 skill-text searches. Tasks [P4-T1] through [P4-T5] each edited
`SKILL.md` and name no artifact of their own, so citing their individual task text as evidence would
name no recorded observation.

Similarly, the Phase 3 test-authoring tasks whose acceptance is that a named `It` passes name no
artifact individually; their recorded observation is the Batch C suite run in
`evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md`, which records the three Batch C suites
reporting zero failures and zero errors between them, and which is reconfirmed at the end of the
plan by `evidence/qa-gates/final-test-mcp.2026-09-06T23-09.md`.

## Checkbox-state agreement

Every row above records `[x]`, and `spec.md` carries `[x]` for every one of the 37 criteria. The
recorded state therefore matches the state of each criterion in `spec.md` for all 37, with no row
disagreeing.

## Two explicit negative statements required by this task

**No criterion asserts that the `bash <file>` indirection is closed.** `AC-36` is the only criterion
that mentions the indirection, and it asserts the opposite: that `SKILL.md` **records the
`bash <file>` indirection as an accepted residual**, using the `enforce-pr-author-skill.ps1:35-41`
posture of a policy-level integrity check that prevents accidental bypass and requires a deliberate,
documented act to circumvent, and which is explicitly not a cryptographic or security boundary. The
indirection is carried forward as item 4 of the plan's `Deferred And Recorded, Not Executed` list
(D8), where no task in this plan changes it and no task opens a GitHub issue for it. A reader
should not infer from 37 of 37 criteria passing that the indirection was closed; it was accepted and
documented.

**No criterion asserts a permission-layer block.** A search of the entire acceptance-criteria region
of `spec.md` for the string `permission` returns matches only on the field name
`permissionDecision`, which is the value the hook functions
`Invoke-EpicWorktreeRemovalGateDecision` and `Get-ParallelWorktreeGateBlockDecision` return from
their own decision contract. That is the hook-decision layer, not the Claude permission system. The
`_BLOCKED` tokens appearing in `AC-03`, `AC-04` and `AC-05` are the leading tokens of the gates' deny
**reason strings**, again emitted by the hooks. No criterion in this specification claims that the
Claude permission layer denies, allows, or otherwise enforces any part of this feature's behaviour.

Both statements are recorded because the gap between "every criterion passes" and "the underlying
concern is fully eliminated" is exactly where an over-reading would occur, and neither property is
in evidence.

Output Summary: All **37** acceptance criteria in `spec.md` are checked `- [x]` and **0** remain
unchecked, verified by mechanical count (37 checked, 0 unchecked). This record maps all 37
identifiers, each appearing exactly once, to the plan task that satisfies it and the evidence
artifact that proves it, with the plan-task column derived from the plan's own
`(Satisfies AC-nn.)` annotations. The checkbox state recorded for every identifier matches `spec.md`
with no disagreement. `AC-25` was the final criterion decided, by [P8-T5], on the strength of CI run
`34205298954`. This record states explicitly that **no criterion asserts the `bash <file>`
indirection is closed** — `AC-36` records it as an accepted residual and it remains deferred as D8 —
and that **no criterion asserts a permission-layer block**, the only `permission` occurrences being
the hooks' own `permissionDecision` return field.
