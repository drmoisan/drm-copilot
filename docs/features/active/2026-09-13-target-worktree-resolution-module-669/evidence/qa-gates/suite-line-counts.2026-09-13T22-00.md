# Pester Suite Physical Line Counts

Timestamp: 2026-09-17T08:30:20-04:00
Command: @(Get-Content -LiteralPath '<suite>').Count for tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1, tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1, and tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
EXIT_CODE: 0
Output Summary: final counts 445, 404, and 88; each is under 500 (and at most 480). WorktreeResolution.Tests.ps1 was 494 before the plan's reduction (one purpose line per It); after the reduction it is 445 and still reports 48 passed, 0 failed. No split occurred.

| Suite | Before | Reduction | Final | Under 500 |
| --- | --- | --- | --- | --- |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | 494 (2026-09-17T08:28:22-04:00) | per-test comments reduced to one `# Purpose:` line per It (the Assert rationale kept; Arrange/Act/Assert comment lines removed; the blank-line separation between phases retained) | 445 | yes |
| tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | 404 | none | 404 | yes |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | 88 | none | 88 | yes |

The reduction changed comments only; every `It` name is unchanged, so the passed-test list recorded in
evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md still holds. Re-run after the
reduction: PassedCount=48, FailedCount=0, SkippedCount=0.

Split suite path:
none

## Post-QC addendum (2026-09-17T08:44:26-04:00)

The [P4-T3] analyzer repair (helper renames and explicit topology passing) added a few lines to the two
behavioural suites. Recounted with the same command:

| Suite | Final count after [P4-T3] repair | Under 500 |
| --- | --- | --- |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | 448 | yes |
| tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | 408 | yes |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | 88 | yes |

All three remain at most 480. Module counts at the same time: WorktreeResolution.psm1 480,
WorktreeTargetResolution.psm1 341.
