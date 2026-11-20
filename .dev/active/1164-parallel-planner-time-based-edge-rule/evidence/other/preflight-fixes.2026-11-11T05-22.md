# Preflight Fixes — Issue 1164 Remediation Plan (cycle 1, R2 preflight)

Timestamp: 2026-11-11T05-22
Plan: docs/features/active/parallel-planner-time-based-edge-rule-1164/remediation-plan.2026-11-11T04-47.md

Each fix below is a task-text correction made in place. No task was added, removed, or reordered, and no asserted value changed.

1. [P0-T2] | wording correction | "the Pyright count of `reportPrivateUsage` suppressions" replaced with "the count of `reportPrivateUsage` suppression comments in the test file, read by a search of that file". Pyright reports diagnostics and does not count suppression comments, so the former wording named a value Pyright does not print.
2. [P1-T2] | literal clarification | Each new corpus file sets its `name` field to its file stem. The TypeScript parity test titles each case from the `name` field (`reproduces the expected errors of %s`), so a copied `name` would duplicate the source case's title.
3. [P1-T3] | citation correction | The disposition of `parallel-scheduling-rule-wording.Tests.ps1` now states that no required token lies in `## Enforcement` and that the new class (1) text carries none of the suite's absence tokens. The suite's absence check reads the whole rule file, so the former "no token it reads lies in `## Enforcement`" was inaccurate; the disposition (unchanged) is the same.
4. [P2-T8] | scope clarification | The commit names the untracked review-cycle files of `<FEATURE>/` (the `2026-11-11T04-32` policy audit, code review, feature audit, and remediation inputs, and `remediation-inputs.2026-11-11T04-47.md`) and the plan. The acceptance already requires `git status --porcelain` to list no change under `<FEATURE>/`, which cannot hold while those files stay untracked.
5. Pre-Mortem `File size` | count correction | `parallel-state-shared.ts` 487 corrected to 486 logical lines and `BlastRadiusAccess.psm1` 282 corrected to 281 (`wc -l`; both files end with a line terminator). The 500-line conclusion is unchanged.
