# File-Size Baseline (Remediation Cycle 2026-08-26T02-36)

Timestamp: 2026-08-26T03-19

Stamp substitution: the plan fixes the evidence filename stamp at `2026-08-26T02-36`; the `Timestamp:`
field records the actual execution stamp.

Command: `pwsh -NoProfile -Command 'Get-ChildItem -Path ./scripts/dev-tools/Invoke-ReleaseVerification.ps1, ./scripts/dev-tools/Invoke-ReleaseTagPush.ps1, ./scripts/dev-tools/Invoke-ReleaseReconciliation.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | ForEach-Object { $_.Name + " " + @(Get-Content -LiteralPath $_.FullName).Count }'`

EXIT_CODE: 0

Output Summary: one integer line count per path, as reported by the command.

| Path | Lines |
|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 499 |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | 278 |
| `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` | 166 |
| `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | 346 |
| `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | 491 |

`scripts/dev-tools/Invoke-ReleaseVerification.ps1` stands at 499 lines against the 500-line cap from
`.claude/rules/general-code-change.md`, with one line of headroom. That is the constraint forcing the
Phase 1 module split.
