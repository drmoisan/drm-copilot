# Preflight Fixes

Timestamp: 2026-10-31T05-28
Plan: docs/features/active/2026-10-30-docs-authoring-workflow-1037/plan.2026-10-30T18-59.md

## Fix 1 — [P0-T4]

- Defect class: literal-formatting defect (check-mode route unstated).
- Finding: `Invoke-PoshQCFormat` in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` has no check switch; it writes through its `-WriteFile` scriptblock and logs `Formatted:` per changed file.
- Change: the acceptance names check mode as `Invoke-PoshQCFormat` with a no-op `-WriteFile` scriptblock and defines the changed-file count as the number of `Formatted:` log lines. The asserted outcome (numeric count, unchanged tree) is unchanged.

## Fix 2 — [P4-T1]

- Defect class: stale citation.
- Finding: the task listed `surface-delta` options `-Base`, `-BaseSnapshot`, `-BaseLedger`, `-Profile` from the epic `### Enforcement notes from the two preparations of 1034` bullet, while the same task restricts skill text to option names recorded in [P0-T2], and the 1034 spec dispatch row declares `Option = @{ Base = 'value'; Profile = 'value' }` (1034 rejected caller-materialized `-BaseSnapshot` and `-BaseLedger` files). Following the parenthetical would fail the [P6-T2] option-membership test.
- Change: the parenthetical now reads that options are taken from the `surface-delta` row recorded in [P0-T2] and that the 1034 spec row declares `-Base` and `-Profile` only.

## Fix 3 — [P6-T2]

- Defect class: literal-formatting defect (assertion scope on the command line).
- Finding: the root-step line `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name> ...` also carries `-NoProfile`, `-File` and `-Command`, which are not dispatch-row options; "each `-<Option>` on that line" would include them.
- Change: the check applies to each `-<Option>` after the `-Command <name>` token on that line. The intended membership assertion is unchanged.

## Fix 4 — [P7-T2]

- Defect class: typo (count).
- Finding: the feature creates nine new test files (three hook suites, one helper, five structural suites) and edits two; "nine new or edited test files" omitted the two edited files.
- Change: "the three hooks, the nine new test files and the two edited test files".

## Fix 5 — [P7-T4]

- Defect class: typo (count) and evidence-path correction.
- Finding: the new Pester suites number eight (the ninth new test file is `DocsAuthoringRoles.Helpers.ps1`, which is not a suite). Spec AC "The new suites pass in seeded shuffled file-order runs ... and in a fresh single-process run over `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`" requires the fresh single-process result under `regression-testing/`, while [P7-T3] writes it under `qa-gates/`.
- Change: "eight new suites"; the `pester-shuffle.<timestamp>.md` record also carries the JUnit counts of the [P7-T3] fresh single-process run.

## Fix 6 — [P7-T6]

- Defect class: typo (count).
- Finding: the temporary-file token scan targets new test files; "nine new suites" miscounts (eight suites plus one helper).
- Change: "the nine new test files".

## Fix 7 — `## Open Questions / Notes` N5

- Defect class: stale citation (consistent with Fix 2).
- Change: "its epic options" now reads "its dispatch-row options (recorded in [P0-T2])".
