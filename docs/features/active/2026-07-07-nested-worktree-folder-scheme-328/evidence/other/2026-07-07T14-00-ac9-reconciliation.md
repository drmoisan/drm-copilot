# AC9 Reconciliation (R3, Issue #328)

Timestamp: 2026-07-07T13-59

## AC9 Criterion (verbatim, unchanged)

"All existing tests affected by the scheme change are updated, and new behavior (parent-directory creation, `ensureParentDirectory` command, empty-parent cleanup, new-scheme encoding matches) has unit coverage meeting repository thresholds (line >= 85%, branch >= 75%)."

## Source-File State (confirmed, no text change)

- `spec.md` lines 273-276: `- [x]` — checked.
- `user-story.md` lines 80-83: `- [x]` — checked.
- Both checkboxes are `[x]` with byte-identical criterion text. No modification was made to either criterion's wording; this task only confirms the existing state.

## Consistency with the Phase 2 Coverage Disposition

The AC9 `[x]` state is consistent with a PASS evaluation given the Phase 2 dispositions:
- Tests affected by the scheme change are updated: the PowerShell suite was updated to dot-source the whole script for valid coverage attribution and a new `Invoke-GitWorktreeAdd` seam test was added (P1-T3, P1-T4); TypeScript tests were completed in the prior implementation cycle.
- Unit coverage meeting repository thresholds:
  - Line: the changed file's coverable surface is fully covered (46/46 = 100%); the whole-file 61.33% figure is below 85% only because of structurally uncoverable surface, discharged by the sanctioned line-coverage exception dossier (`../regression-testing/fail-before-exception.2026-07-07T14-00-ps-line-coverage.md`, P2-T3).
  - Branch: Pester emits no BRANCH metric; the per-branch enumeration shows 14/14 coverable outcomes exercised (100%; 87.5% counting structurally-uncoverable outcomes), discharged by the sanctioned branch-coverage exception dossier (`../regression-testing/fail-before-exception.2026-07-07T14-00-ps-branch-coverage.md`, P2-T4).
- The prior AC9 PARTIAL evaluation in `feature-audit.2026-07-07T13-16.md` was driven by the invalid 4.88% attribution artifact and the changed file's absence from the coverage denominator. Both root causes are now resolved: attribution is valid and the file is in the committed `CodeCoverage.Path`. The remaining sub-threshold whole-file figure is dischargeable structural impossibility, not a coverage deficiency.

## Disposition

AC9 remains `[x]` in both source files with unchanged text and is consistent with a PASS re-audit evaluation.
