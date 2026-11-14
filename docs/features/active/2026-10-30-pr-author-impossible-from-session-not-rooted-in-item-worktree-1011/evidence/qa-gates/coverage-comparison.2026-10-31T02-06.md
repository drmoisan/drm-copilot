# PowerShell Line Coverage Comparison (Issue #1011, AC-15)

Timestamp: 2026-10-31T02-06
Command: sh SCRATCH/issue-1011-read-results.sh (LINE counters and per-line hits from artifacts/pester/powershell-coverage.xml written by the P6-T4 full run; baseline from the P0-T5 run)
EXIT_CODE: 0
Output Summary: both files are at or above 85 percent and not below baseline; every changed line is executed.

| File | Baseline line coverage | Post-change line coverage | Threshold | Result |
|---|---|---|---|---|
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 100% (77/77) | 100% (87/87) | 85% | PASS |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 97.41% (113/116) | 97.73% (129/132) | 85% | PASS |

Changed functions:
- `Test-PrAuthorAllowlistForm` (allowlist hook): every line executed; the file reports 0 missed lines.
- `Test-PrAuthorAbsoluteBodyPathToken` (allowlist hook, new): every line executed; the file reports 0 missed lines.
- `ConvertFrom-PrAuthorHookTargetResult` (helpers, new): every line executed; no missed line lies in this function.
- `Resolve-PrAuthorWorktreeTarget` (helpers, body replaced): every line executed; no missed line lies in this function.

Missed lines in the helpers file after the change: 308, 324, and 347. All three are error returns inside `Test-PrAuthorReceiptVerification` (receipt not valid JSON, body bytes unreadable, and unparseable `created_at`). That function is unchanged (FUNCTIONS_UNCHANGED: 2/2 in scope-check). These are the baseline misses 254, 270, and 293, moved down by the 54 lines inserted above them. No changed line is missed. PowerShell has no branch-coverage gate.
