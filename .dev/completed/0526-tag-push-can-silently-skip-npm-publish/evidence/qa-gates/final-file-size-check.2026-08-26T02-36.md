# Final QA Loop — Stage 6 — 500-Line File-Size Check

Timestamp: 2026-08-26T04-21

> Filename-stamp substitution note: the filename carries the fixed cycle stamp `2026-08-26T02-36`
> required by the plan, whose acceptance conditions assert exact filenames. The `Timestamp:` field
> records the actual execution stamp, `2026-08-26T04-21`. Same convention as Phases 0 through 3.

Command: `pwsh -NoProfile -Command 'Get-ChildItem -Path ./scripts/dev-tools/Invoke-ReleaseVerification.ps1, ./scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1, ./scripts/dev-tools/Invoke-ReleaseTagPush.ps1, ./scripts/dev-tools/Invoke-ReleaseReconciliation.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | ForEach-Object { $_.Name + " " + @(Get-Content -LiteralPath $_.FullName).Count }'`

EXIT_CODE: 0

## Output Summary

The 500-line cap in `.claude/rules/general-code-change.md` applies to production code, test code, and
reusable script files alike. **All seven paths are at or under the cap.**

| # | Path | Line count | Headroom under 500 |
|---|---|---|---|
| 1 | `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | **421** | 79 |
| 2 | `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` | **156** | 344 |
| 3 | `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | **278** | 222 |
| 4 | `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` | **166** | 334 |
| 5 | `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | **364** | 136 |
| 6 | `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1` | **125** | 375 |
| 7 | `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | **497** | **3** |

Maximum observed line count: 497. No path exceeds 500.

### Files that grew during this phase group, and by how much

Only one file in the list changed during Phases 4 through 7:
`tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` grew from **491 to 497 lines**, a net
increase of **6 lines**.

The growth is entirely attributable to the stale-mock correction applied in this phase group. The
`Invoke-TagPublishVerification` mock in that file still declared the two parameters
`[int]$IntervalSeconds` and `[int]$MaxAttempts`, which the production function no longer has after
task P2-T1 replaced them with six per-check budgets. The file was green only because
`Invoke-ReleaseTagPushGuarded` passes neither, so the stale parameters went unbound. Bringing the
mock's `param()` block into parity with the production signature replaced 2 parameter declarations
with 6 and 1 discard statement with 3, for a net of +6 lines.

### Headroom note, recorded deliberately

`tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` at 497 lines has **3 lines of headroom**
under the cap. It is within the cap and this stage passes, but the margin is narrow enough that the
next addition of any size to that file will breach it.

This is the same file already recorded as minor finding **m1** in
`remediation-inputs.2026-08-26T02-36.md`, which flagged it at 491 lines as being "within 10 lines of
the 500-line cap". m1 is explicitly out of scope for this remediation cycle, and no task in the
approved plan authorizes splitting that file. The condition is therefore recorded here rather than
acted on, so that the narrowed margin is visible to the maintainer who dispositions m1.

The sibling file named by m1, `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, was resolved as a
side effect of Phase 1: the module split brought it from 499 lines down to 421.

The stage changed no file on disk. The loop proceeds to stage 7 (`P7-T7`, test purity) without a
restart. This is loop iteration 1.
