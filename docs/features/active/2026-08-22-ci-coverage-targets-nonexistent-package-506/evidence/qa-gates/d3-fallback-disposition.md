# Phase 6 — Decision D3 pre-authorized fallback disposition (P6-T6)

Timestamp: 2026-08-25T23-12

Task: [P6-T6]
Class: **record-only task on the skip branch.** This task executed no command of its own; it read
the [P6-T5] artifact and recorded the branch taken. It therefore records `Timestamp:` and the
substantive content the task text prescribes, and carries **no `Command:` row and no `EXIT_CODE:`
row**.

Disposition: SKIPPED

## Why the skip branch was taken

The [P6-T5] artifact
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/green-workflow-run.md`
records run `32925230528` with `conclusion` `success` and `status` `completed`, at head SHA
`e825b5e62f7b816859eee8fae2c7e23ddb40679b`, which equals the branch head. That artifact is cited here
as the proof of the conclusion, as the task's skip branch requires.

The action branch of [P6-T6] is reachable only when the run failed **solely** because the
`Enforce Python coverage thresholds` step reported a coverage shortfall on a Python leg other than
3.13. The run did not fail at all: all four matrix legs — 3.10, 3.11, 3.12, and 3.13 — completed
successfully, so no leg reported a shortfall and the narrowing condition is not met. The action
branch is therefore not taken.

## Consequences of the skip branch

1. **The enforcement step is not narrowed.** It carries no `if` key and continues to run on every
   Python matrix leg, which is the state decision D3 prefers and which
   `test_threshold_step_runs_on_every_matrix_leg` asserts.
2. **AC-12 lands in its primary form**, verified by `test_threshold_step_runs_on_every_matrix_leg` in
   `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`. The alternative-form test
   `test_threshold_step_is_narrowed_to_the_pinned_leg` is absent from the change, so the criterion's
   "exactly one of the two tests is present" condition holds.
3. **No follow-up issue is filed and none is required.** The follow-up-issue link that the
   alternative form of AC-12 demands is an obligation of the action branch only.
4. **No superseding `spec.md` line count is recorded.** No task edited `spec.md` between [P5-T2] and
   [P6-T7], so the line count [P5-T2] recorded in the evidence index remains the reference against
   which [P6-T7] compares, as the plan states for this branch.
5. **[P6-T1] through [P6-T5] are not repeated**, and the commit authorized by the action branch is
   not made. [P6-T1] therefore stands as the last commit this plan made.

## Why the disposition is a dedicated field in a dedicated file

The value `SKIPPED` is recorded here as a `Disposition:` field and is deliberately not written as an
`EXIT_CODE:` row in any artifact, and in particular not in the [P6-T5] green-run artifact. The
repository's verification-evidence collector parses `EXIT_CODE:` as an integer; a non-integer value
makes the whole artifact unparseable, and an unparseable artifact is dropped by the collector filter
rather than degraded. Writing `EXIT_CODE: SKIPPED` into the green-run artifact would therefore remove
the sole AC-17 evidence artifact from verification entirely and yield a BLOCKED verdict under the
plan's fail-closed evidence rule. Recording the disposition in a separate field of a separate file
preserves the record at no such cost.

## Acceptance

- The disposition artifact exists and records exactly one of `Disposition: SKIPPED` or
  `Disposition: ACTION` — it records `SKIPPED`.
- The artifact carries no `EXIT_CODE:` row.
- The skip branch is recorded together with its citation of the green-run artifact.
