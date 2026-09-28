# Ruling B State-Read Absence and Forbidden-Construct Searches

Timestamp: 2026-09-17T08:20:22-04:00
Command: for each of .claude/lib/worktree-resolution/WorktreeResolution.psm1 and .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1: Select-String -LiteralPath <module> -SimpleMatch -Pattern <token> for Start-Process, Invoke-Expression, Invoke-WebRequest, Invoke-RestMethod, Get-Date, $env: ; Select-String -LiteralPath <module> -Pattern '(^\s*|[&|;=(]\s*)git(\.exe)?\s' ; @(Get-Content -LiteralPath <module>) | ForEach-Object { $_ -replace '#.*$', '' } | Select-String -SimpleMatch -Pattern 'orchestrator-state' (and 'checkpoint')
EXIT_CODE: 0
Output Summary: All eighteen searches return 0 matches (twelve forbidden-token searches, two git-invocation regex searches, four comment-stripped Ruling B searches). Declaration searches: 'function Resolve-WorktreeCallTarget' -> 1 and 'function Join-WorktreeResolutionPath' -> 1 in WorktreeTargetResolution.psm1.

## Declaration searches (WorktreeTargetResolution.psm1)

| Pattern | Matches |
| --- | --- |
| `function Resolve-WorktreeCallTarget` | 1 |
| `function Join-WorktreeResolutionPath` | 1 |

## Forbidden-construct searches (14; verifies spec.md:701)

| # | Module | Search | Matches |
| --- | --- | --- | --- |
| 1 | WorktreeResolution.psm1 | `-SimpleMatch Start-Process` | 0 |
| 2 | WorktreeResolution.psm1 | `-SimpleMatch Invoke-Expression` | 0 |
| 3 | WorktreeResolution.psm1 | `-SimpleMatch Invoke-WebRequest` | 0 |
| 4 | WorktreeResolution.psm1 | `-SimpleMatch Invoke-RestMethod` | 0 |
| 5 | WorktreeResolution.psm1 | `-SimpleMatch Get-Date` | 0 |
| 6 | WorktreeResolution.psm1 | `-SimpleMatch $env:` | 0 |
| 7 | WorktreeResolution.psm1 | `-Pattern '(^\s*\|[&\|;=(]\s*)git(\.exe)?\s'` | 0 |
| 8 | WorktreeTargetResolution.psm1 | `-SimpleMatch Start-Process` | 0 |
| 9 | WorktreeTargetResolution.psm1 | `-SimpleMatch Invoke-Expression` | 0 |
| 10 | WorktreeTargetResolution.psm1 | `-SimpleMatch Invoke-WebRequest` | 0 |
| 11 | WorktreeTargetResolution.psm1 | `-SimpleMatch Invoke-RestMethod` | 0 |
| 12 | WorktreeTargetResolution.psm1 | `-SimpleMatch Get-Date` | 0 |
| 13 | WorktreeTargetResolution.psm1 | `-SimpleMatch $env:` | 0 |
| 14 | WorktreeTargetResolution.psm1 | `-Pattern '(^\s*\|[&\|;=(]\s*)git(\.exe)?\s'` | 0 |

## Ruling B comment-stripped searches (4; verifies spec.md:674)

| # | Module | Token | Matches |
| --- | --- | --- | --- |
| 15 | WorktreeResolution.psm1 | `orchestrator-state` | 0 |
| 16 | WorktreeResolution.psm1 | `checkpoint` | 0 |
| 17 | WorktreeTargetResolution.psm1 | `orchestrator-state` | 0 |
| 18 | WorktreeTargetResolution.psm1 | `checkpoint` | 0 |

Total searches returning zero: 18 of 18.

Post-QC re-run (2026-09-17T08:44:26-04:00) against the final module sources (after the [P4-T3] OutputType
repair): 18 of 18 searches return zero; both declaration searches return 1.

The table escapes `|` as `\|` for Markdown only; the executed regular expression was
`(^\s*|[&|;=(]\s*)git(\.exe)?\s`.
