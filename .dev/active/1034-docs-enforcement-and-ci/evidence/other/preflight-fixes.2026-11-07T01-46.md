# Preflight Fixes - Issue 1034 Remediation Cycle 1

Timestamp: 2026-11-07T01-46
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T01-25.md

Every fix edits plan text only. No task was added, removed or reordered.

## Fix 1

- Location: `## Definitions`, [P2-T5] acceptance, [P3-T6] acceptance
- Defect class: stale ref in an acceptance condition, with the intent unambiguous
- Finding: `git diff MERGE_BASE HEAD` already shows changed lines inside `## Acceptance Criteria` of `spec.md` and `user-story.md`, because earlier passes and the review changed checkboxes. The condition could not pass whatever this cycle does.
- Change: added the definition `PLAN_HEAD`, derived from the commit that added this plan, and replaced the `MERGE_BASE` operand with `PLAN_HEAD` in both acceptances. The assertion that this cycle changes no line of that section is unchanged.

## Fix 2

- Location: [P1-T1] `merge target controls`, `## Acceptance Criteria Traceability`
- Defect class: scope addition not carried into task text
- Finding: `## Open Questions` adds the N6 row and the Scope line names N6, but no task text or traceability row stated it. The row passes on the current code, so it belongs with the controls and not with the rows P1-T3 requires to fail.
- Change: named the row in `merge target controls` and added an N6 traceability row. The behavior asserted is the one the scope addition states.

## Checks That Found No Defect

- Every sweep form was run through the scanner on unmodified code in a SCRATCH probe. Each form in the `merge target binding (F1)` scope either makes a lookup the row rejects or makes a `gh` call where the row requires none, so each fails before the fix, and each control holds.
- Typed `catch` for `FileNotFoundException` and `DirectoryNotFoundException` matches the exception raised through a .NET method call; a directory read raises `UnauthorizedAccessException`.
- The payload anomaly text and the planned deny text carry no path separator.
- `config/poshqc-coverage.json`, both `enforce-epic-merge-gate-command.ps1` copies, `.github/agents/feature-review.agent.md` and `.codex/agents/feature-reviewer*.toml` show no diff from `MERGE_BASE`, and the step 4 sentence is byte-identical in the eight `feature-review` files.
