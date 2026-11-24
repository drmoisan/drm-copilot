# Decisions (execution)

Timestamp: 2026-11-24T11-50
Command: none (decision record, autonomous mode)
EXIT_CODE: 0
Output Summary: planning decision repeated with the recorded state lines; both conditional case groups will be written.

## D-EXEC-1 Conditional profile-loading cases (repeats the plan's planning decision)

Plan `## Open Questions / Notes`: family and legacy-exclusion logic is proven with in-memory arrays in `DocsReviewCadence.Tests.ps1`; the profile-loading cases in `DocsValidation.ReviewCadence.Tests.ps1` and `DocsValidateCommands.ReviewCadence.Tests.ps1` are written only when the upstream schema declares the keys.

Recorded state (upstream-verification.2026-11-24T11-50.md):
- FamiliesState: PRESENT
- LegacyExclusionsState: PRESENT

Decision: write the conditional cases of P2-T2 (derived due date, legacy exclusion) and P2-T3 (derived due date, source `interval`).

## D-EXEC-2 Overdue insertion point

The overdue call goes inside the existing `if ($Mode -ceq 'docs-complete')` block of `Invoke-DocsValidation`, directly after the `Get-DocsFamilyFinding` loop (P0-T1 line (c)). Recommended option: it follows both the completion-gate findings and the family check, as D1 and the epic shared design require, and does not depend on the snapshot or ledger loading.

## D-EXEC-3 Family directory base

Repository-relative (P0-T1 line (a)); `Get-DocsReviewIntervalDays` compares the page path, which is repository-relative, with `directory` with trailing '/' removed, ordinal, at a '/' boundary.
