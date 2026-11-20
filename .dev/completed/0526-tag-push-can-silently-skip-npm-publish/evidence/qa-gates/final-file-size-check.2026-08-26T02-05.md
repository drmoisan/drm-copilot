# Final QA — File-Size Cap — P7-T8

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

Command:

```
wc -l scripts/dev-tools/Invoke-ReleaseVerification.ps1 scripts/dev-tools/Invoke-ReleaseTagPush.ps1 scripts/dev-tools/Invoke-ReleaseReconciliation.ps1 tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
```

EXIT_CODE: 0

## Cap

`.claude/rules/general-code-change.md`: no production code, test code, or reusable script file may
exceed **500 lines**. None of the file-size exemptions applies — none of these files is a throwaway
script, a raw text fixture, or a Markdown document.

## Line counts — all eight files, measured after the P7-T1 formatter run

| # | File | Kind | Lines | Headroom | <= 500 |
|---|---|---|---|---|---|
| 1 | `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | production | **499** | 1 | PASS |
| 2 | `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | production | **278** | 222 | PASS |
| 3 | `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` | production | **166** | 334 | PASS |
| 4 | `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | test | **346** | 154 | PASS |
| 5 | `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | test | **491** | 9 | PASS |
| 6 | `tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1` | test | **89** | 411 | PASS |
| 7 | `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` | test | **150** | 350 | PASS |
| 8 | `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1` | test | **106** | 394 | PASS |

Eight line counts recorded. Every one is at most 500.

## Pre-format and post-format counts for `scripts/dev-tools/Invoke-ReleaseVerification.ps1`

The plan's "Known constraint" note requires both counts for this file to be recorded here, because
P7-T1 is the first task in the plan that runs the formatter over it: the file did not exist at the
Phase 0 baseline and no earlier phase ran a formatter pass across it.

| Measurement point | Lines |
|---|---|
| **Pre-format** (immediately before the P7-T1 `mcp__drm-copilot__run_poshqc_format` run) | **499** |
| **Post-format** (immediately after that run) | **499** |
| Delta | **0** |

**The formatter did not change the file.** The count is unchanged at 499, one line below the cap.

The remedy the plan authorizes for the case where the formatter pushes this file past 500 —
condensing comment-based help further so the file returns to at most 500 lines — was therefore **not
required and was not performed**. The helper-extraction split named in the plan's Known-constraint
note remains out of scope, as the plan states.

No `.ps1` file anywhere in the repository was rewritten by the formatter; the changed-file count
recorded by P7-T1 is 0, verified against `git status --porcelain`.

## Headroom note

Two files carry thin headroom and are flagged here for the benefit of any later change:

- `scripts/dev-tools/Invoke-ReleaseVerification.ps1` at 499 lines has **1 line** of headroom. Any
  future addition to this file breaches the cap immediately. The recorded remedy for that case is the
  helper-extraction split described in the plan's "Known constraint" note: extract
  `ConvertFrom-JsonSafely`, `Resolve-PublishStepConclusion`, `Get-RecoveryInstruction`,
  `ConvertTo-VerificationResult`, and `Get-CodexPinnedMcpVersion` into a sibling module. That split
  additionally requires a new `CodeCoverage.Path` registration in both in-repo runsettings copies and
  a new test file.
- `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` at 491 lines has **9 lines** of headroom.

Output Summary: All eight `.ps1` files added or modified by this change are at or below the 500-line
cap. Counts: 499, 278, 166, 346, 491, 89, 150, 106. The formatter changed no file, so the pre-format
and post-format counts for `scripts/dev-tools/Invoke-ReleaseVerification.ps1` are both 499 and no
comment-help condensation was required. Two files carry thin headroom (1 line and 9 lines) and are
flagged for later changes. AC23 is satisfied.
